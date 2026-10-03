import React from "react";
import { AbsoluteFill, useCurrentFrame, useVideoConfig, interpolate } from "remotion";
import { COLORS, FONT, MONO, ttlColor } from "../theme";
import { FLEET } from "../data";
import { MacWindow } from "../components/MacWindow";
import { SandboxListRow } from "../components/SandboxListRow";
import { TTLRing, Chip, StatusDot } from "../components/atoms";
import { AppIcon } from "../components/Logo";
import { rise } from "../anim";
import { Caption } from "../components/Caption";

const Field: React.FC<{ label: string; value: React.ReactNode; mono?: boolean }> = ({
  label,
  value,
  mono,
}) => (
  <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
    <span
      style={{
        fontFamily: FONT,
        fontSize: 13,
        fontWeight: 600,
        letterSpacing: 1.1,
        textTransform: "uppercase",
        color: COLORS.textFaint,
      }}
    >
      {label}
    </span>
    <span
      style={{
        fontFamily: mono ? MONO : FONT,
        fontSize: 19,
        fontWeight: 550,
        color: COLORS.text,
        whiteSpace: "nowrap",
      }}
    >
      {value}
    </span>
  </div>
);

const ActionChip: React.FC<{ children: React.ReactNode; accent?: boolean }> = ({
  children,
  accent,
}) => (
  <span
    style={{
      padding: "6px 12px",
      borderRadius: 8,
      fontFamily: FONT,
      fontSize: 14,
      fontWeight: 600,
      color: accent ? COLORS.docker : COLORS.textDim,
      background: accent ? "rgba(36,150,237,0.14)" : "rgba(255,255,255,0.05)",
      border: `1px solid ${accent ? "rgba(36,150,237,0.4)" : COLORS.stroke}`,
    }}
  >
    {children}
  </span>
);

export const S4Window: React.FC = () => {
  const f = useCurrentFrame();
  const { fps } = useVideoConfig();

  const winScale = interpolate(f, [0, 26], [0.94, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: (t) => 1 - Math.pow(1 - t, 3),
  });
  const winOpacity = interpolate(f, [0, 18], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const fraction = interpolate(f, [50, 196], [0.78, 0.12], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const totalMin = 72;
  const rem = Math.round(fraction * totalMin);
  const label = rem >= 60 ? `${Math.floor(rem / 60)}h ${rem % 60}m` : `${rem}m`;
  const sandbox = FLEET[0];
  const pulse = ((f - 40) % 45) / 45;

  return (
    <AbsoluteFill style={{ alignItems: "center", justifyContent: "center" }}>
      <div
        style={{
          opacity: winOpacity,
          transform: `scale(${winScale}) translateY(${(1 - winOpacity) * 20}px)`,
        }}
      >
        <MacWindow
          width={1520}
          height={800}
          title="Sbx Monitor"
          titlebarRight={
            <>
              <span style={{ fontFamily: FONT, fontSize: 13, color: COLORS.textFaint }}>Auto-refresh 10s</span>
            </>
          }
          bodyStyle={{ display: "flex" }}
        >
          {/* sidebar */}
          <div
            style={{
              width: 400,
              flex: "0 0 auto",
              borderRight: `1px solid ${COLORS.stroke}`,
              background: "rgba(10,13,18,0.4)",
              display: "flex",
              flexDirection: "column",
              padding: "16px 12px",
            }}
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                gap: 10,
                padding: "4px 6px 14px",
              }}
            >
              <AppIcon size={26} glow={0.5} />
              <span style={{ fontFamily: FONT, fontSize: 17, fontWeight: 650, color: COLORS.text }}>
                Sandboxes
              </span>
              <span
                style={{
                  marginLeft: "auto",
                  fontFamily: FONT,
                  fontSize: 13,
                  fontWeight: 600,
                  color: COLORS.textDim,
                  padding: "3px 9px",
                  borderRadius: 999,
                  background: "rgba(255,255,255,0.06)",
                }}
              >
                3
              </span>
            </div>
            <div style={{ display: "flex", flexDirection: "column", gap: 5 }}>
              {FLEET.map((s, i) => (
                <div key={s.id} style={{ ...rise(f, 20 + i * 8, 16, 14) }}>
                  <SandboxListRow
                    sandbox={{ ...s, ttlFraction: i === 0 ? fraction : s.ttlFraction }}
                    selected={i === 0}
                    pulse={i === 0 ? pulse : 0}
                  />
                </div>
              ))}
            </div>
            <div
              style={{
                marginTop: "auto",
                display: "flex",
                alignItems: "center",
                gap: 10,
                padding: "12px 8px 4px",
                borderTop: `1px solid ${COLORS.stroke}`,
                fontFamily: FONT,
                fontSize: 15,
                color: COLORS.textDim,
              }}
            >
              <span style={{ fontSize: 17 }}>⚙︎</span> Settings
            </div>
          </div>

          {/* detail */}
          <div style={{ flex: 1, minWidth: 0, padding: "26px 34px", display: "flex", flexDirection: "column" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 14, ...rise(f, 10, 16, 14) }}>
              <StatusDot running pulse={pulse} size={12} />
              <span style={{ fontFamily: FONT, fontSize: 40, fontWeight: 700, letterSpacing: -1, color: COLORS.text }}>
                {sandbox.name}
              </span>
              <Chip color={COLORS.green}>● Running</Chip>
              <Chip color={COLORS.textDim}>{sandbox.agent}</Chip>
            </div>

            <div
              style={{
                marginTop: 28,
                display: "flex",
                gap: 46,
                alignItems: "center",
                ...rise(f, 20, 18, 18),
              }}
            >
              <TTLRing fraction={fraction} size={244} label={label} caption="Time to live" />
              <div style={{ display: "flex", flexDirection: "column", gap: 22, flex: 1 }}>
                <div style={{ display: "flex", gap: 40 }}>
                  <Field label="Sandbox ID" value={sandbox.id} mono />
                  <Field label="Created" value={sandbox.created} />
                </div>
                <div style={{ display: "flex", gap: 40 }}>
                  <Field label="Resources" value={<>{sandbox.vcpu} vCPU · {sandbox.mem}</>} />
                  <Field
                    label="Expires"
                    value={<span style={{ color: ttlColor(fraction) }}>{label}</span>}
                  />
                </div>
                <Field label="Image" value={sandbox.image} mono />
              </div>
            </div>

            <div style={{ marginTop: 34, ...rise(f, 60, 18, 16) }}>
              <div
                style={{
                  fontFamily: FONT,
                  fontSize: 13,
                  fontWeight: 600,
                  letterSpacing: 1.1,
                  textTransform: "uppercase",
                  color: COLORS.textFaint,
                  marginBottom: 12,
                }}
              >
                Exposed ports
              </div>
              <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
                {sandbox.ports.map((p, i) => (
                  <div
                    key={p.port}
                    style={{
                      ...rise(f, 68 + i * 10, 16, 14),
                      display: "flex",
                      alignItems: "center",
                      gap: 14,
                      padding: "13px 16px",
                      borderRadius: 12,
                      background: "rgba(255,255,255,0.035)",
                      border: `1px solid ${COLORS.stroke}`,
                    }}
                  >
                    <span style={{ fontFamily: MONO, fontSize: 17, fontWeight: 600, color: COLORS.cyan, width: 66 }}>
                      :{p.port}
                    </span>
                    <span style={{ fontFamily: MONO, fontSize: 16, color: COLORS.textDim, flex: 1 }}>{p.url}</span>
                    <ActionChip accent>Open</ActionChip>
                    <ActionChip>Copy</ActionChip>
                    <ActionChip>Unpublish</ActionChip>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </MacWindow>
      </div>

      <Caption
        text="TTL, ports, resources, status — one place."
        sub="Named sandboxes with agent, countdown, and public HTTPS URLs."
        start={120}
      />
    </AbsoluteFill>
  );
};
