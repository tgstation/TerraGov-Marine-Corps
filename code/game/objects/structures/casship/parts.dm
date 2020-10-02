///Base cas plabe structure, we use this instead of turfs because we want to peek onto the turfs below
/obj/structure/caspart
	name = "\improper Condor Jet"
	icon = 'icons/Marine/casship.dmi'
	icon_state = "1"
	layer = ABOVE_MOB_LAYER

/obj/structure/cas
	name = "Condor piloting computer"
	desc = "Does not support Pinball."
	icon = 'icons/Marine/casship.dmi'
	icon_state = "cockpit"

/obj/structure/caspart/internalengine
	var/image/engine_overlay

/obj/structure/caspart/internalengine/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(!istype(port, /obj/docking_port/mobile/casplane))
		return
	var/obj/docking_port/mobile/casplane/planeport = port
	planeport.engines += src
	return ..()

/obj/structure/caspart/internalengine/right
	icon_state = "50"

/obj/structure/caspart/internalengine/left
	icon_state = "54"

#define PLANE_STATE_ACTIVATED	1
#define PLANE_STATE_DEACTIVATED	2
#define PLANE_STATE_PREPARED	3
#define PLANE_STATE_FLYING		4

/obj/structure/caspart/caschair
	name = "\improper Condor Jet pilot seat"
	icon_state = "chair"
	layer = ABOVE_MOB_LAYER
	req_access = list(ACCESS_MARINE_PILOT)
	interaction_flags = INTERACT_MACHINE_TGUI|INTERACT_MACHINE_NOSILICON
	var/ship_tag = "casplane"
	var/obj/docking_port/mobile/casplane/owner
	var/mob/living/carbon/human/occupant
	var/image/cockpit
	var/ui_x = 200
	var/ui_y = 200

/obj/structure/caspart/caschair/Initialize()
	. = ..()
	cockpit = image('icons/Marine/cas_plane_cockpit.dmi', src, "cockpit_closed")
	add_overlay(cockpit)

/obj/structure/caspart/caschair/Destroy()
	owner?.chair = null
	owner = null
	if(occupant)
		eject_user(TRUE)
	QDEL_NULL(cockpit)
	return ..()


/obj/structure/caspart/caschair/attack_hand(mob/living/user)
	if(!allowed(user))
		to_chat(user, "access denied")
		return
	switch(owner.state)
		if(PLANE_STATE_DEACTIVATED)
			cut_overlays()
			cockpit = image('icons/Marine/cas_plane_cockpit.dmi', src, "cockpit_open")
			add_overlay(cockpit)
			flick("cockpit_opening", cockpit)
			owner.state = PLANE_STATE_ACTIVATED
			return
		if(PLANE_STATE_PREPARED | PLANE_STATE_FLYING)
			to_chat("ur flying stoopid")
			return
		if(PLANE_STATE_ACTIVATED)
			if(occupant)
				to_chat(user, "someones inside")
				return
			to_chat(user, "u start climbing in")
			if(!do_after(user, 2 SECONDS, TRUE, src))
				return
			user.visible_message("he gets in", "u get in")
			if(occupant)
				to_chat(user, "someone faster")
				return
			user.forceMove(src)
			occupant = user

/obj/structure/caspart/caschair/resisted_against(datum/source)
	if(owner.state == PLANE_STATE_PREPARED|| owner.state == PLANE_STATE_FLYING)
		to_chat(source, "is flying")
		return
	eject_user(FALSE)

/obj/structure/caspart/caschair/proc/eject_user(forced = FALSE)
	if(!forced)
		to_chat(occupant, "you start getting out")
		if(!do_after(occupant, 2 SECONDS, TRUE, src))
			return
	occupant.forceMove(loc)
	occupant = null


/obj/structure/caspart/caschair/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(!istype(port, /obj/docking_port/mobile/casplane))
		return
	var/obj/docking_port/mobile/casplane/plane = port
	owner = port
	plane.chair = src

/obj/docking_port/mobile/casplane
	id = "casplane"
	dir = SOUTH
	dwidth = 5
	dheight = 6
	width = 11
	height = 12

	ignitionTime = 10 SECONDS
	callTime = 38 SECONDS
	rechargeTime = 2 MINUTES
	prearrivalTime = 12 SECONDS

	///What state our plane is in, i.e can we launch/do we have to deploy stairs etc
	var/state = PLANE_STATE_DEACTIVATED
	///List of engine tiles so we can track them for overlays
	var/list/engines = list()
	///Chair that handles all the ui and click stuff
	var/obj/structure/caspart/caschair/chair
	///Camera eye we create when we begin a CAS mission that we fire from
	var/mob/camera/aiEye/remote/eyeobj
	///Action to stop the eye
	var/datum/action/innate/camera_off/off_action
	///Number for how much fuel we have left, this x15 seconds is how much time we have while flying
	var/fuel_left = 10

/obj/docking_port/mobile/casplane/Initialize()
	. = ..()
	off_action = new

/obj/docking_port/mobile/casplane/Destroy(force)
	STOP_PROCESSING(SSslowprocess, src)
	end_cas_mission(chair?.occupant)
	return ..()

/obj/docking_port/mobile/casplane/process()
	fuel_left--
	if(fuel_left <= 0)
		SSshuttle.moveShuttle(id, "casdock", TRUE)
		return PROCESS_KILL


/obj/docking_port/mobile/casplane/on_ignition()
	playsound(return_center_turf(), 'sound/effects/engine_startup.ogg', 60, 0)
	for(var/i in engines)
		var/obj/structure/caspart/internalengine/engine = i
		engine.cut_overlays()
		var/image/engine_overlay = image('icons/Marine/cas_plane_cockpit.dmi', src, "engine_on")
		engine.add_overlay(engine_overlay)
	START_PROCESSING(SSslowprocess, src)

/obj/docking_port/mobile/casplane/on_prearrival()
	playsound(return_center_turf(), 'sound/effects/engine_landing.ogg', 60, 0)
	if(destination)
		playsound(destination.return_center_turf(), 'sound/effects/engine_landing.ogg', 60, 0)
	for(var/i in engines)
		var/obj/structure/caspart/internalengine/engine = i
		engine.cut_overlays()
		var/image/engine_overlay = image('icons/Marine/cas_plane_cockpit.dmi', src, "engine_idle")
		engine.add_overlay(engine_overlay)
	STOP_PROCESSING(SSslowprocess, src)

/obj/docking_port/mobile/casplane/proc/turn_on_engines()
	for(var/i in engines)
		var/obj/structure/caspart/internalengine/engine = i
		var/image/engine_overlay = image('icons/Marine/cas_plane_cockpit.dmi', src, "engine_idle")
		engine.add_overlay(engine_overlay)
		state = PLANE_STATE_PREPARED

/obj/docking_port/mobile/casplane/proc/turn_off_engines()
	for(var/i in engines)
		var/obj/structure/caspart/internalengine/engine = i
		engine.cut_overlays()
		state = PLANE_STATE_ACTIVATED

/obj/docking_port/mobile/casplane/proc/begin_cas_mission(mob/living/user)
	if(!fuel_left)
		to_chat(user, "no fiel")
		return
	if(mode != SHUTTLE_IDLE)
		to_chat(user, "not flying")
		return
	if(eyeobj)
		to_chat(user, "in use")
		return
	if(!eyeobj)
		eyeobj = new()
		eyeobj.origin = src
	if(!eyeobj.eye_initialized)
		eyeobj.eye_initialized = TRUE
		give_eye_control(user)
		eyeobj.setLoc(locate(round(world.maxx / 2), round(world.maxy / 2), 2))
	else
		give_eye_control(user)
		eyeobj.setLoc(eyeobj.loc)


/obj/docking_port/mobile/casplane/proc/give_eye_control(mob/user)
	off_action.target = user
	off_action.give_action(user)
	eyeobj.eye_user = user
	eyeobj.name = "CAS Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	eyeobj.setLoc(eyeobj.loc)
	RegisterSignal(user, COMSIG_CLICK, .proc/fire_weapons_at)

/obj/docking_port/mobile/casplane/proc/end_cas_mission(mob/living/user)
	if(!user)
		return
	UnregisterSignal(user, COMSIG_CLICK)
	off_action.remove_action(user)
	for(var/V in eyeobj.visibleCameraChunks)
		var/datum/camerachunk/C = V
		C.remove(eyeobj)
	if(user.client)
		user.reset_perspective(null)
		if(eyeobj.visible_icon && user.client)
			user.client.images -= eyeobj.user_image
	eyeobj.eye_user = null
	user.remote_control = null

	user.unset_interaction()

/obj/docking_port/mobile/casplane/proc/fire_weapons_at(location, control, params, mob/user)
	explosion(location, 12,21,212,21)

/obj/structure/caspart/caschair/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "MarineCasship", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/structure/caspart/caschair/ui_data(mob/user)
	if(!owner)
		WARNING("[src] with no owner")
		return

	. = list()
	.["on_flyby"] = owner.mode == SHUTTLE_CALL
	.["dest_select"] = !(owner.mode == SHUTTLE_CALL || owner.mode == SHUTTLE_IDLE)
	.["fuel_left"] = owner.fuel_left
	.["ship_status"] = owner.getStatusText()

/obj/structure/caspart/caschair/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!owner)
		return

	switch(action)
		if("launch")
			owner.enterTransit()
		if("land")
			SSshuttle.moveShuttle(owner.id, "casdock", TRUE)
		if("deploy")
			owner.begin_cas_mission(usr)
		if("toggle_engines")
			switch(owner.state)
				if(PLANE_STATE_ACTIVATED)
					owner.turn_on_engines()
				if(PLANE_STATE_PREPARED)
					owner.turn_off_engines()


/obj/structure/caspart/caschair/on_unset_interaction(mob/M)
	if(M == occupant)
		owner.end_cas_mission(M)
