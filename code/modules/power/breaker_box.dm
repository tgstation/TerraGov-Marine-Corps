// Updated version of old powerswitch by Atlantis
// Has better texture, and is now considered electronic device
// AI has ability to toggle it in 5 seconds
// Humans need 30 seconds (AI is faster when it comes to complex electronics)
// Used for advanced grid control (read: Substations)

/obj/machinery/power/breakerbox
	name = "Breaker Box"
	icon = 'icons/obj/power.dmi'
	icon_state = "bbox_off"
	var/icon_state_on = "bbox_on"
	var/icon_state_off = "bbox_off"
	density = TRUE
	anchored = TRUE
	var/on = FALSE
	var/busy = FALSE
	var/directions = list(1,2,4,8,5,6,9,10)

/obj/machinery/power/breakerbox/activated
	icon_state = "bbox_on"

	// Enabled on server startup. Used in substations to keep them in bypass mode.
/obj/machinery/power/breakerbox/activated/Initialize()
	..()
	set_state(1)

/obj/machinery/power/breakerbox/examine(mob/user)
	to_chat(user, "Large machine with heavy duty switching circuits used for advanced grid control")
	if(on)
		to_chat(user, "<span class='green'> It seems to be online.</span>")
	else
		to_chat(user, "<span class='warning'>It seems to be offline</span>")

/obj/machinery/power/breakerbox/attack_ai(mob/user)
	if(busy)
		to_chat(user, "<span class='warning'>System is busy. Please wait until current operation is finished before changing power settings.</span>")
		return

	busy = 1
	to_chat(user, "<span class='green'> Updating power settings..</span>")
	if(do_after(user, 5 SECONDS, FALSE, src)) //5s for AI as AIs can manipulate electronics much faster.
		set_state(!on)
		to_chat(user, "<span class='green'> Update Completed. New setting:[on ? "on": "off"]</span>")
	busy = 0


/obj/machinery/power/breakerbox/attack_hand(mob/user)

	if(busy)
		to_chat(user, "<span class='warning'>System is busy. Please wait until current operation is finished before changing power settings.</span>")
		return

	busy = 1
	user.visible_message("<span class='warning'> [user] started reprogramming [src]!</span>","You start reprogramming [src]")
	if(do_after(user, 30 SECONDS, FALSE, src, BUSY_ICON_BUILD)) // 30s for non-AIs as humans have to manually reprogram it and rapid switching may cause some lag / powernet updates flood. If AIs spam it they can be easily traced.
		set_state(!on)
		user.visible_message(\
		"<span class='notice'>[user.name] [on ? "enabled" : "disabled"] the breaker box!</span>",\
		"<span class='notice'>You [on ? "enabled" : "disabled"] the breaker box!</span>")
	busy = 0

/obj/machinery/power/breakerbox/proc/set_state(var/state)
	on = state
	if(on)
		icon_state = icon_state_on
		var/list/connection_dirs = list()
		for(var/direction in directions)
			for(var/obj/structure/cable/C in get_step(src,direction))
				if(C.d1 == turn(direction, 180) || C.d2 == turn(direction, 180))
					connection_dirs += direction
					break

		for(var/direction in connection_dirs)
			var/obj/structure/cable/C = new/obj/structure/cable(src.loc)
			C.d1 = 0
			C.d2 = direction
			C.icon_state = "[C.d1]-[C.d2]"
			//C.breaker_box = src

			var/datum/powernet/PN = new()
			PN.number = SSmachines.powernets.len + 1
			SSmachines.powernets += PN
			PN.cables += C

			C.mergeConnectedNetworks(C.d2)
			C.mergeConnectedNetworksOnTurf()

	else
		icon_state = icon_state_off
		for(var/obj/structure/cable/C in src.loc)
			qdel(C)
