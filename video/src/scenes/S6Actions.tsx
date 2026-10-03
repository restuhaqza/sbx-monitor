import React from "react";
import { AbsoluteFill, useCurrentFrame, interpolate } from "remotion";
import { COLORS, FONT, MONO } from "../theme";
import { rise } from "../anim";
import { Caption } from "../components/Caption";
import { AppIcon } from "../components/Logo";

const ClockPlus: React.FC<{ color: string }> = ({ color }) => (
  <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
    <circle cx="11" cy="12" r="8.2" stroke={color} strokeWidth="1.8" />
    <path d="M11 7.5V12l3 1.8" stroke={color} strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" />
    <path d="M19 5v5M16.5 7.5h5" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
  </svg>
);
const StopIcon: React.FC<{ color: string }> = ({ color }) => (
  <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
    <rect x="4" y="4" width="16" height="16" rx="4" stroke={color} strokeWidth="1.8" />
    <rect x="9" y="9" width="6" height="6" rx="1.5" fill={color} />
  </svg>
);
const TrashIcon: React.FC<{ color: string }> = ({ color }) => (
  <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
    <path d="M4.5 6.5h15M9 6.5V5a1.5 1.5 0 011.5-1.5h3A1.5 1.5 0 0115 5v1.5" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
    <path d="M6.5 6.5l1 12a2 2 0 002 1.9h5a2 2 0 002-1.9l1-12" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
    <path d="M10 10.5v6M14 10.5v6" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
  </svg>
);
const BellIcon: React.FC<{ color: string }> = ({ color }) => (
  <svg width="30" height="30" viewBox="0 0 24 24" fill="none">
    <path d="M12 3.5a5.5 5.5 0 015.5 5.5v3.2l1.5 2.8H5l1.5-2.8V9A5.5 5.5 0 0112 3.5z" stroke={color} strokeWidth="1.8" strokeLinejoin="round" />
    <path d="M10 18.5a2 2 0 004 0" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
  </svg>
);

const ActionCard: React.FC<{
  icon: React.ReactNode;
  title: string;
  sub: string;
  tint: string;
  start: number;
  frame: number;
}> = ({ icon, title, sub, tint, start, frame }) => (
  <div
    style={{
      ...rise(frame, start, 18, 26),
      width: 268,
      padding: "24px 22px",
      borderRadius: 18,
      background: "rgba(22,27,36,0.72)",
      border: `1px solid ${COLORS.stroke}`,
      boxShadow: "0 24px 60px rgba(0,0,0,0.42)",
      display: "flex",
      flexDirection: "column",
      gap: 16,
    }}
  >
    <div
      style={{
        width: 54,
        height: 54,
        borderRadius: 14,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: `${tint}22`,
        border: `1px solid ${tint}55`,
      }}
    >
      {icon}
    </div>
    <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
      <span style={{ fontFamily: FONT, fontSize: 23, fontWeight: 650, color: COLORS.text }}>{title}</span>
      <span style={{ fontFamily: MONO, fontSize: 13.5, color: COLORS.textFaint }}>{sub}</span>
    </div>
  </div>
);

export const S6Actions: React.FC = () => {
  const f = useCurrentFrame();

  const toastY = interpolate(f, [70, 96], [-40, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: (t) => 1 - Math.pow(1 - t, 3),
  });
  const toastO = interpolate(f, [70, 88], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <div
        style={{
          display: "flex",
          gap: 24,
          marginTop: -40,
        }}
      >
        <ActionCard
          icon={<ClockPlus color={COLORS.cyan} />}
          title="Extend TTL"
          sub="+15m · +30m · +1h · +2h"
          tint={COLORS.cyan}
          start={6}
          frame={f}
        />
        <ActionCard
          icon={<StopIcon color={COLORS.amber} />}
          title="Stop"
          sub="with confirmation"
          tint={COLORS.amber}
          start={16}
          frame={f}
        />
        <ActionCard
          icon={<TrashIcon color={COLORS.red} />}
          title="Remove"
          sub="destructive · confirmed"
          tint={COLORS.red}
          start={26}
          frame={f}
        />
        <ActionCard
          icon={<BellIcon color={COLORS.violet} />}
          title="Notify"
          sub="before anything expires"
          tint={COLORS.violet}
          start={36}
          frame={f}
        />
      </div>

      {/* notification toast */}
      <div
        style={{
          position: "absolute",
          top: 96,
          right: 120,
          width: 470,
          transform: `translateY(${toastY}px)`,
          opacity: toastO,
          display: "flex",
          gap: 16,
          alignItems: "center",
          padding: "16px 18px",
          borderRadius: 18,
          background: "rgba(26,31,41,0.9)",
          backdropFilter: "blur(24px)",
          border: `1px solid ${COLORS.strokeStrong}`,
          boxShadow: "0 30px 80px rgba(0,0,0,0.55)",
        }}
      >
        <AppIcon size={44} glow={0.6} />
        <div style={{ display: "flex", flexDirection: "column", gap: 4, flex: 1 }}>
          <span style={{ fontFamily: FONT, fontSize: 15, fontWeight: 650, color: COLORS.text }}>
            Sbx Monitor
          </span>
          <span style={{ fontFamily: FONT, fontSize: 15, color: COLORS.textDim }}>
            <span style={{ color: COLORS.red, fontWeight: 600 }}>ml-notebook</span> expires in 4m
          </span>
        </div>
        <span
          style={{
            fontFamily: FONT,
            fontSize: 14,
            fontWeight: 650,
            color: COLORS.docker,
            padding: "7px 13px",
            borderRadius: 9,
            background: "rgba(36,150,237,0.16)",
            border: "1px solid rgba(36,150,237,0.42)",
          }}
        >
          Extend
        </span>
      </div>

      <Caption
        text="Extend, stop, remove — and get warned in time."
        sub="Destructive actions ask first. Notifications fire before expiry."
        start={100}
      />
    </AbsoluteFill>
  );
};
