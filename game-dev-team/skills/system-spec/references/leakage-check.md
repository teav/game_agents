# leakage-check

Run before locking any spec version.

## Regex

```
\b(Phaser|Godot|Unity|Unreal|Bun|Vite|Webpack|esbuild|WebGL|WebGPU|GDScript|GameObject|MonoBehaviour|Node2D|Sprite2D|tween|Tweens?|RAF|requestAnimationFrame|v8|JavaScriptCore|Metal|Vulkan|DirectX|OpenGL|GLSL|HLSL|TypeScript|JavaScript|TSConfig|GDExtension|MeshInstance|Signal\b|EventEmitter|EventTarget|Promise|async/await|setTimeout|setInterval|localStorage|sessionStorage|IndexedDB|fetch\(|XMLHttpRequest|Phaser\.Scene|Phaser\.GameObjects)\b
```

## Run

```bash
grep -nE '<regex above>' docs/game/spec/system-spec.md
```

Any hit is a bug.

## Replacements

| Leaked term             | Replace with                                              |
| ----------------------- | --------------------------------------------------------- |
| `Phaser.Scene`          | "state machine state" or "game phase"                     |
| `GameObject`            | "entity"                                                  |
| `Tween`                 | "interpolation over time" with start/end/duration         |
| `requestAnimationFrame` | "per-frame tick"                                          |
| `setTimeout`            | "scheduled event at T+N ms" or "tick-counted delay"       |
| `localStorage`          | "persistent key-value storage" (interface in Section 3)   |
| `WebGL` / `Metal`       | Describe what gets drawn, not the renderer                |
| `TypeScript`            | Describe the data shape; the type system is platform-tier |

## Exception

Engine names may appear in Section 11 (`at_risk` items) when describing why a feature might not fit on a specific stack. They may NOT appear in any other section.

## Manual checks beyond the regex

- Method names implying a specific API (e.g., "the spawn() callback")
- Data structures named after engine primitives (e.g., "the Scene tree")
- Implementation order only meaningful in a specific runtime

Decision rule: would a Godot developer reading this expect to find a direct equivalent in their engine? If no, rewrite.
