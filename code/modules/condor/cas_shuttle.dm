/obj/docking_port/stationary/marine_dropship/cas
	name = "CAS plane hangar pad"
	id = SHUTTLE_CAS_DOCK
	roundstart_template = /datum/map_template/shuttle/cas

/obj/docking_port/mobile/marine_dropship/casplane
	name = "Condor Jet"
	id = SHUTTLE_CAS_DOCK
	width = 11
	height = 12

	callTime = 0
	ignitionTime = 10 SECONDS
	rechargeTime = 0
	prearrivalTime = 10 SECONDS

	///What state our plane is in, i.e can we launch/do we have to deploy stairs etc
	var/state = PLANE_STATE_DEACTIVATED
	///Direction we will use for attacks while in combat mode
	var/attackdir = NORTH
	///List of engine tiles so we can track them for overlays
	var/list/engines = list()
	///Chair that handles all the ui and click stuff
	var/obj/structure/caspart/caschair/chair
	///Camera eye we create when we begin a CAS mission that we fire from
	var/mob/camera/aiEye/remote/hud/eyeobj
	///Action to stop the eye
	var/datum/action/innate/camera_off/cas/off_action
	///Number for how much fuel we have left, this x15 seconds is how much time we have while flying
	var/fuel_left = 40
	///How much fuel we can hold maximum
	var/fuel_max = 40
	///Our currently selected weapon we will fire
	var/obj/structure/dropship_equipment/cas/weapon/active_weapon
	///Minimap for the pilot to know where the marines have ran off to
	var/datum/action/minimap/marine/external/cas_mini

	///If the shuttle is currently returning to the hangar.
	var/currently_returning = FALSE
	/// Jump to Lase action for active firemissions
	var/datum/action/innate/jump_to_lase/jump_action

/obj/docking_port/mobile/marine_dropship/casplane/Initialize(mapload)
	. = ..()
	off_action = new
	cas_mini = new
	jump_action = new(null, src)
	RegisterSignal(src, COMSIG_SHUTTLE_SETMODE, PROC_REF(update_state))

/obj/docking_port/mobile/marine_dropship/casplane/Destroy(force)
	STOP_PROCESSING(SSslowprocess, src)
	end_cas_mission(chair?.occupant)
	QDEL_NULL(off_action)
	QDEL_NULL(cas_mini)
	return ..()

/obj/docking_port/mobile/marine_dropship/casplane/process()
	#ifndef TESTING
	fuel_left--
	if((fuel_left <= LOW_FUEL_LANDING_THRESHOLD) && (state == PLANE_STATE_FLYING))
		to_chat(chair.occupant, span_warning("Out of fuel, landing."))
		SSshuttle.moveShuttle(id, SHUTTLE_CAS_DOCK, TRUE)
		currently_returning = TRUE
		end_cas_mission(chair.occupant)
	if (fuel_left <= 0)
		fuel_left = 0
		turn_off_engines()
	#endif


/obj/docking_port/mobile/marine_dropship/casplane/on_ignition()
	. = ..()
	for(var/i in engines)
		var/obj/structure/caspart/internalengine/engine = i
		engine.cut_overlays()
		var/image/engine_overlay = image('icons/Marine/cas_plane_engines.dmi', engine.loc, "engine_on", 4.2)
		engine_overlay.pixel_x = engine.x_offset
		engine_overlay.layer += 0.1
		engine.add_overlay(engine_overlay)

/obj/docking_port/mobile/marine_dropship/casplane/on_prearrival()
	. = ..()
	if(fuel_left <= LOW_FUEL_LANDING_THRESHOLD)
		turn_off_engines()
		return
	for(var/i in engines)
		var/obj/structure/caspart/internalengine/engine = i
		engine.cut_overlays()
		var/image/engine_overlay = image('icons/Marine/cas_plane_engines.dmi', engine.loc, "engine_idle", 4.2)
		engine_overlay.pixel_x = engine.x_offset
		engine_overlay.layer += 0.1
		engine.add_overlay(engine_overlay)

///Updates state and overlay to make te engines on
/obj/docking_port/mobile/marine_dropship/casplane/proc/turn_on_engines()
	for(var/i in engines)
		var/obj/structure/caspart/internalengine/engine = i
		var/image/engine_overlay = image('icons/Marine/cas_plane_engines.dmi', engine.loc, "engine_idle", 4.2)
		engine_overlay.pixel_x = engine.x_offset
		engine_overlay.layer += 0.1
		engine.add_overlay(engine_overlay)
	state = PLANE_STATE_PREPARED
	START_PROCESSING(SSslowprocess, src)

///Updates state and overlay to make te engines off
/obj/docking_port/mobile/marine_dropship/casplane/proc/turn_off_engines()
	for(var/i in engines)
		var/obj/structure/caspart/internalengine/engine = i
		engine.cut_overlays()
	state = PLANE_STATE_ACTIVATED
	STOP_PROCESSING(SSslowprocess, src)

///Called to check if a equipment was changed and to unset the active equipment if it got removed
/obj/docking_port/mobile/marine_dropship/casplane/proc/on_equipment_change(datum/source)
	if(!locate(active_weapon) in equipments)
		active_weapon = null

///Updates our state. We use a different var from mode so we can distinguish when engines are turned on/ we are in-flight
/obj/docking_port/mobile/marine_dropship/casplane/proc/update_state(datum/source, mode)
	if(state == PLANE_STATE_DEACTIVATED)
		return
	if(!is_mainship_level(z) || mode != SHUTTLE_IDLE)
		state = PLANE_STATE_FLYING
	else
		for(var/i in engines)
			var/obj/structure/caspart/internalengine/engine = i
			if(length(engine.overlays))
				state = PLANE_STATE_PREPARED
			else
				state = PLANE_STATE_ACTIVATED

///Runs checks and creates a new eye/hands over control to the eye
/obj/docking_port/mobile/marine_dropship/casplane/proc/begin_cas_mission(mob/living/user)
	if(!fuel_left)
		to_chat(user, span_warning("No fuel remaining!"))
		return
	if(state != PLANE_STATE_FLYING || is_mainship_level(z))
		to_chat(user, span_warning("You are not in-flight!"))
		return
	if(currently_returning)
		to_chat(user, span_warning("You are currently on your return flight!"))
		return
	if(!eyeobj)
		eyeobj = new()
		eyeobj.origin = src
		cas_mini.override_locator(eyeobj)

	if(eyeobj.eye_user)
		to_chat(user, span_warning("CAS mode is already in-use!"))
		return

	SSmonitor.process_human_positions()

	#ifndef TESTING
	if(SSmonitor.human_on_ground <= 5)
		to_chat(user, span_warning("The signal from the area of operations is too weak, you cannot route towards the battlefield."))
		return
	#endif

	// AT THIS POINT, A FIREMISSION IS READY TO START!

	var/starting_point
	if(length(GLOB.active_cas_targets))
		starting_point = tgui_input_list(user, "Select a CAS target", "CAS Targeting", GLOB.active_cas_targets)

	else //if we don't have any targets use the minimap to select a starting position
		var/atom/movable/screen/minimap/map = SSminimaps.fetch_minimap_object(2, MINIMAP_FLAG_MARINE)
		user.client.screen += map
		var/list/polled_coords = map.get_coords_from_click(user)
		user.client.screen -= map
		starting_point = locate(polled_coords[1], polled_coords[2], 2)

	if(GLOB.minidropship_start_loc && !starting_point) //and if this somehow fails (it shouldn't) we just go to the default point
		starting_point = GLOB.minidropship_start_loc

	if(!starting_point)
		return

	if(state != PLANE_STATE_FLYING || is_mainship_level(z)) //Secondary safety due to input being able to delay time.
		to_chat(user, span_warning("You are not in-flight!"))
		return
	if(currently_returning)
		to_chat(user, span_warning("You are currently on your return flight!"))
		return
	if(eyeobj.eye_user)
		to_chat(user, span_warning("CAS mode is already in-use!"))
		return

	SSmonitor.process_human_positions()
	#ifndef TESTING
	if(SSmonitor.human_on_ground <= 5)
		to_chat(user, span_warning("The signal from the area of operations is too weak, you cannot route towards the battlefield."))
		return
	#endif

	to_chat(user, span_warning("Targets detected, routing to area of operations."))
	give_eye_control(user)
	eyeobj.setLoc(get_turf(starting_point))

///Gives user control of the eye and allows them to start shooting
/obj/docking_port/mobile/marine_dropship/casplane/proc/give_eye_control(mob/user)
	off_action.target = user
	off_action.give_action(user)
	cas_mini.target = user
	cas_mini.give_action(user)
	jump_action.target = user
	jump_action.give_action(user)

	eyeobj.eye_user = user
	eyeobj.name = "CAS Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	eyeobj.setLoc(eyeobj.loc)

	RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(fire_weapons_at))
	RegisterSignal(user, COMSIG_TOPIC, PROC_REF(handle_topic))

	user.client.mouse_pointer_icon = 'icons/effects/supplypod_down_target.dmi'

///Ends the CAS mission
/obj/docking_port/mobile/marine_dropship/casplane/proc/end_cas_mission(mob/living/user)
	if(!user)
		return
	if(eyeobj?.eye_user != user)
		return

	UnregisterSignal(user, COMSIG_MOB_CLICKON)
	UnregisterSignal(user, COMSIG_TOPIC)

	user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)

	off_action.remove_action(user)
	cas_mini.remove_action(user)
	jump_action.remove_action(user)


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

///Handles clicking on a target while in CAS mode
/obj/docking_port/mobile/marine_dropship/casplane/proc/fire_weapons_at(datum/source, atom/target, turf/location, control, params)
	if(state != PLANE_STATE_FLYING || is_mainship_level(z))
		end_cas_mission(source)
		return
	if(!GLOB.cameranet.checkTurfVis(get_turf_pixel(target)))
		return
	if(!active_weapon)
		to_chat(source, span_warning("No active weapon selected!"))
		return
	var/area/A = get_area(target)
	if(A.ceiling >= CEILING_UNDERGROUND)
		to_chat(source, span_warning("That target is too deep underground!"))
		return
	if(A.flags_area & OB_CAS_IMMUNE)
		to_chat(source, span_warning("Our payload won't reach this target!"))
		return
	if(active_weapon.ammo_equipped?.ammo_count <= 0)
		to_chat(source, span_warning("No ammo remaining!"))
		return
	if(!COOLDOWN_CHECK(active_weapon, last_fired))
		to_chat(source, span_warning("[active_weapon] just fired, wait for it to cool down."))
		return
	active_weapon.open_fire(target, attackdir)
	record_cas_activity(active_weapon)

/obj/docking_port/mobile/marine_dropship/casplane/ui_data(mob/user)
	. = list()
	.["plane_state"] = state
	.["location_state"] = !is_mainship_level(z)
	.["plane_mode"] = mode
	.["fuel_left"] = fuel_left
	.["fuel_max"] = fuel_max
	.["attackdir"] = uppertext(dir2text(attackdir))
	.["active_lasers"] = length(GLOB.active_cas_targets)

	var/element_nbr = 1
	.["all_weapons"] = list()
	for(var/obj/structure/dropship_equipment/cas/weapon/weapon in equipments)
		.["all_weapons"] += list(list(
			"name"= sanitize(copytext(weapon.name,1,MAX_MESSAGE_LEN)),
			"ammo" = weapon.ammo_equipped?.ammo_count,
			"max_ammo" = weapon.ammo_equipped?.max_ammo_count,
			"ammo_name" = weapon.ammo_equipped?.name,
			"eqp_tag" = element_nbr,
		))
		if(weapon == active_weapon)
			.["active_weapon_tag"] = element_nbr
		element_nbr++

/// Used to intercept JUMP links.
/obj/docking_port/mobile/marine_dropship/casplane/proc/handle_topic(datum/source, mob/user, list/href_list)
	SIGNAL_HANDLER

	if(href_list["cas_jump"])
		if(user != eyeobj?.eye_user)
			return

		if(!(state == PLANE_STATE_FLYING) || !eyeobj)
			return

		var/obj/effect/overlay/temp/laser_target/cas/lase = locate(href_list["cas_jump"]) in GLOB.active_cas_targets
		if(!istype(lase))
			to_chat(user, span_warning("That marker has expired."))
			return

		eyeobj.setLoc(get_turf(lase))
		return
