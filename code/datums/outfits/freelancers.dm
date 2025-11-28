//What all freelancers have shared in between them
/datum/outfit/job/freelancer
	name = "Freelancer"
	jobtype = /datum/job/freelancer

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/distress/dutch
	head = /obj/item/clothing/head/helmet/marine/freelancer
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer
	shoes = /obj/item/clothing/shoes/marine/brown/full
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

//===========================STANDARD================================

/datum/outfit/job/freelancer/standard
	wear_suit = /obj/item/clothing/suit/storage/marine/freelancer
	back = /obj/item/storage/backpack/lightpack/freelancer
	mask = /obj/item/clothing/mask/bandanna
	r_pocket = /obj/item/storage/pouch/grenade
	l_pocket = /obj/item/storage/pouch/medkit/freelancer

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/explosive/plastique = 1,
	)

	suit_contents = list(
		/obj/item/storage/pill_bottle/dylovene = 1,
		/obj/item/storage/pill_bottle/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
	)

// PR412 with UGL
/datum/outfit/job/freelancer/standard/m412
	name = "Freelancer Standard"
	jobtype = /datum/job/freelancer/standard

	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/rifle/m412/freelancer

	backpack_contents = list(
		/obj/item/ammo_magazine/packet/acp = 1,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 2,
		/obj/item/ammo_magazine/packet/p10x24mm = 3,
		/obj/item/explosive/grenade/m15 = 1,
		/obj/item/explosive/grenade/incendiary = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle = 6,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade = 6,
	)

// V10 pump shotgun
/datum/outfit/job/freelancer/standard/pump
	belt = /obj/item/storage/belt/shotgun/mixed
	suit_store = /obj/item/weapon/gun/shotgun/pump/freelancer

	backpack_contents = list(
		/obj/item/ammo_magazine/packet/p10x20mm = 1,
		/obj/item/weapon/gun/smg/standard_machinepistol/compact = 1,
		/obj/item/ammo_magazine/smg/standard_machinepistol = 2,
		/obj/item/ammo_magazine/handful/buckshot = 3,
		/obj/item/explosive/grenade/m15 = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 2,
		/obj/item/storage/box/explosive_mines = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/incendiary = 2,
	)

// AR-11
/datum/outfit/job/freelancer/standard/tx11
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancerone

	backpack_contents = list(
		/obj/item/ammo_magazine/packet/acp = 1,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 2,
		/obj/item/ammo_magazine/packet/p492x34mm = 3,
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade/incendiary = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/tx11 = 6,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/incendiary = 2,
	)
//===========================MEDIC================================

/datum/outfit/job/freelancer/medic
	name = "Freelancer Medic"
	jobtype = /datum/job/freelancer/medic

	head = /obj/item/clothing/head/helmet/marine/freelancer/medic
	mask = /obj/item/clothing/mask/gas/tactical/freelancer
	w_uniform = /obj/item/clothing/under/marine/veteran/freelancer/medic
	belt = /obj/item/storage/belt/lifesaver/quick
	wear_suit = /obj/item/clothing/suit/storage/marine/freelancer/medic
	glasses = /obj/item/clothing/glasses/hud/health
	back = /obj/item/storage/backpack/marine/corpsman/freelancer
	r_pocket = /obj/item/storage/pouch/grenade
	l_pocket = /obj/item/storage/pouch/magazine/large

	webbing_contents = list(
		/obj/item/bodybag/cryobag = 1,
		/obj/item/roller = 1,
		/obj/item/tweezers = 1,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/advanced/meraderm = 1,
		/obj/item/reagent_containers/hypospray/advanced/big/combatmix = 1,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/smokebomb/antigas = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 2,
		/obj/item/explosive/grenade/incendiary = 2,
	)

	suit_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/tool/extinguisher = 1,
	)

// SMG-25
/datum/outfit/job/freelancer/medic/m25
	suit_store = /obj/item/weapon/gun/smg/m25/vgrip

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 2,
		/obj/item/storage/pill_bottle/isotonic = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/ammo_magazine/packet/p10x20mm = 2,
		/obj/item/ammo_magazine/smg/m25 = 2,
		/obj/item/explosive/grenade/m15 = 2,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/smg/m25 = 3,
	)

/datum/outfit/job/freelancer/medic/marksman
	suit_store = /obj/item/weapon/gun/rifle/standard_dmr/freelancer

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 2,
		/obj/item/storage/pill_bottle/isotonic = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/ammo_magazine/packet/acp = 1,
		/obj/item/weapon/gun/pistol/standard_heavypistol/tactical = 1,
		/obj/item/ammo_magazine/pistol/standard_heavypistol = 2,
		/obj/item/ammo_magazine/packet/p10x27mm = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/standard_dmr = 3,
	)

//===========================VETERAN================================

/datum/outfit/job/freelancer/grenadier
	name = "Freelancer Veteran"
	jobtype = /datum/job/freelancer/grenadier

	head = /obj/item/clothing/head/helmet/marine/freelancer/heavy
	mask = /obj/item/clothing/mask/gas/tactical/freelancer
	back = /obj/item/storage/backpack/lightpack/freelancer
	l_pocket = /obj/item/storage/pouch/medkit/freelancer/leader

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/stack/medical/splint = 1,
	)

// ALF-51B CQB-er with disposable rockets
/datum/outfit/job/freelancer/grenadier/alf
	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/freelancer/heavy
	suit_store = /obj/item/weapon/gun/rifle/alf_machinecarbine/assault
	r_pocket = /obj/item/storage/pouch/grenade

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/ammo_magazine/pistol/heavy = 3,
		/obj/item/weapon/gun/pistol/heavy = 1,
		/obj/item/weapon/gun/launcher/rocket/oneuse = 3,
		/obj/item/explosive/plastique = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/alf_machinecarbine = 6,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/incendiary = 2,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/alf_machinecarbine = 4,
	)

// HPR gunner
/datum/outfit/job/freelancer/grenadier/hpr
	belt = /obj/item/storage/belt/sparepouch
	wear_suit = /obj/item/clothing/suit/storage/marine/freelancer/heavy/general
	suit_store = /obj/item/weapon/gun/rifle/m412l1_hpr/freelancer
	r_pocket = /obj/item/storage/pouch/grenade

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/weapon/gun/pistol/heavy = 1,
		/obj/item/ammo_magazine/pistol/heavy = 3,
		/obj/item/ammo_magazine/m412l1_hpr = 3,
		/obj/item/explosive/plastique = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/m412l1_hpr = 3,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/incendiary = 2,
	)


	suit_contents = list(
		/obj/item/ammo_magazine/m412l1_hpr = 2,
	)

// AR-55 grenadier
/datum/outfit/job/freelancer/grenadier/tx55
	belt = /obj/item/storage/belt/marine
	wear_suit = /obj/item/clothing/suit/storage/marine/freelancer/heavy
	suit_store = /obj/item/weapon/gun/rifle/tx55/freelancer_custom/grenadier
	r_pocket = /obj/item/storage/pouch/magazine/large

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/weapon/gun/pistol/heavy = 1,
		/obj/item/ammo_magazine/pistol/heavy = 3,
		/obj/item/ammo_magazine/packet/p10x24mm = 2,
		/obj/item/ammo_magazine/rifle/standard_assaultrifle = 1,
		/obj/item/explosive/plastique = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/tx54/incendiary = 3,
		/obj/item/ammo_magazine/rifle/tx54 = 3,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/standard_assaultrifle = 3,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/tx54/incendiary = 2,
		/obj/item/ammo_magazine/rifle/tx54 = 2,
	)
//===========================SPECIALIST================================

/datum/outfit/job/freelancer/specialist
	name = "Freelancer Specialist"
	jobtype = /datum/job/freelancer/specialist

	glasses = /obj/item/clothing/glasses/meson
	mask = /obj/item/clothing/mask/gas/tactical/freelancer
	l_pocket = /obj/item/storage/pouch/medkit/freelancer/leader

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/stack/medical/splint = 1,
	)

// RL-160 recoilless rifle
/datum/outfit/job/freelancer/specialist/rocketeer
	head = /obj/item/clothing/head/helmet/marine/freelancer/specialist
	wear_suit = /obj/item/clothing/suit/storage/marine/freelancer/heavy/spec
	belt = /obj/item/storage/belt/marine
	suit_store = /obj/item/weapon/gun/smg/standard_smg/freelancer
	back = /obj/item/storage/holster/backholster/rpg/freelancer/full
	r_pocket = /obj/item/storage/pouch/grenade

	belt_contents = list(
		/obj/item/ammo_magazine/smg/standard_smg/ap = 6,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/packet/p10x20mm/ap = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/binoculars = 1,
		/obj/item/explosive/plastique = 3,
	)

	r_pocket_contents = list(
		/obj/item/explosive/grenade/m15 = 4,
		/obj/item/explosive/grenade/incendiary = 2,
	)

// flamer with wide nozzle
/datum/outfit/job/freelancer/specialist/flamer
	head = /obj/item/clothing/head/helmet/marine/freelancer/specialist/pyro
	wear_suit = /obj/item/clothing/suit/storage/marine/freelancer/pyro
	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/smg/standard_smg/freelancer
	back = /obj/item/weapon/gun/flamer/big_flamer/marinestandard/wide
	r_pocket = /obj/item/storage/pouch/magazine/large

	belt_contents = list(
		/obj/item/ammo_magazine/flamer_tank/large = 3,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/packet/p10x20mm/ap = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/binoculars = 1,
		/obj/item/ammo_magazine/flamer_tank/large = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/smg/standard_smg/ap = 3,
	)
//===========================LEADER================================

/datum/outfit/job/freelancer/leader
	name = "Freelancer Leader"
	jobtype = /datum/job/freelancer/leader

	head = /obj/item/clothing/head/helmet/marine/freelancer/beret
	mask = /obj/item/clothing/mask/bandanna
	glasses = /obj/item/clothing/glasses/hud/health
	wear_suit = /obj/item/clothing/suit/storage/marine/freelancer/heavy/valk
	back = /obj/item/storage/backpack/lightpack/freelancer
	l_pocket = /obj/item/storage/pouch/medkit/freelancer/leader
	r_pocket = /obj/item/storage/pouch/magazine/pistol/large

	webbing_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/binoculars/tactical = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/pistol/heavy = 6,
	)

// PR-11
/datum/outfit/job/freelancer/leader/m41a
	belt = /obj/item/storage/belt/grenade/b17
	suit_store = /obj/item/weapon/gun/rifle/m41a/freelancer_custom/leader

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/weapon/gun/pistol/heavy/gold = 1,
		/obj/item/ammo_magazine/packet/p10x24mm = 3,
		/obj/item/ammo_magazine/rifle/m41a = 2,
		/obj/item/explosive/grenade/smokebomb/antigas = 1,
		/obj/item/explosive/plastique = 2,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/m41a = 4,
	)

/// AR-55
/datum/outfit/job/freelancer/leader/tx55
	suit_store = /obj/item/weapon/gun/rifle/tx55/freelancer_custom/leader
	belt = /obj/item/storage/belt/marine

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/weapon/gun/pistol/heavy/gold = 1,
		/obj/item/ammo_magazine/packet/p10x24mm = 2,
		/obj/item/ammo_magazine/rifle/tx54/incendiary = 1,
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade/smokebomb/antigas = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/explosive/plastique = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/tx54/incendiary = 2,
		/obj/item/ammo_magazine/rifle/tx54/he = 2,
		/obj/item/ammo_magazine/rifle/tx54 = 2,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/standard_assaultrifle = 4,
	)

/// AR-11
/datum/outfit/job/freelancer/leader/tx11
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancer_custom/leader
	belt = /obj/item/belt_harness/marine

	backpack_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/weapon/gun/pistol/heavy/gold = 1,
		/obj/item/ammo_magazine/packet/p492x34mm = 3,
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade/smokebomb/antigas = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/explosive/plastique = 2,
	)

	suit_contents = list(
		/obj/item/ammo_magazine/rifle/tx11 = 4,
	)
