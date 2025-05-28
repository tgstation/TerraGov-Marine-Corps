/datum/outfit/job/npc/tgmc/squad_leader
	name = "NPC TGMC squad leader"
	jobtype = /datum/job/terragov/squad/leader

	id = /obj/item/card/id/dogtag
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/leader
	glasses = /obj/item/clothing/glasses/hud/health
	w_uniform = /obj/item/clothing/under/marine/black_vest
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/leader/antenna
	back = /obj/item/storage/backpack/marine/radiopack
	belt = /obj/item/storage/belt/marine
	gloves = /obj/item/clothing/gloves/marine/black
	l_pocket = /obj/item/storage/pouch/medkit/firstaid
	r_pocket = /obj/item/storage/pouch/magazine/large
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancerone
	ears = /obj/item/radio/headset/mainship/marine
	shoes = /obj/item/clothing/shoes/marine/full

	backpack_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
		/obj/item/ammo_magazine/rifle/tx11 = 6,
		/obj/item/storage/box/m94 = 1,
	)
	suit_contents = list(
		/obj/item/stack/medical/heal_pack/advanced/bruise_pack = 1,
		/obj/item/stack/medical/heal_pack/advanced/burn_pack = 1,
		/obj/item/stack/medical/splint = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = 1,
	)
	belt_contents = list(/obj/item/ammo_magazine/rifle/tx11 = 6)
	r_pocket_contents = list(/obj/item/ammo_magazine/rifle/tx11 = 3)
	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2,
	)
	webbing_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/explosive/grenade/smokebomb/antigas = 2,
	)

/datum/outfit/job/npc/tgmc/smartgunner
	name = "NPC TGMC smartgunner"
	jobtype = /datum/job/terragov/squad/smartgunner

	id = /obj/item/card/id/dogtag
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_one
	glasses = /obj/item/clothing/glasses/night/m56_goggles
	w_uniform = /obj/item/clothing/under/marine/black_vest
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/tyr
	back = /obj/item/storage/backpack/marine/standard
	belt = /obj/item/storage/belt/sparepouch
	gloves = /obj/item/clothing/gloves/marine/black
	l_pocket = /obj/item/storage/pouch/medkit/firstaid
	r_pocket = /obj/item/storage/pouch/grenade
	suit_store = /obj/item/weapon/gun/rifle/standard_smartmachinegun/basic
	ears = /obj/item/radio/headset/mainship/marine
	shoes = /obj/item/clothing/shoes/marine/full

	backpack_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/ammo_magazine/standard_smartmachinegun = 5,
	)
	suit_contents = list(
		/obj/item/storage/pill_bottle/bicaridine = 1,
		/obj/item/storage/pill_bottle/kelotane = 1,
		/obj/item/storage/pill_bottle/tricordrazine = 1,
		/obj/item/storage/pill_bottle/tramadol = 1,
		/obj/item/stack/medical/splint = 1,
	)
	belt_contents = list(/obj/item/ammo_magazine/standard_smartmachinegun = 3)
	r_pocket_contents = list(
		/obj/item/explosive/grenade = 4,
		/obj/item/explosive/grenade/sticky/trailblazer = 2,
	)
	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)
	webbing_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade/bullet/hefa = 2,
		/obj/item/explosive/grenade/smokebomb/antigas = 1,
	)

/datum/outfit/job/npc/tgmc/corpsman
	name = "NPC TGMC Corpsman"
	jobtype = /datum/job/terragov/squad/corpsman

	id = /obj/item/card/id/dogtag
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/npc_medic
	glasses = /obj/item/clothing/glasses/hud/health
	w_uniform = /obj/item/clothing/under/marine/corpsman/corpman_vest
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/mimir
	back = /obj/item/storage/backpack/marine/corpsman
	belt = /obj/item/storage/belt/lifesaver
	gloves = /obj/item/clothing/gloves/marine/black
	l_pocket = /obj/item/storage/pouch/medkit/medic
	r_pocket = /obj/item/storage/pouch/magazine/large
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancerone
	ears = /obj/item/radio/headset/mainship/marine
	shoes = /obj/item/clothing/shoes/marine/full

	backpack_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/defibrillator = 1,
		/obj/item/ammo_magazine/rifle/tx11 = 6,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)
	suit_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade/bullet/hefa = 1,
		/obj/item/explosive/grenade/mirage = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/explosive/grenade/smokebomb/antigas = 1,
	)
	belt_contents = list(
		/obj/item/storage/pill_bottle/bicaridine = 2,
		/obj/item/storage/pill_bottle/kelotane = 2,
		/obj/item/storage/pill_bottle/tramadol = 2,
		/obj/item/storage/pill_bottle/tricordrazine = 2,
		/obj/item/storage/pill_bottle/dylovene = 1,
		/obj/item/storage/pill_bottle/inaprovaline = 2,
		/obj/item/storage/pill_bottle/spaceacillin = 1,
		/obj/item/storage/pill_bottle/alkysine = 1,
		/obj/item/storage/pill_bottle/imidazoline = 1,
		/obj/item/storage/pill_bottle/quickclot = 1,
		/obj/item/storage/pill_bottle/meralyne = 1,
		/obj/item/storage/pill_bottle/dermaline = 1,
		/obj/item/stack/medical/splint = 3,
		/obj/item/healthanalyzer = 1,
	)
	r_pocket_contents = list(
		/obj/item/ammo_magazine/rifle/tx11 = 3,
	)
	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2,
	)
	webbing_contents = list(
		/obj/item/tweezers = 1,
		/obj/item/reagent_containers/hypospray/advanced/meraderm = 1,
		/obj/item/reagent_containers/hypospray/advanced/nanoblood = 1,
		/obj/item/reagent_containers/hypospray/advanced/oxycodone = 1,
		/obj/item/stack/medical/splint = 2,
	)

/datum/outfit/job/npc/tgmc/standard
	name = "NPC TGMC standard"
	jobtype = /datum/job/terragov/squad/standard

	id = /obj/item/card/id/dogtag
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_one
	glasses = /obj/item/clothing/glasses/mgoggles
	w_uniform = /obj/item/clothing/under/marine/black_vest
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/tyr
	back = /obj/item/storage/backpack/marine/standard
	belt = /obj/item/storage/belt/marine
	gloves = /obj/item/clothing/gloves/marine/black
	l_pocket = /obj/item/storage/pouch/medkit/firstaid
	r_pocket = /obj/item/storage/pouch/magazine/large
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancerone
	ears = /obj/item/radio/headset/mainship/marine
	shoes = /obj/item/clothing/shoes/marine/full

	backpack_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 1,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/ammo_magazine/rifle/tx11 = 5,
	)
	suit_contents = list(
		/obj/item/storage/pill_bottle/bicaridine = 1,
		/obj/item/storage/pill_bottle/kelotane = 1,
		/obj/item/storage/pill_bottle/tricordrazine = 1,
		/obj/item/storage/pill_bottle/tramadol = 1,
		/obj/item/stack/medical/splint = 1,
	)
	belt_contents = list(/obj/item/ammo_magazine/rifle/tx11 = 6)
	r_pocket_contents = list(/obj/item/ammo_magazine/rifle/tx11 = 3)
	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)
	webbing_contents = list(
		/obj/item/explosive/grenade = 2,
		/obj/item/explosive/grenade/bullet/hefa = 2,
		/obj/item/explosive/grenade/smokebomb/antigas = 1,
	)

/datum/outfit/job/npc/tgmc/standard/shotgunner
	name = "NPC TGMC standard shotgunner"
	jobtype = /datum/job/terragov/squad/standard

	id = /obj/item/card/id/dogtag
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/light/shield
	glasses = /obj/item/clothing/glasses/mgoggles
	w_uniform = /obj/item/clothing/under/marine/black_vest
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/hod
	back = /obj/item/storage/backpack/marine/standard
	belt = /obj/item/storage/belt/shotgun
	gloves = /obj/item/clothing/gloves/marine/black
	l_pocket = /obj/item/storage/pouch/medkit/firstaid
	r_pocket = /obj/item/storage/pouch/shotgun
	suit_store = /obj/item/weapon/gun/shotgun/pump/t35/vgrip
	ears = /obj/item/radio/headset/mainship/marine
	shoes = /obj/item/clothing/shoes/marine/full

	backpack_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
		/obj/item/stack/medical/heal_pack/ointment = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/ammo_magazine/handful/buckshot = 5,
		/obj/item/ammo_magazine/handful/slug = 2,
	)
	suit_contents = list(
		/obj/item/storage/pill_bottle/bicaridine = 1,
		/obj/item/storage/pill_bottle/kelotane = 1,
		/obj/item/storage/pill_bottle/tricordrazine = 1,
		/obj/item/storage/pill_bottle/tramadol = 1,
		/obj/item/stack/medical/splint = 1,
	)
	belt_contents = list(
		/obj/item/ammo_magazine/handful/buckshot = 7,
		/obj/item/ammo_magazine/handful/slug = 7,
	)
	r_pocket_contents = list(/obj/item/ammo_magazine/handful/slug = 4)
	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 1,
	)
	webbing_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade/bullet/hefa = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
		/obj/item/explosive/grenade/smokebomb/antigas = 1,
	)

//
/datum/outfit/job/npc/tgmc/squad_engineer
	name = "NPC TGMC squad engineer"
	jobtype = /datum/job/terragov/squad/engineer

	id = /obj/item/card/id/dogtag
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/mimirengi
	glasses = /obj/item/clothing/glasses/welding
	w_uniform = /obj/item/clothing/under/marine/engineer/black_vest
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x/mimir
	back = /obj/item/storage/backpack/marine/engineerpack
	belt = /obj/item/storage/belt/marine
	gloves = /obj/item/clothing/gloves/marine/insulated
	l_pocket = /obj/item/storage/pouch/medkit/firstaid
	r_pocket = /obj/item/storage/pouch/tools/full
	suit_store = /obj/item/weapon/gun/rifle/tx11/freelancerone
	ears = /obj/item/radio/headset/mainship/marine
	shoes = /obj/item/clothing/shoes/marine/full

	backpack_contents = list(
		/obj/item/storage/box/MRE = 1,
		/obj/item/stack/sheet/plasteel/large_stack = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/ammo_magazine/rifle/tx11 = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = 2,
	)
	suit_contents = list(
		/obj/item/stack/sheet/metal/large_stack = 4,
		/obj/item/stack/sheet/plasteel/large_stack = 1,
	)
	belt_contents = list(/obj/item/ammo_magazine/rifle/tx11 = 6)
	head_contents = list(/obj/item/reagent_containers/hypospray/autoinjector/combat_advanced = 2)
	webbing_contents = list(
		/obj/item/explosive/grenade/m15 = 2,
		/obj/item/explosive/grenade/smokebomb/antigas = 1,
		/obj/item/cell/high = 2,
	)
