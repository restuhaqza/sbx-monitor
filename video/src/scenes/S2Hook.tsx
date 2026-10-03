import React from "react";
import { AbsoluteFill, useCurrentFrame, interpolate } from "remotion";
import { COLORS, FONT, ttlColor } from "../theme";
import { rise } from "../anim";
import { TTLRing, Chip } from "../components/atoms";

const Line: React.FC<{
  text: string;
  start: number;
  frame: number;
  color?: string;
}> = ({ text, start, frame, color = COLORS.text }) => (
  <div
    style={{
      ...rise(frame, start, 18, 30),
      fontFamily: FONT,
      fontSize: 62,
      fontWeight: 650,
      letterSpacing: -1.8,
      color,
    }}
  >
    {text}
  </div>
);

export const S2Hook: React.FC = () => {
  const f = useCurrentFrame();

  // A sandbox counting down to zero: 7m -> 0m over the scene.
  const secs = Math.max(0, Math.round(interpolate(f, [40, 132], [420, 0])));
  const mm = Math.floor(secs / 60);
  const ss = secs % 60;
  const frac = secs / 420;

  return (
    <AbsoluteFill
      style={{
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "center",
        gap: 120,
        padding: "0 140px 90px",
      }}
    >
      <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
        <Line text="Cloud sandboxes expire." start={6} frame={f} />
        <Line text="Ports get buried." start={30} frame={f} />
        <Line text="Fleets drift out of sight." start={54} frame={f} />
        <div
          style={{
            ...rise(f, 82, 20, 26),
            marginTop: 22,
            fontFamily: FONT,
            fontSize: 30,
            fontWeight: 500,
            color: COLORS.cyan,
          }}
        >
          Keeping track shouldn&apos;t be a full-time job.
        </div>
      </div>

      <div
        style={{
          opacity: interpolate(f, [20, 40], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
          transform: `translateY(${interpolate(f, [20, 44], [24, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          })}px)`,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 24,
          padding: "38px 44px",
          borderRadius: 24,
          background: "rgba(20,25,34,0.7)",
          border: `1px solid ${COLORS.stroke}`,
          boxShadow: "0 30px 80px rgba(0,0,0,0.5)",
          width: 380,
        }}
      >
        <div
          style={{
            fontFamily: FONT,
            fontSize: 16,
            fontWeight: 600,
            letterSpacing: 1.5,
            textTransform: "uppercase",
            color: COLORS.textFaint,
          }}
        >
          Expiring soon
        </div>
        <TTLRing
          fraction={frac}
          size={220}
          label={`${mm}:${ss.toString().padStart(2, "0")}`}
          caption="Time to live"
        />
        <div style={{ display: "flex", gap: 10 }}>
          <Chip color={COLORS.textDim}>ml-notebook</Chip>
          <Chip color={ttlColor(frac)} mono>expires</Chip>
        </div>
      </div>
    </AbsoluteFill>
  );
};
