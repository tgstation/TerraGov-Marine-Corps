/datum/outfit/job/som/command/commander
	name = SOM_COMMANDER
	jobtype = /datum/job/som/command/commander

	id = /obj/item/card/id/gold
	ears = /obj/item/radio/headset/mainship/mcom/som
	belt = /obj/item/storage/holster/belt/mateba/officer/full
	w_uniform = /obj/item/clothing/under/som/officer/senior
	shoes = /obj/item/clothing/shoes/marine/som/knife
	gloves = /obj/item/clothing/gloves/marine/techofficer/captain
	r_pocket = /obj/item/storage/pouch/general/large/command

	r_hand = /obj/item/binoculars/fire_support/campaign/som


/datum/outfit/job/som/command/fieldcommander
	name = SOM_FIELD_COMMANDER
	jobtype = /datum/job/som/command/fieldcommander

	id = /obj/item/card/id/dogtag/fc
	ears = /obj/item/radio/headset/mainship/mcom/som
	head = /obj/item/clothing/head/modular/som/leader
	mask = /obj/item/clothing/mask/gas
	w_uniform = /obj/item/clothing/under/som/officer/senior
	wear_suit = /obj/item/clothing/suit/modular/som/heavy/leader/officer
	shoes = /obj/item/clothing/shoes/marine/som/knife
	r_pocket = /obj/item/storage/pouch/general/large/command
	gloves = /obj/item/clothing/gloves/marine/officer
	belt = /obj/item/storage/holster/belt/pistol/m4a3/fieldcommander
	glasses = /obj/item/clothing/glasses/hud/health
	l_pocket = /obj/item/storage/pouch/grenade/som/combat_patrol
	back = /obj/item/storage/backpack/satchel/som

/datum/outfit/job/som/command/fieldcommander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclot, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_SUIT)

/datum/outfit/job/som/command/staffofficer
	name = SOM_STAFF_OFFICER
	jobtype = /datum/job/som/command/staffofficer

	id = /obj/item/card/id/silver
	ears = /obj/item/radio/headset/mainship/mcom/som
	w_uniform = /obj/item/clothing/under/som/officer
	shoes = /obj/item/clothing/shoes/marine/som/knife
	r_pocket = /obj/item/storage/pouch/general/large
	l_pocket = /obj/item/binoculars/tactical

/datum/outfit/job/som/command/pilot
	name = SOM_PILOT_OFFICER
	jobtype = /datum/job/som/command/pilot

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/holster/belt/pistol/m4a3/vp70
	ears = /obj/item/radio/headset/mainship/mcom/som
	w_uniform = /obj/item/clothing/under/marine/officer/pilot
	wear_suit = /obj/item/clothing/suit/storage/marine/pilot
	shoes = /obj/item/clothing/shoes/marine/som/knife
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
	ears = /obj/item/radio/headset/mainship/mcom/som
	w_uniform = /obj/item/clothing/under/marine/officer/mech
	wear_suit = /obj/item/clothing/suit/storage/marine/mech_pilot
	head = /obj/item/clothing/head/helmet/marine/mech_pilot
	shoes = /obj/item/clothing/shoes/marine/som/knife
	gloves = /obj/item/clothing/gloves/marine

/datum/outfit/job/som/command/assault_crewman
	name = SOM_ASSAULT_CREWMAN
	jobtype = /datum/job/som/command/mech_pilot

	id = /obj/item/card/id/dogtag
	ears = /obj/item/radio/headset/mainship/mcom/som
	shoes = /obj/item/clothing/shoes/marine/som/knife
	belt = /obj/item/storage/belt/utility/full
	glasses = /obj/item/clothing/glasses/welding
	w_uniform = /obj/item/clothing/under/marine/officer/assault_crewman
	wear_suit = /obj/item/clothing/suit/storage/marine/assault_crewman
	head = /obj/item/clothing/head/helmet/marine/assault_crewman
	gloves = /obj/item/clothing/gloves/marine
	l_pocket = /obj/item/pamphlet/tank_loader

/datum/outfit/job/som/engineering/chief
	name = SOM_CHIEF_ENGINEER
	jobtype = /datum/job/som/engineering/chief

	id = /obj/item/card/id/silver
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/mainship/mcom/som
	w_uniform = /obj/item/clothing/under/marine/officer/ce
	wear_suit = /obj/item/clothing/suit/storage/marine/officer/req
	shoes = /obj/item/clothing/shoes/marine/som/knife
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
	shoes = /obj/item/clothing/shoes/marine/som/knife
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
	ears = /obj/item/radio/headset/mainship/mcom/som
	w_uniform = /obj/item/clothing/under/marine/officer/ro_suit
	wear_suit = /obj/item/clothing/suit/storage/marine/officer/req
	suit_store = /obj/item/weapon/gun/energy/taser
	shoes = /obj/item/clothing/shoes/marine/som/knife
	gloves = /obj/item/clothing/gloves/insulated
	head = /obj/item/clothing/head/tgmccap/req
	r_pocket = /obj/item/storage/pouch/general/large

/datum/outfit/job/som/medical

	id = /obj/item/card/id
	belt = /obj/item/storage/belt/rig/medical
	ears = /obj/item/radio/headset/mainship/som/doc
	w_uniform = /obj/item/clothing/under/rank/medical/purple
	wear_suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/latex
	glasses = /obj/item/clothing/glasses/hud/health
	mask = /obj/item/clothing/mask/surgical
	back = /obj/item/storage/backpack/satchel
	head = /obj/item/clothing/head/surgery/purple
	l_pocket = /obj/item/storage/pouch/surgery
	r_pocket = /obj/item/storage/pouch/medkit/doctor

	backpack_contents = list(
		/obj/item/tweezers_advanced = 1,
		/obj/item/reagent_containers/glass/bottle/lemoline/doctor = 1,
	)

/datum/outfit/job/som/medical/professor
	name = SOM_CHIEF_MEDICAL_OFFICER
	jobtype = /datum/job/som/medical/professor

	ears = /obj/item/radio/headset/mainship/mcom/som
	w_uniform = /obj/item/clothing/under/rank/medical/blue
	wear_suit = /obj/item/clothing/suit/storage/labcoat/cmo
	head = /obj/item/clothing/head/cmo

/datum/outfit/job/som/medical/medicalofficer
	name = SOM_MEDICAL_DOCTOR
	jobtype = /datum/job/som/medical/medicalofficer


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

/datum/outfit/job/civilian/synthetic/som
	name = SYNTHETIC
	jobtype = /datum/job/som/silicon/synthetic

	id = /obj/item/card/id/gold
	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/mainship/mcom/som
	w_uniform = /obj/item/clothing/under/rank/synthetic
	shoes = /obj/item/clothing/shoes/white
	gloves = /obj/item/clothing/gloves/insulated
	r_pocket = /obj/item/storage/pouch/general/medium
	l_pocket = /obj/item/storage/pouch/general/medium
