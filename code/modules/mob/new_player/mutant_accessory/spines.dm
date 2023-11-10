/datum/mutant_accessory/spines
	icon = 'icons/mob/mutant_accessory/spines.dmi'
	key = "spines"
	generic = "Spines"
	special_render_case = TRUE
	default_color = DEFAULT_SECONDARY
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_ADJ_LAYER)

/datum/mutant_accessory/spines/is_hidden(mob/living/carbon/human/H)
	/*
	var/obj/item/organ/tail/T = H.getorganslot(ORGAN_SLOT_TAIL)
	if(!T || (H.wear_suit && (H.try_hide_mutant_parts || H.wear_suit.flags_inv & HIDEJUMPSUIT)))
		return TRUE
	*/
	return FALSE

/datum/mutant_accessory/spines/get_special_render_state(mob/living/carbon/human/H)
	/*
	var/obj/item/organ/tail/T = H.getorganslot(ORGAN_SLOT_TAIL)
	if(T && T.wagging)
		return "[icon_state]_wagging"
	*/
	return icon_state


/datum/mutant_accessory/spines/none
	name = "None"
	icon_state = "none"
	color_src = null

/datum/mutant_accessory/spines/short
	name = "Short"
	icon_state = "short"

/datum/mutant_accessory/spines/shortmeme
	name = "Short + Membrane"
	icon_state = "shortmeme"

/datum/mutant_accessory/spines/long
	name = "Long"
	icon_state = "long"

/datum/mutant_accessory/spines/longmeme
	name = "Long + Membrane"
	icon_state = "longmeme"

/datum/mutant_accessory/spines/aqautic
	name = "Aquatic"
	icon_state = "aqua"
