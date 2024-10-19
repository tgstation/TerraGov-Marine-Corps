
/datum/outfit/job/upp/commando/standard
	name = "USL Elite Powder Monkey"
	jobtype = /datum/job/upp/commando/standard

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/marine/upp/full
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/uppcap
	mask = /obj/item/clothing/mask/gas/pmc/upp
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles/upp
	suit_store = /obj/item/weapon/gun/rifle/type71/commando
	r_pocket = /obj/item/storage/pouch/general/large
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack
	implants = list(/obj/item/implant/suicide_dust)

	backpack_contents = list(
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/reagent_containers/food/snacks/upp = 2,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/smokebomb/cloak = 2,
		/obj/item/chameleon = 1,
		/obj/item/explosive/plastique = 2,
		/obj/item/binoculars = 1,
		/obj/item/restraints/handcuffs = 1,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/upp = 2,
	)

	shoe_contents = list(
		/obj/item/weapon/combat_knife/upp = 1,
	)

	r_pocket_contents = list(
		/obj/item/reagent_containers/hypospray/advanced = 1,
		/obj/item/reagent_containers/glass/bottle/chloralhydrate = 1,
		/obj/item/reagent_containers/glass/bottle/sleeptoxin = 1,
	)


/datum/outfit/job/upp/commando/medic
	name = "USL Elite Surgeon"
	jobtype = /datum/job/upp/commando/medic

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/lifesaver/full/upp
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP/medic
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/uppcap
	mask = /obj/item/clothing/mask/gas/pmc/upp
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles/upp
	suit_store = /obj/item/weapon/gun/smg/skorpion
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/pouch/general/large
	back = /obj/item/storage/backpack/lightpack
	implants = list(/obj/item/implant/suicide_dust)

	backpack_contents = list(
		/obj/item/defibrillator = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/binoculars = 1,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/chameleon = 1,
		/obj/item/clothing/glasses/hud/health = 1,
		/obj/item/ammo_magazine/smg/skorpion = 5,
		/obj/item/attachable/suppressor = 1,
		/obj/item/attachable/reddot = 1,
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


/datum/outfit/job/upp/commando/leader
	name = "USL Elite Captain"
	jobtype = /datum/job/upp/commando/leader

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/holster/belt/korovin/tranq
	ears = /obj/item/radio/headset/distress/usl
	w_uniform = /obj/item/clothing/under/marine/veteran/UPP
	shoes = /obj/item/clothing/shoes/marine
	wear_suit = /obj/item/clothing/suit/storage/faction/UPP/commando
	gloves = /obj/item/clothing/gloves/marine/veteran/pmc
	head = /obj/item/clothing/head/uppcap/beret
	mask = /obj/item/clothing/mask/gas/pmc/upp
	glasses = /obj/item/clothing/glasses/night/m42_night_goggles/upp
	suit_store = /obj/item/weapon/gun/rifle/type71/commando
	r_pocket = /obj/item/storage/pouch/general/large
	l_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	back = /obj/item/storage/backpack/lightpack
	implants = list(/obj/item/implant/suicide_dust)

	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/upp = 1,
		/obj/item/radio = 1,
		/obj/item/tool/crowbar/red = 1,
		/obj/item/explosive/grenade/phosphorus/upp = 2,
		/obj/item/stack/sheet/metal/medium_stack = 1,
		/obj/item/stack/sheet/plasteel/small_stack = 1,
		/obj/item/chameleon = 1,
		/obj/item/ammo_magazine/rifle/type71 = 3,
	)

	suit_contents = list(
		/obj/item/explosive/grenade/upp = 2,
	)

	shoe_contents = list(
		/obj/item/weapon/combat_knife/upp = 1,
	)

	r_pocket_contents = list(
		/obj/item/binoculars = 1,
		/obj/item/assembly/signaler = 1,
		/obj/item/detpack = 1,
	)
