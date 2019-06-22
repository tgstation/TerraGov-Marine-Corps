#define FLAMER_LIT				(1 << 0)
#define FLAMER_COOLDOWN			(1 << 1)
#define FLAMER_ALWAYS_LIT		(1 << 2)
#define FLAMER_INTERNAL_TANK	(1 << 3)

#define NAPALM_TRIANGULAR		(1 << 0)

/datum/component/flamethrower
	var/flamer_flags
	var/obj/item/reagent_container/flamer_tank/tank
	var/max_range = INFINITY // limit that overrides reagent limit
	var/fire_delay
	var/fire_sound = 'sound/weapons/gun_flamethrower3.ogg'
	var/reagent_consumption = 5

/datum/component/flamethrower/Initialize(flamer_flags, obj/item/reagent_container/flamer_tank/tank, fire_delay, max_range)
	. = ..()
	src.flamer_flags = flamer_flags
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
	if(!istype(I, /obj/item/reagent_container))
		return
	if(!tank)
		if(!istype(I, /obj/item/reagent_container/flamer_tank))
			if(user)
				to_chat(user, "theres no tank loaded, load one first")
			return COMPONENT_NO_AFTERATTACK
		if(flamer_flags & FLAMER_INTERNAL_TANK)
			CRASH("somehow a flamer with an internal tank no longer has a tank")
		if(user)
			user.dropItemToGround(I)
			to_chat(user, "you load a new tank")
		tank = I
		I.moveToNullspace()
		return COMPONENT_NO_AFTERATTACK
	I.afterattack(tank, user, TRUE)
	return COMPONENT_NO_AFTERATTACK

/datum/component/flamethrower/proc/fire(datum/source, atom/target, mob/user)
	. = COMPONENT_GUN_FIRED
	to_chat(world, "got fire signal, [source], [target], [user]")
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

	if(!tank.reagents?.total_volume)
		to_chat(user, "empty tank or no reagents datum on tank")
		return

	var/datum/reagent/napalm/R = tank.reagents.get_master_reagent()
	if(!istype(R))
		to_chat(user, "no napalm reagent in tank")
		return

	var/power = 100
	if(R.volume < tank.reagents.total_volume)
		power = R.volume / max(tank.reagents.total_volume, 1)

	unleash_flame(target, user, R, power)

/datum/component/flamethrower/proc/unleash_flame(atom/target, mob/living/user, datum/reagent/napalm/R, power)
	flamer_flags |= FLAMER_COOLDOWN
	to_chat(user, "unleashing flame")
	if(R.napalm_flags & NAPALM_TRIANGULAR)
		flame_triangular(target, user, R, power)
	else
		flame_line(target, user, R, power)

	addtimer(CALLBACK(src, .proc/cooldown_end), fire_delay)

/datum/component/flamethrower/proc/cooldown_end()
	DISABLE_BITFIELD(flamer_flags, FLAMER_COOLDOWN)

/datum/component/flamethrower/proc/flame_line(atom/target, mob/living/user, datum/reagent/napalm/R, power)
	to_chat(user, "flaming a line to [target]")
	var/list/turf/turfs = getline(get_turf(parent),target)
	to_chat(user, "line is [jointext(turfs, ", ")]")
	playsound(parent, fire_sound, 50, 1)
	var/turf/prev_T
	var/delay = 0
	var/distance = 1

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
		if(R.volume < reagent_consumption)
			to_chat(user, "not enough reagent")
			break
		if(distance > min(R.max_range, max_range))
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

		R.volume -= reagent_consumption
		if(delay < 1)
			INVOKE_ASYNC(src, .proc/flame_turf, TF, user, R, power)
		else
			addtimer(CALLBACK(src, .proc/flame_turf, TF, user, R, power), delay)
		delay++
		if(blocked)
			break
		distance++
		prev_T = T

/datum/component/flamethrower/proc/flame_triangular(atom/target, mob/living/user, datum/reagent/napalm/R, power)
	var/unleash_dir = user.dir //don't want the player to turn around mid-unleash to bend the fire.
	var/list/turf/turfs = getline(user,target)
	playsound(parent, fire_sound, 50, 1)
	var/distance = 1
	var/turf/prev_T
	var/delay = 0

	for(var/turf/T in turfs)
		if(T == get_turf(parent))
			prev_T = T
			continue
		if(T.density)
			break
		if(get_turf(parent) != user)
			break
		if(R.volume < reagent_consumption)
			break
		if(distance > min(R.max_range, max_range))
			break
		if(prev_T && LinkBlocked(prev_T, T))
			break
		R.volume -= reagent_consumption
		if(delay < 1)
			INVOKE_ASYNC(src, .proc/flame_turf, T, user, R, power)
		else
			addtimer(CALLBACK(src, .proc/flame_turf, T, user, R, power), delay)
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

			addtimer(CALLBACK(src, .proc/flame_turf, RT, user, R, power), delay)
			prev_R = R
			delay++

		var/turf/prev_L = T
		for (var/turf/L in left)
			if (L.density)
				break
			if(prev_L && LinkBlocked(prev_L, L))
				break

			addtimer(CALLBACK(src, .proc/flame_turf, L, user, R, power), delay)
			prev_L = L
			delay++

		distance++


/datum/component/flamethrower/proc/flame_turf(turf/T, mob/living/user, datum/reagent/napalm/R, power)
	if(!istype(T))
		return

	T.ignite(R.burntime * power, R.burnlevel * power, R.flame_color)

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
		M.apply_damage(rand(R.burnlevel*power,(R.burnlevel*power*2))* fire_mod, BURN, null, armor_block) // Make it so its the amount of heat or twice it for the initial blast.

		M.adjust_fire_stacks(rand(5,R.burnlevel*power*2))
		M.IgniteMob()

		to_chat(M, "[isxeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!")


/obj/item/reagent_container/flamer_tank
	name = "abstract flamer tank"

/obj/item/reagent_container/flamer_tank/regular
	volume = 300
	list_reagents = list("napalm" = 300)

/obj/item/reagent_container/flamer_tank/internal
	volume = 100
	list_reagents = list("napalm" = 100)

/datum/reagent/napalm
	name = "napalm"
	id = "napalm"
	description = "Required for flamerthrowers. Highly flamable."
	color = "#660000" // rgb: 102, 0, 0
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "gross metal"
	var/napalm_flags
	var/burntime = 17
	var/burnlevel = 24
	var/max_range = 6
	var/flame_color = "red" // todo: replace the sprite with a white one and color it based on reagent color var

/datum/reagent/napalm/green
	name = "green napalm"
	id = "greennapalm"
	napalm_flags = NAPALM_TRIANGULAR
	burnlevel = 10
	burntime = 50
	max_range = 4
	flame_color = "green"

/datum/reagent/napalm/blue
	name = "blue napalm"
	id = "bluenapalm"
	burnlevel = 45
	burntime = 40
	max_range = 7
	flame_color = "blue"

// add on mob life etc


