#define PLANE_STATE_ACTIVATED	0
#define PLANE_STATE_DEACTIVATED	1
#define PLANE_STATE_PREPARED	2
#define PLANE_STATE_FLYING		3

#define LOW_FUEL_THRESHOLD		5
#define FUEL_PER_CAN_POUR		3

#define LOW_FUEL_LANDING_THRESHOLD 4

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
	///Ui size in x
	var/ui_x = 600
	///UI size in y
	var/ui_y = 500

/obj/structure/caspart/caschair/Initialize()
	. = ..()
	set_cockpit_overlay("cockpit_closed")

/obj/structure/caspart/caschair/Destroy()
	owner?.chair = null
	owner = null
	if(occupant)
		INVOKE_ASYNC(src, .proc/eject_user, TRUE)
	QDEL_NULL(cockpit)
	return ..()

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
		to_chat(user, "<span class='warning'>Access denied!</span>")
		return
	switch(owner.state)
		if(PLANE_STATE_DEACTIVATED)
			set_cockpit_overlay("cockpit_opening")//flick doesnt work here, thanks byond
			sleep(7)
			set_cockpit_overlay("cockpit_open")
			owner.state = PLANE_STATE_ACTIVATED
			return
		if(PLANE_STATE_PREPARED | PLANE_STATE_FLYING)
			to_chat("<span class='warning'>The plane is in-flight!</span>")
			return
		if(PLANE_STATE_ACTIVATED)
			if(occupant)
				to_chat(user, "<span class='warning'>Someone is already inside!</span>")
				return
			to_chat(user, "<span class='notice'>You start climbing into the cockpit...</span>")
			if(!do_after(user, 2 SECONDS, TRUE, src))
				return
			user.visible_message("<span class='notice'>[user] climbs into the plane cockpit!</span>", "<span class='notice'>You get in the seat!</span>")
			if(occupant)
				to_chat(user, "<span class='warning'>[occupant] got in before you!</span>")
				return
			user.forceMove(src)
			occupant = user
			interact(occupant)
			RegisterSignal(occupant, COMSIG_LIVING_DO_RESIST, /atom/movable.proc/resisted_against)
			set_cockpit_overlay("cockpit_closing")
			sleep(7)
			set_cockpit_overlay("cockpit_closed")

/obj/structure/caspart/caschair/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/reagent_containers/jerrycan))
		return ..()
	if(owner.state == PLANE_STATE_FLYING)
		to_chat(user, "<span class='warning'>You can't refuel mid-air!</span>")
		return
	var/obj/item/reagent_containers/jerrycan/gascan = I
	if(gascan.reagents.total_volume == 0)
		to_chat(user, "<span class='warning'>Out of fuel!</span>")
		return
	if(owner.fuel_left >= owner.fuel_max)
		to_chat(user, "<span class='notice'>The plane is already fully fuelled!</span>")
		return

	var/fuel_transfer_amount = min(gascan.fuel_usage*2, gascan.reagents.total_volume)
	gascan.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
	owner.fuel_left = min(owner.fuel_left + FUEL_PER_CAN_POUR, owner.fuel_max)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(user, "<span class='notice'>You refill the plane with fuel. New fuel level [owner.fuel_left/owner.fuel_max*100]%</span>")


/obj/structure/caspart/caschair/resisted_against(datum/source)
	if(owner.state)
		ui_interact(occupant)
		return
	INVOKE_ASYNC(src, .proc/eject_user)

///Eject the user, use forced = TRUE to do so instantly
/obj/structure/caspart/caschair/proc/eject_user(forced = FALSE)
	if(!forced)
		to_chat(occupant, "<span class='notice'>You start getting out of the cockpit.</span>")
		if(!do_after(occupant, 2 SECONDS, TRUE, src))
			return
		set_cockpit_overlay("cockpit_opening")
		sleep(7)
	set_cockpit_overlay("cockpit_open")
	UnregisterSignal(occupant, COMSIG_LIVING_DO_RESIST)
	occupant.unset_interaction()
	occupant.forceMove(loc)
	occupant = null


/obj/structure/caspart/caschair/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(!istype(port, /obj/docking_port/mobile/marine_dropship/casplane))
		return
	var/obj/docking_port/mobile/marine_dropship/casplane/plane = port
	owner = plane
	plane.chair = src

/obj/docking_port/stationary/marine_dropship/cas
	name = "CAS plane hangar pad"
	id = "casplane"
	roundstart_template = /datum/map_template/shuttle/cas

/obj/docking_port/mobile/marine_dropship/casplane
	id = "casplane"
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
	var/mob/camera/aiEye/remote/eyeobj
	///Action to stop the eye
	var/datum/action/innate/camera_off/cas/off_action
	///Number for how much fuel we have left, this x15 seconds is how much time we have while flying
	var/fuel_left = 40
	///How much fuel we can hold maximum
	var/fuel_max = 40
	///Our currently selected weapon we will fire
	var/obj/structure/dropship_equipment/weapon/active_weapon

/obj/docking_port/mobile/marine_dropship/casplane/Initialize()
	. = ..()
	off_action = new
	RegisterSignal(src, COMSIG_SHUTTLE_SETMODE, .proc/update_state)

/obj/docking_port/mobile/marine_dropship/casplane/Destroy(force)
	STOP_PROCESSING(SSslowprocess, src)
	end_cas_mission(chair?.occupant)
	return ..()

/obj/docking_port/mobile/marine_dropship/casplane/process()
	fuel_left--
	if((fuel_left <= LOW_FUEL_LANDING_THRESHOLD) && (state == PLANE_STATE_FLYING))
		to_chat(chair.occupant, "<span class='warning'>Out of fuel, landing.</span>")
		SSshuttle.moveShuttle(id, "casplane", TRUE)
		end_cas_mission(chair.occupant)
	if (fuel_left <= 0)
		fuel_left = 0
		turn_off_engines()


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
	if(!is_mainship_level(z))
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
		to_chat(user, "<span class='warning'>No fuel remaining!</span>")
		return
	if(state != PLANE_STATE_FLYING)
		to_chat(user, "<span class='warning'>You are not in-flight!</span>")
		return
	if(!eyeobj)
		eyeobj = new()
		eyeobj.origin = src
	if(eyeobj.eye_user)
		to_chat(user, "<span class='warning'>CAS mode is already in-use!</span>")
		return
	if(!length(GLOB.active_cas_targets))
		to_chat(user, "<span class='warning'>No active laser targets detected!</span>")
		return
	to_chat(user, "<span class='warning'>Laser targets detected, routing to target.</span>")
	var/input = input(user, "Select a CAS target", "CAS targetting") as null|anything in GLOB.active_cas_targets
	if(!input)
		return
	give_eye_control(user)
	eyeobj.setLoc(get_turf(input))

///Gives user control of the eye and allows them to start shooting
/obj/docking_port/mobile/marine_dropship/casplane/proc/give_eye_control(mob/user)
	off_action.target = user
	off_action.give_action(user)
	eyeobj.eye_user = user
	eyeobj.name = "CAS Camera Eye ([user.name])"
	user.remote_control = eyeobj
	user.reset_perspective(eyeobj)
	eyeobj.setLoc(eyeobj.loc)
	RegisterSignal(user, COMSIG_MOB_CLICKON, .proc/fire_weapons_at)
	user.client.mouse_pointer_icon = 'icons/effects/supplypod_down_target.dmi'

///Ends the CAS mission
/obj/docking_port/mobile/marine_dropship/casplane/proc/end_cas_mission(mob/living/user)
	if(!user)
		return
	if(eyeobj?.eye_user != user)
		return
	UnregisterSignal(user, COMSIG_MOB_CLICKON)
	user.client.mouse_pointer_icon = initial(user.client.mouse_pointer_icon)
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

///Handles clicking on a target while in CAS mode
/obj/docking_port/mobile/marine_dropship/casplane/proc/fire_weapons_at(datum/source, atom/target, turf/location, control, params)
	if(state != PLANE_STATE_FLYING)
		end_cas_mission(source)
		return
	if(!GLOB.cameranet.checkTurfVis(get_turf_pixel(target)))
		return
	if(!active_weapon)
		to_chat(source, "<span class='warning'>No active weapon selected!</span>")
		return
	var/area/A = get_area(target)
	if(A.ceiling >= CEILING_DEEP_UNDERGROUND)
		to_chat(source, "<span class='warning'>That target is too deep underground!</span>")
		return
	if(active_weapon.ammo_equipped?.ammo_count <= 0)
		to_chat(source, "<span class='warning'>No ammo remaining!</span>")
		return
	if(!COOLDOWN_CHECK(active_weapon, last_fired))
		to_chat(source, "<span class='warning'>[active_weapon] just fired, wait for it to cool down.</span>")
		return
	active_weapon.open_fire(target, attackdir)

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
	return owner.ui_data(user)

/obj/docking_port/mobile/marine_dropship/casplane/ui_data(mob/user)
	. = list()
	.["plane_state"] = state
	.["plane_mode"] = mode
	.["fuel_left"] = fuel_left
	.["fuel_max"] = fuel_max
	.["ship_status"] = getStatusText()
	.["attackdir"] = uppertext(dir2text(attackdir))
	var/element_nbr = 1
	.["all_weapons"] = list()
	for(var/i in equipments)
		var/obj/structure/dropship_equipment/weapon/weapon = i
		.["all_weapons"] += list(list("name"= sanitize(copytext(weapon.name,1,MAX_MESSAGE_LEN)), "ammo" = weapon?.ammo_equipped?.ammo_count, "eqp_tag" = element_nbr))
		if(weapon == active_weapon)
			.["active_weapon_tag"] = element_nbr
		element_nbr++
	.["active_lasers"] = length(GLOB.active_cas_targets)
	.["active_weapon_name"] = null
	.["active_weapon_ammo"] = null
	.["active_weapon_max_ammo"] = null
	.["active_weapon_ammo_name"] =  null
	if(active_weapon)
		.["active_weapon_name"] = sanitize(copytext(active_weapon?.name,1,MAX_MESSAGE_LEN))
		if(active_weapon.ammo_equipped)
			.["active_weapon_ammo"] = active_weapon.ammo_equipped.ammo_count
			.["active_weapon_max_ammo"] = active_weapon.ammo_equipped.max_ammo_count
			.["active_weapon_ammo_name"] =  active_weapon.ammo_equipped.name

/obj/docking_port/mobile/marine_dropship/casplane/getStatusText()
	switch(mode)
		if(SHUTTLE_IDLE||SHUTTLE_RECHARGING)
			switch(state)
				if(PLANE_STATE_FLYING)
					return "In-mission"
				if(PLANE_STATE_PREPARED)
					return "Engines online and ready for launch."
				if(PLANE_STATE_ACTIVATED)
					return "Engines Offline. Idle mode engaged."
		if(SHUTTLE_IGNITING)
			return "Accelerating to new destination."
		if(SHUTTLE_PREARRIVAL)
			return "Decelerating."
	return "Unknown status"

/obj/structure/caspart/caschair/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(!owner)
		return

	switch(action)
		if("launch")
			if(owner.fuel_left <= LOW_FUEL_THRESHOLD)
				to_chat(usr, "<span class='warning'>Unable to launch, low fuel.")
				return
			SSshuttle.moveShuttleToDock(owner.id, SSshuttle.generate_transit_dock(owner), TRUE)
		if("land")
			SSshuttle.moveShuttle(owner.id, "casplane", TRUE)
			owner.end_cas_mission(usr)
		if("deploy")
			owner.begin_cas_mission(usr)
		if("change_weapon")
			var/selection = text2num(params["selection"])
			owner.active_weapon = owner.equipments[selection]
		if("deselect")
			owner.active_weapon = null
			. = TRUE
		if("toggle_engines")
			if(owner.mode == SHUTTLE_IGNITING)
				return
			switch(owner.state)
				if(PLANE_STATE_ACTIVATED)
					owner.turn_on_engines()
				if(PLANE_STATE_PREPARED)
					owner.turn_off_engines()
		if("cycle_attackdir")
			owner.attackdir = turn(owner.attackdir, 90)
			. = TRUE



/obj/structure/caspart/caschair/on_unset_interaction(mob/M)
	if(M == occupant)
		owner.end_cas_mission(M)

/datum/action/innate/camera_off/cas
	name = "Exit CAS mode"

/datum/action/innate/camera_off/cas/Activate()
	if(!isliving(target))
		return
	var/mob/living/living = target
	var/mob/camera/aiEye/remote/remote_eye = living.remote_control
	var/obj/docking_port/mobile/marine_dropship/casplane/plane = remote_eye.origin
	plane.end_cas_mission(living)

#undef LOW_FUEL_THRESHOLD
#undef PLANE_STATE_ACTIVATED
#undef PLANE_STATE_DEACTIVATED
#undef PLANE_STATE_PREPARED
#undef PLANE_STATE_FLYING
#undef FUEL_PER_CAN_POUR
#undef LOW_FUEL_LANDING_THRESHOLD
