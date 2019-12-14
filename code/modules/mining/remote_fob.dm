/////////For remote construction of FOB using a computer on the ship during setup phase
GLOBAL_LIST_INIT(dropship_lzs, typecacheof(list(/area/shuttle/drop1/lz1, /area/shuttle/drop2/lz2)))


/////////////////////////////// Drone Mob

/mob/camera/aiEye/remote/fobdrone
	name = "Remote Construction Drone"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	icon = 'icons/Marine/remotefob.dmi'
	icon_state = "drone"
	var/area/starting_area
	use_static = FALSE
	var/turf/spawnloc

/mob/camera/aiEye/remote/fobdrone/Initialize()
	. = ..()
	starting_area = get_area(loc)

/mob/camera/aiEye/remote/fobdrone/setLoc(var/atom/t) //unrestricted movement inside the landing zone
	var/area/curr_area = get_area(t)
	if(istype(t, /turf/closed) || locate(/obj/machinery/door/poddoor) in t)
		return
	if(curr_area == starting_area || is_type_in_typecache(curr_area, GLOB.dropship_lzs))
		return ..()


/mob/camera/aiEye/remote/fobdrone/relaymove(mob/user, direct)
	dir = direct //This camera eye is visible as a drone, and needs to keep the dir updated
	..()

/mob/camera/aiEye/remote/fobdrone/update_remote_sight(mob/living/user)
	user.see_invisible = FALSE
	user.sight = SEE_SELF|SEE_BLACKNESS
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
	user.see_in_dark = 7
	return TRUE

/////////////////////////////// the camera computer

/obj/machinery/computer/camera_advanced/remote_fob
	name = "FOB Construction Drone Control"
	desc = "A computer console equipped with camera screen and controls for a planetside deployed construction drone. Materials or equipment vouchers can be added simply by inserting them into the computer."
//	icon_screen = 
//	icon_keyboard =
	icon_state = "syndishuttle"
	req_access = list(ACCESS_MARINE_REMOTEBUILD)
	networks = FALSE
	off_action = new/datum/action/innate/camera_off/remote_fob
	jump_action = null
	var/drone_creation_allowed = TRUE
	var/spawn_spot
	var/lz
	var/datum/action/innate/remote_fob/metal_cade/metal_cade = new
	var/max_metal = 50 //mostly to prevent jokers collecting all the metal and dumping it in
	var/metal_remaining = 0
	var/datum/action/innate/remote_fob/plast_cade/plast_cade = new
	var/max_plasteel = 50
	var/plasteel_remaining = 0
	var/datum/action/innate/remote_fob/toggle_wiring/toggle_wiring = new //whether or not new barricades will be wired
	var/do_wiring = FALSE
	var/datum/action/innate/remote_fob/sentry/sentry = new
	var/sentry_remaining = 0

/obj/machinery/computer/camera_advanced/remote_fob/Initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_TRANSIT, .proc/disable_drone_creation)

/obj/machinery/computer/camera_advanced/remote_fob/proc/disable_drone_creation()
	drone_creation_allowed = FALSE
	UnregisterSignal(SSdcs, COMSIG_GLOB_DROPSHIP_TRANSIT)

/obj/machinery/computer/camera_advanced/remote_fob/examine(mob/user)
	. = ..()
	var/list/details = list()
	details +=("It has [metal_remaining] sheets of metal remaining.</br>")
	details +=("It has [plasteel_remaining] sheets of plasteel remaining.</br>")
	details +=("It has [sentry_remaining] sentries ready for placement.</br>")
	to_chat(user, "[details.Join(" ")] ")

/obj/machinery/computer/camera_advanced/remote_fob/give_eye_control(mob/user)
	. = ..()
	user.lighting_alpha = 120
	eyeobj.name = "Remote Construction Drone"
	if(eyeobj.eye_initialized)
		eyeobj.setLoc(get_turf(spawn_spot))


/obj/machinery/computer/camera_advanced/remote_fob/attack_hand(mob/living/user)
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access Denied!</span>")
		return
	if(!drone_creation_allowed)
		to_chat(user, "<span class='notice'>Communication with the drone impossible due to fuel-residue in deployment zone atmosphere.</span>")
		return
	spawn_spot = FALSE
	var/port
	switch(tgalert(user, "Summon Drone in:", "FOB Construction Drone Control", "LZ1","LZ2"))
		if("LZ1")
			port = /obj/docking_port/stationary/marine_dropship/lz1
			for(port in SSshuttle.stationary)
				if(istype(get_area(port), /area/shuttle/drop1/lz1))
					spawn_spot = port
					break
		if("LZ2")
			port = /obj/docking_port/stationary/marine_dropship/lz2
			for(port in SSshuttle.stationary)
				if(istype(get_area(port), /area/shuttle/drop2/lz2))
					spawn_spot = port
					break
		else
			return
	. = ..()
	

/obj/machinery/computer/camera_advanced/remote_fob/CreateEye()
	if(spawn_spot)
		eyeobj = new /mob/camera/aiEye/remote/fobdrone(get_turf(spawn_spot))
		eyeobj.origin = src
	return

/obj/machinery/computer/camera_advanced/remote_fob/attackby(obj/item/stack/W, mob/user, params)
	if(istype(W, /obj/item/stack/sentryvoucher))
		var/useamount = W.amount
		sentry_remaining += useamount
		W.use(useamount)
		to_chat(user, "<span class='notice'>Sentry voucher redeemed.</span>")
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 25, FALSE)
		return
	if(istype(W, /obj/item/stack/sheet/metal))
		if(max_metal >= metal_remaining)
			to_chat(user, "<span class='notice'>Can't insert any more metal.")
			return
		var/useamount = min(W.amount, (max_metal-metal_remaining))
		metal_remaining += useamount
		W.use(useamount)
		to_chat(user, "<span class='notice'>Inserted [useamount] metal sheets.")
		return
	if(istype(W, /obj/item/stack/sheet/plasteel))
		if(max_plasteel >= plasteel_remaining)
			to_chat(user, "<span class='notice'>Can't insert any more plasteel.")
			return
		var/useamount = min(W.amount, (max_plasteel-plasteel_remaining))
		plasteel_remaining += useamount
		W.use(useamount)
		to_chat(user, "<span class='notice'>Inserted [useamount] plateel sheets.")
		return
	else
		to_chat(user, "<span class ='notice'>Invalid material type.</span>")
	..()

/obj/machinery/computer/camera_advanced/remote_fob/GrantActions(mob/living/user)
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

	eyeobj.invisibility = 0

/obj/machinery/computer/camera_advanced/remote_fob/remove_eye_control(mob/living/user)
	.. ()
	eyeobj.invisibility = INVISIBILITY_ABSTRACT
	eyeobj.eye_initialized = FALSE
	return PROCESS_KILL

/obj/machinery/computer/camera_advanced/remote_fob/check_eye(mob/living/user)
	if(!drone_creation_allowed)
		to_chat(user, "<span class='notice'>Communication with the drone has been disrupted.</span>")
		user.unset_interaction()
	. = ..()

/////////////////////////////// Placement Actions

/datum/action/innate/remote_fob //Parent stuff
	action_icon = 'icons/Marine/remotefob.dmi'
	var/mob/living/C //the mob using the action
	var/mob/camera/aiEye/remote/fobdrone //the drone belonging to the computer
	var/obj/machinery/computer/camera_advanced/remote_fob/console //the computer itself

/datum/action/innate/remote_fob/Activate()
	if(!target)
		return TRUE
	C = owner
	fobdrone = C.remote_control
	console = target

/datum/action/innate/remote_fob/proc/check_spot()
	var/turf/build_target = get_turf(fobdrone)
	var/turf/build_area = get_area(build_target)

	if(!is_type_in_typecache(build_area, GLOB.dropship_lzs))
		to_chat(owner, "<span class='warning'>You can only build within the Landing Zone!</span>")
		return FALSE

	return TRUE

/datum/action/innate/camera_off/remote_fob
	name = "Log out"

/datum/action/innate/remote_fob/metal_cade
	name = "Place Metal Barricade"
	action_icon_state = "metal_cade"
	

/datum/action/innate/remote_fob/metal_cade/Activate()
	if(..() || !check_spot())
		return

	if(console.metal_remaining < 4)
		to_chat(owner, "<span class='warning'>Out of material.</span>")
		return

	var/turf/buildplace = get_turf(fobdrone)
	var/obj/structure/barricade/cade = /obj/structure/barricade
	if(is_blocked_turf(buildplace))
		for(var/obj/thing in buildplace)
			if(istype(thing, cade) && thing.dir != fobdrone.dir)
				break
			else
				to_chat(owner, "<span class='warning'>No space here for a barricade.</span>")
				return
	if(!do_after(fobdrone, 3 SECONDS, FALSE, buildplace, BUSY_ICON_BUILD))
		return
	console.metal_remaining -= 4
	cade = new /obj/structure/barricade/metal(buildplace)
	cade.setDir(fobdrone.dir)
	if(console.do_wiring)
		if(console.metal_remaining <= 1)
			to_chat(owner, "<span class='warning'>Not enough material for razor-wiring.</span>")
			return

		console.metal_remaining -=2
		cade.wire()


/datum/action/innate/remote_fob/plast_cade
	name = "Place Plasteel Barricade"
	action_icon_state = "plast_cade"

/datum/action/innate/remote_fob/plast_cade/Activate()
	if(..() || !check_spot())
		return

	if(console.plasteel_remaining < 5)
		to_chat(owner, "<span class='warning'>Out of material.</span>")
		return

	var/turf/buildplace = get_turf(fobdrone)
	var/obj/structure/barricade/cade = /obj/structure/barricade
	if(is_blocked_turf(buildplace))
		for(var/obj/thing in buildplace)
			if(istype(thing, cade) && thing.dir != fobdrone.dir)
				break
			else
				to_chat(owner, "<span class='warning'>No space here for a barricade.</span>")
				return
	if(!do_after(fobdrone, 3 SECONDS, FALSE, buildplace, BUSY_ICON_BUILD))
		return
	console.plasteel_remaining -= 5
	cade = new /obj/structure/barricade/plasteel(buildplace)
	cade.setDir(fobdrone.dir)
	cade.closed = 0
	cade.density = 1
	cade.update_icon()
	cade.update_overlay()
	if(console.do_wiring)
		if(console.metal_remaining <= 1)
			to_chat(owner, "<span class='warning'>Not enough material for razor-wiring.</span>")
			return

		console.metal_remaining -=2
		cade.wire()
		

/datum/action/innate/remote_fob/toggle_wiring
	name = "Toggle Razorwire"
	action_icon_state = "wire"

/datum/action/innate/remote_fob/toggle_wiring/Activate()
	if(..())
		return
	console.do_wiring = !console.do_wiring
	to_chat(owner, "<span class='notice'>Will now [console.do_wiring ? "do wiring" : "stop wiring"].</span>")

/datum/action/innate/remote_fob/sentry
	name = "Place Sentry"
	action_icon_state = "sentry"

/datum/action/innate/remote_fob/sentry/Activate()
	if(..() || !check_spot())
		return
	var/obj/machinery/marine_turret/turret = /obj/machinery/marine_turret
	var/turf/buildplace = get_turf(fobdrone)
	var/obj/structure/barricade/cade = /obj/structure/barricade
	if(console.sentry_remaining < 1)
		to_chat(owner, "<span class='warning'>You need to redeem a Sentry voucher to place one.</span>")
		return
	if(is_blocked_turf(buildplace))
		for(var/obj/thing in buildplace)
			if(istype(thing, cade))
				break
			else
				to_chat(owner, "<span class='warning'>No space here for a sentry.</span>")
				return
	if(!do_after(fobdrone, 6 SECONDS, FALSE, buildplace, BUSY_ICON_BUILD))
		return
	console.sentry_remaining -= 1
	turret = new /obj/machinery/marine_turret(buildplace)
	turret.setDir(fobdrone.dir)

/obj/item/stack/sentryvoucher
	name = "Sentry gun voucher"
	desc = "A voucher for a UA 571-C sentry gun, redeemable at the Remote FOB Construction Console. Keep buying them for a chance at Bal Di's golden sentry ticket!"
	icon = 'icons/Marine/remotefob.dmi'
	icon_state = "sentry_voucher"
	max_amount = 1
