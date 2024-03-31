

//NOTE: Breathing happens once per FOUR TICKS, unless the last breath fails. In which case it happens once per ONE TICK! So oxyloss healing is done once per 4 ticks while oxyloss damage is applied once per tick!

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection()
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15% and the head has 30%
#define THERMAL_PROTECTION_HEAD			0.3
#define THERMAL_PROTECTION_CHEST		0.15
#define THERMAL_PROTECTION_GROIN		0.15
#define THERMAL_PROTECTION_LEG_LEFT		0.075
#define THERMAL_PROTECTION_LEG_RIGHT	0.075
#define THERMAL_PROTECTION_FOOT_LEFT	0.025
#define THERMAL_PROTECTION_FOOT_RIGHT	0.025
#define THERMAL_PROTECTION_ARM_LEFT		0.075
#define THERMAL_PROTECTION_ARM_RIGHT	0.075
#define THERMAL_PROTECTION_HAND_LEFT	0.025
#define THERMAL_PROTECTION_HAND_RIGHT	0.025

/mob/living/carbon/human
	var/leprosy = 2
	var/allmig_reward = 0

/mob/living/carbon/human/Life()
//	set invisibility = 0
	if (notransform)
		return

	. = ..()

	if (QDELETED(src))
		return 0

	if(. && (mode != AI_OFF))
		handle_ai()

	if(advsetup)
		Stun(100)

	if(mind)
		for(var/datum/antagonist/A in mind.antag_datums)
			A.on_life(src)

	if(!IS_IN_STASIS(src))
		if(.) //not dead
			for(var/datum/mutation/human/HM in dna.mutations) // Handle active genes
				HM.on_life()

		if(mode == AI_OFF)
			if(stat)
				if(health > 0)
					if(has_status_effect(/datum/status_effect/debuff/sleepytime))
						tiredness = 0
						remove_status_effect(/datum/status_effect/debuff/sleepytime)
						var/datum/game_mode/chaosmode/C = SSticker.mode
						if(istype(C))
							if(mind)
								if(!mind.antag_datums || !mind.antag_datums.len)
									allmig_reward++
									to_chat(src, "<span class='danger'>Nights Survived: \Roman[allmig_reward]</span>")
									if(C.allmig)
										if(allmig_reward > 3)
											adjust_triumphs(1)
					if(has_status_effect(/datum/status_effect/debuff/trainsleep))
						remove_status_effect(/datum/status_effect/debuff/trainsleep)
			if(leprosy == 1)
				adjustToxLoss(2)
			else if(leprosy == 2)
				if(client)
					if(check_blacklist(client.ckey))
						ADD_TRAIT(src, TRAIT_NOPAIN, TRAIT_GENERIC)
						leprosy = 1
						var/obj/item/bodypart/B = get_bodypart(BODY_ZONE_HEAD)
						if(B)
							B.sellprice = rand(16, 33)
					else
						leprosy = 3
			//heart attack stuff
			handle_heart()
			handle_liver()
			update_rogfat()
			update_rogstam()
			if(charflaw)
				charflaw.flaw_on_life(src)
			if(health <= 0)
				adjustOxyLoss(0.5)
			else
				if(!(NOBLOOD in dna.species.species_traits))
					if(blood_volume <= BLOOD_VOLUME_SURVIVE)
						adjustOxyLoss(0.5)
						if(blood_volume <= 20)
							adjustOxyLoss(5)
			if(!client && !HAS_TRAIT(src, TRAIT_NOSLEEP))
				if(mob_timers["slo"])
					if(world.time > mob_timers["slo"] + 90 SECONDS)
						Sleeping(100)
				else
					mob_timers["slo"] = world.time
			else
				if(mob_timers["slo"])
					mob_timers["slo"] = null

		//Stuff jammed in your limbs hurts
		handle_embedded_objects()

		if(dna?.species)
			dna.species.spec_life(src) // for mutantraces
	if(!typing)
		set_typing_indicator(FALSE)
	//Update our name based on whether our face is obscured/disfigured
	name = get_visible_name()

	if(stat != DEAD)
		return 1

/mob/living/carbon/human/DeadLife()
	set invisibility = 0

	if(notransform)
		return

	if(mind)
		for(var/datum/antagonist/A in mind.antag_datums)
			A.on_life(src)

	if(!IS_IN_STASIS(src))
		. = ..()
		handle_embedded_objects()

	name = get_visible_name()

/mob/living/carbon/human/proc/on_daypass()
	if(dna?.species)
		if(STUBBLE in dna.species.species_traits)
			if(gender == MALE)
				if(age != AGE_YOUNG)
					has_stubble = TRUE
					update_hair()

/mob/living/carbon/human/calculate_affecting_pressure(pressure)
	if (wear_armor && head && istype(wear_armor, /obj/item/clothing) && istype(head, /obj/item/clothing))
		var/obj/item/clothing/CS = wear_armor
		var/obj/item/clothing/CH = head
		if (CS.clothing_flags & CH.clothing_flags & STOPSPRESSUREDAMAGE)
			return ONE_ATMOSPHERE
	return pressure


/mob/living/carbon/human/handle_traits()
	if (getOrganLoss(ORGAN_SLOT_BRAIN) >= 60)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "brain_damage", /datum/mood_event/brain_damage)
	else
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "brain_damage")
	return ..()

/mob/living/carbon/human/handle_mutations_and_radiation()
	if(!dna || !dna.species.handle_mutations_and_radiation(src))
		..()

/mob/living/carbon/human/breathe()
	if(!dna.species.breathe(src))
		..()

/mob/living/carbon/human/check_breath(datum/gas_mixture/breath)

	var/L = getorganslot(ORGAN_SLOT_LUNGS)

	if(!L)
		if(health >= crit_threshold)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS + 1)
		else if(!HAS_TRAIT(src, TRAIT_NOCRITDAMAGE))
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		failed_last_breath = 1

		var/datum/species/S = dna.species

		if(S.breathid == "o2")
			throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		else if(S.breathid == "tox")
			throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else if(S.breathid == "co2")
			throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		else if(S.breathid == "n2")
			throw_alert("not_enough_nitro", /obj/screen/alert/not_enough_nitro)

		return FALSE
	else
		if(istype(L, /obj/item/organ/lungs))
			var/obj/item/organ/lungs/lun = L
			lun.check_breath(breath,src)

/mob/living/carbon/human/handle_environment(datum/gas_mixture/environment)
	dna.species.handle_environment(environment, src)

///FIRE CODE
/mob/living/carbon/human/handle_fire()
	. = ..()
	if(.) //if the mob isn't on fire anymore
		return

	if(dna)
		. = dna.species.handle_fire(src) //do special handling based on the mob's species. TRUE = they are immune to the effects of the fire.

	if(!last_fire_update)
		last_fire_update = fire_stacks
	if((fire_stacks > 10 && last_fire_update <= 10) || (fire_stacks <= 10 && last_fire_update > 10))
		last_fire_update = fire_stacks
		update_fire()


/mob/living/carbon/human/proc/get_thermal_protection()
	var/thermal_protection = 0 //Simple check to estimate how protected we are against multiple temperatures
	if(wear_armor)
		if(wear_armor.max_heat_protection_temperature >= FIRE_SUIT_MAX_TEMP_PROTECT)
			thermal_protection += (wear_armor.max_heat_protection_temperature*0.7)
	if(head)
		if(head.max_heat_protection_temperature >= FIRE_HELM_MAX_TEMP_PROTECT)
			thermal_protection += (head.max_heat_protection_temperature*THERMAL_PROTECTION_HEAD)
	thermal_protection = round(thermal_protection)
	return thermal_protection

/mob/living/carbon/human/IgniteMob()
	//If have no DNA or can be Ignited, call parent handling to light user
	//If firestacks are high enough
	if(!dna || dna.species.CanIgniteMob(src))
		if(!on_fire)
			if(fire_stacks > 10)
				Immobilize(30)
				emote("firescream", TRUE)
			else
				emote("pain", TRUE)
		return ..()
	. = FALSE //No ignition

/mob/living/carbon/human/ExtinguishMob()
	if(!dna || !dna.species.ExtinguishMob(src))
		last_fire_update = null
		..()

/mob/living/carbon/human/SoakMob(locations)
	. = ..()
	var/coverhead
//	var/coverfeet
	//add belt slots to this for rusting
	var/list/body_parts = list(head, wear_mask, wear_wrists, wear_shirt, wear_neck, cloak, wear_armor, wear_pants, backr, backl, gloves, shoes, belt, s_store, glasses, ears, wear_ring) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(zone2covered(BODY_ZONE_HEAD, C.body_parts_covered))
				coverhead = TRUE
//			if(zone2covered(BODY_ZONE_PRECISE_L_FOOT, C.body_parts_covered))
//				coverfeet = TRUE
	if(locations & HEAD)
		if(!coverhead)
			add_stress(/datum/stressevent/coldhead)
//	if(locations & FEET)
//		if(!coverfeet)
//			add_stress(/datum/stressevent/coldfeet)

//END FIRE CODE


//This proc returns a number made up of the flags for body parts which you are protected on. (such as HEAD, CHEST, GROIN, etc. See setup.dm for the full list)
/mob/living/carbon/human/proc/get_heat_protection_flags(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = 0
	//Handle normal clothing
	if(head)
		if(head.max_heat_protection_temperature && head.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= head.heat_protection
	if(wear_armor)
		if(wear_armor.max_heat_protection_temperature && wear_armor.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_armor.heat_protection
	if(wear_pants)
		if(wear_pants.max_heat_protection_temperature && wear_pants.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_pants.heat_protection
	if(shoes)
		if(shoes.max_heat_protection_temperature && shoes.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= shoes.heat_protection
	if(gloves)
		if(gloves.max_heat_protection_temperature && gloves.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= gloves.heat_protection
	if(wear_mask)
		if(wear_mask.max_heat_protection_temperature && wear_mask.max_heat_protection_temperature >= temperature)
			thermal_protection_flags |= wear_mask.heat_protection

	return thermal_protection_flags

/mob/living/carbon/human/proc/get_heat_protection(temperature) //Temperature is the temperature you're being exposed to.
	var/thermal_protection_flags = get_heat_protection_flags(temperature)

	var/thermal_protection = 0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & CHEST)
			thermal_protection += THERMAL_PROTECTION_CHEST
		if(thermal_protection_flags & GROIN)
			thermal_protection += THERMAL_PROTECTION_GROIN
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT


	return min(1,thermal_protection)

//See proc/get_heat_protection_flags(temperature) for the description of this proc.
/mob/living/carbon/human/proc/get_cold_protection_flags(temperature)
	var/thermal_protection_flags = 0
	//Handle normal clothing

	if(head)
		if(head.min_cold_protection_temperature && head.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= head.cold_protection
	if(wear_armor)
		if(wear_armor.min_cold_protection_temperature && wear_armor.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_armor.cold_protection
	if(wear_pants)
		if(wear_pants.min_cold_protection_temperature && wear_pants.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_pants.cold_protection
	if(shoes)
		if(shoes.min_cold_protection_temperature && shoes.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= shoes.cold_protection
	if(gloves)
		if(gloves.min_cold_protection_temperature && gloves.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= gloves.cold_protection
	if(wear_mask)
		if(wear_mask.min_cold_protection_temperature && wear_mask.min_cold_protection_temperature <= temperature)
			thermal_protection_flags |= wear_mask.cold_protection

	return thermal_protection_flags

/mob/living/carbon/human/proc/get_cold_protection(temperature)
	temperature = max(temperature, 2.7) //There is an occasional bug where the temperature is miscalculated in ares with a small amount of gas on them, so this is necessary to ensure that that bug does not affect this calculation. Space's temperature is 2.7K and most suits that are intended to protect against any cold, protect down to 2.0K.
	var/thermal_protection_flags = get_cold_protection_flags(temperature)

	var/thermal_protection = 0
	if(thermal_protection_flags)
		if(thermal_protection_flags & HEAD)
			thermal_protection += THERMAL_PROTECTION_HEAD
		if(thermal_protection_flags & CHEST)
			thermal_protection += THERMAL_PROTECTION_CHEST
		if(thermal_protection_flags & GROIN)
			thermal_protection += THERMAL_PROTECTION_GROIN
		if(thermal_protection_flags & LEG_LEFT)
			thermal_protection += THERMAL_PROTECTION_LEG_LEFT
		if(thermal_protection_flags & LEG_RIGHT)
			thermal_protection += THERMAL_PROTECTION_LEG_RIGHT
		if(thermal_protection_flags & FOOT_LEFT)
			thermal_protection += THERMAL_PROTECTION_FOOT_LEFT
		if(thermal_protection_flags & FOOT_RIGHT)
			thermal_protection += THERMAL_PROTECTION_FOOT_RIGHT
		if(thermal_protection_flags & ARM_LEFT)
			thermal_protection += THERMAL_PROTECTION_ARM_LEFT
		if(thermal_protection_flags & ARM_RIGHT)
			thermal_protection += THERMAL_PROTECTION_ARM_RIGHT
		if(thermal_protection_flags & HAND_LEFT)
			thermal_protection += THERMAL_PROTECTION_HAND_LEFT
		if(thermal_protection_flags & HAND_RIGHT)
			thermal_protection += THERMAL_PROTECTION_HAND_RIGHT

	return min(1,thermal_protection)

/mob/living/carbon/human/handle_random_events()
	..()
	//Puke if toxloss is too high
	if(!stat)
		if(prob(33))
			if(getToxLoss() >= 75 && blood_volume)
				mob_timers["puke"] = world.time
				vomit(1, blood = TRUE)

/mob/living/carbon/human/has_smoke_protection()
	if(wear_mask)
		if(wear_mask.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	if(glasses)
		if(glasses.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	if(head && istype(head, /obj/item/clothing))
		var/obj/item/clothing/CH = head
		if(CH.clothing_flags & BLOCK_GAS_SMOKE_EFFECT)
			return TRUE
	return ..()

/obj/item/proc/on_embed_life(mob/living/user)
	return

/mob/living/proc/handle_embedded_objects()
	for(var/obj/item/I in simple_embedded_objects)

		if(I.on_embed_life(src))
			return

		if(prob(I.embedding.embedded_pain_chance))
//			BP.receive_damage(I.w_class*I.embedding.embedded_pain_multiplier)
			to_chat(src, "<span class='danger'>[I] in me hurts!</span>")

		if(prob(I.embedding.embedded_fall_chance))
//			BP.receive_damage(I.w_class*I.embedding.embedded_fall_pain_multiplier)
			simple_embedded_objects -= I
			I.forceMove(drop_location())
			to_chat(src,"<span class='danger'>[I] falls out of me!</span>")
			if(!has_embedded_objects())
				clear_alert("embeddedobject")

/mob/living/carbon/human/handle_embedded_objects()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		for(var/obj/item/I in BP.embedded_objects)

			if(I.on_embed_life(BP))
				return

			if(prob(I.embedding.embedded_pain_chance))
				BP.receive_damage(I.w_class*I.embedding.embedded_pain_multiplier)
//				to_chat(src, "<span class='danger'>[I] in my [BP.name] hurts!</span>")

			if(prob(I.embedding.embedded_fall_chance))
				BP.receive_damage(I.w_class*I.embedding.embedded_fall_pain_multiplier)
				BP.embedded_objects -= I
				I.forceMove(drop_location())
				to_chat(src,"<span class='danger'>[I] falls out of my [BP.name]!</span>")
				if(!has_embedded_objects())
					clear_alert("embeddedobject")
					SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "embedded")

/mob/living/carbon/human/proc/handle_heart()
	var/we_breath = !HAS_TRAIT_FROM(src, TRAIT_NOBREATH, SPECIES_TRAIT)

	if(!undergoing_cardiac_arrest())
		return

	if(we_breath)
		adjustOxyLoss(8)
		Unconscious(80)
	// Tissues die without blood circulation
	adjustBruteLoss(2)

#undef THERMAL_PROTECTION_HEAD
#undef THERMAL_PROTECTION_CHEST
#undef THERMAL_PROTECTION_GROIN
#undef THERMAL_PROTECTION_LEG_LEFT
#undef THERMAL_PROTECTION_LEG_RIGHT
#undef THERMAL_PROTECTION_FOOT_LEFT
#undef THERMAL_PROTECTION_FOOT_RIGHT
#undef THERMAL_PROTECTION_ARM_LEFT
#undef THERMAL_PROTECTION_ARM_RIGHT
#undef THERMAL_PROTECTION_HAND_LEFT
#undef THERMAL_PROTECTION_HAND_RIGHT
