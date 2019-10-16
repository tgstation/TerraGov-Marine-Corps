// These may have some say.dm bugs regarding understanding common,
// might be worth adapting the bugs into a feature and using these
// subtypes as a basis for non-common-speaking alien foreigners. ~ Z

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/species/skrell
	race = "Skrell"

/datum/species/skrell/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.h_style = "Skrell Male Tentacles"

/mob/living/carbon/human/species/tajaran
	race = "Tajara"

/datum/species/tajaran/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.h_style = "Tajaran Ears"

/mob/living/carbon/human/species/unathi
	race = "Unathi"
	
/datum/species/unathi/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.h_style = "Unathi Horns"

/mob/living/carbon/human/species/vox
	race = "Vox"

/datum/species/vox/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.h_style = "Short Vox Quills"

/mob/living/carbon/human/species/voxarmalis
	race = "Vox Armalis"

/datum/species/vox/armalis/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.h_style = "Bald"

/mob/living/carbon/human/species/machine
	race = "Machine"

/datum/species/machine/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.h_style = "blue IPC screen"

/mob/living/carbon/human/species/synthetic
	race = "Synthetic"

/mob/living/carbon/human/species/synthetic_old
	race = "Early Synthetic"

/mob/living/carbon/human/species/moth
	race = "Moth"

/datum/species/moth/handle_post_spawn(mob/living/carbon/human/H)
	. = ..()
	H.moth_wings = pick(GLOB.moth_wings_list - "Burnt Off")
