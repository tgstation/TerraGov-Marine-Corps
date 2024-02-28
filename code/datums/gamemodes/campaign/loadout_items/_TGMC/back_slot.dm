/datum/loadout_item/back
	item_slot = ITEM_SLOT_BACK

/datum/loadout_item/back/empty
	name = "no backpack"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
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

/datum/loadout_item/back/marine_satchel
	name = "Satchel"
	desc = "A heavy-duty satchel carried by some TGMC soldiers and support personnel. Carries less than a backpack, but items can be drawn instantly."
	item_typepath = /obj/item/storage/backpack/marine/satchel
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, STAFF_OFFICER, CAPTAIN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/back/marine_backpack
	name = "Backpack"
	desc = "The standard-issue pack of the TGMC forces. Designed to slug gear into the battlefield. Carries more than a satchel but has a draw delay."
	item_typepath = /obj/item/storage/backpack/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER)

/datum/loadout_item/back/combat_pack
	name = "Combat pack"
	desc = "A small lightweight pack for expeditions and short-range operations. Has the storage capacity of a backpack but no draw delay."
	purchase_cost = 25
	item_typepath = /obj/item/storage/backpack/lightpack
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER)

/datum/loadout_item/back/combat_pack/free
	purchase_cost = 0
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/back/flamer_tank
	name = "Flame tank"
	desc = "A specialized fuel tank for use with the FL-84 flamethrower and FL-240 incinerator unit."
	req_desc = "Requires a FL-84 flamethrower."
	item_typepath = /obj/item/ammo_magazine/flamer_tank/backtank
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(/obj/item/weapon/gun/flamer/big_flamer/marinestandard/wide = ITEM_SLOT_SUITSTORE)

/datum/loadout_item/back/flamer_tank/x_fuel
	name = "X-fuel tank"
	desc = "A specialized fuel tank of ultra thick napthal type X, known for its extreme heat and slow burn rate, as well as it's distinct blue flames. For use with the FL-84 flamethrower and FL-240 incinerator unit."
	item_typepath = /obj/item/ammo_magazine/flamer_tank/backtank/X
	purchase_cost = 25
	unlock_cost = 200
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

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

//special unlockable
/datum/loadout_item/back/marine_shotgun
	name = "SH-35"
	desc = "Equipped with a mag harness, bayonet, angled grip and foldable stock. \
	The SH-35 is the most commonly used shotgun of the TGMC. With good mobility and handling, it has unparalleled close range power when using buckshot. Able to kill or maim all but the most heavily armored targets with a single well aimmed blast. \
	When using flechette rounds, it can provide surprisingly powerful long range damage with good penetration, although its low rate of fire means its sustained damage is relatively poor. \
	Uses 12 gauge shells."
	ui_icon = "shotgun"
	purchase_cost = 25
	item_typepath = /obj/item/weapon/gun/shotgun/pump/t35/standard
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER)
	loadout_item_flags = NONE

/datum/loadout_item/back/marine_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/shotgun/buckshot, SLOT_R_HAND)

/datum/loadout_item/back/machete
	name = "Machete"
	desc = "A large leather scabbard carrying a M2132 machete. It can be strapped to the back, waist or armor. Extremely dangerous against human opponents - if you can get close enough."
	ui_icon = "machete"
	item_typepath = /obj/item/storage/holster/blade/machete/full
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER)
	loadout_item_flags = NONE

//corpsman
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
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

//engineer
/datum/loadout_item/back/engineerpack
	name = "Sentry welderpack"
	desc = "A specialized backpack worn by TGMC technicians. It carries a fueltank for quick welder refueling. Loaded with 2 point defense sentries, excellent for defending areas or establishing killboxes."
	item_typepath = /obj/item/storage/backpack/marine/engineerpack
	jobs_supported = list(SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/back/engineerpack/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/sentry/mini/combat_patrol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/sentry/mini/combat_patrol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/minisentry, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/minisentry, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)

/datum/loadout_item/back/tgmc_rocket_bag
	name = "Rocket bag"
	desc = "This backpack holds 4 67mm shells, in addition to a recoiless rifle. \
	A powerful ranged weapon with a wide area of effect, the recoiless rifle is a powerful support weapon that can severely wound whole groups of opponents in a single shot. Has a draw delay."
	purchase_cost = 100
	quantity = 2
	item_typepath = /obj/item/storage/holster/backholster/rpg/low_impact
	jobs_supported = list(SQUAD_ENGINEER)

/datum/loadout_item/back/tech_backpack
	name = "Demolition backpack"
	desc = "The standard-issue backpack worn by TGMC technicians. Filled with a tremendous amount of detpacks, C4, claymores and grenades. Has a draw delay."
	item_typepath = /obj/item/storage/backpack/marine/tech
	jobs_supported = list(SQUAD_ENGINEER)

/datum/loadout_item/back/tech_backpack/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/minelayer, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)

//smartgunner
/datum/loadout_item/back/sg_minigun_powerpack
	name = "SG-85 powerpack"
	desc = "A reinforced backpack heavy with the IFF altered ammunition, onboard micro generator, and extensive cooling system which enables the SG-85 gatling gun to operate. \
	Use the SG-85 on the backpack itself to connect them."
	req_desc = "Requires an SG-85."
	item_typepath = /obj/item/ammo_magazine/minigun_powerpack/smartgun
	jobs_supported = list(SQUAD_SMARTGUNNER)
	item_whitelist = list(/obj/item/weapon/gun/minigun/smart_minigun/motion_detector = ITEM_SLOT_SUITSTORE)
