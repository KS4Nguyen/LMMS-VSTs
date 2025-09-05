// vst_ringmod.c
#include <math.h>
#include <string.h>
#include "aeffect.h"
#include "aeffectx.h"

/**
 * VST2.4 SDK
 * header wie aeffect.h/aeffectx.h
 * https://github.com/R-Tur/VST_SDK_2.4/blob/master/pluginterfaces/vst2.x/aeffectx.h
 */

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// --- Parameter-Indices
enum {
    kParamNote = 0,     // 0..127 (MIDI-Note als Float)
    kParamDetune,       // -100..+100 cents
    kParamMix,          // 0..1
    kParamGain,         // 0..2
    kNumParams
};

// --- Plugin-State
typedef struct {
    float params[kNumParams];
    float sr;
    float phaseL, phaseR;
    float phaseInc;          // aus aktueller Trägerfreq
    int   midiNote;          // -1 wenn keiner aktiv
    float targetFreq;
    float smoothedFreq;      // sanfter Übergang
} RingModState;

// --- Util: MIDI-Note -> Frequenz
static float midi_to_freq(int note, float detune_cents) {
    // f = 440 * 2^((note-69)/12) * 2^(detune/1200)
    double n = (double)note - 69.0;
    double f = 440.0 * pow(2.0, n/12.0) * pow(2.0, detune_cents/1200.0);
    return (float)f;
}

// --- Parameter-Helper (normalisiert <-> skaliert)
static float clampf(float x, float lo, float hi){ return x < lo ? lo : (x > hi ? hi : x); }

static float param_to_note(float p){ return 127.0f * clampf(p, 0.f, 1.f); }        // 0..127
static float note_to_param(float n){ return clampf(n/127.0f, 0.f, 1.f); }

static float param_to_detune(float p){ return -100.0f + 200.0f*clampf(p,0.f,1.f);} // -100..+100 cents
static float detune_to_param(float c){ return clampf((c+100.0f)/200.0f,0.f,1.f); }

static float param_to_mix(float p){ return clampf(p,0.f,1.f); }                    // 0..1
static float mix_to_param(float m){ return clampf(m,0.f,1.f); }

static float param_to_gain(float p){ return 2.0f*clampf(p,0.f,1.f); }              // 0..2
static float gain_to_param(float g){ return clampf(g/2.0f,0.f,1.f); }

// --- Dispatcher / Callbacks Vorab-Deklarationen
static VstIntPtr dispatcher(AEffect* e, VstInt32 op, VstInt32 idx, VstIntPtr val, void* ptr, float opt);
static void processReplacing(AEffect* e, float** in, float** out, VstInt32 samples);
static void setParameter(AEffect* e, VstInt32 idx, float val);
static float getParameter(AEffect* e, VstInt32 idx);

// --- AEffect-Erzeugung
static AEffect* createEffectInstance(audioMasterCallback audioMaster) {
    AEffect* effect = (AEffect*)calloc(1, sizeof(AEffect));
    RingModState* st = (RingModState*)calloc(1, sizeof(RingModState));

    effect->magic = kEffectMagic;
    effect->dispatcher = dispatcher;
    effect->processReplacing = processReplacing;
    effect->setParameter = setParameter;
    effect->getParameter = getParameter;

    effect->numInputs = 2;
    effect->numOutputs = 2;
    effect->numParams = kNumParams;
    effect->numPrograms = 1;

    effect->flags = effFlagsCanReplacing;

    effect->resvd1 = 0;
    effect->resvd2 = 0;
    effect->object = st;
    effect->user = NULL;

    // Default-Parameter
    st->params[kParamNote]   = note_to_param(57.0f); // A3=220 Hz als Start
    st->params[kParamDetune] = detune_to_param(0.0f);
    st->params[kParamMix]    = mix_to_param(1.0f);
    st->params[kParamGain]   = gain_to_param(1.0f);

    st->sr = 44100.0f;
    st->phaseL = st->phaseR = 0.0f;
    st->midiNote = -1;
    st->targetFreq = 220.0f;
    st->smoothedFreq = 220.0f;
    st->phaseInc = 2.0f * (float)M_PI * st->targetFreq / st->sr;

    return effect;
}

// --- VST Entry Points
#if defined(_WIN32)
__declspec(dllexport)
#endif
AEffect* VSTPluginMain(audioMasterCallback audioMaster) {
    if (!audioMaster(NULL, audioMasterVersion, 0, 0, NULL, 0.0f)) return NULL;
    return createEffectInstance(audioMaster);
}

#if defined(__APPLE__) && defined(__MACH__)
AEffect* main_macho(audioMasterCallback audioMaster) { return VSTPluginMain(audioMaster); }
#endif

#if defined(_WIN32)
__declspec(dllexport)
#endif
AEffect* main(audioMasterCallback audioMaster) { return VSTPluginMain(audioMaster); }

// --- Dispatcher
static VstIntPtr dispatcher(AEffect* e, VstInt32 op, VstInt32 idx, VstIntPtr val, void* ptr, float opt) {
    RingModState* st = (RingModState*)e->object;
    switch (op) {
        case effOpen: break;
        case effClose:
            free(st);
            free(e);
            break;
        case effSetSampleRate:
            st->sr = opt > 1.f ? opt : 44100.f;
            st->phaseInc = 2.0f * (float)M_PI * st->targetFreq / st->sr;
            break;
        case effSetBlockSize:
            // no-op
            break;
        case effMainsChanged:
            // val != 0 -> On, val == 0 -> Off
            break;
        case effGetVendorString:
            strncpy((char*)ptr, "YourName", kVstMaxVendorStrLen); return 1;
        case effGetProductString:
            strncpy((char*)ptr, "ChromaticRingMod", kVstMaxProductStrLen); return 1;
        case effGetVendorVersion:
            return 1000;
        case effCanDo:
            if (ptr && strcmp((char*)ptr, "receiveVstEvents") == 0) return 1;
            if (ptr && strcmp((char*)ptr, "receiveVstMidiEvent") == 0) return 1;
            return 0;
        case effProcessEvents: {
            // MIDI verarbeiten
            VstEvents* evs = (VstEvents*)ptr;
            for (VstInt32 i = 0; i < evs->numEvents; ++i) {
                if (evs->events[i]->type == kVstMidiType) {
                    VstMidiEvent* me = (VstMidiEvent*)evs->events[i];
                    unsigned char stByte = (unsigned char)me->midiData[0];
                    unsigned char d1 = (unsigned char)me->midiData[1];
                    unsigned char d2 = (unsigned char)me->midiData[2];
                    int status = stByte & 0xF0;
                    if (status == 0x90 && d2 > 0) { // NoteOn mit Velocity>0
                        st->midiNote = d1;
                    } else if (status == 0x80 || (status == 0x90 && d2 == 0)) { // NoteOff
                        if (st->midiNote == d1) st->midiNote = -1;
                    } else if (status == 0xB0 && d1 == 123) { // All Notes Off
                        st->midiNote = -1;
                    }
                }
            }
            return 1;
        }
        default: break;
    }
    return 0;
}

// --- Parameter setzen/lesen
static void setParameter(AEffect* e, VstInt32 idx, float val) {
    RingModState* st = (RingModState*)e->object;
    if (idx < 0 || idx >= kNumParams) return;
    st->params[idx] = clampf(val, 0.f, 1.f);

    // Ziel-Frequenz updaten (sanftes Gleiten im Prozess)
    int note = (st->midiNote >= 0) ? st->midiNote : (int)roundf(param_to_note(st->params[kParamNote]));
    float det = param_to_detune(st->params[kParamDetune]);
    st->targetFreq = midi_to_freq(note, det);
}

static float getParameter(AEffect* e, VstInt32 idx) {
    RingModState* st = (RingModState*)e->object;
    if (idx < 0 || idx >= kNumParams) return 0.f;
    return st->params[idx];
}

// --- Signalverarbeitung
static void processReplacing(AEffect* e, float** in, float** out, VstInt32 n) {
    RingModState* st = (RingModState*)e->object;

    float* inL = in[0];  float* inR = in[1];
    float* outL = out[0]; float* outR = out[1];

    float mix  = param_to_mix(st->params[kParamMix]);
    float gain = param_to_gain(st->params[kParamGain]);

    // Frequenz-Glide (sanft, samplegenau)
    const float glide = 0.0015f; // ~1.5 ms Zeitkonstante
    for (VstInt32 i = 0; i < n; ++i) {
        // Update targetFreq ggf. durch aktive MIDI-Note
        int curNote = (st->midiNote >= 0) ? st->midiNote : (int)roundf(param_to_note(st->params[kParamNote]));
        float det = param_to_detune(st->params[kParamDetune]);
        st->targetFreq = midi_to_freq(curNote, det);

        st->smoothedFreq += (st->targetFreq - st->smoothedFreq) * glide;
        st->phaseInc = 2.0f * (float)M_PI * st->smoothedFreq / st->sr;

        // Phasen inkrementieren
        st->phaseL += st->phaseInc;
        st->phaseR += st->phaseInc;
        if (st->phaseL > 2.0f*(float)M_PI) st->phaseL -= 2.0f*(float)M_PI;
        if (st->phaseR > 2.0f*(float)M_PI) st->phaseR -= 2.0f*(float)M_PI;

        float cL = sinf(st->phaseL);
        float cR = sinf(st->phaseR);

        float dryL = inL ? inL[i] : 0.f;
        float dryR = inR ? inR[i] : 0.f;

        float wetL = dryL * cL;
        float wetR = dryR * cR;

        outL[i] = gain * (dryL * (1.0f - mix) + wetL * mix);
        outR[i] = gain * (dryR * (1.0f - mix) + wetR * mix);
    }
}
