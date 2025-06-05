/datum/outfit/job/som/militia/standard
	name = "Militia Standard"
	jobtype = /datum/job/som/mercenary/militia/standard

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship/som
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine/clf/full
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/strawhat
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pill_bottle/zoom
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/storage/box/m94 = 1,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/stick = 2,
	)


/datum/outfit/job/som/militia/standard/uzi
	belt = /obj/item/storage/belt/knifepouch
	suit_store = /obj/item/weapon/gun/smg/uzi/mag_harness
	backpack_contents = list(
		/obj/item/storage/box/m94 = 1,
		/obj/item/ammo_magazine/smg/uzi/extended = 8,
	)


/datum/outfit/job/som/militia/standard/skorpion
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness

	backpack_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/ammo_magazine/smg/skorpion = 7,
	)

/datum/outfit/job/som/militia/standard/mpi_km
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/standard

	backpack_contents = list(
		/obj/item/explosive/plastique = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/mpi_km = 6,
	)


/datum/outfit/job/som/militia/standard/shotgun
	belt = /obj/item/storage/belt/shotgun
	suit_store = /obj/item/weapon/gun/shotgun/pump/standard

	backpack_contents = list(
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/plastique = 1,
		/obj/item/stack/sheet/metal/medium_stack = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 7,
		/obj/item/ammo_magazine/handful/flechette = 7,
	)


/datum/outfit/job/som/militia/standard/fanatic
	head = /obj/item/clothing/head/headband/rambo
	wear_suit = /obj/item/clothing/suit/storage/marine/boomvest/fast
	belt = /obj/item/weapon/gun/shotgun/double/sawn
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness

	backpack_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/explosive/grenade/phosphorus/upp = 1,
		/obj/item/ammo_magazine/smg/skorpion = 5,
	)

/datum/outfit/job/som/militia/standard/som_smg
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/smg/som/basic

	backpack_contents = list(
		/obj/item/explosive/plastique = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/smg/som = 6,
	)


/datum/outfit/job/som/militia/standard/mpi_grenadier
	belt = /obj/item/storage/belt/marine/som
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/black/grenadier

	backpack_contents = list(
		/obj/item/explosive/grenade/som = 2,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/mpi_km/black = 6,
	)


/datum/outfit/job/som/militia/medic
	name = "Militia Medic"
	jobtype = /datum/job/som/mercenary/militia/medic

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/lifesaver/full/upp
	ears = /obj/item/radio/headset/mainship/som
	head = /obj/item/clothing/head/tgmcberet/bloodred
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine/clf/full
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/skorpion
	l_pocket = /obj/item/storage/pouch/medical_injectors/medic
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/roller = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 1,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/stick = 2,
	)

/datum/outfit/job/som/militia/medic/uzi
	suit_store = /obj/item/weapon/gun/smg/uzi/mag_harness
	r_pocket = /obj/item/storage/holster/flarepouch

	backpack_contents = list(
		/obj/item/ammo_magazine/smg/uzi/extended = 7,
	)

	r_pocket_contents = list(
		/obj/item/weapon/gun/grenade_launcher/single_shot/flare = 1,
		/obj/item/explosive/grenade/flare = 6,
	)


/datum/outfit/job/som/militia/medic/skorpion
	suit_store = /obj/item/weapon/gun/smg/skorpion/mag_harness
	r_pocket = /obj/item/storage/holster/flarepouch

	backpack_contents = list(
		/obj/item/ammo_magazine/smg/skorpion = 7,
	)

	r_pocket_contents = list(
		/obj/item/weapon/gun/grenade_launcher/single_shot/flare = 1,
		/obj/item/explosive/grenade/flare = 6,
	)


/datum/outfit/job/som/militia/medic/paladin
	suit_store = /obj/item/weapon/gun/shotgun/pump/cmb/mag_harness
	r_pocket = /obj/item/storage/pouch/shotgun

	backpack_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/ammo_magazine/handful/flechette = 2,
	)

	r_pocket_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 2,
		/obj/item/ammo_magazine/handful/flechette = 2,
	)


/datum/outfit/job/som/militia/leader
	name = "Militia Leader"
	jobtype = /datum/job/som/mercenary/militia/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine
	ears = /obj/item/radio/headset/mainship/som
	w_uniform = /obj/item/clothing/under/colonist/webbing
	shoes = /obj/item/clothing/shoes/marine/clf/full
	wear_suit = /obj/item/clothing/suit/storage/faction/militia
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/militia
	glasses = /obj/item/clothing/glasses/hud/health
	r_pocket = /obj/item/storage/pouch/pistol
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/radio = 1,
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/storage/box/MRE = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/storage/box/m94 = 2,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/ammo_magazine/pistol/highpower = 2,
		/obj/item/explosive/plastique = 2,
	)

	suit_contents = list(
		/obj/item/binoculars = 1,
		/obj/item/radio = 1,
	)

	r_pocket_contents = list(
		/obj/item/weapon/gun/pistol/highpower = 1,
	)

/datum/outfit/job/som/militia/leader/assault_rifle
	suit_store = /obj/item/weapon/gun/rifle/m16/ugl

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/m16 = 6,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/stick = 4,
		/obj/item/explosive/grenade/smokebomb = 1,
	)

/datum/outfit/job/som/militia/leader/mpi_km
	suit_store = /obj/item/weapon/gun/rifle/mpi_km/grenadier
	belt = /obj/item/storage/belt/marine/som

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/mpi_km = 6,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/stick = 4,
		/obj/item/explosive/grenade/smokebomb = 1,
	)


/datum/outfit/job/som/militia/leader/som_rifle
	suit_store = /obj/item/weapon/gun/rifle/som/basic
	belt = /obj/item/storage/belt/marine/som

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/som = 6,
	)

	webbing_contents = list(
		/obj/item/ammo_magazine/handful/micro_grenade = 2,
		/obj/item/ammo_magazine/handful/micro_grenade/dragonbreath = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/cluster = 1,
		/obj/item/ammo_magazine/handful/micro_grenade/smoke_burst = 1,
	)

/datum/outfit/job/som/militia/leader/upp_rifle
	suit_store = /obj/item/weapon/gun/rifle/type71/flamer/standard

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/type71 = 6,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/stick = 2,
		/obj/item/ammo_magazine/flamer_tank/mini = 2,
		/obj/item/explosive/grenade/smokebomb = 1,
	)


/datum/outfit/job/som/militia/leader/lmg_d
	suit_store = /obj/item/weapon/gun/rifle/lmg_d/magharness
	belt = /obj/item/storage/belt/marine/som

	belt_contents = list(
		/obj/item/ammo_magazine/rifle/lmg_d = 6,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade/stick = 4,
		/obj/item/explosive/grenade/smokebomb = 1,
	)


/datum/outfit/job/freelancer/standard/one/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/freelancer/standard/two/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/freelancer/standard/three/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/freelancer/medic/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/freelancer/grenadier/one/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/freelancer/grenadier/two/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/freelancer/leader/one/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/freelancer/leader/two/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/pmc/standard/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/pmc/gunner/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/pmc/leader/campaign
	ears = /obj/item/radio/headset/mainship

/datum/outfit/job/icc/standard/mpi_km/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/icc/standard/icc_pdw/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/icc/standard/icc_battlecarbine/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/icc/guard/coilgun/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/icc/guard/icc_autoshotgun/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/icc/medic/icc_machinepistol/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/icc/medic/icc_sharpshooter/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/icc/leader/trenchgun/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/icc/leader/icc_confrontationrifle/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/tgmc/campaign_robot
	name = "Combat robot"
	jobtype = /datum/job/terragov/squad/standard/campaign_robot

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship
	w_uniform = /obj/item/clothing/under/marine/robotic/black_vest
	wear_suit = /obj/item/clothing/suit/modular/tdf/robot/tyr_two
	head = /obj/item/clothing/head/modular/tdf/robot
	r_pocket = /obj/item/storage/pouch/pistol
	l_pocket = /obj/item/storage/pouch/grenade/combat_patrol
	back = /obj/item/storage/backpack/marine/satchel

	belt = /obj/item/storage/belt/marine/te_cells
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/gyro

	suit_contents = list(
		/obj/item/tool/crowbar = 1,
		/obj/item/tool/weldingtool = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sandbags/large_stack = 1,
		/obj/item/tool/shovel/etool = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 1,
		/obj/item/explosive/plastique = 1,
	)


/datum/outfit/job/tgmc/campaign_robot/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	H.set_species("Combat Robot")


/datum/outfit/job/tgmc/campaign_robot/machine_gunner
	belt = /obj/item/storage/belt/sparepouch
	suit_store = /obj/item/weapon/gun/rifle/standard_gpmg/machinegunner

	backpack_contents = list(
		/obj/item/ammo_magazine/standard_gpmg = 2,
		/obj/item/ammo_magazine/pistol/vp70 = 1,
		/obj/item/tool/weldingtool = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/weapon/shield/riot/marine/deployable = 1,
	)

	belt_contents = list(
		/obj/item/ammo_magazine/standard_gpmg = 3,
	)

	webbing_contents = list(
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 4,
	)

	r_pocket_contents = list(
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
	)


/datum/outfit/job/tgmc/campaign_robot/guardian
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/gyro
	r_hand = /obj/item/weapon/shield/riot/marine

	backpack_contents = list(
		/obj/item/ammo_magazine/pistol/vp70 = 1,
		/obj/item/tool/weldingtool = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/cell/lasgun/lasrifle = 3,
	)

	webbing_contents = list(
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 4,
	)

	r_pocket_contents = list(
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
	)


/datum/outfit/job/tgmc/campaign_robot/jetpack
	wear_suit = /obj/item/clothing/suit/modular/tdf/robot/shield_overclocked
	r_pocket = /obj/item/storage/pouch/magazine/large
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/mag_harness
	back = /obj/item/jetpack_marine/heavy

	webbing_contents = list(
		/obj/item/explosive/grenade/sticky = 2,
		/obj/item/explosive/grenade/incendiary = 1,
		/obj/item/explosive/grenade = 2,
	)

	r_pocket_contents = list(
		/obj/item/cell/lasgun/lasrifle = 3,
	)


/datum/outfit/job/tgmc/campaign_robot/laser_mg
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser/patrol

	backpack_contents = list(
		/obj/item/explosive/grenade = 1,
		/obj/item/tool/weldingtool = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/tool/extinguisher/mini = 1,
		/obj/item/ammo_magazine/pistol/vp70 = 3,
	)

	webbing_contents = list(
		/obj/item/explosive/grenade = 5,
	)

	r_pocket_contents = list(
		/obj/item/weapon/gun/pistol/vp70/tactical = 1,
	)


/datum/outfit/job/vsd/standard/grunt_one/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/standard/ksg/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/standard/grunt_second/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/standard/grunt_third/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/standard/lmg/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/standard/upp/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/standard/upp_second/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/standard/upp_third/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/spec/demolitionist/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/spec/gunslinger/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/spec/uslspec_one/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/spec/uslspec_two/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/spec/machinegunner/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/medic/ksg/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/medic/vsd_rifle/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/medic/vsd_carbine/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/engineer/l26/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/engineer/vsd_rifle/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/juggernaut/ballistic/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/juggernaut/eod/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/juggernaut/flamer/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/leader/one/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/leader/two/campaign
	ears = /obj/item/radio/headset/mainship/som

/datum/outfit/job/vsd/leader/upp_three/campaign
	ears = /obj/item/radio/headset/mainship/som
