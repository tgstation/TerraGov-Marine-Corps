/datum/loadout_item/secondary
	item_slot = ITEM_SLOT_SECONDARY
	item_whitelist = list(
		/obj/item/storage/backpack/marine/satchel = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/lightpack = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/engineerpack = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/tech = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/corpsman = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/satchel/som = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/lightpack/som = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/engineerpack/som = ITEM_SLOT_BACK,
	)
	req_desc = "Requires some kind of back storage."

//Default bag items if we don't need to spawn anything specific to the main secondary item
/datum/loadout_item/secondary/proc/default_load(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	var/datum/loadout_item/suit_store/main_gun/primary = holder.equipped_things["[ITEM_SLOT_SUITSTORE]"]
	if(istype(primary))
		wearer.equip_to_slot_or_del(new primary.ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new primary.secondary_ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
		return

	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	switch(wearer.faction)
		if(FACTION_SOM)
			wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		else
			wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/empty
	name = "None"
	desc = "Nothing. Nadda."
	ui_icon = "empty"
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	req_desc = null
	item_whitelist = null
	jobs_supported = list(
		SQUAD_MARINE,
		SQUAD_CORPSMAN,
		SQUAD_ENGINEER,
		SQUAD_SMARTGUNNER,
		SQUAD_LEADER,
		FIELD_COMMANDER,
		STAFF_OFFICER,
		CAPTAIN,
		SOM_SQUAD_MARINE,
		SOM_SQUAD_CORPSMAN,
		SOM_SQUAD_ENGINEER,
		SOM_SQUAD_VETERAN,
		SOM_SQUAD_LEADER,
		SOM_FIELD_COMMANDER,
		SOM_STAFF_OFFICER,
		SOM_COMMANDER,
	)


/datum/loadout_item/secondary/gun
	///Ammo type this gun will use
	var/obj/item/secondary_weapon_ammo

/datum/loadout_item/secondary/gun/New()
	. = ..()
	if(secondary_weapon_ammo)
		return
	var/obj/item/weapon/gun/weapon_type = item_typepath
	secondary_weapon_ammo = weapon_type::default_ammo_type

/datum/loadout_item/secondary/gun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	var/gun_spawned = FALSE
	var/ammo_spawned = FALSE

	if(isholster(wearer.belt))
		var/obj/item/storage/holster/holster = wearer.belt
		wearer.equip_to_slot_or_del(new item_typepath(wearer), SLOT_IN_HOLSTER)
		gun_spawned = TRUE
		for(var/i = 1 to holster.storage_datum.max_storage_space)
			if(!wearer.equip_to_slot_or_del(new secondary_weapon_ammo, SLOT_IN_HOLSTER))
				break
			ammo_spawned = TRUE

	if(!isstorageobj(wearer.back))
		return

	if(!gun_spawned)
		wearer.equip_to_slot_or_del(new item_typepath(wearer), SLOT_IN_BACKPACK)

	if(ammo_spawned)
		default_load(wearer, loadout, holder)
	for(var/i = 1 to 10)
		if(!wearer.equip_to_slot_or_del(new secondary_weapon_ammo, SLOT_IN_BACKPACK))
			break
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK) //because secondary fills last, there should only be space if secondary ammo is w_class 3, or the loadout naturally has spare space
