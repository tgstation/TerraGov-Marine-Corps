/datum/mutant_accessory/ears
	key = "ears"
	generic = "Ears"
	//organ_type = /obj/item/organ/ears/mutant
	relevent_layers = list(BODY_ADJ_LAYER, BODY_FRONT_LAYER)
	icon = 'icons/mob/mutant_accessory/ears.dmi'

/datum/mutant_accessory/ears/is_hidden(mob/living/carbon/human/H)
	if(H.head && (H.head.flags_inv_hide & HIDETOPHAIR) || (H.wear_mask && (H.wear_mask.flags_inv_hide & HIDETOPHAIR)))
		return TRUE
	return FALSE

/datum/mutant_accessory/ears/none
	name = "None"
	icon_state = "none"

/datum/mutant_accessory/ears/cat
	name = "Cat"
	icon_state = "cat"
	color_src = USE_ONE_COLOR
	allowed_species = list(FLEXIBLE_SPECIES)
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)
	extra = TRUE
	extra_color_src = null

/datum/mutant_accessory/ears/cat/haircolor
	name = "Cat, haircolored"
	color_src = HAIR

/datum/mutant_accessory/ears/mutant
	//organ_type = /obj/item/organ/ears/mutant
	color_src = USE_MATRIXED_COLORS
	allowed_species = list(FLEXIBLE_SPECIES)

/datum/mutant_accessory/ears/mutant/none
	name = "None"
	icon_state = "none"
	color_src = null
	factual = FALSE

/datum/mutant_accessory/ears/mutant/vulpkanin
	allowed_species = list(FLEXIBLE_SPECIES, VULPINE_SPECIES)

/datum/mutant_accessory/ears/mutant/tajaran
	allowed_species = list(FLEXIBLE_SPECIES, FELINE_SPECIES)

/datum/mutant_accessory/ears/mutant/akula
	allowed_species = list(FLEXIBLE_SPECIES, AQUATIC_SPECIES)

/datum/mutant_accessory/ears/mutant/axolotl
	name = "Axolotl"
	icon_state = "axolotl"
	color_src = USE_ONE_COLOR

/datum/mutant_accessory/ears/mutant/bat
	name = "Bat"
	icon_state = "bat"

/datum/mutant_accessory/ears/mutant/bear
	name = "Bear"
	icon_state = "bear"
	color_src = USE_ONE_COLOR

/datum/mutant_accessory/ears/mutant/bigwolf
	name = "Big Wolf"
	icon_state = "bigwolf"

/datum/mutant_accessory/ears/mutant/bigwolfinner
	name = "Big Wolf (ALT)"
	icon_state = "bigwolfinner"
	extra = TRUE
	extra_color_src = NONE

/datum/mutant_accessory/ears/mutant/bigwolfdark //alphabetical sort ignored here for ease-of-use
	name = "Dark Big Wolf"
	icon_state = "bigwolfdark"

/datum/mutant_accessory/ears/mutant/bigwolfinnerdark
	name = "Dark Big Wolf (ALT)"
	icon_state = "bigwolfinnerdark"
	extra = TRUE
	extra_color_src = NONE

/datum/mutant_accessory/ears/mutant/bunny
	name = "Bunny"
	icon_state = "bunny"

/datum/mutant_accessory/ears/mutant/tajaran/catbig
	name = "Cat, Big"
	icon_state = "catbig"

/datum/mutant_accessory/ears/mutant/tajaran/catnormal
	name = "Cat, normal"
	icon_state = "catnormal"

/datum/mutant_accessory/ears/mutant/cow
	name = "Cow"
	icon_state = "cow"
	color_src = USE_ONE_COLOR

/datum/mutant_accessory/ears/mutant/curled
	name = "Curled Horn"
	icon_state = "horn1"
	color_src = USE_ONE_COLOR
	default_color = DEFAULT_TERTIARY

/datum/mutant_accessory/ears/mutant/deer
	name = "Deer"
	icon_state = "deer"
	color_src = USE_ONE_COLOR
	default_color = DEFAULT_TERTIARY

/datum/mutant_accessory/ears/mutant/eevee
	name = "Eevee"
	icon_state = "eevee"
	color_src = USE_ONE_COLOR

/datum/mutant_accessory/ears/mutant/eevee_alt
	name = "Eevee ALT"
	icon_state = "eevee_alt"
	color_src = USE_MATRIXED_COLORS

/datum/mutant_accessory/ears/mutant/elf
	name = "Elf"
	icon_state = "elf"
	color_src = USE_ONE_COLOR
	default_color = DEFAULT_SKIN_OR_PRIMARY

/datum/mutant_accessory/ears/mutant/elephant
	name = "Elephant"
	icon_state = "elephant"
	color_src = USE_ONE_COLOR

/datum/mutant_accessory/ears/mutant/fennec
	name = "Fennec"
	icon_state = "fennec"

/datum/mutant_accessory/ears/mutant/fish
	name = "Fish"
	icon_state = "fish"
	color_src = USE_ONE_COLOR

/datum/mutant_accessory/ears/mutant/vulpkanin/fox
	name = "Fox"
	icon_state = "fox"

/datum/mutant_accessory/ears/mutant/husky
	name = "Husky"
	icon_state = "wolf"

/datum/mutant_accessory/ears/mutant/jellyfish
	name = "Jellyfish"
	icon_state = "jellyfish"
	color_src = HAIR

/datum/mutant_accessory/ears/mutant/kangaroo
	name = "Kangaroo"
	icon_state = "kangaroo"

/datum/mutant_accessory/ears/mutant/lab
	name = "Dog, Long"
	icon_state = "lab"
	color_src = USE_ONE_COLOR

/datum/mutant_accessory/ears/mutant/murid
	name = "Murid"
	icon_state = "murid"

/datum/mutant_accessory/ears/mutant/vulpkanin/otie
	name = "Otusian"
	icon_state = "otie"

/datum/mutant_accessory/ears/mutant/rabbit
	name = "Rabbit"
	icon_state = "rabbit"

/datum/mutant_accessory/ears/mutant/pede
	name = "Scolipede"
	icon_state = "pede"

/datum/mutant_accessory/ears/mutant/akula/sergal
	name = "Sergal"
	icon_state = "sergal"

/datum/mutant_accessory/ears/mutant/skunk
	name = "skunk"
	icon_state = "skunk"

/datum/mutant_accessory/ears/mutant/squirrel
	name = "Squirrel"
	icon_state = "squirrel"

/datum/mutant_accessory/ears/mutant/vulpkanin/wolf
	name = "Wolf"
	icon_state = "wolf"

/datum/mutant_accessory/ears/mutant/vulpkanin/perky
	name = "Perky"
	icon_state = "perky"

/datum/mutant_accessory/ears/mutant/antenna_simple1
	name = "Insect antenna"
	icon_state = "antenna_simple1"

/datum/mutant_accessory/ears/mutant/antenna_simple2
	name = "Insect antenna 2"
	icon_state = "antenna_simple2"

/datum/mutant_accessory/ears/mutant/antenna_fuzzball
	name = "Fuzzball antenna"
	icon_state = "antenna_fuzzball"

/datum/mutant_accessory/ears/mutant/cobrahood
	name = "Cobra Hood"
	icon_state = "cobrahood"

/datum/mutant_accessory/ears/mutant/cobrahoodears
	name = "Cobra Hood (Ears)"
	icon_state = "cobraears"

/datum/mutant_accessory/ears/mutant/miqote
	name = "Miqo'te"
	icon_state = "miqote"
