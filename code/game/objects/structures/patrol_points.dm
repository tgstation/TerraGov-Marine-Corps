/obj/structure/patrol_point
	name = "Patrol start point"
	desc = "A one way ticket to the combat zone."
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "ladder11"
	anchored = TRUE
	resistance_flags = RESIST_ALL
	layer = LADDER_LAYER
	//ID to link with associated exit point
	var/id = null
	///The linked exit point
	var/obj/effect/landmark/patrol_point/linked_point = null

/obj/structure/patrol_point/Initialize()
	..()

	return INITIALIZE_HINT_LATELOAD


/obj/structure/patrol_point/LateInitialize()
	create_link()

///Links the patrol point to its associated exit point
/obj/structure/patrol_point/proc/create_link()
	for(var/obj/effect/landmark/patrol_point/exit_point AS in GLOB.patrol_point_list)
		if(exit_point.id == id)
			linked_point = exit_point
			return

/obj/structure/patrol_point/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.incapacitated() || !Adjacent(user) || user.lying_angle || user.buckled || user.anchored)
		return
	if(!linked_point)
		create_link()
		if(!linked_point)
			//Link your stuff bro. There may be a better way to do this, but the way modular map insert works, linking does not properly happen during initialisation
			to_chat(user, span_warning("This doesn't seem to go anywhere."))
			return
	user.visible_message(span_notice("[user] goes through the [src]."),
	span_notice("You walk through the [src]."))
	user.trainteleport(linked_point.loc)

/obj/structure/patrol_point/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(. || !linked_point)
		return

	user.forceMove(get_turf(linked_point))
