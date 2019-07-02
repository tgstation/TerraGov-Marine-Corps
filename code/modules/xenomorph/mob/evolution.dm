//Xenomorph Evolution Code - Apophis775 - Last Edit: 11JUN16

//Recoded and consolidated by Abby -- ALL evolutions come from here now. It should work with any caste, anywhere
// refactored by spookydonut because the above two were shitcoders and i'm sure in time my code too will be considered shit.
//All castes need an evolves_to() list in their defines
//Such as evolves_to = list("Warrior", "Sentinel", "Runner", "Badass") etc
// except use typepaths now so you dont have to have an entry for literally every evolve path

#define TO_XENO_TIER_2_FORMULA(tierA, tierB, tierC) ( (tierB + tierC) > tierA ) )
#define TO_XENO_TIER_3_FORMULA(tierA, tierB, tierC) ( (tierC * 3) > (tierA + tierB) )

/mob/living/carbon/xenomorph/verb/Evolve()
	set name = "Evolve"
	set desc = "Evolve into a higher form."
	set category = "Alien"

	if(is_ventcrawling)
		to_chat(src, "<span class='warning'>This place is too constraining to evolve.</span>")
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>We can't evolve here.</span>")
		return

	if(xeno_caste.hardcore)
		to_chat(src, "<span class='warning'>Nuh-uh.</span>")
		return

	if(is_banned_from(ckey, ROLE_XENOMORPH))
		log_admin_private("[key_name(src)] has tried to evolve as a xenomorph while being banned from the role.")
		message_admins("[ADMIN_TPMONTY(src)] has tried to evolve as a xenomorph while being banned. They shouldn't be playing the role.")
		to_chat(src, "<span class='warning'>You are jobbanned from aliens and cannot evolve. How did you even become an alien?</span>")
		return

	if(incapacitated(TRUE))
		to_chat(src, "<span class='warning'>We can't evolve in our current state.</span>")
		return

	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>The restraints are too restricting to allow us to evolve.</span>")
		return

	if(isxenolarva(src)) //Special case for dealing with larvae
		if(amount_grown < max_grown)
			to_chat(src, "<span class='warning'>We are not yet fully grown. Currently at: [amount_grown] / [max_grown].</span>")
			return

	if(isnull(xeno_caste.evolves_to))
		to_chat(src, "<span class='warning'>We are already the apex of form and function. Let's go forth and spread the hive!</span>")
		return

	if(health < maxHealth)
		to_chat(src, "<span class='warning'>We must be at full health to evolve.</span>")
		return

	if(plasma_stored < xeno_caste.plasma_max)
		to_chat(src, "<span class='warning'>We must be at full plasma to evolve.</span>")
		return

	if (agility || fortify || crest_defense)
		to_chat(src, "<span class='warning'>We cannot evolve while in this stance.</span>")
		return

	var/list/castes_to_pick = list()
	for(var/type in xeno_caste.evolves_to)
		var/datum/xeno_caste/Z = GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE]
		castes_to_pick += Z.caste_name
	var/castepick = input("We are growing into a beautiful alien! It is time to choose a caste.") as null|anything in castes_to_pick
	if(!castepick) //Changed my mind
		return

	var/new_caste_type
	for(var/type in xeno_caste.evolves_to)
		var/datum/xeno_caste/XC = GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE]
		if(castepick == XC.caste_name)
			new_caste_type = type
			break

	if(!new_caste_type)
		CRASH("[src] tried to evolve but failed to find a new_caste_type")

	if(!isturf(loc)) //cdel'd or inside something
		return

	if(incapacitated(TRUE))
		to_chat(src, "<span class='warning'>We can't evolve in our current state.</span>")
		return

	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>The restraints are too restricting to allow us to evolve.</span>")
		return

	if(xeno_caste.hardcore)
		to_chat(src, "<span class='warning'>Nuh-uhh.</span>")
		return

	// used below
	var/tierones
	var/tiertwos
	var/tierthrees

	if(new_caste_type == /mob/living/carbon/xenomorph/queen) //Special case for dealing with queenae
		if(is_banned_from(ckey, ROLE_XENO_QUEEN))
			to_chat(src, "<span class='warning'>You are jobbanned from the Queen role.</span>")
			return
		
		if(hive.living_xeno_queen)
			to_chat(src, "<span class='warning'>There already is a living Queen.</span>")
			return

		if(hive.can_hive_have_a_queen())
			to_chat(src, "<span class='warning'>The hivemind is too weak to sustain a Queen. Gather more xenos. [hive.xenos_per_queen] are required.</span>")
			return FALSE

		if(hivenumber == XENO_HIVE_NORMAL && SSticker?.mode && hive.xeno_queen_timer)
			to_chat(src, "<span class='warning'>We must wait about [round(hive.xeno_queen_timer / 60)] minutes for the hive to recover from the previous Queen's death.<span>")
			return

		if(mind)
			mind.assigned_role = ROLE_XENO_QUEEN

		switch(hivenumber) // because it causes issues otherwise
			if(XENO_HIVE_CORRUPTED)
				new_caste_type = /mob/living/carbon/xenomorph/queen/Corrupted
			if(XENO_HIVE_ALPHA)
				new_caste_type = /mob/living/carbon/xenomorph/queen/Alpha
			if(XENO_HIVE_BETA)
				new_caste_type = /mob/living/carbon/xenomorph/queen/Beta
			if(XENO_HIVE_ZETA)
				new_caste_type = /mob/living/carbon/xenomorph/queen/Zeta
			if(XENO_HIVE_ADMEME)
				new_caste_type = /mob/living/carbon/xenomorph/queen/admeme

	else if(new_caste_type == /mob/living/carbon/xenomorph/shrike) //Special case for dealing with shrikes
		if(is_banned_from(ckey, ROLE_XENO_QUEEN))
			to_chat(src, "<span class='warning'>You are jobbanned from Queen-like roles.</span>")

		if(length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/shrike]))
			to_chat(src, "<span class='warning'>There already is a living Shrike. The hive cannot contain more than one psychic energy repository.</span>")
			return
		
		if(mind)
			mind.assigned_role = ROLE_XENO_QUEEN

	else
		var/potential_queens = length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/larva]) + length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/drone])

		tierones = length(hive.xenos_by_tier[XENO_TIER_ONE])
		tiertwos = length(hive.xenos_by_tier[XENO_TIER_TWO])
		tierthrees = length(hive.xenos_by_tier[XENO_TIER_THREE])

		if((tier == XENO_TIER_ONE && TO_XENO_TIER_2_FORMULA(tierones, tiertwos, tierthrees))
			to_chat(src, "<span class='warning'>The hive cannot support another Tier 2, wait for either more aliens to be born or someone to die.</span>")
			return
		else if(tier == XENO_TIER_TWO && TO_XENO_TIER_3_FORMULA(tierones, tiertwos, tierthrees))
			to_chat(src, "<span class='warning'>The hive cannot support another Tier 3, wait for either more aliens to be born or someone to die.</span>")
			return
		else if(!hive.living_xeno_ruler && potential_queens == 1)
			if(isxenolarva(src) && new_caste_type != /mob/living/carbon/xenomorph/drone)
				to_chat(src, "<span class='xenonotice'>The hive currently has no sister able to become a ruler! The survival of the hive requires from us to be a Drone!</span>")
				return
			else if(isxenodrone(src) && new_caste_type != /mob/living/carbon/xenomorph/shrike)
				to_chat(src, "<span class='xenonotice'>The hive currently has no sister able to become a ruler! The survival of the hive requires from us to be a Shrike!</span>")
		else if(xeno_caste.evolution_threshold && evolution_stored < xeno_caste.evolution_threshold)
			to_chat(src, "<span class='warning'>We must wait before evolving. Currently at: [evolution_stored] / [xeno_caste.evolution_threshold].</span>")
			return
		else
			to_chat(src, "<span class='xenonotice'>It looks like the hive can support our evolution to <span style='font-weight: bold'>[castepick]!</span></span>")

	if(isnull(new_caste_type))
		CRASH("[src] tried to evolve but their castepick was null")

	visible_message("<span class='xenonotice'>\The [src] begins to twist and contort.</span>", \
	"<span class='xenonotice'>We begin to twist and contort.</span>")
	do_jitter_animation(1000)

	if(!do_after(src, 25, FALSE, null, BUSY_ICON_CLOCK))
		to_chat(src, "<span class='warning'>We quiver, but nothing happens. We must hold still while evolving.</span>")
		return

	tierones = length(hive.xenos_by_tier[XENO_TIER_ONE])
	tiertwos = length(hive.xenos_by_tier[XENO_TIER_TWO])
	tierthrees = length(hive.xenos_by_tier[XENO_TIER_THREE])

	if(new_caste_type == /mob/living/carbon/xenomorph/queen)
		if(hive.living_xeno_queen) //Do another check after the tick.
			to_chat(src, "<span class='warning'>There already is a Queen.</span>")
			return
	else if(new_caste_type == /mob/living/carbon/xenomorph/shrike)
		if(length(hive.xenos_by_typepath[/mob/living/carbon/xenomorph/shrike]))
			to_chat(src, "<span class='warning'>There already is a Shrike.</span>")
			return
	else // these shouldnt be checked if trying to become a queen.
		if((tier == XENO_TIER_ONE && TO_XENO_TIER_2_FORMULA(tierones, tiertwos, tierthrees))
			to_chat(src, "<span class='warning'>Another sister evolved meanwhile. The hive cannot support another Tier 2.</span>")
			return
		else if(tier == XENO_TIER_TWO && TO_XENO_TIER_3_FORMULA(tierones, tiertwos, tierthrees))
			to_chat(src, "<span class='warning'>Another sister evolved meanwhile. The hive cannot support another Tier 3.</span>")
			return

	if(!isturf(loc)) //cdel'd or moved into something
		return


	//From there, the new xeno exists, hopefully
	var/mob/living/carbon/xenomorph/new_xeno = new new_caste_type(get_turf(src))

	if(!istype(new_xeno))
		//Something went horribly wrong!
		stack_trace("[src] tried to evolve but their new_xeno wasn't a xeno at all.")
		if(new_xeno)
			qdel(new_xeno)
		return

	for(var/obj/item/W in contents) //Drop stuff
		dropItemToGround(W)

	empty_gut(FALSE, TRUE)

	if(mind)
		mind.transfer_to(new_xeno)
	else
		new_xeno.key = key

	//Pass on the unique nicknumber, then regenerate the new mob's name now that our player is inside
	new_xeno.nicknumber = nicknumber
	new_xeno.hivenumber = hivenumber
	new_xeno.transfer_to_hive(hivenumber)
	new_xeno.generate_name()

	if(new_xeno.health - getBruteLoss(src) - getFireLoss(src) > 0) //Cmon, don't kill the new one! Shouldnt be possible though
		new_xeno.bruteloss = src.bruteloss //Transfers the damage over.
		new_xeno.fireloss = src.fireloss //Transfers the damage over.
		new_xeno.updatehealth()

	if(xeno_mobhud)
		var/datum/atom_hud/H = GLOB.huds[DATA_HUD_XENO_STATUS]
		H.add_hud_to(new_xeno) //keep our mobhud choice
		new_xeno.xeno_mobhud = TRUE

	new_xeno.middle_mouse_toggle = middle_mouse_toggle //Keep our toggle state

	update_spits() //Update spits to new/better ones

	new_xeno.visible_message("<span class='xenodanger'>A [new_xeno.xeno_caste.caste_name] emerges from the husk of \the [src].</span>", \
	"<span class='xenodanger'>We emerge in a greater form from the husk of our old body. For the hive!</span>")

	GLOB.round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.

	if(queen_chosen_lead && new_caste_type != /mob/living/carbon/xenomorph/queen) // xeno leader is removed by Destroy()
		new_xeno.queen_chosen_lead = TRUE
		hive.xeno_leader_list += new_xeno
		new_xeno.hud_set_queen_overwatch()
		if(hive.living_xeno_queen)
			new_xeno.handle_xeno_leader_pheromones(hive.living_xeno_queen)

	if(hive.living_xeno_queen && hive.living_xeno_queen.observed_xeno == src)
		hive.living_xeno_queen.set_queen_overwatch(new_xeno)
	qdel(src)
	spawn(0)
		new_xeno.do_jitter_animation(1000)

#undef TO_XENO_TIER_2_FORMULA
#undef TO_XENO_TIER_3_FORMULA