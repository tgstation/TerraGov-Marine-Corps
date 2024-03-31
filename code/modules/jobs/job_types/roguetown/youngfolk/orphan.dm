/datum/job/roguetown/orphan
	title = "Orphan"
	flag = ORPHAN
	department_flag = YOUNGFOLK
	faction = "Station"
	total_positions = 5
	spawn_positions = 3

	allowed_races = list("Humen",
	"Humen",
	"Half-Elf")
	allowed_ages = list(AGE_YOUNG)

	tutorial = "Dozens of unwanted children are born in the kingdom of Psydonia every day. They sometimes make something of themselves but much more often die early in the streets."

	outfit = /datum/outfit/job/roguetown/orphan
	display_order = JDO_ORPHAN
	show_in_credits = FALSE

/datum/job/roguetown/orphan/New()
	. = ..()
	peopleknowme = list()

/datum/outfit/job/roguetown/orphan/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.gender == FEMALE)
		armor = /obj/item/clothing/suit/roguetown/shirt/rags
	else
		pants = /obj/item/clothing/under/roguetown/tights/vagrant
		if(prob(50))
			pants = /obj/item/clothing/under/roguetown/tights/vagrant/l
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant
		if(prob(50))
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/vagrant/l
	if(prob(33))
		cloak = /obj/item/clothing/cloak/half/brown
		gloves = /obj/item/clothing/gloves/roguetown/fingerless
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, pick(1,2), TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/stealing, round(rand(2,5)), TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, pick(1,2), TRUE)
		H.STALUC = rand(1, 20)
	if(prob(10))
		r_hand = /obj/item/rogue/instrument/flute
	H.change_stat("intelligence", -4)
	H.change_stat("constitution", -1)
	H.change_stat("endurance", -1)