/mob/living/carbon/human/species/dwarf/mountain
	race = /datum/species/dwarf/mountain

/datum/species/dwarf/mountain
	name = "Dwarf"
	id = "dwarf"
	desc = "<b>Dwarf</b><br>\
	A proud and robust race of short mountain folk, \
	the dwarves are known for their pride in martial strength \
	and their tenacity towards their ancient traditions.\
	A Dwarf, much like the rock that they carve their fortress out of \
	is stubborn and ancient, with their race being the longest lived of all \
	of the weeping gods creation. They, like stone: also rarely change \
	and tend to shun the modernization of the world around them. \
	Instead, a Dwarf looks to his ancestorial heritage for guidance on \
	the various challenges they face. Even if, in some irony: this behaviour \
	leads the race towards technological advacement as they continue \
	to improve their craft through powerful mechanization and forging \
	Dwarves are hearty, but are not known for their speed or eyesight..."
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,YOUNGBEARD,STUBBLE,OLDGREY)
	inherent_traits = list(TRAIT_NOMOBSWAP)
	possible_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD)
	default_features = list("mcolor" = "FFF", "wings" = "None")
	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/animalhide/human
	disliked_food = NONE
	liked_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_icon_m = 'icons/roguetown/mob/bodies/m/md.dmi'
	limbs_icon_f = 'icons/roguetown/mob/bodies/f/fd.dmi'
	dam_icon = 'icons/roguetown/mob/bodies/dam/dam_male.dmi'
	dam_icon_f = 'icons/roguetown/mob/bodies/dam/dam_female.dmi'
	hairyness = "t3"
	soundpack_m = /datum/voicepack/male/dwarf
	soundpack_f = /datum/voicepack/female/dwarf
	custom_clothes = TRUE
	offset_features = list(OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_WRISTS = list(0,0),\
	OFFSET_CLOAK = list(0,0), OFFSET_FACEMASK = list(0,-4), OFFSET_HEAD = list(0,-4), \
	OFFSET_FACE = list(0,-4), OFFSET_BELT = list(0,-5), OFFSET_BACK = list(0,-4), \
	OFFSET_NECK = list(0,-4), OFFSET_MOUTH = list(0,-4), OFFSET_PANTS = list(0,0), \
	OFFSET_SHIRT = list(0,0), OFFSET_ARMOR = list(0,0), OFFSET_HANDS = list(0,-3), \
	OFFSET_ID_F = list(0,-4), OFFSET_GLOVES_F = list(0,-4), OFFSET_WRISTS_F = list(0,-4), OFFSET_HANDS_F = list(0,-4), \
	OFFSET_CLOAK_F = list(0,0), OFFSET_FACEMASK_F = list(0,-5), OFFSET_HEAD_F = list(0,-5), \
	OFFSET_FACE_F = list(0,-5), OFFSET_BELT_F = list(0,-5), OFFSET_BACK_F = list(0,-5), \
	OFFSET_NECK_F = list(0,-5), OFFSET_MOUTH_F = list(0,-5), OFFSET_PANTS_F = list(0,0), \
	OFFSET_SHIRT_F = list(0,0), OFFSET_ARMOR_F = list(0,0), OFFSET_UNDIES = list(0,0), OFFSET_UNDIES_F = list(0,0))
	specstats = list("strength" = 1, "perception" = -2, "intelligence" = 0, "constitution" = 2, "endurance" = 2, "speed" = -3, "fortune" = 0)
	specstats_f = list("strength" = 1, "perception" = -2, "intelligence" = 0, "constitution" = 2, "endurance" = 1, "speed" = -2, "fortune" = 0)
	enflamed_icon = "widefire"
	possible_faiths = list(FAITH_PSYDON, FAITH_DWARF)

/datum/species/dwarf/mountain/check_roundstart_eligible()
	return TRUE

/datum/species/dwarf/mountain/get_span_language(datum/language/message_language)
	if(!message_language)
		return
	if(message_language.type == /datum/language/dwarvish)
		return list(SPAN_DWARF)
//	if(message_language.type == /datum/language/common)
//		return list(SPAN_DWARF)
	return message_language.spans

/datum/species/dwarf/mountain/get_skin_list()
	return sortList(list(
	"skin1" = "ffe0d1",
	"skin2" = "fcccb3",
	"skin3" = "edc6b3",
	"skin4" = "e2b9a3",
	"skin5" = "d9a284",
	"skin6" = "c69b83"
	))

/datum/species/dwarf/mountain/get_hairc_list()
	return sortList(list(
	"black - oil" = "181a1d",
	"black - cave" = "201616",
	"black - rogue" = "2b201b",
	"black - midnight" = "1d1b2b",

	"blond - pale" = "9d8d6e",
	"blond - dirty" = "88754f",
	"blond - drywheat" = "d5ba7b",
	"blond - strawberry" = "c69b71",

	"brown - mud" = "362e25",
	"brown - oats" = "7a4e1e",
	"brown - grain" = "58433b",
	"brown - soil" = "48322a",

	"red - berry" = "b23434",
	"red - wine" = "b87f77",
	"red - sunset" = "bf6821",
	"red - blood" = "822b2b"
	))

/datum/species/dwarf/mountain/random_name(gender,unique,lastname)

	var/randname
	if(unique)
		if(gender == MALE)
			for(var/i in 1 to 10)
				randname = pick( world.file2list("strings/rt/names/dwarf/dwarmm.txt") )
				if(!findname(randname))
					break
		if(gender == FEMALE)
			for(var/i in 1 to 10)
				randname = pick( world.file2list("strings/rt/names/dwarf/dwarmf.txt") )
				if(!findname(randname))
					break
	else
		if(gender == MALE)
			randname = pick( world.file2list("strings/rt/names/dwarf/dwarmm.txt") )
		if(gender == FEMALE)
			randname = pick( world.file2list("strings/rt/names/dwarf/dwarmf.txt") )
	return randname

/datum/species/dwarf/mountain/random_surname()
	return " [pick(world.file2list("strings/rt/names/dwarf/dwarmlast.txt"))]"
