import React from "react";
import { AbsoluteFill, useCurrentFrame, interpolate } from "remotion";
import { COLORS, FONT } from "../theme";
import { FLEET } from "../data";
import { SandboxListRow } from "../components/SandboxListRow";
import { TrayGlyph } from "../components/Logo";
import { rise } from "../anim";
import { Caption } from "../components/Caption";

const MenuBarGlyph: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <span style={{ display: "inline-flex", alignItems: "center" }}>{children}</span>
);

const Wifi: React.FC = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
    <path d="M3 9.5C6 6.8 9.2 5.5 12 5.5s6 1.3 9 4" stroke="#D7DEE9" strokeWidth="1.8" strokeLinecap="round" />
    <path d="M6.2 12.8C8 11.2 10 10.4 12 10.4s4 .8 5.8 2.4" stroke="#D7DEE9" strokeWidth="1.8" strokeLinecap="round" />
    <circle cx="12" cy="16.5" r="1.7" fill="#D7DEE9" />
  </svg>
);

const Battery: React.FC = () => (
  <span style={{ display: "inline-flex", alignItems: "center", gap: 3 }}>
    <span style={{ width: 30, height: 14, border: "1.5px solid #8B97A8", borderRadius: 4, padding: 2 }}>
      <span style={{ display: "block", width: "78%", height: "100%", background: "#D7DEE9", borderRadius: 1.5 }} />
    </span>
    <span style={{ width: 2, height: 6, background: "#8B97A8", borderRadius: 1 }} />
  </span>
);

const Search: React.FC = () => (
  <svg width="17" height="17" viewBox="0 0 24 24" fill="none">
    <circle cx="10.5" cy="10.5" r="6" stroke="#D7DEE9" strokeWidth="1.9" />
    <path d="M15.5 15.5L20 20" stroke="#D7DEE9" strokeWidth="1.9" strokeLinecap="round" />
  </svg>
);

const ControlCenter: React.FC = () => (
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
    <rect x="3" y="3" width="18" height="18" rx="5" stroke="#D7DEE9" strokeWidth="1.7" />
    <circle cx="9" cy="9.5" r="1.7" fill="#D7DEE9" />
    <circle cx="15" cy="14.5" r="1.7" fill="#D7DEE9" />
  </svg>
);

export const S3Tray: React.FC = () => {
  const f = useCurrentFrame();

  const bar = interpolate(f, [0, 24], [-44, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: (t) => 1 - Math.pow(1 - t, 3),
  });

  const trayPop = interpolate(f, [30, 46], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const popY = interpolate(f, [44, 66], [-24, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: (t) => 1 - Math.pow(1 - t, 3),
  });
  const popOpacity = interpolate(f, [44, 62], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // click ripple on the tray item
  const ripple = interpolate(f, [30, 46], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const runningCount = FLEET.filter((s) => s.running).length;
  const pulse = ((f - 60) % 45) / 45;

  return (
    <AbsoluteFill>
      {/* menu bar */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: 40,
          transform: `translateY(${bar}px)`,
          background: "rgba(16,19,25,0.72)",
          backdropFilter: "blur(24px)",
          borderBottom: "1px solid rgba(255,255,255,0.08)",
          display: "flex",
          alignItems: "center",
          padding: "0 18px",
          gap: 22,
          fontFamily: FONT,
          fontSize: 17,
          color: "#D7DEE9",
          zIndex: 5,
        }}
      >
        <span style={{ fontWeight: 700 }}>Finder</span>
        {["File", "Edit", "View", "Window", "Help"].map((m) => (
          <span key={m} style={{ opacity: 0.9 }}>{m}</span>
        ))}
        <div style={{ marginLeft: "auto", display: "flex", alignItems: "center", gap: 20 }}>
          <MenuBarGlyph><Wifi /></MenuBarGlyph>
          <MenuBarGlyph><Battery /></MenuBarGlyph>
          <MenuBarGlyph><Search /></MenuBarGlyph>
          <MenuBarGlyph><ControlCenter /></MenuBarGlyph>
          {/* tray item */}
          <span style={{ position: "relative", display: "inline-flex", alignItems: "center", opacity: trayPop }}>
            <TrayGlyph size={20} color="#EAF0F8" />
            <span
              style={{
                position: "absolute",
                top: -7,
                right: -9,
                minWidth: 17,
                height: 17,
                padding: "0 4px",
                borderRadius: 9,
                background: COLORS.docker,
                color: "white",
                fontSize: 11,
                fontWeight: 700,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                boxShadow: "0 0 0 2px rgba(16,19,25,0.9)",
              }}
            >
              {runningCount}
            </span>
            {ripple < 1 ? (
              <span
                style={{
                  position: "absolute",
                  left: "50%",
                  top: "50%",
                  width: 20 + ripple * 70,
                  height: 20 + ripple * 70,
                  marginLeft: -(10 + ripple * 35),
                  marginTop: -(10 + ripple * 35),
                  borderRadius: "50%",
                  border: "2px solid rgba(36,150,237,0.7)",
                  opacity: 1 - ripple,
                }}
              />
            ) : null}
          </span>
          <span style={{ fontVariantNumeric: "tabular-nums" }}>Tue 12:54</span>
        </div>
      </div>

      {/* popover */}
      <div
        style={{
          position: "absolute",
          top: 52,
          right: 180,
          width: 470,
          transform: `translateY(${popY}px) scale(${0.96 + popOpacity * 0.04})`,
          opacity: popOpacity,
          transformOrigin: "top right",
          borderRadius: 18,
          background: "rgba(22,27,36,0.9)",
          backdropFilter: "blur(30px)",
          border: `1px solid ${COLORS.strokeStrong}`,
          boxShadow: "0 40px 100px rgba(0,0,0,0.6)",
          padding: 12,
          zIndex: 4,
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 10,
            padding: "10px 12px 12px",
            borderBottom: `1px solid ${COLORS.stroke}`,
          }}
        >
          <TrayGlyph size={18} color={COLORS.docker} />
          <span style={{ fontFamily: FONT, fontSize: 16, fontWeight: 650, color: COLORS.text }}>
            Sbx Monitor
          </span>
          <span style={{ fontFamily: FONT, fontSize: 14, color: COLORS.textFaint, marginLeft: 2 }}>
            · {runningCount} running
          </span>
          <span
            style={{
              marginLeft: "auto",
              fontFamily: FONT,
              fontSize: 13,
              fontWeight: 600,
              color: COLORS.green,
            }}
          >
            Live
          </span>
        </div>

        <div style={{ padding: "8px 4px", display: "flex", flexDirection: "column", gap: 4 }}>
          {FLEET.map((s, i) => (
            <div key={s.id} style={{ ...rise(f, 56 + i * 9, 16, 16) }}>
              <SandboxListRow
                sandbox={s}
                selected={i === 0}
                pulse={i === 0 ? pulse : 0}
              />
            </div>
          ))}
        </div>

        <div
          style={{
            ...rise(f, 92, 16, 12),
            display: "flex",
            justifyContent: "center",
            padding: "11px 0 6px",
            marginTop: 4,
            borderTop: `1px solid ${COLORS.stroke}`,
            fontFamily: FONT,
            fontSize: 15,
            fontWeight: 600,
            color: COLORS.docker,
          }}
        >
          Open Dashboard
        </div>
      </div>

      <Caption
        text="It lives in your menu bar."
        sub="One glance shows the whole fleet — status, TTL, and agents."
        start={70}
      />
    </AbsoluteFill>
  );
};
