/datum/fire_support/cruise_missile
	name = "Cruise missile strike"
	fire_support_type = FIRESUPPORT_TYPE_CRUISE_MISSILE
	scatter_range = 1
	uses = 1
	icon_state = "cruise"
	initiate_chat_message = "TARGET ACQUIRED CRUISE MISSILE INBOUND."
	initiate_screen_message = "Cruise missile programmed, one out."
	initiate_sound = 'sound/weapons/rocket_incoming.ogg'
	start_visual = null
	start_sound = null

/datum/fire_support/cruise_missile/select_target(turf/target_turf)
	explosion(target_turf, 4, 5, 6, explosion_cause="cruise missile")

/datum/fire_support/cruise_missile/unlimited
	fire_support_type = FIRESUPPORT_TYPE_CRUISE_MISSILE_UNLIMITED
	uses = -1

/datum/fire_support/rad_missile
	name = "Radioactive missile"
	fire_support_type = FIRESUPPORT_TYPE_RAD_MISSILE
	scatter_range = 4
	impact_quantity = 1
	icon_state = "rad_missile"
	initiate_chat_message = "TARGET ACQUIRED RAD MISSILE INBOUND."
	initiate_screen_message = "Target locked, rads inbound!"
	initiate_title = "Avenger-4"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_pilot
	start_visual = /obj/effect/temp_visual/dropship_flyby/som
	uses = 2
	///Base strength of the rad effects
	var/rad_strength = 25
	///Range for the maximum rad effects
	var/inner_range = 3
	///Range for the moderate rad effects
	var/mid_range = 6
	///Range for the minimal rad effects
	var/outer_range = 9

/datum/fire_support/rad_missile/do_impact(turf/target_turf)
	playsound(target_turf, 'sound/effects/portal_opening.ogg', 100, FALSE)
	for(var/mob/living/victim in hearers(outer_range, target_turf))
		var/strength
		var/sound_level
		if(get_dist(victim, target_turf) <= inner_range)
			strength = rad_strength
			sound_level = 4
		else if(get_dist(victim, target_turf) <= mid_range)
			strength = rad_strength * 0.7
			sound_level = 3
		else
			strength = rad_strength * 0.3
			sound_level = 2

		strength = victim.modify_by_armor(strength, BIO, 25)
		victim.apply_radiation(strength, sound_level)

	explosion(target_turf, 0, 1, 0, 4, explosion_cause=name)
