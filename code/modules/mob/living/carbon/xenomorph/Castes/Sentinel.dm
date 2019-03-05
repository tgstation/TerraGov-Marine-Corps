/datum/xeno_caste/sentinel
	caste_name = "Sentinel"
	display_name = "Sentinel"
	upgrade_name = "Young"
	caste_desc = "A weak ranged combat alien."
	caste_type_path = /mob/living/carbon/Xenomorph/Sentinel
	tier = 1
	upgrade = 0

	// *** Melee Attacks *** //
	melee_damage_lower = 15
	melee_damage_upper = 25

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
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_VENT_CRAWL|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER

	// *** Defense *** //
	armor_deflection = 15

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
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
	speed = -0.95

	// *** Plasma *** //
	plasma_max = 450
	plasma_gain = 15

	// *** Health *** //
	max_health = 180

	// *** Evolution *** //
	upgrade_threshold = 200

	// *** Defense *** //
	armor_deflection = 20

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade1)

/datum/xeno_caste/sentinel/elder
	upgrade_name = "Elder"
	caste_desc = "A ranged combat alien. It looks pretty strong."

	upgrade = 2

	// *** Melee Attacks *** //
	melee_damage_lower = 23
	melee_damage_upper = 33

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -1.05

	// *** Plasma *** //
	plasma_max = 550
	plasma_gain = 18

	// *** Health *** //
	max_health = 190

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 23

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
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
	armor_deflection = 25

	// *** Ranged Attack *** //
	spit_delay = 1.3 SECONDS
	spit_types = list(/datum/ammo/xeno/toxin/upgrade3)

/mob/living/carbon/Xenomorph/Sentinel
	caste_base_type = /mob/living/carbon/Xenomorph/Sentinel
	name = "Sentinel"
	desc = "A slithery, spitting kind of alien."
	icon = 'icons/Xeno/48x48_Xenos.dmi'
	icon_state = "Sentinel Walking"
	health = 150
	maxHealth = 150
	plasma_stored = 75
	pixel_x = -12
	old_x = -12
	tier = 1
	upgrade = 0
	speed = -0.8
	pull_speed = -2
	wound_type = "alien" //used to match appropriate wound overlays
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

	if(!H || !isliving(H))
		return

	if(!check_state())
		return

	if(world.time < last_neurotoxin_sting + SENTINEL_STING_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='xenowarning'>You are not ready to use the sting again. It will be ready in [(last_neurotoxin_sting + SENTINEL_STING_COOLDOWN - world.time) * 0.1] seconds.</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to sting but are too disoriented!</span>")
		return

	if(!H.can_sting() )
		to_chat(src, "<span class='xenowarning'>Your sting won't affect this target!</span>")
		return

	if(!Adjacent(H))
		if(world.time > (recent_notice + notice_delay)) //anti-notice spam
			to_chat(src, "<span class='xenowarning'>You can't reach this target!</span>")
			recent_notice = world.time //anti-notice spam
		return

	if ((H.status_flags & XENO_HOST) && istype(H.buckled, /obj/structure/bed/nest))
		to_chat(src, "<span class='xenowarning'>Ashamed, you reconsider bullying the poor, nested host with your stinger.</span>")
		return

	if(!check_plasma(150))
		return
	last_neurotoxin_sting = world.time
	use_plasma(150)

	round_statistics.sentinel_neurotoxin_stings++

	face_atom(H)
	animation_attack_on(H)
	H.reagents.add_reagent("xeno_toxin", SENTINEL_STING_AMOUNT_INITIAL) //15 units transferred initially.
	to_chat(H, "<span class='danger'>You feel a tiny prick.</span>")
	to_chat(src, "<span class='xenowarning'>Your stinger injects your victim with neurotoxin!</span>")
	playsound(H, 'sound/effects/spray3.ogg', 15, 1)
	playsound(H, pick('sound/voice/alien_drool1.ogg', 'sound/voice/alien_drool2.ogg'), 15, 1)
	overdose_check(H)

	addtimer(CALLBACK(src, .sentinel_sting_cooldown), SENTINEL_STING_COOLDOWN)

	recurring_injection(H)

/mob/living/carbon/Xenomorph/Sentinel/proc/sentinel_sting_cooldown()
	playsound(loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	to_chat(src, "<span class='xenodanger'>You feel your neurotoxin glands refill. You can use your Neurotoxin Sting again.</span>")
	update_action_button_icons()
