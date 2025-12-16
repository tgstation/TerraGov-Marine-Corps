/datum/outfit/job/command/ceo
	name = CHIEF_EXECUTIVE_OFFICER
	jobtype = /datum/job/terragov/command/ceo

	id = /obj/item/card/id/gold
	belt = /obj/item/storage/holster/belt/mateba/officer/full
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/sneaking/armoredsuit
	shoes = /obj/item/clothing/shoes/marine
	gloves = /obj/item/clothing/gloves/marine/officer/
	r_pocket = /obj/item/storage/pouch/general/large/command
	l_pocket = /obj/item/hud_tablet/leadership
	back = /obj/item/storage/backpack/lightpack

/datum/outfit/job/command/ceo/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_hand(new /obj/item/binoculars/fire_support/extended, SLOT_IN_R_POUCH)

/datum/outfit/job/command/corpseccommander
	name = CORPSEC_COMMANDER
	jobtype = /datum/job/terragov/command/corpseccommander

	id = /obj/item/card/id/dogtag
	belt = /obj/item/storage/holster/blade/officer/full
	glasses = /obj/item/clothing/glasses/hud/security
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/hosformalmale
	wear_suit = /obj/item/clothing/suit/armor/hos
	shoes = /obj/item/clothing/shoes/swat
	gloves = /obj/item/clothing/gloves/marine/officer
	head = /obj/item/clothing/head/beret/sec/hos
	r_pocket = /obj/item/storage/pouch/general/large/command
	l_pocket = /obj/item/hud_tablet/fieldcommand
	back = /obj/item/storage/backpack/security
	suit_store = /obj/item/storage/holster/belt/pistol/m4a3/fieldcommander

/datum/outfit/job/command/corpseccomander/robot
	species = list(SPECIES_COMBAT_ROBOT)

	w_uniform = /obj/item/clothing/under/marine/robotic
	wear_suit = /obj/item/clothing/suit/modular/robot
	head = /obj/item/clothing/head/modular/robot
	r_pocket = /obj/item/storage/pouch/general/large/command
	l_pocket = /obj/item/hud_tablet/fieldcommand
	suit_store = /obj/item/storage/holster/belt/pistol/m4a3/fieldcommander

/datum/outfit/job/command/vanguard
	name = VANGUARD
	jobtype = /datum/job/terragov/command/vanguard

	id = /obj/item/card/id/card/silver/vanguard
	ears = /obj/item/radio/headset/mainship/mcom
	w_uniform = /obj/item/clothing/under/marine/officer
	shoes = /obj/item/clothing/shoes/marine
	r_pocket = /obj/item/storage/pouch/general/large


/datum/outfit/job/command/vanguard/robot
	species = list(SPECIES_COMBAT_ROBOT)

	w_uniform = /obj/item/clothing/under/marine/robotic
	head = /obj/item/clothing/head/modular/robot
	r_pocket = /obj/item/storage/pouch/general/large
