/datum/loadout_item/back
	item_slot = ITEM_SLOT_BACK

/datum/loadout_item/back/empty
	name = "no backpack"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/back/marine_satchel
	name = "Satchel"
	desc = "A heavy-duty satchel carried by some TGMC soldiers and support personnel. Carries less than a backpack, but items can be drawn instantly."
	item_typepath = /obj/item/storage/backpack/marine/satchel
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/back/marine_backpack
	name = "Backpack"
	desc = "The standard-issue pack of the TGMC forces. Designed to slug gear into the battlefield. Carries more than a satchel but has a draw delay."
	item_typepath = /obj/item/storage/backpack/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/back/flamer_tank
	name = "Flame tank"
	desc = "A specialized fuel tank for use with the FL-84 flamethrower and FL-240 incinerator unit."
	req_desc = "Requires a FL-84 flamethrower."
	item_typepath = /obj/item/ammo_magazine/flamer_tank/backtank
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(/obj/item/weapon/gun/flamer/big_flamer/marinestandard/wide = ITEM_SLOT_SUITSTORE)

/datum/loadout_item/back/jetpack
	name = "Heavy jetpack"
	desc = "An upgraded jetpack with enough fuel to send a person flying for a short while with extreme force. \
	It provides better mobility for heavy users and enough thrust to be used in an aggressive manner. \
	Alt right click or middleclick to fly to a destination when the jetpack is equipped. Will collide with hostiles"
	req_desc = "Requires a SMG-25 or ALF-51B."
	item_typepath = /obj/item/jetpack_marine/heavy
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(
		/obj/item/weapon/gun/smg/m25/magharness = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/rifle/alf_machinecarbine/assault = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/back/corpsman_satchel
	name = "Medical satchel"
	desc = "A heavy-duty satchel carried by some TGMC corpsmen. You can recharge defibrillators by plugging them in. Carries less than a backpack, but items can be drawn instantly."
	item_typepath = /obj/item/storage/backpack/marine/corpsman/satchel
	jobs_supported = list(SQUAD_CORPSMAN)

/datum/loadout_item/back/corpsman_backpack
	name = "Medical backpack"
	desc = "The standard-issue backpack worn by TGMC corpsmen. You can recharge defibrillators by plugging them in. Carries more than a satchel but has a draw delay."
	item_typepath = /obj/item/storage/backpack/marine/corpsman
	jobs_supported = list(SQUAD_CORPSMAN)
