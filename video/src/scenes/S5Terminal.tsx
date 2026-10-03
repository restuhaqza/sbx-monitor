import React from "react";
import { AbsoluteFill, useCurrentFrame, interpolate } from "remotion";
import { COLORS, FONT, MONO } from "../theme";
import { MacWindow, TrafficLights } from "../components/MacWindow";
import { rise } from "../anim";
import { Caption } from "../components/Caption";

const CARET = "▋";

const typedText = (f: number, start: number, cps: number, text: string) => {
  const n = Math.max(0, Math.floor(((f - start) / 30) * cps));
  return text.slice(0, Math.min(text.length, n));
};

const Caret: React.FC<{ f: number; on?: boolean }> = ({ f, on = true }) =>
  on ? (
    <span style={{ opacity: Math.floor(f / 15) % 2 === 0 ? 1 : 0.05 }}>{CARET}</span>
  ) : null;

const ModeChip: React.FC<{ label: string; sub: string; active: number; start: number; frame: number }> = ({
  label,
  sub,
  active,
  start,
  frame,
}) => (
  <div
    style={{
      ...rise(frame, start, 16, 14),
      padding: "12px 20px",
      borderRadius: 12,
      background: active ? "rgba(36,150,237,0.16)" : "rgba(255,255,255,0.04)",
      border: `1px solid ${active ? "rgba(36,150,237,0.5)" : COLORS.stroke}`,
      display: "flex",
      flexDirection: "column",
      gap: 4,
      minWidth: 190,
    }}
  >
    <span style={{ fontFamily: FONT, fontSize: 16, fontWeight: 650, color: active ? COLORS.text : COLORS.textDim }}>
      {label}
    </span>
    <span style={{ fontFamily: MONO, fontSize: 12.5, color: COLORS.textFaint }}>{sub}</span>
  </div>
);

export const S5Terminal: React.FC = () => {
  const f = useCurrentFrame();

  const cmd1 = "sbx --cloud exec -it sbx_8f3a91 bash";
  const cmd2 = "npm run dev";
  const t1 = typedText(f, 22, 28, cmd1);
  const t2 = typedText(f, 74, 22, cmd2);

  const showPrompt = f > 22 + (cmd1.length * 30) / 28 + 8;
  const showDev = f > 74 + (cmd2.length * 30) / 22 + 6;

  const winOpacity = interpolate(f, [0, 18], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <MacWindow
        width={1240}
        height={620}
        title="api-dev — sbx exec"
        style={{
          opacity: winOpacity,
          transform: `translateY(${(1 - winOpacity) * 22}px)`,
        }}
        bodyStyle={{
          background: "linear-gradient(180deg, #0B0E13, #090B0F)",
          padding: "22px 26px",
          fontFamily: MONO,
          fontSize: 21,
          lineHeight: 1.75,
          color: "#CFE0F2",
        }}
      >
        <div>
          <span style={{ color: COLORS.green }}>restu@mac</span>
          <span style={{ color: COLORS.textFaint }}>:~$ </span>
          <span style={{ color: COLORS.text }}>{t1}</span>
          <Caret f={f} on={f < 22 + (cmd1.length * 30) / 28 + 10} />
        </div>

        {showPrompt ? (
          <div style={{ color: "#8FB6D9" }}>
            root@sbx_8f3a91:/workspace#
          </div>
        ) : null}

        <div style={{ marginTop: 12 }}>
          <span style={{ color: COLORS.green }}>restu@mac</span>
          <span style={{ color: COLORS.textFaint }}>:~$ </span>
          <span style={{ color: COLORS.text }}>{t2}</span>
          <Caret f={f} on={f >= 72 && !showDev} />
        </div>

        {showDev ? (
          <div style={{ marginTop: 4 }}>
            <div style={{ ...rise(f, 96, 12, 8), color: COLORS.textDim }}>
              <span style={{ color: COLORS.cyan }}>VITE</span> v6.0.3  ready in{" "}
              <span style={{ color: COLORS.green }}>412 ms</span>
            </div>
            <div style={{ ...rise(f, 106, 12, 8), color: COLORS.textDim }}>
              ➜  Local:   <span style={{ color: COLORS.text }}>http://localhost:3000/</span>
            </div>
            <div style={{ ...rise(f, 116, 12, 8), color: COLORS.textDim }}>
              ➜  Network: <span style={{ color: COLORS.text }}>https://3000-sbx8f3a91.sbx.app</span>
            </div>
          </div>
        ) : null}
      </MacWindow>

      <div
        style={{
          marginTop: 34,
          display: "flex",
          gap: 16,
          alignItems: "center",
        }}
      >
        <div
          style={{
            ...rise(f, 124, 16, 12),
            fontFamily: FONT,
            fontSize: 16,
            fontWeight: 600,
            letterSpacing: 0.6,
            textTransform: "uppercase",
            color: COLORS.textFaint,
            marginRight: 6,
          }}
        >
          Real PTY terminal
        </div>
        <ModeChip label="Sandbox shell" sub="sbx exec -it" active={1} start={130} frame={f} />
        <ModeChip label="Agent session" sub="sbx attach" active={0} start={138} frame={f} />
        <ModeChip label="Host shell" sub="login shell" active={0} start={146} frame={f} />
      </div>

      <Caption
        text="A real embedded terminal."
        sub="Sandbox shell, the agent's TUI, or your host — interactive TUIs included."
        start={78}
      />
    </AbsoluteFill>
  );
};
