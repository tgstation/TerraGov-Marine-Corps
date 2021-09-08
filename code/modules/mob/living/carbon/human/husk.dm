/datum/species/husk
	name = "Husk"
	name_plural = "Husks"
	icobase = 'icons/mob/human_races/r_husk.dmi'
	deform = 'icons/mob/human_races/r_husk.dmi'
	total_health = 200
	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_PAIN|NO_CHEM_METABOLIZATION|NO_STAMINA|DETACHABLE_HEAD|HAS_UNDERWEAR
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 8
	blood_color = "#110a0a"
	hair_color = "#000000"
	slowdown = 1.5
	screams = list(MALE = "male_scream", FEMALE = "female_scream") //TODO : port zombie sounds
	paincries = list(MALE = "male_pain", FEMALE = "female_pain")
	goredcries = list(MALE = "male_gored", FEMALE = "female_gored")
	warcries = list(MALE = "male_warcry", FEMALE = "female_warcry")

/datum/species/husk/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	H.health = total_health
	H.status_flags |= CANNOT_HOLD //Failsafe if something manage to skip the attack_hand check
	H.dropItemToGround(H.r_hand)
	H.dropItemToGround(H.l_hand)
	//remove larva
	var/obj/item/alien_embryo/alien_embryo = locate() in src
	if(alien_embryo)
		qdel(alien_embryo)
		return

/datum/species/husk/post_species_loss(mob/living/carbon/human/H)
	H.status_flags &= ~CANNOT_HOLD

/datum/species/husk/handle_unique_behavior(mob/living/carbon/human/H)
	for(var/datum/limb/limb AS in H.limbs) //Regrow some limbs
		if(limb.limb_status & LIMB_DESTROYED && !(limb.parent?.limb_status & LIMB_DESTROYED) && prob(10))
			limb.remove_limb_flags(LIMB_DESTROYED)
			H.update_body()

	if(H.health != total_health)
		H.heal_limbs(10)

	for(var/organ_slot in has_organ)
		var/datum/internal_organ/internal_organ = H.internal_organs_by_name[organ_slot]
		internal_organ?.heal_organ_damage(1)
	H.updatehealth()

/datum/species/husk/spec_unarmedattack(mob/living/carbon/human/user, atom/target)
	return TRUE

/datum/species/husk/handle_death(mob/living/carbon/human/H)
	if(!H.on_fire && H.has_working_organs())
		addtimer(CALLBACK(H, /mob/living/carbon/human.proc/revive_to_crit), 5 SECONDS)
