import React from "react";
import {
  AbsoluteFill,
  Sequence,
  useCurrentFrame,
  interpolate,
  Audio,
  staticFile,
} from "remotion";
import { Backdrop } from "./components/Backdrop";
import { COLORS } from "./theme";
import { S1Title } from "./scenes/S1Title";
import { S2Hook } from "./scenes/S2Hook";
import { S3Tray } from "./scenes/S3Tray";
import { S4Window } from "./scenes/S4Window";
import { S5Terminal } from "./scenes/S5Terminal";
import { S6Actions } from "./scenes/S6Actions";
import { S7Outro } from "./scenes/S7Outro";

const SCENES = [
  { Comp: S1Title, duration: 90 },
  { Comp: S2Hook, duration: 150 },
  { Comp: S3Tray, duration: 210 },
  { Comp: S4Window, duration: 210 },
  { Comp: S5Terminal, duration: 240 },
  { Comp: S6Actions, duration: 180 },
  { Comp: S7Outro, duration: 120 },
];

const Scene: React.FC<{
  durationInFrames: number;
  children: React.ReactNode;
  fade?: number;
}> = ({ durationInFrames, children, fade = 12 }) => {
  const f = useCurrentFrame();
  const opacity = interpolate(
    f,
    [0, fade, durationInFrames - fade, durationInFrames],
    [0, 1, 1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  );
  return <AbsoluteFill style={{ opacity }}>{children}</AbsoluteFill>;
};

export const Promo: React.FC = () => {
  let from = 0;
  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.bg0 }}>
      <Backdrop />
      {SCENES.map(({ Comp, duration }, i) => {
        const start = from;
        from += duration;
        return (
          <Sequence key={i} from={start} durationInFrames={duration}>
            <Scene durationInFrames={duration}>
              <Comp />
            </Scene>
          </Sequence>
        );
      })}
      <Audio src={staticFile("music.mp3")} volume={0.5} />
    </AbsoluteFill>
  );
};
