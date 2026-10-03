import React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig, interpolate } from "remotion";
import { COLORS, FONT, MONO } from "../theme";
import { AppIcon } from "../components/Logo";
import { rise, pop } from "../anim";

const GitHubMark: React.FC<{ size?: number; color?: string }> = ({ size = 26, color = COLORS.text }) => (
  <svg width={size} height={size} viewBox="0 0 16 16" fill={color}>
    <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82a7.4 7.4 0 012-.27c.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0016 8c0-4.42-3.58-8-8-8z" />
  </svg>
);

export const S7Outro: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          gap: 26,
          marginTop: -10,
        }}
      >
        <div style={pop(f, fps, 0, { from: 0.72 })}>
          <AppIcon size={132} glow={1.3} />
        </div>
        <div
          style={{
            ...rise(f, 14, 20, 24),
            fontFamily: FONT,
            fontSize: 76,
            fontWeight: 700,
            letterSpacing: -2.6,
            color: COLORS.text,
          }}
        >
          Sbx Monitor
        </div>

        <div
          style={{
            ...rise(f, 26, 20, 22),
            display: "flex",
            alignItems: "center",
            gap: 13,
            padding: "15px 26px",
            borderRadius: 999,
            background: "rgba(255,255,255,0.05)",
            border: `1px solid ${COLORS.strokeStrong}`,
          }}
        >
          <GitHubMark size={27} />
          <span style={{ fontFamily: MONO, fontSize: 25, fontWeight: 550, color: COLORS.text }}>
            github.com/restuhaqza/sbx-monitor
          </span>
        </div>

        <div
          style={{
            ...rise(f, 40, 20, 18),
            fontFamily: FONT,
            fontSize: 22,
            fontWeight: 500,
            color: COLORS.textDim,
          }}
        >
          MIT · macOS 14+ · Swift 5.9+ · built with SwiftTerm
        </div>

        <div
          style={{
            ...rise(f, 54, 20, 16),
            marginTop: 4,
            fontFamily: FONT,
            fontSize: 24,
            fontWeight: 650,
            color: COLORS.cyan,
          }}
        >
          ★ Star it on GitHub
        </div>
      </div>
    </AbsoluteFill>
  );
};
