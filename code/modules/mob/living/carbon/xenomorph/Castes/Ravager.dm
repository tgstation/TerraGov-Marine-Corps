/datum/xeno_caste/ravager
	caste_name = "Ravager"
	display_name = "Ravager"
	upgrade_name = "Young"
	caste_desc = "A brutal, devastating front-line attacker."
	caste_type_path = /mob/living/carbon/Xenomorph/Ravager
	tier = 3
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 40
	melee_damage_upper = 60
	attack_delay = -2 

	// *** Tackle *** //
	tackle_damage = 55

	// *** Speed *** //
	speed = -0.4

	// *** Plasma *** //
	plasma_max = 150
	plasma_gain = 10

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 400

	deevolves_to = /mob/living/carbon/Xenomorph/Hunter

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA
	
	// *** Defense *** //
	armor_deflection = 20

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

	// *** Ranged Attack *** //
	charge_type = 3 //Claw at end of charge

/datum/xeno_caste/ravager/mature
	upgrade_name = "Mature"
	caste_desc = "A brutal, devastating front-line attacker. It looks a little more dangerous."

	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 50
	melee_damage_upper = 70
	attack_delay = -2 

	// *** Tackle *** //
	tackle_damage = 60

	// *** Speed *** //
	speed = -0.45

	// *** Plasma *** //
	plasma_max = 175
	plasma_gain = 13

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 25

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

/datum/xeno_caste/ravager/elder
	upgrade_name = "Elder"
	caste_desc = "A brutal, devastating front-line attacker. It looks pretty strong."

	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 55
	melee_damage_upper = 75
	attack_delay = -2 

	// *** Tackle *** //
	tackle_damage = 65

	// *** Speed *** //
	speed = -0.48

	// *** Plasma *** //
	plasma_max = 190
	plasma_gain = 14

	// *** Health *** //
	max_health = 260

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 28

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

/datum/xeno_caste/ravager/ancient
	upgrade_name = "Ancient"
	caste_desc = "As I walk through the valley of the shadow of death."
	ancient_message = "You are death incarnate. All will tremble before you."
	upgrade = 3

	// *** Melee Attacks *** //
	melee_damage_lower = 60
	melee_damage_upper = 80
	attack_delay = -2 

	// *** Tackle *** //
	tackle_damage = 70

	// *** Speed *** //
	speed = -0.5

	// *** Plasma *** //
	plasma_max = 200
	plasma_gain = 15

	// *** Health *** //
	max_health = 265

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 30

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

/mob/living/carbon/Xenomorph/Ravager
	caste_base_type = /mob/living/carbon/Xenomorph/Ravager
	name = "Ravager"
	desc = "A huge, nasty red alien with enormous scythed claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Ravager Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	xeno_explosion_resistance = 1 //can't be gibbed from explosions
	tier = 3
	upgrade = 0
	pixel_x = -16
	old_x = -16
	//Ravager vars
	var/rage = 0
	var/rage_resist = 1.00
	var/ravage_used = FALSE
	var/ravage_delay = null
	var/charge_delay = null
	var/second_wind_used = FALSE
	var/second_wind_delay = null
	var/last_rage = null
	var/last_damage = null
	var/usedcharge = FALSE

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/charge,
		/datum/action/xeno_action/activable/ravage,
		/datum/action/xeno_action/second_wind,
		)

/mob/living/carbon/Xenomorph/Ravager/Stat()
	. = ..()
	if(!.)
		return

	stat(null, "Rage: [rage] / [RAVAGER_MAX_RAGE]")

/mob/living/carbon/Xenomorph/Ravager/proc/charge(atom/T)
	if(!T) return

	if(!check_state())
		return

	if(usedPounce)
		to_chat(src, "<span class='xenowarning'>You must gather your strength before using Eviscerating Charge. It can be used in: [(charge_delay - world.time) * 0.1] seconds.</span>")
		return

	if(!check_plasma(80))
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't charge with that thing on your leg!</span>")
		return

	visible_message("<span class='danger'>[src] charges towards \the [T]!</span>", \
	"<span class='danger'>You charge towards \the [T]!</span>" )
	emote("roar") //heheh
	usedPounce = 1 //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	use_plasma(80)

	throw_at(T, RAV_CHARGEDISTANCE, RAV_CHARGESPEED, src)

	charge_delay = world.time + RAV_CHARGECOOLDOWN

	spawn(RAV_CHARGECOOLDOWN)
		usedPounce = FALSE
		to_chat(src, "<span class='xenodanger'>Your exoskeleton quivers as you get ready to use Eviscerating Charge again.</span>")
		playsound(src, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
		update_action_button_icons()


//Chance of insta limb amputation after a melee attack.
/mob/living/carbon/Xenomorph/Ravager/proc/delimb(var/mob/living/carbon/human/H, var/datum/limb/O)
	if (prob(isYautja(H)?10:20)) // lets halve this for preds
		O = H.get_limb(check_zone(zone_selected))
		if (O.body_part != UPPER_TORSO && O.body_part != LOWER_TORSO && O.body_part != HEAD) //Only limbs.
			visible_message("<span class='danger'>The limb is sliced clean off!</span>","<span class='danger'>You slice off a limb!</span>")
			O.droplimb()
			return 1

	return 0

//Super hacky firebreathing Halloween rav.
/datum/xeno_caste/ravager/ravenger
	caste_name = "Ravenger"
	display_name = "Ravenger"
	upgrade_name = ""
	caste_type_path = /mob/living/carbon/Xenomorph/Ravager/ravenger
	tier = 3
	upgrade = 3

	// *** Melee Attacks *** //
	melee_damage_lower = 70
	melee_damage_upper = 90
	attack_delay = -2 

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
	caste_flags = CASTE_IS_INTELLIGENT

	// *** Defense *** //
	armor_deflection = 20

	fire_resist = 0.5 //0 to 1; lower is better as it is a multiplier.

	// *** Ranged Attack *** //
	charge_type = 3 //Claw at end of charge

/mob/living/carbon/Xenomorph/Ravager/ravenger
	caste_base_type = /mob/living/carbon/Xenomorph/Ravager/ravenger
	desc = "It's a goddamn dragon! Run! RUUUUN!"
	plasma_stored = 200
	upgrade = 3
	var/used_fire_breath = 0
	actions = list(
		/datum/action/xeno_action/activable/breathe_fire,
		)

/mob/living/carbon/Xenomorph/Ravager/ravenger/New()
	..()
	verbs -= /mob/living/carbon/Xenomorph/verb/hive_status

/mob/living/carbon/Xenomorph/Ravager/ravenger/proc/breathe_fire(atom/A)
	set waitfor = 0
	if(world.time <= used_fire_breath + 75)
		return
	var/list/turf/turfs = getline2(src, A)
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

/mob/living/carbon/Xenomorph/Ravager/ravenger/proc/flame_turf(turf/T)
	if(!istype(T))
		return

	for(var/obj/flamer_fire/F in T) // No stacking flames!
		cdel(F)

	new/obj/flamer_fire(T)

	var/fire_mod
	for(var/mob/living/carbon/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)
			continue
		fire_mod = 1
		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
				continue
			fire_mod = X.xeno_caste.fire_resist + X.fire_resist_modifier
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || istype(H.wear_suit, /obj/item/clothing/suit/space/rig/atmos))
				continue

		M.adjustFireLoss(rand(20, 50) * fire_mod) //Fwoom!
		to_chat(M, "[isXeno(M) ? "<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!</Sspan>")
