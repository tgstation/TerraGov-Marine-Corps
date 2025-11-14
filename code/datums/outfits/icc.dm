/datum/outfit/job/icc
	name = "ICC Standard"
	jobtype = /datum/job/icc

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine/icc
	ears = /obj/item/radio/headset/distress/icc
	w_uniform = /obj/item/clothing/under/icc/webbing
	shoes = /obj/item/clothing/shoes/marine/icc/knife
	wear_suit = /obj/item/clothing/suit/storage/marine/icc
	gloves = /obj/item/clothing/gloves/marine/icc
	head = /obj/item/clothing/head/helmet/marine/icc
	mask = /obj/item/clothing/mask/gas/icc

	head_contents = list(
		/obj/item/reagent_containers/food/snacks/wrapped/barcaridine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
	)

// Basic standard equipment
/datum/outfit/job/icc/standard
	name = "ICC Standard"
	jobtype = /datum/job/icc

	id = /obj/item/card/id/silver
	gloves = /obj/item/clothing/gloves/marine/icc/insulated
	r_pocket = /obj/item/storage/pouch/pistol/icc
	l_pocket = /obj/item/storage/pouch/medical_injectors/icc/firstaid
	back = /obj/item/storage/backpack/lightpack/icc

	backpack_contents = list(
		/obj/item/explosive/grenade/som = 5,
		/obj/item/ammo_magazine/pistol/icc_dpistol = 3,
		/obj/item/stack/sheet/metal/large_stack = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/tool/screwdriver = 1,
		/obj/item/tool/wrench = 1,
	)

	head_contents = list(
		/obj/item/explosive/plastique = 2,
	)

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/plastique = 4,
		/obj/item/storage/box/m94 = 1,
	)

	r_pocket_contents = list(
		/obj/item/weapon/gun/pistol/icc_dpistol = 1,
	)

/datum/outfit/job/icc/standard/mpi_km
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/standard
	belt_contents = list(
		/obj/item/ammo_magazine/rifle/mpi_km/black = 6,
	)

/datum/outfit/job/icc/standard/icc_pdw
	suit_store = /obj/item/weapon/gun/smg/icc_pdw/standard

	belt_contents = list(
		/obj/item/ammo_magazine/smg/icc_pdw = 6,
	)


/datum/outfit/job/icc/standard/icc_battlecarbine
	suit_store = /obj/item/weapon/gun/rifle/icc_battlecarbine/standard

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/icc_battlecarbine = 6,
	)

/datum/outfit/job/icc/standard/icc_assaultcarbine
	suit_store = /obj/item/weapon/gun/rifle/icc_assaultcarbine

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/icc_assaultcarbine = 6,
	)

/datum/outfit/job/icc/guard
	name = "ICC Guard"
	jobtype = /datum/job/icc/guard

	shoes = /obj/item/clothing/shoes/marine/icc/guard/knife
	wear_suit = /obj/item/clothing/suit/storage/marine/icc/guard
	gloves = /obj/item/clothing/gloves/marine/icc/guard
	head = /obj/item/clothing/head/helmet/marine/icc/guard
	back = /obj/item/storage/backpack/lightpack/icc

	backpack_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/som = 6,
		/obj/item/storage/box/m94 = 1,
	)

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/tramadol = 1,
	)


/datum/outfit/job/icc/guard/coilgun
	suit_store = /obj/item/weapon/gun/launcher/rocket/icc
	back = /obj/item/weapon/gun/rifle/icc_coilgun
	l_pocket = /obj/item/storage/pouch/explosive/icc
	r_pocket = /obj/item/storage/pouch/explosive/icc

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/icc_coilgun = 6,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rocket/icc/thermobaric = 2,
		/obj/item/ammo_magazine/rocket/icc/heat = 2,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rocket/icc = 4,
	)

	backpack_contents = null


/datum/outfit/job/icc/guard/icc_autoshotgun
	suit_store = /obj/item/weapon/gun/rifle/icc_coilgun
	back = /obj/item/weapon/gun/rifle/icc_autoshotgun/guard
	l_pocket = /obj/item/storage/pouch/magazine/large/icc
	r_pocket = /obj/item/storage/pouch/magazine/large/icc

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/icc_coilgun = 6,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/icc_autoshotgun/frag = 3,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/icc_autoshotgun = 3,
	)

	backpack_contents = null

/datum/outfit/job/icc/guard/icc_bagmg
	wear_suit = /obj/item/clothing/suit/storage/marine/icc/guard/heavy
	head = /obj/item/clothing/head/helmet/marine/icc/guard/heavy
	suit_store = /obj/item/weapon/gun/rifle/icc_coilgun
	back = /obj/item/storage/holster/icc_mg/full
	belt = /obj/item/ammo_magazine/icc_mg/belt
	l_pocket = /obj/item/storage/pouch/magazine/large/icc
	r_pocket = /obj/item/storage/pouch/magazine/large/icc

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/icc_coilgun = 3,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/icc_coilgun = 3,
	)

	backpack_contents = null

/datum/outfit/job/icc/medic
	name = "ICC Medic"
	jobtype = /datum/job/icc/medic

	id = /obj/item/card/id/silver
	gloves = /obj/item/clothing/gloves/marine/icc
	back = /obj/item/storage/backpack/lightpack/icc
	belt = /obj/item/storage/belt/lifesaver/icc/ert
	glasses = /obj/item/clothing/glasses/hud/health

	backpack_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/som = 6,
		/obj/item/defibrillator = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/weapon/gun/pistol/icc_dpistol = 1,
		/obj/item/ammo_magazine/pistol/icc_dpistol = 1,
	)

	suit_contents = list(
		/obj/item/reagent_containers/hypospray/advanced/combat_advanced = 1,
		/obj/item/tool/extinguisher = 1,
	)

	webbing_contents = list(
		/obj/item/roller = 1,
		/obj/item/tweezers = 1,
		/obj/item/storage/pill_bottle/spaceacillin = 1,
		/obj/item/reagent_containers/hypospray/advanced/nanoblood = 1,
		/obj/item/bodybag/cryobag = 1,
	)


/datum/outfit/job/icc/medic/icc_machinepistol
	suit_store = /obj/item/weapon/gun/smg/icc_machinepistol/medic
	l_pocket = /obj/item/storage/pouch/magazine/large/icc
	r_pocket = /obj/item/storage/pouch/magazine/large/icc

	backpack_contents = list(
		/obj/item/ammo_magazine/smg/icc_machinepistol = 3,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/smg/icc_machinepistol/hp = 3,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/smg/icc_machinepistol = 3,
	)


/datum/outfit/job/icc/medic/icc_sharpshooter
	suit_store = /obj/item/weapon/gun/rifle/icc_sharpshooter/medic
	l_pocket = /obj/item/storage/pouch/magazine/large/icc
	r_pocket = /obj/item/storage/pouch/magazine/large/icc

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/icc_sharpshooter = 3,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/icc_sharpshooter = 3,
	)


/datum/outfit/job/icc/leader
	name = "ICC Leader"
	jobtype = /datum/job/icc/leader

	shoes = /obj/item/clothing/shoes/marine/icc/knife
	wear_suit = /obj/item/clothing/suit/storage/marine/icc/guard
	gloves = /obj/item/clothing/gloves/marine/icc/guard
	head = /obj/item/clothing/head/helmet/marine/icc/guard
	back = /obj/item/storage/backpack/lightpack/icc/guard
	l_pocket = /obj/item/storage/pouch/medical_injectors/icc/firstaid
	r_pocket = /obj/item/storage/pouch/construction/icc/full

	backpack_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/som = 6,
		/obj/item/explosive/grenade/incendiary/som = 2,
		/obj/item/tool/extinguisher = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/storage/box/m94 = 1,
	)

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
	)

	webbing_contents = list(
		/obj/item/binoculars/tactical/range = 1,
		/obj/item/explosive/plastique = 4,
	)


/datum/outfit/job/icc/leader/ml101
	suit_store = /obj/item/weapon/gun/shotgun/pump/icc_heavyshotgun/icc_leader
	belt = /obj/item/storage/belt/shotgun/icc/mixed

/datum/outfit/job/icc/leader/icc_confrontationrifle
	belt = /obj/item/storage/belt/marine/icc
	suit_store = /obj/item/weapon/gun/rifle/icc_confrontationrifle/leader

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/icc_confrontationrifle = 6,
	)

/datum/outfit/job/icc/leader
	name = "ICC Leader"
	jobtype = /datum/job/icc/leader

	shoes = /obj/item/clothing/shoes/marine/icc/knife
	wear_suit = /obj/item/clothing/suit/storage/marine/icc/guard
	gloves = /obj/item/clothing/gloves/marine/icc/guard
	head = /obj/item/clothing/head/helmet/marine/icc/guard
	back = /obj/item/storage/backpack/lightpack/icc/guard
	l_pocket = /obj/item/storage/pouch/medical_injectors/icc/firstaid
	r_pocket = /obj/item/storage/pouch/construction/icc/full

	suit_contents = list(
		/obj/item/reagent_containers/food/snacks/wrapped/barcaridine = 2,
	)

	backpack_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/som = 6,
		/obj/item/storage/box/m94 = 1,
	)

	webbing_contents = list(
		/obj/item/binoculars/tactical/range = 1,
		/obj/item/explosive/plastique = 4,
	)

/datum/outfit/job/icc/leader/icc_heavyshotgun
	suit_store = /obj/item/weapon/gun/shotgun/pump/icc_heavyshotgun/icc_leader
	belt = /obj/item/storage/belt/shotgun/icc/mixed

/datum/outfit/job/icc/leader/icc_confrontationrifle
	belt = /obj/item/storage/belt/marine/icc
	suit_store = /obj/item/weapon/gun/rifle/icc_confrontationrifle/leader

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/icc_confrontationrifle = 6,
	)
