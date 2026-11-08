/datum/species/synthetic
	name = "Synthetic"
	default_language_holder = /datum/language_holder/synthetic
	unarmed_type = /datum/unarmed_attack/punch
	limb_type = SPECIES_LIMB_HUMAN

	total_health = 125 //more health than regular humans

	brute_mod = 0.7
	burn_mod = 0.8 // A slight amount of burn resistance. Changed from 0.7 due to their critical condition phase

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 500
	heat_level_2 = 1000
	heat_level_3 = 2000

	body_temperature = 350

	species_flags = NO_BREATHE|NO_BLOOD|NO_POISON|NO_PAIN|IS_SYNTHETIC|NO_CHEM_METABOLIZATION|NO_STAMINA|DETACHABLE_HEAD|HAS_LIPS|HAS_UNDERWEAR|HAS_SKIN_COLOR|ROBOTIC_LIMBS|GREYSCALE_BLOOD|SPECIES_NO_HUG

	blood_color = "#EEEEEE"

	has_organ = list()

	lighting_cutoff = LIGHTING_CUTOFF_HIGH

	screams = list(MALE = SFX_MALE_SCREAM, FEMALE = SFX_FEMALE_SCREAM)
	paincries = list(MALE = SFX_MALE_PAIN, FEMALE = SFX_FEMALE_PAIN)
	goredcries = list(MALE = SFX_MALE_GORED, FEMALE = SFX_FEMALE_GORED)
	warcries = list(MALE = SFX_MALE_WARCRY, FEMALE = SFX_FEMALE_WARCRY)
	special_death_message = "You have been shut down.<br><small>But it is not the end of you yet... if you still have your body, wait until somebody can resurrect you...</small>"

	/// Lowest percentage of max health dealt as damage when in crit
	var/crit_damage_percentage_low = 2 / 100
	/// Highest percentage of max health dealt as damage when in crit
	var/crit_damage_percentage_high = 6 / 100
	/// Threshold where critical overheating starts
	var/custom_crit_threshold = -30

/datum/species/synthetic/handle_unique_behavior(mob/living/carbon/human/human)
	if(human.health >= custom_crit_threshold || human.stat == DEAD)
		return
	human.apply_effect(3 SECONDS, EFFECT_STUTTER)
	var/ignore_mod = (1 + (-burn_mod + 1))
	var/damage_min = (total_health * crit_damage_percentage_low) * ignore_mod
	var/damage_max = (total_health * crit_damage_percentage_high) * ignore_mod
	human.adjustFireLossByPart(rand(damage_min, damage_max), /datum/limb/chest::name)
	if(prob(12))
		human.visible_message(
			span_danger("[human] shudders violently and shoots out sparks!"),
			span_warning("Critical damage sustained. Internal temperature regulation systems offline. Shutdown imminent. <b>Estimated integrity: [round(human.health)]%.</b>"),
		)
		do_sparks(4, TRUE, human)

/datum/species/synthetic/on_species_gain(mob/living/carbon/human/human, datum/species/old_species)
	. = ..()
	var/datum/atom_hud/AH = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED_SYNTH]
	AH.add_hud_to(human)
	human.health_threshold_crit = -100 // They overheat below custom_crit_threshold

/datum/species/synthetic/post_species_loss(mob/living/carbon/human/human)
	. = ..()
	var/datum/atom_hud/AH = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED_SYNTH]
	AH.remove_hud_from(human)
	human.health_threshold_crit = -50

/mob/living/carbon/human/species/synthetic/binarycheck(mob/human)
	return TRUE

/datum/species/synthetic/prefs_name(datum/preferences/prefs)
	. = prefs.synthetic_name
	if(!. || . == "Undefined") //In case they don't have a name set
		switch(prefs.gender)
			if(MALE)
				. = "David"
			if(FEMALE)
				. = "Anna"
			else
				. = "Jeri"
		to_chat(prefs.parent, span_warning("You forgot to set your synthetic name in your preferences. Please do so next time."))

/datum/species/synthetic/early
	name = "Early Synthetic"
	icobase = 'icons/mob/human_races/r_synthetic.dmi'
	limb_type = SPECIES_LIMB_GENERIC
	species_flags = parent_type::species_flags ^ (HAS_LIPS | HAS_SKIN_COLOR)
	hair_color = "#000000"

	slowdown = 1.15
	total_health = 200
	brute_mod = 0.6
	burn_mod = 0.6

	hair_color = "#000000"
