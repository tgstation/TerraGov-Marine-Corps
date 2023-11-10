/obj/item/organ/genital/penis
	name = "penis"
	desc = "A male reproductive organ."
	icon_state = "penis"
	icon = 'modular_skyrat/icons/obj/genitals/penis.dmi'
	organ_type = /datum/internal_organ/genital/penis


/datum/internal_organ/genital/penis
	name = "penis"
	masturbation_verb = "stroke"
	arousal_verb = "You pop a boner"
	unarousal_verb = "Your boner goes down"
	organ_id = ORGAN_PENIS
	linked_organ_slot = "testicles"
	genital_flags = CAN_MASTURBATE_WITH|CAN_CLIMAX_WITH|GENITAL_CAN_AROUSE|UPDATE_OWNER_APPEARANCE|GENITAL_UNDIES_HIDDEN|GENITAL_CAN_TAUR
	fluid_transfer_factor = 0.5
	shape = DEF_COCK_SHAPE
	size = 2 //arbitrary value derived from length and diameter for sprites.
	removed_type = /obj/item/organ/genital/penis

	var/length = 6 //inches
	var/prev_length = 6
	var/diameter = 4.38
	var/diameter_ratio = COCK_DIAMETER_RATIO_DEF //0.25; check citadel_defines.dm

/datum/internal_organ/genital/penis/genital_examine(mob/user)
	var/lowershape = lowertext(shape)
	var/round_L = round(length)
	var/round_D = round(diameter)
	return "<span class='notice'>You see [aroused_state ? "an erect" : "a flaccid"] [lowershape] [name]. You estimate it's about [round_L] inch[round_L != 1 ? "es" : ""] long and [round_D] inch[round_D != 1 ? "es" : ""] in diameter.</span>"

/datum/internal_organ/genital/penis/modify_size(modifier, min, max)
	var/new_value = clamp(length + modifier, min, max)
	if(new_value == length)
		return
	prev_length = length
	length = new_value
	update()
	return ..()

/datum/internal_organ/genital/penis/update_size()
	if(length <= 0) //I don't actually know what round() does to negative numbers, so to be safe!!
		if(owner)
			to_chat(owner, "<span class='warning'>You feel your [pick(GLOB.dick_nouns)] shrinking away from your body as your groin flattens out!</span>")
		QDEL_NULL(linked_organ)
		qdel(src)
		return

	var/rounded_length = round(length)
	var/rounded_prev_length = round(prev_length)
	var/new_size
	//var/enlargement = FALSE
	switch(rounded_length)
		if(0 to 6) //If modest size
			new_size = 1
		if(7 to 11) //If large
			new_size = 2
		if(12 to 20) //If massive
			new_size = 3
		if(21 to 34) //If massive and due for large effects
			new_size = 3
			//enlargement = TRUE
		if(35 to INFINITY) //If comical
			new_size = 4 //no new sprites for anything larger yet
			//enlargement = TRUE
	//if(owner)
	//	var/status_effect = owner.has_status_effect(STATUS_EFFECT_PENIS_ENLARGEMENT)
	//	if(enlargement && !status_effect)
	//		owner.apply_status_effect(STATUS_EFFECT_PENIS_ENLARGEMENT)
	//	else if(!enlargement && status_effect)
	//		owner.remove_status_effect(STATUS_EFFECT_PENIS_ENLARGEMENT)
	if(linked_organ)
		linked_organ.size = clamp(size + new_size, BALLS_SIZE_MIN, BALLS_SIZE_MAX)
		linked_organ.update()
	size = new_size

	if(owner)
		if(rounded_length > rounded_prev_length)
			to_chat(owner, "<span class='notice'>Your [pick(GLOB.dick_nouns)] [pick("swells up to", "flourishes into", "expands into", "bursts forth into", "grows eagerly into", "amplifys into")] a [round(length, 0.1)] inch penis.</b></span>")
		else if((rounded_length < rounded_prev_length) && length > 0.5)
			to_chat(owner, "<span class='notice'>Your [pick(GLOB.dick_nouns)] [pick("shrinks down to", "decreases into", "diminishes into", "deflates into", "shrivels regretfully into", "contracts into")] a [round(length, 0.1)] inch penis.</b></span>")

	diameter = length * diameter_ratio //Is it just me or is this ludicous, why not make it exponentially decay?
