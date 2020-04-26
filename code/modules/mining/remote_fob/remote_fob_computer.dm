
/////////////////////////////// the camera computer

/obj/machinery/computer/camera_advanced/remote_fob
	name = "FOB Construction Drone Control"
	desc = "A computer console equipped with camera screen and controls for a planetside deployed construction drone. Materials or equipment vouchers can be added simply by inserting them into the computer."
	icon = 'icons/Marine/remotefob.dmi'
	icon_state = "fobpc"
	req_one_access = list(ACCESS_MARINE_REMOTEBUILD, ACCESS_MARINE_CE, ACCESS_MARINE_ENGINEERING)
	networks = FALSE
	off_action = new/datum/action/innate/camera_off/remote_fob
	jump_action = null
	var/drone_creation_allowed = TRUE
	var/obj/docking_port/stationary/marine_dropship/spawn_spot
	var/datum/action/innate/remote_fob/metal_cade/metal_cade
	var/max_metal = 50 //mostly to prevent jokers collecting all the metal and dumping it in
	var/metal_remaining = 0
	var/datum/action/innate/remote_fob/plast_cade/plast_cade
	var/max_plasteel = 50
	var/plasteel_remaining = 0
	var/datum/action/innate/remote_fob/toggle_wiring/toggle_wiring //whether or not new barricades will be wired
	var/do_wiring = FALSE
	var/datum/action/innate/remote_fob/sentry/sentry
	var/sentry_remaining = 0
	var/datum/action/innate/remote_fob/eject_metal/eject_metal
	var/datum/action/innate/remote_fob/eject_plasteel/eject_plasteel

/obj/machinery/computer/camera_advanced/remote_fob/Initialize()
	. = ..()
	metal_cade = new()
	plast_cade = new()
	toggle_wiring = new()
	sentry = new()
	eject_metal = new()
	eject_plasteel = new()

	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_TRANSIT, .proc/disable_drone_creation)

/obj/machinery/computer/camera_advanced/remote_fob/proc/disable_drone_creation()
	drone_creation_allowed = FALSE
	UnregisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_TRANSIT)


/obj/machinery/computer/camera_advanced/remote_fob/Destroy()
	spawn_spot = null
	QDEL_NULL(metal_cade)
	QDEL_NULL(plast_cade)
	QDEL_NULL(toggle_wiring)
	QDEL_NULL(sentry)
	QDEL_NULL(eject_metal)
	QDEL_NULL(eject_plasteel)
	
	return ..()


/obj/machinery/computer/camera_advanced/remote_fob/examine(mob/user)
	. = ..()
	var/list/details = list()
	details +="It has [metal_remaining] sheets of metal remaining.</br>"
	details +="It has [plasteel_remaining] sheets of plasteel remaining.</br>"
	details +="It has [sentry_remaining] sentries ready for placement.</br>"
	to_chat(user, details.Join(" "))

/obj/machinery/computer/camera_advanced/remote_fob/give_eye_control(mob/user)
	. = ..()
	icon_state = "fobpc-transfer"
	user.lighting_alpha = 120
	eyeobj.name = "Remote Construction Drone"
	eyeobj.register_facedir_signals(user)
	if(eyeobj.eye_initialized)
		eyeobj.setLoc(get_turf(spawn_spot))
	
/obj/machinery/computer/camera_advanced/remote_fob/interact(mob/living/user)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(isAI(user))
		to_chat(user, "<span class='warning'>#ERROR! Drone terminated AI connection on handshake. Error thrown: 'We don't want machines building machines, but good try.'</span>")
		return // In order to allow AIs to use this update_sight() needs to be refactored to properly handle living
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied!</span>")
		return
	if(!drone_creation_allowed)
		to_chat(user, "<span class='notice'>Communication with the drone impossible due to fuel-residue in deployment zone atmosphere.</span>")
		return
	spawn_spot = FALSE
	switch(tgalert(user, "Summon Drone in:", "FOB Construction Drone Control", "LZ1","LZ2","Cancel"))
		if("LZ1")
			spawn_spot = locate(/obj/docking_port/stationary/marine_dropship/lz1) in SSshuttle.stationary
			if(!spawn_spot)
				to_chat(user, "<span class='warning'>No valid location for drone deployment found.</span>")
				return	
		if("LZ2")
			spawn_spot = locate(/obj/docking_port/stationary/marine_dropship/lz2) in SSshuttle.stationary
			if(!spawn_spot)
				to_chat(user, "<span class='warning'>No valid location for drone deployment found.</span>")
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
		if(istype(attacking_stack, /obj/item/stack/voucher/sentry))
			var/useamount = attacking_stack.amount
			sentry_remaining += useamount
			attacking_stack.use(useamount)
			to_chat(user, "<span class='notice'>Sentry voucher redeemed.</span>")
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 25, FALSE)
			flick("fobpc-insert", src)
			return
		if(istype(attacking_stack, /obj/item/stack/sheet/metal))
			if(max_metal <= metal_remaining)
				to_chat(user, "<span class='notice'>Can't insert any more metal.")
				return
			var/useamount = min(attacking_stack.amount, (max_metal-metal_remaining))
			metal_remaining += useamount
			attacking_stack.use(useamount)
			to_chat(user, "<span class='notice'>Inserted [useamount] metal sheets.")
			flick("fobpc-insert", src)
			return
		if(istype(attacking_stack, /obj/item/stack/sheet/plasteel))
			if(max_plasteel <= plasteel_remaining)
				to_chat(user, "<span class='notice'>Can't insert any more plasteel.")
				return
			var/useamount = min(attacking_stack.amount, (max_plasteel-plasteel_remaining))
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

	if(eject_metal)
		eject_metal.target = src
		eject_metal.give_action(user)
		actions += eject_metal

	if(eject_plasteel)
		eject_plasteel.target = src
		eject_plasteel.give_action(user)
		actions += eject_plasteel

	eyeobj.invisibility = 0

/obj/machinery/computer/camera_advanced/remote_fob/remove_eye_control(mob/living/user)
	icon_state = "fobpc"
	eyeobj.invisibility = INVISIBILITY_ABSTRACT
	eyeobj.eye_initialized = FALSE
	eyeobj.unregister_facedir_signals(user)
	return ..()

/obj/machinery/computer/camera_advanced/remote_fob/check_eye(mob/living/user)
	if(!drone_creation_allowed)
		to_chat(user, "<span class='notice'>Communication with the drone has been disrupted.</span>")
		user.unset_interaction()
		return
	return ..()
