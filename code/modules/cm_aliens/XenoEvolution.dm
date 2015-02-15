//Xenomorph Evolution Code - Colonial Marines - Apophis775 - Last Edit: 24JAN2015


//Larva Evolve
/mob/living/carbon/Xenomorph/Larva/verb/Evolve()
	set name = "Evolve"
	set desc = "Evolve into a cute wittle alium"
	set category = "Abilities"

	if(stat !=CONSCIOUS)
		src << "\red You need to be conscious to evolve."
		return

	if(handcuffed || legcuffed)
		src << "\red The restraints are too restricting to allow you to evolve"
		return

	if(amount_grown < max_grown)
		src << "\red You are not fully Grown"
		return

	var/newcaste = larva_evolution()

	switch(newcaste)
		if("Runner")
			new_xeno = new /mob/living/carbon/Xenomorph/Runner(loc)
		if("Sentinel")
			//	new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(loc)
		if("Drone")
			new_xeno = new /mob/living/carbon/Xenomorph/Drone(loc)
	if(mind)
		mind.transfer_to(new_xeno)
	del(src)
	return


//Drone Evolve to Queen
/mob/living/carbon/Xenomorph/Drone/verb/Evolve()
	set name = "Evolve (500)"
	set desc = "Evolve into a beautiful Alien Queen, requires 500 Plasma."
	set category = "Abilities"

	if(stat !=CONSCIOUS)
		src << "\red You need to be conscious to evolve."
		return

	if(handcuffed || legcuffed)
		src << "\red The restraints are too restricting to allow you to evolve."
		return


	if(storedplasma == 500)
		var/no_queen = 1
		for(var/mob/living/carbon/Xenomorph/Queen/Q in living_mob_list)
			if(!Q.key && Q.stat != DEAD)
				continue
			no_queen = 0
		if(no_queen)
			src << "\red There is already a queen."
			return
		new_xeno = new /mob/living/carbon/Xenomorph/Queen(loc)


	if(mind)
		mind.transfer_to(new_xeno)
	del(src)
	return
