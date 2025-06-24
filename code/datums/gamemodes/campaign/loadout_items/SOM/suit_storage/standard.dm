/datum/loadout_item/suit_store/main_gun/som_marine
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/suit_store/main_gun/som_marine/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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
	Uses 10x24mm caseless ammunition and 10 gauge micro grenades."
	ui_icon = "v31"
	item_typepath = /obj/item/weapon/gun/rifle/som/standard
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return

	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle/enhanced
	name = "V-31+"
	desc = "Equipped with a red dot sight, extended barrel, vertical grip and integrated micro rail launcher. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	Uses a mix of standard and AP 10x24mm caseless ammunition, and 10 gauge micro grenades."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/som/ap

/datum/loadout_item/suit_store/main_gun/som_marine/standard_rifle/enhanced/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	return ..()

/datum/loadout_item/suit_store/main_gun/som_marine/mpi_grenadier
	name = "MPi-KM"
	desc = "Equipped with a red dot sight and underbarrel grenade launcher. The MPi-KM is a modern reproduction based off several variants of kalashnikov type rifles used during the original Martian rebellion. \
	These weapons were already ancient at that time, and their continued use by the SOM speaks more to their cultural legacy than any tactical benefits. \
	Despite having relatively poor mobility and handling, it never the less has fearsome firepower and good capacity, ensuring it stays a relevant weapon choice for the SOM. Uses 7.62x39mm ammunition."
	ui_icon = "ak47"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/black/grenadier

/datum/loadout_item/suit_store/main_gun/som_marine/mpi_grenadier/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/carbine
	name = "V-34"
	desc = "Equipped with a red dot sight and foldable stock. The V-34 is a modern redesign of an ancient weapon that saw extensive use in the Martian uprising. \
	It combines good mobility and managable handling with fearsome stopping power and a tremendous rate of fire, making the V-34 an exceptionally deadly weapon at close range. \
	With poor falloff and accuracy, it is a poor weapon outside of close range, and its mobility lacks compared to some other close range weapons like the V-21. \
	Uses 7.62x39mm ammunition."
	ui_icon = "v34"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/black/standard

/datum/loadout_item/suit_store/main_gun/som_marine/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/smg
	name = "V-21"
	desc = "Equipped with a motion sensor, recoil compensator and vertical grip. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	It uses 10x20mm caseless rounds."
	req_desc = "Requires M-11 scout armor."
	ui_icon = "v21"
	item_typepath = /obj/item/weapon/gun/smg/som/scout
	item_whitelist = list(
		/obj/item/clothing/suit/modular/som/light/shield = ITEM_SLOT_OCLOTHING,
		/obj/item/clothing/suit/modular/som/light/shield_overclocked = ITEM_SLOT_OCLOTHING,
	)

/datum/loadout_item/suit_store/main_gun/som_marine/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/smg/enhanced
	name = "V-21+"
	desc = "Equipped with a motion sensor, recoil compensator and vertical grip. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	Uses a mix of standard and AP 10x20mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/smg/som/ap

/datum/loadout_item/suit_store/main_gun/som_marine/smg/enhanced/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	return ..()

/datum/loadout_item/suit_store/main_gun/som_marine/standard_shotgun
	name = "V-51"
	desc = "Equipped with a mag harness, bayonet and undebarrel flashlight. The V-51 is the main shotgun utilised by the Sons of Mars. \
	Semi automatic with great handling and mobility, it is less powerful than the SH-35 used by the TGMC, but makes up for it with a superior rate of fire. \
	Uses 12 gauge shells."
	req_desc = "Requires M-11 scout armor."
	ui_icon = "v51"
	item_typepath = /obj/item/weapon/gun/shotgun/som/standard
	ammo_type = /obj/item/ammo_magazine/handful/buckshot
	secondary_ammo_type = /obj/item/ammo_magazine/handful/buckshot
	item_whitelist = list(
		/obj/item/clothing/suit/modular/som/light/shield = ITEM_SLOT_OCLOTHING,
		/obj/item/clothing/suit/modular/som/light/shield_overclocked = ITEM_SLOT_OCLOTHING,
	)

/datum/loadout_item/suit_store/main_gun/som_marine/standard_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(istype(secondary) && !isholster(wearer.belt))
		wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_BACKPACK)
	else
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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
	ui_icon = "v62"
	item_typepath = /obj/item/weapon/gun/flamer/som/mag_harness
	item_whitelist = list(/obj/item/clothing/suit/modular/som/heavy/pyro = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/som_marine/flamer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X/som, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/flamer/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(istype(secondary) && !isholster(wearer.belt))
		wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	else
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield
	name = "V-21 & riot shield"
	desc = "Equipped with a red dot sight, recoil compensator and vertical grip, along with a S-144 boarding shield, intended for use with M-31 combat armor for boarding actions.. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	When used with the boarding shield, use of the higher rate of fire is highly unrecommended outside of anything but absolute point blank range. \
	It uses 10x20mm caseless rounds."
	ui_icon = "riot_shield"
	item_typepath = /obj/item/weapon/gun/smg/som/one_handed

/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/som, SLOT_L_HAND)
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/smg_and_shield/enhanced
	name = "V-21+ & riot shield"
	desc = "Equipped with a red dot sight, recoil compensator and vertical grip, along with a S-144 boarding shield, intended for use with M-31 combat armor for boarding actions.. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	When used with the boarding shield, use of the higher rate of fire is highly unrecommended outside of anything but absolute point blank range. \
	Uses a mix of standard and AP 10x20mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/smg/som/ap

/datum/loadout_item/suit_store/main_gun/som_marine/machinegunner
	name = "V-41"
	desc = "Equipped with a red dot sight, extended barrel and bipod. The V-41 is a large man portable machine used by the SOM, allowing for sustained, accurate suppressive firepower at the cost of mobility and handling. \
	Commonly seen where their preferred tactics of fast, mobile aggression is ill suited. Has impressive ranged damage application as a static weapon. Uses 10x26mm Caseless ammunition."
	ui_icon = "v41"
	item_typepath = /obj/item/weapon/gun/rifle/som_mg/standard

/datum/loadout_item/suit_store/main_gun/som_marine/machinegunner/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/machinegunner/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/big_rifle
	name = "V-35"
	desc = "Equipped with a mag harness, extended barrel and bipod. The V-35 is a more recent addition to the SOM armory, \
	where its superior per shot firepower serves as a cheaper alternative to vastly more expensive and maintenance intensive volkite weaponry. \
	A variety of ammunition types further more gives the V-35 significant tactical flexibility that volkite weaponry typically lacks, in addition to the ability to use aim mode. \
	Uses a mix of standard, incendiary and AT 10x27mm caseless ammunition."
	ui_icon = "default"
	item_typepath = /obj/item/weapon/gun/rifle/som_big/support
	purchase_cost = 35

/datum/loadout_item/suit_store/main_gun/som_marine/big_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/incendiary, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/anti_armour, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/big_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(istype(wearer.belt, /obj/item/storage/belt))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/anti_armour, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/anti_armour, SLOT_IN_BELT)

	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger
	name = "VX-32 charger"
	desc = "Unlocked for free with the Advanced rifle training perk. Equipped with a motion detector and gyroscopic stabilizer. The VX-32 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has excellent mobility and handling and is best used at close range. Can be used one handed relatively effectively with sufficient skill. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-33."
	ui_icon = "vx32"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout
	unlock_cost = 300
	purchase_cost = 35
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/volkite_charger/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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

/datum/loadout_item/suit_store/boarding_axe/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_ACCESSORY)

	if(istype(wearer.belt, /obj/item/storage/belt/sparepouch))
		wearer.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/paracetamol, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/isotonic, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/clothing/mask/cigarette/cigar/cohiba, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/matches, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_BELT)

	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/suppressed_rifle
	name = "V-31-suppressed"
	desc = "Equipped with a mag harness, suppressor, vertical grip and integrated micro rail launcher. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	This particular example is a less common variant intended for stealthy operations, where its quietness and lack of muzzle flash can help get the jump on unsuspecting opponents. \
	Uses 10x24mm caseless ammunition and 10 gauge micro grenades."
	ui_icon = "v31"
	item_typepath = /obj/item/weapon/gun/rifle/som/suppressed

/datum/loadout_item/suit_store/main_gun/som_marine/suppressed_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak/som, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_marine/suppressed_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/smoke_burst, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_marine/suppressed_rifle/enhanced
	name = "V-31-suppressed+"
	desc = "Equipped with a mag harness, suppressor, vertical grip and integrated micro rail launcher. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	This particular example is a less common variant intended for stealthy operations, where its quietness and lack of muzzle flash can help get the jump on unsuspecting opponents. \
	Uses a mix of standard and AP 10x24mm caseless ammunition, and 10 gauge micro grenades."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/som/ap

/datum/loadout_item/suit_store/main_gun/som_marine/suppressed_rifle/enhanced/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	return ..()
