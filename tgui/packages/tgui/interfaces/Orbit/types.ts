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
  caste?: string;
  health?: number;
  icon?: string;
  job?: string;
  name: string;
  nickname?: string;
  orbiters?: number;
  ref: string;
};
