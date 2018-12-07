/datum/xeno_caste/sentinel
	caste_name = "Sentinel"
	display_name = "Sentinel"
	upgrade_name = "Young"
	caste_desc = "A weak ranged combat alien."
	caste_type_path = /mob/living/carbon/Xenomorph/Sentinel
	tier = 1
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 10
	melee_damage_upper = 20

	// *** Tackle *** //
	tackle_damage = 25

	// *** Speed *** //
	speed = -0.8

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 10

	// *** Health *** //
	max_health = 150

	// *** Evolution *** //
	evolution_threshold = 100
	upgrade_threshold = 100

	evolves_to = list(/mob/living/carbon/Xenomorph/Spitter)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA

	// *** Defense *** //
	armor_deflection = 15

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin)

/datum/xeno_caste/sentinel/mature
	upgrade_name = "Mature"
	caste_desc = "A ranged combat alien. It looks a little more dangerous."

	upgrade = 1

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = -0.9

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 12

	// *** Health *** //
	max_health = 180

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	armor_deflection = 15

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade1)

/datum/xeno_caste/sentinel/elder
	upgrade_name = "Elder"
	caste_desc = "A ranged combat alien. It looks pretty strong."

	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.0

	// *** Plasma *** //
	plasma_max = 500
	plasma_gain = 15

	// *** Health *** //
	max_health = 190

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 20

	// *** Ranged Attack *** //
	spit_delay = 1 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade2)

/datum/xeno_caste/sentinel/ancient
	upgrade_name = "Ancient"
	caste_desc = "Neurotoxin Factory, don't let it get you."
	ancient_message = "You are the stun master. Your stunning is legendary and causes massive quantities of salt."
	upgrade = 3

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -1.1

	// *** Plasma *** //
	plasma_max = 600
	plasma_gain = 20

	// *** Health *** //
	max_health = 195

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 20

	// *** Ranged Attack *** //
	spit_delay = 1.5 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade3)

/mob/living/carbon/Xenomorph/Sentinel
	caste_base_type = /mob/living/carbon/Xenomorph/Sentinel
	name = "Sentinel"
	desc = "A slithery, spitting kind of alien."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Sentinel Walking"
	health = 150
	maxHealth = 150
	plasma_stored = 75
	pixel_x = 0
	old_x = 0
	tier = 1
	upgrade = 0
	speed = -0.8
	pull_speed = -2
	var/last_neurotoxin_sting = null
	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/corrosive_acid/drone,
		/datum/action/xeno_action/activable/xeno_spit,
		/datum/action/xeno_action/activable/neurotox_sting,
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)


/mob/living/carbon/Xenomorph/Sentinel/proc/neurotoxin_sting(var/mob/living/H)

	if(!check_state()) return

	if(world.time < last_neurotoxin_sting + NEUROTOXIN_STING_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='xenowarning'>You are not ready to use the sting again. It will be ready in [(last_neurotoxin_sting + NEUROTOXIN_STING_COOLDOWN - world.time) SECONDS] seconds.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to sting but are too disoriented!</span>")
		return

	if(!istype(H) || isXeno(H) || isrobot(H))
		to_chat(src, "<span class='xenowarning'>Your sting won't affect this target!</span>")
		return

	if(!Adjacent(H))
		to_chat(src, "<span class='xenowarning'>You're too far away to sting this target!</span>")
		return

	if ((H.status_flags & XENO_HOST) && istype(H.buckled, /obj/structure/bed/nest))
		to_chat(src, "<span class='xenowarning'>You reconsider bullying the poor, nested host with your stinger.</span>")
		return

	if(!check_plasma(150))
		return
	last_neurotoxin_sting = world.time
	use_plasma(150)

	round_statistics.sentinel_neurotoxin_stings++

	face_atom(H)
	animation_attack_on(H)
	H.reagents.add_reagent("xeno_toxin", NEUROTOXIN_STING_AMOUNT_INITIAL) //15 units transferred initially.
	to_chat(H, "<span class='danger'>You feel a tiny prick.</span>")
	to_chat(src, "<span class='xenowarning'>Your stinger injects your victim with neurotoxin!</span>")
	playsound(H, 'sound/effects/spray3.ogg', 15, 1)
	playsound(H, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	if(do_after(src, NEUROTOXIN_STING_INJECT_DELAY, TRUE, 5, BUSY_ICON_HOSTILE)) //First follow up injection
		if(!neurotoxin_recurring_injection(H))
			return
		to_chat(src, "<span class='xenowarning'>Your stinger continues to inject neurotoxin!</span>")
		if(do_after(src, NEUROTOXIN_STING_INJECT_DELAY, TRUE, 5, BUSY_ICON_HOSTILE)) //Second follow up injection
			if(!neurotoxin_recurring_injection(H))
				return
			to_chat(src, "<span class='xenowarning'>Your stinger retracts as it finishes discharging the neurotoxin.</span>")


	spawn(NEUROTOXIN_STING_COOLDOWN)
		playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
		to_chat(src, "<span class='xenodanger'>You feel your neurotoxin glands refill. You can use your neurotoxin sting again.</span>")
		update_action_button_icons()


/mob/living/carbon/Xenomorph/Sentinel/proc/neurotoxin_recurring_injection(var/mob/living/H)
	if(!Adjacent(H))
		return FALSE
	face_atom(H)
	animation_attack_on(H)
	playsound(H, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	H.reagents.add_reagent("xeno_toxin", NEUROTOXIN_STING_AMOUNT_RECURRING) //10 units transferred.
	return TRUE
