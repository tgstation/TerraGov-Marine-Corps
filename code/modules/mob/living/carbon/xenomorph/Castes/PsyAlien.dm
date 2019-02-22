/datum/xeno_caste/psyalien
	caste_name = "PsyAlien"
	display_name = "PsyAlien"
	upgrade_name = "Young"
	caste_type_path = /mob/living/carbon/Xenomorph/PsyAlien
	caste_desc = "The biggest alien with psy power."

	tier = 3
	upgrade = 0

	deevolves_to = /mob/living/carbon/Xenomorph/Drone

	// *** Melee Attacks *** //
	melee_damage_lower = 12
	melee_damage_upper = 16

	// *** Tackle *** //
	tackle_damage = 20

	// *** Speed *** //
	speed = 0.2

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 40

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_CAN_BE_GIVEN_PLASMA

	can_hold_eggs = CAN_HOLD_TWO_HANDS

	// *** Defense *** //
	armor_deflection = 30

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/psyattack)

	// *** Pheromones *** //
	aura_strength = 2.5
	aura_allowed = list("frenzy", "warding", "recovery")

/datum/xeno_caste/psyalien/mature
	upgrade_name = "Mature"
	caste_desc = "The biggest alien with psy power/"

	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 20

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = 0.1

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 45

	// *** Health *** //
	max_health = 225

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 35

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/psyattack/upgrade2)

	// *** Pheromones *** //
	aura_strength = 3


/datum/xeno_caste/psyalien/elder
	upgrade_name = "Elder"
	caste_desc = "The biggest and baddest xeno."

	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 25

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 50

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 40

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/psyattack/upgrade3)

	// *** Pheromones *** //
	aura_strength = 3.5


/datum/xeno_caste/psyalien/ancient
	upgrade_name = "Ancient"
	caste_desc = "The most perfect Xeno form imaginable."
	ancient_message = "You are the Alpha and the Omega.Row! Row! Fight to power."
	upgrade = 3

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 55

	// *** Health *** //
	max_health = 275

	// *** Evolution *** //
	upgrade_threshold = 1600

	// *** Defense *** //
	armor_deflection = 45

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/psyattack/upgrade3)

	// *** Pheromones *** //
	aura_strength = 4



/mob/living/carbon/Xenomorph/PsyAlien
	caste_base_type = /mob/living/carbon/Xenomorph/PsyAlien
	name = "PsyAlien"
	desc = "Big brains."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "PsyAlien Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 300
	speed = 0.1
	tier = 3
	upgrade = 0
	drag_delay = 6 //pulling a big dead xeno is hard
	xeno_explosion_resistance = 2
	mob_size = MOB_SIZE_BIG
	wound_type = "psyalien" //used to match appropriate wound overlays

	pixel_x = -16
	old_x = -16

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/screech_psy,
		/datum/action/xeno_action/toggle_range,
		/datum/action/xeno_action/emit_pheromones,
		/datum/action/xeno_action/activable/xeno_psypower,
	)

/mob/living/carbon/Xenomorph/PsyAlien/update_icons()
	if(stat == DEAD)
		icon_state = "PsyAlien Dead"
	else if(lying)
		if((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "PsyAlien Sleeping"
		else
			icon_state = "PsyAlien Knocked Down"
	else
		if(m_intent == MOVE_INTENT_RUN)
			icon_state = "PsyAlien Running"
		else
			icon_state = "PsyAlien Walking"

	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds()

/mob/living/carbon/Xenomorph/PsyAlien/proc/screech()
	if(!check_state())
		return

	if(has_screeched)
		to_chat(src, "<span class='warning'>You are not ready to screech again.</span>")
		return

	if(!check_plasma(100))
		return

	//screech is so powerful it kills huggers in our hands
	if(istype(r_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = r_hand
		if(FH.stat != DEAD)
			FH.Die()

	if(istype(l_hand, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/FH = l_hand
		if(FH.stat != DEAD)
			FH.Die()

	has_screeched = 1
	use_plasma(100)
	spawn(500)
		has_screeched = 0
		to_chat(src, "<span class='warning'>You feel your throat muscles vibrate. You are ready to screech again.</span>")
		for(var/Z in actions)
			var/datum/action/A = Z
			A.update_button_icon()
	//playsound(loc, 'sound/voice/alien_queen_screech.ogg', 75, 0)
	visible_message("<span class='xenohighdanger'>\The [src] emits a deafening psi-attack!</span>")
	round_statistics.queen_screech++
	create_shriekwave()
	//stop_momentum(charge_dir)

	for(var/mob/M in view())
		if(M && M.client)
			if(isXeno(M))
				shake_camera(M, 10, 1)
			else
				shake_camera(M, 30, 1) //50 deciseconds, SORRY 5 seconds was way too long. 3 seconds now

	for(var/mob/living/carbon/human/H in oview(7, src))
		var/dist = get_dist(src,H)
		var/reduction = max(1 - 0.1 * H.protection_aura, 0)
		var/halloss_damage = (max(0,140 - dist * 10)) * reduction
		var/stun_duration = max(0,1.1 - dist * 0.1) * reduction

		if(dist < 10)
			to_chat(H, "<span class='danger'>An ear-splitting guttural roar tears through your mind and makes your world convulse!</span>")
			H.stunned += stun_duration
			H.KnockDown(stun_duration)
			H.apply_damage(halloss_damage, HALLOSS)
			if(!H.ear_deaf)
				H.ear_deaf += stun_duration * 20  //Deafens them temporarily
			spawn(31)
				shake_camera(H, stun_duration * 10, 0.75) //Perception distorting effects of the psychic scream

/proc/update_living_psyaliens()
	outer_loop:
		for(var/datum/hive_status/hive in hive_datum)
			if(hive.living_xeno_psyalien)
				if(hive.living_xeno_psyalien.hivenumber == hive.hivenumber)
					continue
			for(var/mob/living/carbon/Xenomorph/PsyAlien/P in living_mob_list)
				if(P.hivenumber == hive.hivenumber)
					hive.living_xeno_psyalien = P
					continue outer_loop
			hive.living_xeno_psyalien = null