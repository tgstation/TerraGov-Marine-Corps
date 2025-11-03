/datum/fire_support/rockets
	name = "Rocket barrage"
	fire_support_type = FIRESUPPORT_TYPE_ROCKETS
	scatter_range = 9
	impact_quantity = 15
	uses = 3
	icon_state = "rockets"
	initiate_chat_message = "TARGET ACQUIRED ROCKET RUN INBOUND."
	initiate_screen_message = "Rockets hot, incoming!"

/datum/fire_support/rockets/do_impact(turf/target_turf)
	explosion(target_turf, 0, 2, 4, 6, 2, explosion_cause=name)

/datum/fire_support/rockets/unlimited
	fire_support_type = FIRESUPPORT_TYPE_ROCKETS_UNLIMITED
	uses = -1

/datum/fire_support/incendiary_rockets
	name = "Incendiary rocket barrage"
	fire_support_type = FIRESUPPORT_TYPE_INCEND_ROCKETS
	scatter_range = 9
	impact_quantity = 9
	icon_state = "incendiary_rockets"
	initiate_chat_message = "TARGET ACQUIRED ROCKET RUN INBOUND."
	initiate_screen_message = "Rockets hot, incoming!"
	initiate_title = "Avenger-4"
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_pilot
	start_visual = /obj/effect/temp_visual/dropship_flyby/som
	uses = 2

/datum/fire_support/incendiary_rockets/do_impact(turf/target_turf)
	explosion(target_turf, weak_impact_range = 4, flame_range = 4, throw_range = 2, explosion_cause=name)
