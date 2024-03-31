/mob/living/carbon/human/species/elf
	race = /datum/species/elf

/datum/species/elf
	name = "Elfb"
	id = "elf"
	max_age = 850

/datum/species/elf/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	RegisterSignal(C, COMSIG_MOB_SAY, .proc/handle_speech)
	C.grant_language(/datum/language/common)
	C.grant_language(/datum/language/elvish)

/datum/species/elf/check_roundstart_eligible()
	return FALSE

/datum/species/elf/after_creation(mob/living/carbon/C)
	..()
//	if(!C.has_language(/datum/language/elvish))
	C.grant_language(/datum/language/elvish)
	to_chat(C, "<span class='info'>I can speak Elfish with ,e before my speech.</span>")

/datum/species/elf/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_SAY)
	C.remove_language(/datum/language/elvish)

/datum/species/elf/qualifies_for_rank(rank, list/features)
	return TRUE

/datum/species/elf/get_skin_list()
	return sortList(list(
	"skin1" = "ffe0d1",
	"skin2" = "fcccb3"
	))

/datum/species/elf/get_hairc_list()
	return sortList(list(
	"black - nightsky" = "0a0707",
	"brown - treebark" = "362e25",
	"blonde - moonlight" = "dfc999",
	"red - autumn" = "a34332"
	))