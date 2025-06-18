type TemperatureData = {
  current: string;
  color: string;
  warning: boolean;
};

type SpeciesData = {
  is_synthetic: boolean;
  is_combat_robot: boolean;
  is_robotic_species: boolean;
};

type LimbData = {
  name: string;
  brute: number;
  burn: number;
  bandaged: boolean;
  salved: boolean;
  missing: boolean;
  bleeding: boolean;
  implants: boolean;
  internal_bleeding: boolean;
  limb_status?: string;
  limb_type?: string;
  open_incision: boolean;
  infected: boolean;
  necrotized: boolean;
  max_damage: number;
};

type ChemData = {
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

type OrganData = {
  name: string;
  status: string;
  broken_damage: number;
  bruised_damage: number;
  damage: number;
  effects: string;
};

type AdviceData = {
  advice: string;
  icon: string;
  color: string;
  tooltip: string;
};

export type MedScannerData = {
  patient: string;
  species: Record<string, SpeciesData>;
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
  revivable_boolean: boolean;
  revivable_string: number;
  has_chemicals: boolean;
  has_unknown_chemicals: boolean;
  chemicals_lists?: Record<string, ChemData>;
  limb_data_lists?: Record<string, LimbData>;
  limbs_damaged: number;
  damaged_organs?: Record<string, OrganData>;
  ssd: string | null;
  blood_type: string;
  blood_amount: number;
  regular_blood_amount: number;
  body_temperature: TemperatureData;
  pulse: string;
  infection: boolean;
  internal_bleeding: boolean;
  total_unknown_implants: number;
  hugged: boolean;
  advice?: Record<string, AdviceData>;
  accessible_theme: boolean;
};
