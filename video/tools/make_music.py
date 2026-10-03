#!/usr/bin/env python3
"""Synthesize a soft, minimal electronic music bed for the Sbx Monitor promo.

Pure standard library (no numpy). Writes a 16-bit stereo WAV, then the caller
encodes it. Deterministic (seeded) so re-runs match.

Design: warm pad on an Am - F - C - G loop, gentle sub, sparse plucks with
echo, and a very soft kick pulse for momentum. ~40 s, loopable.
"""
import array
import math
import random
import struct
import sys
import wave

SR = 44100
DUR = 40.0
N = int(SR * DUR)
random.seed(7)
TWO_PI = math.tau

CHORDS = [
    [110.00, 261.63, 329.63, 440.00],  # Am
    [87.31, 220.00, 261.63, 349.23],   # F
    [130.81, 164.81, 196.00, 261.63],  # C
    [98.00, 123.47, 146.83, 196.00],   # G
]
CHORD_LEN = 2.5
LOOP = len(CHORDS) * CHORD_LEN  # 10 s

mix = [0.0] * N


def add(pos, value):
    if 0 <= pos < N:
        mix[pos] += value


def chord_at(t):
    phase = (t % LOOP) / CHORD_LEN
    k = int(phase) % len(CHORDS)
    frac = phase - int(phase)
    return CHORDS[k], CHORDS[(k + 1) % len(CHORDS)], frac


# ---- 1. Pad: crossfaded chord tones, soft harmonics + slight detune ----
pad_gain = 0.14
xsec = 0.55  # seconds of crossfade between chords
seg = CHORD_LEN + xsec
n_segs = int(DUR / CHORD_LEN) + 2
for s in range(n_segs):
    start = s * CHORD_LEN
    tones = CHORDS[s % len(CHORDS)]
    length = int(seg * SR)
    for i in range(length):
        pos = int(start * SR) + i
        if pos >= N:
            break
        t = i / SR
        # trapezoid envelope
        env = min(t / 0.9, (seg - t) / 0.9, 1.0)
        if env <= 0:
            continue
        val = 0.0
        for j, f in enumerate(tones):
            amp = (1.0, 0.5, 0.28, 0.18)[j % 4]
            det = 1.0 + (0.0016 if (i + j) % 2 == 0 else -0.0016)
            val += amp * math.sin(TWO_PI * f * t)
            val += amp * 0.5 * math.sin(TWO_PI * f * det * t)
            val += amp * 0.16 * math.sin(TWO_PI * f * 2 * t)
        mix[pos] += val * env * pad_gain / len(tones)


# ---- 2. Sub bass: chord root, one octave down ----
for s in range(n_segs):
    start = s * CHORD_LEN
    root = CHORDS[s % len(CHORDS)][0] / 2.0
    length = int(seg * SR)
    for i in range(length):
        pos = int(start * SR) + i
        if pos >= N:
            break
        t = i / SR
        env = min(t / 0.9, (seg - t) / 0.9, 1.0)
        if env <= 0:
            continue
        mix[pos] += 0.16 * math.sin(TWO_PI * root * t) * env


# ---- 3. Plucks: sparse arpeggio with echo ----
step = 0.25  # eighth notes at 120 BPM
n_steps = int(DUR / step)
for k in range(n_steps):
    t0 = k * step
    tones, nxt, frac = chord_at(t0)
    if k % 4 == 3:
        continue  # leave space
    f = tones[(k * 3) % len(tones)] * 2.0
    if k % 8 in (5, 6):
        f *= 1.0
    start = int(t0 * SR)
    dur = int(0.5 * SR)
    for i in range(dur):
        pos = start + i
        if pos >= N:
            break
        t = i / SR
        env = math.exp(-t / 0.11)
        v = math.sin(TWO_PI * f * t) * env * 0.09
        mix[pos] += v
        # echo taps
        add(pos + int(0.375 * SR), v * 0.34)
        add(pos + int(0.75 * SR), v * 0.12)


# ---- 4. Soft kick pulse every beat ----
beat = 0.5
n_beats = int(DUR / beat)
for b in range(n_beats):
    start = int(b * beat * SR)
    dur = int(0.16 * SR)
    for i in range(dur):
        pos = start + i
        if pos >= N:
            break
        t = i / SR
        f = 47 + 90 * math.exp(-t / 0.03)
        env = math.exp(-t / 0.055)
        mix[pos] += 0.17 * math.sin(TWO_PI * f * t) * env


# ---- 5. Normalize, master fades ----
peak = max(abs(x) for x in mix) or 1.0
gain = 0.9 / peak
fade_in = int(1.0 * SR)
fade_out = int(3.5 * SR)
for i in range(N):
    g = mix[i] * gain
    if i < fade_in:
        g *= i / fade_in
    if i > N - fade_out:
        g *= (N - i) / fade_out
    mix[i] = g

# ---- 6. Write 16-bit stereo WAV ----
out = sys.argv[1] if len(sys.argv) > 1 else "public/music.wav"
samples = array.array("h")
for v in mix:
    s = int(max(-1.0, min(1.0, v)) * 32767)
    samples.append(s)
    samples.append(s)

with wave.open(out, "wb") as w:
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(samples.tobytes())

print(f"wrote {out}: {N} frames ({DUR:.1f}s)")
