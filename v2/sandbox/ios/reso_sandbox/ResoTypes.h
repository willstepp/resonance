//
//  ResoTypes.h
//  gl_sandbox
//
//  Created by Daniel Stepp on 4/17/13.
//  Copyright (c) 2013 Monomyth Software. All rights reserved.
//

#ifndef gl_sandbox_ResoTypes_h
#define gl_sandbox_ResoTypes_h

typedef enum {
  Download,
  Upload
} MediaTransfer;

typedef enum {
  ThumbnailQueue,
  PreviewQueue,
  SoundQueue,
  MixQueue
} MediaTransferQueue;

typedef enum {
  Cloud,
  Queued,
  Downloading,
  Device
} SoundState;

typedef enum {
  PlayerMain,
  ModuleExpand,
  Visual,
  Timer,
  Mix,
  Share
} ResoAppState;

typedef enum {
  Horizontal,
  Vertical
} ResoOrientation;

typedef enum {
  Player,
  Recorder
} EngineType;

typedef enum {
  Reverb,
  Pitch,
  Distortion,
  Echo,
  Flange,
  EffectTypeCount
} EffectType;

typedef enum {
  //REVERB
  
  //Dry Level : Mix level of dry signal in output in mB. Ranges from -10000.0 to 0.0. Default is 0.
  Reverb_DryLevel,
  //Room : Room effect level at low frequencies in mB. Ranges from -10000.0 to 0.0. Default is -10000.0.
  Reverb_Room,
  //Room HF : Room effect high-frequency level re. low frequency level in mB. Ranges from -10000.0 to 0.0. Default is 0.0.
  Reverb_RoomHF,
  //Decay Time : Reverberation decay time at low-frequencies in seconds. Ranges from 0.1 to 20.0. Default is 1.0.
  Reverb_DecayTime,
  //Decay HF Ratio : High-frequency to low-frequency decay time ratio. Ranges from 0.1 to 2.0. Default is 0.5.
  Reverb_DecayHFRatio,
  //Reflections : Early reflections level relative to room effect in mB. Ranges from -10000.0 to 1000.0. Default is -10000.0.
  Reverb_ReflectionsLevel,
  //Reflect Delay : Delay time of first reflection in seconds. Ranges from 0.0 to 0.3. Default is 0.02.
  Reverb_ReflectionsDelay,
  //Reverb : Late reverberation level relative to room effect in mB. Ranges from -10000.0 to 2000.0. Default is 0.0.
  Reverb_ReverbLevel,
  //Reverb Delay : Late reverberation delay time relative to first reflection in seconds. Ranges from 0.0 to 0.1. Default is 0.04.
  Reverb_ReverbDelay,
  //Diffusion : Reverberation diffusion (echo density) in percent. Ranges from 0.0 to 100.0. Default is 100.0.
  Reverb_Diffusion,
  //Density : Reverberation density (modal density) in percent. Ranges from 0.0 to 100.0. Default is 100.0.
  Reverb_Density,
  //HF Reference : Reference high frequency in Hz. Ranges from 20.0 to 20000.0. Default is 5000.0.
  Reverb_HFReference,
  //Room LF : Room effect low-frequency level in mB. Ranges from -10000.0 to 0.0. Default is 0.0.
  Reverb_RoomLF,
  //LF Reference : Reference low-frequency in Hz. Ranges from 20.0 to 1000.0. Default is 250.0.
  Reverb_LFReference,
  
  
  //PITCH
  
  //Echo delay in ms. 10 to 5000. Default = 500.
  Echo_Delay,
  //Echo decay per delay. 0 to 1. 1.0 = No decay, 0.0 = total decay (ie simple 1 line delay). Default = 0.5.
  Echo_DecayRatio,
  //Maximum channels supported. 0 to 16. 0 = same as fmod's default output polyphony, 1 = mono, 2 = stereo etc. See remarks for more. Default = 0. It is suggested to leave at 0!
  Echo_MaxChannels,
  //Volume of original signal to pass to output. 0.0 to 1.0. Default = 1.0.
  Echo_DryMix,
  //Volume of echo signal to pass to output. 0.0 to 1.0. Default = 1.0.
  Echo_WetMix,
  
  
  //FLANGE
  
  //Volume of original signal to pass to output. 0.0 to 1.0. Default = 0.45.
  Flange_DryMix,
  //Volume of flange signal to pass to output. 0.0 to 1.0. Default = 0.55.
  Flange_WetMix,
  //Flange depth (percentage of 40ms delay). 0.01 to 1.0. Default = 1.0.
  Flange_Depth,
  //Flange speed in hz. 0.0 to 20.0. Default = 0.1.
  Flange_Rate,
  
  
  //DISTORTION
  
  //Distortion value. 0.0 to 1.0. Default = 0.5.
  Distortion_Level,
  
  
  //PITCH
  
  //Pitch value. 0.5 to 2.0. Default = 1.0. 0.5 = one octave down, 2.0 = one octave up. 1.0 does not change the pitch.
  Pitch_Value,
  //FFT window size. 256, 512, 1024, 2048, 4096. Default = 1024. Increase this to reduce 'smearing'. This effect is a warbling sound similar to when an mp3 is encoded at very low bitrates.
  Pitch_FFTSize,
  //Removed. Do not use. FMOD now uses 4 overlaps and cannot be changed.
  Pitch_Overlap,
  //Maximum channels supported. 0 to 16. 0 = same as fmod's default output polyphony, 1 = mono, 2 = stereo etc. See remarks for more. Default = 0. It is suggested to leave at 0!
  Pitch_MaxChannels,
  
  
  //COUNT
  EffectParameterCount
  
} EffectParameter;

typedef enum {
  Binaural,
  WhiteNoise,
  Unknown
} ToneType;

typedef enum {
  BinauralGap,
  Frequency
} ToneProperty;

typedef enum {
  Preview,
  One,
  Two,
  Three,
  Four,
  Five
} Module;

#endif
