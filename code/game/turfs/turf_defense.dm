///the essential proc to call when an obj must receive damage of any kind.
/turf/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE)
	testing("attackby2")
	if(damage_flag == "melee" && damage_amount < damage_deflection)
		return 0
	if(QDELETED(src))
		stack_trace("[src] taking damage after deletion")
		return
	if(sound_effect)
		playsound(src, pick(attacked_sound), 100, FALSE)
	if(turf_integrity <= 0)
		return
	damage_amount = damage_amount
	. = damage_amount
	turf_integrity = max(turf_integrity - damage_amount, 0)
	//BREAKING FIRST
	if(integrity_failure && turf_integrity <= integrity_failure * max_integrity)
		turf_break(damage_flag)
		if(break_message)
			visible_message(break_message)
		if(break_sound)
			playsound(src, break_sound, 100, TRUE)
	//DESTROYING SECOND
	if(turf_integrity <= 0)
		if(islist(debris))
			for(var/I in debris)
				for(var/i in 1 to debris[I])
					new I (get_turf(src))
		if(break_message)
			visible_message(break_message)
		if(break_sound)
			playsound(src, break_sound, 100, TRUE)
		turf_destruction(damage_flag)

///called after the obj takes damage and integrity is below integrity_failure level
/turf/proc/turf_break(damage_flag)
	return

///what happens when the obj's integrity reaches zero.
/turf/proc/turf_destruction(damage_flag)
	return

/turf/bullet_act(obj/projectile/P)
	. = ..()
	if(. != BULLET_ACT_FORCE_PIERCE)
//		. =  BULLET_ACT_TURF
		testing("hitturf [src]")
		P.handle_drop()
		return BULLET_ACT_HIT