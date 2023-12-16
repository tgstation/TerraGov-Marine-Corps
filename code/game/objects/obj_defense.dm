/obj/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", effects = TRUE, attack_dir, armour_penetration = 0)
	if(QDELETED(src))
		CRASH("[src] taking damage after deletion")
	if(!damage_amount)
		return
	if(effects)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if((resistance_flags & INDESTRUCTIBLE) || obj_integrity <= 0)
		return

	if(damage_flag)
		damage_amount = round(modify_by_armor(damage_amount, damage_flag, armour_penetration), DAMAGE_PRECISION)
	if(damage_amount < DAMAGE_PRECISION)
		return
	. = damage_amount
	obj_integrity = max(obj_integrity - damage_amount, 0)
	update_icon()

	//BREAKING FIRST
	if(integrity_failure && obj_integrity <= integrity_failure)
		obj_break(damage_flag)

	//DESTROYING SECOND
	if(obj_integrity <= 0)
		obj_destruction(damage_amount, damage_type, damage_flag)

///Increase obj_integrity and record it to the repairer's stats
/obj/proc/repair_damage(repair_amount, mob/user)
	repair_amount = min(repair_amount, max_integrity - obj_integrity)
	if(user?.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
		personal_statistics.integrity_repaired += repair_amount
		personal_statistics.times_repaired++
	obj_integrity += repair_amount

///the sound played when the obj is damaged.
/obj/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(hit_sound)
		playsound(loc, hit_sound, 40, 1)
		return

	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/weapons/smash.ogg', 25, 1)
			else
				playsound(loc, 'sound/weapons/tap.ogg', 25, 1)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 50, 1)


/obj/ex_act(severity)
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		return
	. = ..() //contents explosion
	if(QDELETED(src))
		return
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(INFINITY, BRUTE, BOMB, 0)
		if(EXPLODE_HEAVY)
			take_damage(rand(100, 250), BRUTE, BOMB, 0)
		if(EXPLODE_LIGHT)
			take_damage(rand(10, 90), BRUTE, BOMB, 0)
		if(EXPLODE_WEAK)
			take_damage(rand(5, 45), BRUTE, BOMB, 0)


/obj/hitby(atom/movable/AM, speed = 5)
	. = ..()
	if(!.)
		return
	if(!anchored && (move_resist < MOVE_FORCE_STRONG))
		step(src, AM.dir)
	visible_message(span_warning("[src] was hit by [AM]."), visible_message_flags = COMBAT_MESSAGE)
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	take_damage(tforce, BRUTE, MELEE, 1, get_dir(src, AM))


/obj/bullet_act(obj/projectile/P)
	if(istype(P.ammo, /datum/ammo/xeno) && !(resistance_flags & XENO_DAMAGEABLE))
		return
	. = ..()
	if(P.damage < 1)
		return
	playsound(loc, P.hitsound, 50, 1)
	visible_message(span_warning("\the [src] is damaged by \the [P]!"), visible_message_flags = COMBAT_MESSAGE)
	take_damage(P.damage, P.ammo.damage_type, P.ammo.armor_type, 0, REVERSE_DIR(P.dir), P.ammo.penetration)


/obj/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src, ATTACK_EFFECT_SMASH)
	user.changeNext_move(CLICK_CD_MELEE)
	return take_damage(damage_amount, damage_type, damage_flag, effects, get_dir(src, user), armor_penetration)


/obj/attack_animal(mob/living/simple_animal/M)
	if(!M.melee_damage && !M.obj_damage)
		M.emote("custom", message = "[M.friendly] [src].")
		return 0
	else
		var/play_soundeffect = 1
		if(M.obj_damage)
			. = attack_generic(M, M.obj_damage, M.melee_damage_type, "melee", play_soundeffect, M.armour_penetration)
		else
			. = attack_generic(M, M.melee_damage, M.melee_damage_type, "melee", play_soundeffect, M.armour_penetration)
		if(. && !play_soundeffect)
			playsound(loc, 'sound/effects/meteorimpact.ogg', 100, 1)


/obj/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	// SHOULD_CALL_PARENT(TRUE) // TODO: fix this
	if(X.status_flags & INCORPOREAL) //Ghosts can't attack machines
		return FALSE
	SEND_SIGNAL(X, COMSIG_XENOMORPH_ATTACK_OBJ, src)
	if(SEND_SIGNAL(src, COMSIG_OBJ_ATTACK_ALIEN, X) & COMPONENT_NO_ATTACK_ALIEN)
		return FALSE
	if(!(resistance_flags & XENO_DAMAGEABLE))
		to_chat(X, span_warning("We stare at \the [src] cluelessly."))
		return FALSE
	if(effects)
		X.visible_message(span_danger("[X] has slashed [src]!"),
		span_danger("We slash [src]!"))
		X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
		playsound(loc, "alien_claw_metal", 25)
	attack_generic(X, damage_amount, damage_type, damage_flag, effects, armor_penetration)
	return TRUE

/obj/attack_larva(mob/living/carbon/xenomorph/larva/L)
	L.visible_message(span_danger("[L] nudges its head against [src]."), \
	span_danger("You nudge your head against [src]."))


///the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_OBJ_DECONSTRUCT, disassembled)
	qdel(src)


///called after the obj takes damage and integrity is below integrity_failure level
/obj/proc/obj_break(damage_flag)
	return


///what happens when the obj's integrity reaches zero.
/obj/proc/obj_destruction(damage_amount, damage_type, damage_flag)
	SHOULD_CALL_PARENT(TRUE)
	if(destroy_sound)
		playsound(loc, destroy_sound, 35, 1)
	deconstruct(FALSE)


///changes max_integrity while retaining current health percentage, returns TRUE if the obj got broken.
/obj/proc/modify_max_integrity(new_max, can_break = TRUE, damage_type = BRUTE, new_failure_integrity = null)
	var/current_integrity = obj_integrity
	var/current_max = max_integrity

	if(current_integrity != 0 && current_max != 0)
		var/percentage = current_integrity / current_max
		current_integrity = max(1, round(percentage * new_max))	//don't destroy it as a result
		obj_integrity = current_integrity

	max_integrity = new_max

	if(new_failure_integrity != null)
		integrity_failure = new_failure_integrity

	if(can_break && integrity_failure && current_integrity <= integrity_failure)
		obj_break(damage_type)
		return TRUE
	return FALSE

///returns how much the object blocks an explosion. Used by subtypes.
/obj/proc/GetExplosionBlock(explosion_dir)
	CRASH("Unimplemented GetExplosionBlock()")
