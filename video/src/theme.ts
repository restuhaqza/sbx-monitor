export const FPS = 30;
export const DURATION_IN_FRAMES = 1200; // 40s
export const WIDTH = 1920;
export const HEIGHT = 1080;

export const COLORS = {
  bg0: "#07090D",
  bg1: "#0E1219",
  bg2: "#161B24",
  panel: "rgba(24, 29, 38, 0.72)",
  panelSolid: "#141922",
  stroke: "rgba(255,255,255,0.09)",
  strokeStrong: "rgba(255,255,255,0.16)",
  text: "#E8EDF5",
  textDim: "#9AA6B8",
  textFaint: "#5E6A7D",
  docker: "#2496ED",
  cyan: "#22D3EE",
  green: "#34D399",
  amber: "#FBBF24",
  orange: "#FB923C",
  red: "#F87171",
  violet: "#A78BFA",
};

export const FONT =
  '-apple-system, BlinkMacSystemFont, "SF Pro Display", "SF Pro Text", "Inter", "Helvetica Neue", Arial, sans-serif';
export const MONO =
  '"SF Mono", "JetBrains Mono", "Menlo", "Consolas", monospace';

export const ttlColor = (fraction: number): string => {
  // fraction: 1 = far from expiry, 0 = expired
  if (fraction > 0.6) return COLORS.green;
  if (fraction > 0.35) return COLORS.amber;
  if (fraction > 0.18) return COLORS.orange;
  return COLORS.red;
};
