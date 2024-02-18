/datum/loadout_item/suit_store/main_gun/som_marine
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/suit_store/main_gun/som_marine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!ammo_type)
		return
	if(!istype(wearer.back, /obj/item/storage))
		return
	if(istype(wearer.belt, /obj/item/storage/holster/belt/pistol/m4a3/som)) //if we have a backpack and pistol belt, we just load more ammo in the back
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	else //else we put the sidearm in the bag
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/standard(wearer), SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle
	name = "V-31"
	desc = "Equipped with a red dot sight, extended barrel, vertical grip and integrated micro rail launcher. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	Uses 10x25mm caseless ammunition and 10 gauge micro grenades."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/standard
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/mpi_grenadier
	name = "MPi-KM"
	desc = "Equipped with a red dot sight and underbarrel grenade launcher. The MPi-KM is a modern reproduction based off several variants of kalashnikov type rifles used during the original Martian rebellion. \
	These weapons were already ancient at that time, and their continued use by the SOM speaks more to their cultural legacy than any tactical benefits. \
	Despite having relatively poor mobility and handling, it never the less has fearsome firepower and good capacity, ensuring it stays a relevant weapon choice for the SOM. Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/black/grenadier

/datum/loadout_item/suit_store/main_gun/som_marine/mpi_grenadier/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/carbine
	name = "V-34"
	desc = "Equipped with a red dot sight and foldable stock. The V-34 is a modern redesign of an ancient weapon that saw extensive use in the Martian uprising. \
	It combines good mobility and managable handling with fearsome stopping power and a tremendous rate of fire, making the V-34 an exceptionally deadly weapon at close range. \
	With poor falloff and accuracy, it is a poor weapon outside of close range, and its mobility lacks compared to some other close range weapons like the V-21. \
	Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/black/standard

/datum/loadout_item/suit_store/main_gun/som_marine/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/smg
	name = "V-21"
	desc = "Equipped with a motion sensor, recoil compensator and vertical grip. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	It uses 10x20mm caseless rounds."
	req_desc = "Requires M-11 scout armor."
	ui_icon = "smg"
	item_typepath = /obj/item/weapon/gun/smg/som/scout
	item_whitelist = list(
		/obj/item/clothing/suit/modular/som/light/shield = ITEM_SLOT_OCLOTHING,
		/obj/item/clothing/suit/modular/som/light/shield_overclocked = ITEM_SLOT_OCLOTHING,
	)

/datum/loadout_item/suit_store/main_gun/som_marine/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_shotgun
	name = "V-51"
	desc = "Equipped with a mag harness, bayonet and undebarrel flashlight. The V-51 is the main shotgun utilised by the Sons of Mars. \
	Semi automatic with great handling and mobility, it is less powerful than the SH-35 used by the TGMC, but makes up for it with a superior rate of fire. \
	Uses 12 gauge shells."
	req_desc = "Requires M-11 scout armor."
	ui_icon = "shotgun"
	item_typepath = /obj/item/weapon/gun/shotgun/som/standard
	item_whitelist = list(
		/obj/item/clothing/suit/modular/som/light/shield = ITEM_SLOT_OCLOTHING,
		/obj/item/clothing/suit/modular/som/light/shield_overclocked = ITEM_SLOT_OCLOTHING,
	)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/flamer
	name = "V-62 incinerator"
	desc = "Equipped with a mag harness and wide nozzle. The V-62 is a deadly weapon employed in close quarter combat, favoured as much for the terror it inspires as the actual damage it inflicts. \
	It has good range for a flamer, able to effortly clear out enclosed or defensive positions but lacks the integrated extinguisher of its TGMC equivalent."
	req_desc = "Requires M-31 combat armor with a Hades fireproof module."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/flamer/som/mag_harness
	item_whitelist = list(/obj/item/clothing/suit/modular/som/heavy/pyro = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/som_marine/flamer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/flamer/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som/extended, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield
	name = "V-21 & riot shield"
	desc = "Equipped with a red dot sight, recoil compensator and vertical grip, along with a S-144 boarding shield, intended for use with M-31 combat armor for boarding actions.. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	When used with the boarding shield, use of the higher rate of fire is highly unrecommended outside of anything but absolute point blank range. \
	It uses 10x20mm caseless rounds."
	ui_icon = "riot_shield"
	item_typepath = /obj/item/weapon/gun/smg/som/one_handed

/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/som, SLOT_L_HAND)
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	return ..() //we explicitly don't want a sidearm for this weapon choice

/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/machinegunner
	name = "V-41"
	desc = "Equipped with a red dot sight, extended barrel and bipod. The V-41 is a large man portable machine used by the SOM, allowing for sustained, accurate suppressive firepower at the cost of mobility and handling. \
	Commonly seen where their preferred tactics of fast, mobile aggression is ill suited. Has impressive ranged damage application as a static weapon. Uses 10x26mm Caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_mg/standard

/datum/loadout_item/suit_store/main_gun/som_marine/machinegunner/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/machinegunner/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger
	name = "VX-32 charger"
	desc = "Equipped with a mag harness. The VX-32 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has excellent mobility and handling and is best used at close range. Can be used one handed relatively effectively with sufficient skill. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-33."
	ui_icon = "volkite"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/magharness
	purchase_cost = 50
	quantity = 4

/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/boarding_axe
	name = "Boarding axe"
	desc = "A SOM boarding axe, a monstrous two handed weapon that inflicts terrible damage even through heavy armor. \
	When wielded it can be used to block as well as attack, and can also be used to force unpowered airlocks open. \
	You'll kill pretty much anything you can hit with this - providing you can get close enough to use it."
	req_desc = "Requires M-31 combat armor with a Lorica extra armor module."
	ui_icon = "axe"
	item_typepath = /obj/item/weapon/twohanded/fireaxe/som
	item_whitelist = list(/obj/item/clothing/suit/modular/som/heavy/lorica = ITEM_SLOT_OCLOTHING)
	item_blacklist = list(/obj/item/weapon/twohanded/fireaxe/som = ITEM_SLOT_BACK)
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/suit_store/boarding_axe/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

//Engineer
/datum/loadout_item/suit_store/main_gun/som_engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)

/datum/loadout_item/suit_store/main_gun/som_engineer/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle
	name = "V-31"
	desc = "Equipped with a red dot sight, extended barrel, vertical grip and integrated micro rail launcher. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	Uses 10x25mm caseless ammunition and 10 gauge micro grenades."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/standard
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_engineer/mpi
	name = "MPi-KM"
	desc = "Equipped with a mag harness and laser sight. The MPi-KM is a modern reproduction based off several variants of kalashnikov type rifles used during the original Martian rebellion. \
	These weapons were already ancient at that time, and their continued use by the SOM speaks more to their cultural legacy than any tactical benefits. \
	Despite having relatively poor mobility and handling, it never the less has fearsome firepower and good capacity, ensuring it stays a relevant weapon choice for the SOM. Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/black/magharness

/datum/loadout_item/suit_store/main_gun/som_engineer/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/carbine
	name = "V-34"
	desc = "Equipped with a red dot sight and foldable stock. The V-34 is a modern redesign of an ancient weapon that saw extensive use in the Martian uprising. \
	It combines good mobility and managable handling with fearsome stopping power and a tremendous rate of fire, making the V-34 an exceptionally deadly weapon at close range. \
	With poor falloff and accuracy, it is a poor weapon outside of close range, and its mobility lacks compared to some other close range weapons like the V-21. \
	Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/black/standard

/datum/loadout_item/suit_store/main_gun/som_engineer/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/smg
	name = "V-21"
	desc = "Equipped with a mag harness, recoil compensator and vertical grip. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	It uses 10x20mm caseless rounds."
	ui_icon = "smg"
	item_typepath = /obj/item/weapon/gun/smg/som/support

/datum/loadout_item/suit_store/main_gun/som_engineer/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_engineer/flechette_shotgun
	name = "V-51"
	desc = "Equipped with a mag harness and bayonet. The V-51 is the main shotgun utilised by the Sons of Mars. \
	Semi automatic with great handling and mobility, it is less powerful than the SH-35 used by the TGMC, but makes up for it with a superior rate of fire. \
	Uses 12 gauge shells."
	ui_icon = "shotgun"
	item_typepath = /obj/item/weapon/gun/shotgun/som/support

/datum/loadout_item/suit_store/main_gun/som_engineer/flechette_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/flechette_shotgun/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)

//Medic
/datum/loadout_item/suit_store/main_gun/som_medic
	jobs_supported = list(SOM_SQUAD_CORPSMAN)

/datum/loadout_item/suit_store/main_gun/som_medic/standard_rifle
	name = "V-31"
	desc = "Equipped with a red dot sight, extended barrel, vertical grip and integrated micro rail launcher. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	Uses 10x25mm caseless ammunition and 10 gauge micro grenades."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/standard
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_medic/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_medic/mpi
	name = "MPi-KM"
	desc = "Equipped with a mag harness and laser sight. The MPi-KM is a modern reproduction based off several variants of kalashnikov type rifles used during the original Martian rebellion. \
	These weapons were already ancient at that time, and their continued use by the SOM speaks more to their cultural legacy than any tactical benefits. \
	Despite having relatively poor mobility and handling, it never the less has fearsome firepower and good capacity, ensuring it stays a relevant weapon choice for the SOM. Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/black/magharness

/datum/loadout_item/suit_store/main_gun/som_medic/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_medic/carbine
	name = "V-34"
	desc = "Equipped with a red dot sight and foldable stock. The V-34 is a modern redesign of an ancient weapon that saw extensive use in the Martian uprising. \
	It combines good mobility and managable handling with fearsome stopping power and a tremendous rate of fire, making the V-34 an exceptionally deadly weapon at close range. \
	With poor falloff and accuracy, it is a poor weapon outside of close range, and its mobility lacks compared to some other close range weapons like the V-21. \
	Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/black/standard

/datum/loadout_item/suit_store/main_gun/som_medic/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/carbine/black, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_medic/smg
	name = "V-21"
	desc = "Equipped with a mag harness, recoil compensator and vertical grip. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	It uses 10x20mm caseless rounds."
	ui_icon = "smg"
	item_typepath = /obj/item/weapon/gun/smg/som/support

/datum/loadout_item/suit_store/main_gun/som_medic/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_medic/flechette_shotgun
	name = "V-51"
	desc = "Equipped with a mag harness and bayonet, and solely loaded with flechette rounds. The V-51 is the main shotgun utilised by the Sons of Mars. \
	Semi automatic with great handling and mobility, it is less powerful than the SH-35 used by the TGMC, but makes up for it with a superior rate of fire. \
	Uses 12 gauge shells."
	ui_icon = "shotgun"
	item_typepath = /obj/item/weapon/gun/shotgun/som/support

/datum/loadout_item/suit_store/main_gun/som_medic/flechette_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/oxycodone, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)

//Veteran
/datum/loadout_item/suit_store/main_gun/som_veteran
	jobs_supported = list(SOM_SQUAD_VETERAN)

/datum/loadout_item/suit_store/main_gun/som_veteran/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!ammo_type)
		return
	if(istype(wearer.back, /obj/item/storage))
		if(istype(wearer.belt, /obj/item/storage/holster/belt/pistol/m4a3/som)) //if we have a backpack and pistol belt, we just load more ammo in the back
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		else //else we put the sidearm in the bag
			wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/som/standard(wearer), SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/standard_rifle
	name = "V-31"
	desc = "Equipped with a red dot sight, extended barrel, vertical grip and integrated micro rail launcher. Also comes with light armor piercing ammunition. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	Uses 10x25mm caseless ammunition and 10 gauge micro grenades."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/veteran
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_veteran/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/standard_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/smg
	name = "V-21"
	desc = "Equipped with a red dot sight, recoil compensator and vertical grip, along with armor piercing ammunition. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	It uses 10x20mm caseless rounds."
	ui_icon = "smg"
	item_typepath = /obj/item/weapon/gun/smg/som/veteran

/datum/loadout_item/suit_store/main_gun/som_veteran/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/breacher
	name = "VX-32B charger"
	desc = "Equipped with a mag harness and gyroscopic stabiliser for effective one handed use, and comes with a S-144 boarding shield, intended for use with M-31 Lorica combat armor for boarding actions. \
	The VX-32 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has excellent mobility and handling and is best used at close range. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-33."
	ui_icon = "riot_shield"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	purchase_cost = 75

/datum/loadout_item/suit_store/main_gun/som_veteran/breacher/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/som, SLOT_L_HAND)
	if(istype(wearer.back, /obj/item/storage))
		return ..()

	wearer.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	return ..()

/datum/loadout_item/suit_store/main_gun/som_veteran/breacher/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_charger
	name = "VX-32 charger"
	desc = "Equipped with a motion sensor and gyroscopic stabiliser for effective one handed use. \
	The VX-32 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has excellent mobility and handling and is best used at close range. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-33."
	ui_icon = "volkite"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_charger/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_caliver
	name = "VX-33 caliver"
	desc = "Equipped with a red dot sight and laser sight. \
	The VX-33 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has middling mobility and handling, it is a long range rifle analogue, able to project strong damage even at long ranges. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-32, and can also be linked to a volkite powerpack."
	ui_icon = "volkite"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/standard

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_caliver/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_caliver/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/mpi
	name = "MPi-KM"
	desc = "Equipped with a mag harness and underbarrel grenade launcher. This MPi-KM is an original example of one of several variants of kalashnikov type rifles used during the original Martian rebellion. \
	Passed down the generations and lovingly maintained as a family heirloom, \
	its use on modern battlefields is an idiosyncratic example of the SOM's persistant desire to maintain a link to their cultural past, more than any possible tactical reason. \
	Despite having relatively poor mobility and handling, it never the less has fearsome firepower and good capacity, ensuring it stays a relevant weapon choice for the SOM. Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/grenadier

/datum/loadout_item/suit_store/main_gun/som_veteran/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/carbine
	name = "V-34"
	desc = "Equipped with a mag harness and foldable stock. This V-34 is refurbished and well maintained weapon passed down from its use during the original Martian rebellion, \
	more family heirloom than a battlefield weapon, it serves just as well regardless. \
	It combines good mobility and managable handling with fearsome stopping power and a tremendous rate of fire, making the V-34 an exceptionally deadly weapon at close range. \
	With poor falloff and accuracy, it is a poor weapon outside of close range, and its mobility lacks compared to some other close range weapons like the V-21. \
	Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/mag_harness

/datum/loadout_item/suit_store/main_gun/som_veteran/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_caliver_pack
	name = "VX-33P Caliver"
	desc = "Equipped with a motion sensor and laser sight, this one is intended to be used with a back worm powerpack. \
	The VX-33 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has middling mobility and handling, it is a long range rifle analogue, able to project strong damage even at long ranges. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-32, and can also be linked to a volkite powerpack."
	req_desc = "Requires a volkite powerback."
	ui_icon = "volkite"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor
	quantity = 2
	purchase_cost = 75
	item_whitelist = list(/obj/item/cell/lasgun/volkite/powerpack = ITEM_SLOT_BACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_caliver_pack/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	if(istype(wearer.belt, /obj/item/weapon/gun/shotgun/double/sawn))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	else
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_culverin
	name = "VX-42 culverin"
	desc = "Equipped with a mag harness. \
	The VX-42 is a massive and terrifying energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	It has poor mobility and handling and is somewhat inaccurate at range, especially on the move. Despite this, the VX-42 can unleash a blistering amount of firepower, making it one of the most feared weapons in the SOM arsenal. \
	Targets at close range are torn apart, and its high rate of fire more than makes up for its somewhat poor long range accuracy. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	It must be linked to a volkite powerpack, allowing for sustained fire, although its energy demands can quickly drain even the powerpack, leaving a trigger happy operate vulnerable while it recharges."
	req_desc = "Requires a volkite powerback to operate."
	ui_icon = "volkite"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	quantity = 2
	purchase_cost = 150
	item_whitelist = list(/obj/item/cell/lasgun/volkite/powerpack = ITEM_SLOT_BACK)

/datum/loadout_item/suit_store/main_gun/som_veteran/volkite_culverin/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	if(istype(wearer.belt, /obj/item/weapon/gun/shotgun/double/sawn))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	else
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_veteran/radioactive_smg
	name = "V-21R"
	desc = "Equipped with a red dot sight, recoil compensator and vertical grip, along with radioactive and incendiary ammunition. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	It uses 10x20mm caseless rounds."
	req_desc = "Requires a suit with a Mithridatius environmental protection module."
	ui_icon = "smg"
	item_typepath = /obj/item/weapon/gun/smg/som/support
	item_whitelist = list(/obj/item/clothing/suit/modular/som/heavy/mithridatius = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/som_veteran/radioactive_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

	if(istype(wearer.belt, /obj/item/storage/belt))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som, SLOT_IN_BELT)
	if(istype(wearer.l_store, /obj/item/storage/pouch/magazine))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
	if(istype(wearer.r_store, /obj/item/storage/pouch/magazine))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/rad, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/rad, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/energy_sword
	name = "Energy sword"
	desc = "A SOM energy sword. Designed to cut through armored plate. An uncommon primary weapon, typically seen wielded by so called 'blink assault' troops. \
	Can be used defensively to great effect, mainly against opponents trying to strike you in melee, although some users report varying levels of success in blocking ranged projectiles."
	ui_icon = "machete"
	item_typepath = /obj/item/weapon/energy/sword/som
	jobs_supported = list(SOM_SQUAD_VETERAN)

/datum/loadout_item/suit_store/energy_sword/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)

//Squad leader
/datum/loadout_item/suit_store/main_gun/som_squad_leader
	jobs_supported = list(SOM_SQUAD_LEADER)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!ammo_type)
		return
	if(istype(wearer.back, /obj/item/storage))
		if(istype(wearer.belt, /obj/item/storage/holster/belt/pistol/m4a3/som)) //if we have a backpack and pistol belt, we just load more ammo in the back
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		else //else we put the sidearm in the bag
			wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta(wearer), SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/standard_rifle
	name = "V-31"
	desc = "Equipped with a red dot sight, extended barrel, vertical grip and integrated micro rail launcher. Also comes with light armor piercing ammunition. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	Uses 10x25mm caseless ammunition and 10 gauge micro grenades."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/veteran
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_squad_leader/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/smg
	name = "V-21"
	desc = "Equipped with a red dot sight, recoil compensator and vertical grip, along with armor piercing ammunition. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	It uses 10x20mm caseless rounds."
	ui_icon = "smg"
	item_typepath = /obj/item/weapon/gun/smg/som/veteran

/datum/loadout_item/suit_store/main_gun/som_squad_leader/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_charger
	name = "VX-32 charger"
	desc = "Equipped with a motion sensor and gyroscopic stabiliser for effective one handed use. \
	The VX-32 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has excellent mobility and handling and is best used at close range. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-33."
	ui_icon = "volkite"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_caliver
	name = "VX-33 caliver"
	desc = "Equipped with a motion sensor and laser sight. \
	The VX-33 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has middling mobility and handling, it is a long range rifle analogue, able to project strong damage even at long ranges. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-32, and can also be linked to a volkite powerpack."
	ui_icon = "volkite"
	purchase_cost = 50
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_caliver/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/mpi
	name = "MPi-KM"
	desc = "Equipped with a mag harness and underbarrel grenade launcher. This MPi-KM is an original example of one of several variants of kalashnikov type rifles used during the original Martian rebellion. \
	Passed down the generations and lovingly maintained as a family heirloom, \
	its use on modern battlefields is an idiosyncratic example of the SOM's persistant desire to maintain a link to their cultural past, more than any possible tactical reason. \
	Despite having relatively poor mobility and handling, it never the less has fearsome firepower and good capacity, ensuring it stays a relevant weapon choice for the SOM. Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/grenadier

/datum/loadout_item/suit_store/main_gun/som_squad_leader/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/carbine
	name = "V-34"
	desc = "Equipped with a mag harness and foldable stock. This V-34 is refurbished and well maintained weapon passed down from its use during the original Martian rebellion, \
	more family heirloom than a battlefield weapon, it serves just as well regardless. \
	It combines good mobility and managable handling with fearsome stopping power and a tremendous rate of fire, making the V-34 an exceptionally deadly weapon at close range. \
	With poor falloff and accuracy, it is a poor weapon outside of close range, and its mobility lacks compared to some other close range weapons like the V-21. \
	Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/mag_harness

/datum/loadout_item/suit_store/main_gun/som_squad_leader/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

//Field commander
/datum/loadout_item/suit_store/main_gun/som_field_commander
	jobs_supported = list(SOM_FIELD_COMMANDER)

/datum/loadout_item/suit_store/main_gun/som_field_commander/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!ammo_type)
		return
	if(istype(wearer.back, /obj/item/storage))
		if(istype(wearer.belt, /obj/item/storage/holster/belt/pistol/m4a3/som)) //if we have a backpack and pistol belt, we just load more ammo in the back
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		else //else we put the sidearm in the bag
			wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
			wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta/custom(wearer), SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_field_commander/standard_rifle
	name = "V-31"
	desc = "Equipped with a red dot sight, extended barrel, vertical grip and integrated micro rail launcher. Also comes with light armor piercing ammunition. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	Uses 10x25mm caseless ammunition and 10 gauge micro grenades."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som/veteran
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_field_commander/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/smg
	name = "V-21"
	desc = "Equipped with a red dot sight, recoil compensator and vertical grip, along with armor piercing ammunition. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	It uses 10x20mm caseless rounds."
	ui_icon = "smg"
	item_typepath = /obj/item/weapon/gun/smg/som/veteran

/datum/loadout_item/suit_store/main_gun/som_field_commander/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/volkite_charger
	name = "VX-32 charger"
	desc = "Equipped with a motion sensor and gyroscopic stabiliser for effective one handed use. \
	The VX-32 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has excellent mobility and handling and is best used at close range. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-33."
	ui_icon = "volkite"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout

/datum/loadout_item/suit_store/main_gun/som_field_commander/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/volkite_caliver
	name = "VX-33 caliver"
	desc = "Equipped with a red dot sight and laser sight. \
	The VX-33 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has middling mobility and handling, it is a long range rifle analogue, able to project strong damage even at long ranges. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-32, and can also be linked to a volkite powerpack."
	ui_icon = "volkite"
	purchase_cost = 50
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor

/datum/loadout_item/suit_store/main_gun/som_field_commander/volkite_caliver/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/mpi
	name = "MPi-KM"
	desc = "Equipped with a mag harness and underbarrel grenade launcher. This MPi-KM is an original example of one of several variants of kalashnikov type rifles used during the original Martian rebellion. \
	Passed down the generations and lovingly maintained as a family heirloom, \
	its use on modern battlefields is an idiosyncratic example of the SOM's persistant desire to maintain a link to their cultural past, more than any possible tactical reason. \
	Despite having relatively poor mobility and handling, it never the less has fearsome firepower and good capacity, ensuring it stays a relevant weapon choice for the SOM. Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/grenadier

/datum/loadout_item/suit_store/main_gun/som_field_commander/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_field_commander/carbine
	name = "V-34"
	desc = "Equipped with a mag harness and foldable stock. This V-34 is refurbished and well maintained weapon passed down from its use during the original Martian rebellion, \
	more family heirloom than a battlefield weapon, it serves just as well regardless. \
	It combines good mobility and managable handling with fearsome stopping power and a tremendous rate of fire, making the V-34 an exceptionally deadly weapon at close range. \
	With poor falloff and accuracy, it is a poor weapon outside of close range, and its mobility lacks compared to some other close range weapons like the V-21. \
	Uses 7.62x39mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/mag_harness

/datum/loadout_item/suit_store/main_gun/som_field_commander/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/fc_boarding_axe
	name = "Boarding axe"
	desc = "A SOM boarding axe, a monstrous two handed weapon that inflicts terrible damage even through heavy armor. \
	When wielded it can be used to block as well as attack, and can also be used to force unpowered airlocks open. \
	You'll kill pretty much anything you can hit with this - providing you can get close enough to use it."
	ui_icon = "axe"
	item_typepath = /obj/item/weapon/twohanded/fireaxe/som
	item_blacklist = list(/obj/item/weapon/twohanded/fireaxe/som = ITEM_SLOT_BACK)
	jobs_supported = list(SOM_FIELD_COMMANDER)

/datum/loadout_item/suit_store/fc_boarding_axe/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign/som, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return
	if(istype(wearer.belt, /obj/item/storage/holster/belt/pistol/m4a3/som))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	else
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/small, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta/custom(wearer), SLOT_IN_BACKPACK)

	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
