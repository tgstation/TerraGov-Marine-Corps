//Xenomorph Evolution Code - Apophis775 - Last Edit: 11JUN16

//Recoded and consolidated by Abby -- ALL evolutions come from here now. It should work with any caste, anywhere
// refactored by spookydonut because the above two were shitcoders and i'm sure in time my code too will be considered shit.
//All castes need an evolves_to() list in their defines
//Such as evolves_to = list("Warrior", "Sentinel", "Runner", "Badass") etc
// except use typepaths now so you dont have to have an entry for literally every evolve path

#define TO_XENO_TIER_2_FORMULA(tierA, tierB, tierC) ( (tierB + tierC) > tierA ) )
#define TO_XENO_TIER_3_FORMULA(tierA, tierB, tierC) ( (tierC * 3) > (tierA + tierB) )

/mob/living/carbon/Xenomorph/verb/Evolve()
	set name = "Evolve"
	set desc = "Evolve into a higher form."
	set category = "Alien"

	if(is_ventcrawling)
		to_chat(src, "<span class='warning'>This place is too constraining to evolve.</span>")
		return

	if(!isturf(loc))
		to_chat(src, "<span class='warning'>You can't evolve here.</span>")
		return

	if(xeno_caste.hardcore)
		to_chat(src, "<span class='warning'>Nuh-uh.</span>")
		return

	if(jobban_isbanned(src, "Alien"))
		to_chat(src, "<span class='warning'>You are jobbanned from aliens and cannot evolve. How did you even become an alien?</span>")
		return

	if(incapacitated(TRUE))
		to_chat(src, "<span class='warning'>You can't evolve in your current state.</span>")
		return

	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>The restraints are too restricting to allow you to evolve.</span>")
		return

	if(isxenolarva(src)) //Special case for dealing with larvae
		if(amount_grown < max_grown)
			to_chat(src, "<span class='warning'>You are not yet fully grown. Currently at: [amount_grown] / [max_grown].</span>")
			return

	if(isnull(xeno_caste.evolves_to))
		to_chat(src, "<span class='warning'>You are already the apex of form and function. Go forth and spread the hive!</span>")
		return

	if(health < maxHealth)
		to_chat(src, "<span class='warning'>You must be at full health to evolve.</span>")
		return

	if(plasma_stored < xeno_caste.plasma_max)
		to_chat(src, "<span class='warning'>You must be at full plasma to evolve.</span>")
		return

	if (agility || fortify || crest_defense)
		to_chat(src, "<span class='warning'>You cannot evolve while in this stance.</span>")
		return

	var/list/castes_to_pick = list()
	for(var/type in xeno_caste.evolves_to)
		var/datum/xeno_caste/Z = GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE]
		castes_to_pick += Z.caste_name
	var/castepick = input("You are growing into a beautiful alien! It is time to choose a caste.") as null|anything in castes_to_pick
	if(!castepick) //Changed my mind
		return

	var/new_caste_type
	for(var/type in xeno_caste.evolves_to)
		if(castepick == GLOB.xeno_caste_datums[type][XENO_UPGRADE_BASETYPE].caste_name)
			new_caste_type = type

	if(!new_caste_type)
		to_chat(src, "EVO8: Something went wrong with evolving")
		return

	if(!isturf(loc)) //cdel'd or inside something
		return

	if(incapacitated(TRUE))
		to_chat(src, "<span class='warning'>You can't evolve in your current state.</span>")
		return

	if(handcuffed || legcuffed)
		to_chat(src, "<span class='warning'>The restraints are too restricting to allow you to evolve.</span>")
		return

	// used below
	var/tierones
	var/tiertwos
	var/tierthrees

	if(new_caste_type == /mob/living/carbon/Xenomorph/Queen) //Special case for dealing with queenae
		if(jobban_isbanned(src, "Queen"))
			to_chat(src, "<span class='warning'>You are jobbanned from the Queen role.</span>")
			return
		if(xeno_caste.hardcore)
			to_chat(src, "<span class='warning'>Nuh-uhh.</span>")
			return
		if(plasma_stored < 500)
			to_chat(src, "<span class='warning'>You require more plasma! Currently at: [plasma_stored] / 500.</span>")
			return

		if(hive.living_xeno_queen)
			to_chat(src, "<span class='warning'>There already is a living Queen.</span>")
			return

		if(hivenumber == XENO_HIVE_NORMAL && SSticker?.mode && hive.xeno_queen_timer)
			to_chat(src, "<span class='warning'>You must wait about [round(hive.xeno_queen_timer / 60)] minutes for the hive to recover from the previous Queen's death.<span>")
			return

		switch(hivenumber) // because it causes issues otherwise
			if(XENO_HIVE_CORRUPTED)
				new_caste_type = /mob/living/carbon/Xenomorph/Queen/Corrupted
			if(XENO_HIVE_ALPHA)
				new_caste_type = /mob/living/carbon/Xenomorph/Queen/Alpha
			if(XENO_HIVE_BETA)
				new_caste_type = /mob/living/carbon/Xenomorph/Queen/Beta
			if(XENO_HIVE_ZETA)
				new_caste_type = /mob/living/carbon/Xenomorph/Queen/Zeta

	else
		var/potential_queens = length(hive.xenos_by_typepath[/mob/living/carbon/Xenomorph/Larva]) + length(hive.xenos_by_typepath[/mob/living/carbon/Xenomorph/Drone])

		tierones = length(hive.xenos_by_tier[XENO_TIER_ONE])
		tiertwos = length(hive.xenos_by_tier[XENO_TIER_TWO])
		tierthrees = length(hive.xenos_by_tier[XENO_TIER_THREE])

		if((tier == XENO_TIER_ONE && TO_XENO_TIER_2_FORMULA(tierones, tiertwos, tierthrees))
			to_chat(src, "<span class='warning'>The hive cannot support another Tier 2, wait for either more aliens to be born or someone to die.</span>")
			return
		else if(tier == XENO_TIER_TWO && TO_XENO_TIER_3_FORMULA(tierones, tiertwos, tierthrees))
			to_chat(src, "<span class='warning'>The hive cannot support another Tier 3, wait for either more aliens to be born or someone to die.</span>")
			return
		else if(!hive.living_xeno_queen && potential_queens == 1 && isxenolarva(src) && new_caste_type != /mob/living/carbon/Xenomorph/Drone)
			to_chat(src, "<span class='xenonotice'>The hive currently has no sister able to become Queen! The survival of the hive requires you to be a Drone!</span>")
			return
		else if(xeno_caste.evolution_threshold && evolution_stored < xeno_caste.evolution_threshold)
			to_chat(src, "<span class='warning'>You must wait before evolving. Currently at: [evolution_stored] / [xeno_caste.evolution_threshold].</span>")
			return
		else if((!hive.living_xeno_queen) && !isxenolarva(src))
			to_chat(src, "<span class='warning'>The Hive is shaken by the death of the last Queen. You can't find the strength to evolve.</span>")
			return
		else
			to_chat(src, "<span class='xenonotice'>It looks like the hive can support your evolution to <span style='font-weight: bold'>[castepick]!</span></span>")

	if(isnull(new_caste_type))
		to_chat(usr, "<span class='warning'>[castepick] is not a valid caste! If you're seeing this message, tell a coder!</span>")
		return

	visible_message("<span class='xenonotice'>\The [src] begins to twist and contort.</span>", \
	"<span class='xenonotice'>You begin to twist and contort.</span>")
	do_jitter_animation(1000)

	if(!do_after(src, 25, FALSE, 5, BUSY_ICON_HOSTILE))
		to_chat(src, "<span class='warning'>You quiver, but nothing happens. Hold still while evolving.</span>")
		return

	tierones = length(hive.xenos_by_tier[XENO_TIER_ONE])
	tiertwos = length(hive.xenos_by_tier[XENO_TIER_TWO])
	tierthrees = length(hive.xenos_by_tier[XENO_TIER_THREE])

	if((tier == XENO_TIER_ONE && TO_XENO_TIER_2_FORMULA(tierones, tiertwos, tierthrees))
		to_chat(src, "<span class='warning'>Another sister evolved meanwhile. The hive cannot support another Tier 2.</span>")
		return
	else if(tier == XENO_TIER_TWO && TO_XENO_TIER_3_FORMULA(tierones, tiertwos, tierthrees))
		to_chat(src, "<span class='warning'>Another sister evolved meanwhile. The hive cannot support another Tier 3.</span>")
		return

	if(!isturf(loc)) //cdel'd or moved into something
		return
	if(new_caste_type == /mob/living/carbon/Xenomorph/Queen && hive.living_xeno_queen) //Do another check after the tick.
		to_chat(src, "<span class='warning'>There already is a Queen.</span>")
		return

	//From there, the new xeno exists, hopefully
	var/mob/living/carbon/Xenomorph/new_xeno = new new_caste_type(get_turf(src))

	if(!istype(new_xeno))
		//Something went horribly wrong!
		to_chat(usr, "<span class='warning'>Something went terribly wrong here. Your new xeno is null! Tell a coder immediately!</span>")
		if(new_xeno)
			qdel(new_xeno)
		return

	if(mind)
		mind.transfer_to(new_xeno)
	else
		new_xeno.key = src.key
		if(new_xeno.client) new_xeno.client.change_view(world.view)

	//Pass on the unique nicknumber, then regenerate the new mob's name now that our player is inside
	new_xeno.nicknumber = nicknumber
	new_xeno.hivenumber = hivenumber
	new_xeno.transfer_to_hive(hivenumber)
	generate_name()

	if(new_xeno.health - getBruteLoss(src) - getFireLoss(src) > 0) //Cmon, don't kill the new one! Shouldnt be possible though
		new_xeno.bruteloss = src.bruteloss //Transfers the damage over.
		new_xeno.fireloss = src.fireloss //Transfers the damage over.
		new_xeno.updatehealth()

	if(xeno_mobhud)
		var/datum/mob_hud/H = huds[MOB_HUD_XENO_STATUS]
		H.add_hud_to(new_xeno) //keep our mobhud choice
		new_xeno.xeno_mobhud = TRUE

	new_xeno.middle_mouse_toggle = middle_mouse_toggle //Keep our toggle state

	update_spits() //Update spits to new/better ones

	for(var/obj/item/W in contents) //Drop stuff
		dropItemToGround(W)

	empty_gut()
	new_xeno.visible_message("<span class='xenodanger'>A [new_xeno.xeno_caste.caste_name] emerges from the husk of \the [src].</span>", \
	"<span class='xenodanger'>You emerge in a greater form from the husk of your old body. For the hive!</span>")

	round_statistics.total_xenos_created-- //so an evolved xeno doesn't count as two.

	if(queen_chosen_lead && new_caste_type != /mob/living/carbon/Xenomorph/Queen) // xeno leader is removed by Destroy()
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