#define PATROL_POINT_RAPPEL_EFFECT "patrol_point_rappel_effect"
#define RAPPEL_DURATION 0.6 SECONDS
#define RAPPEL_HEIGHT 128

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

	activate_point(user)

/obj/structure/patrol_point/mech_shift_click(obj/vehicle/sealed/mecha/mecha_clicker, mob/living/user)
	if(!Adjacent(user))
		return
	activate_point(user, mecha_clicker)

///Handles sending someone and/or something through the patrol_point
/obj/structure/patrol_point/proc/activate_point(mob/living/user, obj/obj_mover)
	if(!user && !obj_mover)
		return
	if(!linked_point)
		create_link()
		if(!linked_point)
			//Link your stuff bro. There may be a better way to do this, but the way modular map insert works, linking does not properly happen during initialisation
			if(user)
				to_chat(user, span_warning("This doesn't seem to go anywhere."))
			return

	if(obj_mover)
		obj_mover.forceMove(linked_point.loc)
	else if(user) //this is mainly configured under the assumption that we only have both an obj and a user if its a manned mech going through
		user.visible_message(span_notice("[user] goes through the [src]."),
		span_notice("You walk through the [src]."))
		user.trainteleport(linked_point.loc)
		add_spawn_protection(user)
	if(!obj_mover)
		new /atom/movable/effect/rappel_rope(linked_point.loc) //mechs don't need a rope

	var/atom/movable/mover = obj_mover ? obj_mover : user

	mover.add_filter(PATROL_POINT_RAPPEL_EFFECT, 2, drop_shadow_filter(y = -RAPPEL_HEIGHT, color = COLOR_TRANSPARENT_SHADOW, size = 4))
	var/shadow_filter = mover.get_filter(PATROL_POINT_RAPPEL_EFFECT)

	var/current_layer = mover.layer
	mover.pixel_y += RAPPEL_HEIGHT
	mover.layer = FLY_LAYER

	animate(mover, pixel_y = mover.pixel_y - RAPPEL_HEIGHT, time = RAPPEL_DURATION)
	animate(shadow_filter, y = 0, size = 0.9, time = RAPPEL_DURATION, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(src, PROC_REF(end_rappel), user, mover, current_layer), RAPPEL_DURATION)

	if(!user)
		return
	user.playsound_local(user, "sound/effects/CIC_order.ogg", 10, 1)
	var/message
	if(issensorcapturegamemode(SSticker.mode))
		switch(user.faction)
			if(FACTION_TERRAGOV)
				message = "Reactivate all sensor towers, good luck team."
			if(FACTION_SOM)
				message = "Prevent reactivation of the sensor towers, glory to Mars!"
	else if(iscombatpatrolgamemode(SSticker.mode))
		switch(user.faction)
			if(FACTION_TERRAGOV)
				message = "Eliminate all hostile forces in the ao, good luck team."
			if(FACTION_SOM)
				message = "Eliminate the TerraGov imperialists in the ao, glory to Mars!"
	else if(iscampaigngamemode(SSticker.mode))
		switch(user.faction)
			if(FACTION_TERRAGOV)
				message = "Stick together and achieve those objectives marines. Good luck."
			if(FACTION_SOM)
				message = "Remember your training marines, show those Terrans the strength of the SOM, glory to Mars!"

	if(!message)
		return

	switch(user.faction)
		if(FACTION_TERRAGOV)
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + message, /atom/movable/screen/text/screen_text/picture/potrait)
		if(FACTION_SOM)
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>OVERWATCH</u></span><br>" + message, /atom/movable/screen/text/screen_text/picture/potrait/som_over)
		else
			user.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>UNKNOWN</u></span><br>" + message, /atom/movable/screen/text/screen_text/picture/potrait/unknown)

/obj/structure/patrol_point/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(. || !linked_point)
		return

	user.forceMove(linked_point.loc)

///Temporarily applies godmode to prevent spawn camping
/obj/structure/patrol_point/proc/add_spawn_protection(mob/living/user)
	user.ImmobilizeNoChain(RAPPEL_DURATION) //looks weird if they can move while rappeling
	user.status_flags |= GODMODE
	addtimer(CALLBACK(src, PROC_REF(remove_spawn_protection), user), 10 SECONDS)

///Ends the rappel effects
/obj/structure/patrol_point/proc/end_rappel(mob/living/user, atom/movable/mover, original_layer)
	mover.remove_filter(PATROL_POINT_RAPPEL_EFFECT)
	mover.layer = original_layer
	SEND_SIGNAL(mover, COMSIG_MOVABLE_PATROL_DEPLOYED, TRUE, 1.5, 2)
	if(ismecha(mover))
		new /obj/effect/temp_visual/rappel_dust(linked_point.loc, 3)
		playsound(linked_point.loc, 'sound/effects/behemoth/behemoth_stomp.ogg', 40, TRUE)
	shake_camera(user, 0.2 SECONDS, 0.5)

///Removes spawn protection godmode
/obj/structure/patrol_point/proc/remove_spawn_protection(mob/user)
	user.status_flags &= ~GODMODE

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

/obj/structure/patrol_point/tgmc_22
	id = "TGMC_22"

/obj/structure/patrol_point/tgmc_23
	id = "TGMC_23"

/obj/structure/patrol_point/tgmc_24
	id = "TGMC_24"

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

/obj/structure/patrol_point/som_22
	id = "SOM_22"

/obj/structure/patrol_point/som_23
	id = "SOM_23"

/obj/structure/patrol_point/som_24
	id = "SOM_24"

/atom/movable/effect/rappel_rope
	name = "rope"
	icon = 'icons/Marine/mainship_props.dmi'
	icon_state = "rope"
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	resistance_flags = RESIST_ALL
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/effect/rappel_rope/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/effects/rappel.ogg', 50, TRUE, falloff = 2)
	playsound(loc, 'sound/effects/tadpolehovering.ogg', 100, TRUE, falloff = 2.5)
	balloon_alert_to_viewers("You see a dropship fly overhead and begin dropping ropes!")
	ropeanimation()

/atom/movable/effect/rappel_rope/proc/ropeanimation()
	flick("rope_deploy", src)
	addtimer(CALLBACK(src, PROC_REF(ropeanimation_stop)), 2 SECONDS)

/atom/movable/effect/rappel_rope/proc/ropeanimation_stop()
	flick("rope_up", src)
	QDEL_IN(src, 5)
