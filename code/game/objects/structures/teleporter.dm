#define TELEPORTING_COST 250
/obj/machinery/deployable/teleporter
	density = FALSE
	max_integrity = 200
	resistance_flags = XENO_DAMAGEABLE
	idle_power_usage = 50
	///List of all teleportable types
	var/static/list/teleportable_types = list(
		/obj/structure/closet,
		/mob/living/carbon/human,
		/obj/machinery,
	)
	///List of banned teleportable types
	var/static/list/blacklisted_types = list(
		/obj/machinery/nuclearbomb
	)

/obj/machinery/deployable/teleporter/examine(mob/user)
	. = ..()
	var/obj/item/teleporter_kit/kit = get_internal_item()
	if(!kit?.cell)
		. += "It is currently lacking a power cell."
	if(kit?.linked_teleporter)
		. += "It is currently linked to Teleporter #[kit.linked_teleporter.self_tele_tag] at [get_area(kit.linked_teleporter)]"
	else
		. += "It is not linked to any other teleporter."


/obj/machinery/deployable/teleporter/Initialize(mapload)
	. = ..()
	SSminimaps.add_marker(src, MINIMAP_FLAG_MARINE, image('icons/UI_icons/map_blips.dmi', null, "teleporter"))


/obj/machinery/deployable/teleporter/attack_hand(mob/living/user)
	. = ..()
	var/obj/item/teleporter_kit/kit = get_internal_item()
	if(!istype(kit))
		CRASH("A teleporter didn't have an internal item, or it was of the wrong type.")

	if (!powered() && (!kit.cell || kit.cell.charge < TELEPORTING_COST))
		to_chat(user, span_warning("A red light flashes on \the [src]. It seems it doesn't have enough power."))
		playsound(loc,'sound/machines/buzz-two.ogg', 25, FALSE)
		return

	if(!COOLDOWN_CHECK(kit, teleport_cooldown))
		to_chat(user, span_warning("\The [src] is still recharging! It will be ready in [round(COOLDOWN_TIMELEFT(kit, teleport_cooldown) / 10)] seconds."))
		return

	if(!kit.linked_teleporter)
		to_chat(user, span_warning("\The [src] is not linked to any other teleporter."))
		return

	if(!istype(kit.linked_teleporter.loc, /obj/machinery/deployable/teleporter))
		to_chat(user, span_warning("The other teleporter is not deployed!"))
		return

	var/obj/machinery/deployable/teleporter/deployed_linked_teleporter = kit.linked_teleporter.loc
	var/obj/item/teleporter_kit/linked_kit = deployed_linked_teleporter.get_internal_item()

	if(deployed_linked_teleporter.z != z)
		to_chat(user, span_warning("[src] and [deployed_linked_teleporter] are too far apart!"))
		return

	if(!deployed_linked_teleporter.powered() && (!linked_kit?.cell || linked_kit.cell.charge < TELEPORTING_COST))
		to_chat(user, span_warning("[deployed_linked_teleporter] is not powered!"))
		return

	var/list/atom/movable/teleporting = list()
	for(var/atom/movable/thing in loc)
		if(is_type_in_list(thing, blacklisted_types))
			continue
		if(is_type_in_list(thing, teleportable_types) && !thing.anchored)
			teleporting += thing

	if(!length(teleporting))
		to_chat(user, span_warning("No teleportable content was detected on [src]!"))
		return

	do_sparks(5, TRUE, src)
	playsound(loc,'sound/effects/phasein.ogg', 50, FALSE)
	COOLDOWN_START(kit, teleport_cooldown, 2 SECONDS)
	COOLDOWN_START(linked_kit, teleport_cooldown, 2 SECONDS)
	if(powered())
		use_power(TELEPORTING_COST * 200)
	else
		kit.cell.charge -= TELEPORTING_COST
	update_icon()
	if(deployed_linked_teleporter.powered())
		deployed_linked_teleporter.use_power(TELEPORTING_COST * 200)
	else
		linked_kit.cell.charge -= TELEPORTING_COST
	deployed_linked_teleporter.update_icon()
	for(var/atom/movable/thing_to_teleport AS in teleporting)
		thing_to_teleport.forceMove(get_turf(deployed_linked_teleporter))

/obj/machinery/deployable/teleporter/attack_ghost(mob/dead/observer/user)
	var/obj/item/teleporter_kit/kit = internal_item
	if(!istype(kit) || !kit.linked_teleporter)
		return
	user.forceMove(get_turf(kit.linked_teleporter))

/obj/machinery/deployable/teleporter/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(!user)
		return
	var/obj/item/teleporter_kit/kit = get_internal_item()
	if(!istype(kit))
		CRASH("A teleporter didn't have an internal item, or it was of the wrong type.")
	if(!kit.cell)
		to_chat(user, span_warning("There is no cell to remove!"))
		return
	if(!do_after(user, 2 SECONDS, NONE, src))
		return FALSE
	playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
	to_chat(user , span_notice("You remove [kit.cell] from \the [src]."))
	user.put_in_hands(kit.cell)
	kit.cell = null
	update_icon()

/obj/machinery/deployable/teleporter/attackby(obj/item/I, mob/user, params)
	if(!ishuman(user))
		return FALSE
	if(!istype(I, /obj/item/cell))
		return FALSE
	var/obj/item/teleporter_kit/kit = get_internal_item()
	if(!istype(kit))
		CRASH("A teleporter didn't have an internal item, or it was of the wrong type.")
	if(kit?.cell)
		to_chat(user , span_warning("There is already a cell inside, use a crowbar to remove it."))
		return FALSE
	if(!do_after(user, 2 SECONDS, NONE, src))
		return FALSE
	user.temporarilyRemoveItemFromInventory(I)
	I.forceMove(kit)
	kit.cell = I
	playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
	update_icon()

/obj/machinery/deployable/teleporter/update_icon_state()
	var/obj/item/teleporter_kit/kit = get_internal_item()
	if(powered() || kit?.cell?.charge > TELEPORTING_COST)
		icon_state = default_icon_state + "_on"
		return
	icon_state = default_icon_state

/obj/item/teleporter_kit
	name = "\improper ASRS Bluespace teleporter"
	desc = "A bluespace telepad for moving personnel and equipment across small distances to another prelinked teleporter. Ctrl+Click on a tile to deploy, use a wrench to undeploy, use a crowbar to remove the power cell."
	icon = 'icons/Marine/teleporter.dmi'
	icon_state = "teleporter"

	max_integrity = 200
	flags_item = IS_DEPLOYABLE|DEPLOYED_WRENCH_DISASSEMBLE

	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	///The linked teleporter
	var/obj/item/teleporter_kit/linked_teleporter
	///The optional cell to power the teleporter if off the grid
	var/obj/item/cell/cell
	COOLDOWN_DECLARE(teleport_cooldown)

	///Tag for teleporters number. Exists for fluff reasons. Shared variable.
	var/static/tele_tag = 78
	///References to the number of the teleporter.
	var/self_tele_tag

/obj/item/teleporter_kit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, /obj/machinery/deployable/teleporter, 2 SECONDS)
	cell = new /obj/item/cell/high(src)
	tele_tag++
	self_tele_tag = tele_tag
	name = "\improper ASRS Bluespace teleporter #[tele_tag]"


/obj/item/teleporter_kit/Destroy()
	if(linked_teleporter)
		linked_teleporter.linked_teleporter = null
		linked_teleporter = null
	QDEL_NULL(cell)
	return ..()

///Link the two teleporters
/obj/item/teleporter_kit/proc/set_linked_teleporter(obj/item/teleporter_kit/link_teleport)
	if(linked_teleporter)
		CRASH("A teleporter was linked with another teleporter even though it already has a twin!")
	if(link_teleport == src)
		CRASH("A teleporter was linked with itself!")
	linked_teleporter = link_teleport

/obj/item/teleporter_kit/attackby(obj/item/I, mob/user, params)
	if(!ishuman(user))
		return FALSE
	if(!istype(I, /obj/item/teleporter_kit))
		return

	var/obj/item/teleporter_kit/gadget = I
	if(linked_teleporter)
		balloon_alert(user, "The teleporter is already linked with another!")
		return
	if(linked_teleporter == src)
		balloon_alert(user, "You can't link the teleporter with itself!")
		return
	linked_teleporter = linked_teleporter
	balloon_alert(user, "You link both teleporters to each others.")

	set_linked_teleporter(gadget)
	gadget.set_linked_teleporter(src)
	return

/obj/item/teleporter_kit/attack_self(mob/user)
	do_unique_action(user)

/obj/item/teleporter_kit/attack_ghost(mob/dead/observer/user)
	if(!linked_teleporter)
		return
	user.forceMove(get_turf(linked_teleporter))

/obj/effect/teleporter_linker
	name = "\improper ASRS bluespace teleporters"
	desc = "Two bluespace telepads for moving personnel and equipment across small distances to another prelinked teleporter."

/obj/effect/teleporter_linker/Initialize(mapload)
	. = ..()
	var/obj/item/teleporter_kit/teleporter_a = new(loc)
	var/obj/item/teleporter_kit/teleporter_b = new(loc)
	teleporter_a.set_linked_teleporter(teleporter_b)
	teleporter_b.set_linked_teleporter(teleporter_a)
	qdel(src)

