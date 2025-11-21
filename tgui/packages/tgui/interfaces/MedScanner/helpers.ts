import {
  COLOR_DARKER_RED,
  COLOR_DARKER_YELLOW,
  COLOR_MID_GREY,
  COLOR_ROBOTIC_LIMB,
  LIMB_DAMAGE_HSL as LIMB_HSL,
} from './constants';
import { BloodColors, LimbTypes } from './data';

/**
 * Helper for getting the name color of a limb based on relevant factors
 * @param bruteDamage brute damage number
 * @param burnDamage burn damage number
 * @param maxHealth maximum health of this limb
 * @param roboticToBeginWith this means we're working with a robotic species and need to adjust the color to work with those themes
 * @param limbType limb type for determining if we should return robot colors
 * @returns string: a suitable hsl color
 */
export function getLimbNameColor(
  bruteDamage: number,
  burnDamage: number,
  maxHealth: number,
  roboticToBeginWith: boolean,
  limbType?: LimbTypes,
): string {
  const damage = (bruteDamage + burnDamage) / maxHealth;
  if (limbType === LimbTypes.Robotic) {
    return roboticToBeginWith ? 'white' : COLOR_ROBOTIC_LIMB;
  }
  if (damage <= 0) return 'white';
  if (damage > 1) return 'grey'; // greater than 100% damage can be safely considered a lost cause

  // scale hue linearly from 44/yellow (low damage) to 4/red (high damage)
  return `hsl(${LIMB_HSL.hue - 40 * damage}, ${LIMB_HSL.sat}%, ${LIMB_HSL.lum}%)`;
}

/**
 * Helper for the limb type tag getting its color based on limb type
 * @param limbType limb type for determining the output color
 * @param roboticToBeginWith this means we're working with a robotic species and need to adjust the color to work with those themes
 * @param accessible accessible theme status
 * @returns string: a suitable color
 */
export function getLimbTypeColor(
  limbType: LimbTypes,
  roboticToBeginWith: boolean,
  accessible: boolean,
): string {
  if (limbType === LimbTypes.Robotic) {
    if (roboticToBeginWith) return accessible ? 'lime' : 'label';
    else return COLOR_ROBOTIC_LIMB;
  } else if (limbType === LimbTypes.Biotic) {
    return 'tan';
  }
  return 'white'; // fallback (if we ever need to show that a limb is Normal lmfao)
}

/** `MedColors` but background and foreground use the blood color enums */
type BloodColorData = {
  background: BloodColors;
  foreground: BloodColors;
  darker: string;
};

/**
 * Helper for getting a color based on blood level
 * @param volume current blood level
 * @param initial initial blood level
 * @param internalBleeding internal bleeding status: overrides blood level and always returns red
 * @returns BloodColorData: background, foreground, darker as keys
 */
export function getBloodColor(
  volume: number,
  initial: number,
  internalBleeding: boolean,
): BloodColorData {
  const percent = volume / initial;
  if (percent < 0.6 || internalBleeding) {
    return {
      background: BloodColors.CritBG,
      foreground: BloodColors.CritFG,
      darker: COLOR_DARKER_RED,
    };
  }
  if (percent < 0.9) {
    return {
      background: BloodColors.WarnBG,
      foreground: BloodColors.WarnFG,
      darker: COLOR_DARKER_YELLOW,
    };
  }
  return {
    background: BloodColors.FineBG,
    foreground: BloodColors.FineFG,
    darker: COLOR_MID_GREY,
  };
}
