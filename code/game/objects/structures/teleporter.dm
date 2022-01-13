#define TELEPORTING_COST 500

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
	COOLDOWN_DECLARE(teleport_cooldown)
	///List of all teleportable types
	var/static/list/teleportable_types = typecacheof(list(
		/obj/structure/closet,
		/mob/living/carbon/human,
		/obj/machinery,
	))
	///The linked teleporter
	var/obj/machinery/teleporter/linked_teleporter
	///The optional cell to power the teleporter if off the grid
	var/obj/item/cell/cell

/obj/machinery/teleporter/proc/set_linked_teleporter(obj/machinery/teleporter/linked_teleporter)
	if(src.linked_teleporter)
		CRASH("A teleporter was linked with another teleporter even though it already has a twin!")
	src.linked_teleporter = linked_teleporter
	RegisterSignal(linked_teleporter, COMSIG_PARENT_QDELETING, .proc/linked_teleporter_malfunction)

/obj/machinery/teleporter/Destroy()
	linked_teleporter = null
	QDEL_NULL(cell)
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

	if (!powered() && (!cell || cell.charge < TELEPORTING_COST))
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
	
	if(!linked_teleporter.anchored || (!linked_teleporter.powered() && (!linked_teleporter.cell || linked_teleporter.cell.charge < TELEPORTING_COST)))
		to_chat(user, span_warning("The other teleporter is not functional!"))
		return
	
	var/list/atom/movable/teleporting = list()
	for(var/atom/movable/thing in loc)
		if(is_type_in_list(thing, teleportable_types) && !thing.anchored)
			teleporting += thing
	
	if(!teleporting.len)
		to_chat(user, span_warning("No teleportable content was detected on [src]!"))
		return

	do_sparks(5, TRUE, src)
	playsound(loc,'sound/effects/phasein.ogg', 50, FALSE)
	COOLDOWN_START(src, teleport_cooldown, 30 SECONDS)
	if(powered())
		use_power(TELEPORTING_COST * 200)
	else
		cell.charge -= TELEPORTING_COST
	update_icon()
	if(linked_teleporter.powered())
		linked_teleporter.use_power(TELEPORTING_COST * 200)
	else	
		cell.charge -= TELEPORTING_COST
	linked_teleporter.update_icon()
	for(var/atom/movable/thing_to_teleport AS in teleporting)
		thing_to_teleport.forceMove(get_turf(linked_teleporter))

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

/obj/machinery/teleporter/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(!user)
		return
	if(!cell)
		to_chat(user, span_warning("There is no cell to remove!"))
		return
	if(!do_after(user, 2 SECONDS, TRUE, src))
		return FALSE
	playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
	to_chat(user , span_notice("You remove [cell] from \the [src]."))
	user.put_in_hands(cell)
	cell = null
	update_icon()

/obj/machinery/teleporter/attackby(obj/item/I, mob/user, params)
	if(!ishuman(user))
		return FALSE
	if(!istype(I, /obj/item/cell))
		return FALSE
	if(cell)
		to_chat(user , span_warning("There is already a cell inside, use a crowbar to remove it."))
		return
	if(!do_after(user, 2 SECONDS, TRUE, src))
		return FALSE
	I.forceMove(src)
	user.temporarilyRemoveItemFromInventory(I)
	cell = I
	playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
	update_icon()

/obj/machinery/teleporter/update_icon_state()
	if(anchored && (powered() || cell?.charge > TELEPORTING_COST))
		icon_state = "broadcast receiver"
		return
	icon_state = "broadcast receiver_off"
