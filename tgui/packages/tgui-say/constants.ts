/** Window sizes in pixels */
export enum WindowSize {
  Small = 30,
  Medium = 50,
  Large = 70,
  Width = 231,
}

/** Line lengths for autoexpand */
export enum LineLength {
  Small = 20,
  Medium = 39,
  Large = 59,
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
  ':s ': 'CAS',
  ':u ': 'Req',
  ':q ': 'Alpha',
  ':b ': 'Bravo',
  ':c ': 'Charlie',
  ':d ': 'Delta',
} as const;
