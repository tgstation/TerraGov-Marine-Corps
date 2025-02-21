/datum/outfit/job/som/ert
	id = /obj/item/card/id/dogtag/som

//Base SOM standard outfit
/datum/outfit/job/som/ert/standard
	name = "SOM Marine"
	jobtype = /datum/job/som/ert/standard

	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/medstorage
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som
	r_pocket = /obj/item/storage/pouch/firstaid/som/full
	l_pocket = /obj/item/storage/pouch/grenade/som/ert
	back = /obj/item/storage/backpack/lightpack/som

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

/datum/outfit/job/som/ert/standard/standard_assaultrifle
	suit_store = /obj/item/weapon/gun/rifle/som/mag_harness
	belt = /obj/item/storage/belt/marine/som/som_rifle

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/som = 2,
		/obj/item/ammo_magazine/rifle/som = 2,
		/obj/item/storage/box/m94 = 1,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/handful/micro_grenade = 2,
		/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/cluster = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst = 1,
	)

/datum/outfit/job/som/ert/standard/standard_smg
	suit_store = /obj/item/weapon/gun/smg/som/support
	belt = /obj/item/storage/belt/marine/som/som_smg

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/som = 2,
		/obj/item/ammo_magazine/smg/som = 3,
		/obj/item/storage/box/m94 = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 2,
		/obj/item/binoculars = 1,
	)

/datum/outfit/job/som/ert/standard/standard_shotgun
	back = /obj/item/storage/backpack/satchel/som
	belt = /obj/item/storage/belt/shotgun/som/mixed
	wear_suit = /obj/item/clothing/suit/modular/som/light/shield
	suit_store = /obj/item/weapon/gun/shotgun/som/standard

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 2,
		/obj/item/binoculars = 1,
	)

/datum/outfit/job/som/ert/standard/charger
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/magharness
	belt = /obj/item/storage/belt/marine/som/volkite

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/som = 2,
		/obj/item/cell/lasgun/volkite = 2,
		/obj/item/storage/box/m94 = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 2,
		/obj/item/tool/extinguisher/mini = 1,
	)

//Base SOM medic outfit
/datum/outfit/job/som/ert/medic
	name = "SOM Medic"
	jobtype = /datum/job/som/ert/medic

	belt = /obj/item/storage/belt/lifesaver/som/quick
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/medic/vest
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som
	gloves = /obj/item/clothing/gloves/marine/som
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som
	glasses = /obj/item/clothing/glasses/hud/health
	r_pocket = /obj/item/storage/pouch/magazine/large/som
	l_pocket = /obj/item/storage/pouch/grenade/som/ert
	back = /obj/item/storage/backpack/lightpack/som

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = 1,
	)

	webbing_contents = list(
		/obj/item/roller = 1,
		/obj/item/tweezers_advanced = 1,
		/obj/item/storage/pill_bottle/spaceacillin = 1,
		/obj/item/reagent_containers/hypospray/advanced/nanoblood = 1,
		/obj/item/bodybag/cryobag = 1,
		/obj/item/reagent_containers/hypospray/advanced/combat_advanced = 1,
	)

/datum/outfit/job/som/ert/medic/standard_assaultrifle
	suit_store = /obj/item/weapon/gun/rifle/som/mag_harness

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/ammo_magazine/rifle/som = 3,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 1,
		/obj/item/ammo_magazine/handful/micro_grenade = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/tool/crowbar/red = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/som = 3,
	)


/datum/outfit/job/som/ert/medic/standard_smg
	suit_store = /obj/item/weapon/gun/smg/som/support

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/ammo_magazine/smg/som = 6,
		/obj/item/tool/extinguisher = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/tool/crowbar/red = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/smg/som = 3,
	)


/datum/outfit/job/som/ert/medic/standard_shotgun
	r_pocket = /obj/item/storage/pouch/shotgun/som
	suit_store = /obj/item/weapon/gun/shotgun/som/support

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/ammo_magazine/handful/flechette = 6,
		/obj/item/tool/extinguisher = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/tool/crowbar/red = 1,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/handful/flechette = 4,
	)

//Base SOM veteran outfit
/datum/outfit/job/som/ert/veteran
	name = "SOM Veteran"
	jobtype = /datum/job/som/ert/veteran

	belt = /obj/item/storage/belt/marine/som/volkite
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/veteran/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/veteran
	glasses = /obj/item/clothing/glasses/meson
	r_pocket = /obj/item/storage/pouch/firstaid/som/full
	l_pocket = /obj/item/storage/pouch/grenade/som/ert
	back = /obj/item/storage/backpack/lightpack/som

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

/datum/outfit/job/som/ert/veteran/charger
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet

	backpack_contents = list(
		/obj/item/explosive/grenade/som = 1,
		/obj/item/ammo_magazine/pistol/highpower = 2,
		/obj/item/weapon/gun/pistol/highpower = 1,
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/cell/lasgun/volkite = 3,
		/obj/item/tool/crowbar/red = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)

/datum/outfit/job/som/ert/veteran/breacher_vet
	head = /obj/item/clothing/head/modular/som/lorica
	glasses = /obj/item/clothing/glasses/welding
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	l_hand = /obj/item/weapon/shield/riot/marine/som

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	backpack_contents = list(
		/obj/item/tool/extinguisher = 1,
		/obj/item/tool/weldingtool/largetank = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/cell/lasgun/volkite = 4,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/som = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/explosive/grenade/incendiary/som = 2,
	)


/datum/outfit/job/som/ert/veteran/caliver
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/somvet

	backpack_contents = list(
		/obj/item/explosive/grenade/som = 1,
		/obj/item/ammo_magazine/pistol/highpower = 2,
		/obj/item/weapon/gun/pistol/highpower = 1,
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/cell/lasgun/volkite = 3,
		/obj/item/tool/crowbar/red = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)


/datum/outfit/job/som/ert/veteran/caliver_pack
	belt = /obj/item/storage/belt/grenade/som
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/somvet
	l_pocket = /obj/item/storage/pouch/pistol/som
	back = /obj/item/cell/lasgun/volkite/powerpack

	belt_contents = list(
		/obj/item/explosive/grenade/smokebomb/som = 2,
		/obj/item/explosive/grenade/smokebomb/satrapine = 2,
		/obj/item/explosive/grenade/som = 3,
		/obj/item/explosive/grenade/incendiary/som = 2,
	)

	webbing_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/ammo_magazine/pistol/highpower = 2,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)

	l_pocket_contents = list(
		/obj/item/weapon/gun/pistol/highpower = 1,
	)

/datum/outfit/job/som/ert/veteran/culverin
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	back = /obj/item/cell/lasgun/volkite/powerpack

	webbing_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)

/datum/outfit/job/som/ert/veteran/rpg
	head = /obj/item/clothing/head/modular/som/bio
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/mithridatius
	suit_store = /obj/item/weapon/gun/smg/som/support
	belt = /obj/item/storage/belt/marine/som
	back = /obj/item/storage/holster/backholster/rpg/som/ert
	l_pocket = /obj/item/storage/pouch/grenade/som

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/smg/som = 2,
		/obj/item/ammo_magazine/smg/som/rad = 4,
	)

	webbing_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/binoculars = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/ammo_magazine/smg/som/incendiary = 1,
		/obj/item/storage/box/MRE/som = 1,
	)

	l_pocket_contents = list(
		/obj/item/explosive/grenade/smokebomb/som = 2,
		/obj/item/explosive/grenade/smokebomb/satrapine = 2,
		/obj/item/explosive/grenade/rad = 2,
	)

/datum/outfit/job/som/ert/veteran/pyro
	head = /obj/item/clothing/head/modular/som/hades
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/pyro/genstorage
	belt = /obj/item/storage/holster/belt/pistol/m4a3/som
	back = /obj/item/ammo_magazine/flamer_tank/backtank
	suit_store = /obj/item/weapon/gun/flamer/som/mag_harness

	suit_contents = list(
		/obj/item/tool/extinguisher = 1,
		/obj/item/explosive/grenade/som = 1,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/pistol/som/extended = 3,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/tool/crowbar/red = 1,
	)

	belt_contents = list(
		/obj/item/weapon/gun/pistol/som/burst = 1,
		/obj/item/ammo_magazine/pistol/som/extended = 6,
	)


/datum/outfit/job/som/ert/veteran/shotgunner
	belt = /obj/item/storage/belt/shotgun/som/flechette
	wear_suit = /obj/item/clothing/suit/modular/som/light/shield
	suit_store = /obj/item/weapon/gun/shotgun/som/burst/ert

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 5,
		/obj/item/weapon/gun/pistol/som/standard = 1,
		/obj/item/tool/extinguisher = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/incendiary/som = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/binoculars = 1,
	)

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

//Base SOM leader outfit
/datum/outfit/job/som/ert/leader
	name = "SOM Leader"
	jobtype = /datum/job/som/ert/leader

	belt = /obj/item/storage/belt/marine/som/volkite
	ears = /obj/item/radio/headset/distress/som
	w_uniform = /obj/item/clothing/under/som/leader/webbing
	shoes = /obj/item/clothing/shoes/marine/som/knife
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/leader/valk
	gloves = /obj/item/clothing/gloves/marine/som/veteran
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/som/leader
	glasses = /obj/item/clothing/glasses/hud/health
	r_pocket = /obj/item/storage/pouch/firstaid/som/combat_patrol_leader
	l_pocket = /obj/item/storage/pouch/grenade/som/ert
	back = /obj/item/storage/backpack/lightpack/som

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

/datum/outfit/job/som/ert/leader/standard_assaultrifle
	suit_store = /obj/item/weapon/gun/rifle/som/veteran
	belt = /obj/item/storage/belt/marine/som/som_rifle_ap

	backpack_contents = list(
		/obj/item/explosive/plastique = 2,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/weapon/energy/sword/som = 1,
		/obj/item/ammo_magazine/rifle/som/ap = 1,
		/obj/item/ammo_magazine/handful/micro_grenade = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 2,
		/obj/item/ammo_magazine/handful/micro_grenade/cluster = 1,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/cell/lasgun/volkite/small = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/binoculars/tactical/range = 1,
	)


/datum/outfit/job/som/ert/leader/charger
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet

	backpack_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/cell/lasgun/volkite/small = 2,
		/obj/item/tool/extinguisher = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/cell/lasgun/volkite = 2,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta = 1,
		/obj/item/weapon/energy/sword/som = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 3,
		/obj/item/binoculars/tactical/range = 1,
		/obj/item/storage/box/MRE/som = 1,
	)


/datum/outfit/job/som/ert/leader/caliver
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/somvet
	backpack_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/cell/lasgun/volkite/small = 2,
		/obj/item/tool/extinguisher = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/cell/lasgun/volkite = 3,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/serpenta = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 3,
		/obj/item/binoculars/tactical/range = 1,
		/obj/item/storage/box/MRE/som = 1,
	)


/datum/outfit/job/som/ert/leader/caliver_pack
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/caliver/tacsensor
	belt = /obj/item/belt_harness
	back = /obj/item/cell/lasgun/volkite/powerpack

	webbing_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/weapon/energy/sword/som = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/storage/box/MRE/som = 1,
	)


/datum/outfit/job/som/ert/veteran/breacher_melee
	head = /obj/item/clothing/head/modular/som/lorica
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	suit_store = /obj/item/weapon/twohanded/fireaxe/som
	belt = /obj/item/storage/holster/belt/pistol/m4a3/som

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som = 2,
		/obj/item/explosive/plastique = 5,
		/obj/item/tool/extinguisher = 1,
		/obj/item/explosive/grenade/som = 3,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/explosive/grenade/rad = 2,
		/obj/item/explosive/grenade/incendiary/som = 1,
	)

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

	belt_contents = list(
		/obj/item/weapon/gun/pistol/som/burst = 1,
		/obj/item/ammo_magazine/pistol/som/extended = 6,
	)


/datum/outfit/job/som/ert/veteran/breacher_rpg
	head = /obj/item/clothing/head/modular/som/lorica
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	suit_store = /obj/item/weapon/twohanded/fireaxe/som
	belt = /obj/item/storage/belt/grenade/som
	back = /obj/item/storage/holster/backholster/rpg/som/ert
	l_pocket = /obj/item/storage/pouch/explosive/som

	belt_contents = list(
		/obj/item/explosive/grenade/som = 3,
		/obj/item/explosive/grenade/smokebomb/som = 2,
		/obj/item/explosive/grenade/smokebomb/satrapine = 2,
		/obj/item/explosive/grenade/rad = 2,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/tool/extinguisher/mini = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/rocket/som/thermobaric = 2,
		/obj/item/ammo_magazine/rocket/som/heat = 1,
		/obj/item/ammo_magazine/rocket/som/rad = 1,
	)

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

/datum/outfit/job/som/ert/veteran/breacher_flamer
	head = /obj/item/clothing/head/modular/som/hades
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/pyro
	suit_store = /obj/item/weapon/twohanded/fireaxe/som
	belt = /obj/item/storage/belt/sparepouch/som
	back = /obj/item/weapon/gun/flamer/som/mag_harness

	belt_contents = list(
		/obj/item/ammo_magazine/flamer_tank/large/som = 3,
	)

	webbing_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/tool/extinguisher/mini = 1,
	)

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)

/datum/outfit/job/som/ert/veteran/breacher_culverin
	head = /obj/item/clothing/head/modular/som/lorica
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/culverin/magharness
	back = /obj/item/cell/lasgun/volkite/powerpack

	webbing_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/weapon/energy/sword/som = 1,
	)

	suit_contents = list(
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/isotonic = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/dylovene = 1,
	)


/datum/outfit/job/som/ert/medic/breacher
	head = /obj/item/clothing/head/modular/som/lorica
	w_uniform = /obj/item/clothing/under/som/medic/vest/black
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/lorica
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	l_hand = /obj/item/weapon/shield/riot/marine/som

	backpack_contents = list(
		/obj/item/tool/extinguisher = 1,
		/obj/item/defibrillator = 1,
		/obj/item/cell/lasgun/volkite = 5,
		/obj/item/storage/pill_bottle/russian_red = 1,
		/obj/item/explosive/plastique = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/explosive/grenade/incendiary/som = 1,
		/obj/item/tool/crowbar/red = 1,
	)

	r_pocket_contents = list(
		/obj/item/cell/lasgun/volkite = 3,
	)


/datum/outfit/job/som/ert/leader/breacher_melee
	suit_store = /obj/item/weapon/twohanded/fireaxe/som
	belt = /obj/item/storage/holster/belt/pistol/m4a3/som

	backpack_contents = list(
		/obj/item/storage/box/MRE/som = 1,
		/obj/item/ammo_magazine/pistol/som/extended = 2,
		/obj/item/explosive/plastique = 3,
		/obj/item/tool/extinguisher = 1,
		/obj/item/explosive/grenade/som = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/russian_red = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 2,
		/obj/item/binoculars/tactical/range = 1,
		/obj/item/explosive/grenade/rad = 2,
	)

/datum/outfit/job/som/ert/leader/breacher_ranged
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet
	l_hand = /obj/item/weapon/shield/riot/marine/som

	backpack_contents = list(
		/obj/item/tool/extinguisher = 1,
		/obj/item/tool/weldingtool/largetank = 1,
		/obj/item/explosive/plastique = 3,
		/obj/item/clothing/glasses/welding = 1,
		/obj/item/cell/lasgun/volkite = 3,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/som = 1,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/som = 1,
		/obj/item/weapon/energy/sword/som = 1,
		/obj/item/explosive/grenade/rad = 2,
	)

