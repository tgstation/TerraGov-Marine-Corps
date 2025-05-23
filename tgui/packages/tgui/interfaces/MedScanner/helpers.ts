import { COLOR_ROBOTIC_LIMB, LIMB_DAMAGE_HSL } from './constants';

/**
 * @param bruteDamage brute damage number
 * @param burnDamage burn damage number
 * @param maxHealth maximum health of this limb
 * @param limbType string limb type for determining if we should return robot colors
 * @returns an hsl color string
 */
export function getLimbColor(
  bruteDamage: number,
  burnDamage: number,
  maxHealth: number,
  limbType?: string,
): string {
  const damage = (bruteDamage + burnDamage) / maxHealth;
  if (limbType === 'Robotic') return COLOR_ROBOTIC_LIMB;
  if (damage <= 0) return 'white';
  if (damage > 1) return 'grey'; // greater than 100% damage can be safely considered a lost cause

  // scale hue linearly from 44/yellow (low damage) to 4/red (high damage)
  const hue = 44 - 40 * damage;
  return `hsl(${hue}, ${LIMB_DAMAGE_HSL.sat}, ${LIMB_DAMAGE_HSL.lum})`;
}
