/obj/item/clothing/gloves/insulated
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "insulated"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	flags_cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/yellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05

/obj/item/clothing/gloves/yellow/Initialize(mapload)
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)

/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	flags_cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	flags_heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE


/obj/item/clothing/gloves/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"

/obj/item/clothing/gloves/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"

/obj/item/clothing/gloves/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"

/obj/item/clothing/gloves/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"

/obj/item/clothing/gloves/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"

/obj/item/clothing/gloves/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"

/obj/item/clothing/gloves/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"

/obj/item/clothing/gloves/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"

/obj/item/clothing/gloves/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"

/obj/item/clothing/gloves/sectoid
	name = "psionic field"
	desc = "A field of invisible energy, it protects the wearer but prevents any clothing from being worn."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-blue"
	flags_item = DELONDROP
	soft_armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 20, FIRE = 20, ACID = 25)

/obj/item/clothing/gloves/sectoid/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SECTOID_TRAIT)
