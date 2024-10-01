/datum/outfit/job/imperial
	name = "Imperial Standard"
	jobtype = /datum/job/imperial

	id = /obj/item/card/id
	ears = /obj/item/radio/headset/distress/imperial
	w_uniform = /obj/item/clothing/under/marine/imperial
	shoes = /obj/item/clothing/shoes/marine/imperial
	gloves = /obj/item/clothing/gloves/marine

/datum/outfit/job/imperial/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.grant_language(/datum/language/imperial)

/datum/outfit/job/imperial/guardsman
	name = "Imperial Guardsman"
	jobtype = /datum/job/imperial/guardsman

	belt = /obj/item/storage/belt/marine/te_cells
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial
	suit_store = /obj/item/weapon/gun/energy/lasgun/lasrifle
	head = /obj/item/clothing/head/helmet/marine/imperial
	r_pocket = /obj/item/storage/pouch/medical_injectors/firstaid
	l_pocket = /obj/item/storage/holster/flarepouch/full
	back = /obj/item/storage/backpack/lightpack

	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/enrg_bar = 2,
	)

	suit_contents = list(
		/obj/item/explosive/grenade = 1,
		/obj/item/explosive/grenade/incendiary = 1,
	)

	head_contents = list(
		/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 1,
	)


/datum/outfit/job/imperial/guardsman/sergeant
	name = "Guardsman Sergeant"
	jobtype = /datum/job/imperial/guardsman/sergeant

	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/sergeant
	head = /obj/item/clothing/head/helmet/marine/imperial/sergeant
	r_pocket = /obj/item/storage/pouch/explosive/upp
	l_pocket = /obj/item/storage/pouch/field_pouch/full

/datum/outfit/job/imperial/guardsman/medicae
	name = "Guardsman Medicae"
	jobtype = /datum/job/imperial/guardsman/medicae

	belt = /obj/item/storage/belt/lifesaver/full
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/medicae
	glasses = /obj/item/clothing/glasses/hud/health
	l_pocket = /obj/item/storage/pouch/medkit/medic
	r_pocket = /obj/item/storage/pouch/medical_injectors/medic

	backpack_contents = list(
		/obj/item/cell/lasgun/lasrifle = 5,
		/obj/item/defibrillator = 1,
		/obj/item/storage/pill_bottle/zoom = 1,
	)

/datum/outfit/job/imperial/commissar
	name = "Imperial Commissar"
	jobtype = /datum/job/imperial/commissar

	belt = /obj/item/storage/holster/belt/mateba/full //Ideally this can be later replaced with a bolter
	w_uniform = /obj/item/clothing/under/marine/imperial/commissar
	wear_suit = /obj/item/clothing/suit/storage/marine/imperial/commissar
	suit_store = /obj/item/weapon/sword/commissar_sword
	gloves = /obj/item/clothing/gloves/marine/commissar
	head = /obj/item/clothing/head/commissar
	l_pocket = /obj/item/storage/pouch/medkit/firstaid
	r_pocket = /obj/item/storage/pouch/magazine/pistol/large/mateba
	back = /obj/item/storage/backpack/lightpack
	
	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/enrg_bar = 2,
	)

	suit_contents = list(
		/obj/item/explosive/grenade = 1,
		/obj/item/explosive/grenade/incendiary = 1,
	)
