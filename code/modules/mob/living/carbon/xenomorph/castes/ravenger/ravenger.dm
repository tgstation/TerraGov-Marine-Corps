//Super hacky firebreathing Halloween rav.
/datum/xeno_caste/ravager/ravenger
	caste_name = "Ravenger"
	display_name = "Ravenger"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/xenomorph/ravager/ravenger
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_BASETYPE

	// *** Melee Attacks *** //
	melee_damage_lower = 70
	melee_damage_upper = 90

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 600

	hardcore = TRUE

	// *** Flags *** //
	caste_flags = CASTE_IS_INTELLIGENT|CASTE_HIDE_IN_STATUS

	// *** Defense *** //
	armor_deflection = 20

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

	// *** Ranged Attack *** //
	charge_type = 3 //Claw at end of charge

/datum/xeno_caste/ravager/ravenger/young
	upgrade = XENO_UPGRADE_THREE

/mob/living/carbon/xenomorph/ravager/ravenger
	caste_base_type = /mob/living/carbon/xenomorph/ravager/ravenger
	desc = "It's a goddamn dragon! Run! RUUUUN!"
	plasma_stored = 200
	upgrade = XENO_UPGRADE_THREE
	var/used_fire_breath = 0
	actions = list(
		/datum/action/xeno_action/activable/breathe_fire,
		)

/mob/living/carbon/xenomorph/ravager/ravenger/Initialize()
	. = ..()
	verbs -= /mob/living/carbon/xenomorph/verb/hive_status

/datum/action/xeno_action/activable/breathe_fire
	name = "Breathe Fire"
	action_icon_state = "breathe_fire"
	mechanics_text = "Not as dangerous to yourself as you would think."
	ability_name = "breathe fire"

/datum/action/xeno_action/activable/breathe_fire/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/ravenger/X = owner
	X.breathe_fire(A)

/datum/action/xeno_action/activable/breathe_fire/action_cooldown_check()
	var/mob/living/carbon/xenomorph/ravager/ravenger/X = owner
	if(world.time > X.used_fire_breath + 75) return TRUE

/mob/living/carbon/xenomorph/ravager/ravenger/proc/breathe_fire(atom/A)
	set waitfor = 0
	if(world.time <= used_fire_breath + 75)
		return
	var/list/turf/turfs = getline(src, A)
	var/distance = 0
	var/obj/structure/window/W
	var/turf/T
	playsound(src, 'sound/weapons/gun_flamethrower2.ogg', 50, 1)
	visible_message("<span class='xenowarning'>\The [src] sprays out a stream of flame from its mouth!</span>", \
	"<span class='xenowarning'>You unleash a spray of fire on your enemies!</span>")
	used_fire_breath = world.time
	for(T in turfs)
		if(T == loc)
			continue
		if(distance >= 5)
			break
		if(DirBlocked(T, dir))
			break
		else if(DirBlocked(T, turn(dir, 180)))
			break
		if(locate(/turf/closed/wall/resin, T) || locate(/obj/structure/mineral_door/resin, T))
			break
		W = locate() in T
		if(W)
			if(W.is_full_window())
				break
			if(W.dir == dir)
				break
		flame_turf(T)
		distance++
		sleep(1)

/mob/living/carbon/xenomorph/ravager/ravenger/proc/flame_turf(turf/T)
	if(!istype(T))
		return

	for(var/obj/flamer_fire/F in T) // No stacking flames!
		qdel(F)

	new/obj/flamer_fire(T)

	var/fire_mod
	for(var/mob/living/carbon/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)
			continue
		fire_mod = 1
		if(isxeno(M))
			var/mob/living/carbon/xenomorph/X = M
			if(X.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
				continue
			fire_mod = CLAMP(X.xeno_caste.fire_resist + X.fire_resist_modifier, 0, 1)
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || istype(H.wear_suit, /obj/item/clothing/suit/space/rig/atmos))
				continue

		M.adjustFireLoss(rand(20, 50) * fire_mod) //Fwoom!
		to_chat(M, "[isxeno(M) ? "<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!</Sspan>")
