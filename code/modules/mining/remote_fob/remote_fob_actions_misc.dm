/////////////////////////////// Placement Actions

/datum/action/innate/remote_fob //Parent stuff
	action_icon = 'icons/Marine/remotefob.dmi'
	var/mob/living/builder //the mob using the action
	var/mob/camera/aiEye/remote/fobdrone //the drone belonging to the computer
	var/obj/machinery/computer/camera_advanced/remote_fob/console //the computer itself

/datum/action/innate/remote_fob/Activate()
	if(!target)
		return TRUE
	builder = owner
	fobdrone = builder.remote_control
	console = target

/datum/action/innate/remote_fob/Destroy()
	builder = null
	fobdrone = null
	console = null
	return ..()

/datum/action/innate/remote_fob/proc/check_spot()
	var/turf/build_target = get_turf(fobdrone)
	var/turf/build_area = get_area(build_target)

	if(build_area.density)

		fobdrone.balloon_alert(owner, "No space to build anything here.")
		return FALSE
	if(fobdrone.do_actions)
		fobdrone.balloon_alert(owner, "You are already building something.")
		return FALSE

	return TRUE

/datum/action/innate/camera_off/remote_fob
	name = "Log out"

/datum/action/innate/remote_fob/metal_cade
	name = "Place Metal Barricade"
	action_icon_state = "metal_cade"


/datum/action/innate/remote_fob/metal_cade/Activate()
	. = ..()
	if(. || !check_spot())
		return

	if(console.metal_remaining < 4)
		to_chat(owner, span_warning("Out of material."))
		return

	var/turf/buildplace = get_turf(fobdrone)
	var/obj/structure/barricade/cade = /obj/structure/barricade
	for(var/obj/thing in buildplace)
		if(!thing.density) //not dense, move on
			continue
		if(!(thing.flags_atom & ON_BORDER)) //dense and non-directional, end
			fobdrone.balloon_alert(owner, "No space here for a barricade")
			return
		if(thing.dir != fobdrone.dir)
			continue
		fobdrone.balloon_alert(owner, "No space here for a barricade")
		return
	if(!do_after(fobdrone, 1.5 SECONDS, IGNORE_HELD_ITEM, buildplace, BUSY_ICON_BUILD))
		return
	console.metal_remaining -= 4
	cade = new /obj/structure/barricade/metal(buildplace)
	cade.setDir(fobdrone.dir)
	if(console.do_wiring)
		if(console.metal_remaining <= 1)
			fobdrone.balloon_alert(owner, "Not enough material for razor-wiring.")
			return

		console.metal_remaining -=2
		cade.wire()
		fobdrone.balloon_alert(owner, "Barricade placed with wiring. [console.metal_remaining] metal sheets remaining.")
		return
	fobdrone.balloon_alert(owner, "Barricade placed. [console.metal_remaining] metal sheets remaining.")

/datum/action/innate/remote_fob/plast_cade
	name = "Place Plasteel Barricade"
	action_icon_state = "plast_cade"

/datum/action/innate/remote_fob/plast_cade/Activate()
	. = ..()
	if(. || !check_spot())
		return

	if(console.plasteel_remaining < 5)
		fobdrone.balloon_alert(owner, "Out of material")
		return

	var/turf/buildplace = get_turf(fobdrone)
	var/obj/structure/barricade/cade = /obj/structure/barricade
	for(var/obj/thing in buildplace)
		if(!thing.density) //not dense, move on
			continue
		if(!(thing.flags_atom & ON_BORDER)) //dense and non-directional, end
			fobdrone.balloon_alert(owner, "No space here for a barricade")
			return
		if(thing.dir != fobdrone.dir)
			continue
		fobdrone.balloon_alert(owner, "No space here for a barricade")
		return
	if(!do_after(fobdrone, 1.5 SECONDS, IGNORE_HELD_ITEM, buildplace, BUSY_ICON_BUILD))
		return
	console.plasteel_remaining -= 5
	cade = new /obj/structure/barricade/plasteel(buildplace)
	cade.setDir(fobdrone.dir)
	cade.closed = FALSE
	cade.density = TRUE
	cade.update_icon()
	if(console.do_wiring)
		if(console.metal_remaining <= 1)
			fobdrone.balloon_alert(owner, "Not enough material for razor-wiring")
			return
		cade.wire()
		console.metal_remaining -=2
		fobdrone.balloon_alert(owner, "Barricade placed with wiring. [console.plasteel_remaining] plasteel sheets, [console.metal_remaining] metal sheets remaining.")
		return
	fobdrone.balloon_alert(owner, "Barricade placed. [console.plasteel_remaining] plasteel sheets remaining.")

/datum/action/innate/remote_fob/toggle_wiring
	name = "Toggle Razorwire"
	action_icon_state = "wire"

/datum/action/innate/remote_fob/toggle_wiring/Activate()
	. = ..()
	if(.)
		return
	console.do_wiring = !console.do_wiring
	to_chat(owner, span_notice("Will now [console.do_wiring ? "do wiring" : "stop wiring"]."))
/datum/action/innate/remote_fob/eject_metal_action
	name = "Eject All Metal"
	action_icon_state = "fobpc-eject_m"

/datum/action/innate/remote_fob/eject_metal_action/Activate()
	. = ..()
	if(.)
		return
	if(console.metal_remaining <= 0)
		fobdrone.balloon_alert(owner, "No metal to eject")
		return
	console.eject_mat(EJECT_METAL)
	fobdrone.balloon_alert(owner, "Metal sheets ejected")


/datum/action/innate/remote_fob/eject_plasteel_action
	name = "Eject All Plasteel"
	action_icon_state = "fobpc-eject_p"

/datum/action/innate/remote_fob/eject_plasteel_action/Activate()
	. = ..()
	if(.)
		return
	if(console.plasteel_remaining <= 0)
		fobdrone.balloon_alert(owner, "No plasteel to eject")
		return
	console.eject_mat(EJECT_PLASTEEL)
	fobdrone.balloon_alert(owner, "Plasteel sheets ejected")
