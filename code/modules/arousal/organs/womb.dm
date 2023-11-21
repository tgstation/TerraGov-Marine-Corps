/obj/item/organ/genital/womb
	name = "womb"
	desc = "A female reproductive organ."
	icon_state = "womb"
	icon = 'modular_skyrat/icons/obj/genitals/vagina.dmi'
	organ_type = /datum/internal_organ/genital/womb


/datum/internal_organ/genital/womb
	name = "womb"
	organ_id = ORGAN_WOMB
	linked_organ_slot = "vagina"
	genital_flags = GENITAL_INTERNAL|GENITAL_FLUID_PRODUCTION
	fluid_id = /datum/reagent/consumable/femcum
	removed_type = /obj/item/organ/genital/womb
