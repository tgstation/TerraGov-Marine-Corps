import {
  COLOR_DARKER_RED,
  COLOR_DARKER_YELLOW,
  COLOR_MID_GREY,
  COLOR_ROBOTIC_LIMB,
  LIMB_DAMAGE_HSL as LIMB_HSL,
} from './constants';
import { LimbTypes, MedColors } from './data';

/**
 * Helper for getting the name color of a limb based on relevant factors
 * @param bruteDamage brute damage number
 * @param burnDamage burn damage number
 * @param maxHealth maximum health of this limb
 * @param limbType string limb type for determining if we should return robot colors
 * @returns an hsl color string
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
 * @param limbType string limb type for determining the output color
 * @param roboticToBeginWith if the patient is under the robot umbrella
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
  }
  if (limbType === LimbTypes.Biotic) {
    return 'tan';
  }
  return 'white'; // fallback (if we ever show that a limb is Normal lmfao)
}

/**
 * Helper for getting a color based on blood level
 * @param volume current blood level
 * @param initial initial blood level
 * @param internalBleeding internal bleeding status: overrides blood level and always returns red
 * @returns MedColorTuple: `0` is background color, `1` is foreground color, `2` is a darker color
 */
export function getBloodColor(
  volume: number,
  initial: number,
  internalBleeding: boolean,
): MedColors {
  const percent = volume / initial;
  if (percent < 0.6 || internalBleeding) {
    return { background: 'red', foreground: 'white', darker: COLOR_DARKER_RED };
  }
  if (percent < 0.9) {
    return {
      background: 'yellow',
      foreground: 'black',
      darker: COLOR_DARKER_YELLOW,
    };
  }
  return { background: 'grey', foreground: 'white', darker: COLOR_MID_GREY }; // fallback
}
