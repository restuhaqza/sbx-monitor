import React from "react";
import { AbsoluteFill, useCurrentFrame } from "remotion";
import { COLORS } from "../theme";

/**
 * Persistent dark backdrop with slow-moving colour blooms and a faint grid.
 * Deterministic: every value derives from the frame index.
 */
export const Backdrop: React.FC = () => {
  const f = useCurrentFrame();

  const blob = (
    x: number,
    y: number,
    size: number,
    color: string,
    phase: number,
    drift: number,
  ): React.CSSProperties => ({
    position: "absolute",
    left: `calc(${x}% + ${Math.sin((f + phase) / 90) * drift}px)`,
    top: `calc(${y}% + ${Math.cos((f + phase) / 110) * drift}px)`,
    width: size,
    height: size,
    borderRadius: "50%",
    background: `radial-gradient(circle at center, ${color} 0%, transparent 68%)`,
    filter: "blur(40px)",
    opacity: 0.55,
  });

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(160deg, ${COLORS.bg1} 0%, ${COLORS.bg0} 55%, #05070A 100%)`,
        overflow: "hidden",
      }}
    >
      <div style={blob(-6, -10, 900, "rgba(36,150,237,0.42)", 0, 30)} />
      <div style={blob(78, 8, 780, "rgba(34,211,238,0.24)", 260, 24)} />
      <div style={blob(46, 82, 900, "rgba(167,139,250,0.18)", 520, 28)} />

      {/* faint grid */}
      <AbsoluteFill
        style={{
          backgroundImage:
            "linear-gradient(rgba(255,255,255,0.035) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.035) 1px, transparent 1px)",
          backgroundSize: "64px 64px",
          transform: `translateY(${(f * 0.15) % 64}px)`,
          maskImage:
            "radial-gradient(ellipse 80% 70% at 50% 45%, black 30%, transparent 78%)",
          WebkitMaskImage:
            "radial-gradient(ellipse 80% 70% at 50% 45%, black 30%, transparent 78%)",
        }}
      />

      {/* vignette */}
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(ellipse at center, transparent 45%, rgba(0,0,0,0.55) 100%)",
        }}
      />
      {/* subtle film grain */}
      <AbsoluteFill style={{ opacity: 0.05, mixBlendMode: "overlay" }}>
        <div
          style={{
            width: "100%",
            height: "100%",
            backgroundImage:
              "repeating-conic-gradient(from 0deg, rgba(255,255,255,0.5) 0deg 1deg, transparent 1deg 2deg)",
            backgroundSize: "3px 3px",
            transform: `translate(${(f * 7) % 3}px, ${(f * 13) % 3}px)`,
          }}
        />
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
