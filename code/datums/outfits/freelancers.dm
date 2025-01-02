//What all freelancers have shared in between them
/datum/outfit/job/freelancer
	name = "Freelancer"
	jobtype = /datum/job/freelancer

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	mask = /obj/item/clothing/mask/rebreather/scarf/freelancer
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer
	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/frelancer
	back = /obj/item/storage/backpack/lightpack
	l_pocket = /obj/item/storage/pouch/medkit/firstaid

	backpack_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/reagent_containers/food/snacks/burger/tofu = 1,
		/obj/item/reagent_containers/food/drinks/flask/marine = 1,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

	shoe_contents = list(
		/obj/item/weapon/combat_knife = 1,
	)

/datum/outfit/job/freelancer/standard
	name = "Freelancer Standard"
	jobtype = /datum/job/freelancer/standard

	backpack_contents = list(
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/stack/sheet/metal/small_stack = 1,
		/obj/item/stack/sheet/plasteel/medium_stack = 1,
	)

/datum/outfit/job/freelancer/standard/one
	suit_store = /obj/item/weapon/gun/rifle/m16/freelancer
	r_pocket = /obj/item/storage/pouch/shotgun

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/m16 = 2,
		/obj/item/ammo_magazine/pistol/g22 = 3,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/m16 = 6,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 4,
	)


///m16 ugl
/datum/outfit/job/freelancer/standard/two
	suit_store = /obj/item/weapon/gun/rifle/m16/ugl
	r_pocket = /obj/item/storage/pouch/grenade

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/m16 = 2,
		/obj/item/ammo_magazine/pistol/g22 = 3,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/m16 = 6,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade = 4,
		/obj/item/explosive/grenade/incendiary = 2,
	)


///tx11
/datum/outfit/job/freelancer/standard/three
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancerone
	r_pocket = /obj/item/storage/pouch/grenade

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/tx11 = 2,
		/obj/item/ammo_magazine/pistol/g22 = 3,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/tx11 = 6,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade = 4,
		/obj/item/explosive/grenade/incendiary = 2,
	)


/datum/outfit/job/freelancer/medic
	name = "Freelancer Medic"
	jobtype = /datum/job/freelancer/medic

	belt = /obj/item/storage/belt/lifesaver/full
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/medic
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/rifle/famas/freelancermedic
	r_pocket = /obj/item/storage/pouch/medical_injectors/medic
	l_pocket = /obj/item/storage/pouch/magazine/large

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/roller = 1,
		/obj/item/tweezers = 1,
		/obj/item/ammo_magazine/rifle/famas = 2,
		/obj/item/ammo_magazine/pistol/g22 = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/famas = 3,
	)

	suit_contents = null

/datum/outfit/job/freelancer/grenadier
	name = "Freelancer Veteran"
	jobtype = /datum/job/freelancer/grenadier
	r_pocket = /obj/item/storage/pouch/grenade

	r_pocket_contents = list(
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 2,
		/obj/item/explosive/grenade/incendiary = 2,
	)

/datum/outfit/job/freelancer/grenadier/one
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer/veteran
	suit_store = /obj/item/weapon/gun/rifle/alf_machinecarbine/freelancer

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/alf_machinecarbine = 2,
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/stack/sheet/plasteel/medium_stack = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 3,
		/obj/item/tool/extinguisher/mini = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/alf_machinecarbine = 6,
	)


///machine gunner
/datum/outfit/job/freelancer/grenadier/two
	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/rifle/m412l1_hpr/freelancer

	backpack_contents = list(
		/obj/item/ammo_magazine/m412l1_hpr = 4,
		/obj/item/ammo_magazine/pistol/vp70 = 3,
		/obj/item/tool/extinguisher/mini = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/m412l1_hpr = 3,
	)


///actual grenadier
/datum/outfit/job/freelancer/grenadier/three
	suit_store = /obj/item/weapon/gun/rifle/tx55/freelancer
	r_pocket = /obj/item/storage/pouch/magazine/large

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/tx54 = 2,
		/obj/item/ammo_magazine/rifle/tx54/incendiary = 2,
		/obj/item/ammo_magazine/pistol/vp70 = 2,
		/obj/item/tool/extinguisher/mini = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/standard_carbine = 2,
		/obj/item/ammo_magazine/rifle/tx54 = 2,
		/obj/item/ammo_magazine/rifle/tx54/incendiary = 2,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/standard_carbine = 3,
	)


/datum/outfit/job/freelancer/leader
	name = "Freelancer Leader"
	jobtype = /datum/job/freelancer/leader

/datum/outfit/job/freelancer/leader
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer/veteran
	head = /obj/item/clothing/head/frelancer/beret
	glasses = /obj/item/clothing/glasses/hud/health

	backpack_contents = list(
		/obj/item/stack/sheet/metal/large_stack = 1,
	)

	suit_contents = null //leaders have a snowflake storage module which populates its own contents

/datum/outfit/job/freelancer/leader/one
	belt = /obj/item/storage/belt/grenade/b17
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/leader
	suit_store = /obj/item/weapon/gun/rifle/m16/freelancer
	r_pocket = /obj/item/storage/pouch/shotgun

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/m16 = 3,
		/obj/item/ammo_magazine/pistol/vp70 = 2,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 4,
	)


///tx11
/datum/outfit/job/freelancer/leader/two
	belt = /obj/item/belt_harness/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/leader/two
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancertwo
	r_pocket = /obj/item/storage/pouch/grenade

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/tx11 = 3,
		/obj/item/ammo_magazine/pistol/vp70 = 2,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade = 4,
		/obj/item/explosive/grenade/incendiary = 2,
	)


///tx55
/datum/outfit/job/freelancer/leader/three
	wear_suit = /obj/item/clothing/suit/storage/faction/freelancer/leader/three
	suit_store = /obj/item/weapon/gun/rifle/tx55/freelancer
	r_pocket = /obj/item/storage/pouch/magazine/large

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/standard_carbine = 3,
		/obj/item/ammo_magazine/pistol/vp70 = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/standard_carbine = 2,
		/obj/item/ammo_magazine/rifle/tx54 = 2,
		/obj/item/ammo_magazine/rifle/tx54/incendiary = 2,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/standard_carbine = 3,
	)
