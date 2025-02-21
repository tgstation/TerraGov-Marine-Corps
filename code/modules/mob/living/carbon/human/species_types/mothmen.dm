/datum/species/moth
	name = "Moth"
	icobase = 'icons/mob/human_races/r_moth.dmi'
	default_language_holder = /datum/language_holder/moth
	eyes = "blank_eyes"
	count_human = TRUE
	species_flags = HAS_LIPS|HAS_NO_HAIR
	screams = list("neuter" = 'sound/voice/moth_scream.ogg')
	paincries = list("neuter" = 'sound/voice/human/male/pain_3.ogg')
	goredcries = list("neuter" = 'sound/voice/moth_scream.ogg')
	burstscreams = list("neuter" = 'sound/voice/moth_scream.ogg')
	warcries = list("neuter" = 'sound/voice/moth_scream.ogg')

	flesh_color = "#E5CD99"

	reagent_tag = IS_MOTH

	namepool = /datum/namepool/moth

/datum/species/moth/handle_fire(mob/living/carbon/human/H)
	if(H.moth_wings != "Burnt Off" && H.bodytemperature >= 400 && H.fire_stacks > 0)
		to_chat(H, span_danger("Your precious wings burn to a crisp!"))
		H.moth_wings = "Burnt Off"
		H.update_body()

/datum/species/moth/proc/update_moth_wings(mob/living/carbon/human/H)
	H.remove_overlay(MOTH_WINGS_LAYER)
	H.remove_underlay(MOTH_WINGS_BEHIND_LAYER)

	var/datum/sprite_accessory/moth_wings/wings = GLOB.moth_wings_list[H.moth_wings]

	if(wings)
		H.overlays_standing[MOTH_WINGS_LAYER] = image(wings.icon, icon_state = "m_moth_wings_[wings.icon_state]_FRONT")
		H.underlays_standing[MOTH_WINGS_BEHIND_LAYER] = image(wings.icon, icon_state = "m_moth_wings_[wings.icon_state]_BEHIND")
		H.apply_overlay(MOTH_WINGS_LAYER)
		H.apply_underlay(MOTH_WINGS_BEHIND_LAYER)

/datum/species/moth/update_body(mob/living/carbon/human/H)
	update_moth_wings(H)

/datum/species/moth/update_inv_head(mob/living/carbon/human/H)
	update_moth_wings(H)

/datum/species/moth/update_inv_w_uniform(mob/living/carbon/human/H)
	update_moth_wings(H)

/datum/species/moth/update_inv_wear_suit(mob/living/carbon/human/H)
	update_moth_wings(H)

/datum/species/moth/post_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.remove_overlay(MOTH_WINGS_LAYER)
	H.remove_underlay(MOTH_WINGS_BEHIND_LAYER)
