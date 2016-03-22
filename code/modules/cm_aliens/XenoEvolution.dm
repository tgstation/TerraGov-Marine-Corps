//Xenomorph Evolution Code - Colonial Marines - Apophis775 - Last Edit: 24JAN2015

//Recoded and consolidated by Abby -- ALL evolutions come from here now. It should work with any caste, anywhere
//All castes need an evolves_to() list in their defines
//Such as evolves_to = list("Warrior", "Sentinel", "Runner", "Badass") etc

/mob/living/carbon/Xenomorph/verb/Evolve()
	set name = "Evolve"
	set desc = "Evolve into a higher form."
	set category = "Alien"

	if(jobban_isbanned(src,"Alien"))
		src << "\red You are jobbanned from Aliens and cannot evolve. How did you even become an alien?"
		return

	if(stat)
		src << "You have to be conscious to evolve."
		return

	if(handcuffed || legcuffed)
		src << "\red The restraints are too restricting to allow you to evolve."
		return

	if(istype(src,/mob/living/carbon/Xenomorph/Larva)) //Special case for dealing with larvae
		if(amount_grown < max_grown)
			src << "\red You are not yet fully grown. You are currently at [amount_grown]/[max_grown]."
			return

	if(isnull(evolves_to))
		src << "You are already the apex of form and function. Go! Spread the hive!"
		return

	//Recoded the caste selection to add cancel buttons, makes it look nicer, uses a list() in castes for easy additions
	var/list/pop_list = list()
	for(var/Q in evolves_to) //Populate our evolution list
		pop_list += Q
	pop_list += "Cancel"

	//I'd really like to turn all this into an href popup window but dang I am really bad at html
	//--Abby

	var/caste = input("You are growing into a beautiful alien! It is time to choose a caste.") as null|anything in pop_list
	if(caste == "Cancel" || isnull(caste) || caste == "") //Changed my mind
		return

	if(stat)
		src << "You have to be conscious to evolve."
		return

	if(handcuffed || legcuffed)
		src << "\red The restraints are too restricting to allow you to evolve."
		return

	if(caste == "Queen") // Special case for dealing with queenae
		if(storedplasma >= 500)
			if(is_queen_alive())
				src << "\red There is already a queen."
				return
		else
			src << "You require more plasma! Currently at: [storedplasma] / 500."
			return

		if(ticker && ticker.mode && ticker.mode.queen_death_timer)
			src << "You must wait about [round(ticker.mode.queen_death_timer / 60)] minutes for the hive to recover from the previous Queen's death."
			return

	var/mob/living/carbon/Xenomorph/M = null

	//Better to use a get_caste_by_text proc but ehhhhhhhh. Lazy.
	switch(caste) //ADD NEW CASTES HERE!
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
		usr << "[caste] is not a valid caste! If you're seeing this message tell a coder!"
		return

	if(jellyMax && caste != "Queen") //Does the caste have a jelly timer? Then check it
		if(jellyGrow < jellyMax)
			src << "You must wait to let the royal jelly seep into your lymph. Currently at: [jellyGrow] / [jellyMax]."
			return

	visible_message("\green <b> \The [src] begins to twist and contort..</b>","\green <b>You begin to twist and contort..</b>")
	if(do_after(src,25))
		if(caste == "Queen") // Do another check after the tick.
			if(is_queen_alive())
				src << "\red There is already a queen."
				return
		var/mob/living/carbon/Xenomorph/new_xeno = new M(get_turf(src))
		if(!istype(new_xeno))
			//Something went horribly wrong!
			usr << "Something went terribly wrong here. Your new xeno is null! Tell a coder immediately!"
			if(new_xeno)
				del(new_xeno)
			return

		//We have to reset the name here after evolving.
		if(caste != "Queen")
			new_xeno.nicknumber = nicknumber
			new_xeno.name = "[initial(name)] ([nicknumber])"
		new_xeno.real_name = new_xeno.name

		remove_inherent_verbs()

		if(mind)
			mind.transfer_to(new_xeno)
		else
			new_xeno.key = src.key

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

		for (var/obj/item/W in src.contents) //Drop stuff
			src.drop_from_inventory(W)

		src.drop_l_hand() //Drop dem huggies, just in case
		src.drop_r_hand()

		empty_gut()
		new_xeno.visible_message("\green <b> \The [new_xeno] emerges from the husk of [src].</b>","\green <b>You emerge in a greater form from the husk of your old body. For the hive!</b>")
		del(src)
	else
		src << "You quiver, but nothing happens. Hold still while evolving."

	return

/proc/is_queen_alive()
	var/found = 0

	for(var/mob/living/carbon/Xenomorph/Queen/Q in mob_list)
		if(!isnull(Q) && Q.stat != DEAD)
			found = 1
			break

	return found