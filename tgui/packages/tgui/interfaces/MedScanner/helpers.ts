import {
  COLOR_DARKER_ORANGE,
  COLOR_DARKER_RED,
  COLOR_DARKER_YELLOW,
  COLOR_MID_GREY,
  COLOR_ROBOTIC_LIMB,
  LIMB_DAMAGE_HSL,
} from './constants';
import {
  LimbTypes,
  MedColorTuple,
  OrganStatuses,
  RevivableStates,
  TempColor,
} from './data';

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
  const hue = 44 - 40 * damage;
  return `hsl(${hue}, ${LIMB_DAMAGE_HSL.sat}, ${LIMB_DAMAGE_HSL.lum})`;
}

/**
 * Helper for the limb type tag getting its color based on limb type
 * @param limbType string limb type for determining the output color
 * @param roboticToBeginWith if the patient is under the robot umbrella
 * @param accessible accessible theme status
 * @returns
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
 * Helper for getting the color of an organ
 * @param status the organ's status
 * @returns tuple: `0` is background color, `1` is foreground color, `2` is a darker color
 */
export function getOrganColor(status: OrganStatuses): MedColorTuple {
  if (status === OrganStatuses.OK) {
    return ['grey', 'white', COLOR_MID_GREY];
  }
  if (status === OrganStatuses.Bruised) {
    return ['orange', 'white', COLOR_DARKER_ORANGE];
  }
  if (status === OrganStatuses.Broken) {
    return ['red', 'white', COLOR_DARKER_RED];
  }
  return ['grey', 'white', COLOR_MID_GREY]; // fallback
}

/**
 * Helper for getting a color based on blood level
 * @param volume current blood level
 * @param initial initial blood level
 * @param internalBleeding internal bleeding status: overrides blood level and always returns red
 * @returns tuple: `0` is background color, `1` is foreground color, `2` is a darker color
 */
export function getBloodColor(
  volume: number,
  initial: number,
  internalBleeding: boolean,
): MedColorTuple {
  const percent = volume / initial;
  if (percent < 0.6 || internalBleeding) {
    return ['red', 'white', COLOR_DARKER_RED];
  }
  if (percent < 0.9) {
    return ['yellow', 'black', COLOR_DARKER_YELLOW];
  }
  return ['grey', 'white', COLOR_MID_GREY]; // fallback
}

/**
 * Helper for getting a color based on revivable status
 * @param status the revivable status enum
 * @param accessible accessible theme status
 * @returns string: a suitable color based on revivability
 */
export function getReviveColor(
  status: RevivableStates,
  accessible: boolean,
): string {
  if (status === RevivableStates.Never) return 'red'; // regardless of theme
  if (status === RevivableStates.NotYet) {
    return 'orange'; // also regardless of theme
  }
  if (status === RevivableStates.Ready) {
    return accessible ? 'yellow' : 'hsl(184, 65%, 85%)';
  }
  return 'orange'; // fallback
}

/**
 * Helper for getting a foreground (text) color based on temp color
 * @param color the TempColor enum
 * @returns string: a suitable color based on temperature
 */
export function getTempBoxTextColor(color: TempColor): string {
  if (color === TempColor.T1Heat) {
    return 'black'; // on yellow
  }
  if (color === TempColor.T2Heat) {
    return 'white'; // on orange
  }
  if (color === TempColor.T3Heat) {
    return 'white'; // on red
  }
  return 'black'; // on white (this should never appear in game, though)
}
