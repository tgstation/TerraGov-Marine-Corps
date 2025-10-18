/** Used by color helpers: `2` is a darker color */
export type MedColorTuple = [string, string, string];

/** Refers to indexes, for use with color helpers */
export enum MedColorIndexes {
  Background,
  Foreground,
  Darker,
}

/** Enum of blood colors, independent of DM-side */
export enum BloodColors {
  FineBG = 'grey',
  FineFG = 'white',
  WarnBG = 'yellow',
  WarnFG = 'black',
  CritBG = 'red',
  CritFG = 'white',
}

/** Enum of temperature colors, tied to DM-side */
export enum TempColor {
  T1Heat = 'yellow',
  T2Heat = 'orange',
  T3Heat = 'red',
  OK = 'white',
}

/** Enum of revivability states, tied to DM-side */
export enum RevivableStates {
  Impossible = 'never',
  ActionNeeded = 'blocked',
  Ready = 'ready',
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
  Splinted = 'Splinted',
  Stabilized = 'Stabilized',
}

/** Enum of organ statuses, tied to DM-side */
export enum OrganStatuses {
  OK = 'Functional',
  Bruised = 'Damaged',
  Broken = 'Failing',
}

type Temperature = {
  current: string;
  color: TempColor;
  warning: boolean;
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

export type Advice = {
  advice: string;
  icon: string;
  color: string;
  tooltip: string;
};

export type MedScannerData = {
  patient: string;
  species: Species;
  dead: boolean;
  health: number;
  max_health: number;
  crit_threshold: number;
  dead_threshold: number;
  total_brute: number;
  total_burn: number;
  toxin: number;
  oxy: number;
  clone: number;
  revivable_status: RevivableStates;
  revivable_reason: string;
  has_chemicals: boolean;
  has_unknown_chemicals: boolean;
  chemicals_lists?: Record<string, Chemical>;
  total_flow_rate: number;
  limb_data_lists?: Record<string, Limb>;
  limbs_damaged: number;
  damaged_organs?: Record<string, Organ>;
  ssd?: string;
  blood_type: string;
  blood_amount: number;
  regular_blood_amount: number;
  body_temperature: Temperature;
  pulse: string;
  infection: boolean;
  internal_bleeding: boolean;
  total_unknown_implants: number;
  hugged: boolean;
  advice?: Advice[];
  accessible_theme: boolean;
};
