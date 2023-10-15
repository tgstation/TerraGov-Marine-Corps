/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	resistance_flags = RESIST_ALL
	var/in_use = FALSE

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/dummy)

/mob/living/carbon/human/dummy/Initialize(mapload)
	SHOULD_CALL_PARENT(FALSE)// just dummies, shouldnt register
	if(flags_atom & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_atom |= INITIALIZED
	set_species()
	return INITIALIZE_HINT_NORMAL // This stops dummies being setup and registered in the human_mob_list

/mob/living/carbon/human/dummy/Destroy()
	in_use = FALSE
	return ..()

/mob/living/carbon/human/dummy/Life()
	SSmobs.stop_processing(src)


/mob/living/carbon/human/dummy/proc/wipe_state()
	delete_equipment()
	cut_overlays(TRUE)

//Inefficient pooling/caching way.
GLOBAL_LIST_EMPTY(human_dummy_list)
GLOBAL_LIST_EMPTY(dummy_mob_list)

/proc/generate_or_wait_for_human_dummy(slotkey)
	if(!slotkey)
		return new /mob/living/carbon/human/dummy
	var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotkey]
	if(istype(D))
		UNTIL(!D.in_use)
	if(QDELETED(D))
		D = new
		GLOB.human_dummy_list[slotkey] = D
		GLOB.dummy_mob_list += D
	D.in_use = TRUE
	return D

/proc/generate_dummy_lookalike(slotkey, mob/target)
	if(!istype(target))
		return generate_or_wait_for_human_dummy(slotkey)

	var/mob/living/carbon/human/dummy/copycat = generate_or_wait_for_human_dummy(slotkey)

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.transfer_identity(copycat)

		if(ishuman(target))
			var/mob/living/carbon/human/human_target = target
			human_target.copy_clothing_prefs(copycat)

	else
		//even if target isn't a carbon, if they have a client we can make the
		//dummy look like what their human would look like based on their prefs
		target?.client?.prefs?.copy_to(copycat)

	return copycat

/mob/living/carbon/human/dummy/set_species(new_species, default_colour)
	if(!new_species)
		new_species = "Human"
	if(species)
		if(species.name && species.name == new_species) //we're already that species.
			return
		// Clear out their species abilities.
		species.remove_inherent_abilities(src)
	var/datum/species/oldspecies = species
	species = GLOB.all_species[new_species]
	if(oldspecies)
		//additional things to change when we're no longer that species
		oldspecies.post_species_loss(src)
	species.create_organs(src)
	if(species.base_color && default_colour)
		//Apply colour.
		r_skin = hex2num(copytext(species.base_color,2,4))
		g_skin = hex2num(copytext(species.base_color,4,6))
		b_skin = hex2num(copytext(species.base_color,6,8))
	else
		r_skin = 0
		g_skin = 0
		b_skin = 0
	if(species.hair_color)
		r_hair = hex2num(copytext(species.hair_color, 2, 4))
		g_hair = hex2num(copytext(species.hair_color, 4, 6))
		b_hair = hex2num(copytext(species.hair_color, 6, 8))
	INVOKE_ASYNC(src, PROC_REF(regenerate_icons))
	INVOKE_ASYNC(src, PROC_REF(update_body))
	INVOKE_ASYNC(src, PROC_REF(restore_blood))
	return TRUE

/mob/living/carbon/human/dummy/hud_set_job()
	return

/proc/unset_busy_human_dummy(slotkey)
	if(!slotkey)
		return
	var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotkey]
	if(istype(D))
		D.wipe_state()
		D.in_use = FALSE

/proc/clear_human_dummy(slotkey)
	if(!slotkey)
		return

	var/mob/living/carbon/human/dummy/dummy = GLOB.human_dummy_list[slotkey]

	GLOB.human_dummy_list -= slotkey
	if(istype(dummy))
		GLOB.dummy_mob_list -= dummy
		qdel(dummy)
