/mob/living/carbon/human/blind_eyes(amount, forced = FALSE)
	if(isspeciessynthetic(src))
		return
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			set_blindness(0, TRUE)
	return ..()

/mob/living/carbon/human/adjust_blindness(amount, forced = FALSE)
	if(isspeciessynthetic(src))
		return
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			set_blindness(0, TRUE)
	return ..()

/mob/living/carbon/human/set_blindness(amount, forced = FALSE)
	if(isspeciessynthetic(src))
		return
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			return
	return ..()

/mob/living/carbon/human/blur_eyes(amount, forced = FALSE)
	if(isspeciessynthetic(src))
		return
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			set_blurriness(0, TRUE)
	return ..()

/mob/living/carbon/human/adjust_blurriness(amount, forced = FALSE)
	if(isspeciessynthetic(src))
		return
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			set_blurriness(0, TRUE)
	return ..()

/mob/living/carbon/human/set_blurriness(amount, forced = FALSE)
	if(isspeciessynthetic(src))
		return
	if(!forced)
		if(has_vision() && !has_eyes() && stat == CONSCIOUS)
			return
	return ..()

/mob/living/carbon/human/Losebreath(amount, forced = FALSE)
	if(!(species.species_flags & NO_BREATHE) || forced)
		return ..()

/mob/living/carbon/human/adjust_Losebreath(amount, forced = FALSE)
	if(!(species.species_flags & NO_BREATHE) || forced)
		return ..()

/mob/living/carbon/human/set_Losebreath(amount, forced = FALSE)
	if(!(species.species_flags & NO_BREATHE) || forced)
		return ..()

/mob/living/carbon/human/vomit()
	if(isspeciessynthetic(src))
		return //Machines don't throw up.
	return ..()


/mob/living/carbon/human/adjust_ear_damage(damage = 0, deaf = 0)
	if(HAS_TRAIT(src, TRAIT_EARDAMAGE_IMMUNE))
		return
	if(isspeciessynthetic(src))
		return
	return ..()


/mob/living/carbon/human/set_ear_damage(damage = 0, deaf = 0)
	if(isspeciessynthetic(src))
		return
	return ..()

/mob/living/carbon/human/proc/rip_out_heart(mob/living/user, var/pickup_heart = TRUE)
	to_chat(user, span_notice("You start to remove [src]'s heart, preventing [p_them()] from rising again!"))
	if(!do_after(user, 2 SECONDS, NONE, src))
		return
	if(!get_organ_slot(ORGAN_SLOT_HEART))
		to_chat(user, span_notice("The heart is no longer here!"))
		return
	log_combat(user, src, "ripped [src]'s heart")
	visible_message(span_notice("[user] ripped off [src]'s heart!"), span_notice("You ripped off [src]'s heart!"))
	remove_organ_slot(ORGAN_SLOT_HEART)
	var/obj/item/organ/heart/heart = new
	heart.die()
	if(pickup_heart)
		user.put_in_hands(heart)
	if(iszombie(src))
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(fade_out), heart), 9.5 SECONDS)
		QDEL_IN(heart, 10 SECONDS)
	chestburst = CARBON_CHEST_BURSTED
	update_burst()
