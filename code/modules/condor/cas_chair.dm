/obj/structure/caspart/caschair
	name = "\improper Condor Jet pilot seat"
	icon_state = "chair"
	layer = ABOVE_MOB_LAYER
	req_access = list(ACCESS_MARINE_PILOT)
	interaction_flags = INTERACT_MACHINE_TGUI|INTERACT_MACHINE_NOSILICON
	resistance_flags = RESIST_ALL
	///The docking port we are handling control for
	var/obj/docking_port/mobile/marine_dropship/casplane/owner
	///The pilot human
	var/mob/living/carbon/human/occupant
	///Animated cockpit /image overlay, 96x96
	var/image/cockpit
	/// Whether CAS is usable or not.
	var/cas_usable = CAS_USABLE

/obj/structure/caspart/caschair/Initialize(mapload)
	. = ..()
	set_cockpit_overlay("cockpit_closed")
	RegisterSignal(SSdcs, COMSIG_GLOB_CAS_LASER_CREATED, PROC_REF(receive_laser_cas))
	RegisterSignals(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED), PROC_REF(cas_usable))

/obj/structure/caspart/caschair/Destroy()
	owner?.chair = null
	owner = null
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAS_LASER_CREATED)
	if(occupant)
		INVOKE_ASYNC(src, PROC_REF(eject_user), TRUE)
	QDEL_NULL(cockpit)
	return ..()

/obj/structure/caspart/caschair/proc/receive_laser_cas(datum/source, obj/effect/overlay/temp/laser_target/cas/incoming_laser)
	SIGNAL_HANDLER
	playsound(src, 'sound/effects/binoctarget.ogg', 15)
	if(occupant)
		to_chat(occupant, span_notice("CAS laser detected, [incoming_laser.name] [CAS_JUMP_LINK(incoming_laser)]"))

/obj/structure/caspart/caschair/proc/cas_usable(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_OPEN_TIMED_SHUTTERS_LATE, COMSIG_GLOB_OPEN_TIMED_SHUTTERS_XENO_HIVEMIND, COMSIG_GLOB_OPEN_SHUTTERS_EARLY, COMSIG_GLOB_TADPOLE_LAUNCHED))
	cas_usable = TRUE
	if(occupant)
		to_chat(occupant, span_notice("Combat initiated, CAS now available."))

///Handles updating the cockpit overlay
/obj/structure/caspart/caschair/proc/set_cockpit_overlay(new_state)
	cut_overlays()
	cockpit = image('icons/Marine/cas_plane_cockpit.dmi', src, new_state)
	cockpit.pixel_x = -16
	cockpit.pixel_y = -32
	cockpit.layer = ABOVE_ALL_MOB_LAYER
	add_overlay(cockpit)
	var/image/side = image('icons/Marine/casship.dmi', src, "3")
	side.pixel_x = 32
	add_overlay(side)
	side = image('icons/Marine/casship.dmi', src, "6")
	side.pixel_x = -32
	add_overlay(side)

/obj/structure/caspart/caschair/attack_hand(mob/living/user)
	if(!allowed(user))
		to_chat(user, span_warning("Access denied!"))
		return

	switch(owner.state)
		if(PLANE_STATE_DEACTIVATED)
			set_cockpit_overlay("cockpit_opening")//flick doesnt work here, thanks byond
			sleep(0.7 SECONDS)
			set_cockpit_overlay("cockpit_open")
			owner.state = PLANE_STATE_ACTIVATED
			return

		if(PLANE_STATE_PREPARED, PLANE_STATE_FLYING)
			to_chat(user, span_warning("The plane is in-flight!"))
			return

		if(PLANE_STATE_ACTIVATED)
			if(occupant == user)
				resisted_against()
				return

			else if(occupant)
				to_chat(user, span_warning("Someone is already inside!"))
				return

			to_chat(user, span_notice("You start climbing into the cockpit..."))
			if(!do_after(user, 2 SECONDS, NONE, src))
				return

			user.visible_message(span_notice("[user] climbs into the plane cockpit!"), span_notice("You get in the seat!"))

			if(occupant)
				to_chat(user, span_warning("[occupant] got in before you!"))
				return

			user.forceMove(src)
			occupant = user
			interact(occupant)

			RegisterSignal(occupant, COMSIG_LIVING_DO_RESIST, TYPE_PROC_REF(/atom/movable, resisted_against))
			set_cockpit_overlay("cockpit_closing")
			addtimer(CALLBACK(src, PROC_REF(set_cockpit_overlay), "cockpit_closed"), 7)

/obj/structure/caspart/caschair/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/reagent_containers/jerrycan))
		return ..()
	if(owner.state == PLANE_STATE_FLYING)
		to_chat(user, span_warning("You can't refuel mid-air!"))
		return
	var/obj/item/reagent_containers/jerrycan/gascan = I
	if(gascan.reagents.total_volume == 0)
		to_chat(user, span_warning("Out of fuel!"))
		return
	if(owner.fuel_left >= owner.fuel_max)
		to_chat(user, span_notice("The plane is already fully fuelled!"))
		return

	var/fuel_transfer_amount = min(gascan.fuel_usage*2, gascan.reagents.total_volume)
	gascan.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
	owner.fuel_left = min(owner.fuel_left + CAS_FUEL_PER_CAN_POUR, owner.fuel_max)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(user, span_notice("You refill the plane with fuel. New fuel level [owner.fuel_left/owner.fuel_max*100]%"))


/obj/structure/caspart/caschair/resisted_against(datum/source)
	if(owner.state)
		ui_interact(occupant)
		return
	INVOKE_ASYNC(src, PROC_REF(eject_user))

///Eject the user, use forced = TRUE to do so instantly
/obj/structure/caspart/caschair/proc/eject_user(forced = FALSE)
	if(!forced)
		if(SSmapping.level_trait(z, ZTRAIT_RESERVED))
			to_chat(occupant, span_notice("Getting out of the cockpit while flying seems like a bad idea to you."))
			return
		to_chat(occupant, span_notice("You start getting out of the cockpit."))
		if(!do_after(occupant, 2 SECONDS, NONE, src))
			return
	set_cockpit_overlay("cockpit_opening")
	addtimer(CALLBACK(src, PROC_REF(set_cockpit_overlay), "cockpit_open"), 7)
	UnregisterSignal(occupant, COMSIG_LIVING_DO_RESIST)
	occupant.unset_interaction()
	occupant.forceMove(get_step(loc, WEST))
	occupant = null

/obj/structure/caspart/caschair/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(!occupant)
		to_chat(X, span_xenowarning("There is nothing of interest in there."))
		return
	if(X.status_flags & INCORPOREAL || X.do_actions)
		return
	visible_message(span_warning("[X] begins to pry the [src]'s cover!"), 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(!do_after(X, 2 SECONDS))
		return
	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	eject_user(TRUE)

/obj/structure/caspart/caschair/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(!istype(port, /obj/docking_port/mobile/marine_dropship/casplane))
		return
	var/obj/docking_port/mobile/marine_dropship/casplane/plane = port
	owner = plane
	plane.chair = src

/obj/structure/caspart/caschair/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "MarineCasship", name)
		ui.open()

/obj/structure/caspart/caschair/ui_data(mob/user)
	if(!owner)
		WARNING("[src] with no owner")
		return
	return owner.ui_data(user)

/obj/structure/caspart/caschair/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!owner)
		return
	if(action == "toggle_engines")
		if(owner.mode == SHUTTLE_IGNITING)
			return
		switch(owner.state)
			if(PLANE_STATE_ACTIVATED)
				owner.turn_on_engines()
			if(PLANE_STATE_PREPARED)
				owner.turn_off_engines()
	if(action == "eject")
		if(owner.state != PLANE_STATE_ACTIVATED)
			return
		resisted_against()
		ui.close()

	if(owner.state == PLANE_STATE_ACTIVATED)
		return

	switch(action)
		if("launch")
			if(!cas_usable)
				to_chat(usr, "<span class='warning'>Combat has not yet initiated, CAS unavailable.")
				return
			if(owner.state == PLANE_STATE_FLYING || owner.mode != SHUTTLE_IDLE)
				return
			if(owner.fuel_left <= LOW_FUEL_THRESHOLD)
				to_chat(usr, "<span class='warning'>Unable to launch, low fuel.")
				return
			SSshuttle.moveShuttleToDock(owner.id, SSshuttle.generate_transit_dock(owner), TRUE)
			owner.currently_returning = FALSE
		if("land")
			if(owner.state != PLANE_STATE_FLYING)
				return
			SSshuttle.moveShuttle(owner.id, SHUTTLE_CAS_DOCK, TRUE)
			owner.end_cas_mission(usr)
			owner.currently_returning = TRUE
		if("deploy")
			if(owner.state != PLANE_STATE_FLYING)
				return
			owner.begin_cas_mission(usr)
		if("change_weapon")
			var/selection = text2num(params["selection"])
			owner.active_weapon = owner.equipments[selection]
		if("cycle_attackdir")
			if(params["newdir"] == null)
				owner.attackdir = turn(owner.attackdir, 90)
				return TRUE
			owner.attackdir = params["newdir"]
			return TRUE

/obj/structure/caspart/caschair/on_unset_interaction(mob/M)
	if(M == occupant)
		owner.end_cas_mission(M)
