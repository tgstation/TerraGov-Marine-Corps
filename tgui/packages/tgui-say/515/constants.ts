/** Window sizes in pixels */
export enum WINDOW_SIZES {
  small = 30,
  medium = 50,
  large = 70,
  width = 231,
}

/** Line lengths for autoexpand */
export enum LINE_LENGTHS {
  small = 22,
  medium = 45,
}

/**
 * Radio prefixes.
 * Displays the name in the left button, tags a css class.
 */
export const RADIO_PREFIXES = {
  ':a ': 'Hive',
  ':v ': 'Cmd',
  ':e ': 'Engi',
  ':m ': 'Med',
  ':o ': 'AI',
  ':f ': 'CAS',
  ':s ': 'Sec',
  ':u ': 'Req',
  ':q ': 'alpha',
  ':b ': 'bravo',
  ':c ': 'charlie',
  ':d ': 'delta',
  ':p ': 'PMC',
} as const;
