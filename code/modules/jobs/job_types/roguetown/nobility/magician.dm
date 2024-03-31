/datum/job/roguetown/magician
	title = "Court Magician"
	flag = WIZARD
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1

	allowed_races = list("Humen",
	"Humen",
	"Elf",
	"Aasimar",
	"Half-Elf")
	allowed_sexes = list(MALE, FEMALE)
	spells = list(/obj/effect/proc_holder/spell/invoked/projectile/fireball/greater, /obj/effect/proc_holder/spell/invoked/projectile/fireball, /obj/effect/proc_holder/spell/invoked/projectile/lightningbolt, /obj/effect/proc_holder/spell/invoked/projectile/fetch)
	display_order = JDO_MAGICIAN
	tutorial = "Your creed is one dedicated to the conquering of the arcane arts and the constant thrill of knowledge. You owe your life to the Lord, for it was his coin that allowed you to continue your studies in these darker ages. Something you have proven time and time again as justicar and trusted advisor to their reign. You may have an apprentice, show them what they can achieve in their future. "
	outfit = /datum/outfit/job/roguetown/magician
	whitelist_req = TRUE
	give_bank_account = 47
	min_pq = -4

/datum/outfit/job/roguetown/magician/pre_equip(mob/living/carbon/human/H)
	..()
	ADD_TRAIT(H, RTRAIT_SEEPRICES, type)
	shoes = /obj/item/clothing/shoes/roguetown/shortboots
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/black
	cloak = /obj/item/clothing/cloak/black_cloak
	id = /obj/item/clothing/ring/gold
	belt = /obj/item/storage/belt/rogue/leather/plaquesilver
	beltr = /obj/item/keyring/mage
	neck = /obj/item/clothing/neck/roguetown/talkstone
	pants = /obj/item/clothing/under/roguetown/tights/random
	r_hand = /obj/item/rogueweapon/woodstaff
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 6, TRUE)
		H.mind.adjust_skillrank(/datum/skill/magic/arcane, pick(6,5), TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.change_stat("strength", -2)
		H.change_stat("intelligence", 5)
		H.change_stat("constitution", -2)
		H.change_stat("speed", -2)
		if(H.age == AGE_OLD)
			H.change_stat("speed", -1)
			H.change_stat("intelligence", 1)
			if(H.dna.species.id == "human")
				belt = /obj/item/storage/belt/rogue/leather/plaquegold
				cloak = null
				head = /obj/item/clothing/head/roguetown/wizhat
				armor = /obj/item/clothing/suit/roguetown/shirt/robe/wizard
				H.dna.species.soundpack_m = new /datum/voicepack/male/wizard()
	ADD_TRAIT(H, RTRAIT_NOBLE, TRAIT_GENERIC)
