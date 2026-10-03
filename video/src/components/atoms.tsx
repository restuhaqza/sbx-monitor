import React from "react";
import { COLORS, FONT, ttlColor } from "../theme";

export const StatusDot: React.FC<{
  running: boolean;
  pulse?: number;
  size?: number;
}> = ({ running, pulse = 0, size = 9 }) => {
  const color = running ? COLORS.green : COLORS.textFaint;
  return (
    <span
      style={{ position: "relative", width: size, height: size, display: "inline-block", flex: "0 0 auto" }}
    >
      {running ? (
        <span
          style={{
            position: "absolute",
            inset: -pulse * 8,
            borderRadius: "50%",
            background: color,
            opacity: Math.max(0, 0.35 * (1 - pulse)),
            filter: "blur(3px)",
          }}
        />
      ) : null}
      <span
        style={{
          position: "absolute",
          inset: 0,
          borderRadius: "50%",
          background: color,
          boxShadow: running ? `0 0 10px ${color}` : "none",
        }}
      />
    </span>
  );
};

/** Circular TTL countdown ring. `fraction` 1 → full ring, 0 → empty. */
export const TTLRing: React.FC<{
  fraction: number;
  size: number;
  stroke?: number;
  label?: string;
  caption?: string;
}> = ({ fraction, size, stroke = 10, label, caption }) => {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const color = ttlColor(fraction);
  return (
    <div style={{ position: "relative", width: size, height: size, flex: "0 0 auto" }}>
      <svg width={size} height={size} style={{ transform: "rotate(-90deg)" }}>
        <circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          fill="none"
          stroke="rgba(255,255,255,0.08)"
          strokeWidth={stroke}
        />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          fill="none"
          stroke={color}
          strokeWidth={stroke}
          strokeLinecap="round"
          strokeDasharray={c}
          strokeDashoffset={c * (1 - Math.max(0, Math.min(1, fraction)))}
          style={{ filter: `drop-shadow(0 0 8px ${color}88)` }}
        />
      </svg>
      <div
        style={{
          position: "absolute",
          inset: 0,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          gap: 2,
        }}
      >
        <div
          style={{
            fontFamily: FONT,
            fontSize: size * 0.22,
            fontWeight: 700,
            color: COLORS.text,
            letterSpacing: -0.5,
          }}
        >
          {label}
        </div>
        {caption ? (
          <div
            style={{
              fontFamily: FONT,
              fontSize: size * 0.095,
              fontWeight: 500,
              color: COLORS.textFaint,
              textTransform: "uppercase",
              letterSpacing: 1.2,
            }}
          >
            {caption}
          </div>
        ) : null}
      </div>
    </div>
  );
};

export const Chip: React.FC<{
  children: React.ReactNode;
  color?: string;
  mono?: boolean;
}> = ({ children, color = COLORS.textDim, mono }) => (
  <span
    style={{
      display: "inline-flex",
      alignItems: "center",
      gap: 7,
      padding: "6px 12px",
      borderRadius: 9,
      background: "rgba(255,255,255,0.05)",
      border: `1px solid ${COLORS.stroke}`,
      fontFamily: mono ? MONO_SAFE : FONT,
      fontSize: 15,
      fontWeight: 500,
      color,
      whiteSpace: "nowrap",
    }}
  >
    {children}
  </span>
);

const MONO_SAFE =
  '"SF Mono", "JetBrains Mono", "Menlo", "Consolas", monospace';
