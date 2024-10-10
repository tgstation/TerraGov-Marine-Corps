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
	l_pocket = /obj/item/storage/pouch/medkit/firstaid
	r_pocket = /obj/item/storage/holster/flarepouch/full
	suit_store = /obj/item/weapon/gun/rifle/m41a/magharness
	ears = /obj/item/radio/headset/distress/retired
	shoes = /obj/item/clothing/shoes/marine/brown/full

	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/burger/tofu = 1,
		/obj/item/reagent_containers/food/drinks/flask/marine = 1,
		/obj/item/explosive/grenade/incendiary = 2,
		/obj/item/explosive/grenade = 4,
	)

	suit_contents = list(
		/obj/item/storage/fancy/chemrettes = 1,
		/obj/item/explosive/grenade/m15 = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/m41a = 6,
	)

/datum/outfit/job/retired/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/list/limbs = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	for(var/i in 1 to 2)
		var/datum/limb/picked_limb = H.get_limb(pick_n_take(limbs))
		picked_limb.robotize()


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
	shoes = null

	suit_contents = list(
		/obj/item/storage/fancy/chemrettes = 1,
		/obj/item/explosive/grenade/m15 = 1,
	)

	belt_contents = null
	backpack_contents = null

/datum/outfit/job/retired/leader/post_equip(mob/living/carbon/human/H, visualsOnly)
	H.amputate_limb(BODY_ZONE_L_LEG)
	H.amputate_limb(BODY_ZONE_R_LEG)
	var/obj/vehicle/ridden/wheelchair/weaponized/wheelchair = new(H.drop_location())
	wheelchair.buckle_mob(H, TRUE)
