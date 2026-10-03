import React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig, interpolate } from "remotion";
import { AppIcon } from "../components/Logo";
import { COLORS, FONT } from "../theme";
import { rise } from "../anim";

const Pill: React.FC<{ children: React.ReactNode; start: number; frame: number }> = ({
  children,
  start,
  frame,
}) => (
  <div
    style={{
      ...rise(frame, start, 16, 14),
      padding: "9px 18px",
      borderRadius: 999,
      background: "rgba(255,255,255,0.05)",
      border: `1px solid ${COLORS.stroke}`,
      fontFamily: FONT,
      fontSize: 18,
      fontWeight: 500,
      color: COLORS.textDim,
    }}
  >
    {children}
  </div>
);

export const S1Title: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();

  const iconScale = interpolate(f, [4, 30], [0.6, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: (t) => 1 - Math.pow(1 - t, 3),
  });
  const iconOpacity = interpolate(f, [4, 20], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 30,
          marginTop: -30,
        }}
      >
        <div style={{ transform: `scale(${iconScale})`, opacity: iconOpacity }}>
          <AppIcon size={150} glow={1.2} />
        </div>
        <div
          style={{
            ...rise(f, 26, 20, 26),
            fontFamily: FONT,
            fontSize: 92,
            fontWeight: 700,
            letterSpacing: -3.5,
            color: COLORS.text,
          }}
        >
          Sbx Monitor
        </div>
        <div
          style={{
            ...rise(f, 38, 20, 22),
            fontFamily: FONT,
            fontSize: 32,
            fontWeight: 450,
            color: COLORS.textDim,
            letterSpacing: -0.4,
          }}
        >
          Docker Sandboxes cloud, at a glance.
        </div>
        <div style={{ display: "flex", gap: 14, marginTop: 12 }}>
          <Pill start={46} frame={f}>macOS 14+</Pill>
          <Pill start={52} frame={f}>Menu bar &amp; window</Pill>
          <Pill start={58} frame={f}>Built-in terminal</Pill>
        </div>
      </div>
    </AbsoluteFill>
  );
};
