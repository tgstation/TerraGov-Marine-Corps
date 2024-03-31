/datum/job/roguetown/steward
	title = "Steward"
	flag = STEWARD
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1

	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Dwarf",
	"Dwarf",
	"Aasimar",
	"Half-Elf")
	allowed_sexes = list(MALE, FEMALE)
	display_order = JDO_STEWARD
	tutorial = "Coin, Coin, Coin! Oh beautiful coin: Youre addicted to it, and you hold the position as the King's personal treasurer of both coin and information. You know the power silver and gold has on a man's mortal soul, and you know just what lengths theyll go to in order to get even more. Keep your festering economy and your rats alive, theyre the only two things you can weigh any trust into anymore."
	outfit = /datum/outfit/job/roguetown/steward
	give_bank_account = 17

/datum/outfit/job/roguetown/steward/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.gender == FEMALE)
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gen/blue
		cloak = /obj/item/clothing/cloak/tabard/knight
	else
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor
		pants = /obj/item/clothing/under/roguetown/tights/random
		armor = /obj/item/clothing/cloak/tabard/knight
	ADD_TRAIT(H, RTRAIT_SEEPRICES, type)
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	head = /obj/item/clothing/head/roguetown/chaperon/greyscale
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	beltr = /obj/item/keyring/steward

	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 6, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.change_stat("strength", -2)
		H.change_stat("intelligence", 8)
		H.change_stat("constitution", -2)
		H.change_stat("speed", -2)
	ADD_TRAIT(H, RTRAIT_NOBLE, TRAIT_GENERIC)

	if(H.charflaw)
		if(H.charflaw.type != /datum/charflaw/badsight)
			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_ARM)
			if(O)
				O.drop_limb()
				qdel(O)
			O = H.get_bodypart(BODY_ZONE_L_ARM)
			if(O)
				O.drop_limb()
				qdel(O)
			H.regenerate_limb(BODY_ZONE_R_ARM)
			H.regenerate_limb(BODY_ZONE_L_ARM)
			H.charflaw = new /datum/charflaw/badsight()
			if(!istype(H.wear_mask, /obj/item/clothing/mask/rogue/spectacles))
				qdel(H.wear_mask)
				mask = /obj/item/clothing/mask/rogue/spectacles
