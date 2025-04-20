/datum/loadout_item/suit_store/main_gun/som_squad_leader
	jobs_supported = list(SOM_SQUAD_LEADER)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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
	ui_icon = "v31"
	item_typepath = /obj/item/weapon/gun/rifle/som/veteran
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/som_squad_leader/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
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
	ui_icon = "v21"
	item_typepath = /obj/item/weapon/gun/smg/som/veteran

/datum/loadout_item/suit_store/main_gun/som_squad_leader/smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/som/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/big_rifle
	name = "V-35"
	desc = "Equipped with a motion sensor, extended barrel and vertical grip. The V-35 is a more recent addition to the SOM armory, \
	where its superior per shot firepower serves as a cheaper alternative to vastly more expensive and maintenance intensive volkite weaponry. \
	A variety of ammunition types further more gives the V-35 significant tactical flexibility that volkite weaponry typically lacks, in addition to the ability to use aim mode. \
	Uses a mix of standard, incendiary and AT 10x27mm caseless ammunition."
	ui_icon = "default"
	item_typepath = /obj/item/weapon/gun/rifle/som_big/standard
	purchase_cost = 35

/datum/loadout_item/suit_store/main_gun/som_squad_leader/big_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/anti_armour, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/big_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(istype(wearer.belt, /obj/item/storage/belt))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/anti_armour, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/som_big/anti_armour, SLOT_IN_BELT)

	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign/som, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_charger
	name = "VX-32 charger"
	desc = "Equipped with a motion sensor and gyroscopic stabiliser for effective one handed use. \
	The VX-32 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has excellent mobility and handling and is best used at close range. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-33."
	ui_icon = "vx32"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/scout

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_charger/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_caliver
	name = "VX-33 caliver"
	desc = "Equipped with a motion sensor and laser sight. \
	The VX-33 is a sophisticated energy weapon capable of explosively deflagrated organic targets, horrifically burning and igniting the victim and anyone unfortunate enough to be near them. \
	Has middling mobility and handling, it is a long range rifle analogue, able to project strong damage even at long ranges. \
	Its deflagrating ability works best against light armored targets, where it can quickly mow down and demoralise tightly packed enemies. Against heavily armored opponents, its effectiveness can quickly drop however. \
	Uses volkite power cells, shared with the VX-32, and can also be linked to a volkite powerpack."
	ui_icon = "vx33"
	purchase_cost = 50
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor

/datum/loadout_item/suit_store/main_gun/som_squad_leader/volkite_caliver/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
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
	ui_icon = "ak47"
	item_typepath = /obj/item/weapon/gun/rifle/mpi_km/grenadier

/datum/loadout_item/suit_store/main_gun/som_squad_leader/mpi/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
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
	ui_icon = "v34"
	item_typepath = /obj/item/weapon/gun/rifle/som_carbine/mag_harness

/datum/loadout_item/suit_store/main_gun/som_squad_leader/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/som, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km/extended, SLOT_IN_BACKPACK)
