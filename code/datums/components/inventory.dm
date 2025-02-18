
#define COMSIG_MOB_ITEM_EQUIPPED "mob_item_equipped"
#define COMSIG_MOB_ITEM_UNEQUIPPED "mob_item_unequipped"

#define COMSIG_INVENTORY_STORED_REMOVAL "inventory_stored_removal"

/datum/inventory
	var/mob/living/owner

	var/list/equipped_list

	var/list/gun_list
	var/list/melee_list //excludes bayo boot knife due to type, includes shield
	var/list/ammo_list
	///generic stuff, splints etc?
	var/list/medical_list
	var/list/grenade_list
	var/list/engineering_list

	var/list/brute_list
	var/list/burn_list
	var/list/tox_list
	var/list/oxy_list
	var/list/clone_list
	var/list/pain_list

/datum/inventory/New(mob/living/new_owner)
	. = ..()
	owner = new_owner

	RegisterSignal(owner, COMSIG_MOB_ITEM_EQUIPPED, PROC_REF(item_equipped))

	clear_lists()
	var/list/equip_list = list()
	for(var/slot AS in SLOT_ALL)
		equip_list |= owner.get_item_by_slot(slot)
	for(var/obj/item AS in equip_list)
		item_equipped(owner, item)

/datum/inventory/Destroy(force, ...)
	owner = null
	clear_lists(TRUE)
	return ..()

///clears or resets the inventory lists
/datum/inventory/proc/clear_lists(null_lists = FALSE)
	if(null_lists)
		QDEL_NULL(equipped_list)
		QDEL_NULL(gun_list)
		QDEL_NULL(melee_list)
		QDEL_NULL(ammo_list)
		QDEL_NULL(medical_list)
		QDEL_NULL(grenade_list)
		QDEL_NULL(engineering_list)

		QDEL_NULL(brute_list)
		QDEL_NULL(burn_list)
		QDEL_NULL(tox_list)
		QDEL_NULL(oxy_list)
		QDEL_NULL(clone_list)
		QDEL_NULL(pain_list)
		return
	equipped_list = list()
	gun_list = list()
	melee_list = list()
	ammo_list = list()
	medical_list = list()
	grenade_list = list()
	engineering_list = list()

	brute_list = list()
	burn_list = list()
	tox_list = list()
	oxy_list = list()
	clone_list = list()
	pain_list = list()

///Handles an item being equipped, and its contents
/datum/inventory/proc/item_equipped(mob/user, obj/item/equipped_item)
	SIGNAL_HANDLER
	if(!equipped_item)
		return
	if(equipped_item in equipped_list)
		return
	RegisterSignal(equipped_item, COMSIG_ATOM_ENTERED, PROC_REF(item_stored))
	RegisterSignal(equipped_item, COMSIG_ITEM_REMOVED_INVENTORY, PROC_REF(item_unequipped))
	equipped_list += equipped_item

	var/list/sort_list = list(equipped_item)
	sort_list += get_stored(equipped_item) NOTE TO SELF://internal storage stuff isnt populated if the mob has ai BEFORE the outfit

	for(var/thing in sort_list)
		sort_item(thing)

///Recursive proc to retrieve all stored items inside something
/datum/inventory/proc/get_stored(obj/item/thing)
	var/list/sort_list = list()
	if(thing.storage_datum)
		sort_list += thing.contents
	for(var/item in thing.contents)
		sort_list += get_stored(item)
	return sort_list

///Handles the removal of an item
/datum/inventory/proc/item_unequipped(obj/item/unequipped_item, mob/user)
	SIGNAL_HANDLER
	if(unequipped_item.loc == owner)
		return //still equipped
	UnregisterSignal(unequipped_item, list(COMSIG_ATOM_ENTERED, COMSIG_ITEM_REMOVED_INVENTORY))
	equipped_list -= unequipped_item

	var/list/sort_list = list(unequipped_item)
	sort_list += get_stored(unequipped_item)

	for(var/obj/item/thing AS in sort_list)
		SEND_SIGNAL(thing, COMSIG_INVENTORY_STORED_REMOVAL)

//wrapper due to arg order, can probs remove tho
/datum/inventory/proc/item_stored(mob/store_mob, obj/item/new_item, slot)
	SIGNAL_HANDLER
	sort_item(new_item)

/datum/inventory/proc/sort_item(obj/item/new_item)
	if(isgun(new_item))
		gun_list_add(new_item)
		return
	if(istype(new_item, /obj/item/weapon) && !istype(new_item, /obj/item/weapon/twohanded/offhand)) //todo: boot knives excludes since theyre a different path
		melee_list_add(new_item)
		return
	if(istype(new_item, /obj/item/explosive/grenade))
		grenade_list_add(new_item)
		return
	if(istype(new_item, /obj/item/ammo_magazine) || istype(new_item, /obj/item/cell/lasgun))
		ammo_list_add(new_item)
		return
	if(isitemstack(new_item))
		if(istype(new_item, /obj/item/stack/medical))
			medical_list_add(new_item)
			return
		if(istype(new_item, /obj/item/stack/sheet))
			engineering_list_add(new_item)
			return
	if(isreagentcontainer(new_item))
		medical_list_add(new_item)
		return

//boiler plate

///Adds an item to this list
/datum/inventory/proc/gun_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	gun_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(gun_list_removal))

///Adds an item to this list
/datum/inventory/proc/melee_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	melee_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(melee_list_removal))

///Adds an item to the relevant med lists
/datum/inventory/proc/medical_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(medical_list_removal))
	var/generic = TRUE
	for(var/damtype in GLOB.ai_damtype_to_heal_list)
		if(!(new_item.type in GLOB.ai_damtype_to_heal_list[damtype]))
			continue
		generic = FALSE
		var/list/type_list
		switch(damtype)
			if(BRUTE)
				type_list = brute_list
			if(BURN)
				type_list = burn_list
			if(TOX)
				type_list = tox_list
			if(OXY)
				type_list = oxy_list
			if(CLONE)
				type_list = clone_list
			if(PAIN)
				type_list = pain_list

		type_list += new_item
		var/list/old_list = type_list.Copy()
		type_list.Cut()
		for(var/type in GLOB.ai_damtype_to_heal_list[damtype])
			for(var/obj/item/thing AS in old_list)
				if(thing.type == type)
					type_list += thing

	if(generic)
		medical_list += new_item

///Adds an item to this list
/datum/inventory/proc/ammo_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	ammo_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(ammo_list_removal))

///Adds an item to this list
/datum/inventory/proc/grenade_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	grenade_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(grenade_list_removal))

///Adds an item to this list
/datum/inventory/proc/engineering_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	engineering_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(engineering_list_removal))

///Removes an item from this list
/datum/inventory/proc/gun_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && moving_item.loc == owner)
		return //still in inventory
	gun_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL))

///Removes an item from this list
/datum/inventory/proc/melee_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && moving_item.loc == owner)
		return //still in inventory
	melee_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL))

///Removes an item from this list
/datum/inventory/proc/medical_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && moving_item.loc == owner)
		return //still in inventory
	medical_list -= moving_item
	brute_list -= moving_item
	burn_list -= moving_item
	tox_list -= moving_item
	oxy_list -= moving_item
	clone_list -= moving_item
	pain_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL))

///Removes an item from this list
/datum/inventory/proc/ammo_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && moving_item.loc == owner)
		return //still in inventory
	ammo_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL))

///Removes an item from this list
/datum/inventory/proc/grenade_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && moving_item.loc == owner)
		return //still in inventory
	grenade_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL))

///Removes an item from this list
/datum/inventory/proc/engineering_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && moving_item.loc == owner)
		return //still in inventory
	engineering_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL))


