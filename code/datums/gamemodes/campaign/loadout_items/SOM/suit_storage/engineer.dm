/datum/loadout_item/suit_store/main_gun/som_engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)

/datum/loadout_item/suit_store/main_gun/som_engineer/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle
	name = "V-31"
	desc = "Equipped with a red dot sight, extended barrel, vertical grip and integrated micro rail launcher. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	Uses 10x24mm caseless ammunition and 10 gauge micro grenades."
	ui_icon = "v31"
	item_typepath = /obj/item/weapon/gun/rifle/som/standard
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/dragonbreath, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack/marine/engineerpack/som))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/micro_grenade/cluster, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/standard_rifle/enhanced
	name = "V-31+"
	desc = "Equipped with a red dot sight, extended barrel, vertical grip and integrated micro rail launcher. The V-31 is the principal ballistic weapon for the SOM. \
	It has good mobility and handling and a good rate of fire, but tends to favour closer range fighting compared to many TGMC equivilents. \
	The rail launcher electromagnetically launches a variety of 10 gauge airbursting grenades. Extremely effective when used correctly, their fixed fuse time makes them entirely ineffective at very close or far ranges. \
	Managing engagement range is thus vital for maximising the effectiveness of this weapon. \
	Uses a mix of standard and AP 10x24mm caseless ammunition, and 10 gauge micro grenades."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/som/ap

/datum/loadout_item/suit_store/main_gun/som_engineer/mpi
	name = "MPi-KM"
	desc = "Equipped with a red dot sight and underslung grenade launcher. The MPi-KM is a modern reproduction based off several variants of kalashnikov type rifles used during the original Martian rebellion. \
	These weapons were already ancient at that time, and their continued use by the SOM speaks more to their cultural legacy than any tactical benefits. \
	Despite having relatively poor mobility and handling, it never the less has fearsome firepower and good capacity, ensuring it stays a relevant weapon choice for the SOM. Uses 7.62x39mm ammunition."
	ui_icon = "ak47"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/black/grenadier

/datum/loadout_item/suit_store/main_gun/som_engineer/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/som, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack/marine/engineerpack/som))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/carbine
	name = "V-34"
	desc = "Equipped with a red dot sight and foldable stock. The V-34 is a modern redesign of an ancient weapon that saw extensive use in the Martian uprising. \
	It combines good mobility and managable handling with fearsome stopping power and a tremendous rate of fire, making the V-34 an exceptionally deadly weapon at close range. \
	With poor falloff and accuracy, it is a poor weapon outside of close range, and its mobility lacks compared to some other close range weapons like the V-21. \
	Uses 7.62x39mm ammunition."
	ui_icon = "v34"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/black/standard

/datum/loadout_item/suit_store/main_gun/som_engineer/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack/marine/engineerpack/som))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/smg
	name = "V-21"
	desc = "Equipped with a mag harness, recoil compensator and vertical grip. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	It uses 10x20mm caseless rounds."
	ui_icon = "v21"
	item_typepath = /obj/item/weapon/gun/smg/som/support

/datum/loadout_item/suit_store/main_gun/som_engineer/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack/marine/engineerpack/som))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/smg/enhanced
	name = "V-21+"
	desc = "Equipped with a mag harness, recoil compensator and vertical grip. The V-21 is the principal submachinegun used by the Sons of Mars, with a variable rate of fire. \
	Has outstanding mobility and handling and can be comfortably fired one handed on its lower fire rate mode. \
	When set to its higher rate of fire, it unleashes a staggering torrent of firepower, but is difficult to control even two handed, and quickly loses effectiveness at range. \
	At close range however, it will quickly obliterate most targets - as long as you don't run out of ammo. \
	Uses a mix of standard and AP 10x20mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/smg/som/ap

/datum/loadout_item/suit_store/main_gun/som_engineer/flechette_shotgun
	name = "V-51"
	desc = "Equipped with a mag harness and bayonet. The V-51 is the main shotgun utilised by the Sons of Mars. \
	Semi automatic with great handling and mobility, it is less powerful than the SH-35 used by the TGMC, but makes up for it with a superior rate of fire. \
	Uses 12 gauge shells."
	ui_icon = "v51"
	item_typepath = /obj/item/weapon/gun/shotgun/som/support
	ammo_type = /obj/item/ammo_magazine/handful/flechette
	secondary_ammo_type = /obj/item/ammo_magazine/handful/flechette

/datum/loadout_item/suit_store/main_gun/som_engineer/flechette_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack/marine/engineerpack/som))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_engineer/volkite_charger
	name = "VX-32 charger"
	desc = "Unlocked for free with the Advanced rifle training perk. Equipped with a red dot sight and laser sight. The VX-32 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has excellent mobility and handling and is best used at close range. Can be used one handed relatively effectively with sufficient skill. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-33."
	ui_icon = "vx32"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/standard
	unlock_cost = 300
	purchase_cost = 25
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/som_engineer/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack/marine/engineerpack/som))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
