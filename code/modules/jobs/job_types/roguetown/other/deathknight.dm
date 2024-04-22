/datum/job/roguetown/deathknight
	title = "Death Knight"
	flag = GRAVEDIGGER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 0
	spawn_positions = 0

	allowed_sexes = list("male", "female")
	allowed_races = list("Humen","Humen", "Half-Elf","Dark Elf","Elf","Elf", "Dwarf","Dwarf")
	tutorial = ""

	outfit = /datum/outfit/job/roguetown/deathknight
	show_in_credits = FALSE
	give_bank_account = FALSE

/datum/job/roguetown/deathknight/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	var/datum/game_mode/chaosmode/C = SSticker.mode
	C.deathknightspawn = FALSE
	C.deathknights |= L.mind
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		if(M.mind)
			M.mind.special_role = "Death Knight"
			M.mind.assigned_role = "Death Knight"
			M.mind.current.job = null
		if(H.dna && H.dna.species)
			H.dna.species.species_traits |= NOBLOOD
			H.dna.species.soundpack_m = new /datum/voicepack/skeleton()
			H.dna.species.soundpack_f = new /datum/voicepack/skeleton()
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
		for(var/obj/item/bodypart/B in H.bodyparts)
			B.skeletonize()
//		H.remove_all_languages()
		H.base_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, /datum/intent/simple/claw)
		H.update_a_intents()
		H.cmode_music = 'sound/music/combatbandit.ogg'

		var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
		if(eyes)
			eyes.Remove(H,1)
			QDEL_NULL(eyes)
		eyes = new /obj/item/organ/eyes/night_vision/zombie
		eyes.Insert(H)
		H.ambushable = FALSE
		H.underwear = "Nude"
		if(H.charflaw)
			QDEL_NULL(H.charflaw)
		H.update_body()
		H.mob_biotypes = MOB_UNDEAD
		H.faction = list("undead")
		H.name = "Death Knight"
		H.real_name = "Death Knight"
		ADD_TRAIT(H, TRAIT_NOMOOD, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOFATSTAM, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOLIMBDISABLE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOHUNGER, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOBREATH, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOPAIN, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOSLEEP, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_SHOCKIMMUNE, TRAIT_GENERIC)
		ADD_TRAIT(H, RTRAIT_HEAVYARMOR, TRAIT_GENERIC)

/datum/outfit/job/roguetown/deathknight/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/axesmaces, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/magic/arcane, 3, TRUE)


	belt = /obj/item/storage/belt/rogue/leather
	pants = /obj/item/clothing/under/roguetown/platelegs/blk/death
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/blkknight
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	armor = /obj/item/clothing/suit/roguetown/armor/plate/blkknight/death
	gloves = /obj/item/clothing/gloves/roguetown/plate/blk/death
	backl = /obj/item/rogueweapon/sword/long/death
	head = /obj/item/clothing/head/roguetown/helmet/heavy/knight/black

	H.change_stat("intelligence", 3)
	H.change_stat("strength", 2)
	H.change_stat("endurance", 2)
	H.change_stat("constitution", 2)
	H.change_stat("speed", -3)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/lightningbolt)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/fetch)

	H.ambushable = FALSE

	var/datum/antagonist/new_antag = new /datum/antagonist/skeleton/knight()
	H.mind.add_antag_datum(new_antag)

/obj/item/clothing/suit/roguetown/armor/plate/blkknight/death
	color = CLOTHING_BLACK

/obj/item/clothing/shoes/roguetown/boots/armor/blkknight/death
	color = CLOTHING_BLACK

/obj/item/clothing/gloves/roguetown/plate/blk/death
	color = CLOTHING_BLACK

/obj/item/clothing/under/roguetown/platelegs/blk/death
	color = CLOTHING_BLACK
