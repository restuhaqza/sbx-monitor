import React from "react";
import { useCurrentFrame, interpolate } from "remotion";
import { COLORS, FONT } from "../theme";

/**
 * Bottom caption bar. Clean, high-contrast, silent-video friendly.
 */
export const Caption: React.FC<{
  text: string;
  sub?: string;
  start?: number;
}> = ({ text, sub, start = 0 }) => {
  const f = useCurrentFrame();
  const p = interpolate(f, [start, start + 14], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        position: "absolute",
        left: 0,
        right: 0,
        bottom: 52,
        display: "flex",
        justifyContent: "center",
        pointerEvents: "none",
      }}
    >
      <div
        style={{
          opacity: p,
          transform: `translateY(${(1 - p) * 18}px)`,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 8,
          padding: "16px 30px",
          borderRadius: 18,
          background: "rgba(10,13,18,0.62)",
          border: `1px solid ${COLORS.stroke}`,
          boxShadow: "0 18px 50px rgba(0,0,0,0.45)",
          maxWidth: 1280,
        }}
      >
        <div
          style={{
            fontFamily: FONT,
            fontSize: 34,
            fontWeight: 600,
            letterSpacing: -0.3,
            color: COLORS.text,
            textAlign: "center",
          }}
        >
          {text}
        </div>
        {sub ? (
          <div
            style={{
              fontFamily: FONT,
              fontSize: 21,
              fontWeight: 450,
              color: COLORS.textDim,
              textAlign: "center",
            }}
          >
            {sub}
          </div>
        ) : null}
      </div>
    </div>
  );
};
