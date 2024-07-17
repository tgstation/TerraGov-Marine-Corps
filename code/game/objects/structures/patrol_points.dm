/obj/structure/patrol_point
	name = "Patrol start point"
	desc = "A one way ticket to the combat zone. Shift click to deploy when inside a mech."
	icon = 'icons/effects/campaign_effects.dmi'
	icon_state = "patrol_point_1"
	anchored = TRUE
	resistance_flags = RESIST_ALL
	layer = LADDER_LAYER
	///ID to link with associated exit point
	var/id = null
	///The linked exit point
	var/obj/effect/landmark/patrol_point/linked_point = null

/obj/structure/patrol_point/Initialize(mapload)
	..()

	return INITIALIZE_HINT_LATELOAD


/obj/structure/patrol_point/LateInitialize()
	create_link()

///Links the patrol point to its associated exit point
/obj/structure/patrol_point/proc/create_link()
	for(var/obj/effect/landmark/patrol_point/exit_point AS in GLOB.patrol_point_list)
		if(exit_point.id == id)
			linked_point = exit_point
			RegisterSignal(linked_point, COMSIG_QDELETING, PROC_REF(delete_link))
			return

///Removes the linked patrol exist point
/obj/structure/patrol_point/proc/delete_link()
	SIGNAL_HANDLER
	linked_point = null

/obj/structure/patrol_point/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.incapacitated() || !Adjacent(user) || user.lying_angle || user.buckled || user.anchored)
		return

	activate_point(user, user)

/obj/structure/patrol_point/mech_shift_click(obj/vehicle/sealed/mecha/mecha_clicker, mob/living/user)
	if(!Adjacent(user))
		return
	activate_point(user, mecha_clicker)

///Handles sending someone and/or something through the patrol_point
/obj/structure/patrol_point/proc/activate_point(mob/living/user, atom/movable/thing_to_move)
	if(!thing_to_move)
		return
	if(!linked_point)
		create_link()
		if(!linked_point)
			//Link your stuff bro. There may be a better way to do this, but the way modular map insert works, linking does not properly happen during initialisation
			if(user)
				to_chat(user, span_warning("This doesn't seem to go anywhere."))
			return

	thing_to_move.visible_message(span_notice("[thing_to_move] goes through the [src]."), user ? span_notice("You go through the [src].") : null)
	linked_point.do_deployment(thing_to_move, user)

/obj/structure/patrol_point/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(!linked_point)
		create_link()
		if(!linked_point)
			to_chat(user, span_warning("This doesn't seem to go anywhere."))
			return
	user.forceMove(linked_point.loc)

/obj/structure/patrol_point/tgmc_11
	id = "TGMC_11"

/obj/structure/patrol_point/tgmc_12
	id = "TGMC_12"

/obj/structure/patrol_point/tgmc_13
	id = "TGMC_13"

/obj/structure/patrol_point/tgmc_14
	id = "TGMC_14"

/obj/structure/patrol_point/tgmc_21
	id = "TGMC_21"
	icon_state = "patrol_point_2"

/obj/structure/patrol_point/tgmc_22
	id = "TGMC_22"
	icon_state = "patrol_point_2"

/obj/structure/patrol_point/tgmc_23
	id = "TGMC_23"
	icon_state = "patrol_point_2"

/obj/structure/patrol_point/tgmc_24
	id = "TGMC_24"
	icon_state = "patrol_point_2"

/obj/structure/patrol_point/som_11
	id = "SOM_11"

/obj/structure/patrol_point/som_12
	id = "SOM_12"

/obj/structure/patrol_point/som_13
	id = "SOM_13"

/obj/structure/patrol_point/som_14
	id = "SOM_14"

/obj/structure/patrol_point/som_21
	id = "SOM_21"
	icon_state = "patrol_point_2"

/obj/structure/patrol_point/som_22
	id = "SOM_22"
	icon_state = "patrol_point_2"

/obj/structure/patrol_point/som_23
	id = "SOM_23"
	icon_state = "patrol_point_2"

/obj/structure/patrol_point/som_24
	id = "SOM_24"
	icon_state = "patrol_point_2"
