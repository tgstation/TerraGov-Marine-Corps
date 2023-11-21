#define BREASTS_ICON_MIN_SIZE 1
#define BREASTS_ICON_MAX_SIZE 6

/obj/item/organ/genital/breasts
	name = "breasts"
	desc = "Female milk producing organs."
	icon_state = "breasts"
	icon = 'modular_skyrat/icons/obj/genitals/breasts.dmi'


/datum/internal_organ/genital/breasts
	name = "breasts"
	masturbation_verb = "massage"
	arousal_verb = "Your breasts start feeling sensitive"
	unarousal_verb = "Your breasts no longer feel sensitive"
	orgasm_verb = "leaking"
	parent_limb = "chest"
	organ_id = ORGAN_BREASTS
	genital_flags = CAN_MASTURBATE_WITH|CAN_CLIMAX_WITH|GENITAL_CAN_AROUSE|GENITAL_FLUID_PRODUCTION|UPDATE_OWNER_APPEARANCE|GENITAL_UNDIES_HIDDEN
	fluid_transfer_factor = 0.5
	size = BREASTS_SIZE_DEF
	shape = DEF_BREASTS_SHAPE
	fluid_id = /datum/reagent/consumable/drink/milk
	removed_type = /obj/item/organ/genital/breasts

	var/static/list/breast_values = list("flat" = 0, "a" =  1, "b" = 2, "c" = 3, "d" = 4, "e" = 5, "f" = 6, "g" = 7, "h" = 8, "i" = 9, "j" = 10, "k" = 11, "l" = 12, "m" = 13, "n" = 14, "o" = 15, "huge" = 16)
	var/cached_size //these two vars pertain size modifications and so should be expressed in NUMBERS.
	var/prev_size //former cached_size value, to allow update_size() to early return should be there no significant changes.

/datum/internal_organ/genital/breasts/New(mob/living/carbon/M, do_update = TRUE)
	if(do_update)
		cached_size = breast_values[size]
		prev_size = cached_size
	return ..()

/datum/internal_organ/genital/breasts/genital_examine(mob/user)
	var/lowershape = lowertext(shape)
	var/txt = "<span class='notice'>"
	switch(lowershape)
		if("pair")
			txt += "You see a pair of breasts."
		if("quad")
			txt += "You see two pairs of breasts, one just under the other."
		if("sextuple")
			txt += "You see three sets of breasts, running from their chest down to their belly."
		else
			txt += "You see some breasts, they seem to be quite exotic."
	if(size == "huge")
		txt = "<span class='notice'>You see [pick("some serious honkers", "a real set of badonkers", "some dobonhonkeros", "massive dohoonkabhankoloos", "two big old tonhongerekoogers", "a couple of giant bonkhonagahoogs", "a pair of humongous hungolomghnonoloughongous")]. Their volume is way beyond cupsize now, measuring in about [round(cached_size)]cm in diameter."
	else
		if(size == "flat")
			txt += " They're very small and flatchested, however."
		else
			txt += " You estimate that they're [uppertext(size)]-cups."
	if((genital_flags & GENITAL_FLUID_PRODUCTION) && aroused_state)
		var/datum/reagent/R = GLOB.chemical_reagents_list[fluid_id]
		if(R)
			txt += " They're leaking [lowertext(R.name)]."
	txt += "</span>"
	return txt

//Allows breasts to grow and change size, with sprite changes too.
//maximum wah
//Comical sizes slow you down in movement and actions.
//Ridiculous sizes makes you more cumbersome.
//this is far too lewd wah

/datum/internal_organ/genital/breasts/modify_size(modifier, min = -INFINITY, max = INFINITY)
	var/new_value = clamp(cached_size + modifier, min, max)
	if(new_value == cached_size)
		return
	prev_size = cached_size
	cached_size = new_value
	update()
	..()

/datum/internal_organ/genital/breasts/update_size()//wah
	var/rounded_cached = round(cached_size)
	if(cached_size < 0)//I don't actually know what round() does to negative numbers, so to be safe!!fixed
		if(owner)
			to_chat(owner, "<span class='warning'>You feel your breasts shrinking away from your body as your chest flattens out.</span>")
		return
	//var/enlargement = FALSE
	switch(rounded_cached)
		if(0) //flatchested
			size = "flat"
		if(1 to 8) //modest
			size = breast_values[rounded_cached]
		if(9 to 15) //massive
			size = breast_values[rounded_cached]
			//enlargement = TRUE
		if(16 to INFINITY) //rediculous
			size = "huge"
			//enlargement = TRUE
	//if(owner)
	//	var/status_effect = owner.has_status_effect(STATUS_EFFECT_BREASTS_ENLARGEMENT)
	//	if(enlargement && !status_effect)
	//		owner.apply_status_effect(STATUS_EFFECT_BREASTS_ENLARGEMENT)
	//	else if(!enlargement && status_effect)
	//		owner.remove_status_effect(STATUS_EFFECT_BREASTS_ENLARGEMENT)

	if((rounded_cached < 16) && owner)//Because byond doesn't count from 0, I have to do this.
		var/r_prev_size = round(prev_size)
		if(rounded_cached > r_prev_size)
			to_chat(owner, "<span class='notice'>Your breasts [pick("swell up to", "flourish into", "expand into", "burst forth into", "grow eagerly into", "amplify into")] a [uppertext(size)]-cup.</span>")
		else if(rounded_cached < r_prev_size)
			to_chat(owner, "<span class='notice'>Your breasts [pick("shrink down to", "decrease into", "diminish into", "deflate into", "shrivel regretfully into", "contracts into")] a [uppertext(size)]-cup.</span>")


#undef BREASTS_ICON_MIN_SIZE
#undef BREASTS_ICON_MAX_SIZE
