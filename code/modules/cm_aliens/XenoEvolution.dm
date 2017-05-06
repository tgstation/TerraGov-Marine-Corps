//Xenomorph Evolution Code - Colonial Marines - Apophis775 - Last Edit: 11JUN16

//Recoded and consolidated by Abby -- ALL evolutions come from here now. It should work with any caste, anywhere
//All castes need an evolves_to() list in their defines
//Such as evolves_to = list("Warrior", "Sentinel", "Runner", "Badass") etc

/mob/living/carbon/Xenomorph/verb/Evolve()
	set name = "Evolve"
	set desc = "Evolve into a higher form."
	set category = "Alien"
	var totalXenos = 0.0 //total number of Xenos
	// var tierA = 0.0 //Tier 1 - Not used in calculation of Tier maximums
	var tierB = 0.0 //Tier 2
	var tierC = 0.0 //Tier 3

	if(is_ventcrawling)
		src << "<span class='warning'>This place is too constraining to evolve.</span>"
		return

	var/area/A = get_area(loc)
	if(istype(A, /area/sulaco/hub))
		src << "<span class='warning'>This seems like a bad idea, you might get stuck in here.</span>"
		return

	if(hardcore)
		src << "<span class='warning'>Nuh-uh.</span>"
		return

	if(jobban_isbanned(src, "Alien"))
		src << "<span class='warning'>You are jobbanned from aliens and cannot evolve. How did you even become an alien?</span>"
		return

	if(stat != CONSCIOUS)
		src << "<span class='warning'>You have to be conscious to evolve.</span>"
		return

	if(handcuffed || legcuffed)
		src << "<span class='warning'>The restraints are too restricting to allow you to evolve.</span>"
		return

	if(isXenoLarva(src)) //Special case for dealing with larvae
		if(amount_grown < max_grown)
			src << "<span class='warning'>You are not yet fully grown. Currently at: [amount_grown] / [max_grown].</span>"
			return

	if(isnull(evolves_to))
		src << "<span class='warning'>You are already the apex of form and function. Go! Spread the hive!</span>"
		return

	if(upgrade > 0 && caste != "Drone")
		src << "<span class='warning'>You gave up evolving in exchange for more power.</span>"
		return

	if(health < maxHealth)
		src << "<span class='warning'>You must be at full health to evolve.</span>"
		return

	if(storedplasma < maxplasma)
		src << "<span class='warning'>You must be at full plasma to evolve.</span>"
		return

	//This will build a list of ALL the current Xenos and their Tiers, then use that to calculate if they can evolve or not.
	//Should count mindless as well so people don't cheat
	for(var/mob/living/carbon/Xenomorph/M in living_mob_list)
		if(M.tier == 0)
			continue
		else if(M.tier == 1)
		// 	tierA++
		else if(M.tier == 2)
			tierB++
		else if(M.tier == 3)
			tierC++
		else
			src <<"<span class='warning'>You shouldn't see this. If you do, bug repot it! (Error XE01).</span>"
			continue
		totalXenos++

	//Debugging that should've been done
	// world << "[tierA] Tier 1"
	// world << "[tierB] Tier 2"
	// world << "[tierC] Tier 3"
	// world << "[totalXenos] Total"

	//Recoded the caste selection to add cancel buttons, makes it look nicer, uses a list() in castes for easy additions
	var/list/pop_list = list()
	for(var/Q in evolves_to) //Populate our evolution list
		if(caste == "Drone" && upgrade > 0)
			pop_list += "Queen"
		else
			pop_list += Q
	pop_list += "Cancel"

	//I'd really like to turn all this into an href popup window but dang I am really bad at html
	//--Abby

	var/castepick = input("You are growing into a beautiful alien! It is time to choose a caste.") as null|anything in pop_list
	if(castepick == "Cancel" || isnull(castepick) || castepick == "") //Changed my mind
		return

	if(stat != CONSCIOUS)
		src << "<span class='warning'>You have to be conscious to evolve.</span>"
		return

	if(handcuffed || legcuffed)
		src << "<span class='warning'>The restraints are too restricting to allow you to evolve.</span>"
		return

	if(castepick == "Queen") //Special case for dealing with queenae
		if(!hardcore)
			if(storedplasma >= 500)
				if(is_queen_alive())
					src << "<span class='warning'>There is already a queen.</span>"
					return
			else
				src << "<span class='warning'>You require more plasma! Currently at: [storedplasma] / 500.</span>"
				return

			if(ticker && ticker.mode && ticker.mode.xeno_queen_timer)
				src << "<span class='warning'>You must wait about [round(ticker.mode.xeno_queen_timer / 60)] minutes for the hive to recover from the previous Queen's death.<span>"
				return
		else
			src << "<span class='warning'>Nuh-uhh.</span>"
			return




	if(tier == 1 && ((tierB + tierC) / totalXenos)> 0.5 && castepick != "Queen")
		src << "<span class='warning'>The hive cannot support another Tier 2, either upgrade or wait for either more aliens to be born or someone to die.</span>"
		return
	else if(tier == 2 && (tierC / totalXenos)> 0.25 && castepick != "Queen")
		src << "<span class='warning'>The hive cannot support another Tier 3, either upgrade or wait for either more aliens to be born or someone to die.</span>"
		return
	else
		src << "<span class='xenonotice'>It looks like the hive can support your evolution!</span>"

	var/mob/living/carbon/Xenomorph/M = null

	//Better to use a get_caste_by_text proc but ehhhhhhhh. Lazy.
	switch(castepick) //ADD NEW CASTES HERE!
		if("Larva" || "Bloody Larva" || "Normal Larva") //Not actually possible, but put here for insanity's sake
			M = /mob/living/carbon/Xenomorph/Larva
		if("Runner")
			M = /mob/living/carbon/Xenomorph/Runner
		if("Drone")
			M = /mob/living/carbon/Xenomorph/Drone
		if("Carrier")
			M = /mob/living/carbon/Xenomorph/Carrier
		if("Hivelord")
			M = /mob/living/carbon/Xenomorph/Hivelord
		if("Praetorian")
			M = /mob/living/carbon/Xenomorph/Praetorian
		if("Ravager")
			M = /mob/living/carbon/Xenomorph/Ravager
		if("Sentinel")
			M = /mob/living/carbon/Xenomorph/Sentinel
		if("Spitter")
			M = /mob/living/carbon/Xenomorph/Spitter
		if("Hunter")
			M = /mob/living/carbon/Xenomorph/Hunter
		if("Queen")
			M = /mob/living/carbon/Xenomorph/Queen
		if("Crusher")
			M = /mob/living/carbon/Xenomorph/Crusher
		if("Boiler")
			M = /mob/living/carbon/Xenomorph/Boiler

	if(isnull(M))
		usr << "<span class='warning'>[castepick] is not a valid caste! If you're seeing this message, tell a coder!</span>"
		return

	if(jellyMax && castepick != "Queen") //Does the caste have a jelly timer? Then check it
		if(jellyGrow < jellyMax)
			src << "<span class='warning'>You must wait before evolving. Currently at: [jellyGrow] / [jellyMax].</span>"
			return

	visible_message("<span class='xenonotice'>\The [src] begins to twist and contort.</span>", \
	"<span class='xenonotice'>You begin to twist and contort.</span>")
	if(do_after(src, 25, FALSE))
		if(castepick == "Queen") //Do another check after the tick.
			if(is_queen_alive())
				src << "<span class='warning'>There already is a Queen.</span>"
				return

		//From there, the new xeno exists, hopefully
		var/mob/living/carbon/Xenomorph/new_xeno = new M(get_turf(src))

		if(!istype(new_xeno))
			//Something went horribly wrong!
			usr << "<span class='warning'>Something went terribly wrong here. Your new xeno is null! Tell a coder immediately!</span>"
			if(new_xeno)
				del(new_xeno)
			return

		if(mind)
			mind.transfer_to(new_xeno)
		else
			new_xeno.key = src.key

		//Pass on the unique nicknumber, then regenerate the new mob's name now that our player is inside
		new_xeno.nicknumber = nicknumber
		generate_name()

		//Clear verbs
		remove_inherent_verbs()


		if(new_xeno.health - getBruteLoss(src) - getFireLoss(src) > 0) //Cmon, don't kill the new one! Shouldnt be possible though
			new_xeno.bruteloss = src.bruteloss //Transfers the damage over.
			new_xeno.fireloss = src.fireloss //Transfers the damage over.
			new_xeno.updatehealth()

		new_xeno.add_inherent_verbs()
		new_xeno.jellyGrow = 0
		if(jelly)
			new_xeno.jelly = jelly
		new_xeno.middle_mouse_toggle = src.middle_mouse_toggle //Keep our toggle state
		new_xeno.shift_mouse_toggle = src.shift_mouse_toggle //Keep our toggle state

		for(var/obj/item/W in contents) //Drop stuff
			drop_inv_item_on_ground(W)

		empty_gut()
		new_xeno.visible_message("<span class='xenodanger'>A [new_xeno.caste] emerges from the husk of \the [src].</span>", \
		"<span class='xenodanger'>You emerge in a greater form from the husk of your old body. For the hive!</span>")
		del(src)
	else
		src << "<span class='warning'>You quiver, but nothing happens. Hold still while evolving.</span>"

/proc/is_queen_alive()
	var/found = 0

	for(var/mob/living/carbon/Xenomorph/Queen/Q in living_mob_list)
		if(!isnull(Q) && Q.stat != DEAD)
			found = 1
			break

	return found
