export type Loadout =
  {
    name: string;
    job: string;
  }

export type LoadoutItemData = 
  {
    loadout: Loadout;
  }

export type LoadoutListData = 
  {
    loadout_list: Loadout[];
    job: string;
  }

export type LoadoutManagerData = 
  {
    loadout_list: Loadout[];
  };

export type LoadoutTabData = 
  {
    job: string;
    setJob: any;
  }

export type NameInputModalData = {
  label : string;
  button_text : string;
  onSubmit : Function;
  onBack : Function;
}
