# Audio Assets - Placeholder

This prototype includes audio code but requires actual audio files to be added.

## Required SFX Files (audio/sfx/)

Place the following WAV files in `audio/sfx/`:

1. **rock_break.wav**
   - Played when: Rock is destroyed by clicking
   - Suggested: Short crunch/shatter sound (0.3-0.5s)
   - Volume: Medium-high

2. **mineral_collect.wav**
   - Played when: Mineral is auto-collected
   - Suggested: Soft "plink" or "ding" (0.2-0.3s)
   - Volume: Medium

3. **sort_correct.wav**
   - Played when: Mineral successfully sorted into bin
   - Suggested: Satisfying "pop" or "click" (0.1-0.2s)
   - Volume: Medium

4. **bin_complete.wav**
   - Played when: Bin reaches capacity (10/10)
   - Suggested: Triumphant "chime" or "success" (0.5-1.0s)
   - Volume: Medium-high

5. **combo.wav**
   - Played when: 5-combo bonus triggered
   - Suggested: Energetic "whoosh" or "powerup" (0.3-0.5s)
   - Volume: High

## Required Music File (audio/music/)

Place the following OGG file in `audio/music/`:

1. **bgm_ambient.ogg**
   - Type: Looping background music
   - Mood: Calm, relaxing, meditative
   - Tempo: Slow (60-90 BPM)
   - Duration: 2-3 minutes (will loop)
   - Volume: Low (background level)
   - Reference style: Lo-fi, ambient, C418's Minecraft soundtrack

## Audio Specifications

- **SFX Format**: WAV (16-bit, 44.1kHz, mono or stereo)
- **Music Format**: OGG Vorbis (quality 5-7, stereo)
- **Colorblind Support**: All game feedback has visual + audio cues

## Temporary Solution

Until audio files are added, the game will function normally but be silent. All audio code is implemented and ready - just drop the files into the correct folders with matching filenames.

## Free Audio Resources

- **SFX**: freesound.org, zapsplat.com
- **Music**: freemusicarchive.org, incompetech.com
- **Tools**: Audacity (editing), LMMS (music creation), Bfxr (SFX generation)
