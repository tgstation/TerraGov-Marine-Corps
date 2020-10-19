//Halo//

/obj/item/clothing/gloves/covenant/


//	var/list/species_allowed = list("Sangheili","Unggoy", "Kigyar")

/obj/item/clothing/gloves/covenant/sangheili
	icon = 'icons/obj/clothing/covenant/sangheili.dmi'
	siemens_coefficient = 0
	permeability_coefficient = 0
	flags_cold_protection = HANDS
	flags_heat_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_armor_protection = HANDS
	soft_armor = list("melee" = 15, "bullet" = 20, "laser" = 15, "energy" = 20, "bomb" = 20, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 20)
	sprite_sheets = list("Sangheili" = 'icons/mob/species/sangheili/gloves.dmi')
//	species_allowed = "Sangheili"

/obj/item/clothing/gloves/covenant/sangheili/minor
	name = "Minor Gauntlets"
	desc = "Gauntlets for a Sangheili Minor."
	icon_state = "minor_gloves"
	item_state = "minor_gloves"

/obj/item/clothing/gloves/covenant/sangheili/ranger
	name = "Ranger Gauntlets"
	desc = "Gauntlets for a Sangheili Ranger."
	icon_state = "ranger_gloves"
	item_state = "ranger_gloves"

/obj/item/clothing/gloves/covenant/sangheili/officer
	name = "Officer Gauntlets"
	desc = "Gauntlets for a Sangheili Officer."
	icon_state = "officer_gloves"
	item_state = "officer_gloves"

/obj/item/clothing/gloves/covenant/sangheili/specops
	name = "Special Ops Gauntlets"
	desc = "Gauntlets for a Special Operations Sangheili."
	icon_state = "specops_gloves"
	item_state = "specops_gloves"

/obj/item/clothing/gloves/covenant/sangheili/ultra
	name = "Ultra Gauntlets"
	desc = "Gauntlets for a Sangheili Ultra."
	icon_state = "ultra_gloves"
	item_state = "ultra_gloves"

/obj/item/clothing/gloves/covenant/sangheili/general
	name = "General Gauntlets"
	desc = "Gauntlets for a Sangheili General."
	icon_state = "general_gloves"
	item_state = "general_gloves"
