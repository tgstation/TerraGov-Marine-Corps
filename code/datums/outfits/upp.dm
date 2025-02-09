/datum/outfit/job/upp/standard
	name = "USL Gunner"
	jobtype = /datum/job/upp/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine/upp/full
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/UPP
	mask = /obj/item/clothing/mask/gas/pmc/leader
	suit_store = /obj/item/weapon/gun/rifle/type71
	r_pocket = /obj/item/storage/pouch/pistol
	l_pocket = /obj/item/storage/pouch/magazine/pistol/large
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/explosive/grenade/upp = 1,
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 2,
		/obj/item/reagent_containers/hypospray/autoinjector/tramadol = 1,
		/obj/item/stack/medical/heal_pack/gauze = 1,
		/obj/item/stack/medical/splint = 1,
		/obj/item/reagent_containers/food/snacks/upp = 1,
		/obj/item/radio = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/plastique = 2,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/upp = 2,
	)

	shoe_contents = list(
		/obj/item/weapon/combat_knife/upp = 1,
	)

	l_pocket_contents = list(
		/obj/item/ammo_magazine/pistol/c99 = 6,
	)

	r_pocket_contents = list(
		/obj/item/weapon/gun/pistol/c99 = 1,
	)

/datum/outfit/job/upp/standard/hvh
	name = "USL Gunner (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/hvh


/datum/outfit/job/upp/medic
	name = "USL Surgeon"
	jobtype = /datum/job/upp/medic

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/lifesaver/full/upp
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP/medic
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/uppcap
	glasses = /obj/item/clothing/glasses/hud/health
	suit_store = /obj/item/weapon/gun/smg/skorpion
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/roller = 1,
		/obj/item/reagent_containers/food/snacks/upp = 2,
		/obj/item/radio = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 1,
		/obj/item/ammo_magazine/smg/skorpion = 4,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/upp = 2,
	)

	shoe_contents = list(
		/obj/item/weapon/combat_knife/upp = 1,
	)

	l_pocket_contents = list(
		/obj/item/reagent_containers/hypospray/advanced/oxycodone = 1,
		/obj/item/reagent_containers/hypospray/advanced/tricordrazine = 1,
		/obj/item/reagent_containers/glass/bottle/tricordrazine = 1,
	)


/datum/outfit/job/upp/medic/hvh
	name = "USL Surgeon (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/hvh


/datum/outfit/job/upp/heavy
	name = "USL Powder Monkey"
	jobtype = /datum/job/upp/heavy

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine/upp/full
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/heavy
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/helmet/UPP/heavy
	suit_store = /obj/item/weapon/gun/rifle/type71/flamer
	r_pocket = /obj/item/storage/pouch/explosive
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/stack/sheet/metal/small_stack = 1,
		/obj/item/reagent_containers/food/snacks/upp = 2,
		/obj/item/radio = 1,
		/obj/item/storage/box/m94 = 2,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/incendiary/molotov = 2,
		/obj/item/explosive/plastique = 1,
		/obj/item/ammo_magazine/flamer_tank = 1,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/upp = 2,
	)

	shoe_contents = list(
		/obj/item/weapon/combat_knife/upp = 1,
	)

	r_pocket_contents = list(
		/obj/item/assembly/signaler = 1,
		/obj/item/detpack = 2,
		/obj/item/explosive/grenade/smokebomb/cloak = 1,
	)

/datum/outfit/job/upp/heavy/hvh
	name = "USL Powder Monkey (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/heavy/hvh


/datum/outfit/job/upp/leader
	name = "USL Captain"
	jobtype = /datum/job/upp/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/holster/belt/korovin/standard
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/heavy
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/uppcap/beret
	suit_store = /obj/item/weapon/gun/rifle/type71
	r_pocket = /obj/item/storage/pouch/general/large
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/stack/sheet/plasteel/small_stack = 1,
		/obj/item/reagent_containers/food/snacks/upp = 1,
		/obj/item/radio = 1,
		/obj/item/storage/box/m94 = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/ammo_magazine/rifle/type71 = 4,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/upp = 2,
	)

	shoe_contents = list(
		/obj/item/weapon/combat_knife/upp = 1,
	)

	r_pocket_contents = list(
		/obj/item/binoculars = 1,
		/obj/item/explosive/plastique = 2,
	)



/datum/outfit/job/upp/leader/hvh
	name = "USL Captain (HvH)"

	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/heavy/hvh
