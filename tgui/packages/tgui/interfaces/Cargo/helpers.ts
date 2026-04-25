import { useSupplyPacks } from './constants';
import { SupplyRequest } from './types';

export function getSupplyRequestCost(input: SupplyRequest | SupplyRequest[]) {
  const supplyrequests = Array.isArray(input) ? input : [input];
  const totalCost = supplyrequests.reduce((sum, request) => {
    return sum + getSupplyRequestCostFromTypepathMap(request.packs);
  }, 0);

  return totalCost;
}

export function getSupplyRequestCostFromTypepathMap(input: {
  [typepath: string]: { amount: number };
}) {
  const data = useSupplyPacks();
  if (!data) return 0;
  const totalCost = Object.entries(input).reduce(
    (sum, [typepath, { amount }]) => {
      const pack = data[typepath];
      return sum + (pack ? pack.cost * amount : 0);
    },
    0,
  );

  return totalCost;
}
