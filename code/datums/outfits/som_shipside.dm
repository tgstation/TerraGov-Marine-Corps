/datum/outfit/job/som/command/commander
	name = SOM_COMMANDER
	jobtype = /datum/job/som/command/commander

	id = /obj/item/card/id/gold

	r_hand = /obj/item/binoculars/fire_support/campaign/som


/datum/outfit/job/som/command/fieldcommander
	name = SOM_FIELD_COMMANDER
	jobtype = /datum/job/som/command/fieldcommander

	id = /obj/item/card/id/dogtag/fc

/datum/outfit/job/som/command/staffofficer
	name = SOM_STAFF_OFFICER
	jobtype = /datum/job/som/command/staffofficer

	id = /obj/item/card/id/silver

/datum/outfit/job/som/command/pilot
	name = SOM_PILOT_OFFICER
	jobtype = /datum/job/som/command/pilot

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/holster/belt/pistol/m4a3/vp70
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/pilot
	wear_suit = /obj/item/clothing/suit/storage/marine/pilot
	shoes = /obj/item/clothing/shoes/marine/full
	gloves = /obj/item/clothing/gloves/insulated
	glasses = /obj/item/clothing/glasses/sunglasses/aviator
	head = /obj/item/clothing/head/helmet/marine/pilot
	r_pocket = /obj/item/storage/pouch/general/large
	l_pocket = /obj/item/hud_tablet/pilot

/datum/outfit/job/som/command/mech_pilot
	name = SOM_MECH_PILOT
	jobtype = /datum/job/som/command/mech_pilot

	id = /obj/item/card/id/dogtag
	belt = /obj/item/storage/belt/utility/full
	glasses = /obj/item/clothing/glasses/welding
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/mech
	wear_suit = /obj/item/clothing/suit/storage/marine/mech_pilot
	head = /obj/item/clothing/head/helmet/marine/mech_pilot
	shoes = /obj/item/clothing/shoes/marine/full
	gloves = /obj/item/clothing/gloves/marine

/datum/outfit/job/som/engineering/chief
	name = SOM_CHIEF_ENGINEER
	jobtype = /datum/job/som/engineering/chief

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/ce
	wear_suit = /obj/item/clothing/suit/storage/marine/officer/req
	shoes = /obj/item/clothing/shoes/marine/full
	glasses = /obj/item/clothing/glasses/welding/superior
	gloves = /obj/item/clothing/gloves/insulated
	head = /obj/item/clothing/head/beret/marine/techofficer
	r_pocket = /obj/item/storage/pouch/construction
	back = /obj/item/storage/backpack/marine/engineerpack

	r_pocket_contents = list(
		/obj/item/stack/sheet/metal/large_stack = 1,
		/obj/item/stack/sheet/plasteel/large_stack = 1,
		/obj/item/stack/sandbags/large_stack = 1,
		/obj/item/stack/barbed_wire/full = 1,
	)

/datum/outfit/job/som/engineering/tech
	name = SOM_TECH
	jobtype = /datum/job/som/engineering/tech

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/mainship/st
	w_uniform = /obj/item/clothing/under/marine/officer/engi
	wear_suit = /obj/item/clothing/suit/storage/marine/ship_tech
	shoes = /obj/item/clothing/shoes/marine/full
	gloves = /obj/item/clothing/gloves/insulated
	glasses = /obj/item/clothing/glasses/welding/flipped
	head = /obj/item/clothing/head/tgmccap/req
	r_pocket = /obj/item/storage/pouch/general/medium
	back = /obj/item/storage/backpack/marine/engineerpack

/datum/outfit/job/som/requisitions/officer
	name = SOM_REQUISITIONS_OFFICER
	jobtype = /datum/job/som/requisitions/officer

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/holster/belt/m44/full
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer/ro_suit
	wear_suit = /obj/item/clothing/suit/storage/marine/officer/req
	suit_store = /obj/item/weapon/gun/energy/taser
	shoes = /obj/item/clothing/shoes/marine/full
	gloves = /obj/item/clothing/gloves/insulated
	head = /obj/item/clothing/head/tgmccap/req
	r_pocket = /obj/item/storage/pouch/general/large

/datum/outfit/job/som/medical
	belt = /obj/item/storage/belt/rig/medical
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	mask = /obj/item/clothing/mask/surgical
	back = /obj/item/storage/backpack/satchel

	backpack_contents = list(
		/obj/item/tweezers_advanced = 1,
		/obj/item/reagent_containers/glass/bottle/lemoline/doctor = 1,
	)

/datum/outfit/job/som/medical/professor
	name = SOM_CHIEF_MEDICAL_OFFICER
	jobtype = /datum/job/som/medical/professor

	id = /obj/item/card/id
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/rank/medical/blue
	wear_suit = /obj/item/clothing/suit/storage/labcoat/cmo
	head = /obj/item/clothing/head/cmo
	r_pocket = /obj/item/storage/pouch/medkit/doctor
	l_pocket = /obj/item/storage/pouch/surgery


/datum/outfit/job/som/medical/medicalofficer
	name = SOM_MEDICAL_DOCTOR
	jobtype = /datum/job/som/medical/medicalofficer

	id = /obj/item/card/id
	ears = /obj/item/radio/headset/mainship/doc
	w_uniform = /obj/item/clothing/under/rank/medical/purple
	wear_suit = /obj/item/clothing/suit/storage/labcoat
	head = /obj/item/clothing/head/surgery/purple

/datum/outfit/job/som/civilian/chef
	name = SOM_CHEF
	jobtype = /datum/job/som/civilian/chef

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/rig/medical
	ears = /obj/item/radio/headset/mainship/doc
	w_uniform = /obj/item/clothing/under/rank/medical/purple
	wear_suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/surgery/purple
	back = /obj/item/storage/backpack/satchel

	backpack_contents = list(
		/obj/item/tweezers_advanced = 1,
		/obj/item/reagent_containers/glass/bottle/lemoline/doctor = 1,
	)
