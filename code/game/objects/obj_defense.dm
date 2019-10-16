/obj/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(QDELETED(src))
		CRASH("[src] taking damage after deletion")
	
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	
	if((resistance_flags & INDESTRUCTIBLE) || obj_integrity <= 0)
		return
	damage_amount = run_obj_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration)
	
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
		obj_destruction(damage_flag)


/obj/proc/repair_damage(repair_amount)
	obj_integrity = min(obj_integrity + repair_amount, max_integrity)


///returns the damage value of the attack after processing the obj's various armor protections
/obj/proc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penetration = 0)
	if(!damage_type)
		return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	if(armor_protection)		//Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = CLAMP(armor_protection - armour_penetration, min(armor_protection, 0), 100)
	return round(damage_amount * (100 - armor_protection) * 0.01, DAMAGE_PRECISION)


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


/obj/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	. = ..() //contents explosion
	if(target == src)
		take_damage(INFINITY, BRUTE, "bomb", 0)
		return
	switch(severity)
		if(1)
			take_damage(INFINITY, BRUTE, "bomb", 0)
		if(2)
			take_damage(rand(100, 250), BRUTE, "bomb", 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, "bomb", 0)


/obj/hitby(atom/movable/AM)
	. = ..()
	visible_message("<span class='warning'>[src] was hit by [AM].</span>")
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else if(isobj(AM))
		var/obj/item/I = AM
		tforce = I.throwforce
	take_damage(tforce, BRUTE, "melee", 1, get_dir(src, AM))


/obj/bullet_act(obj/item/projectile/P)
	if(istype(P.ammo, /datum/ammo/xeno) && !(resistance_flags & XENO_DAMAGEABLE))
		return
	. = ..()
	playsound(loc, P.hitsound, 50, 1)
	visible_message("<span class='warning'>\the [src] is damaged by \the [P]!</span>")
	bullet_ping(P)
	take_damage(P.damage, P.ammo.damage_type, P.ammo.armor_type, 0, turn(P.dir, 180), P.ammo.penetration)


/obj/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0) //used by attack_alien, attack_animal, and attack_slime
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	return take_damage(damage_amount, damage_type, damage_flag, sound_effect, get_dir(src, user), armor_penetration)


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


/obj/attack_alien(mob/living/carbon/xenomorph/X)
	if(!(resistance_flags & XENO_DAMAGEABLE))
		to_chat(X, "<span class='warning'>We stare at \the [src] cluelessly.</span>")
		return
	X.visible_message("<span class='danger'>[X] has slashed [src]!</span>",
	"<span class='danger'>We slash [src]!</span>")
	X.flick_attack_overlay(src, "slash")
	playsound(loc, "alien_claw_metal", 25)
	attack_generic(X, X.xeno_caste.melee_damage, BRUTE, "melee", FALSE)


/obj/attack_larva(mob/living/carbon/xenomorph/larva/L)
	L.visible_message("<span class='danger'>[L] nudges its head against [src].</span>", \
	"<span class='danger'>You nudge your head against [src].</span>")


///the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	SEND_SIGNAL(src, COMSIG_OBJ_DECONSTRUCT, disassembled)
	qdel(src)


///called after the obj takes damage and integrity is below integrity_failure level
/obj/proc/obj_break(damage_flag)
	return


///what happens when the obj's integrity reaches zero.
/obj/proc/obj_destruction(damage_flag)
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
