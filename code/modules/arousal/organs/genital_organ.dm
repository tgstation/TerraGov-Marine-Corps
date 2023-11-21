/obj/item/organ/genital
	name = "genital"
	desc = "Lewd."
	organ_type = /datum/internal_organ/genital

/obj/item/organ/genital/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(organ_data)
		var/datum/internal_organ/genital/G = organ_data
		to_chat(user, G.genital_examine(user))
