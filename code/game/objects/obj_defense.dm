//We will round to this value in damage calculations.
#define DAMAGE_PRECISION 0.1

//the essential proc to call when an obj must receive damage of any kind.
/obj/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	if(QDELETED(src))
		stack_trace("[src] taking damage after deletion")
		return
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if(!(resistance_flags & INDESTRUCTIBLE) && obj_integrity > 0)
		damage_amount = run_obj_armor(damage_amount, damage_type, damage_flag, attack_dir, armour_penetration)
		if(damage_amount >= DAMAGE_PRECISION)
			. = damage_amount
			var/old_integ = obj_integrity
			obj_integrity = max(old_integ - damage_amount, 0)
			if(obj_integrity <= 0)
				var/int_fail = integrity_failure
				if(int_fail && old_integ > int_fail)
					obj_break(damage_flag)
				obj_destruction(damage_flag)
			else if(integrity_failure)
				if(obj_integrity <= integrity_failure)
					obj_break(damage_flag)

//returns the damage value of the attack after processing the obj's various armor protections
/obj/proc/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir, armour_penetration = 0)
	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	if(armor_protection)		//Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = CLAMP(armor_protection - armour_penetration, 0, 100)
	return round(damage_amount * (100 - armor_protection)*0.01, DAMAGE_PRECISION)

//the sound played when the obj is damaged.
/obj/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	..()
	take_damage(AM.throwforce, BRUTE, "melee", 1, get_dir(src, AM))

/obj/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	..() //contents explosion
	if(target == src)
		obj_integrity = 0
		qdel(src)
		return
	switch(severity)
		if(1)
			obj_integrity = 0
			qdel(src)
		if(2)
			take_damage(rand(100, 250), BRUTE, "bomb", 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, "bomb", 0)

/obj/bullet_act(obj/item/projectile/P)
	. = ..()
	playsound(src, P.hitsound, 50, 1)
	visible_message("<span class='danger'>[src] is hit by \a [P]!</span>", null, null, 3)
	if(!QDELETED(src)) //Bullet on_hit effect might have already destroyed this object
		take_damage(P.damage, P.ammo.damage_type, P.armor_type, 0, turn(P.dir, 180), P.ammo.penetration)

/obj/proc/attack_generic(mob/living/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0) //used by attack_alien, attack_animal, and attack_slime
	user.animation_attack_on(src)
	user.changeNext_move(CLICK_CD_MELEE)
	return take_damage(damage_amount, damage_type, damage_flag, sound_effect, get_dir(src, user), armor_penetration)

/obj/attack_alien(mob/living/carbon/Xenomorph/user)
	if(attack_generic(user, 60, BRUTE, "melee", 0))
		playsound(loc, "alien_claw_metal", 25, 1)

/obj/attack_animal(mob/living/simple_animal/M)
	if(!M.melee_damage_upper && !M.obj_damage)
		M.emote("custom", message = "[M.friendly] [src].")
		return 0
	else
		var/play_soundeffect = 1
		if(M.environment_smash)
			play_soundeffect = 0
		if(M.obj_damage)
			. = attack_generic(M, M.obj_damage, M.melee_damage_type, "melee", play_soundeffect, M.armour_penetration)
		else
			. = attack_generic(M, rand(M.melee_damage_lower,M.melee_damage_upper), M.melee_damage_type, "melee", play_soundeffect, M.armour_penetration)
		if(. && !play_soundeffect)
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)

//the obj is deconstructed into pieces, whether through careful disassembly or when destroyed.
/obj/proc/deconstruct(disassembled = TRUE)
	SEND_SIGNAL(src, COMSIG_OBJ_DECONSTRUCT, disassembled)
	qdel(src)

//what happens when the obj's health is below integrity_failure level.
/obj/proc/obj_break(damage_flag)
	return

//what happens when the obj's integrity reaches zero.
/obj/proc/obj_destruction(damage_flag)
	deconstruct(FALSE)

//changes max_integrity while retaining current health percentage
//returns TRUE if the obj broke, FALSE otherwise
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

//returns how much the object blocks an explosion
/obj/proc/GetExplosionBlock()
	CRASH("Unimplemented GetExplosionBlock()")
