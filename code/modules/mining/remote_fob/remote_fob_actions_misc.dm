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
		to_chat(owner, "<span class='warning'>No space to build anything here.")
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
		to_chat(owner, "<span class='warning'>Out of material.</span>")
		return

	var/turf/buildplace = get_turf(fobdrone)
	var/obj/structure/barricade/cade = /obj/structure/barricade
	for(var/obj/thing in buildplace)
		if(!thing.density) //not dense, move on
			continue
		if(!(thing.flags_atom & ON_BORDER)) //dense and non-directional, end
			to_chat(owner, "<span class='warning'>No space here for a barricade.</span>")
			return
		if(thing.dir != fobdrone.dir)
			continue
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
		to_chat(owner, "<span class='notice'>Barricade placed with wiring. [console.metal_remaining] metal sheets remaining.</span>")
		return
	to_chat(owner, "<span class='notice'>Barricade placed. [console.metal_remaining] metal sheets remaining.</span>")

/datum/action/innate/remote_fob/plast_cade
	name = "Place Plasteel Barricade"
	action_icon_state = "plast_cade"

/datum/action/innate/remote_fob/plast_cade/Activate()
	. = ..()
	if(. || !check_spot())
		return

	if(console.plasteel_remaining < 5)
		to_chat(owner, "<span class='warning'>Out of material.</span>")
		return

	var/turf/buildplace = get_turf(fobdrone)
	var/obj/structure/barricade/cade = /obj/structure/barricade
	for(var/obj/thing in buildplace)
		if(!thing.density) //not dense, move on
			continue
		if(!(thing.flags_atom & ON_BORDER)) //dense and non-directional, end
			to_chat(owner, "<span class='warning'>No space here for a barricade.</span>")
			return
		if(thing.dir != fobdrone.dir)
			continue
		to_chat(owner, "<span class='warning'>No space here for a barricade.</span>")
		return
	if(!do_after(fobdrone, 3 SECONDS, FALSE, buildplace, BUSY_ICON_BUILD))
		return
	console.plasteel_remaining -= 5
	cade = new /obj/structure/barricade/plasteel(buildplace)
	cade.setDir(fobdrone.dir)
	cade.closed = FALSE
	cade.density = TRUE
	cade.update_icon()
	cade.update_overlay()
	if(console.do_wiring)
		if(console.metal_remaining <= 1)
			to_chat(owner, "<span class='warning'>Not enough material for razor-wiring.</span>")
			return

		console.metal_remaining -=2
		cade.wire()
		to_chat(owner, "<span class='notice'>Barricade placed with wiring. [console.plasteel_remaining] plasteel sheets, [console.metal_remaining] metal sheets remaining.remaining.</span>")
		return
	to_chat(owner, "<span class='notice'>Barricade placed. [console.plasteel_remaining] plasteel sheets remaining.</span>")		

/datum/action/innate/remote_fob/toggle_wiring
	name = "Toggle Razorwire"
	action_icon_state = "wire"

/datum/action/innate/remote_fob/toggle_wiring/Activate()
	. = ..()
	if(.)
		return
	console.do_wiring = !console.do_wiring
	to_chat(owner, "<span class='notice'>Will now [console.do_wiring ? "do wiring" : "stop wiring"].</span>")

/datum/action/innate/remote_fob/sentry
	name = "Place Sentry"
	action_icon_state = "sentry"

/datum/action/innate/remote_fob/sentry/Activate()
	. = ..()
	if(. || !check_spot())
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

/datum/action/innate/remote_fob/eject_metal
	name = "Eject All Metal"
	action_icon_state = "fobpc-eject_m"

/datum/action/innate/remote_fob/eject_metal/Activate()
	. = ..()
	if(.)
		return
	if(console.metal_remaining <= 0)
		to_chat(owner, "<span class='warning'>Nothing to eject.</span>")
		return
	var/obj/item/stack/sheet/metal/stack = /obj/item/stack/sheet/metal
	var/turf/consolespot = get_turf(console)
	stack = new /obj/item/stack/sheet/metal(consolespot)
	stack.amount = console.metal_remaining
	console.metal_remaining = 0
	to_chat(owner, "<span class='notice'>Ejected [stack.amount] metal sheets.</span>")
	flick("fobpc-eject", console)

/datum/action/innate/remote_fob/eject_plasteel
	name = "Eject All Plasteel"
	action_icon_state = "fobpc-eject_p"

/datum/action/innate/remote_fob/eject_plasteel/Activate()
	. = ..()
	if(.)
		return
	if(console.plasteel_remaining <= 0)
		to_chat(owner, "<span class='warning'>Nothing to eject.</span>")
		return
	flick("fobpc-eject", console)
	var/obj/item/stack/sheet/plasteel/stack = /obj/item/stack/sheet/plasteel
	var/turf/consolespot = get_turf(console)
	stack = new /obj/item/stack/sheet/plasteel(consolespot)
	stack.amount = console.plasteel_remaining
	console.plasteel_remaining = 0
	to_chat(owner, "<span class='notice'>Ejected [stack.amount] plasteel sheets.</span>")


/obj/item/stack/voucher/sentry
	name = "Sentry gun voucher"
	desc = "A voucher for a UA 571-C sentry gun, redeemable at the Remote FOB Construction Console. Keep buying them for a chance at Bal Di's golden sentry ticket!"
	icon = 'icons/Marine/remotefob.dmi'
	icon_state = "sentry_voucher"
	max_amount = 1
	w_class = WEIGHT_CLASS_TINY
