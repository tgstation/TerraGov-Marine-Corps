/datum/job/retired
	title = "TGMC retired veteran"
	job_category = JOB_CAT_MARINE
	paygrade = "MSGT"
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/veteran //they're old, they know their stuff
	faction = FACTION_TERRAGOV
	outfit = /datum/outfit/job/retired

/datum/outfit/job/retired
	name = "TGMC retired veteran"
	jobtype = /datum/job/retired

	id = /obj/item/card/id/dogtag
	wear_suit = /obj/item/clothing/suit/storage/marine/officer/req //it's pas
	glasses = /obj/item/clothing/glasses/eyepatch
	w_uniform = /obj/item/clothing/under/marine/service
	mask = /obj/item/clothing/mask/cigarette/pipe
	head = /obj/item/clothing/head/servicecap
	back = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/marine
	gloves = /obj/item/clothing/gloves/marine/black
	l_store = /obj/item/storage/pouch/medkit/firstaid
	r_store = /obj/item/storage/holster/flarepouch/full
	suit_store = /obj/item/weapon/gun/rifle/m41a/magharness
	ears = /obj/item/radio/headset/distress/retired

/datum/outfit/job/retired/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m41a, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m41a, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m41a, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m41a, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m41a, SLOT_IN_BELT)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/m41a, SLOT_IN_BELT)

	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/snacks/burger/tofu, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/flask/marine, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/storage/fancy/chemrettes, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_SUIT)

/datum/job/retired/leader
	title = "TGMC retired veteran expedition leader"
	paygrade = "LtCol"
	skills_type = /datum/skills/veteran_captain //The leader gets even more skills
	outfit = /datum/outfit/job/retired/leader

/datum/outfit/job/retired/leader
	name = "TGMC retired veteran expedition leader"
	jobtype = /datum/job/retired/leader

	id = /obj/item/card/id/dogtag/fc
	head = /obj/item/clothing/head/tgmcberet/fc
	gloves = /obj/item/clothing/gloves/marine/officer
	w_uniform = /obj/item/clothing/under/marine/officer/exec
	belt = /obj/item/storage/holster/blade/officer/full
	suit_store = /obj/item/storage/holster/belt/mateba/full
	back = /obj/item/ammo_magazine/minigun_wheelchair

/datum/outfit/job/retired/leader/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.equip_to_slot_or_del(new /obj/item/storage/fancy/chemrettes, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_SUIT)

	H.amputate_limb(BODY_ZONE_L_LEG)
	H.amputate_limb(BODY_ZONE_R_LEG)
	var/obj/vehicle/ridden/wheelchair/weaponized/wheelchair = new(H.drop_location())
	wheelchair.buckle_mob(H, TRUE)

/datum/job/retired/augmented
	title = "TGMC augmented veteran"
	outfit = /datum/outfit/job/retired/augmented

/datum/outfit/job/retired/augmented
	name = "TGMC augmented veteran"
	jobtype = /datum/job/retired/augmented

/datum/outfit/job/retired/augmented/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..() // Same gear as the regular outfit, but we give them some robot limbs
	for(var/i in 1 to 2)
		var/datum/limb/picked_limb = H.get_limb(pick_n_take(list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)))
		picked_limb.robotize()

