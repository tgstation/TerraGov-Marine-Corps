/datum/species/monkey
	name = "Monkey"
	icobase = 'icons/mob/human_races/r_monkey.dmi'
	species_flags = HAS_NO_HAIR|NO_STAMINA|DETACHABLE_HEAD
	inherent_traits = list(TRAIT_CAN_VENTCRAWL)
	reagent_tag = IS_MONKEY
	eyes = "blank_eyes"
	unarmed_type = /datum/unarmed_attack/bite/strong
	secondary_unarmed_type = /datum/unarmed_attack/punch/strong
	joinable_roundstart = FALSE
	death_message = "lets out a faint chimper as it collapses and stops moving..."
	dusted_anim = "dust-m"
	gibbed_anim = "monkey"

/datum/species/monkey/handle_unique_behavior(mob/living/carbon/human/H)
	if(!H.client && H.stat == CONSCIOUS)
		if(prob(33) && H.canmove && !H.buckled && isturf(H.loc) && !H.pulledby) //won't move if being pulled
			step(H, pick(GLOB.cardinals))

		if(prob(1))
			H.emote(pick("scratch","jump","roll","tail"))

/datum/species/monkey/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.allow_pass_flags |= PASS_LOW_STRUCTURE //todo: this is probably meant to be pass_flags, not allow past?

/datum/species/monkey/spec_unarmedattack(mob/living/carbon/human/user, atom/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/victim = target
	if(prob(25))
		victim.visible_message(span_danger("[user]'s bite misses [victim]!"),
			span_danger("You avoid [user]'s bite!"), span_hear("You hear jaws snapping shut!"))
		to_chat(user, span_danger("Your bite misses [victim]!"))
		return TRUE
	victim.apply_damage(rand(10, 20), BRUTE, "chest", updating_health = TRUE)
	victim.visible_message(span_danger("[name] bites [victim]!"),
		span_userdanger("[name] bites you!"), span_hear("You hear a chomp!"))
	to_chat(user, span_danger("You bite [victim]!"))
	target.attack_hand(user)
	return TRUE

/datum/species/monkey/random_name(gender,unique,lastname)
	return "[lowertext(name)] ([rand(1,999)])"

/datum/species/monkey/farwa
	name = "Farwa"
	icobase = 'icons/mob/human_races/r_farwa.dmi'

/datum/species/monkey/naera
	name = "Naera"
	icobase = 'icons/mob/human_races/r_naera.dmi'

/datum/species/monkey/stok
	name = "Stok"
	icobase = 'icons/mob/human_races/r_stok.dmi'

/datum/species/monkey/yiren
	name = "Yiren"
	icobase = 'icons/mob/human_races/r_yiren.dmi'
	cold_level_1 = ICE_COLONY_TEMPERATURE - 20
	cold_level_2 = ICE_COLONY_TEMPERATURE - 40
	cold_level_3 = ICE_COLONY_TEMPERATURE - 80
