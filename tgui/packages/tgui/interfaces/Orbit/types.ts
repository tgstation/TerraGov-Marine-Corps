export type OrbitData = {
  dead: Observable[];
  ghosts: Observable[];
  humans: Observable[];
  marines: Observable[];
  misc: Observable[];
  npcs: Observable[];
  som: Observable[];
  survivors: Observable[];
  xenos: Observable[];
};

export type Observable = {
  health?: number;
  job?: string;
  icon?: string;
  name: string;
  nickname?: string;
  orbiters?: number;
  ref: string;
};
