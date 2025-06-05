/datum/outfit/job/survivor
	name = "Survivor"
	jobtype = /datum/job/survivor

	w_uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/snow
	back = /obj/item/storage/backpack/satchel/norm
	wear_suit = /obj/item/clothing/suit/storage/snow_suit
	ears = /obj/item/radio/headset/survivor
	mask = /obj/item/clothing/mask/rebreather
	head = /obj/item/clothing/head/hardhat/rugged
	belt = /obj/item/belt_harness
	gloves = /obj/item/clothing/gloves/black
	glasses = /obj/item/clothing/glasses/welding
	r_pocket = /obj/item/storage/pouch/tools/full
	l_pocket = /obj/item/storage/pouch/survival/full
	id = /obj/item/card/id/captains_spare/survival
	backpack_contents = list(
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

/datum/outfit/job/survivor/non_deployed_operative
	name = "Non-Deployed Operative Survivor"
	jobtype = /datum/job/survivor/non_deployed_operative

	w_uniform = /obj/item/clothing/under/marine/service
	gloves = /obj/item/clothing/gloves/white
	shoes = /obj/item/clothing/shoes/marine/full
	head = /obj/item/clothing/head/servicecap
	back = /obj/item/storage/backpack/marine/satchel
	backpack_contents = list(
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
		/obj/item/tool/pen = 1,
		/obj/item/paper = 1,
		/obj/item/folder/white = 1,
	)

/datum/outfit/job/survivor/prisoner
	name = "Prisoner Survivor"
	jobtype = /datum/job/survivor/prisoner

	w_uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/orange
	back =  /obj/item/storage/backpack/security
	mask = /obj/item/clothing/mask/gas/modular/skimask
	backpack_contents = list(
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
		/obj/item/restraints/handcuffs = 1
	)

/datum/outfit/job/survivor/stripper
	name = "Stripper Survivor"
	jobtype = /datum/job/survivor/stripper

	w_uniform = /obj/item/clothing/under/lewd/stripper
	shoes = /obj/item/clothing/shoes/high_heels/red
	back =  /obj/item/storage/backpack/satchel
	head = /obj/item/clothing/head/bunny_ears
	backpack_contents = list(
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
	)

/datum/outfit/job/survivor/maid
	name = "Maid Survivor"
	jobtype = /datum/job/survivor/maid

	w_uniform = /obj/item/clothing/under/dress/maid
	gloves = /obj/item/clothing/gloves/latex
	shoes = /obj/item/clothing/shoes/high_heels
	back =  /obj/item/storage/backpack/satchel/norm
	backpack_contents = list(
		/obj/item/reagent_containers/food/drinks/cans/waterbottle = 1,
		/obj/item/tool/soap/deluxe = 1,
		/obj/item/reagent_containers/glass/bucket = 1,
	)
