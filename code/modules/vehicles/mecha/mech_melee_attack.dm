/**
 * ## Mech melee attack
 * Called when a mech melees a target with fists
 * Handles damaging the target & associated effects
 * return value is number of damage dealt
 * Arguments:
 * * mecha_attacker: Mech attacking this target
 * * user: mob that initiated the attack from inside the mech as a controller
 */
/atom/proc/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	SHOULD_CALL_PARENT(TRUE)
	log_combat(user, src, "attacked", mecha_attacker, "(INTENT: [uppertext(user.a_intent)] (DAMTYPE: [uppertext(mecha_attacker.damtype)])")
	return 0

/obj/mech_melee_attack(obj/vehicle/sealed/mecha/mecha_attacker, mob/living/user)
	mecha_attacker.do_attack_animation(src)
	switch(mecha_attacker.damtype)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 50, TRUE)
		else
			return 0
	mecha_attacker.visible_message(span_danger("[mecha_attacker] hits [src]!"), span_danger("You hit [src]!"), null, COMBAT_MESSAGE_RANGE)
	..()
	return take_damage(mecha_attacker.force * 3, mecha_attacker.damtype, MELEE, FALSE, get_dir(src, mecha_attacker)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

///Mech shift click functionality
/atom/proc/mech_shift_click(obj/vehicle/sealed/mecha/mecha_clicker, mob/living/user)
	return
