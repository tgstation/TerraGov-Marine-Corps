/obj/item/organ/genital/vagina
	name = "vagina"
	desc = "A female reproductive organ."
	icon_state = "vagina"
	icon = 'modular_skyrat/icons/obj/genitals/vagina.dmi'
	organ_type = /datum/internal_organ/genital/vagina


/datum/internal_organ/genital/vagina
	name = "vagina"
	masturbation_verb = "finger"
	arousal_verb = "You feel wetness on your crotch"
	unarousal_verb = "You no longer feel wet"
	organ_id = ORGAN_VAGINA
	linked_organ_slot = "womb"
	genital_flags = CAN_MASTURBATE_WITH|CAN_CLIMAX_WITH|GENITAL_CAN_AROUSE|GENITAL_UNDIES_HIDDEN
	fluid_transfer_factor = 0.1 //Yes, some amount is exposed to you, go get your AIDS
	shape = DEF_VAGINA_SHAPE
	removed_type = /obj/item/organ/genital/vagina

	var/cap_length = 8//D   E   P   T   H (cap = capacity)
	var/cap_girth = 12
	var/cap_girth_ratio = 1.5
	var/clits = 1
	var/clit_diam = 0.25
	var/clit_len = 0.25

/datum/internal_organ/genital/vagina/genital_examine(mob/user)
	return "<span class='notice'>You see a vagina. It is taut with smooth skin, though without much hair and [aroused_state ? "is slick with female arousal." : "seems to be dry."]</span>"
