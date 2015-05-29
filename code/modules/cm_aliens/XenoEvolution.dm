//Xenomorph Evolution Code - Colonial Marines - Apophis775 - Last Edit: 24JAN2015

//Recoded and consolidated by Abby -- ALL evolutions come from here now. It should work with any caste, anywhere
//All castes need an evolves_to() list in their defines
//Such as evolves_to = list("Warrior", "Sentinel", "Runner", "Badass") etc

/mob/living/carbon/Xenomorph/verb/Evolve()
	set name = "Evolve"
	set desc = "Evolve into a higher form."
	set category = "Alien"

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

	if(caste == "Queen") // Special case for dealing with queenae
		if(!istype(src,/mob/living/carbon/Xenomorph/Drone)) //logic! - Remove this if you want any caste to be able to queen it up
			return
		if(storedplasma >= 500)
			var/no_queen = 1 //Assume queen is dead
			for(var/mob/living/carbon/Xenomorph/Queen/Q in living_mob_list)
				if(Q.stat != DEAD)
					break
				no_queen = 0
			if(!no_queen)
				src << "\red There is already a queen."
				return
		else
			src << "You require more plasma! Currently at: [storedplasma] / 500."
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
		if("Queen")
			M = /mob/living/carbon/Xenomorph/Queen
	if(isnull(M))
		usr << "[M] is not a valid caste! If you're seeing this message tell a coder!"
		return

	if(jellyMax && caste != "Queen") //Does the caste have a jelly timer? Then check it
		if(jellyGrow < jellyMax)
			src << "You must wait to let the royal jelly seep into your lymph. Currently at: [jellyGrow] / [jellyMax]."
			return

	for(var/mob/O in viewers(src, null))
		O.show_message(text("\green <B>[src] begins to twist and contort!</B>"), 1)

	remove_inherent_verbs()
	new_xeno = new M(get_turf(src))

	if(mind)
		mind.transfer_to(new_xeno)
	else
		new_xeno.key = src.key

	new_xeno.add_inherent_verbs()
	new_xeno.jellyGrow = 0

	for (var/obj/item/W in src.contents) //Drop stuff
		src.drop_from_inventory(W)

	src.drop_l_hand() //Drop dem huggies
	src.drop_r_hand()

	//bleergh. Evolving makes you throw up, just to avoid messy (heheh!) issues
	if(stomach_contents.len)
		for(var/mob/S in src)
			if(S in stomach_contents)
				stomach_contents.Remove(S)
				S.loc = loc
	del(src)
	return

