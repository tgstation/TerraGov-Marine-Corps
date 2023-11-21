/datum/mutant_accessory/wings
	icon = 'icons/mob/mutant_accessory/wings.dmi'
	generic = "Wings"
	key = "wings"
	color_src = USE_ONE_COLOR
	allowed_species = list(FLEXIBLE_SPECIES)
	//organ_type = /obj/item/organ/wings
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER, BODY_ADJ_LAYER)

/datum/mutant_accessory/wings/is_hidden(mob/living/carbon/human/H)
	if(H.wear_suit && H.try_hide_mutant_parts)
		return TRUE
	return FALSE

/datum/mutant_accessory/wings/none
	name = "None"
	icon_state = "none"
	factual = FALSE
	allowed_species = null
	color_src = null

/datum/mutant_accessory/wings/wide
	icon = 'icons/mob/mutant_accessory/wide_wings.dmi'
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER, BODY_ADJ_LAYER)

/datum/mutant_accessory/wings/wide/angel
	name = "Angel"
	icon_state = "angel"
	dimension_x = 46
	center = TRUE
	dimension_y = 34
	color_src = USE_ONE_COLOR
	default_color = "FFFFFF"

/datum/mutant_accessory/wings/wide/dragon
	name = "Dragon"
	icon_state = "dragon"
	dimension_x = 96
	center = TRUE
	dimension_y = 32
	color_src = USE_ONE_COLOR

//TODO: seperate moth wings from moth fluff
/datum/mutant_accessory/wings/moth
	icon = 'icons/mob/mutant_accessory/moth_wings.dmi' //Needs new icon to suit new naming convention
	default_color = "FFFFFF"
	allowed_species = list(FLEXIBLE_SPECIES, MOTH_SPECIES)
	//organ_type = /obj/item/organ/wings/moth
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/mutant_accessory/wings/moth/is_hidden(mob/living/carbon/human/H)
	if((H.wear_suit && (H.try_hide_mutant_parts || (H.wear_suit.flags_inv_hide & HIDEJUMPSUIT))))
		return TRUE
	return FALSE

/datum/mutant_accessory/wings/moth/plain
	name = "Plain"
	icon_state = "plain"

/datum/mutant_accessory/wings/moth/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/mutant_accessory/wings/moth/luna
	name = "Luna"
	icon_state = "luna"

/datum/mutant_accessory/wings/moth/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/mutant_accessory/wings/moth/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/mutant_accessory/wings/moth/royal
	name = "Royal"
	icon_state = "royal"

/datum/mutant_accessory/wings/moth/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/mutant_accessory/wings/moth/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/mutant_accessory/wings/moth/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/mutant_accessory/wings/moth/punished
	name = "Burnt Off"
	icon_state = "punished"
	locked = TRUE

/datum/mutant_accessory/wings/moth/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/mutant_accessory/wings/moth/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/mutant_accessory/wings/moth/poison
	name = "Poison"
	icon_state = "poison"

/datum/mutant_accessory/wings/moth/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/mutant_accessory/wings/moth/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/mutant_accessory/wings/moth/snow
	name = "Snow"
	icon_state = "snow"

/datum/mutant_accessory/wings/moth/oakworm
	name = "Oak Worm"
	icon_state = "oakworm"

/datum/mutant_accessory/wings/moth/jungle
	name = "Jungle"
	icon_state = "jungle"

/datum/mutant_accessory/wings/moth/witchwing
	name = "Witch Wing"
	icon_state = "witchwing"

/datum/mutant_accessory/wings/mammal
	default_color = DEFAULT_PRIMARY
	allowed_species = list(ALL_CUSTOMISH_SPECIES)
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/mutant_accessory/wings/mammal/bat
	name = "Bat"
	icon_state = "bat"

/datum/mutant_accessory/wings/mammal/fairy
	name = "Fairy"
	icon_state = "fairy"

/datum/mutant_accessory/wings/mammal/feathery
	name = "Feathery"
	icon_state = "feathery"


/datum/mutant_accessory/wings/mammal/featheryalt1
	name = "Feathery (alt 1)"
	icon_state = "featheryalt1"
	color_src = USE_MATRIXED_COLORS

/datum/mutant_accessory/wings/mammal/featheryalt2
	name = "Feathery (alt 2)"
	icon_state = "featheryalt2"
	color_src = USE_MATRIXED_COLORS

/datum/mutant_accessory/wings/mammal/bee
	name = "Bee"
	icon_state = "bee"

/datum/mutant_accessory/wings/mammal/succubus
	name = "Succubus"
	icon_state = "succubus"
	color_src = USE_MATRIXED_COLORS

/datum/mutant_accessory/wings/mammal/dragon_synth
	name = "Dragon (synthetic alt)"
	icon_state = "dragonsynth"
	color_src = USE_MATRIXED_COLORS

/datum/mutant_accessory/wings/mammal/dragon_alt1
	name = "Dragon (alt 1)"
	icon_state = "dragonalt1"
	color_src = USE_MATRIXED_COLORS
	center = TRUE

/datum/mutant_accessory/wings/mammal/dragon_alt2
	name = "Dragon (alt 2)"
	icon_state = "dragonalt2"
	color_src = USE_MATRIXED_COLORS
	center = TRUE

/datum/mutant_accessory/wings/mammal/harpywings
	name = "Harpy"
	icon_state = "harpy"
	color_src = USE_ONE_COLOR

/datum/mutant_accessory/wings/mammal/harpywingsalt1
	name = "Harpy (alt 1)"
	icon_state = "harpyalt"
	color_src = USE_ONE_COLOR

/datum/mutant_accessory/wings/mammal/harpywingsalt2
	name = "Harpy (Bat)"
	icon_state = "harpybat"
	color_src = USE_ONE_COLOR
