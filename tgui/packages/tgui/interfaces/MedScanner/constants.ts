import { MedColors, OrganStatuses, RevivableStates, TempLevels } from './data';

// Sizing
/** Font size for the limit of counters like chem units and organ health */
export const COUNTER_MAX_SIZE = '75%';
/** What most elements will use for their padding and margin */
export const SPACING_PIXELS = '5px';
/** A rounded border like the ProgressBars and Sections */
export const ROUNDED_BORDER = {
  borderRadius: '0.16em',
};

// Colors
/** For the multiple elements using zebra stripes, this is the base for each step */
export const COLOR_ZEBRA_BG = 'hsla(0, 0%, 100%, 0.075)';
/** Color of the [Robotic] tag, and robotic limb names */
export const COLOR_ROBOTIC_LIMB = 'hsl(218, 60%, 72%)';
/** Custom color for brute damage */
export const COLOR_BRUTE = 'red';
/** Custom color for burn damage */
export const COLOR_BURN = 'hsl(39, 100%, 60%)';
/** Middle ground between grey and light grey TGUI color presets */
export const COLOR_MID_GREY = 'hsl(0, 0%, 59%)';
/** Marginally darker version of the TGUI red color preset */
export const COLOR_DARKER_RED = 'hsl(0, 72%, 42%)';
/** Marginally darker version of the TGUI yellow color preset */
export const COLOR_DARKER_YELLOW = 'hsl(52, 97%, 40%)';
/** Marginally darker version of the orange TGUI color preset */
export const COLOR_DARKER_ORANGE = 'hsl(24, 89%, 40%)';
/** Saturation and Luminance for `getLimbColor` */
export const LIMB_DAMAGE_HSL = {
  hue: 44,
  sat: 100,
  lum: 62,
};

// Mappings
/** Revivable states tied to colors */
export const REVIVABLE_STATES_TO_COLORS: Record<RevivableStates, string> = {
  [RevivableStates.Never]: 'red',
  [RevivableStates.NotYet]: 'orange',
  [RevivableStates.Ready]: 'yellow',
};

/** Temperature levels tied to text colors */
export const TEMP_LEVELS_TO_DATA: Record<
  TempLevels,
  MedColors & { tag: string }
> = {
  [TempLevels.OK]: {
    foreground: 'black',
    background: 'white',
    tag: 'OK',
  },
  [TempLevels.T1Heat]: {
    foreground: 'black',
    background: 'yellow',
    tag: 'MODERATE',
  },
  [TempLevels.T2Heat]: {
    foreground: 'white',
    background: 'orange',
    tag: 'SEVERE',
  },
  [TempLevels.T3Heat]: {
    foreground: 'white',
    background: 'red',
    tag: 'CRITICAL',
  },
};

/** Organ statuses tied to colors */
export const ORGAN_STATUSES_TO_COLORS: Record<OrganStatuses, MedColors> = {
  [OrganStatuses.OK]: {
    background: 'grey',
    foreground: 'white',
    darker: COLOR_MID_GREY,
  },
  [OrganStatuses.Bruised]: {
    background: 'orange',
    foreground: 'white',
    darker: COLOR_DARKER_ORANGE,
  },
  [OrganStatuses.Broken]: {
    background: 'red',
    foreground: 'white',
    darker: COLOR_DARKER_RED,
  },
};
