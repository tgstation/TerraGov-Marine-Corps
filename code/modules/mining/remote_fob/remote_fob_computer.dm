
/////////////////////////////// the camera computer

/obj/machinery/computer/camera_advanced/remote_fob
	name = "FOB Construction Drone Control"
	desc = "A computer console equipped with camera screen and controls for a planetside deployed construction drone. Materials or equipment vouchers can be added simply by inserting them into the computer."
	icon = 'icons/Marine/remotefob.dmi'
	icon_state = "fobpc"
	interaction_flags = INTERACT_MACHINE_DEFAULT
	req_one_access = list(ACCESS_MARINE_REMOTEBUILD, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING)
	resistance_flags = RESIST_ALL
	networks = FALSE
	off_action = new/datum/action/innate/camera_off/remote_fob
	jump_action = null
	var/drone_creation_allowed = TRUE
	var/obj/docking_port/stationary/marine_dropship/spawn_spot
	var/datum/action/innate/remote_fob/metal_cade/metal_cade
	var/metal_remaining = 200
	var/datum/action/innate/remote_fob/plast_cade/plast_cade
	var/plasteel_remaining = 100
	var/datum/action/innate/remote_fob/toggle_wiring/toggle_wiring //whether or not new barricades will be wired
	var/do_wiring = FALSE
	var/datum/action/innate/remote_fob/sentry/sentry
	var/sentry_remaining = 0
	var/datum/action/innate/remote_fob/eject_metal_action/eject_metal_action
	var/datum/action/innate/remote_fob/eject_plasteel_action/eject_plasteel_action

/obj/machinery/computer/camera_advanced/remote_fob/Initialize()
	. = ..()
	metal_cade = new()
	plast_cade = new()
	toggle_wiring = new()
	sentry = new()
	eject_metal_action = new()
	eject_plasteel_action = new()

	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_TRANSIT, .proc/disable_drone_creation)

/obj/machinery/computer/camera_advanced/remote_fob/proc/disable_drone_creation()
	SIGNAL_HANDLER
	drone_creation_allowed = FALSE
	eject_mat(EJECT_METAL)
	eject_mat(EJECT_PLASTEEL)
	UnregisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_TRANSIT)


/obj/machinery/computer/camera_advanced/remote_fob/Destroy()
	spawn_spot = null
	QDEL_NULL(metal_cade)
	QDEL_NULL(plast_cade)
	QDEL_NULL(toggle_wiring)
	QDEL_NULL(sentry)
	QDEL_NULL(eject_metal_action)
	QDEL_NULL(eject_plasteel_action)

	return ..()


/obj/machinery/computer/camera_advanced/remote_fob/examine(mob/user)
	. = ..()
	var/list/details = list()
	details +="It has [metal_remaining] sheets of metal remaining.</br>"
	details +="It has [plasteel_remaining] sheets of plasteel remaining.</br>"
	details +="It has [sentry_remaining] sentries ready for placement.</br>"
	. += details.Join(" ")

/obj/machinery/computer/camera_advanced/remote_fob/give_eye_control(mob/user)
	. = ..()
	icon_state = "fobpc-transfer"
	user.lighting_alpha = 120
	eyeobj.name = "Remote Construction Drone"
	eyeobj.register_facedir_signals(user)
	if(eyeobj.eye_initialized)
		eyeobj.setLoc(get_turf(spawn_spot))

///Eject all of the selected mat from the fob drone console
/obj/machinery/computer/camera_advanced/remote_fob/proc/eject_mat(mattype)
	flick("fobpc-eject", src)
	var/turf/consolespot = get_turf(loc)
	switch(mattype)
		if(EJECT_METAL)
			var/obj/item/stack/sheet/metal/stack = /obj/item/stack/sheet/metal
			while(metal_remaining>0)
				stack = new /obj/item/stack/sheet/metal(consolespot)
				stack.amount = min(metal_remaining, 50)
				metal_remaining -= stack.amount
			return
		if(EJECT_PLASTEEL)
			var/obj/item/stack/sheet/plasteel/stack = /obj/item/stack/sheet/plasteel
			while(plasteel_remaining>0)
				stack = new /obj/item/stack/sheet/plasteel(consolespot)
				stack.amount = min(plasteel_remaining, 50)
				plasteel_remaining -= stack.amount

/obj/machinery/computer/camera_advanced/remote_fob/interact(mob/living/user)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(!allowed(user))
		to_chat(user, span_warning("Access Denied!"))
		return
	if(!drone_creation_allowed)
		to_chat(user, span_notice("Communication with the drone impossible due to fuel-residue in deployment zone atmosphere."))
		return
	spawn_spot = FALSE
	switch(tgui_alert(user, "Summon Drone in:", "FOB Construction Drone Control", list("LZ1","LZ2", "Cancel")))
		if("LZ1")
			spawn_spot = locate(/obj/docking_port/stationary/marine_dropship/lz1) in SSshuttle.stationary
			if(!spawn_spot)
				to_chat(user, span_warning("No valid location for drone deployment found."))
				return
		if("LZ2")
			spawn_spot = locate(/obj/docking_port/stationary/marine_dropship/lz2) in SSshuttle.stationary
			if(!spawn_spot)
				to_chat(user, span_warning("No valid location for drone deployment found."))
				return
		else
			return
	return ..()

/obj/machinery/computer/camera_advanced/remote_fob/CreateEye()
	if(!spawn_spot)
		CRASH("CreateEye() called without a spawn_spot designated")
	eyeobj = new /mob/camera/aiEye/remote/fobdrone(get_turf(spawn_spot))
	eyeobj.origin = src

/obj/machinery/computer/camera_advanced/remote_fob/attackby(obj/item/attackingitem, mob/user, params)
	if(istype(attackingitem, /obj/item/stack))
		var/obj/item/stack/attacking_stack = attackingitem
		if(istype(attacking_stack, /obj/item/stack/sheet/metal))
			var/useamount = attacking_stack.amount
			metal_remaining += useamount
			attacking_stack.use(useamount)
			to_chat(user, "<span class='notice'>Inserted [useamount] metal sheets.")
			flick("fobpc-insert", src)
			return
		if(istype(attacking_stack, /obj/item/stack/sheet/plasteel))
			var/useamount = attacking_stack.amount
			plasteel_remaining += useamount
			attacking_stack.use(useamount)
			to_chat(user, "<span class='notice'>Inserted [useamount] plasteel sheets.")
			flick("fobpc-insert", src)
			return
	return ..()

/obj/machinery/computer/camera_advanced/remote_fob/give_actions(mob/living/user)
	if(off_action)
		off_action.target = user
		off_action.give_action(user)
		actions += off_action

	if(metal_cade)
		metal_cade.target = src
		metal_cade.give_action(user)
		actions += metal_cade

	if(plast_cade)
		plast_cade.target = src
		plast_cade.give_action(user)
		actions += plast_cade

	if(toggle_wiring)
		toggle_wiring.target = src
		toggle_wiring.give_action(user)
		actions += toggle_wiring

	if(sentry)
		sentry.target = src
		sentry.give_action(user)
		actions += sentry

	if(eject_metal_action)
		eject_metal_action.target = src
		eject_metal_action.give_action(user)
		actions += eject_metal_action

	if(eject_plasteel_action)
		eject_plasteel_action.target = src
		eject_plasteel_action.give_action(user)
		actions += eject_plasteel_action

	RegisterSignal(user, COMSIG_MOB_CLICKON, .proc/on_controller_click)

	eyeobj.invisibility = 0

/obj/machinery/computer/camera_advanced/remote_fob/remove_eye_control(mob/living/user)
	icon_state = "fobpc"
	eyeobj.invisibility = INVISIBILITY_ABSTRACT
	eyeobj.eye_initialized = FALSE
	eyeobj.unregister_facedir_signals(user)
	UnregisterSignal(user, COMSIG_MOB_CLICKON)
	return ..()

/obj/machinery/computer/camera_advanced/remote_fob/check_eye(mob/living/user)
	if(!drone_creation_allowed)
		to_chat(user, span_notice("Communication with the drone has been disrupted."))
		user.unset_interaction()
		return
	return ..()

/// Lets players click a tile while controlling to face it.
/obj/machinery/computer/camera_advanced/remote_fob/proc/on_controller_click(datum/source, atom/target, turf/location, control, params)
	SIGNAL_HANDLER
	eyeobj.facedir(get_dir(eyeobj, target))
