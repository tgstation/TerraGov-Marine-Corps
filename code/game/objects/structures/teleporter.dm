/obj/effect/teleporter_linker/Initialize()
	. = ..()
	var/obj/machinery/teleporter/teleporter_a = new(loc)
	var/obj/machinery/teleporter/teleporter_b = new(loc)
	teleporter_a.set_linked_teleporter(teleporter_b)
	teleporter_b.set_linked_teleporter(teleporter_a)

/obj/machinery/teleporter
	name = "ASRS Bluespace teleporter"
	desc = "A bluespace telepad for moving personnel and equipment across small distances to another prelinked teleporter. They are using quantum entanglement technology and are as such very volatile."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "broadcast receiver_off"
	density = FALSE
	anchored = FALSE
	wrenchable = TRUE
	idle_power_usage = 50
	active_power_usage = 3000
	COOLDOWN_DECLARE(teleport_cooldown)
	///List of all teleportable types
	var/static/list/teleportable_types = typecacheof(list(
		/obj/structure/closet/crate,
		/mob/living/carbon/human,
		/obj/machinery,
	))
	///The linked teleporter
	var/obj/machinery/teleporter/linked_teleporter

/obj/machinery/teleporter/proc/set_linked_teleporter(obj/machinery/teleporter/linked_teleporter)
	if(src.linked_teleporter)
		CRASH("A teleporter was linked with another teleporter eve though it already has a twin!")
	src.linked_teleporter = linked_teleporter
	RegisterSignal(linked_teleporter, COMSIG_PARENT_QDELETING, .proc/linked_teleporter_malfunction)

/obj/machinery/teleporter/Destroy()
	linked_teleporter = null
	return ..()

///Explode when the other teleporter is destroyed
/obj/machinery/teleporter/proc/linked_teleporter_malfunction()
	SIGNAL_HANDLER
	explosion(src, 0, 1, 2)
	qdel(src)

/obj/machinery/teleporter/attack_hand(mob/living/user)
	. = ..()
	if (!anchored)
		to_chat(user, span_warning("Nothing happens. The [src] must be bolted to the ground first."))
		return

	if (!powered())
		to_chat(user, span_warning("A red light flashes on the [src]. It seems it doesn't have enough power."))
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		return

	if(!COOLDOWN_CHECK(src, teleport_cooldown))
		to_chat(user, span_warning("The [src] is still recharging! It will be ready in [round(COOLDOWN_TIMELEFT(src, teleport_cooldown) / 10)] seconds."))
		return
	
	if(!linked_teleporter)
		to_chat(user, span_warning("The [src] is not linked to any other teleporter"))
		return

	if(linked_teleporter.z != z)
		to_chat(user, span_warning("The [src] and the [linked_teleporter] are too far appart"))
		return
	
	if(!linked_teleporter.anchored || !linked_teleporter.powered())
		to_chat(user, span_warning("The other teleporter is not functional!"))
		return
	
	var/atom/movable/teleporting
	for(var/thing in loc)
		if(is_type_in_list(thing, teleportable_types))
			teleporting = thing
			if(teleporting.anchored)
				teleporting = null
				continue
			break
	
	if(!teleporting)
		to_chat(user, span_warning("No teleportable content was detected on [src]!"))
		return

	do_sparks(5, TRUE, src)
	playsound(loc,'sound/effects/phasein.ogg', 50, FALSE)
	COOLDOWN_START(src, teleport_cooldown, 30 SECONDS)
	use_power = ACTIVE_POWER_USE//takes a lot more power while cooling down
	addtimer(VARSET_CALLBACK(src, use_power, IDLE_POWER_USE), 30 SECONDS)

	teleporting.forceMove(get_turf(linked_teleporter))

/obj/machinery/teleporter/wrench_act(mob/living/user, obj/item/I)
	anchored = !anchored
	if(anchored)
		to_chat(user, "You bolt the [src] to the ground, activating it.")
		playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
		update_icon()
		return
	to_chat(user, "You unbolt the [src] from the ground, deactivating it.")
	playsound(loc, 'sound/items/ratchet.ogg', 25, TRUE)
	update_icon()

/obj/machinery/teleporter/update_icon_state()
	if(anchored)
		icon_state = "broadcast receiver"
		return
	icon_state = "broadcast receiver_off"
