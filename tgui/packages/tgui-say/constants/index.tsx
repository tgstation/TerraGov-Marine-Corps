/** Radio channels */
export const CHANNELS = [
  'Say',
  'Radio',
  'Me',
  'OOC',
  'LOOC',
  'XOOC',
  'MOOC',
] as const;

/** Window sizes in pixels */
export enum WINDOW_SIZES {
  small = 30,
  medium = 50,
  large = 70,
  width = 231,
}

/** Line lengths for autoexpand */
export enum LINE_LENGTHS {
  small = 20,
  medium = 35,
}

/**
 * Radio prefixes.
 * Contains the properties:
 * id - string. css class identifier.
 * label - string. button label.
 */
export const RADIO_PREFIXES = {
  ':a ': {
    id: 'hive',
    label: 'Hive',
  },
  ':v ': {
    id: 'command',
    label: 'Cmd',
  },
  ':e ': {
    id: 'engi',
    label: 'Engi',
  },
  ':m ': {
    id: 'medical',
    label: 'Med',
  },
  ':o ': {
    id: 'ai',
    label: 'AI',
  },
  ':s ': {
    id: 'firesupport',
    label: 'CAS',
  },
  ':u ': {
    id: 'requisitions',
    label: 'Req',
  },
  ':q ': {
    id: 'alpha',
    label: 'alpha',
  },
  ':b ': {
    id: 'bravo',
    label: 'bravo',
  },
  ':c ': {
    id: 'charlie',
    label: 'charlie',
  },
  ':d ': {
    id: 'delta',
    label: 'delta',
  },
  ':ф ': {
    id: 'hive',
    label: 'Hive',
  },
  ':м ': {
    id: 'command',
    label: 'Cmd',
  },
  ':у ': {
    id: 'engi',
    label: 'Engi',
  },
  ':ь ': {
    id: 'medical',
    label: 'Med',
  },
  ':щ ': {
    id: 'ai',
    label: 'AI',
  },
  ':ы ': {
    id: 'firesupport',
    label: 'CAS',
  },
  ':г ': {
    id: 'requisitions',
    label: 'Req',
  },
  ':й ': {
    id: 'alpha',
    label: 'alpha',
  },
  ':и ': {
    id: 'bravo',
    label: 'bravo',
  },
  ':с ': {
    id: 'charlie',
    label: 'charlie',
  },
  ':в ': {
    id: 'delta',
    label: 'delta',
  },
} as const;
