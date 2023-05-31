///Component for making something capable of tactical reload via right click.
/datum/component/tac_reload_storage
	///The storage item that we are attempting to use to tactical reload on.
	///Use this over checking the item directly, for edge cases such as indirect storage (e.g: storage armor module).
	var/obj/item/storage/reloading_storage

/datum/component/tac_reload_storage/Initialize()
	if(!isstorage(parent) && !istype(parent, /obj/item/armor_module/storage))
		return COMPONENT_INCOMPATIBLE

/datum/component/tac_reload_storage/Destroy(force, silent)
	reloading_storage = null
	return ..()

/datum/component/tac_reload_storage/RegisterWithParent()
	if(istype(parent, /obj/item/armor_module/storage))
		RegisterSignal(parent, COMSIG_ATTACHMENT_ATTACHED, PROC_REF(on_suit_attach))
		RegisterSignal(parent, COMSIG_ATTACHMENT_DETACHED, PROC_REF(on_suit_detach))
	else
		reloading_storage = parent
		RegisterSignal(parent, COMSIG_PARENT_ATTACKBY_ALTERNATE, PROC_REF(on_parent_attackby_alternate))
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/tac_reload_storage/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATTACHMENT_ATTACHED,
		COMSIG_ATTACHMENT_DETACHED,
		COMSIG_PARENT_ATTACKBY_ALTERNATE,
		COMSIG_PARENT_EXAMINE,
	))

///Hook into the examine of the parent to show the player that they can tac reload from this
/datum/component/tac_reload_storage/proc/on_examine(datum/source, mob/user, list/details)
	SIGNAL_HANDLER
	details += span_notice("To perform a reload with the ammunition inside, right click on the belt with any compatible gun.")

/**
 * When attacked by a gun, will attempt to tactical reload it from our set reloading storage.
 * Args:
 * - source: The storage item source or armor suit. Use reloading_storage instead as it takes into account remote storage.
 * - reloading_gun: The gun item that's attacking parent, that we want to reload.
 * - user: The person attempting to reload the gun
 * - params: The params (distance, etc.)
 */
/datum/component/tac_reload_storage/proc/on_parent_attackby_alternate(datum/source, obj/item/weapon/gun/reloading_gun, mob/user, params)
	SIGNAL_HANDLER
	if(!istype(reloading_gun))
		return
	if(!reloading_storage)
		CRASH("[user] attempted to reload [reloading_gun] on [source], but it has no storage attached!")
	INVOKE_ASYNC(src, PROC_REF(do_tac_reload), reloading_gun, user, params)

///Performs the tactical reload
/datum/component/tac_reload_storage/proc/do_tac_reload(obj/item/weapon/gun/reloading_gun, mob/user, params)
	for(var/obj/item/item_to_reload_with in reloading_storage.contents)
		if(!(item_to_reload_with.type in reloading_gun.allowed_ammo_types))
			continue
		if(user.get_active_held_item(reloading_gun))
			reloading_gun.tactical_reload(item_to_reload_with, user)
			reloading_storage.orient2hud()
		return COMPONENT_NO_AFTERATTACK

/**
 * Called when parent (a storage armor module) is attached to any suit
 * Sent by attachment_handler component.
 * Args:
 * source - The storage armor module that's being attached.
 * new_shot - The clothing that the module is being attached to.
 * attacher - The person attaching the armor module to the suit.
 */
/datum/component/tac_reload_storage/proc/on_suit_attach(obj/item/armor_module/storage/source, obj/item/clothing/new_host, mob/attacher)
	SIGNAL_HANDLER
	reloading_storage = source.storage
	RegisterSignal(new_host, COMSIG_PARENT_ATTACKBY_ALTERNATE, PROC_REF(on_parent_attackby_alternate))
	RegisterSignal(new_host, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/**
 * Called when parent (a storage armor module) is detached from any suit
 * Sent by attachment_handler component.
 * Args:
 * source - The storage armor module that's being detached.
 * old_host - The clothing that the module is being detached from.
 * attacher - The person detaching the armor module from the suit.
 */
/datum/component/tac_reload_storage/proc/on_suit_detach(obj/item/armor_module/storage/source, obj/item/clothing/old_host, mob/attacher)
	SIGNAL_HANDLER
	reloading_storage = null
	UnregisterSignal(old_host, list(
		COMSIG_PARENT_ATTACKBY_ALTERNATE,
		COMSIG_PARENT_EXAMINE,
	))
