# Performance Budget

**Project:** Order Game
**Version:** 1.0
**Date:** 2025-10-27
**Engine:** Godot 4.3+

This document defines performance targets, budgets, and optimization strategies for the Order Game MVP.

---

## 1. Target Platforms and Specifications

### 1.1 PC (Primary Platform)

| Spec Category | Minimum | Recommended | Notes |
|---------------|---------|-------------|-------|
| **OS** | Windows 10 64-bit, macOS 10.15, Ubuntu 20.04 | Windows 11, macOS 13, Ubuntu 22.04 | — |
| **CPU** | Intel i3-6100 (2 cores, 3.7 GHz) | Intel i5-8400 (6 cores) | Low CPU usage expected |
| **GPU** | Intel HD Graphics 530 | NVIDIA GTX 1050 | 2D pixel art, minimal GPU load |
| **RAM** | 2 GB | 4 GB | Godot 4 editor uses ~500 MB |
| **Storage** | 50 MB | 100 MB | Base game + 1 music track |
| **Display** | 1280x720 | 1920x1080 | Native resolution, no upscaling |

### 1.2 Web (HTML5 Export)

| Spec Category | Minimum | Recommended | Notes |
|---------------|---------|-------------|-------|
| **Browser** | Chrome 90+, Firefox 88+ | Chrome 110+, Firefox 105+ | WebGL 2.0 required |
| **CPU** | Dual-core 2.5 GHz | Quad-core 3.0 GHz | JavaScript single-threaded |
| **RAM** | 4 GB | 8 GB | Browser overhead ~1 GB |
| **Connection** | 5 Mbps | 10 Mbps | 20 MB initial download |

### 1.3 Mobile (Post-MVP)

| Spec Category | Minimum | Recommended | Notes |
|---------------|---------|-------------|-------|
| **OS** | Android 8.0, iOS 13 | Android 12, iOS 16 | — |
| **CPU** | Snapdragon 660, Apple A11 | Snapdragon 778G, Apple A14 | — |
| **GPU** | Adreno 512, Apple A11 GPU | Adreno 642, Apple A14 GPU | — |
| **RAM** | 3 GB | 6 GB | Background app kills <3 GB |
| **Display** | 720x1280 | 1080x1920 | Portrait orientation |

---

## 2. Performance Targets

### 2.1 Frame Rate (FPS)

| Platform | Target FPS | Warning Threshold | Critical Threshold | Notes |
|----------|-----------|-------------------|-------------------|-------|
| **PC (Desktop)** | 60 | 58 | 50 | VSync on, no drops |
| **Web (Chrome)** | 60 | 55 | 45 | May drop on weak CPUs |
| **Mobile (Post-MVP)** | 60 | 50 | 40 | Battery saver mode: 30 FPS acceptable |

**Measurement:**
- Godot Profiler: Monitor **Frame Time** (target: ≤16.67ms for 60 FPS)
- Stress test: Spawn 50 minerals, break 5 rocks simultaneously

### 2.2 Frame Time Budget (16.67ms @ 60 FPS)

| System | Allocated Time | % of Frame | Notes |
|--------|---------------|------------|-------|
| **Physics** | 5 ms | 30% | RigidBody2D updates, collision |
| **Rendering** | 4 ms | 24% | Draw calls, shader processing |
| **Scripts** | 3 ms | 18% | GDScript logic (sorting, scoring) |
| **Audio** | 1 ms | 6% | Mix 8 concurrent SFX |
| **Particles** | 2 ms | 12% | CPU particles (sparkles, dust) |
| **UI** | 1 ms | 6% | HUD updates, tweens |
| **Reserve** | 0.67 ms | 4% | Buffer for spikes |

**Critical Path:**
- **Physics time >7ms** → Disable physics on resting minerals
- **Draw calls >80** → Use TextureAtlas batching
- **Script time >5ms** → Profile GDScript, optimize hot loops

---

## 3. Resource Budgets

### 3.1 Memory Budget

| Category | Allocated | Notes |
|----------|-----------|-------|
| **Textures** | 50 MB | All sprites (rocks, minerals, UI) |
| **Audio** | 15 MB | 5 SFX (wav) + 1 music (ogg, 128kbps) |
| **Scripts** | 5 MB | GDScript source + compiled bytecode |
| **Scene Instances** | 20 MB | 100 Mineral nodes (pooled), 10 Rocks |
| **Save Data** | 1 MB | JSON save file (~10 KB typical) |
| **Total (Runtime)** | **~100 MB** | Godot engine overhead: ~150 MB |

**Web Export:**
- **WASM Download:** 20 MB (Godot 4 runtime + game)
- **Heap Size:** 256 MB (JavaScript memory)

**Measurement:**
- Godot Profiler → **Monitor** tab → **Video RAM** (texture memory)
- OS Task Manager → RAM usage (should stay <300 MB total)

### 3.2 Texture Memory

| Asset Type | Resolution | Format | Estimated Size | Count | Total |
|------------|-----------|--------|---------------|-------|-------|
| **Rocks** | 32x32 | RGBA8 | 4 KB each | 10 sprites | 40 KB |
| **Minerals** | 16x16 | RGBA8 | 1 KB each | 20 sprites | 20 KB |
| **UI Elements** | 200x150 (bins) | RGBA8 | 117 KB each | 5 sprites | 585 KB |
| **Backgrounds** | 1920x1080 | RGB8 (compressed) | 2 MB | 1 | 2 MB |
| **Particles** | 8x8 | RGBA8 | 256 B each | 5 sprites | 1.2 KB |
| **Total** | — | — | — | — | **~2.7 MB** |

**Optimization:**
- Use **TextureAtlas** to batch all mineral sprites into one 256x256 atlas (reduces draw calls)
- Compress backgrounds (VRAM Compressed, BPTC on PC, ASTC on mobile)
- Disable mipmaps for pixel art (saves 33% memory)

### 3.3 Audio Memory

| Asset Type | Format | Bitrate | Length | Size | Notes |
|------------|--------|---------|--------|------|-------|
| **SFX (×5)** | WAV (16-bit, 44.1 kHz) | 1411 kbps | 0.5s avg | 500 KB total | Uncompressed for low latency |
| **Music (×1)** | OGG (Vorbis) | 128 kbps | 120s | 1.9 MB | Compressed, seamless loop |
| **Total** | — | — | — | **~2.4 MB** | — |

**Streaming:**
- Music: Stream from disk (Godot `AudioStreamOggVorbis` auto-streams >1 MB files)
- SFX: Load into RAM (all SFX <100 KB each)

---

## 4. Performance Limits

### 4.1 On-Screen Entity Limits

| Entity Type | PC Target | Web Target | Mobile Target | Stress Limit | Notes |
|-------------|-----------|------------|---------------|--------------|-------|
| **Minerals (Active)** | 100 | 75 | 50 | 150 | RigidBody2D with physics |
| **Minerals (Resting)** | 200 | 150 | 100 | 300 | Physics disabled (static) |
| **Rocks** | 10 | 10 | 8 | 15 | Minimal impact (static sprites) |
| **Particles** | 200 | 150 | 100 | 300 | CPUParticles2D (dust, sparkles) |
| **Total Nodes** | 500 | 400 | 300 | 800 | Active nodes in scene tree |

**Enforcement:**
- **MineralSpawner:** Cap at 100 active minerals (PC). If limit reached, queue spawn for later.
- **Particle Pooling:** Reuse particle emitters (max 10 emitters, each 20 particles).

### 4.2 Draw Call Budget

| Platform | Target Draw Calls | Warning | Critical | Notes |
|----------|------------------|---------|----------|-------|
| **PC** | <50 | 80 | 100 | Batching via TextureAtlas |
| **Web** | <40 | 60 | 80 | WebGL driver overhead |
| **Mobile** | <30 | 50 | 70 | GPU fill-rate limited |

**Reduction Strategies:**
1. **TextureAtlas:** Batch all minerals into 1 atlas → 100 minerals = 1 draw call (not 100)
2. **MultiMesh (Optional):** Use `MultiMeshInstance2D` for minerals if >100 on screen
3. **UI Batching:** Use `CanvasItem.draw_*` for custom UI instead of separate `Sprite2D` nodes

**Measurement:**
- Godot Profiler → **Servers** tab → **Rendering > Draw Calls in Frame**

### 4.3 Physics Budget

| Metric | PC Target | Web Target | Mobile Target | Notes |
|--------|-----------|------------|---------------|-------|
| **Active RigidBody2D** | 100 | 75 | 50 | Per frame physics step |
| **Collision Checks** | 500 | 400 | 300 | Broad-phase checks |
| **Physics Time** | <5 ms | <7 ms | <10 ms | Per frame |

**Optimization:**
1. **Disable Physics on Rest:**
   ```gdscript
   func _physics_process(delta):
       if linear_velocity.length() < 10 and not is_resting:
           is_resting = true
           set_physics_process(false)  # Stop processing
   ```
2. **Collision Layers:**
   - Minerals: Layer 1 (collide with ground only, not each other)
   - Rocks: Layer 2 (static, no collisions)
   - Ground: Layer 3
3. **Spatial Hashing:** Godot's `PhysicsServer2D` auto-optimizes; ensure collision shapes are simple (circles, not polygons)

---

## 5. Audio Performance

### 5.1 Concurrent Audio Limits

| Platform | Max SFX Channels | Music Streams | Notes |
|----------|-----------------|---------------|-------|
| **PC** | 8 | 1 | Godot default |
| **Web** | 6 | 1 | Browser AudioContext limit |
| **Mobile** | 4 | 1 | Battery optimization |

**Enforcement:**
```gdscript
# AudioManager.gd
const MAX_SFX = 8
var active_sfx: Array[AudioStreamPlayer] = []

func play_sfx(sfx_id: String):
    if active_sfx.size() >= MAX_SFX:
        active_sfx[0].stop()  # Stop oldest SFX
        active_sfx.pop_front()

    var player = AudioStreamPlayer.new()
    player.stream = load("res://assets/audio/sfx/" + sfx_id + ".wav")
    player.play()
    active_sfx.append(player)
    add_child(player)
    player.finished.connect(func(): player.queue_free())
```

### 5.2 Audio Latency

| Platform | Target Latency | Acceptable | Notes |
|----------|---------------|------------|-------|
| **PC** | <10 ms | <30 ms | PulseAudio/WASAPI low latency |
| **Web** | <20 ms | <50 ms | Web Audio API buffer |
| **Mobile** | <30 ms | <70 ms | Hardware audio buffer |

**Godot Settings:**
- `Project Settings > Audio > Driver`: Default (auto-detect best)
- `Project Settings > Audio > Mix Rate`: 44100 Hz (standard)

---

## 6. Network Performance (Future Consideration)

**Not in MVP.** For future multiplayer/leaderboard features:

| Metric | Target | Notes |
|--------|--------|-------|
| **API Latency** | <200 ms | Save score to server |
| **Download Size** | <5 MB | Initial game bundle |
| **CDN Bandwidth** | 1 Mbps per user | Assuming 100 concurrent players |

---

## 7. Optimization Strategies

### 7.1 Object Pooling

**Problem:** Instantiating 100 minerals per session causes GC pauses (50-100ms spikes).

**Solution:** Pre-allocate 100 `Mineral` nodes at startup, reuse inactive ones.

**Implementation:** See `architecture.md` Section 5.1 (MineralPool).

**Benefit:**
- **Before:** 50ms GC spike every 10 rocks broken
- **After:** 0ms GC spikes, smooth 60 FPS

### 7.2 Texture Atlasing

**Problem:** 100 minerals = 100 draw calls (GPU bottleneck on web).

**Solution:** Pack all 16x16 mineral sprites into a single 256x256 atlas.

**Godot Workflow:**
1. Create `TextureAtlas` resource in editor
2. Import all `mineral_*.png` sprites
3. Set sprite `texture` to atlas, adjust `region_rect`

**Benefit:**
- **Before:** 100 draw calls
- **After:** 1 draw call (batched)

### 7.3 Level of Detail (LOD) for Particles

**Problem:** 200 sparkle particles at 60 FPS = heavy CPU load on weak devices.

**Solution:** Reduce particle count on low-end devices.

```gdscript
# Detect device tier
var particle_budget = 200  # PC
if OS.get_name() == "Web":
    particle_budget = 150
elif DisplayServer.window_get_size().x < 1280:  # Low-res = weak device
    particle_budget = 100

# Apply to CPUParticles2D
$SparkleEffect.amount = particle_budget
```

### 7.4 Disable V-Sync for Testing

**Godot Setting:**
- `Project Settings > Display > Window > V-Sync Mode`: Disabled (for profiling)
- Enable V-Sync for release (smooth experience)

---

## 8. Performance Testing Protocol

### 8.1 Automated Tests

**Tool:** GDScript benchmark script

```gdscript
# tests/benchmark_minerals.gd
extends Node

func _ready():
    var start_time = Time.get_ticks_msec()

    # Spawn 100 minerals
    for i in 100:
        MineralPool.spawn_mineral("ruby_small", Vector2(randf_range(0, 1920), 0))

    await get_tree().create_timer(5.0).timeout  # Let physics settle

    var end_time = Time.get_ticks_msec()
    var avg_fps = Engine.get_frames_per_second()

    print("Spawn time: ", end_time - start_time, "ms")
    print("Avg FPS: ", avg_fps)

    assert(avg_fps >= 55, "FPS too low!")
```

**Run:**
```bash
godot --headless --script res://tests/benchmark_minerals.gd
```

### 8.2 Manual Stress Tests

| Test Case | Steps | Pass Criteria |
|-----------|-------|---------------|
| **Mineral Flood** | Spawn 150 minerals at once | FPS ≥55 for 5 seconds |
| **Rapid Breaks** | Break 10 rocks in 2 seconds | No frame drops <50 FPS |
| **Long Session** | Play for 10 minutes | No memory leaks (RAM stable ±10%) |
| **Bin Spam** | Complete 20 bins in a row | Save system responsive (<100ms) |

### 8.3 Web-Specific Tests

| Test Case | Browser | Pass Criteria |
|-----------|---------|---------------|
| **Chrome 110** | Chrome on Windows 11 | 60 FPS, no audio glitches |
| **Firefox 105** | Firefox on Ubuntu 22.04 | 55+ FPS acceptable |
| **Safari 16** (Post-MVP) | Safari on macOS 13 | 50+ FPS acceptable |

**Known Issues:**
- Firefox: Slower physics than Chrome (acceptable if ≥55 FPS)
- Safari: WebGL 2.0 quirks (test input latency)

---

## 9. Performance Monitoring (Post-Release)

### 9.1 In-Game Metrics

**Display FPS Counter (Debug Mode):**
```gdscript
# In HUD.gd
func _process(delta):
    if OS.is_debug_build():
        $FPSLabel.text = "FPS: " + str(Engine.get_frames_per_second())
```

**Telemetry (Optional):**
- Track avg FPS per session
- Send to analytics server (e.g., Google Analytics Events)

### 9.2 Player Feedback

**Post-Session Survey:**
- "Did the game run smoothly?" (Yes/No)
- "Did you experience lag or stuttering?" (Yes/No)

**Threshold for Investigation:**
- >10% of players report lag → Profile bottleneck

---

## 10. Platform-Specific Optimizations

### 10.1 PC

**Strengths:** High CPU/GPU, ample RAM
**Focus:** Maximize visual quality (more particles, no LOD)

**Settings:**
- Particles: 200 max
- Minerals: 100 active
- V-Sync: On
- Fullscreen: Optional (windowed default)

### 10.2 Web (HTML5)

**Weaknesses:** JavaScript single-threaded, WebGL overhead
**Focus:** Reduce physics complexity, cap entities

**Settings:**
- Particles: 150 max
- Minerals: 75 active
- Disable screen shake (micro-stutter in some browsers)
- Audio: Preload all SFX (avoid streaming delays)

**Web-Specific Code:**
```gdscript
if OS.get_name() == "Web":
    $Camera2D.screen_shake_enabled = false
    MineralPool.MAX_ACTIVE = 75
```

### 10.3 Mobile (Post-MVP)

**Weaknesses:** Battery constraints, thermal throttling
**Focus:** Aggressive LOD, 30 FPS mode

**Settings:**
- Particles: 100 max
- Minerals: 50 active
- Target FPS: 60 (degrade to 30 if battery saver enabled)
- Texture resolution: Downscale to 512x512 max

**Battery Detection:**
```gdscript
if OS.is_low_processor_usage_mode_enabled():
    Engine.max_fps = 30  # Battery saver
```

---

## 11. Performance Checklist (Pre-Release)

**Mark ✅ before launch.**

### Frame Rate
- [ ] PC: 60 FPS stable with 100 minerals on screen
- [ ] Web (Chrome): 55+ FPS with 75 minerals
- [ ] No drops below 50 FPS during stress test (10 rocks broken at once)

### Memory
- [ ] RAM usage <300 MB (PC), <250 MB (Web)
- [ ] No memory leaks (10-minute session: RAM stable ±10%)
- [ ] Texture memory <50 MB (Godot Profiler verified)

### Physics
- [ ] Physics time <5 ms per frame (PC)
- [ ] Resting minerals have physics disabled (verified in profiler)
- [ ] No jitter or collision glitches

### Rendering
- [ ] Draw calls <50 (PC), <40 (Web)
- [ ] TextureAtlas used for minerals (verified: 1 draw call per 100 minerals)
- [ ] UI renders at 60 FPS (no UI lag)

### Audio
- [ ] Max 8 concurrent SFX (enforced in AudioManager)
- [ ] Music loops seamlessly (no click/pop at loop point)
- [ ] Audio latency <30 ms (PC), <50 ms (Web)

### Save System
- [ ] Save operation <100 ms (timed in Profiler)
- [ ] Load operation <200 ms (cold start)
- [ ] Corrupted save file handled gracefully (new game starts)

---

## 12. Degradation Strategy

**If performance targets not met, apply in order:**

1. **Reduce Particle Count:** 200 → 150 → 100
2. **Cap Active Minerals:** 100 → 75 → 50
3. **Disable Screen Shake:** Camera2D shake off
4. **Lower Audio Quality:** 44.1 kHz → 22.05 kHz (music only)
5. **Reduce Background Parallax Layers:** 2 layers → 1 layer
6. **Disable Ambient Particles:** Dust motes off

**Last Resort (Mobile Only):**
- Target 30 FPS instead of 60 FPS

---

## 13. Post-Launch Optimization Roadmap

**Week 1 Post-Launch:**
- Collect performance telemetry (avg FPS, platform distribution)
- Identify bottom 10% devices (lowest FPS)

**Week 2:**
- Profile slowest platform (likely Web/Firefox)
- Apply targeted optimizations (e.g., reduce physics iterations)

**Week 4:**
- Implement dynamic LOD system (auto-adjust particles based on FPS)

**Week 8:**
- Mobile port optimizations (Vulkan mobile renderer, texture compression)

---

**End of Performance Budget.**

## Appendix: Profiler Cheat Sheet

**Godot 4 Profiler Shortcuts:**

| Metric | Location in Profiler | Good | Warning | Critical |
|--------|---------------------|------|---------|----------|
| **FPS** | Monitor > FPS | 60 | 58 | 50 |
| **Frame Time** | Profiler > Frame Time | <16.67ms | >17ms | >20ms |
| **Physics Time** | Profiler > Physics Process | <5ms | >7ms | >10ms |
| **Draw Calls** | Servers > Rendering > Draw Calls | <50 | >80 | >100 |
| **VRAM** | Monitor > Video RAM | <50 MB | >80 MB | >100 MB |

**Quick Diagnostics:**
```gdscript
# Add to Main.gd for debug overlay
func _process(delta):
    if Input.is_action_just_pressed("ui_text_completion_query"):  # F1 key
        print("FPS: ", Engine.get_frames_per_second())
        print("Active Minerals: ", MineralPool.active_minerals.size())
        print("Physics Bodies: ", get_tree().get_nodes_in_group("physics").size())
```
