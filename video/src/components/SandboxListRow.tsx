import React from "react";
import { COLORS, FONT, ttlColor } from "../theme";
import type { Sandbox } from "../data";
import { StatusDot } from "./atoms";

export const SandboxListRow: React.FC<{
  sandbox: Sandbox;
  selected?: boolean;
  highlight?: number; // 1 = bright, used for reveals
  pulse?: number;
  width?: number | string;
  showTTLBar?: boolean;
}> = ({ sandbox, selected, highlight = 1, pulse = 0, width = "100%", showTTLBar = true }) => {
  const ttl = ttlColor(sandbox.ttlFraction);
  return (
    <div
      style={{
        width,
        display: "flex",
        alignItems: "center",
        gap: 13,
        padding: "12px 14px",
        borderRadius: 12,
        background: selected ? "rgba(36,150,237,0.16)" : "transparent",
        border: `1px solid ${selected ? "rgba(36,150,237,0.42)" : "transparent"}`,
        opacity: highlight,
      }}
    >
      <StatusDot running={sandbox.running} pulse={pulse} size={9} />
      <div style={{ display: "flex", flexDirection: "column", gap: 4, minWidth: 0, flex: 1 }}>
        <div style={{ display: "flex", alignItems: "baseline", gap: 8 }}>
          <span
            style={{
              fontFamily: FONT,
              fontSize: 18,
              fontWeight: 600,
              color: COLORS.text,
              whiteSpace: "nowrap",
            }}
          >
            {sandbox.name}
          </span>
          <span
            style={{
              fontFamily: FONT,
              fontSize: 13,
              fontWeight: 500,
              color: COLORS.textFaint,
              whiteSpace: "nowrap",
            }}
          >
            {sandbox.agent}
          </span>
        </div>
        {showTTLBar ? (
          <div
            style={{
              width: "100%",
              height: 4,
              borderRadius: 4,
              background: "rgba(255,255,255,0.08)",
              overflow: "hidden",
            }}
          >
            <div
              style={{
                width: `${sandbox.ttlFraction * 100}%`,
                height: "100%",
                background: ttl,
                boxShadow: `0 0 8px ${ttl}aa`,
              }}
            />
          </div>
        ) : null}
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: 10, flex: "0 0 auto" }}>
        <span
          style={{
            fontFamily: FONT,
            fontSize: 16,
            fontWeight: 600,
            color: ttl,
            fontVariantNumeric: "tabular-nums",
          }}
        >
          {sandbox.ttlLabel}
        </span>
        <span style={{ display: "inline-flex", opacity: 0.7 }}>
          <TerminalGlyph color={COLORS.textDim} size={17} />
        </span>
      </div>
    </div>
  );
};

export const TerminalGlyph: React.FC<{ color?: string; size?: number }> = ({
  color = COLORS.text,
  size = 18,
}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
    <rect x="2.5" y="4" width="19" height="16" rx="3" stroke={color} strokeWidth="1.7" />
    <path
      d="M6.5 9.5l3 2.5-3 2.5"
      stroke={color}
      strokeWidth="1.7"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    <path d="M12 15h5" stroke={color} strokeWidth="1.7" strokeLinecap="round" />
  </svg>
);
