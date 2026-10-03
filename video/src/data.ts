export type Port = { port: number; url: string };

export type Sandbox = {
  id: string;
  name: string;
  agent: string;
  running: boolean;
  /** 1 = plenty of TTL left, 0 = expiring now */
  ttlFraction: number;
  ttlLabel: string;
  vcpu: number;
  mem: string;
  image: string;
  ports: Port[];
  created: string;
  expires: string;
};

export const FLEET: Sandbox[] = [
  {
    id: "sbx_8f3a91",
    name: "api-dev",
    agent: "Claude Code",
    running: true,
    ttlFraction: 0.78,
    ttlLabel: "1h 12m",
    vcpu: 4,
    mem: "8 GB",
    image: "ghcr.io/acme/api:dev",
    ports: [
      { port: 3000, url: "https://3000-sbx8f3a91.sbx.app" },
      { port: 5432, url: "https://5432-sbx8f3a91.sbx.app" },
    ],
    created: "12:04",
    expires: "13:16",
  },
  {
    id: "sbx_2c77de",
    name: "web-preview",
    agent: "Codex",
    running: true,
    ttlFraction: 0.42,
    ttlLabel: "38m",
    vcpu: 2,
    mem: "4 GB",
    image: "node:22-alpine",
    ports: [{ port: 5173, url: "https://5173-sbx2c77de.sbx.app" }],
    created: "11:52",
    expires: "12:30",
  },
  {
    id: "sbx_5b10aa",
    name: "ml-notebook",
    agent: "OpenCode",
    running: false,
    ttlFraction: 0.12,
    ttlLabel: "4m",
    vcpu: 8,
    mem: "16 GB",
    image: "jupyter/scipy-notebook:latest",
    ports: [{ port: 8888, url: "https://8888-sbx5b10aa.sbx.app" }],
    created: "10:11",
    expires: "12:58",
  },
];
