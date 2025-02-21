/datum/outfit/job/pmc/standard
	name = "PMC Standard"
	jobtype = /datum/job/pmc/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/holster
	shoes = /obj/item/clothing/shoes/marine/pmc/full
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc
	mask = /obj/item/clothing/mask/gas/pmc/leader
	suit_store = /obj/item/weapon/gun/smg/m25/elite/pmc
	r_pocket = /obj/item/storage/pouch/grenade
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/satchel

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/explosive/plastique = 1,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/smg/m25/ap = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/food/snacks/enrg_bar = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/smg/m25/ap = 6,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/vp70 = 3,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/pmc = 4,
		/obj/item/explosive/grenade/smokebomb/drain = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
	)


/datum/outfit/job/pmc/gunner
	name = "PMC Gunner"
	jobtype = /datum/job/pmc/gunner

	id = /obj/item/card/id/silver
	belt = /obj/item/belt_harness/marine
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/holster
	shoes = /obj/item/clothing/shoes/marine/pmc/full
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner
	mask = /obj/item/clothing/mask/gas/pmc
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun/pmc
	r_pocket = /obj/item/storage/pouch/explosive
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/ammo_magazine/standard_smartmachinegun = 4,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/standard_smartmachinegun = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/food/snacks/enrg_bar = 1,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/vp70 = 3,
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/mine/pmc = 2,
		/obj/item/explosive/grenade/pmc = 2,
	)


/datum/outfit/job/pmc/sniper
	name = "PMC Sniper"
	jobtype = /datum/job/pmc/sniper

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/holster/belt/pistol/m4a3/vp70_pmc
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/webbing
	shoes = /obj/item/clothing/shoes/marine/pmc/full
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/sniper
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/sniper
	mask = /obj/item/clothing/mask/gas/pmc
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	suit_store = /obj/item/weapon/gun/rifle/sniper/elite
	r_pocket = /obj/item/storage/pouch/magazine/large/pmc_sniper
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/satchel

	backpack_contents = list(
		/obj/item/ammo_magazine/sniper/elite = 2,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/explosive_mines/pmc = 1,
		/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread = 1,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/sniper/elite = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/food/snacks/enrg_bar = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/smokebomb/drain = 2,
		/obj/item/explosive/grenade/pmc = 2,
		/obj/item/binoculars/tactical/range = 1,
	)

/datum/outfit/job/pmc/leader
	name = "PMC Leader"
	jobtype = /datum/job/pmc/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/leader/holster
	shoes = /obj/item/clothing/shoes/marine/pmc/full
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/leader
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/leader
	mask = /obj/item/clothing/mask/gas/pmc/leader
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	suit_store = /obj/item/weapon/gun/rifle/m412/elite
	r_pocket = /obj/item/storage/pouch/grenade
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/satchel

	backpack_contents = list(
		/obj/item/ammo_magazine/rifle/ap = 2,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/pmc = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/food/snacks/enrg_bar = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/ap = 6,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/vp78 = 3,
		/obj/item/weapon/gun/pistol/vp78/pmc = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/impact = 4,
		/obj/item/explosive/grenade/smokebomb/drain = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
	)
