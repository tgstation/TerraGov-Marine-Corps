#define FLAMER_LIT				(1 << 0)
#define FLAMER_COOLDOWN			(1 << 1)
#define FLAMER_ALWAYS_LIT		(1 << 2)
#define FLAMER_INTERNAL_TANK	(1 << 3)

/datum/component/flamethrower
	var/flamer_flags
	var/obj/item/ammo_magazine/flamer_tank/tank
	var/max_range = INFINITY // limit that overrides reagent limit
	var/fire_delay
	var/fire_sound = 'sound/weapons/gun_flamethrower3.ogg'

/datum/component/flamethrower/Initialize(flamer_flags, obj/item/ammo_magazine/flamer_tank/tank, fire_delay, max_range)
	. = ..()
	src.flamer_flags = flamer_flags
	if(flamer_flags & FLAMER_INTERNAL_TANK)
		src.tank = new /obj/item/ammo_magazine/flamer_tank/internal
	else
		src.tank = tank
	src.fire_delay = fire_delay
	if(max_range)
		src.max_range = max_range

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/attackby)
	RegisterSignal(parent, COMSIG_GUN_FIRE, .proc/fire)
	RegisterSignal(parent, COMSIG_GUN_UNIQUE_ACTION, .proc/toggle_flame)
	RegisterSignal(parent, COMSIG_FLAMER_IGNITABLE, .proc/ignitable_source)

/datum/component/flamethrower/proc/ignitable_source()
	if(flamer_flags & FLAMER_ALWAYS_LIT|FLAMER_LIT)
		return COMPONENT_FLAMER_IGNITABLE
	return COMPONENT_FLAMER_UNLIT

/datum/component/flamethrower/proc/toggle_flame()
	if(flamer_flags & FLAMER_ALWAYS_LIT)
		return

	TOGGLE_BITFIELD(flamer_flags, FLAMER_LIT)

	SEND_SIGNAL(parent, COMSIG_FLAMER_LIT_STATE, flamer_flags & FLAMER_LIT)

/datum/component/flamethrower/proc/attackby(datum/source, obj/item/I, mob/user, params)
	if(tank)
		if(!is_type_in_typecache(I, GLOB.flamer_refill_objects))
			return
		tank.refill_from(I, user)
		return COMPONENT_NO_AFTERATTACK

	if(!istype(I, /obj/item/ammo_magazine/flamer_tank))
		return

	if(flamer_flags & FLAMER_INTERNAL_TANK)
		CRASH("somehow a flamer with an internal tank no longer has a tank")
	if(user)
		user.dropItemToGround(I)
		to_chat(user, "you load a new tank")
	tank = I
	I.moveToNullspace()
	return COMPONENT_NO_AFTERATTACK

/datum/component/flamethrower/proc/fire(datum/source, atom/target, mob/user)
	. = COMPONENT_GUN_FIRED

	if(!(flamer_flags & FLAMER_LIT|FLAMER_ALWAYS_LIT))
		to_chat(user, "not lit")
		return

	if(flamer_flags & FLAMER_COOLDOWN)
		to_chat(user, "on cooldown")
		return

	if(!tank)
		to_chat(user, "no tank")
		return

	if(!get_turf(target))
		to_chat(user, "nullspace target")
		return // protect against nullspace

	if(!tank.current_rounds)
		to_chat(user, "<span class='warning'>The tank is empty!</span>")
		return

	unleash_flame(target, user)

/datum/component/flamethrower/proc/unleash_flame(atom/target, mob/living/user)
	flamer_flags |= FLAMER_COOLDOWN
	to_chat(user, "unleashing flame")
	if(tank.default_ammo == /datum/ammo/flamethrower/green)
		flame_triangular(target, user)
	else
		flame_line(target, user)

	addtimer(CALLBACK(src, .proc/cooldown_end), fire_delay)

/datum/component/flamethrower/proc/cooldown_end()
	DISABLE_BITFIELD(flamer_flags, FLAMER_COOLDOWN)

/datum/component/flamethrower/proc/flame_line(atom/target, mob/living/user)
	to_chat(user, "flaming a line to [target]")
	var/list/turf/turfs = getline(get_turf(parent),target)
	to_chat(user, "line is [jointext(turfs, ", ")]")
	playsound(parent, fire_sound, 50, 1)
	var/turf/prev_T
	var/delay = 0
	var/distance = 1
	var/max_distance = max_range
	var/burnlevel
	var/burntime
	var/flame_color = "red"

	// again, will be replaced by reagents
	if(tank.caliber == "Fuel")
		burnlevel = 10
		burntime = 12
		
	else
		switch(tank.default_ammo)
			if(/datum/ammo/flamethrower)
				max_distance = min(max_range, 6)
				burnlevel = 24
				burntime = 17

			if(/datum/ammo/flamethrower/blue)
				max_distance = min(max_range, 7)
				burnlevel = 45
				burntime = 40
				flame_color = "blue"

	for(var/F in turfs)
		var/turf/T = F
		to_chat(user, "flaming turf [T]")
		if(T == get_turf(parent))
			prev_T = T
			continue
		if((T.density && !istype(T, /turf/closed/wall/resin)) || isspaceturf(T))
			to_chat(user, "dense turf hit")
			break
		if(!(parent in user))
			to_chat(user, "flamer not in contents of user")
			break
		if(!tank.current_rounds)
			to_chat(user, "not enough reagent")
			break
		if(distance > max_distance)
			to_chat(user, "gone too far")
			break

		var/blocked = FALSE
		for(var/obj/O in T)
			if(O.density && !O.throwpass && !(O.flags_atom & ON_BORDER))
				blocked = TRUE
				break

		var/turf/TF
		if(!prev_T.Adjacent(T) && (T.x != prev_T.x || T.y != prev_T.y)) //diagonally blocked, it will seek for a cardinal turf by the former target.
			blocked = TRUE
			var/turf/Ty = locate(prev_T.x, T.y, prev_T.z)
			var/turf/Tx = locate(T.x, prev_T.y, prev_T.z)
			for(var/turf/TB in shuffle(list(Ty, Tx)))
				if(prev_T.Adjacent(TB) && ((!TB.density && !isspaceturf(T)) || istype(T, /turf/closed/wall/resin)))
					TF = TB
					break
			if(!TF)
				break
		else
			TF = T

		tank.current_rounds--
		if(delay < 1)
			INVOKE_ASYNC(src, .proc/flame_turf, TF, user, burnlevel, burntime, flame_color)
		else
			addtimer(CALLBACK(src, .proc/flame_turf, TF, user, burnlevel, burntime, flame_color), delay)
		delay++
		if(blocked)
			break
		distance++
		prev_T = T

/datum/component/flamethrower/proc/flame_triangular(atom/target, mob/living/user)
	var/unleash_dir = user.dir //don't want the player to turn around mid-unleash to bend the fire.
	var/list/turf/turfs = getline(user,target)
	playsound(parent, fire_sound, 50, 1)
	var/distance = 1
	var/turf/prev_T
	var/delay = 0
	var/max_distance = min(max_range, 4)
	var/flame_color = "green"
	var/burnlevel = 10
	var/burntime = 50

	for(var/turf/T in turfs)
		if(T == get_turf(parent))
			prev_T = T
			continue
		if(T.density)
			break
		if(get_turf(parent) != user)
			break
		if(!tank.current_rounds)
			break
		if(distance > max_distance)
			break
		if(prev_T && LinkBlocked(prev_T, T))
			break
		tank.current_rounds--
		if(delay < 1)
			INVOKE_ASYNC(src, .proc/flame_turf, T, user, burnlevel, burntime, flame_color)
		else
			addtimer(CALLBACK(src, .proc/flame_turf, T, user, burnlevel, burntime, flame_color), delay)
		delay++
		prev_T = T

		var/list/turf/right = list()
		var/list/turf/left = list()
		var/turf/right_turf = T
		var/turf/left_turf = T
		var/right_dir = turn(unleash_dir, 90)
		var/left_dir = turn(unleash_dir, -90)
		for (var/i = 0, i < distance - 1, i++)
			right_turf = get_step(right_turf, right_dir)
			right += right_turf
			left_turf = get_step(left_turf, left_dir)
			left += left_turf

		var/turf/prev_R = T
		for (var/turf/RT in right)

			if (RT.density)
				break
			if(prev_R && LinkBlocked(prev_R, RT))
				break

			addtimer(CALLBACK(src, .proc/flame_turf, RT, user, burnlevel, burntime, flame_color), delay)
			prev_R = RT
			delay++

		var/turf/prev_L = T
		for (var/turf/L in left)
			if (L.density)
				break
			if(prev_L && LinkBlocked(prev_L, L))
				break

			addtimer(CALLBACK(src, .proc/flame_turf, L, user, burnlevel, burntime, flame_color), delay)
			prev_L = L
			delay++

		distance++


/datum/component/flamethrower/proc/flame_turf(turf/T, mob/living/user, burnlevel, burntime, flame_color)
	if(!istype(T))
		return

	T.ignite(burntime, burnlevel, flame_color)

	// Melt a single layer of snow
	if(istype(T, /turf/open/floor/plating/ground/snow))
		var/turf/open/floor/plating/ground/snow/S = T

		if (S.slayer > 0)
			S.slayer -= 1
			S.update_icon(1, 0)

	for(var/obj/structure/jungle/vines/V in T)
		qdel(V)

	var/fire_mod
	for(var/mob/living/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)
			continue

		fire_mod = 1

		if(isxeno(M))
			var/mob/living/carbon/xenomorph/X = M
			if(X.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
				continue
			fire_mod = CLAMP(X.xeno_caste.fire_resist + X.fire_resist_modifier, 0, 1)
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M //fixed :s

			if(user)
				var/area/A = get_area(user)
				if(!user.mind?.bypass_ff && !H.mind?.bypass_ff && user.faction == H.faction)
					log_combat(user, H, "shot", src)
					msg_admin_ff("[ADMIN_TPMONTY(usr)] shot [ADMIN_TPMONTY(H)] with \a [parent] in [ADMIN_VERBOSEJMP(A)].")
				else
					log_combat(user, H, "shot", src)
					msg_admin_attack("[ADMIN_TPMONTY(usr)] shot [ADMIN_TPMONTY(H)] with \a [parent] in [ADMIN_VERBOSEJMP(A)].")

			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || (istype(H.wear_suit, /obj/item/clothing/suit/storage/marine/M35) && istype(H.head, /obj/item/clothing/head/helmet/marine/pyro)))
				continue

		var/armor_block = M.run_armor_check(null, "fire")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || (istype(H.wear_suit, /obj/item/clothing/suit/storage/marine/M35) && istype(H.head, /obj/item/clothing/head/helmet/marine/pyro)))
				H.show_message(text("Your suit protects you from most of the flames."), 1)
				armor_block = CLAMP(armor_block * 1.5, 0.75, 1) //Min 75% resist, max 100%
		M.apply_damage(rand(burnlevel,(burnlevel*2))* fire_mod, BURN, null, armor_block) // Make it so its the amount of heat or twice it for the initial blast.

		M.adjust_fire_stacks(rand(5,burnlevel*2))
		M.IgniteMob()

		to_chat(M, "[isxeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!")

