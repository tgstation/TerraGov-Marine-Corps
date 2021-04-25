type PlayerPreferencesData = {
  is_admin: number,
  slot: number,
  real_name: string,
  random_name: number,
  synthetic_name: string,
  synthetic_type: string,
  xeno_name: string,
  ai_name: string,
  age: number,
  gender: string,
  ethnicity: string,
  species: string,
  body_type: string,
  good_eyesight: number,
  h_style: string,
  r_hair: number,
  g_hair: number,
  b_hair: number,
  grad_style: string,
  r_grad: number,
  g_grad: number,
  b_grad: number,
  f_style: string,
	r_facial: number,
	g_facial: number,
	b_facial: number,
  r_eyes: number,
  g_eyes: number,
  b_eyes: number,
  citizenship: string,
  religion: string,
  nanotrasen_relation: string,
  flavor_text: string,
  med_record: string,
  gen_record: string,
  sec_record: string,
  exploit_record: string,
  underwear: number,
  undershirt: number,
  backpack: number,
  gear: string[],
  job_preferences: AssocStringNumber,
  preferred_squad: string,
  alternate_option: number,
  special_occupation: number,
  ui_style: number,
  ui_style_color: string,
  ui_style_alpha: number,
  windowflashing: number,
  auto_fit_viewport: number,
  focus_chat: number,
  clientfps: number,
  chat_on_map: number,
  max_chat_length: number,
  see_chat_non_mob: number,
  see_rc_emotes: number,
  mute_others_combat_messages: number,
  mute_self_combat_messages: number,
  show_typing: number,
  tooltips: number,
  key_bindings: AssocStringStringArray,
  save_slot_names: AssocStringString,
  synth_types: string[],
  bodytypes: string[],
  ethnicities: string[],
  citizenships: string[],
  religions: string[],
  corporate_relations: string[],
  squads: string[]
  clothing: PreferencesClothingTypeList,
  genders: string[],
  overflow_job: string[],
  ui_styles: string[],
  gearsets: PreferencesGearSets,
  jobs: PreferencesJobsList,
  special_occupations: PreferencesSpecialOccupations,
  all_keybindings: AllKeybindingsList,
  mapRef: string,
}

type AssocStringNumber = {
  [ key:string ]: number
}

type KeybindingsData = {
  name: string,
  display_name: string,
  desc: string,
  category: string,
}

type AllKeybindingsList = {
  [ key: string ]: KeybindingsData[],
}

type PreferencesClothingTypeList = {
  underwear: PreferencesUnderWearTypes
  undershirt: string[],
  backpack: string[],

}
type PreferencesUnderWearTypes = {
  male: string[]
  female: string[]
}

type PreferencesSpecialOccupations = {
  'Latejoin Xenomorph': number,
  'Xenomorph when unrevivable': number,
  'End of Round Deathmatch': number,
  'Prefer Squad over Role': number,
}

type AssocStringString = {
  [ key: string ]: string
}

type AssocStringStringArray = {
  [ key: string ]: string[]
}

type PreferencesGearSets = {
  [ key: string ]: PreferencesGearDatum
}
type PreferencesGearDatum = {
  name: string,
  cost: number,
  slot: number,
}

type PreferencesJobsList = {
  [ key: string ]: PreferencesJobDatum,
}

type PreferencesJobDatum = {
  color: string,
  description: string,
  banned: number,
  playtime_req: number,
  account_age_req: number,
  flags: PreferencesFlagsList
}

type PreferencesFlagsList = {
  bold: number,
}
