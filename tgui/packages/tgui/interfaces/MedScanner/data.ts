/** Used by most color helpers and lookup tables */
export type MedColors = {
  background: string;
  foreground: string;
  darker?: string;
};

/** Enum of overheat tiers, tied to DM-side */
export enum TempLevels {
  OK,
  T1Heat,
  T2Heat,
  T3Heat,
}

/** Enum of blood colors */
export enum BloodColors {
  FineBG = 'grey',
  FineFG = 'white',
  WarnBG = 'yellow',
  WarnFG = 'black',
  CritBG = 'red',
  CritFG = 'white',
}

/** Enum of revivability states, tied to DM-side */
export enum RevivableStates {
  Never = 'Impossible',
  NotYet = 'Not ready',
  Ready = 'Ready',
}

/** Enum of limb types, tied to DM-side */
export enum LimbTypes {
  Normal = '',
  Robotic = 'Robotic',
  Biotic = 'Biotic',
}

/** Enum of limb statuses, tied to DM-side */
export enum LimbStatuses {
  OK = '',
  Fracture = 'Fracture',
  Splinted = 'Splint',
  Stabilized = 'Stable',
}

/** Enum of organ statuses, tied to DM-side */
export enum OrganStatuses {
  OK = 'Functional',
  Bruised = 'Damaged',
  Broken = 'Failing',
}

type Temperature = {
  current: string;
  level: TempLevels;
};

type Species = {
  name: string;
  is_synthetic: boolean;
  is_combat_robot: boolean;
  is_robotic_species: boolean;
};

type Limb = {
  name: string;
  brute: number;
  burn: number;
  bandaged: boolean;
  salved: boolean;
  missing: boolean;
  bleeding: boolean;
  implants: boolean;
  internal_bleeding: boolean;
  limb_status?: LimbStatuses;
  limb_type?: LimbTypes;
  open_incision: boolean;
  infected: boolean;
  necrotized: boolean;
  max_damage: number;
};

type Chemical = {
  name: string;
  description: string;
  amount: number;
  od: string;
  od_threshold: number;
  crit_od_threshold: number;
  color: string;
  metabolism_factor: number;
  dangerous: boolean;
  ui_priority: number;
};

type Organ = {
  name: string;
  status: OrganStatuses;
  broken_damage: number;
  bruised_damage: number;
  damage: number;
  effects: string;
};

type Advice = {
  advice: string;
  icon: string;
  color: string;
  tooltip: string;
};

export type MedScannerData = {
  // Basics
  patient: string;
  dead: boolean;
  health: number;
  max_health: number;
  crit_threshold: number;
  dead_threshold: number;
  total_brute: number;
  total_burn: number;
  total_tox: number;
  total_oxy: number;
  total_clone: number;
  hugged: boolean;
  species: Species;
  accessible_theme: boolean;

  // Chemicals
  has_chemicals: boolean;
  has_unknown_chemicals: boolean;
  chemicals_lists?: Record<string, Chemical>;

  // Limbs
  total_flow_rate: number;
  total_unknown_implants: number;
  internal_bleeding: boolean;
  infection: boolean;
  limb_data_lists?: Record<string, Limb>;
  limbs_damaged: number;

  // Organs
  damaged_organs?: Record<string, Organ>;

  // Revivability
  revivable_status: RevivableStates;
  revivable_reason?: string;

  // Advice
  advice?: Advice[];

  // Footer
  blood_type: string;
  blood_amount: number;
  regular_blood_amount: number;

  body_temperature: Temperature;

  pulse: string;
  ssd?: string;
};
