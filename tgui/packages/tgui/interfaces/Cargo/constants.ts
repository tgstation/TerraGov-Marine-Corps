import { createContext, useContext } from 'react';

import { SupplyPackData } from './types';

export const category_icon = {
  Operations: 'parachute-box',
  Weapons: 'fighter-jet',
  Smartguns: 'star',
  Explosives: 'bomb',
  Armor: 'hard-hat',
  Clothing: 'tshirt',
  Medical: 'medkit',
  Engineering: 'tools',
  Supplies: 'hamburger',
  Imports: 'boxes',
  Vehicles: 'road',
  Factory: 'industry',
  'Pending Order': 'shopping-cart',
};

export enum StaticMenus {
  PreviousPurchases = 'Previous Purchases',
  ExportHistory = 'Export History',
  AwaitingDelivery = 'Awaiting Delivery',
  PendingOrder = 'Pending Order',
  Requests = 'Requests',
  ApprovedRequests = 'Approved Requests',
  DeniedRequests = 'Denied Requests',
}

export const SupplyPacks = createContext<SupplyPackData | undefined>({
  '/datum': {
    name: 'Default Supply Pack',
    cost: 0,
    notes: 'Default supply pack',
    group: 'Default Group',
    contains: {
      '/obj/item': { amount: 1 },
    },
    container_name: 'Default Container',
    available_against_xeno_only: false,
  },
});

export function useSupplyPacks() {
  return useContext(SupplyPacks);
}
