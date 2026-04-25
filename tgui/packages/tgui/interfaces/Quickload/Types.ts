import { Dispatch, SetStateAction } from 'react';
export type Loadout = {
  name: string;
  job: string;
  desc: string;
  amount: string;
  outfit: string;
};

export type LoadoutItemData = {
  loadout: Loadout;
  setShowDesc: Dispatch<SetStateAction<string>>;
};

export type LoadoutListData = {
  loadout_list: Loadout[];
  setShowDesc: Dispatch<SetStateAction<null | string>>;
};

export type LoadoutTabData = {
  job: string;
  setJob: Dispatch<SetStateAction<string>>;
};

export type LoadoutManagerData = {
  loadout_list: Loadout[];
  ui_theme: string;
  vendor_categories: string[];
};

export type NameInputModalData = {
  label: string;
  button_text: string;
  onSubmit: Function;
  onBack: Function;
};
