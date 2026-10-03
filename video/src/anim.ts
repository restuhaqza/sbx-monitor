import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import type { CSSProperties } from "react";

/** Deterministic fade-in at `start`, over `dur` frames, clamped. */
export const fadeIn = (
  frame: number,
  start: number,
  dur: number,
): number =>
  interpolate(frame, [start, start + dur], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

/** Rise + fade reveal. Returns a style object. */
export const rise = (
  frame: number,
  start: number,
  dur = 18,
  distance = 26,
): CSSProperties => {
  const p = fadeIn(frame, start, dur);
  return {
    opacity: p,
    transform: `translateY(${(1 - p) * distance}px)`,
  };
};

/** Scale + fade pop, driven by a spring. Returns a style object. */
export const pop = (
  frame: number,
  fps: number,
  start: number,
  opts: { damping?: number; stiffness?: number; from?: number } = {},
): CSSProperties => {
  const { damping = 200, stiffness = 110, from = 0.86 } = opts;
  const s = spring({
    frame: frame - start,
    fps,
    config: { damping, stiffness, mass: 0.9 },
  });
  return {
    opacity: interpolate(s, [0, 0.4], [0, 1], {
      extrapolateLeft: "clamp",
      extrapolateRight: "clamp",
    }),
    transform: `scale(${from + (1 - from) * s})`,
  };
};

/** Scroll a value with easing independent of frame (for keyframe sequences). */
export const track = (
  frame: number,
  stops: [number, number][],
  ease: (t: number) => number = (t) => t,
): number => {
  const [f0, v0] = stops[0];
  if (frame <= f0) return v0;
  for (let i = 1; i < stops.length; i++) {
    const [f1, v1] = stops[i];
    if (frame <= f1) {
      const t = (frame - f0) / (f1 - f0);
      return interpolate(ease(t), [0, 1], [stops[i - 1][1], v1]);
    }
  }
  return stops[stops.length - 1][1];
};

/** Typewriter helper: how many characters of `text` to show at `frame`. */
export const typed = (
  frame: number,
  start: number,
  cps: number,
  text: string,
): string => {
  const n = Math.max(0, Math.floor(((frame - start) / FPS_) * cps));
  return text.slice(0, Math.min(text.length, n));
};

// Local fps constant so the helper stays pure without hooks.
const FPS_ = 30;

export const useRise = (start: number, dur = 18, distance = 26) => {
  const frame = useCurrentFrame();
  return rise(frame, start, dur, distance);
};

export const usePop = (
  start: number,
  opts?: { damping?: number; stiffness?: number; from?: number },
) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  return pop(frame, fps, start, opts);
};
