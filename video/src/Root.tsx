import React from "react";
import { Composition } from "remotion";
import { Promo } from "./Promo";
import { DURATION_IN_FRAMES, FPS, HEIGHT, WIDTH } from "./theme";

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="SbxPromo"
      component={Promo}
      durationInFrames={DURATION_IN_FRAMES}
      fps={FPS}
      width={WIDTH}
      height={HEIGHT}
    />
  );
};
