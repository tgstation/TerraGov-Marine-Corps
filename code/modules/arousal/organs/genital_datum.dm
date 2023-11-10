/datum/internal_organ/genital
	name = "genital"
	parent_limb = "groin"
	var/shape
	var/sensitivity = 1 // wow if this were ever used that'd be cool but it's not but i'm keeping it for my unshit code
	var/genital_flags //see citadel_defines.dm
	var/masturbation_verb = "masturbate"
	var/orgasm_verb = "cumming" //present continous
	var/arousal_verb = "You feel aroused"
	var/unarousal_verb = "You no longer feel aroused"
	var/fluid_transfer_factor = 0 //How much would a partner get in them if they climax using this?
	var/size = 2 //can vary between num or text, just used in icon_state strings
	var/datum/reagent/fluid_id = null
	var/fluid_max_volume = 50
	var/fluid_efficiency = 1
	var/fluid_rate = CUM_RATE
	var/fluid_mult = 1
	var/time_since_last_orgasm = 500
	var/aroused_state = FALSE //Boolean used in icon_state strings
	var/datum/internal_organ/genital/linked_organ
	var/linked_organ_slot //used for linking an apparatus' organ to its other half on update_link().
	var/layer_index = GENITAL_LAYER_INDEX //Order should be very important. FIRST vagina, THEN testicles, THEN penis, as this affects the order they are rendered in.
	var/datum/reagents/produced_reagents

/datum/internal_organ/genital/New(mob/living/carbon/M, do_update = TRUE)
	..()
	if(fluid_id)
		START_PROCESSING(SSobj, src)
		produced_reagents = new(fluid_max_volume)
		if(genital_flags & GENITAL_FLUID_PRODUCTION)
			produced_reagents.add_reagent(fluid_id, fluid_max_volume)
	if(do_update)
		update()

/datum/internal_organ/genital/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(produced_reagents)
	return ..()

/datum/internal_organ/genital/proc/set_aroused_state(new_state)
	if(!(genital_flags & GENITAL_CAN_AROUSE))
		return FALSE
	if(!((HAS_TRAIT(owner, TRAIT_PERMABONER) && new_state == FALSE) || HAS_TRAIT(owner, TRAIT_NEVERBONER) && new_state == TRUE))
		aroused_state = new_state
	return aroused_state

/datum/internal_organ/genital/proc/update()
	if(QDELETED(src))
		return
	update_size()
	update_appearance()
	if((genital_flags & UPDATE_OWNER_APPEARANCE) && owner && ishuman(owner))
		owner.update_genitals()
	if(linked_organ_slot || (linked_organ && !owner))
		update_link()

/datum/internal_organ/genital/proc/climaxable(mob/living/carbon/human/H, silent = FALSE) //returns the fluid source (ergo reagents holder) if found.aroused_state
	if(genital_flags & GENITAL_FLUID_PRODUCTION)
		. = produced_reagents
	else
		if(linked_organ)
			. = linked_organ.produced_reagents
	if(!. && !silent)
		to_chat(H, "<span class='warning'>Your [name] is unable to produce it's own fluids, it's missing the organs for it.</span>")

/datum/internal_organ/genital/proc/genital_examine(mob/user)
	return

/datum/internal_organ/genital/proc/is_exposed()
	if(!owner || genital_flags & (GENITAL_INTERNAL|GENITAL_HIDDEN))
		return FALSE
	if(genital_flags & GENITAL_THROUGH_CLOTHES)
		return TRUE

	switch(parent_limb) //update as more genitals are added
		if(BODY_ZONE_CHEST)
			return owner.is_chest_exposed()
		if(BODY_ZONE_PRECISE_GROIN)
			return owner.is_groin_exposed()

/datum/internal_organ/genital/proc/toggle_visibility(visibility, update = TRUE)
	genital_flags &= ~(GENITAL_THROUGH_CLOTHES|GENITAL_HIDDEN|GENITAL_UNDIES_HIDDEN)
	if(owner)
		owner.exposed_genitals -= src
	switch(visibility)
		if(GEN_VISIBLE_ALWAYS)
			genital_flags |= GENITAL_THROUGH_CLOTHES
			if(owner)
				owner.exposed_genitals += src
		if(GEN_VISIBLE_NO_UNDIES)
			genital_flags |= GENITAL_UNDIES_HIDDEN
		if(GEN_VISIBLE_NEVER)
			genital_flags |= GENITAL_HIDDEN

	if(update && owner)
		owner.update_genitals()

/mob/living/carbon
	var/list/exposed_genitals = list() //Keeping track of them so we don't have to iterate through every genitalia and see if exposed

/mob/living/carbon/verb/toggle_genitals()
	set category = "IC"
	set name = "Expose/Hide genitals"
	set desc = "Allows you to toggle which genitals should show through clothes or not."

	if(stat != CONSCIOUS)
		to_chat(usr, "<span class='warning'>You can't toggle genitals visibility right now...</span>")
		return

	var/list/genital_list = list()
	for(var/datum/internal_organ/genital/G in internal_organs)
		if(!(G.genital_flags & GENITAL_INTERNAL))
			genital_list += G
	if(!length(genital_list)) //There is nothing to expose
		return
	//Full list of exposable genitals created
	var/datum/internal_organ/genital/picked_organ
	picked_organ = input(src, "Choose which genitalia to expose/hide", "Expose/Hide genitals") as null|anything in genital_list
	if(picked_organ && (picked_organ in internal_organs))
		var/picked_visibility = input(src, "Choose visibility setting", "Expose/Hide genitals") as null|anything in GLOB.genitals_visibility_toggles
		if(picked_visibility && picked_organ && (picked_organ in internal_organs))
			picked_organ.toggle_visibility(picked_visibility)

/mob/living/carbon/verb/toggle_arousal_state()
	set category = "IC"
	set name = "Toggle genital arousal"
	set desc = "Allows you to toggle which genitals are showing signs of arousal."
	var/list/genital_list = list()
	for(var/datum/internal_organ/genital/G in internal_organs)
		if(G.genital_flags & GENITAL_CAN_AROUSE)
			genital_list += G
	if(!length(genital_list)) //There's nothing that can show arousal
		return
	var/datum/internal_organ/genital/picked_organ
	picked_organ = input(src, "Choose which genitalia to toggle arousal on", "Set genital arousal", null) in genital_list
	if(picked_organ)
		var/original_state = picked_organ.aroused_state
		picked_organ.set_aroused_state(!picked_organ.aroused_state)
		if(original_state != picked_organ.aroused_state)
			to_chat(src,"<span class='userlove'>[picked_organ.aroused_state ? picked_organ.arousal_verb : picked_organ.unarousal_verb].</span>")
		else
			to_chat(src,"<span class='userlove'>You can't make that genital [picked_organ.aroused_state ? "unaroused" : "aroused"]!</span>")
		picked_organ.update_appearance()


/datum/internal_organ/genital/proc/modify_size(modifier, min = -INFINITY, max = INFINITY)
	fluid_max_volume += modifier * 2.5
	fluid_rate += modifier / 10
	if(produced_reagents)
		produced_reagents.maximum_volume = fluid_max_volume

/datum/internal_organ/genital/proc/update_size()
	return

/datum/internal_organ/genital/proc/update_appearance()
	if(!owner || owner.stat == DEAD)
		aroused_state = FALSE

/datum/internal_organ/genital/process()
	if(!produced_reagents)
		return
	produced_reagents.maximum_volume = fluid_max_volume
	if(fluid_id && (genital_flags & GENITAL_FLUID_PRODUCTION))
		time_since_last_orgasm++

/datum/internal_organ/genital/proc/generate_fluid(datum/reagents/R)
	var/amount
	R.clear_reagents()
	//skyrat edit - fix coom
	if(fluid_id)
		amount = clamp(fluid_rate * time_since_last_orgasm * fluid_mult, 0, fluid_max_volume)
		R.add_reagent(fluid_id, amount)
	else if(linked_organ && linked_organ.fluid_id)
		amount = clamp(linked_organ.fluid_rate * time_since_last_orgasm * linked_organ.fluid_mult, 0, linked_organ.fluid_max_volume)
		R.add_reagent(linked_organ.fluid_id, amount)
	//
	return TRUE

/datum/internal_organ/genital/proc/update_link()
	if(owner)
		if(linked_organ)
			return FALSE
		linked_organ = owner.internal_organs_by_name[linked_organ_slot]
		if(linked_organ)
			linked_organ.linked_organ = src
			linked_organ.update_link()
			upon_link()
			return TRUE
	if(linked_organ)
		linked_organ.linked_organ = null
		linked_organ = null
	return FALSE

//post organ duo making arrangements.
/datum/internal_organ/genital/proc/upon_link()
	return

/datum/internal_organ/genital/proc/get_features(mob/living/carbon/human/H)
	return

/datum/internal_organ/genital/remove(mob/user)
	. = ..()
	update()
	if(!QDELETED(owner))
		if(genital_flags & UPDATE_OWNER_APPEARANCE)
			owner.update_genitals()
		owner.exposed_genitals -= src


//proc to give a player their genitals and stuff when they log in
/mob/living/carbon/human/proc/give_genitals(clean = FALSE)//clean will remove all pre-existing genitals. proc will then give them any genitals that are enabled in their DNA
	if(clean)
		for(var/datum/internal_organ/genital/G in internal_organs)
			internal_organs -= G
			internal_organs_by_name -= G.name
			qdel(G)

	if(gender == MALE)
		give_genital(/datum/internal_organ/genital/penis)
		give_genital(/datum/internal_organ/genital/testicles)
	else
		give_genital(/datum/internal_organ/genital/breasts)
		give_genital(/datum/internal_organ/genital/womb)
		give_genital(/datum/internal_organ/genital/vagina)

/mob/living/carbon/human/proc/give_genital(datum/internal_organ/genital/G)
	if(internal_organs_by_name[initial(G.name)])
		return FALSE
	G = new G(src)
	G.get_features(src)
	return G

/mob/living/carbon/human/proc/update_genitals()
	return // NYI
