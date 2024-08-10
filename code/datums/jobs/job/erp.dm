/datum/job/erp
	title = "ERP Prankster"
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/prankster
	faction = FACTION_ERP
	minimap_icon = "erp"
	outfit = /datum/outfit/job/erp

/datum/outfit/job/erp
	name = "ERP Prankster"
	jobtype = /datum/job/erp

	id = /obj/item/card/id/captains_spare
	ears = /obj/item/radio/headset/distress/erp
	mask = /obj/item/clothing/mask/gas/clown_hat
	gloves = /obj/item/clothing/gloves/marine/black
	back = /obj/item/storage/backpack/clown
	shoes = /obj/item/clothing/shoes/clown_shoes/erp
	w_uniform = /obj/item/clothing/under/rank/clown/erp
	wear_suit = /obj/item/clothing/suit/modular/rownin/erp
	head = /obj/item/clothing/head/tgmcberet/red2/erp
	l_store = /obj/item/storage/pouch/medkit/firstaid
	r_store = /obj/item/storage/holster/flarepouch/full
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/rifle/standard_carbine/beginner

/datum/outfit/job/erp/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/mre_pack/xmas1, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/mre_pack/xmas2, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine/ap, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/plush/gnome, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/plush/rouny, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/bikehorn, SLOT_IN_ACCESSORY)

/datum/job/erp/masterprankster
	title = "ERP Master Prankster"
	skills_type = /datum/skills/prankster/masterprankster
	outfit = /datum/outfit/job/erp/masterprankster

/datum/outfit/job/erp/masterprankster
	name = "ERP Master Prankster"
	jobtype = /datum/job/erp/masterprankster

	head = /obj/item/clothing/head/tgmcberet/red2/erp/masterprankster
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle

/datum/outfit/job/erp/masterprankster/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/plasma, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/plasma, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/plasma, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/plasma, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/plasma, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/plasma, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/mre_pack/xmas1, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/mre_pack/xmas2, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/plasma, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/cell/lasgun/plasma, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/plush/gnome, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/plush/rouny, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/bikehorn, SLOT_IN_ACCESSORY)

/datum/job/erp/boobookisser
	title = "ERP Boo-boo Kisser"
	skills_type = /datum/skills/prankster/boobookisser
	outfit = /datum/outfit/job/erp/boobookisser

/datum/outfit/job/erp/boobookisser
	name = "ERP Boo-boo kisser"
	jobtype = /datum/job/erp/boobookisser

	l_store = /obj/item/storage/pouch/medkit/medic
	r_store = /obj/item/storage/pouch/medical_injectors/medic
	belt = /obj/item/storage/belt/lifesaver/full

/datum/outfit/job/erp/boobookisser/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/mre_pack/xmas1, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/mre_pack/xmas2, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine/ap, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_carbine/ap, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/plush/gnome, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/plush/rouny, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/bikehorn, SLOT_IN_ACCESSORY)

/datum/job/erp/piethrower
	title = "ERP Pie thrower"
	skills_type = /datum/skills/prankster/piethrower
	outfit = /datum/outfit/job/erp/piethrower

/datum/outfit/job/erp/piethrower
	name = "ERP Pie thrower"
	jobtype = /datum/job/erp/piethrower

	belt = /obj/item/storage/belt/grenade
	suit_store = /obj/item/weapon/gun/grenade_launcher/multinade_launcher/erp
	r_store = /obj/item/storage/pouch/grenade

/datum/outfit/job/erp/piethrower/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/mre_pack/xmas1, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/mre_pack/xmas2, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_R_POUCH)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/creampie, SLOT_IN_R_POUCH)

	H.equip_to_slot_or_del(new /obj/item/tool/crowbar, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/plush/gnome, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/plush/rouny, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/toy/bikehorn, SLOT_IN_ACCESSORY)
