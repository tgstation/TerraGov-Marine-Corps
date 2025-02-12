
#define COMSIG_MOB_ITEM_EQUIPPED "mob_item_equipped"
#define COMSIG_MOB_ITEM_UNEQUIPPED "mob_item_unequipped"

/datum/component/inventory
	var/mob/living/owner

	var/list/equipped_list //matter?

	var/list/gun_list
	var/list/melee_list
	var/list/ammo_list
	var/list/medical_list
	var/list/grenade_list
	var/list/engineering_list

/datum/component/inventory/Initialize(...)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent

	RegisterSignal(owner, COMSIG_MOB_ITEM_EQUIPPED, PROC_REF(item_equipped))
	set_lists()

/datum/component/inventory/Destroy(force, ...)
	owner = null
	clear_lists(TRUE)
	return ..()

/datum/component/inventory/proc/clear_lists(null_lists = FALSE)
	if(null_lists)
		QDEL_NULL(gun_list)
		QDEL_NULL(melee_list)
		QDEL_NULL(ammo_list)
		QDEL_NULL(medical_list)
		QDEL_NULL(grenade_list)
		QDEL_NULL(engineering_list)
		return
	gun_list = list()
	melee_list = list()
	ammo_list = list()
	medical_list = list()
	grenade_list = list()
	engineering_list = list()

/datum/component/inventory/proc/set_lists()
	clear_lists()
	var/equipped_list = list()
	for(var/slot AS in SLOT_ALL)
		equipped_list |= owner.get_item_by_slot(slot)
	for(var/obj/item AS in equipped_list)
		item_equipped(owner, item)

/datum/component/inventory/proc/item_equipped(mob/user, obj/item/equipped_item)
	SIGNAL_HANDLER
	if(!equipped_item)
		return
	RegisterSignal(equipped_item, COMSIG_ATOM_ENTERED, PROC_REF(item_stored))
	RegisterSignal(equipped_item, COMSIG_MOB_ITEM_UNEQUIPPED, PROC_REF(item_unequipped))
	sort_item(equipped_item)
	if(equipped_item.storage_datum)
		for(var/obj/item AS in equipped_item.contents)
			sort_item(item)

/datum/component/inventory/proc/item_unequipped(mob/user, obj/item/unequipped_item)
	SIGNAL_HANDLER
	UnregisterSignal(unequipped_item, list(COMSIG_ATOM_ENTERED, COMSIG_MOB_ITEM_UNEQUIPPED))

/datum/component/inventory/proc/item_stored(mob/store_mob, obj/item/new_item, slot)
	SIGNAL_HANDLER
	sort_item(new_item)

/datum/component/inventory/proc/sort_item(obj/item/new_item)
	if(isgun(new_item))
		gun_list_add(new_item)
		return
	if(istype(new_item, /obj/item/weapon))
		melee_list_add(new_item)
		return
	if(istype(new_item, /obj/item/explosive/grenade))
		grenade_list_add(new_item)
		return
	if(istype(item, /obj/item/ammo_magazine) || istype(item, /obj/item/cell/lasgun))
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
/datum/component/inventory/proc/gun_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	gun_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(gun_list_removal))

///Adds an item to this list
/datum/component/inventory/proc/melee_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	melee_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(melee_list_removal))

///Adds an item to this list
/datum/component/inventory/proc/medical_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	medical_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(medical_list_removal))

///Adds an item to this list
/datum/component/inventory/proc/ammo_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	ammo_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(ammo_list_removal))

///Adds an item to this list
/datum/component/inventory/proc/grenade_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	grenade_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(grenade_list_removal))

///Adds an item to this list
/datum/component/inventory/proc/engineering_list_add(obj/item/new_item)
	SIGNAL_HANDLER
	engineering_list += new_item
	RegisterSignals(new_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING), PROC_REF(engineering_list_removal))

///Removes an item from this list
/datum/component/inventory/proc/gun_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	gun_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

///Removes an item from this list
/datum/component/inventory/proc/melee_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	melee_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

///Removes an item from this list
/datum/component/inventory/proc/medical_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	medical_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

///Removes an item from this list
/datum/component/inventory/proc/ammo_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	ammo_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

///Removes an item from this list
/datum/component/inventory/proc/grenade_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	grenade_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))

///Removes an item from this list
/datum/component/inventory/proc/engineering_list_removal(obj/item/moving_item)
	SIGNAL_HANDLER
	engineering_list -= moving_item
	UnregisterSignal(moving_item, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))


