
#define COMSIG_MOB_ITEM_EQUIPPED "mob_item_equipped"
#define COMSIG_MOB_ITEM_UNEQUIPPED "mob_item_unequipped"

#define COMSIG_INVENTORY_STORED_REMOVAL "inventory_stored_removal"

#define COMSIG_INVENTORY_DAT_GUN_ADDED "inventory_dat_gun_added"
#define COMSIG_INVENTORY_DAT_MELEE_ADDED "inventory_dat_melee_added"

/datum/managed_inventory
	///Mob this inventory is for
	var/mob/living/owner
	///Items actually equipped to slots
	var/list/equipped_list
	//item lists - don't make me autodoc these
	var/list/gun_list
	var/list/melee_list //excludes bayo boot knife due to type, includes shield
	var/list/ammo_list
	var/list/medical_list
	var/list/grenade_list
	var/list/engineering_list
	var/list/food_list
	//damage type specific item lists
	var/list/brute_list
	var/list/burn_list
	var/list/tox_list
	var/list/oxy_list
	var/list/clone_list
	var/list/pain_list

	var/list/eye_list
	var/list/brain_list
	var/list/ib_list
	var/list/organ_list
	var/list/infection_list

/datum/managed_inventory/New(mob/living/new_owner)
	. = ..()
	owner = new_owner

	RegisterSignal(owner, COMSIG_MOB_ITEM_EQUIPPED, PROC_REF(item_equipped))

	clear_lists()
	var/list/equip_list = list()
	for(var/slot AS in SLOT_ALL)
		equip_list |= owner.get_item_by_slot(slot)
	for(var/obj/item AS in equip_list)
		item_equipped(owner, item)

/datum/managed_inventory/Destroy(force, ...)
	owner = null
	clear_lists(TRUE)
	return ..()

///clears or resets the inventory lists
/datum/managed_inventory/proc/clear_lists(null_lists = FALSE)
	if(null_lists)
		QDEL_NULL(equipped_list)
		QDEL_NULL(gun_list)
		QDEL_NULL(melee_list)
		QDEL_NULL(ammo_list)
		QDEL_NULL(medical_list)
		QDEL_NULL(grenade_list)
		QDEL_NULL(engineering_list)
		QDEL_NULL(food_list)

		QDEL_NULL(brute_list)
		QDEL_NULL(burn_list)
		QDEL_NULL(tox_list)
		QDEL_NULL(oxy_list)
		QDEL_NULL(clone_list)
		QDEL_NULL(pain_list)

		QDEL_NULL(eye_list)
		QDEL_NULL(brain_list)
		QDEL_NULL(ib_list)
		QDEL_NULL(organ_list)
		QDEL_NULL(infection_list)
		return
	equipped_list = list()
	gun_list = list()
	melee_list = list()
	ammo_list = list()
	medical_list = list()
	grenade_list = list()
	engineering_list = list()
	food_list = list()

	brute_list = list()
	burn_list = list()
	tox_list = list()
	oxy_list = list()
	clone_list = list()
	pain_list = list()

	eye_list = list()
	brain_list = list()
	ib_list = list()
	organ_list = list()
	infection_list = list()

///Handles an item being equipped, and its contents
/datum/managed_inventory/proc/item_equipped(mob/user, obj/item/equipped_item)
	SIGNAL_HANDLER
	if(!equipped_item)
		return
	if(equipped_item in equipped_list)
		return
	equipped_list += equipped_item
	RegisterSignal(equipped_item, COMSIG_ITEM_REMOVED_INVENTORY, PROC_REF(item_unequipped))

	var/list/sort_list = list(equipped_item)
	sort_list += get_stored(equipped_item) //NOTE TO SELF:internal storage stuff isnt populated if the mob has ai BEFORE the outfit

	for(var/thing in sort_list)
		sort_item(thing)

///Recursive proc to retrieve all stored items inside something
/datum/managed_inventory/proc/get_stored(obj/item/thing)
	var/list/sort_list = list()
	if(thing.storage_datum)
		sort_list += thing.contents
	for(var/item in thing.contents)
		sort_list += get_stored(item)
	return sort_list

///Handles the removal of an item
/datum/managed_inventory/proc/item_unequipped(obj/item/unequipped_item, mob/user)
	SIGNAL_HANDLER
	UnregisterSignal(unequipped_item, COMSIG_ITEM_REMOVED_INVENTORY)
	equipped_list -= unequipped_item
	if(owner in get_nested_locs(unequipped_item))
		return //still equipped

	//generally we only care about items in actual storage, but some things (like gun mags) get 'stored' in things without storage datums - i.e. the gun on reload
	var/list/sort_list = unequipped_item.contents + unequipped_item
	sort_list |= get_stored(unequipped_item)

	for(var/obj/item/thing AS in sort_list)
		SEND_SIGNAL(thing, COMSIG_INVENTORY_STORED_REMOVAL)

///Wrapper for sorting a newly stored item
/datum/managed_inventory/proc/item_stored(mob/store_mob, obj/item/new_item, slot)
	SIGNAL_HANDLER
	sort_item(new_item)

///Sorts an item into any relevant lists
/datum/managed_inventory/proc/sort_item(obj/item/new_item)
	var/list/chosen_list = get_right_list(new_item)
	if(!chosen_list)
		return
	if(new_item in chosen_list)
		return //moved around on our mob

	RegisterSignal(new_item, COMSIG_ATOM_ENTERED, PROC_REF(item_stored))

	if(chosen_list == gun_list)
		gun_list_add(new_item)
	if(chosen_list == melee_list)
		melee_list_add(new_item)
	if(chosen_list == grenade_list)
		grenade_list_add(new_item)
	if(chosen_list == ammo_list)
		ammo_list_add(new_item)
	if(chosen_list == medical_list)
		medical_list_add(new_item)
	if(chosen_list == engineering_list)
		engineering_list_add(new_item)
	if(chosen_list == food_list)
		food_list_add(new_item)

///Finds the right list for an item
/datum/managed_inventory/proc/get_right_list(obj/item/new_item)
	if(isgun(new_item))
		return gun_list
	if((istype(new_item, /obj/item/weapon))) //todo: non weapon type weapons
		if(istype(new_item, /obj/item/weapon/twohanded/offhand))
			return
		return melee_list
	if(istype(new_item, /obj/item/explosive/grenade))
		if(istype(new_item, /obj/item/explosive/grenade/flare))
			return
		return grenade_list
	if(istype(new_item, /obj/item/ammo_magazine) || islascell(new_item))
		return ammo_list
	if(istool(new_item))
		return engineering_list
	if(isitemstack(new_item))
		if(istype(new_item, /obj/item/stack/medical))
			return medical_list
		if(istype(new_item, /obj/item/stack/sheet))
			return engineering_list
	if(isfood(new_item))
		return food_list
	if(iscell(new_item))
		return engineering_list
	if(isreagentcontainer(new_item) || istype(new_item, /obj/item/tweezers_advanced) || istype(new_item, /obj/item/tweezers) || istype(new_item, /obj/item/defibrillator))
		return medical_list

//boiler plate

///Adds an item to this list
/datum/managed_inventory/proc/gun_list_add(obj/item/new_item)
	if(new_item in gun_list)
		return
	//I feel like there was some dumb ass reason why I wasn't able to do this... but with testing it works fine??
	//might have been relevant for non weapons in storage?
	//keep an eye on this.
	gun_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(gun_list_removal))//COMSIG_MOVABLE_MOVED is sent AFTER COMSIG_ATOM_ENTERED.. this is fucking annoying but eh
	SEND_SIGNAL(src, COMSIG_INVENTORY_DAT_GUN_ADDED)

///Adds an item to this list
/datum/managed_inventory/proc/melee_list_add(obj/item/new_item)
	if(new_item in melee_list)
		return
	melee_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(melee_list_removal))
	SEND_SIGNAL(src, COMSIG_INVENTORY_DAT_MELEE_ADDED)

///Adds an item to the relevant med lists
/datum/managed_inventory/proc/medical_list_add(obj/item/new_item)
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
			if(EYE_DAMAGE)
				type_list = eye_list
			if(BRAIN_DAMAGE)
				type_list = brain_list
			if(INTERNAL_BLEEDING)
				type_list = ib_list
			if(ORGAN_DAMAGE)
				type_list = organ_list
			if(INFECTION)
				type_list = infection_list

		if(new_item in type_list) //we can just early return here, due to the signal issue mentioned above
			return

		type_list += new_item
		var/list/old_list = type_list.Copy()
		type_list.Cut()
		for(var/type in GLOB.ai_damtype_to_heal_list[damtype])
			for(var/obj/item/thing AS in old_list)
				if(thing.type == type)
					type_list += thing

	if(generic)
		medical_list |= new_item

///Adds an item to this list
/datum/managed_inventory/proc/ammo_list_add(obj/item/new_item)
	ammo_list |= new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(ammo_list_removal))

///Adds an item to this list
/datum/managed_inventory/proc/grenade_list_add(obj/item/new_item)
	grenade_list |= new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(grenade_list_removal))

///Adds an item to this list
/datum/managed_inventory/proc/engineering_list_add(obj/item/new_item)
	engineering_list |= new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(engineering_list_removal))

///Adds an item to this list
/datum/managed_inventory/proc/food_list_add(obj/item/new_item)
	food_list |= new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL), PROC_REF(food_list_removal))

///Removes an item from this list
/datum/managed_inventory/proc/gun_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && (owner in get_nested_locs(moving_item)))
		return //still in inventory
	gun_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL, COMSIG_ATOM_ENTERED))

///Removes an item from this list
/datum/managed_inventory/proc/melee_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && (owner in get_nested_locs(moving_item)))
		return //still in inventory
	melee_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL, COMSIG_ATOM_ENTERED))

///Removes an item from this list
/datum/managed_inventory/proc/medical_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && (owner in get_nested_locs(moving_item)))
		return //still in inventory
	medical_list -= moving_item
	brute_list -= moving_item
	burn_list -= moving_item
	tox_list -= moving_item
	oxy_list -= moving_item
	clone_list -= moving_item
	pain_list -= moving_item
	eye_list -= moving_item
	brain_list -= moving_item
	ib_list -= moving_item
	organ_list -= moving_item
	infection_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL, COMSIG_ATOM_ENTERED))

///Removes an item from this list
/datum/managed_inventory/proc/ammo_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && (owner in get_nested_locs(moving_item)))
		return //still in inventory
	ammo_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL, COMSIG_ATOM_ENTERED))

///Removes an item from this list
/datum/managed_inventory/proc/grenade_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && (owner in get_nested_locs(moving_item)))
		return //still in inventory
	grenade_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL, COMSIG_ATOM_ENTERED))

///Removes an item from this list
/datum/managed_inventory/proc/engineering_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && (owner in get_nested_locs(moving_item)))
		return //still in inventory
	engineering_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL, COMSIG_ATOM_ENTERED))

///Removes an item from this list
/datum/managed_inventory/proc/food_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	if(!QDELETED(moving_item) && (owner in get_nested_locs(moving_item)))
		return //still in inventory
	food_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING, COMSIG_INVENTORY_STORED_REMOVAL, COMSIG_ATOM_ENTERED))

///Returns a suitable tool from the inventory
/datum/managed_inventory/proc/find_tool(req_tool_behavior)
	var/obj/item/needed_tool
	for(var/obj/item/candidate_tool AS in engineering_list)
		if(candidate_tool.tool_behaviour == req_tool_behavior)
			needed_tool = candidate_tool
			break
	return needed_tool
