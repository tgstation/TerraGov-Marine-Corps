/datum/outfit/job/special_forces/standard
	name = "Special Response Force Standard"
	jobtype = /datum/job/special_forces/standard

	glasses = /obj/item/clothing/glasses/night
	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	mask = /obj/item/clothing/mask/gas/specops
	w_uniform = /obj/item/clothing/under/marine/specops
	shoes = /obj/item/clothing/shoes/marine/srf/full
	wear_suit = /obj/item/clothing/suit/storage/marine/specops
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/modular/m10x
	suit_store = /obj/item/weapon/gun/smg/m25/elite/suppressed
	r_pocket = /obj/item/storage/pouch/grenade
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/ammo_magazine/smg/m25/ap = 2,
		/obj/item/explosive/plastique = 2,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 2,
		/obj/item/stack/medical/splint = 1,
	)

	head_contents = list(
		/obj/item/clothing/glasses/mgoggles = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/smg/m25/ap = 6,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/g22 = 3,
		/obj/item/weapon/gun/pistol/g22 = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/m15 = 4,
		/obj/item/explosive/grenade/smokebomb/cloak = 2,
	)

/datum/outfit/job/special_forces/breacher
	name = "Special Response Force Breacher"
	jobtype = /datum/job/special_forces/breacher

	glasses = /obj/item/clothing/glasses/night
	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	mask = /obj/item/clothing/mask/gas/specops
	w_uniform = /obj/item/clothing/under/marine/specops
	shoes = /obj/item/clothing/shoes/marine/srf/full
	wear_suit = /obj/item/clothing/suit/storage/marine/specops/support
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/modular/m10x
	suit_store = /obj/item/weapon/gun/smg/m25/elite/suppressed/breacher
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pouch/medkit/firstaid
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/ammo_magazine/smg/m25/ap = 2,
		/obj/item/explosive/plastique = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 3,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 2,
		/obj/item/stack/medical/splint = 1,
		/obj/item/explosive/grenade/m15 = 2,
	)

	head_contents = list(
		/obj/item/clothing/glasses/mgoggles = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/smg/m25/ap = 6,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/g22 = 3,
		/obj/item/weapon/gun/pistol/g22 = 1,
	)


/datum/outfit/job/special_forces/drone_operator
	name = "Special Response Force Drone Operator"
	jobtype = /datum/job/special_forces/drone_operator

	glasses = /obj/item/clothing/glasses/night
	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	mask = /obj/item/clothing/mask/gas/specops
	w_uniform = /obj/item/clothing/under/marine/specops
	shoes = /obj/item/clothing/shoes/marine/srf/full
	wear_suit = /obj/item/clothing/suit/storage/marine/specops/support
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/modular/m10x/welding
	suit_store = /obj/item/weapon/gun/smg/m25/elite/suppressed
	r_pocket = /obj/item/storage/pouch/grenade
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/explosive/plastique = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread = 1,
		/obj/item/tool/weldingtool/largetank = 1,
		/obj/item/tool/wrench = 1,
		/obj/item/ammo_magazine/box11x35mm = 2,
		/obj/item/uav_turret = 1,
		/obj/item/deployable_vehicle = 1,
		/obj/item/unmanned_vehicle_remote = 1,
	)

	head_contents = list(
		/obj/item/clothing/glasses/mgoggles = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/smg/m25/ap = 6,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/g22 = 3,
		/obj/item/weapon/gun/pistol/g22 = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/m15 = 4,
		/obj/item/explosive/grenade/smokebomb/cloak = 2,
	)

/datum/outfit/job/special_forces/medic
	name = "Special Response Force Medic"
	jobtype = /datum/job/special_forces/medic

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	w_uniform = /obj/item/clothing/under/marine/specops
	belt = /obj/item/storage/belt/lifesaver/full
	wear_suit = /obj/item/clothing/suit/storage/marine/specops/medic
	head = /obj/item/clothing/head/modular/m10x
	shoes = /obj/item/clothing/shoes/marine/srf/full
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/m25/elite/suppressed
	r_pocket = /obj/item/storage/pouch/medical_injectors/medic
	l_pocket = /obj/item/storage/pouch/magazine/large
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/roller = 1,
		/obj/item/tweezers = 1,
		/obj/item/tool/crowbar = 1,
	)

	head_contents = list(
		/obj/item/clothing/glasses/mgoggles = 1,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/g22 = 3,
		/obj/item/weapon/gun/pistol/g22 = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/smg/m25/ap = 3,
	)

/datum/outfit/job/special_forces/leader
	name = "Special Response Force Leader"
	jobtype = /datum/job/special_forces/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/dutch
	mask = /obj/item/clothing/mask/gas/specops
	w_uniform = /obj/item/clothing/under/marine/specops
	glasses = /obj/item/clothing/glasses/night
	shoes = /obj/item/clothing/shoes/marine/srf/full
	wear_suit = /obj/item/clothing/suit/storage/marine/specops/leader
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/beret/sec
	suit_store = /obj/item/weapon/gun/rifle/m16/spec_op
	r_pocket = /obj/item/storage/pouch/shotgun
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/m16 = 2,
		/obj/item/defibrillator/civi = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat = 1,
		/obj/item/stack/medical/splint = 1,
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade/incendiary = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/m16 = 6,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/g22 = 3,
		/obj/item/weapon/gun/pistol/g22 = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/ammo_magazine/handful/incendiary = 2,
	)
