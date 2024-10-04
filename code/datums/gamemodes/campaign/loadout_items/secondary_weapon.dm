#define MARINE_STANDARD_SECONDARY_AMMO_SPACE 4

/datum/loadout_item/secondary_weapon
	item_slot = ITEM_SLOT_SECONDARY
	item_whitelist = list(
		/obj/item/storage/backpack/marine/satchel = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/lightpack = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/engineerpack = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/tech = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine/corpsman = ITEM_SLOT_BACK,
	)

/datum/loadout_item/secondary_weapon/empty
	name = "None"
	desc = "Nothing. Nadda."
	ui_icon = "empty"
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
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


/datum/loadout_item/secondary_weapon/gun
	///Ammo type this gun will use
	var/obj/item/secondary_weapon_ammo

/datum/loadout_item/secondary_weapon/gun/New()
	. = ..()
	if(secondary_weapon_ammo)
		return
	var/obj/item/weapon/gun/weapon_type = item_typepath
	secondary_weapon_ammo = weapon_type::default_ammo_type

/datum/loadout_item/secondary_weapon/gun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	var/gun_spawned = FALSE
	var/ammo_spawned = FALSE

	if(isholster(wearer.belt)) //curently fails with machete belts, gotta decide what to do with them
		var/obj/item/storage/holster/holster = wearer.belt
		wearer.equip_to_slot_or_del(new item_typepath(wearer), SLOT_IN_HOLSTER)
		gun_spawned = TRUE
		for(var/i = 1 to holster.storage_datum.max_storage_space)
			if(!wearer.equip_to_slot_or_del(new secondary_weapon_ammo, SLOT_IN_HOLSTER))
				break
			ammo_spawned = TRUE

	if(!isstorageobj(wearer.back))
		return //maybe pocket/other storage in the future, for now just back

	if(!gun_spawned)
		wearer.equip_to_slot_or_del(new item_typepath(wearer), SLOT_IN_BACKPACK)
	if(ammo_spawned) //insert other shit instead of secondary ammo
		if(isgun(wearer.s_store)) //extremely fucked, but works for now. if the outfit_holder is an arg, we can just ref the ammo directly though
			var/obj/item/weapon/gun/main_gun = wearer.s_store
			wearer.equip_to_slot_or_del(new main_gun.default_ammo_type, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new main_gun.default_ammo_type, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
		//else
			//spawn other shit? This probably shouldn't happen unless the player is cracked
		return

	//if we place it under primary weapons, we should be able to assume its safely later in the list, thus post equip happens after primary weapon post equip, so we can just fill space instead of using the define
	for(var/i = 1 to 10) //placeholder number, we just want to fill basically.
		if(!wearer.equip_to_slot_or_del(new secondary_weapon_ammo, SLOT_IN_BACKPACK))
			break
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK) //because secondary fills last, there should only be space if secondary ammo is w_class 3, or the loadout naturally has spare space
