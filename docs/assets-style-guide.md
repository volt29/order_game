# Assets Style Guide

**Project:** Order Game
**Version:** 1.0
**Date:** 2025-10-27
**Art Style:** 2D Pixel Art
**Target Resolution:** 1920x1080 (PC), 1080x1920 (Mobile Portrait)

This document defines the visual and audio style for all game assets.

---

## 1. Pixel Art Specifications

### 1.1 Base Resolution

- **Sprite Size:** 16x16 or 32x32 pixels (native)
- **Display Scale:** 2x–4x (renders at 32x32 to 128x128 on screen)
- **Pixel Grid:** Strict alignment (no sub-pixel positioning)
- **Anti-Aliasing:** None (hard edges, classic pixel art)

### 1.2 General Art Direction

**Mood:** Cozy, soft, inviting, minimalist
**References:**
- *Stardew Valley* (color warmth, character)
- *A Short Hike* (gentle environment design)
- *Celeste* (clean sprite work, readability)
- *Unpacking* (tidy aesthetic, satisfying visuals)

**Principles:**
1. **Readability First:** Every sprite must be identifiable at 32x32px from 2 meters away.
2. **Consistent Style:** All assets use same pixel density (no mixing 8x8 and 32x32).
3. **Limited Palette:** 8 core colors + shades (see Color Palette below).
4. **Soft Shapes:** Avoid harsh angles; prefer rounded corners on rocks/UI.

---

## 2. Color Palette

### 2.1 Primary Palette (Colorblind-Safe)

**All colors tested with Deuteranopia and Protanopia simulators.**

| Swatch | Color Name | Hex Code | RGB | Use Case | Accessibility Note |
|--------|------------|----------|-----|----------|-------------------|
| 🔴 | Soft Red | `#E57373` | 229, 115, 115 | Rubies, warm gems | High contrast vs. green/blue |
| 🔵 | Ocean Blue | `#64B5F6` | 100, 181, 246 | Sapphires, water gems | Safe with red/green |
| 🟢 | Forest Green | `#81C784` | 129, 199, 132 | Emeralds, nature gems | Distinguishable from red |
| 🟡 | Sunny Yellow | `#FFD54F` | 255, 213, 79 | Topazes, rare gems | High luminance |
| 🟣 | Royal Purple | `#BA68C8` | 186, 104, 200 | Amethysts, epic gems | Unique hue |
| ⚪ | Pearl White | `#EEEEEE` | 238, 238, 238 | Diamonds, ultra-rare | Maximum contrast |
| ⬛ | UI Gray | `#424242` | 66, 66, 66 | Backgrounds, bins | Neutral dark |
| 🟤 | Accent Cream | `#FFF8E1` | 255, 248, 225 | Highlights, text | Warm neutral |

### 2.2 Secondary Shades (Shadows/Highlights)

For each primary color, generate:
- **Shadow:** -30% brightness (multiply RGB by 0.7)
- **Highlight:** +20% brightness (add 20% toward white)

**Example (Soft Red):**
- Base: `#E57373` (229, 115, 115)
- Shadow: `#A05151` (160, 81, 81)
- Highlight: `#F19B9B` (241, 155, 155)

### 2.3 Colorblind Mode Overlays

When "Colorblind Mode" is enabled, add **pattern overlays** to gems:

| Gem Color | Pattern | Description |
|-----------|---------|-------------|
| Red (Ruby) | Horizontal stripes | 2px white lines, 4px spacing |
| Blue (Sapphire) | Diagonal dots | 3x3px white dots, 45° angle |
| Green (Emerald) | Vertical lines | 2px white lines, 3px spacing |
| Yellow (Topaz) | Checkerboard | 2x2px alternating white/yellow |
| Purple (Amethyst) | Cross-hatch | 2px diagonal grid |
| White (Diamond) | Solid fill | No pattern (already high contrast) |

**Implementation:** Use Godot `CanvasItem.draw_*` or shader to overlay patterns at runtime.

---

## 3. Sprite Assets

### 3.1 Rocks

**Base Size:** 32x32px (displayed at 64x64px on screen)

#### Stone Rock (Tier 0)
- **HP:** 1
- **Appearance:** Rounded rectangle, medium gray (`#9E9E9E`), simple black cracks (2px lines)
- **Animation States:**
  - `idle.png`: Static sprite
  - `crack_1.png`: 1 horizontal crack (not used, breaks in 1 hit)
  - `shatter.png`: 4-frame burst animation (rock splits into 4 triangular fragments)
- **Shatter Particles:** 6 gray dust puffs (8x8px each)

#### Granite Rock (Tier 1)
- **HP:** 2
- **Appearance:** Darker gray (`#757575`), speckled texture (add 10-15 white 1px dots), angular top
- **Animation States:**
  - `idle.png`: Static
  - `crack_1.png`: Deep vertical crack (3px black line)
  - `crack_2.png`: Second horizontal crack intersecting
  - `shatter.png`: 6-frame burst (larger fragments than Stone)
- **Shatter Particles:** 10 gray/white dust puffs

#### Marble Rock (Tier 2, Post-MVP)
- **HP:** 3
- **Appearance:** White base (`#F5F5F5`), gray veins (`#BDBDBD`, 2px flowing lines)
- **Animation States:**
  - `idle.png`
  - `crack_1.png`, `crack_2.png`, `crack_3.png`
  - `shatter.png`: Polished fragments with sparkle effect

### 3.2 Minerals

**Base Size:** 16x16px (displayed at 32x32px on screen)

**Shape Templates:**
1. **Circle:** 12px diameter, centered, 2px white shine (top-left)
2. **Triangle:** Equilateral, 14px sides, point-up, 1px white edge
3. **Square:** 12x12px, rotated 45° (diamond), 2px white corner shine
4. **Hexagon:** 12px width, flat-top, 1px white outline
5. **Star:** 5-pointed, 14px diameter, 2px white center

**Mineral Sprite List (MVP):**

| ID | Name | Color | Shape | Rarity | Sprite Notes |
|----|------|-------|-------|--------|--------------|
| `ruby_small` | Ruby Shard | Soft Red | Triangle | Common | Faceted, sharp point |
| `sapphire_small` | Sapphire | Ocean Blue | Circle | Common | Smooth, glossy |
| `emerald_small` | Emerald Cut | Forest Green | Square | Uncommon | Facets, geometric |
| `topaz_small` | Topaz Gem | Sunny Yellow | Hexagon | Rare | Crystal structure |
| `amethyst_small` | Amethyst Cluster | Royal Purple | Star | Rare | Cluster of small stars |
| `diamond_small` | Diamond | Pearl White | Square | Epic | Maximum shine, sparkle |

**Animation:**
- **Idle:** Gentle float (1px vertical bob, 1 second cycle)
- **Sparkle:** 4-frame twinkle (white particle, 200ms each frame)
- **Collect:** 6-frame trail (fading copies, 50ms each)

### 3.3 UI Elements

**Resolution:** Match screen resolution (1920x1080 native, scale for mobile)

#### Sorting Bins
- **Size:** 200x150px
- **States:**
  - **Empty (0/10):** Light gray (`#BDBDBD`), dashed border (2px), label text centered
  - **Filling (1-9/10):** Progress bar inside (green `#81C784`, fills from bottom)
  - **Full (10/10):** Golden glow (`#FFD54F` aura, 10px radius), checkmark icon (32x32px)
- **Labels:** 16px font, UI Gray, examples: "Red Gems", "Blue Gems", "All Triangles"

#### HUD
- **Score Counter:** 24px font, Pearl White, drop shadow (2px black), top-right (20px margin)
- **Settings Button:** 32x32px gear icon, UI Gray, hover: Accent Cream tint

#### Inventory Panel
- **Background:** Semi-transparent UI Gray (`#424242` at 80% alpha)
- **Mineral Icons:** 16x16px sprites, count text (12px font, white)
- **Layout:** Horizontal strip, 40px height, bottom of playfield

---

## 4. Animation Standards

### 4.1 Frame Rate
- **Target:** 12 FPS for sprite animations (retro feel)
- **Smooth Tweens:** Use Godot `Tween` for position/scale (60 FPS interpolation)

### 4.2 Key Animations

| Animation | Frames | Duration | Notes |
|-----------|--------|----------|-------|
| **Rock Shatter** | 4-6 | 300ms | Fragments fly outward, fade after 500ms |
| **Mineral Spawn** | 4 | 200ms | Alpha fade-in 0→1, scale 0.5→1.0 |
| **Bin Fill** | — | 500ms | Progress bar fills smoothly (tween) |
| **Bin Complete** | 50 particles | 1000ms | Sparkle burst, particles rise + fade |
| **Score Popup** | 3 | 400ms | Text scales 0.8→1.2→1.0, floats up 20px |

### 4.3 Particle Effects

**Sparkle Particle (Generic):**
- **Size:** 4x4px white square
- **Lifetime:** 500ms
- **Motion:** Random velocity (50-150px/s), slow down over time
- **Alpha:** Fades 1.0 → 0.0 over lifetime

**Shatter Dust:**
- **Size:** 8x8px gray circle
- **Lifetime:** 800ms
- **Motion:** Outward from rock center, gravity applies
- **Alpha:** Fades 0.8 → 0.0

---

## 5. Typography

### 5.1 Font Selection

**Primary Font:** [*m5x7*](https://managore.itch.io/m5x7) (free pixel font, 5x7 base)
- **Licensing:** Free for commercial use
- **Sizes:** 16px (body text), 24px (headers), 12px (small labels)
- **Fallback:** Godot default monospace (if m5x7 unavailable)

**Secondary Font:** [*PressStart2P*](https://fonts.google.com/specimen/Press+Start+2P) (retro feel)
- **Use:** Score counter, tutorial tooltips
- **Sizes:** 24px (score), 18px (tooltips)

### 5.2 Text Styling

- **Drop Shadow:** 2px offset (black, 50% alpha) for all UI text
- **Stroke:** 1px black outline for in-game floating text ("+10 Points")
- **Colors:** Pearl White (`#EEEEEE`) for general text, Sunny Yellow (`#FFD54F`) for bonuses

---

## 6. Audio Specifications

### 6.1 Sound Effects (SFX)

**Format:** `.wav` (uncompressed, 16-bit, 44.1 kHz)
**Length:** 0.1s–1.5s (short, punchy)
**Layering:** Max 8 concurrent SFX (engine limit)

**SFX List:**

| ID | Action | Description | Reference | Length |
|----|--------|-------------|-----------|--------|
| `sfx_rock_hit` | Rock Hit | Soft "thunk", mallet on stone | Foley: wooden mallet on concrete | 0.3s |
| `sfx_rock_break` | Rock Break | Crystalline shatter, mid-pitch "crrsh" | Glass breaking + rock crack blend | 0.8s |
| `sfx_mineral_collect` | Collect Mineral | Gentle "ping", glass chime | Wind chime (single note, C5) | 0.4s |
| `sfx_sort_correct` | Correct Sort | Warm "clink", gem into box | Marbles clinking in wooden box | 0.5s |
| `sfx_bin_complete` | Bin Complete | 3-note chime (C-E-G major) | Music box melody | 1.2s |
| `sfx_sort_error` | Mismatch Sort | Soft "boop", non-jarring | Muted rubber bounce | 0.3s |
| `sfx_ui_click` | Button Click | Light tap | Keyboard key press (mechanical) | 0.15s |

**Production Notes:**
- **No harsh transients:** Roll off >12kHz, compress lightly
- **Volume normalization:** Peak at -6dB (leave headroom)
- **Variation:** 2-3 variants per SFX (random pitch shift ±10%)

### 6.2 Music Tracks

**Format:** `.ogg` (Vorbis, 128 kbps, stereo)
**Length:** 90-180 seconds (seamless loop)
**BPM:** 45-60 (slow, relaxing)

**Track 1: "Gentle Quarry"** *(MVP)*
- **Mood:** Calm, neutral, safe
- **Instruments:** Ambient pads, soft piano, minimal strings
- **Structure:** Intro (8 bars) → Loop A (16 bars) → Loop B (16 bars) → Back to Loop A
- **Key:** C Major (no dissonance)
- **Dynamics:** pp–mf (very soft to medium soft, no loud sections)
- **Loop Point:** 120s mark, crossfade 2s

**Track 2: "Forest Whispers"** *(Post-MVP)*
- **Mood:** Serene, nature-inspired
- **Instruments:** Acoustic guitar, flute, bird chirps (sampled)
- **Key:** G Major
- **BPM:** 55

**Track 3: "Zen Mode"** *(Post-MVP)*
- **Mood:** Meditative, minimal
- **Instruments:** Single sustained synth pad, occasional bell
- **Key:** A Minor (somber but peaceful)
- **BPM:** 45

**Reference Tracks:**
- *Animal Crossing: New Horizons* – "1 AM" (minimal, peaceful)
- *Unpacking* – Soundtrack (lo-fi, unobtrusive)
- *A Short Hike* – "Climb to the Peak" (gentle progression)

**Mixing:**
- **EQ:** Roll off <100Hz (avoid bass rumble), boost 2-4kHz (presence)
- **Compression:** Light (2:1 ratio, -20dB threshold)
- **Reverb:** Large hall (30% wet, 2s decay)
- **Stereo Width:** 70% (not full 100%, leaves room for SFX)

---

## 7. Biome Visual Themes

### 7.1 Quarry Biome (MVP)

**Environment:**
- **Background:** Flat horizon line, 2-color gradient (light gray `#E0E0E0` sky → cream `#FFF8E1` ground)
- **Props:** 3-5 static rock piles (background layer, darker gray)
- **Lighting:** Neutral, even (no shadows)
- **Particles:** Occasional dust motes (5-10 on screen, slow drift)

**Rocks:** Stone (70%), Granite (30%)

### 7.2 Forest Biome (Post-MVP)

**Environment:**
- **Background:** Parallax trees (2 layers), dappled sunlight (yellow circles, 20% alpha)
- **Props:** Moss-covered logs, ferns (16x16px sprites)
- **Lighting:** Warm (green-yellow tint)
- **Particles:** Falling leaves (10-15 on screen, gentle sway)

**Rocks:** Granite (50%), Marble (30%), Stone (20%)

### 7.3 Cave Biome (Post-MVP)

**Environment:**
- **Background:** Dark gradient (black `#212121` → dark purple `#4A148C`)
- **Props:** Stalactites (32x64px), glowing crystals (animated pulse)
- **Lighting:** Cool (blue tint), dynamic (crystal glow sources)
- **Particles:** Dust, water droplets (sparkling)

**Rocks:** Marble (60%), Obsidian (new, 40%)

---

## 8. Asset Checklist (MVP)

**Mark ✅ when asset is finalized and exported.**

### Sprites

#### Rocks
- [ ] `stone_rock_idle.png` (32x32px)
- [ ] `stone_rock_shatter_001.png` – `_004.png` (4 frames)
- [ ] `granite_rock_idle.png` (32x32px)
- [ ] `granite_rock_crack1.png` (32x32px)
- [ ] `granite_rock_shatter_001.png` – `_006.png` (6 frames)

#### Minerals (6 types × 2 variants = 12 sprites)
- [ ] `ruby_small.png` (16x16px)
- [ ] `sapphire_small.png`
- [ ] `emerald_small.png`
- [ ] `topaz_small.png`
- [ ] `amethyst_small.png`
- [ ] `diamond_small.png`
- [ ] *(Repeat for `_large` variants if needed)*

#### UI
- [ ] `bin_empty.png` (200x150px)
- [ ] `bin_progress_bar.png` (180x20px, tiled)
- [ ] `bin_full_glow.png` (220x170px, additive blend)
- [ ] `settings_icon.png` (32x32px)
- [ ] `checkmark_icon.png` (32x32px)

#### Particles
- [ ] `sparkle_particle.png` (4x4px)
- [ ] `dust_particle.png` (8x8px)

### Audio

#### SFX
- [ ] `sfx_rock_hit.wav`
- [ ] `sfx_rock_break.wav`
- [ ] `sfx_mineral_collect.wav`
- [ ] `sfx_sort_correct.wav`
- [ ] `sfx_bin_complete.wav`
- [ ] `sfx_sort_error.wav`
- [ ] `sfx_ui_click.wav`

#### Music
- [ ] `music_gentle_quarry.ogg` (120s loop)

---

## 9. Asset Workflow

### 9.1 Sprite Creation

1. **Tool:** [Aseprite](https://www.aseprite.org/) (or [LibreSprite](https://libresprite.github.io/) for free alternative)
2. **Canvas:** 16x16 or 32x32px
3. **Palette:** Import `order_game_palette.ase` (8 base colors + shades)
4. **Export:**
   - Format: `.png` (indexed color, no alpha if opaque)
   - Naming: `category_name_state_frame.png` (e.g., `rock_stone_shatter_003.png`)
   - Destination: `assets/sprites/[category]/`

### 9.2 Audio Production

1. **Recording:** Use foley (real objects) or high-quality sample packs
2. **Editing:** [Audacity](https://www.audacityteam.org/) or [Reaper](https://www.reaper.fm/)
   - Trim silence (leave 50ms attack, 200ms release)
   - Normalize to -6dB
   - Export as `.wav` (16-bit, 44.1kHz)
3. **Music:** [LMMS](https://lmms.io/) or [Ableton Live]
   - Export as `.ogg` (Vorbis, 128kbps)
   - Test loop point (2s crossfade at seam)
4. **Destination:** `assets/audio/sfx/` or `assets/audio/music/`

### 9.3 Godot Import Settings

**Sprites:**
- **Filter:** Off (pixel art, no smoothing)
- **Mipmaps:** Off
- **Repeat:** Off

**Audio:**
- **SFX:** Import as `AudioStreamSample`, loop: Off
- **Music:** Import as `AudioStreamOggVorbis`, loop: On, loop offset: 0s

---

## 10. Style Testing & Approval

### 10.1 Colorblind Testing

**Tools:**
- [Coblis](https://www.color-blindness.com/coblis-color-blindness-simulator/) (upload sprite, test Deuteranopia/Protanopia)
- Godot Color Blind Shader (post-process test)

**Criteria:**
- All 6 gem colors distinguishable in Deuteranopia mode
- UI text readable at 70% contrast minimum

### 10.2 Readability Test

**Method:**
1. Display sprite at 32x32px on 1080p monitor
2. Stand 2 meters away
3. Identify sprite within 2 seconds

**Pass/Fail:** If 3/3 testers succeed → ✅ Pass

---

**End of Assets Style Guide.**
