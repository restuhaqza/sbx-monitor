# Video

The README feature tour is a code-rendered [Remotion](https://remotion.dev)
(React → video) project. The published output lives at the repo root in
[`assets/`](../assets/); this folder holds the source only.

**Published assets**

- `assets/sbx-monitor-promo.gif` — loops inline in the README
- `assets/poster.png` — still frame
- The full 40 s MP4 with sound ships as a **GitHub Release asset**
  (kept out of git history to keep clones small).

## Regenerate

```sh
cd video
npm install

# Regenerate source assets:
cp ../docs/icon.png public/icon.png
python3 tools/make_music.py public/music.wav
ffmpeg -y -i public/music.wav -codec:a libmp3lame -b:a 192k public/music.mp3

# Preview in the Remotion Studio:
npm run studio

# Render the final MP4 (reuses the installed Google Chrome):
npx remotion render src/index.ts SbxPromo out/sbx-monitor-promo.mp4 \
  --browser-executable="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Highlight GIF for the README:
ffmpeg -y -i out/sbx-monitor-promo.mp4 \
  -vf "select='between(t,0,0.7)+between(t,7.6,10.8)+between(t,14.4,17.1)+between(t,23.6,26.8)+between(t,36.2,38.4)',setpts=N/14/TB,fps=14,scale=800:-1:flags=lanczos" -an /tmp/hl.mp4
ffmpeg -y -i /tmp/hl.mp4 \
  -filter_complex "[0:v]fps=12,scale=760:-1:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128:stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
  -loop 0 out/sbx-monitor-promo.gif

cp out/sbx-monitor-promo.mp4 out/sbx-monitor-promo.gif out/poster.png ../assets/
```

Remotion normally downloads its own headless browser; `--browser-executable`
reuses the system Chrome. Omit it on CI and Remotion fetches one.

## Structure

| Path | Purpose |
| --- | --- |
| `src/Promo.tsx` | Master timeline (scene order + durations) and music track |
| `src/Root.tsx` | Composition registration (`SbxPromo`) |
| `src/theme.ts` | Colours, fonts, duration constants, TTL colour ramp |
| `src/anim.ts` | Deterministic motion helpers (fade/rise/pop) |
| `src/data.ts` | Mock sandbox fleet shown in the video |
| `src/components/` | Reused UI: backdrop, captions, window chrome, rows, atoms |
| `src/scenes/` | One file per scene (`S1`…`S7`) |
| `tools/make_music.py` | Standard-library synth for the music bed (no numpy) |

## Scenes (30 fps)

| Scene | Frames | Length |
| --- | --- | --- |
| `S1Title` — logo + tagline | 0–90 | 3 s |
| `S2Hook` — the problem | 90–240 | 5 s |
| `S3Tray` — menu bar + popover | 240–450 | 7 s |
| `S4Window` — dashboard window | 450–660 | 7 s |
| `S5Terminal` — embedded terminal | 660–900 | 8 s |
| `S6Actions` — TTL / stop / remove / notify | 900–1080 | 6 s |
| `S7Outro` — repo call to action | 1080–1200 | 4 s |

All motion is derived from the frame index, so renders are deterministic.

## Swapping the music

Drop any `public/music.mp3` in place (the composition references
`staticFile("music.mp3")`). The bundled bed is a synthesized placeholder — a
licensed track will sound better.
