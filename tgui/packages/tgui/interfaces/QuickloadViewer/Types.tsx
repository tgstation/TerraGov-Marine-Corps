
import { Loadout } from '../LoadoutManager/Types';

export type LoadoutViewerData = 
  {
    items: Record<keyof typeof SLOTS, LoadoutSlotItem>;
    loadout: Loadout;
  }

export type LoadoutSlotItem =
  {
    icons: LoadoutIconInfo[];
    name: string;
  }

export type LoadoutIconInfo =
  {
    icon: string;
    translateX: string;
    translateY: string;
    scale: number;
  }


export type LoadoutSlotData = {
    items: Record<keyof typeof SLOTS, LoadoutSlotItem>;
  };
  

export const getGridSpotKey = (spot: [number, number]): GridSpotKey => {
  return `${spot[0]}/${spot[1]}`;
};

export const SLOTS: Record<
  string,
  {
    displayName: string;
    gridSpot: GridSpotKey;
    image?: string;
  }
  > = {
    slot_glasses: {
      displayName: "eyewear",
      gridSpot: getGridSpotKey([0, 0]),
      image: "inventory-glasses.png",
    },

    slot_head: {
      displayName: "headwear",
      gridSpot: getGridSpotKey([0, 1]),
      image: "inventory-head.png",
    },

    slot_wear_mask: {
      displayName: "mask",
      gridSpot: getGridSpotKey([0, 2]),
      image: "inventory-mask.png",
    },

    slot_w_uniform: {
      displayName: "uniform",
      gridSpot: getGridSpotKey([1, 0]),
      image: "inventory-uniform.png",
    },

    slot_suit: {
      displayName: "armor",
      gridSpot: getGridSpotKey([1, 1]),
      image: "inventory-suit.png",
    },

    slot_gloves: {
      displayName: "gloves",
      gridSpot: getGridSpotKey([1, 2]),
      image: "inventory-gloves.png",
    },

    slot_belt: {
      displayName: "belt",
      gridSpot: getGridSpotKey([2, 0]),
      image: "inventory-belt.png",
    },

    slot_shoes: {
      displayName: "shoes",
      gridSpot: getGridSpotKey([2, 1]),
      image: "inventory-shoes.png",
    },

    slot_s_store: {
      displayName: "armor storage item",
      gridSpot: getGridSpotKey([2, 2]),
      image: "inventory-suit_storage.png",
    },

    slot_back: {
      displayName: "back",
      gridSpot: getGridSpotKey([3, 0]),
      image: "inventory-back.png",
    },

    slot_l_store: {
      displayName: "left pocket",
      gridSpot: getGridSpotKey([3, 1]),
      image: "inventory-pocket.png",
    },

    slot_r_store: {
      displayName: "right pocket",
      gridSpot: getGridSpotKey([3, 2]),
      image: "inventory-pocket.png",
    },
  };

export type GridSpotKey = string;