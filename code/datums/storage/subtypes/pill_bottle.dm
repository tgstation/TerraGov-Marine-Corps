/datum/storage/pill_bottle
	allow_quick_gather = TRUE
	use_to_pickup = TRUE
	storage_slots = null
	use_sound = 'sound/items/pillbottle.ogg'
	max_storage_space = 16
	refill_types = list(/obj/item/storage/pill_bottle)
	refill_sound = 'sound/items/pills.ogg'

/datum/storage/pill_bottle/New(atom/parent)
	. = ..()
	set_holdable(can_hold_list = list(
		/obj/item/reagent_containers/pill,
		/obj/item/toy/dice,
		/obj/item/paper,
	))

/datum/storage/pill_bottle/remove_from_storage(obj/item/item, atom/new_location, mob/user, silent = FALSE, bypass_delay = FALSE)
	. = ..()
	if(!silent && . && user)
		playsound(user, 'sound/items/pills.ogg', 15, 1)

/datum/storage/pill_bottle/on_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	if(!istype(attacking_item, /obj/item/reagent_containers/hypospray))
		return ..()

/datum/storage/pill_bottle/packet
	storage_slots = 8
	max_w_class = 0
	max_storage_space = 8
	trash_item = /obj/item/trash/pillpacket
	refill_types = null
	refill_sound = null
	storage_flags = BYPASS_VENDOR_CHECK

/datum/storage/pill_bottle/packet/New(atom/parent)
	. = ..()
	set_holdable(cant_hold_list = list(/obj/item/reagent_containers/pill)) //Nada. Once you take the pills out. They don't come back in.

/datum/storage/pill_bottle/packet/remove_from_storage(obj/item/item, atom/new_location, mob/user, silent = FALSE, bypass_delay = FALSE)
	. = ..()
	if(!.)
		return
	if(!length(parent.contents) && !QDELETED(parent))
		var/turf/parent_turf = get_turf(parent)
		new trash_item(parent_turf)
		qdel(parent)
		return
	parent.update_icon()
