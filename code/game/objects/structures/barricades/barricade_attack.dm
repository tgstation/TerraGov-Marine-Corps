/obj/structure/barricade/attack_hand_alternate(mob/living/user)
	if(anchored)
		balloon_alert(usr, "fastened to the floor")
		return FALSE

	setDir(turn(dir, 270))

/obj/structure/barricade/attack_animal(mob/user)
	return attack_alien(user)

/obj/structure/barricade/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE

	if(barricade_flags & BARRICADE_IS_WIRED)
		balloon_alert(xeno_attacker, "barbed wire slicing into you!")
		xeno_attacker.apply_damage(15, blocked = MELEE , sharp = TRUE, updating_health = TRUE)

	return ..()

/obj/structure/barricade/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
			return
		if(EXPLODE_HEAVY)
			take_damage(rand(33, 66), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 33), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(10, BRUTE, BOMB)
	update_appearance(UPDATE_ICON)

/obj/structure/barricade/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(!.)
		return
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		take_damage(acid_smoke_damage * S.strength, BURN, ACID)

/obj/structure/barricade/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return TRUE

	if(istype(I, stack_type))
		apply_stack(I, user)
		return TRUE

	if(!istype(I, /obj/item/stack/barbed_wire) || !(barricade_flags & BARRICADE_CAN_WIRE))
		return FALSE
	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return TRUE

	var/obj/item/stack/barbed_wire/B = I

	balloon_alert_to_viewers("setting up wire...")
	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_BUILD) || !(barricade_flags & BARRICADE_CAN_WIRE))
		return TRUE
	if(QDELETED(src))
		return TRUE
	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return TRUE

	playsound(loc, 'sound/effects/barbed_wire_movement.ogg', 25, 1)
	B.use(1)
	wire()
	return TRUE

///Applies the cades stack type to itself
/obj/structure/barricade/proc/apply_stack(obj/item/stack/sheet/stack, mob/user)
	if(obj_integrity >= max_integrity * 0.3)
		return
	if(!(barricade_flags & BARRICADE_STANDARD_REPAIR))
		return
	if(stack.get_amount() < BARRICADE_REPAIR_STACK_AMOUNT)
		balloon_alert(user, "[BARRICADE_REPAIR_STACK_AMOUNT] [stack_type::name] sheets required!")
		return
	if(LAZYACCESS(user.do_actions, src))
		return
	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return

	balloon_alert_to_viewers("repairing base...")
	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity * 0.3)
		return
	if(QDELETED(src))
		return
	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return
	if(!stack.use(BARRICADE_REPAIR_STACK_AMOUNT))
		return

	repair_damage(max_integrity * 0.3, user)
	balloon_alert_to_viewers("base repaired")
	update_appearance(UPDATE_ICON)
