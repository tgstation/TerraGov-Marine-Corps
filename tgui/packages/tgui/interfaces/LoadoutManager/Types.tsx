export type Loadout =
  {
    name: string;
  }

export type LoadoutItemData = 
  {
    loadout: Loadout;
  }

export type LoadoutListData = 
  {
    loadout_list: Loadout[];
  }

export type LoadoutManagerData = 
  {
    loadout_list: Loadout[];
  };

export type NameInputModalData = {
  label : string;
  button_text : string;
  onSubmit : Function;
  onBack : Function;
}
