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
  job_icon?: string;
  name: string;
  orbiters?: number;
  ref: string;
};
