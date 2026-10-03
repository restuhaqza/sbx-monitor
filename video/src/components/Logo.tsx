import React from "react";
import { Img, staticFile } from "remotion";
import { COLORS, FONT } from "../theme";

export const AppIcon: React.FC<{ size: number; glow?: number }> = ({
  size,
  glow = 1,
}) => (
  <div
    style={{
      width: size,
      height: size,
      position: "relative",
      flex: "0 0 auto",
    }}
  >
    <div
      style={{
        position: "absolute",
        inset: -size * 0.35,
        borderRadius: "50%",
        background: `radial-gradient(circle, rgba(36,150,237,${0.4 * glow}) 0%, transparent 70%)`,
        filter: "blur(18px)",
      }}
    />
    <Img
      src={staticFile("icon.png")}
      style={{
        width: size,
        height: size,
        borderRadius: size * 0.22,
        position: "relative",
        boxShadow: `0 ${size * 0.14}px ${size * 0.34}px rgba(0,0,0,0.5)`,
      }}
    />
  </div>
);

/** Small macOS-style menu bar glyph used for the tray item. */
export const TrayGlyph: React.FC<{ size?: number; color?: string }> = ({
  size = 20,
  color = COLORS.text,
}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
    <rect
      x="2.5"
      y="4.5"
      width="19"
      height="15"
      rx="3"
      stroke={color}
      strokeWidth="1.8"
    />
    <path
      d="M2.5 9.2H21.5"
      stroke={color}
      strokeWidth="1.8"
      strokeLinecap="round"
    />
    <circle cx="6" cy="7" r="0.9" fill={color} />
    <path
      d="M8 14.5l2.4 2.4 4.6-4.8"
      stroke={color}
      strokeWidth="1.9"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  </svg>
);

export const LogoLockup: React.FC<{
  iconSize?: number;
  titleSize?: number;
  tagline?: string;
}> = ({ iconSize = 128, titleSize = 76, tagline }) => (
  <div
    style={{
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      gap: 26,
    }}
  >
    <AppIcon size={iconSize} />
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 12 }}>
      <div
        style={{
          fontFamily: FONT,
          fontSize: titleSize,
          fontWeight: 700,
          letterSpacing: -2,
          color: COLORS.text,
        }}
      >
        Sbx Monitor
      </div>
      {tagline ? (
        <div
          style={{
            fontFamily: FONT,
            fontSize: titleSize * 0.34,
            fontWeight: 450,
            color: COLORS.textDim,
            letterSpacing: -0.2,
          }}
        >
          {tagline}
        </div>
      ) : null}
    </div>
  </div>
);
