/*=============================STANDARD==================================*/

// SMG RA-VAL
/datum/outfit/job/pmc/standard
	name = "PMC Standard"
	jobtype = /datum/job/pmc/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/holster
	shoes = /obj/item/clothing/shoes/marine/pmc/elite_full
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc_elite
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard
	mask = /obj/item/clothing/mask/gas/pmc
	suit_store = /obj/item/weapon/gun/smg/val/pmc_standard
	r_pocket = /obj/item/storage/pouch/grenade
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/satchel/pmc

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/ammo_magazine/pistol/mk90 = 1
	)

	suit_contents = list(
		/obj/item/ammo_magazine/smg/val = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/food/snacks/enrg_bar = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/smg/val = 6,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/mk90 = 3,
		/obj/item/weapon/gun/pistol/mk90/pmc_standard = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/pmc = 4,
		/obj/item/explosive/grenade/smokebomb/drain = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
	)

// AR RA-SH-416

/datum/outfit/job/pmc/standard/m416
	suit_store = /obj/item/weapon/gun/rifle/m416/pmc_standard

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/m416 = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/m416 = 6,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/sticky/pmc = 4,
		/obj/item/explosive/grenade/smokebomb/drain = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
	)

// COSMETIC LOADOUTS
// SMG RA-VAL
/datum/outfit/job/pmc/standard/sarge
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/sarge

/datum/outfit/job/pmc/standard/sargetwo
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/sarge
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/stripes

/datum/outfit/job/pmc/standard/sargethree
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/sarge
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/mantis

/datum/outfit/job/pmc/standard/sargefour
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/sarge
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/twoface

/datum/outfit/job/pmc/standard/joker
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/joker
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/twoface

/datum/outfit/job/pmc/standard/jokertwo
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/joker
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/mantis

/datum/outfit/job/pmc/standard/stripes
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/stripes

/datum/outfit/job/pmc/standard/stripestwo
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/stripes
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/stripes

/datum/outfit/job/pmc/standard/stripesthree
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/stripes
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/mantis

// AR RA-SH-416

/datum/outfit/job/pmc/standard/m416/sarge
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/sarge

/datum/outfit/job/pmc/standard/m416/sargetwo
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/sarge
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/stripes

/datum/outfit/job/pmc/standard/m416/sargethree
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/sarge
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/mantis

/datum/outfit/job/pmc/standard/m416/sargefour
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/sarge
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/twoface

/datum/outfit/job/pmc/standard/m416/joker
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/joker
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/twoface

/datum/outfit/job/pmc/standard/m416/jokertwo
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/joker
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/mantis

/datum/outfit/job/pmc/standard/m416/stripes
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/stripes

/datum/outfit/job/pmc/standard/m416/stripestwo
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/stripes
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/stripes

/datum/outfit/job/pmc/standard/m416/stripesthree
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/standard/stripes
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/standard/mantis

/*=============================SMARTGUNNER==================================*/

/datum/outfit/job/pmc/gunner
	name = "PMC Gunner"
	jobtype = /datum/job/pmc/gunner

	id = /obj/item/card/id/silver
	belt = /obj/item/belt_harness/marine
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/webbing
	shoes = /obj/item/clothing/shoes/marine/pmc/elite_full
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc_elite
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner
	mask = /obj/item/clothing/mask/gas/pmc
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun/pmc_gpmg/gunner
	r_pocket = /obj/item/storage/pouch/magazine/pistol/large
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack/pmc

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/ammo_magazine/smart_gpmg = 4,
		/obj/item/weapon/gun/pistol/smart_pistol/pmc = 1,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/smart_gpmg = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/food/snacks/enrg_bar = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/mine/pmc = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/explosive/grenade/pmc = 2,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/pistol/standard_pistol/smart_pistol = 6
	)

// COSMETIC LOADOUTS

/datum/outfit/job/pmc/gunner/sarge
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/sarge

/datum/outfit/job/pmc/gunner/sargetwo
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/sarge
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/skull

/datum/outfit/job/pmc/gunner/sargethree
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/sarge
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/hunter

/datum/outfit/job/pmc/gunner/sargefour
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/sarge
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/stripes

/datum/outfit/job/pmc/gunner/stripes
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/stripes

/datum/outfit/job/pmc/gunner/stripestwo
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/stripes
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/skull

/datum/outfit/job/pmc/gunner/stripesthree
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/stripes
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/hunter

/datum/outfit/job/pmc/gunner/stripesfour
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/stripes
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/stripes

/datum/outfit/job/pmc/gunner/joker
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/joker
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/joker

/datum/outfit/job/pmc/gunner/jokertwo
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/joker
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/skull

/datum/outfit/job/pmc/gunner/jokerthree
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/joker
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/stripes

/datum/outfit/job/pmc/gunner/jokerfour
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/joker
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/hunter

/datum/outfit/job/pmc/sniper
	name = "PMC Sniper"
	jobtype = /datum/job/pmc/sniper

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/holster/belt/pistol/m4a3
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/webbing
	shoes = /obj/item/clothing/shoes/marine/pmc/elite_full
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/sniper
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc_elite
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/sniper
	mask = /obj/item/clothing/mask/gas/pmc
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	suit_store = /obj/item/weapon/gun/rifle/sniper/pmc_railgun
	r_pocket = /obj/item/storage/pouch/magazine/large
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack/pmc

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/plastique = 3,
		/obj/item/storage/box/explosive_mines/pmc = 1,
		/obj/item/reagent_containers/food/snacks/sliceable/sandwiches/meatbread = 1,
		/obj/item/ammo_magazine/railgun/pmc/hvap = 2,
		/obj/item/ammo_magazine/packet/p9mmap = 2,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/railgun/pmc/hvap = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/food/snacks/enrg_bar = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/pistol/mk90/extended = 6,
		/obj/item/weapon/gun/pistol/mk90/pmc_sniper = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/smokebomb/drain = 2,
		/obj/item/explosive/grenade/pmc = 2,
		/obj/item/binoculars/tactical/range = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/railgun/pmc = 3,
	)

/datum/outfit/job/pmc/leader
	name = "PMC Leader"
	jobtype = /datum/job/pmc/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/distress/pmc
	w_uniform = /obj/item/clothing/under/marine/veteran/pmc/leader/holster
	shoes = /obj/item/clothing/shoes/marine/pmc/elite_full
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/leader
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc_elite
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/leader
	mask = /obj/item/clothing/mask/gas/pmc/leader
	suit_store = /obj/item/weapon/gun/rifle/m416/elite/pmc_officer
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles
	r_pocket = /obj/item/storage/pouch/grenade
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack/pmc


	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/mk100_gyrojet = 3,
		/obj/item/weapon/gun/pistol/mk100_gyrojet/pmc_leader = 1,
	)

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/stack/medical/splint = 1,
		/obj/item/explosive/grenade/pmc = 2,
		/obj/item/ammo_magazine/pistol/mk100_gyrojet = 2,
	)

	head_contents = list(
		/obj/item/reagent_containers/food/snacks/enrg_bar = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/m416 = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/m416 = 6,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/impact = 4,
		/obj/item/explosive/grenade/smokebomb/drain = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
	)

/datum/outfit/job/pmc/leader/gunner
// Loadout of leader focused more into support, equipped with SG-25
	wear_suit = /obj/item/clothing/suit/storage/marine/veteran/pmc/gunner/leader
	head = /obj/item/clothing/head/helmet/marine/veteran/pmc/gunner/leader
	suit_store = /obj/item/weapon/gun/rifle/pmc_smartrifle/leader

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/standard_smartrifle = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/standard_smartrifle = 6,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/smokebomb/drain = 3,
		/obj/item/explosive/grenade/smokebomb/cloak = 3,
	)
