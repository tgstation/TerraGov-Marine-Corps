/obj/effect/spawner/random/medical
	name = "Random base medical spawner"
	icon = 'icons/effects/random/medical.dmi'
	icon_state = "random_syringe"
	loot = list(
		/obj/structure/prop/mainship/errorprop,
	)

/obj/effect/spawner/random/medical/health_analyzer
	name = "health analyzer spawner"
	icon_state = "random_healthanalyzer"
	spawn_scatter_radius = 1
	spawn_random_offset = TRUE
	spawn_loot_chance = 35
	loot = list(
		/obj/item/healthanalyzer,
	)

/obj/effect/spawner/random/medical/bloodpack
	name = "Random blood spawner"
	icon_state = "random_bloodpack"
	spawn_loot_chance = 80
	loot = list(
		/obj/item/reagent_containers/blood/empty = 95,
		/obj/item/reagent_containers/blood/AMinus = 20,
		/obj/item/reagent_containers/blood/APlus = 20,
		/obj/item/reagent_containers/blood/BMinus = 20,
		/obj/item/reagent_containers/blood/BPlus = 20,
		/obj/item/reagent_containers/blood/OPlus = 20,
		/obj/item/reagent_containers/blood/OMinus = 5,
	)

/obj/effect/spawner/random/medical/medbelt
	name = "Random medical belt spawner"
	icon_state = "random_medbelt"
	spawn_loot_chance = 25
	loot = list(
		/obj/item/storage/belt/lifesaver = 50,
		/obj/effect/spawner/random/medical/pillbottle = 15,
		/obj/item/storage/belt/lifesaver/quick = 10,
		/obj/item/storage/belt/lifesaver/full = 5,
	)

/obj/effect/spawner/random/medical/medhud
	name = "Random med hud spawner"
	icon_state = "random_medhud"
	spawn_loot_chance = 25
	loot = list(
		/obj/item/clothing/glasses/regular = 30,
		/obj/item/clothing/glasses/hud/health = 15,
		/obj/item/clothing/glasses/hud/medgoggles = 15,
		/obj/item/clothing/glasses/hud/medgoggles/prescription = 10,
		/obj/item/clothing/glasses/hud/medpatch = 5,
		/obj/item/clothing/glasses/hud/medsunglasses = 5,
	)


/obj/effect/spawner/random/medical/surgical
	name = "Random surgical instrument spawner"
	icon_state = "random_surgical"
	loot = list(
		/obj/item/tool/surgery/scalpel/manager,
		/obj/item/tool/surgery/scalpel,
		/obj/item/tool/surgery/hemostat,
		/obj/item/tool/surgery/retractor,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/tool/surgery/cautery,
		/obj/item/tool/surgery/circular_saw,
		/obj/item/tool/surgery/suture,
		/obj/item/tool/surgery/bonegel,
		/obj/item/tool/surgery/bonesetter,
		/obj/item/tool/surgery/FixOVein,
		/obj/item/stack/nanopaste,
	)

/obj/effect/spawner/random/medical/heal_pack
	name = "Random bruise pack spawner"
	icon_state = "random_healpack"
	spawn_loot_chance = 85
	loot = list(
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack,
	)

/obj/effect/spawner/random/medical/heal_pack/bruteweighted
	icon_state = "random_brutekit"
	loot = list(
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack = 8,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack = 2,
	)

/obj/effect/spawner/random/medical/heal_pack/burnweighted
	icon_state = "random_burnkit"
	loot = list(
		/obj/item/stack/medical/heal_pack/advanced/burn_pack = 8,
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack = 2,
	)

/obj/effect/spawner/random/medical/organ
	name = "Random surgical organ spawner"
	icon_state = "random_organ"
	loot = list(
		/obj/item/prop/organ/brain,
		/obj/item/prop/organ/heart,
		/obj/item/prop/organ/lungs,
		/obj/item/prop/organ/kidneys,
		/obj/item/prop/organ/eyes,
		/obj/item/prop/organ/liver,
		/obj/item/prop/organ/appendix,
	)

/obj/effect/spawner/random/medical/medbottle
	name = "Random medical reagent bottle spawner"
	icon_state = "random_medbottle"
	spawn_loot_chance = 50
	loot = list(
		/obj/item/reagent_containers/glass/bottle/bicaridine = 30,
		/obj/item/reagent_containers/glass/bottle/kelotane = 30,
		/obj/item/reagent_containers/glass/bottle/dylovene = 30,
		/obj/item/reagent_containers/glass/bottle/spaceacillin = 15,
		/obj/item/reagent_containers/glass/bottle/dermaline = 15,
		/obj/item/reagent_containers/glass/bottle/tramadol = 10,
		/obj/item/reagent_containers/glass/bottle/tricordrazine = 5,
		/obj/item/reagent_containers/glass/bottle/oxycodone = 5,
		/obj/item/reagent_containers/glass/bottle/meralyne = 5,
		/obj/item/reagent_containers/glass/bottle/lemoline = 5,
		/obj/item/reagent_containers/glass/bottle/meraderm = 1,
	)

/obj/effect/spawner/random/medical/firstaid
	name = "firstaid spawner"
	icon_state = "random_medkit"
	spawn_loot_chance = 35
	loot = list(
		/obj/item/storage/firstaid/regular = 30,
		/obj/item/storage/firstaid/fire = 15,
		/obj/item/storage/firstaid/o2 = 10,
		/obj/item/storage/firstaid/toxin = 10,
		/obj/item/storage/firstaid/adv = 5,
	)

/obj/effect/spawner/random/medical/firstaid/alwaysspawns
	spawn_loot_chance = 100

/obj/effect/spawner/random/medical/medicalcloset
	name = "medical closet spawner"
	icon_state = "random_medical_closet"
	spawn_loot_chance = 65
	loot = list(
		/obj/structure/closet/secure_closet/medical2 = 90,
		/obj/structure/closet/secure_closet/medical_doctor = 40,
		/obj/structure/closet/secure_closet/medical1/colony = 20,
		/obj/structure/closet/secure_closet/chemical/colony = 20,
		/obj/structure/closet/secure_closet/medical3/colony = 5,
		/obj/structure/closet/secure_closet/CMO = 1,
	)


/obj/effect/spawner/random/medical/structure/crate/medsupplies
	name = "medical supplies spawner"
	icon_state = "random_medsupplies"
	spawn_loot_chance = 75
	loot = list(
		/obj/structure/largecrate/supply/medicine/medkits = 6,
		/obj/structure/largecrate/supply/medicine/blood = 2,
		/obj/structure/largecrate/supply/medicine/iv = 2,
		/obj/structure/largecrate/supply/medicine/medivend = 1,
	)

/obj/effect/spawner/random/medical/structure/crate/medsupplies/alwaysspawns
	spawn_loot_chance = 100

/obj/effect/spawner/random/medical/structure/rollerbed
	name = "rollerbed spawner"
	icon_state = "random_rollerbed"
	spawn_loot_chance = 85
	spawn_scatter_radius = 1
	loot = list(
		/obj/structure/bed/roller = 90,
		/obj/effect/spawner/random/decal/blood = 9,
		/obj/structure/bed/medevac_stretcher = 1,
	)

/obj/effect/spawner/random/medical/structure/ivdrip
	name = "iv drip spawner"
	icon_state = "random_ivdrip"
	spawn_loot_chance = 50
	loot = list(
		/obj/machinery/iv_drip = 90,
		/obj/effect/spawner/random/decal/blood = 9,
		/obj/structure/bed/medevac_stretcher = 1,
	)

/obj/effect/spawner/random/medical/pillbottle
	name = "Random pill bottle spawner"
	icon_state = "random_medicine"
	spawn_loot_chance = 50
	loot = list(
		/obj/item/storage/pill_bottle/alkysine = 30,
		/obj/item/storage/pill_bottle/imidazoline = 10,
		/obj/item/storage/pill_bottle/bicaridine = 30,
		/obj/item/storage/pill_bottle/kelotane = 30,
		/obj/item/storage/pill_bottle/tramadol = 15,
		/obj/item/storage/pill_bottle/inaprovaline = 10,
		/obj/item/storage/pill_bottle/dylovene = 15,
		/obj/item/storage/pill_bottle/spaceacillin = 10,
	)

/obj/effect/spawner/random/medical/syringe
	name = "Random syringe spawner"
	icon_state = "random_syringe"
	spawn_loot_chance = 60
	loot = list(
		/obj/item/reagent_containers/syringe = 40,
		/obj/item/reagent_containers/syringe/antiviral = 30,
		/obj/item/reagent_containers/syringe/dylovene = 30,
		/obj/item/reagent_containers/syringe/inaprovaline = 30,
		/obj/item/storage/syringe_case/burn = 10,
		/obj/item/storage/syringe_case/dermaline = 10,
		/obj/item/storage/syringe_case/meraderm = 5,
		/obj/item/storage/syringe_case/oxy = 5,
		/obj/item/storage/syringe_case/tricordrazine = 5,
		/obj/item/storage/box/syringes = 1,
	)

/obj/effect/spawner/random/medical/beaker
	name = "Random beaker spawner"
	icon_state = "random_beaker"
	spawn_loot_chance = 85
	loot = list(
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/beaker/large,
	)

/obj/effect/spawner/random/medical/beaker/bluespace
	name = "Random bluespace beaker spawner"
	icon_state = "random_bluespace_beaker"
	spawn_loot_chance = 100
	loot = list(
		/obj/item/reagent_containers/glass/beaker/bluespace = 8,
		/obj/effect/spawner/random/medical/beaker = 2,
	)

/obj/effect/spawner/random/medical/beaker/regularweighted
	loot = list(
		/obj/item/reagent_containers/glass/beaker = 8,
		/obj/item/reagent_containers/glass/beaker/large = 2,
	)

/obj/effect/spawner/random/medical/beaker/largeweighted
	icon_state = "random_largebeaker"
	loot = list(
		/obj/item/reagent_containers/glass/beaker/large = 8,
		/obj/item/reagent_containers/glass/beaker = 2,
	)
