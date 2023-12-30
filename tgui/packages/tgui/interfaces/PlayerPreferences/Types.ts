type PlayerPreferencesData = {
  slot: number;
  save_slot_names: AssocStringString;
  tabIndex: number;
};

type CharacterCustomizationData = {
  random_name: number;
  h_style: string;
  r_hair: number;
  g_hair: number;
  b_hair: number;
  r_grad: number;
  g_grad: number;
  b_grad: number;
  r_facial: number;
  g_facial: number;
  b_facial: number;
  r_eyes: number;
  g_eyes: number;
  b_eyes: number;
};

type BackgroundInformationData = {
  slot: number;
  flavor_text: string;
  med_record: string;
  gen_record: string;
  sec_record: string;
  exploit_record: string;
};

type GameSettingData = {
  ui_style_color: string;
  scaling_method: string;
  pixel_size: number;
  parallax: number;
  is_admin: number;
};

type GearCustomizationData = {
  gearsets: PreferencesGearSets;
  gear: string[];
  clothing: PreferencesClothingTypeList;
  underwear: number;
  undershirt: number;
  backpack: number;
  gender: string;
};

type KeybindSettingData = {
  all_keybindings: AllKeybindingsList;
  is_admin: number;
};

type KeybindPreferenceData = {
  key_bindings: AssocStringStringArray;
  custom_emotes: AssocStringEmoteArray;
};

type KeybindSentenceCapture = {
  name: string;
};

type ProfilePictureData = {
  mapRef: string;
};

type TextInputModalData = {
  label: string;
  button_text: string;
  onSubmit: Function;
  onBack: Function;
  areaHeigh: string;
  areaWidth: string;
};

type JobPreferencesData = {
  alternate_option: number;
  squads: string[];
  squads_som: string[];
  preferred_squad: string;
  preferred_squad_som: string;
  overflow_job: string[];
  special_occupation: number;
  special_occupations: PreferencesSpecialOccupations;
};

type JobPreferenceData = {
  jobs: PreferencesJobsList;
  job_preferences: AssocStringNumber;
};

type AssocStringNumber = {
  [key: string]: number;
};

type AssocStringEmoteArray = {
  [key: string]: EmoteData;
};

type EmoteData = {
  sentence: string;
  emote_type: string;
};

type KeybindingsData = {
  name: string;
  display_name: string;
  desc: string;
  category: string;
};

type AllKeybindingsList = {
  [key: string]: KeybindingsData[];
};

type PreferencesClothingTypeList = {
  underwear: PreferencesUnderWearTypes;
  undershirt: PreferencesUnderShirtTypes;
  backpack: string[];
};

type PreferencesUnderWearTypes = {
  male: string[];
  female: string[];
};

type PreferencesUnderShirtTypes = {
  male: string[];
  female: string[];
};

type PreferencesSpecialOccupations = {
  'Latejoin Xenomorph': number;
  'Xenomorph when unrevivable': number;
  'End of Round Deathmatch': number;
  'Prefer Squad over Role': number;
};

type AssocStringString = {
  [key: string]: string;
};

type AssocStringStringArray = {
  [key: string]: string[];
};

type PreferencesGearSets = {
  [key: string]: PreferencesGearDatum;
};
type PreferencesGearDatum = {
  name: string;
  cost: number;
  slot: number;
};

type PreferencesJobsList = {
  [key: string]: PreferencesJobDatum;
};

type PreferencesJobDatum = {
  color: string;
  description: string;
  banned: number;
  playtime_req: number;
  account_age_req: number;
  flags: PreferencesFlagsList;
};

type PreferencesFlagsList = {
  bold: number;
};

type DrawOrder = {
  draw_order: string[];
  quick_equip: string[];
};
