# Sprite Assets - Placeholder

This prototype includes sprite code but requires actual pixel art PNG files to be added.

## Required Rock Sprites (sprites/rocks/)

Create 32x32 pixel art PNG files in `sprites/rocks/`:

### stone_rock.png (32x32)
- **Style**: Simple gray/beige rock
- **Colors**:
  - Base: #9E9E9E (gray)
  - Highlight: #BDBDBD (light gray)
  - Shadow: #757575 (dark gray)
- **Shape**: Rounded boulder with 2-3 visible facets
- **Details**: Simple shading, 1-2 small cracks

### granite_rock.png (32x32)
- **Style**: Darker speckled rock
- **Colors**:
  - Base: #616161 (dark gray)
  - Speckles: #424242 (very dark gray), #BDBDBD (light gray)
  - Highlight: #757575 (medium gray)
- **Shape**: More angular than stone_rock
- **Details**: 4-6 small colored speckles distributed across surface

## Required Mineral Sprites (sprites/minerals/)

Create 16x16 pixel art PNG files in `sprites/minerals/`:

### Ruby Sprites (Red - Triangle shape)
**ruby_small.png (16x16)**
- Shape: Upward-pointing triangle (8-10 pixels tall)
- Colors:
  - Base: #E57373 (red from minerals.json)
  - Highlight: #EF9A9A (light red)
  - Shadow: #C62828 (dark red)
- Style: Faceted gem with 2-3 visible faces

**ruby_large.png (16x16)**
- Same as ruby_small but slightly larger (10-12 pixels)
- More detailed facets (4-5 faces)
- Brighter highlight

### Sapphire Sprites (Blue - Square shape)
**sapphire_small.png (16x16)**
- Shape: Rotated square/diamond (8x8 pixels)
- Colors:
  - Base: #64B5F6 (blue from minerals.json)
  - Highlight: #90CAF9 (light blue)
  - Shadow: #1976D2 (dark blue)
- Style: Cubic crystal with 4 faces

**sapphire_large.png (16x16)**
- Same as sapphire_small but larger (10x10 pixels)
- More pronounced cubic structure
- Additional facet lines

### Emerald Sprites (Green - Circle shape)
**emerald_small.png (16x16)**
- Shape: Circle (8 pixel diameter)
- Colors:
  - Base: #81C784 (green from minerals.json)
  - Highlight: #A5D6A7 (light green)
  - Shadow: #388E3C (dark green)
- Style: Smooth rounded gem, 2-3 subtle highlight spots

**emerald_large.png (16x16)**
- Same as emerald_small but larger (11 pixel diameter)
- More defined highlight zones
- Subtle internal "star" pattern

## Pixel Art Specifications

- **Format**: PNG with transparency
- **Resolution**: Exactly 32x32 (rocks) or 16x16 (minerals)
- **Color depth**: 8-bit indexed color or 32-bit RGBA
- **Style**: Clean pixel art, no anti-aliasing on edges
- **Import Settings** (in Godot):
  - Filter: Nearest (for crisp pixels)
  - Repeat: Disabled
  - Mipmaps: Disabled

## Colorblind-Friendly Design

All minerals MUST be distinguishable by shape even in grayscale:
- Ruby = Triangle (colorblind users see shape)
- Sapphire = Square (colorblind users see shape)
- Emerald = Circle (colorblind users see shape)

## Fallback Behavior

Until PNG files are added, the game will use ColorRect placeholders. The sprites are optional for testing but recommended for the full experience.

## Free Pixel Art Tools

- **Editors**: Aseprite (paid), Pixelorama (free), GIMP (free)
- **References**: lospec.com/palette-list (for color palettes)
- **Tutorials**: "How to draw pixel art gems" on YouTube

## Quick Start for Non-Artists

If you're not an artist, you can:
1. Use the ColorRect placeholders (current state)
2. Commission sprites on fiverr.com or itch.io
3. Use free sprite packs from itch.io (search "pixel art gems")
4. Generate with AI (then manually edit to 16x16/32x32)
