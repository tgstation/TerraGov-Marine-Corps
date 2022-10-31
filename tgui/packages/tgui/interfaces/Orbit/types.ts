import { BooleanLike } from "common/react";

export type OrbitData = {
  auto_observe: BooleanLike;
  dead: Observable[];
  ghosts: Observable[];
  humans: Observable[];
  icons?: string[];
  marines: Observable[];
  misc: Observable[];
  npcs: Observable[];
  som: Observable[];
  survivors: Observable[];
  xenos: Observable[];
};

export type Observable = {
  caste?: string;
  health?: number;
  icon?: string;
  job?: string;
  full_name: string;
  nickname?: string;
  orbiters?: number;
  ref: string;
};
