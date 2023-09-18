
// ***************************************
// *********** Front Armor
// ***************************************
//TODO: probably better make it a trait & move it to xenomorph level, but idk
/mob/living/carbon/xenomorph/crusher/projectile_hit(obj/projectile/proj, cardinal_move, uncrossing)
	if(SEND_SIGNAL(src, COMSIG_XENO_PROJECTILE_HIT, proj, cardinal_move, uncrossing) & COMPONENT_PROJECTILE_DODGE)
		return FALSE
	if(proj.ammo.flags_ammo_behavior & AMMO_SKIPS_ALIENS)
		return FALSE
	if((cardinal_move & REVERSE_DIR(dir)))
		proj.damage -= proj.damage * (0.5 * get_sunder())
	return ..()
