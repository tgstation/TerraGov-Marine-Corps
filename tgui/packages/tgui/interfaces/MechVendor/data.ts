export const tabs = ['Mecha Assembly', 'Weapons'];
export const partdefinetofluff = {
  'CHEST': 'Torso',
  'HEAD': 'Head',
  'L_ARM': 'Left Arm',
  'R_ARM': 'Right arm',
  'LEG': 'Legs',
};
export const MECHA_UTILITY = "mecha_utility";
export const MECHA_POWER = "mecha_power";
export const MECHA_ARMOR = "mecha_armor";

export type MechVendData = {
  mech_view: string;
  colors: ColorData;
  visor_colors: ColorData;
  equip_max: MaxEquip;
  selected_primary: SimpleStringList;
  selected_secondary: SimpleStringList;
  selected_visor: string;
  selected_variants: SimpleStringList;
  selected_name: string;
  current_stats: MechStatData,
  all_equipment: AllEquipment,
  selected_equipment: SelectedEquip,
};

type MaxEquip = {
  [key: string]: number;
};

type AllEquipment = {
  weapons: MechWeapon[];
  ammo: MechAmmo[];
  armor: MechArmor[];
  utility: MechUtility[];
  power: MechPower[],
};

export type MechWeapon = {
  type: string;
  name: string;
  desc: string;
  icon_state: string;
  health: number;
  firerate: number;
  burst_count: number;
  scatter: number;
  slowdown: number;
  burst_amount: number,
  damage?: number,
  armor_pierce?: number,
  projectiles?: number,
  cache_max?: number,
  ammo_type?: string,
};

type MechAmmo = {
  type: string;
  name: string;
  icon_state: string;
  ammo_count: string;
  ammo_type?: string,
};

export type MechArmor = {
  type: string;
  name: string;
  desc: string;
  slowdown: number;
};

export type MechUtility = {
  type: string;
  name: string;
  desc: string;
  energy_drain: number;
};

export type MechPower = {
  type: string;
  name: string;
  desc: string;
};

type SelectedEquip = {
  mecha_l_arm: string;
  mecha_r_arm: string;
  mecha_utility: string[],
  mecha_power: string[],
  mecha_armor: string[],
};

type MechStatData = {
  accuracy: number;
  light_mod: number;
  left_scatter: number;
  right_scatter: number;
  health: number;
  slowdown: number;
  armor: string[],
  power_max: number,
};

export type BodypartPickerData = {
  displayingpart: string;
};

export type ColorDisplayData = {
  shown_colors: string;
};

type ColorData = {
  [key: string]: SimpleStringList;
};

type SimpleStringList = {
  [key: string]: string;
};

