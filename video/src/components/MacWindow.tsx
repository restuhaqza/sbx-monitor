import React from "react";
import type { CSSProperties } from "react";
import { COLORS, FONT } from "../theme";

export const TrafficLights: React.FC<{ size?: number }> = ({ size = 13 }) => (
  <div style={{ display: "flex", gap: size * 0.65 }}>
    {["#FF5F57", "#FEBC2E", "#28C840"].map((c) => (
      <div
        key={c}
        style={{
          width: size,
          height: size,
          borderRadius: "50%",
          background: c,
          boxShadow: "inset 0 0 0 0.5px rgba(0,0,0,0.25)",
        }}
      />
    ))}
  </div>
);

export const MacWindow: React.FC<{
  title?: string;
  width: number | string;
  height?: number | string;
  children: React.ReactNode;
  style?: CSSProperties;
  titlebarRight?: React.ReactNode;
  bodyStyle?: CSSProperties;
}> = ({ title, width, height, children, style, titlebarRight, bodyStyle }) => {
  return (
    <div
      style={{
        width,
        height,
        borderRadius: 18,
        overflow: "hidden",
        background: "rgba(18,22,29,0.92)",
        border: `1px solid ${COLORS.strokeStrong}`,
        boxShadow:
          "0 40px 100px rgba(0,0,0,0.62), 0 0 0 1px rgba(255,255,255,0.03) inset",
        display: "flex",
        flexDirection: "column",
        ...style,
      }}
    >
      <div
        style={{
          height: 46,
          flex: "0 0 auto",
          display: "flex",
          alignItems: "center",
          padding: "0 16px",
          gap: 14,
          background:
            "linear-gradient(180deg, rgba(255,255,255,0.055), rgba(255,255,255,0.015))",
          borderBottom: `1px solid ${COLORS.stroke}`,
        }}
      >
        <TrafficLights />
        {title ? (
          <div
            style={{
              fontFamily: FONT,
              fontSize: 15,
              fontWeight: 600,
              color: COLORS.textDim,
              letterSpacing: 0.2,
            }}
          >
            {title}
          </div>
        ) : null}
        <div style={{ marginLeft: "auto", display: "flex", gap: 10 }}>
          {titlebarRight}
        </div>
      </div>
      <div style={{ flex: 1, minHeight: 0, ...bodyStyle }}>{children}</div>
    </div>
  );
};
