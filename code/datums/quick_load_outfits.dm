/datum/outfit/quick
	///Description of the loadout
	var/desc = "Description here"
	///How much of this loadout there is. infinite by default
	var/quantity = -1
	///What job this loadout is associated with. Used for tabs and access.
	var/jobtype = "Squad Marine"


/datum/outfit/quick/equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	pre_equip(H, visualsOnly)

	//Start with uniform,suit,backpack for additional slots. Deletes any existing equipped item to avoid accidentally losing half your loadout. Not suitable for standard gamemodes!
	if(w_uniform)
		qdel(H.w_uniform)
		H.equip_to_slot_or_del(new w_uniform(H),SLOT_W_UNIFORM, override_nodrop = TRUE)
	if(wear_suit)
		qdel(H.wear_suit)
		H.equip_to_slot_or_del(new wear_suit(H),SLOT_WEAR_SUIT, override_nodrop = TRUE)
	if(back)
		qdel(H.back)
		H.equip_to_slot_or_del(new back(H),SLOT_BACK, override_nodrop = TRUE)
	if(belt)
		qdel(H.belt)
		H.equip_to_slot_or_del(new belt(H),SLOT_BELT, override_nodrop = TRUE)
	if(gloves)
		qdel(H.gloves)
		H.equip_to_slot_or_del(new gloves(H),SLOT_GLOVES, override_nodrop = TRUE)
	if(shoes)
		qdel(H.shoes)
		H.equip_to_slot_or_del(new shoes(H),SLOT_SHOES, override_nodrop = TRUE)
	if(head)
		qdel(H.head)
		H.equip_to_slot_or_del(new head(H),SLOT_HEAD, override_nodrop = TRUE)
	if(mask)
		qdel(H.wear_mask)
		H.equip_to_slot_or_del(new mask(H),SLOT_WEAR_MASK, override_nodrop = TRUE)
	if(ears)
		qdel(H.wear_ear)
		if(visualsOnly)
			H.equip_to_slot_or_del(new /obj/item/radio/headset(H), SLOT_EARS, override_nodrop = TRUE)
		else
			H.equip_to_slot_or_del(new ears(H, H.assigned_squad, jobtype), SLOT_EARS, override_nodrop = TRUE)
	if(glasses)
		qdel(H.glasses)
		H.equip_to_slot_or_del(new glasses(H),SLOT_GLASSES, override_nodrop = TRUE)
	if(id)
		H.equip_to_slot_or_del(new id(H),SLOT_WEAR_ID, override_nodrop = TRUE)
	if(suit_store)
		qdel(H.s_store)
		H.equip_to_slot_or_del(new suit_store(H),SLOT_S_STORE, override_nodrop = TRUE)
	if(l_hand)
		qdel(H.l_hand)
		H.put_in_l_hand(new l_hand(H))
	if(r_hand)
		qdel(H.r_hand)
		H.put_in_r_hand(new r_hand(H))

	if(!visualsOnly) // Items in pockets or backpack don't show up on mob's icon.
		if(l_store)
			qdel(H.l_store)
			H.equip_to_slot_or_del(new l_store(H),SLOT_L_STORE, override_nodrop = TRUE)
		if(r_store)
			qdel(H.r_store)
			H.equip_to_slot_or_del(new r_store(H),SLOT_R_STORE, override_nodrop = TRUE)

		if(box)
			if(!backpack_contents)
				backpack_contents = list()
			backpack_contents.Insert(1, box)
			backpack_contents[box] = 1

		if(backpack_contents)
			for(var/path in backpack_contents)
				var/number = backpack_contents[path]
				if(!isnum(number))//Default to 1
					number = 1
				for(var/i in 1 to number)
					H.equip_to_slot_or_del(new path(H),SLOT_IN_BACKPACK, override_nodrop = TRUE)

	post_equip(H, visualsOnly)

	if(!visualsOnly)
		if(internals_slot)
			H.internal = H.get_item_by_slot(internals_slot)
			H.update_action_buttons()

	H.update_body()
	return TRUE

////TGMC/////

//placeholder in case any base configurations are needed for marine outfits
/datum/outfit/quick/tgmc
	name = "TGMC base"
	desc = "This is the base typepath for all TGMC quick vendor outfits. You shouldn't see this."

//Squad marine
/datum/outfit/quick/tgmc/marine
	name = "TGMC Squad Marine"
	jobtype = "Squad Marine"

//Standard AR12 unga
/datum/outfit/quick/tgmc/marine/standard_assaultrifle
	name = "AR12 rifleman"
	desc = "The classic line rifleman. Equipped with an AR-12 with UGL, heavy armor, and plenty of grenades and ammunition."

	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/marine/m10x
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/quick/tgmc/marine/standard_assaultrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/acid, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)

//Standard laser rifle unga
/datum/outfit/quick/tgmc/marine/standard_laserrifle
	name = "Laser rifleman"
	desc = "For when bullets don't cut the mustard. Laser rifle with miniflamer and heavy armor. Lasers are more effective against SOM armor, but cannot break bones and damage organs."

	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/marine/m10x
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/quick/tgmc/marine/standard_laserrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/acid, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)

//MG60 machinegunner
/datum/outfit/quick/tgmc/marine/standard_machinegunner
	name = "MG60 machinegunner"
	desc = "The old reliable workhorse of the TGMC. Equipped with an MG-60 with bipod, medium armor and some basic construction supplies. Good for holding ground and providing firesupport, and the cost of some mobility and armor."

	belt = /obj/item/storage/belt/sparepouch
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/marine/m10x
	suit_store = /obj/item/weapon/gun/rifle/standard_gpmg/machinegunner
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/construction
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/quick/tgmc/marine/standard_machinegunner/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_gpmg, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/tool/shovel/etool, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/sandbags_empty/full, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/half_stack, SLOT_IN_L_POUCH)

//MG27 machinegunner
/datum/outfit/quick/tgmc/marine/medium_machinegunner
	name = "MG27 machinegunner"
	desc = "For when you need the biggest gun you can carry. Equipped with an MG-27 and miniscope and a MR-25 SMG as a side arm, as well as medium armor and a small amount of construction supplies. Allows for devestating, albeit static firepower."

	belt = /obj/item/storage/holster/m25
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/marine/m10x
	suit_store = /obj/item/weapon/gun/standard_mmg/machinegunner
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/construction
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/quick/tgmc/marine/medium_machinegunner/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_mmg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_mmg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_mmg, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/m25/holstered(H), SLOT_IN_HOLSTER)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/tool/shovel/etool, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/sandbags_empty/full, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/half_stack, SLOT_IN_L_POUCH)

//shotgun unga
/datum/outfit/quick/tgmc/marine/standard_shotgun
	name = "SH35 scout"
	desc = "For getting too close for comfort. Equipped with a SH-35 with buckshot and flechette rounds, a MP-19 sidearm, a good amount of grenades and light armor with a cutting edge 'arrowhead' shield module. Provides for excellent mobility and devestating close range firepower, but will falter against sustained firepower."

	belt = /obj/item/storage/belt/shotgun
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/light/shield
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas/tactical
	head = /obj/item/clothing/head/modular/marine/m10x
	suit_store = /obj/item/weapon/gun/shotgun/pump/t35/pointman
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/quick/tgmc/marine/standard_shotgun/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x20mm, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/standard_machinepistol/compact(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/flechette, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/acid, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)

//Laser carbine scout
/datum/outfit/quick/tgmc/marine/standard_lasercarbine
	name = "Laser carbine scout"
	desc = "Highly mobile light infantry. Equipped with a laser carbine with UGL and a laser pistol sidearm, plenty of grenades and light armor with a cutting edge 'arrowhead' shield module. Excellent mobility, but not suited for sustained combat."

	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/light/shield
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/marine/m10x
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/scout
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/quick/tgmc/marine/standard_lasercarbine/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol/tactical(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/lasrifle, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/acid, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)

//Squad Engineer
/datum/outfit/quick/tgmc/engineer
	name = "TGMC Squad Engineer"
	jobtype = "Squad Engineer"

//Rocket man
/datum/outfit/quick/tgmc/engineer/rrengineer
	name = "Rocket man"
	desc = "Bringing the big guns. Equipped with a AR-18 and RL-160 along with the standard engineer kit. Excellent against groups of enemy infantry or light armor, but only has limited ammunition."

	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/meson
	w_uniform = /obj/item/clothing/under/marine/engineer/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/engineer
	gloves = /obj/item/clothing/gloves/marine/insulated
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/marine/m10x/welding
	suit_store = /obj/item/weapon/gun/rifle/standard_carbine/engineer
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/tools/full
	back = /obj/item/storage/holster/backholster/rpg/full

/datum/outfit/quick/tgmc/engineer/rrengineer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_smol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

//sentry nerd
/datum/outfit/quick/tgmc/engineer/sentry
	name = "Sentry technician"
	desc = "Firing more guns than you have hands. Equipped with a AR-12 with miniflamer, and two minisentries along with the standard engineer kit. Allows the user to quickly setup strong points and lock areas down, with some sensible placement."

	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/meson
	w_uniform = /obj/item/clothing/under/marine/engineer/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/engineer
	gloves = /obj/item/clothing/gloves/marine/insulated
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/marine/m10x/welding
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/engineer
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/tools/full
	back = /obj/item/storage/backpack/marine/engineerpack

/datum/outfit/quick/tgmc/engineer/sentry/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/sentry/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/sentry/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/minisentry, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/minisentry, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/half_stack, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_smol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

//Demo man
/datum/outfit/quick/tgmc/engineer/demolition
	name = "Demolition specialist"
	desc = "Boom boom, shake the room. Equipped with a SH-35 and UGL and an impressive array of mines, detpacks and grenades, along with the standard engineer kit. Excellent for blasting through any obstacle, and mining areas to restrict enemy movement."

	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/meson
	w_uniform = /obj/item/clothing/under/marine/engineer/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/engineer
	gloves = /obj/item/clothing/gloves/marine/insulated
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/marine/m10x/welding
	suit_store = /obj/item/weapon/gun/rifle/standard_autoshotgun/engineer
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/tools/full
	back = /obj/item/storage/backpack/marine/tech

/datum/outfit/quick/tgmc/engineer/demolition/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/minelayer, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/assembly/signaler, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/detpack, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_slug, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx15_flechette, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/half_stack, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/stack/cable_coil, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

//Squad Medic
/datum/outfit/quick/tgmc/corpsman
	name = "TGMC Squad Corpsman"
	jobtype = "Squad Corpsman"

//AR12 Standard medic - WIP
/datum/outfit/quick/tgmc/corpsman/standard_medic
	name = "AR12 standard corpsman"
	desc = "Keeping everone else in the fight. Armed with an AR-12 and an impressive array of tools for healing your team, and a 'Mimir' biological protection module to allow you to continue operating in hazardous environments. With medivacs out of the question, you are the only thing standing between your buddies and an early grave."

	belt = /obj/item/storage/belt/lifesaver/quick
	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/hud/health
	w_uniform = /obj/item/clothing/under/marine/corpsman/corpman_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/mimir
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/marine/m10x/mimir
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/medic
	r_store = /obj/item/storage/pouch/medical_injectors
	l_store = /obj/item/storage/pouch/magazine/large
	back = /obj/item/storage/backpack/marine/corpsman

/datum/outfit/quick/tgmc/corpsman/standard_medic/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/nanoblood, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/bodybag/cryobag, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/roller, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tweezers, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/oxycodone, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/combat_advanced, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/neuraline, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_L_POUCH)

//Squad Smartgunner
/datum/outfit/quick/tgmc/smartgunner
	name = "TGMC Squad Smartgunner"
	jobtype = "Squad Smartgunner"

//Standard SG29
/datum/outfit/quick/tgmc/smartgunner/standard_sg
	name = "SG29 smart machinegunner"
	desc = "A gun smarter than the average bear, or marine. Equipped with an SG-29 and medium armor, responsible for providing mobile, accurate firesupport thanks to your IFF ammunition."

	belt = /obj/item/belt_harness/marine
	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas/tactical
	head = /obj/item/clothing/head/modular/marine/m10x
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/marine/satchel

/datum/outfit/quick/tgmc/smartgunner/standard_sg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/standard_smartmachinegun, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(H), SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/acid, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)

//Minigun SG
/datum/outfit/quick/tgmc/smartgunner/minigun_sg
	name = "SG85 smart machinegunner"
	desc = "More bullets than sense. Equipped with an SG-85 smart minigun, a MP-19 sidearm, medium armor and a whole lot of bullets. For when you want to unleash a firehose of firepower. Try not to run out of ammo."

	belt = /obj/item/storage/holster/t19
	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas/tactical
	head = /obj/item/clothing/head/modular/marine/m10x
	suit_store = /obj/item/weapon/gun/minigun/smart_minigun/magharness
	r_store = /obj/item/storage/pouch/firstaid
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/ammo_magazine/minigun_powerpack/smartgun

/datum/outfit/quick/tgmc/smartgunner/minigun_sg/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/standard_machinepistol, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/smg/standard_machinepistol/vgrip(H), SLOT_IN_HOLSTER)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/acid, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)

//Squad Leader
/datum/outfit/quick/tgmc/leader
	name = "TGMC Squad Leader"
	jobtype = "Squad Leader"

//Standard AR12 squad leader
/datum/outfit/quick/tgmc/leader/standard_assaultrifle
	name = "AR12 patrol leader"
	desc = "Gives the orders. Equipped with an AR-12 with UGL, plenty of grenades, some support kit such as deployable cameras, as well as heavy armor with a 'valkyrie' autodoc module. You can provide excellent support to your squad thanks to your kit and order shouting talents."

	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/mainship/marine
	glasses = /obj/item/clothing/glasses/hud/health
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/leader
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/marine/m10x/leader
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	r_store = /obj/item/storage/pouch/medkit
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/marine/standard

/datum/outfit/quick/tgmc/leader/standard_assaultrifle/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/hud_tablet(H, /datum/job/terragov/squad/leader, H.assigned_squad), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/vp70, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_smol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_smol, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/binoculars/tactical/range, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/vp70/tactical(H), SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/bicaridine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/kelotane, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/advanced/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/acid, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/neuro, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)



//// SOM loadouts ////

//placeholder in case any base configurations are needed for marine outfits
/datum/outfit/quick/som
	name = "SOM base"
	desc = "This is the base typepath for all SOM quick vendor outfits. You shouldn't see this."

//SOM Squad Marine
/datum/outfit/quick/som/marine
	name = "SOM Squad Marine"
	jobtype = "SOM Standard"

/datum/outfit/quick/som/marine/mpi
	name = "MPI rifleman"
	desc = "The infantryman on a budget. Equipped with an MPI with UGL, medium armor and a good selection of grenades. While the SOM have developed some exceptionally advanced weaponry, it appears demand far outstrips their production capacity, so many rank and file solders are seen with easy to manufacture and maintain weapons such as the MPI. Despite it's ancient design, still packs a punch."

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/som
	r_store = /obj/item/storage/pouch/firstaid/som
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/satchel/som

/datum/outfit/quick/som/marine/mpi/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/upp(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_assaultrifle, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/mpi_km, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)

/datum/outfit/quick/som/marine/charger
	name = "Charger rifleman"
	desc = "The cutting edge light infantryman of the SOM. Equipped with a volkite charger, medium armor and a good variety of grenades. Volkite weapons are exceptionally dangerous, especially against poorly armored or tightly grouped opponents. The charger is the SOM's premier close/medium range weapon, with good mobility, and can be used (with some difficulty) one handed."

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/standard
	r_store = /obj/item/storage/pouch/firstaid/som
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/satchel/som

/datum/outfit/quick/som/marine/charger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/upp(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)

/datum/outfit/quick/som/marine/caliver
	name = "Caliver rifleman"
	desc = "The cutting edge general infantryman. Equipped with a volkite caliver, medium armor and a good variety of grenades. Volkite weapons are exceptionally dangerous, especially against poorly armored or tightly grouped opponents. The caliver inflicts devastating damage and is effective at longer ranges than the charger, making it more of a true rifle. It's larger size makes it harder to lug around however."

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/standard
	r_store = /obj/item/storage/pouch/firstaid/som
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/satchel/som

/datum/outfit/quick/som/marine/caliver/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/revolver/upp, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/revolver/upp(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite/highcap, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/stick, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary/molotov, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)


/datum/outfit/quick/som/engineer
	name = "SOM Squad Engineer"
	jobtype = "SOM Engineer"


/datum/outfit/quick/som/medic
	name = "SOM Squad Medic"
	jobtype = "SOM Medic"


/datum/outfit/quick/som/veteran
	name = "SOM Squad Veteran"
	jobtype = "SOM Veteran"

/datum/outfit/quick/som/veteran/charger
	name = "Charger Veteran"
	desc = "Heavily armed and armored SOM elite. Equipped with a volkite charger configured for better one handed use, heavy armor and a good variety of grenades. Volkite weapons are exceptionally dangerous, especially against poorly armored or tightly grouped opponents. The charger is the SOM's premier close/medium range weapon, with good mobility, and can be used (with some difficulty) one handed."

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/storage/belt/marine/som
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/veteran/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/veteran
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/standard
	r_store = /obj/item/storage/pouch/firstaid/som
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/storage/backpack/satchel/som

/datum/outfit/quick/som/veteran/charger/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/highpower, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/highpower(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/volkite, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)

/datum/outfit/quick/som/veteran/culverin
	name = "Culverin heavy firesupport"
	desc = "Heavily armored heavy firesupport. Equipped with a volkite culverin and self charging backpack power unit, and a shotgun sidearm. The culverin is the most powerful man portable weapon the SOM have been seen to field. Capabable of laying down a tremendous barrage of firepower for extended periods of time. Although the back-mounted powerpack is self charging, it cannot keep up with the immense power requirements of the gun, so sustained, prolonged use can degrade the weapon's effectiveness greatly."

	id = /obj/item/card/id/dogtag/som
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/veteran/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/veteran
	glasses = /obj/item/clothing/glasses/meson
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	r_store = /obj/item/storage/pouch/firstaid/som
	l_store = /obj/item/storage/pouch/grenade
	back = /obj/item/cell/lasgun/volkite/powerpack

/datum/outfit/quick/som/veteran/culverin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/handful/buckshot, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/upp, SLOT_IN_ACCESSORY)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/bruise_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/advanced/burn_pack, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tricordrazine, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/storage/pill_bottle/packet/tramadol, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/splint, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/inaprovaline, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/satrapine, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_L_POUCH)


/datum/outfit/quick/som/squad_leader
	name = "SOM Squad Leader"
	jobtype = "SOM Leader"
