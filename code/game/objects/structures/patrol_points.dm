/obj/structure/patrol_point
	name = "Patrol start point"
	desc = "A one way ticket to the combat zone."
	icon = 'icons/effects/effects.dmi'
	icon_state = "patrolpoint"
	anchored = TRUE
	resistance_flags = RESIST_ALL
	layer = LADDER_LAYER
	///ID to link with associated exit point
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
			RegisterSignal(linked_point, COMSIG_PARENT_QDELETING, .proc/delete_link)
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
	if(!linked_point)
		create_link()
		if(!linked_point)
			//Link your stuff bro. There may be a better way to do this, but the way modular map insert works, linking does not properly happen during initialisation
			to_chat(user, span_warning("This doesn't seem to go anywhere."))
			return
	user.visible_message(span_notice("[user] goes through the [src]."),
	span_notice("You walk through the [src]."))
	user.trainteleport(linked_point.loc)
	new /atom/movable/effect/rappel_rope(linked_point.loc)
	user.playsound_local(user, "sound/effects/CIC_order.ogg", 10, 1)
	var/message
	if(issensorcapturegamemode(SSticker.mode))
		if(user.faction == FACTION_TERRAGOV)
			message = "CURRENT OBJECTIVE: REACTIVATE ALL SENSOR TOWERS."
		else
			message = "CURRENT OBJECTIVE: PREVENT REACTIVATION OF ALL SENSOR TOWERS."
	else
		message = "CURRENT OBJECTIVE: ELIMINATE HOSTILE FORCES IN THE AO."

	user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>OVERWATCH</u></span><br>" + message, /obj/screen/text/screen_text/command_order)
	update_icon()

/obj/structure/patrol_point/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(. || !linked_point)
		return

	user.forceMove(get_turf(linked_point))

/atom/movable/effect/rappel_rope
	name = "rope"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "rope"
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/effect/rappel_rope/Initialize()
	. = ..()
	playsound(loc, 'sound/effects/rappel.ogg', 50, TRUE, falloff = 2)
	playsound(loc, 'sound/effects/tadpolehovering.ogg', 100, TRUE, falloff = 2.5)
	balloon_alert_to_viewers("You see a dropship fly overhead and begin dropping ropes!")
	ropeanimation()

/atom/movable/effect/rappel_rope/proc/ropeanimation()
	flick("rope_deploy", src)
	addtimer(CALLBACK(src, .proc/ropeanimation_stop), 2 SECONDS)

/atom/movable/effect/rappel_rope/proc/ropeanimation_stop()
	flick("rope_up", src)
	QDEL_IN(src, 5)
