import { LIMB_DAMAGE_HSL, ROBOT_LIMB_COLOR } from './constants';

/**
 * @param damage input damage level for returning a color
 * @param type string limb type for determining if we should return robot colors
 * @returns an hsl color string
 */
export function getLimbColor(damage: number, type?: string): string {
  if (type === 'Robotic') return ROBOT_LIMB_COLOR;
  if (damage <= 0) return 'white';
  if (damage > 1) return 'grey'; // greater than 100% damage can be safely considered a lost cause

  // scale hue linearly from 44/yellow (low damage) to 4/red (high damage)
  const hue = 44 - 40 * damage;
  return `hsl(${hue}, ${LIMB_DAMAGE_HSL.sat}, ${LIMB_DAMAGE_HSL.lum})`;
}
