/datum/loadout_item/suit_store
	item_slot = ITEM_SLOT_SUITSTORE

/datum/loadout_item/suit_store/empty
	name = "no suit stored"
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


/datum/loadout_item/suit_store/main_gun
	///Ammo type this gun will use
	var/ammo_type

/datum/loadout_item/suit_store/main_gun/New()
	. = ..()
	if(ammo_type)
		return
	var/obj/item/weapon/gun/weapon_type = item_typepath
	ammo_type = weapon_type::default_ammo_type

/datum/loadout_item/suit_store/main_gun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!ammo_type)
		return
	if(istype(wearer.belt, /obj/item/storage/belt))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
	if(istype(wearer.l_store, /obj/item/storage/pouch/magazine))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
	if(istype(wearer.r_store, /obj/item/storage/pouch/magazine))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)

/datum/loadout_item/suit_store/main_gun/marine
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/suit_store/main_gun/marine/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_rifle
	name = "AR-12"
	desc = "The Keckler and Hoch AR-12 assault rifle used to be the TerraGov Marine Corps standard issue rifle before the AR-18 carbine replaced it. It is, however, still used widely despite that. \
	The gun itself is very good at being used in most situations however it suffers in engagements at close quarters and is relatively hard to shoulder than some others. It uses 10x24mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/marine/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/laser_rifle
	name = "Laser rifle"
	desc = "A Terra Experimental laser rifle, abbreviated as the TE-R. Has multiple firemodes for tactical flexibility. Uses standard Terra Experimental (abbreviated as TE) power cells. \
	As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman

/datum/loadout_item/suit_store/main_gun/marine/laser_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_laser_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_carbine
	name = "AR-18"
	desc = "The Keckler and Hoch AR-18 carbine is one of the standard rifles used by the TerraGov Marine Corps. \
	It's commonly used by people who prefer greater mobility in combat, like scouts and other light infantry. Uses 10x24mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/standard

/datum/loadout_item/suit_store/main_gun/marine/standard_carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/combat_rifle
	name = "AR-11"
	desc = "The Keckler and Hoch AR-11 is the former standard issue rifle of the TGMC. Most of them have been mothballed into storage long ago, but some still pop up in marine or mercenary hands. \
	It is known for its large magazine size and great burst fire, but rather awkward to use, especially during combat. It uses 4.92×34mm caseless HV ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/tx11/standard

/datum/loadout_item/suit_store/main_gun/marine/combat_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p492x34mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p492x34mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/combat_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/battle_rifle
	name = "BR-64"
	desc = "The San Cristo Arms BR-64 is the TerraGov Marine Corps main battle rifle. It is known for its consistent ability to perform well at most ranges, and medium range stopping power with bursts. \
	It is mostly used by people who prefer a bigger round than the average. Uses 10x26.5smm caseless caliber."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_br/standard

/datum/loadout_item/suit_store/main_gun/marine/battle_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x265mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/skirmish_rifle
	name = "AR-21"
	desc = "The Kauser AR-21 is a versatile rifle is developed to bridge a gap between higher caliber weaponry and a normal rifle. It fires a strong 10x25mm round, which has decent stopping power. \
	It however suffers in magazine size and movement capablity compared to smaller peers."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_skirmishrifle/standard

/datum/loadout_item/suit_store/main_gun/marine/skirmish_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x25mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/alf
	name = "ALF-51B"
	desc = "The Kauser ALF-51B is an unoffical modification of a ALF-51, or better known as the AR-18 carbine, modified to SMG length of barrel, rechambered for a stronger round, and belt based. \
	Truly the peak of CQC. Useless past that. Aiming is impossible. Uses 10x25mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/alf_machinecarbine/assault

/datum/loadout_item/suit_store/main_gun/marine/alf/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/alf_machinecarbine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/alf/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_gpmg
	name = "MG-60"
	desc = "The Raummetall MG-60 general purpose machinegun is the TGMC's current standard GPMG. \
	Though usually seen mounted on vehicles, it is sometimes used by infantry to hold chokepoints or suppress enemies, or in rare cases for marching fire. It uses 10x26mm boxes."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_gpmg/machinegunner

/datum/loadout_item/suit_store/main_gun/marine/standard_gpmg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_gpmg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_mmg
	name = "MG-27"
	desc = "The MG-27 is the SG-29s aging IFF-less cousin, made for rapid accurate machinegun fire in a short amount of time, you could use it while standing, not a great idea. \
	Use the tripod for actual combat. It uses 10x27mm boxes."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/standard_mmg/machinegunner

/datum/loadout_item/suit_store/main_gun/marine/standard_mmg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_mmg, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_mmg, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_mmg, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_mmg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/laser_mg
	name = "Laser machinegun"
	desc = "A Terra Experimental standard issue machine laser gun, often called as the TE-M by marines. \
	High efficiency modulators ensure the TE-M has an extremely high fire count, and multiple firemodes makes it a flexible infantry support gun. \
	Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, \
	they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser/patrol

/datum/loadout_item/suit_store/main_gun/marine/laser_mg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/laser_mg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/flamer
	name = "FL-84"
	desc = "The FL-84 flamethrower is the current standard issue flamethrower of the TGMC, and is used for area control and urban combat. Use unique action to use hydro cannon"
	req_desc = "Requires a suit with a Surt module."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/flamer/big_flamer/marinestandard/wide
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/heavy/surt = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/marine/flamer/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/shotgun
	name = "SH-35"
	desc = "The Terran Armories SH-35 is the shotgun used by the TerraGov Marine Corps. \
	It's used as a close quarters tool when someone wants something more suited for close range than most people, or as an odd sidearm on your back for emergencies. \
	Uses 12 gauge shells. Requires a pump, which is the Unique Action key."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/shotgun/pump/t35/standard

/datum/loadout_item/suit_store/main_gun/marine/shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/standard_machinepistol/compact(wearer), SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/shotgun/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/laser_carbine_scout
	name = "Laser carbine-S"
	desc = "A TerraGov standard issue laser carbine, otherwise known as TE-C for short. Has multiple firemodes for tactical flexibility. \
	Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, \
	they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	req_desc = "Requires a light armour suit."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/scout
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/light/shield = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/marine/laser_carbine_scout/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/laser_carbine_scout/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/scout_carbine
	name = "AR-18-S"
	desc = "The Keckler and Hoch AR-18 carbine is one of the standard rifles used by the TerraGov Marine Corps. \
	It's commonly used by people who prefer greater mobility in combat, like scouts and other light infantry. Uses 10x24mm caseless ammunition. \
	This particular example has an underbarrel grenade launcher and a top mounted motion sensor. Good for scouting out enemy positions."
	req_desc = "Requires a light armour suit."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/scout
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/light/shield = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/suit_store/main_gun/marine/scout_carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/scout_carbine/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/smg_and_shield
	name = "SMG-25 & riot shield"
	desc = "The RivArms SMG-25 submachinegun, an update to a classic design. \
	A light firearm capable of effective one-handed use that is ideal for close to medium range engagements. Uses 10x20mm rounds in a high capacity magazine. \
	This one comes with a TL-172 defensive shield, intended for use with Tyr heavy armor."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/m25/magharness
	item_blacklist = list(/obj/item/jetpack_marine/heavy = ITEM_SLOT_BACK)

/datum/loadout_item/suit_store/main_gun/marine/smg_and_shield/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine, SLOT_L_HAND)
	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_smg
	name = "SMG-25"
	desc = "The RivArms SMG-25 submachinegun, an update to a classic design. \
	A light firearm capable of effective one-handed use that is ideal for close to medium range engagements. Uses 10x20mm rounds in a high capacity magazine."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/m25/magharness

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle
	name = "BR-8"
	desc ="The BR-8 is a light specialized scout rifle, mostly used by light infantry and scouts. \
	It's designed to be useable at all ranges by being very adaptable to different situations due to the ability to use different ammo types. Has IFF.  Takes specialized overpressured 10x28mm rounds."
	req_desc = "Requires a light armour suit."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/tx8/scout
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/light/shield = ITEM_SLOT_OCLOTHING)
	purchase_cost = 100
	quantity = 2

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/standard_machinepistol/scanner(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx8, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx8, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)

//corpsman
/datum/loadout_item/suit_store/main_gun/corpsman
	jobs_supported = list(SQUAD_CORPSMAN)

/datum/loadout_item/suit_store/main_gun/corpsman/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	if(loadout.l_store == /obj/item/storage/pouch/magazine/large)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
	if(loadout.r_store == /obj/item/storage/pouch/magazine/large)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)

/datum/loadout_item/suit_store/main_gun/corpsman/laser_carbine
	name = "Laser carbine"
	desc = "A TerraGov standard issue laser carbine, otherwise known as TE-C for short. Has multiple firemodes for tactical flexibility. \
	Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, \
	they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/scout
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/corpsman/laser_carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/laser_rifle
	name = "Laser rifle"
	desc = "A Terra Experimental laser rifle, abbreviated as the TE-R. Has multiple firemodes for tactical flexibility. Uses standard Terra Experimental (abbreviated as TE) power cells. \
	As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/medic

/datum/loadout_item/suit_store/main_gun/corpsman/laser_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/auto_shotgun
	name = "SH-15"
	desc = "The Zauer SH-15 Automatic Assault Shotgun, this is a Terran Armories variant. \
	Another iteration of the ZX series of firearms though it has been since regulated as part of the TGMC arsenal, hence the SH designation. \
	It took over the various shotgun models as the semi-automatic shotgun provided to the TGMC. It is rifled, \
	and loads primarily longer ranged munitions, being incompatible with buckshot shells. Takes 12-round 16 gauge magazines."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_autoshotgun/engineer

/datum/loadout_item/suit_store/main_gun/corpsman/auto_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/auto_shotgun/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	if(loadout.l_store == /obj/item/storage/pouch/magazine/large)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_L_POUCH)
	if(loadout.r_store == /obj/item/storage/pouch/magazine/large)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_R_POUCH)

/datum/loadout_item/suit_store/main_gun/corpsman/skirmish_rifle
	name = "AR-21"
	desc = "The Kauser AR-21 is a versatile rifle is developed to bridge a gap between higher caliber weaponry and a normal rifle. It fires a strong 10x25mm round, which has decent stopping power. \
	It however suffers in magazine size and movement capablity compared to smaller peers."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_skirmishrifle/standard

/datum/loadout_item/suit_store/main_gun/corpsman/skirmish_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x25mm, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/pdw
	name = "SMG-90"
	desc = "The SMG-90 is the TerraGov Marine Corps standard issue SMG. Its known for it's compact size and ease of use inside the field. \
	It's usually carried by troops who want a lightweight firearm to rush witwearer. It uses 10x20mm caseless rounds."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/smg/standard_smg/tactical

/datum/loadout_item/suit_store/main_gun/corpsman/pdw/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/assault_rifle
	name = "AR-12"
	desc = "The Keckler and Hoch AR-12 assault rifle used to be the TerraGov Marine Corps standard issue rifle before the AR-18 carbine replaced it. It is, however, still used widely despite that. \
	The gun itself is very good at being used in most situations however it suffers in engagements at close quarters and is relatively hard to shoulder than some others. It uses 10x24mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/medic

/datum/loadout_item/suit_store/main_gun/corpsman/assault_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(!istype(wearer.back, /obj/item/storage))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)

//engineer
/datum/loadout_item/suit_store/main_gun/engineer
	jobs_supported = list(SQUAD_ENGINEER)

/datum/loadout_item/suit_store/main_gun/engineer/carbine
	name = "AR-18"
	desc = "The Keckler and Hoch AR-18 carbine is one of the standard rifles used by the TerraGov Marine Corps. \
	It's commonly used by people who prefer greater mobility in combat, like scouts and other light infantry. Uses 10x24mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/engineer
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/engineer/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_large, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_large, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/engineer/assault_rifle
	name = "AR-12"
	desc = "The Keckler and Hoch AR-12 assault rifle used to be the TerraGov Marine Corps standard issue rifle before the AR-18 carbine replaced it. It is, however, still used widely despite that. \
	The gun itself is very good at being used in most situations however it suffers in engagements at close quarters and is relatively hard to shoulder than some others. It uses 10x24mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/engineer

/datum/loadout_item/suit_store/main_gun/engineer/assault_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_large, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/engineer/auto_shotgun
	name = "SH-15"
	desc = "The Zauer SH-15 Automatic Assault Shotgun, this is a Terran Armories variant. \
	Another iteration of the ZX series of firearms though it has been since regulated as part of the TGMC arsenal, hence the SH designation. \
	It took over the various shotgun models as the semi-automatic shotgun provided to the TGMC. It is rifled, \
	and loads primarily longer ranged munitions, being incompatible with buckshot shells. Takes 12-round 16 gauge magazines."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_autoshotgun/engineer

/datum/loadout_item/suit_store/main_gun/engineer/auto_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	if(istype(wearer.belt, /obj/item/storage/belt))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_BELT)

	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)

	return ..()

//Smartgunner

/datum/loadout_item/suit_store/main_gun/smartgunner
	jobs_supported = list(SQUAD_SMARTGUNNER)

/datum/loadout_item/suit_store/main_gun/smartgunner/smartmachinegun
	name = "SG-29"
	desc = "The Raummetall-KT SG-29 is the TGMC's current standard IFF-capable medium machine gun. \
	It's known for its ability to lay down heavy fire support very well. It is generally used when someone wants to hold a position or provide fire support. \
	Requires special training and it cannot turn off IFF. It uses 10x26mm ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/smartgunner/smartmachinegun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(wearer), SLOT_IN_BACKPACK)

	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/smartgunner/smart_minigun
	name = "SG-85"
	desc = "A true monster of providing supportive suppresing fire, the SG-85 is the TGMC's IFF-capable minigun for heavy fire support duty. \
	Boasting a higher firerate than any other handheld weapon. It is chambered in 10x26 caseless."
	req_desc = "Requires a powerback for power and ammo."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/minigun/smart_minigun/motion_detector
	item_whitelist = list(/obj/item/ammo_magazine/minigun_powerpack/smartgun = ITEM_SLOT_BACK)

/datum/loadout_item/suit_store/main_gun/smartgunner/smart_minigun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(loadout.belt == /obj/item/storage/belt/sparepouch)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/smart_minigun, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/smart_minigun, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/standard_machinepistol/compact(wearer), SLOT_IN_BELT)

		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_ACCESSORY)

	else
		wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/smartgunner/smarttargetrifle
	name = "SG-62"
	desc = "The Kauser-KT SG-62 is a IFF-capable rifle used by the TerraGov Marine Corps, coupled with a spotting rifle that is also IFF capable of applying various bullets with specialized ordnance, \
	this is a gun with many answers to many situations... if you have the right ammo loaded. \
	Requires special training and it cannot turn off IFF. It uses high velocity 10x27mm for the rifle and 12x66mm ammunition for the underslung rifle."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_smarttargetrifle/motion

/datum/loadout_item/suit_store/main_gun/smartgunner/smarttargetrifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(wearer), SLOT_IN_BACKPACK)

	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

//squad leader
/datum/loadout_item/suit_store/main_gun/squad_leader
	jobs_supported = list(SQUAD_LEADER)

/datum/loadout_item/suit_store/main_gun/squad_leader/standard_rifle
	name = "AR-12"
	desc = "The Keckler and Hoch AR-12 assault rifle used to be the TerraGov Marine Corps standard issue rifle before the AR-18 carbine replaced it. It is, however, still used widely despite that. \
	The gun itself is very good at being used in most situations however it suffers in engagements at close quarters and is relatively hard to shoulder than some others. It uses 10x24mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman

/datum/loadout_item/suit_store/main_gun/squad_leader/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/hud_tablet(wearer, /datum/job/terragov/squad/leader, wearer.assigned_squad), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/laser_rifle
	name = "Laser rifle"
	desc = "A Terra Experimental laser rifle, abbreviated as the TE-R. Has multiple firemodes for tactical flexibility. Uses standard Terra Experimental (abbreviated as TE) power cells. \
	As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/squad_leader/laser_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/hud_tablet(wearer, /datum/job/terragov/squad/leader, wearer.assigned_squad), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/carbine
	name = "AR-18"
	desc = "The Keckler and Hoch AR-18 carbine is one of the standard rifles used by the TerraGov Marine Corps. \
	It's commonly used by people who prefer greater mobility in combat, like scouts and other light infantry. Uses 10x24mm caseless ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/plasma_pistol

/datum/loadout_item/suit_store/main_gun/squad_leader/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/combat_rifle
	name = "AR-11"
	desc = "The Keckler and Hoch AR-11 is the former standard issue rifle of the TGMC. Most of them have been mothballed into storage long ago, but some still pop up in marine or mercenary hands. \
	It is known for its large magazine size and great burst fire, but rather awkward to use, especially during combat. It uses 4.92×34mm caseless HV ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/tx11/standard

/datum/loadout_item/suit_store/main_gun/squad_leader/combat_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/hud_tablet(wearer, /datum/job/terragov/squad/leader, wearer.assigned_squad), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p492x34mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/battle_rifle
	name = "BR-64"
	desc = "The San Cristo Arms BR-64 is the TerraGov Marine Corps main battle rifle. It is known for its consistent ability to perform well at most ranges, and medium range stopping power with bursts. \
	It is mostly used by people who prefer a bigger round than the average. Uses 10x26.5smm caseless caliber."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_br/standard

/datum/loadout_item/suit_store/main_gun/squad_leader/battle_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x265mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x265mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/auto_shotgun
	name = "SH-15"
	desc = "The Zauer SH-15 Automatic Assault Shotgun, this is a Terran Armories variant. \
	Another iteration of the ZX series of firearms though it has been since regulated as part of the TGMC arsenal, hence the SH designation. \
	It took over the various shotgun models as the semi-automatic shotgun provided to the TGMC. It is rifled, \
	and loads primarily longer ranged munitions, being incompatible with buckshot shells. Takes 12-round 16 gauge magazines."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/standard_autoshotgun/plasma_pistol

/datum/loadout_item/suit_store/main_gun/squad_leader/auto_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/oicw
	name = "AR-55"
	desc = "Officially designated an Objective Individual Combat Weapon, the AR-55 features an upper bullpup 20mm grenade launcher designed to fire a variety of specialised rounds, \
	and an underslung assault rifle using 10x24mm caseless ammunition. Somewhat cumbersome to use due to its size and weight."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/tx55/combat_patrol
	purchase_cost = 100
	quantity = 2

/datum/loadout_item/suit_store/main_gun/squad_leader/oicw/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(wearer), SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/oicw/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	if(loadout.belt == /obj/item/storage/belt/marine)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
	if(loadout.l_store == /obj/item/storage/pouch/magazine/large)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_L_POUCH)
	if(loadout.r_store == /obj/item/storage/pouch/magazine/large)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_R_POUCH)

//FC
/datum/loadout_item/suit_store/officer_sword
	name = "Officers sword"
	desc = "This appears to be a rather old blade that has been well taken care of, it is probably a family heirloom. \
	Well made and extremely sharp, despite its probable non-combat purpose. Comes in a leather scabbard that an attached to your waist or armor."
	item_typepath = /obj/item/storage/holster/blade/officer/full
	jobs_supported = list(FIELD_COMMANDER)
	item_blacklist = list(/obj/item/storage/holster/blade/officer/full = ITEM_SLOT_BELT)

/datum/loadout_item/suit_store/fc_pistol
	name = "P-1911A1-C pistol"
	desc = "A handgun that has received several modifications. It seems to have been lovingly taken care of and passed down for generations. \
	Lacks an auto magazine eject feature. Comes in a holster that fits on your waist or armor."
	item_typepath = /obj/item/storage/holster/belt/pistol/m4a3/fieldcommander
	jobs_supported = list(FIELD_COMMANDER)
	item_blacklist = list(/obj/item/storage/holster/belt/pistol/m4a3/fieldcommander = ITEM_SLOT_BELT)

/datum/loadout_item/suit_store/main_gun/field_commander
	jobs_supported = list(FIELD_COMMANDER)

/datum/loadout_item/suit_store/main_gun/field_commander/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	if(loadout.belt == /obj/item/storage/belt/marine)
		wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/hud_tablet/fieldcommand, SLOT_IN_BACKPACK)
	else
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
/datum/loadout_item/suit_store/main_gun/field_commander/pulse_rifle
	name = "PR-11"
	desc = "A strange failed electronically fired rifle, a rather unknown weapon of its time. \
	It caused a surge in the use of electronic firing in the modern era though. Uses 10x24mm caseless ammunition. Has a irremoveable grenade launcher and a significant magazine capacity."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/m41a/field_commander
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/field_commander/pulse_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/field_commander/combat_rifle
	name = "AR-11"
	desc = "The Keckler and Hoch AR-11 is the former standard issue rifle of the TGMC. Most of them have been mothballed into storage long ago, but some still pop up in marine or mercenary hands. \
	It is known for its large magazine size and great burst fire, but rather awkward to use, especially during combat. It uses 4.92×34mm caseless HV ammunition."
	ui_icon = "ballistic"
	item_typepath = /obj/item/weapon/gun/rifle/tx11/standard

/datum/loadout_item/suit_store/main_gun/field_commander/combat_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/field_commander/laser_rifle
	name = "Laser rifle"
	desc = "A Terra Experimental laser rifle, abbreviated as the TE-R. Has multiple firemodes for tactical flexibility. Uses standard Terra Experimental (abbreviated as TE) power cells. \
	As with all TE Laser weapons, they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman

/datum/loadout_item/suit_store/main_gun/field_commander/laser_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/field_commander/laser_mg
	name = "Laser machinegun"
	desc = "A Terra Experimental standard issue machine laser gun, often called as the TE-M by marines. \
	High efficiency modulators ensure the TE-M has an extremely high fire count, and multiple firemodes makes it a flexible infantry support gun. \
	Uses standard Terra Experimental (abbreviated as TE) power cells. As with all TE Laser weapons, \
	they use a lightweight alloy combined without the need for bullets any longer decreases their weight and aiming speed quite some vs their ballistic counterparts."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser/patrol

/datum/loadout_item/suit_store/main_gun/field_commander/laser_mg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!istype(wearer.back, /obj/item/storage))
		return

	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
