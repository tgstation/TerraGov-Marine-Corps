import { BooleanLike } from 'tgui-core/react';

export type SupplyPackData = {
  [typepath: string]: {
    // typepath is your uid
    name: string;
    cost: number;
    notes?: string;
    group: string;
    contains: {
      [name: string]: { amount: number };
    };
    container_name?: string;
    available_against_xeno_only: BooleanLike;
  };
};

export type SupplyRequest = {
  id: number;
  orderer: string;
  orderer_rank: string;
  reason: string;
  packs: {
    [typepath: string]: { amount: number };
  };
  authed_by: string;
};

export type ExportEntry = {
  id: number;
  name: string;
  points: number;
  amount: number;
  total: number; // todo do this clientside
};

export type CargoData = {
  is_xeno_only: BooleanLike;
  currentpoints: number;
  requests: SupplyRequest[];
  deniedrequests: SupplyRequest[];
  approvedrequests: SupplyRequest[];
  awaiting_delivery?: SupplyRequest[];
  export_history?: ExportEntry[];
  shopping_history?: SupplyRequest[];
  shopping_list?: {
    [typepath: string]: { amount: number };
  };
  elevator?: string;
  elevator_dir?: string;
};
