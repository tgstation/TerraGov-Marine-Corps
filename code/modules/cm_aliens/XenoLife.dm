//Xenomorph Life - Colonial Marines - Apophis775 - Last Edit: 03JAN2015

/mob/living/carbon/Xenomorph/Life()

	set invisibility = 0
	set background = 1

	if (monkeyizing)	return
	if(!loc)			return

	..()

	if (stat != DEAD) //still breathing
		// GROW!
		update_progression()

	//Stops larva from sneakily hitting the hotkey for intents, so they can grab
	if(isXenoLarva(src) && src.a_intent != "help")
		src.a_intent = "help"

	if(jelly && jellyGrow < jellyMax)
		jellyGrow++
		if(jellyGrow == jellyMax-1)
			src << "\green You feel the royal jelly swirl in your veins.."

	if(stat != DEAD) //If not dead, go ahead and update.
		updatehealth()

	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()
	update_icons()
	handle_statuses() //Deals with stunned, etc
	if(loc)
		handle_environment(loc.return_air())
	if(client)
		handle_regular_hud_updates()

/mob/living/carbon/Xenomorph/proc/handle_regular_status_updates()

	if(status_flags & GODMODE)	return 0

	if(stat == DEAD)
		blinded = 1
		silent = 0
		see_in_dark = 8
	else
		if(health <= -100 || (health < 0 && isXenoLarva(src))) //Just died!
			death()
			blinded = 1
			silent = 0
			if(readying_tail) readying_tail = 0
			return 1
		else if(health > -100 && health < 0) //Unconscious
			if(readying_tail) readying_tail = 0
			blinded = 1
			see_in_dark = 3
			Paralyse(4)
			var/turf/T = loc
			if(istype(T))
				if(!locate(/obj/effect/alien/weeds) in T) //In crit, only take damage when not on weeds.
					adjustBruteLoss(5)
		else						//Alive! Yey! Turn on their vision.
			see_in_dark = 8
			blinded = 0
			if(readying_tail && readying_tail < 20)
				readying_tail += rand(1,2)
				if(istype(src,/mob/living/carbon/Xenomorph/Hunter)) readying_tail++ //Warriors get a speed bonus.
				if(readying_tail >= 20)
					readying_tail = 20
					src << "\blue Your tail is now fully poised to impale some unfortunate target."

		if(health > 0) //Just to be safe
			blinded = 0

		ear_deaf = 0 //All this stuff is prob unnecessary
		ear_damage = 0
		eye_blind = 0
		eye_blurry = 0

		if(weakened)
			weakened--

		if(paralysis) //If they're down, make sure they are actually down.
			AdjustParalysis(-3)
			blinded = 1
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(sleeping)
			adjustHalLoss(-3)
			if (mind)
				if((mind.active && client != null) || immune_to_ssd)
					sleeping = max(sleeping-1, 0)
			blinded = 1
			stat = UNCONSCIOUS
		else if(resting)
			blinded = 0
			if(halloss > 0)
				adjustHalLoss(-3)
		else
			stat = CONSCIOUS
			blinded = 0
			if(halloss > 0)
				adjustHalLoss(-1)

		update_icons()

	return 1

/mob/living/carbon/Xenomorph/proc/handle_regular_hud_updates()

	if (healths)
		if (stat != 2)
			switch(round(health * 100 / maxHealth)) //Maxhealth should never be zero or this will generate runtimes.
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(76 to 99)
					healths.icon_state = "health1"
				if(51 to 75)
					healths.icon_state = "health2"
				if(26 to 50)
					healths.icon_state = "health3"
				if(0 to 25)
					healths.icon_state = "health4"
				else
					healths.icon_state = "health5"
		else
			healths.icon_state = "health6"

	if(alien_plasma_display)
		if (stat != 2)
			if(maxplasma) //No divide by zeros please
				switch(round(storedplasma * 100 / maxplasma))
					if(100 to INFINITY)
						alien_plasma_display.icon_state = "power_display2_9"
					if(71 to 99)
						alien_plasma_display.icon_state = "power_display2_8"
					if(61 to 70)
						alien_plasma_display.icon_state = "power_display2_7"
					if(51 to 60)
						alien_plasma_display.icon_state = "power_display2_6"
					if(41 to 50)
						alien_plasma_display.icon_state = "power_display2_5"
					if(31 to 40)
						alien_plasma_display.icon_state = "power_display2_4"
					if(21 to 30)
						alien_plasma_display.icon_state = "power_display2_3"
					if(11 to 20)
						alien_plasma_display.icon_state = "power_display2_2"
					if(1 to 10)
						alien_plasma_display.icon_state = "power_display2_1"
					else
						alien_plasma_display.icon_state = "power_display2_0"
			else
				alien_plasma_display.icon_state = "power_display2_0"
		else
			alien_plasma_display.icon_state = "power_display2_0"

	if(pullin)
		pullin.icon_state = "pull[pulling ? 1 : 0]"

	if (client)
		client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask, global_hud.nvg, global_hud.thermal, global_hud.meson)

	if ((blind && stat != 2))
		if ((blinded))
			blind.layer = 18
		else
			blind.layer = 0

	if(!stat && prob(25)) //Only a 25% chance of proccing the queen locator, since it is expensive and we don't want it firing every tick
		queen_locator()

	if (stat != 2 && prob(10)) //Is this really necessary? Xenos can't look thru cameras.
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return 1

/mob/living/carbon/Xenomorph/proc/handle_environment(var/datum/gas_mixture/environment)
	if(stat != DEAD)
		var/turf/T = src.loc
		if(environment && !fire_immune)
			if(environment.temperature > (T0C+66))
				adjustFireLoss((environment.temperature - (T0C+66))/5) // Might be too high, check in testing.
				if (fire) fire.icon_state = "fire2"
				if(prob(20))
					src << "\red You feel a searing heat!"
			else
				if (fire) fire.icon_state = "fire0"

		if(!T || !istype(T)) return

		if(!is_robotic)//Robot no heal
			if(locate(/obj/effect/alien/weeds) in T)
				if(health >= maxHealth)
					if(!readying_tail) //Readying tail = no plasma increase.
						storedplasma += plasma_gain
				else
					adjustBruteLoss(-(maxHealth / 40) - 2) //Heal 1/40th of your max health in brute per tick. -2 as a bonus, to help smaller pools.
					adjustFireLoss(-(maxHealth / 60)) //Heal from fire half as fast
					adjustOxyLoss(-(maxHealth / 10)) //Xenos don't actually take oxyloss, oh well
					adjustToxLoss(-(maxHealth / 5)) //hmmmm, this is probably unnecessary
					updatehealth() //Make sure their actual health updates immediately.
			else //Xenos restore plasma VERY slowly off weeds, regardless of health
				if(rand(0,1) == 0) storedplasma += 1

			if(readying_tail) storedplasma -= 3
		if(storedplasma > maxplasma) storedplasma = maxplasma
		if(storedplasma < 0)
			storedplasma = 0
			if(readying_tail)
				readying_tail =0
				src << "You feel your tail relax."
	return

/mob/living/carbon/Xenomorph/death(gibbed)
	if(!gibbed)
		icon_state = "[caste] Dead"
	playsound(loc, 'sound/voice/hiss6.ogg', 50, 1, 1)
	if(istype(src,/mob/living/carbon/Xenomorph/Queen))
		xeno_message("A great tremor runs through the hive as the Queen is slain. Vengeance!",3)
		xeno_message("The slashing of hosts is now permitted!",2)
		slashing_allowed = 1
	else
		var/area/A = get_area(src)
		if(A)
			xeno_message("Hive: A [src.name] has <b>died</b> at [sanitize(A.name)]!",3)
		else
			xeno_message("Hive: A [src.name] has <b>died!</b>",3)
	if(!is_robotic)
		return ..(gibbed,"lets out a waning guttural screech, green blood bubbling from its maw.")
	else
		return ..(gibbed,"begins to shudder, and the lights go out in its eyes as it lies still.")

/mob/living/carbon/Xenomorph/proc/queen_locator()
	var/mob/living/carbon/Xenomorph/Queen/target = null

	if(locate_queen)
		for(var/mob/living/carbon/Xenomorph/Queen/M in living_mob_list)
			if(M && !M.stat)
				target = M
				break

	if(!target || !istype(target) || is_intelligent)
		locate_queen.icon_state = "trackoff"
		return

	if(target.z != src.z || get_dist(src,target) < 1 || src == target)
		locate_queen.icon_state = "trackondirect"
	else
		locate_queen.dir = get_dir(src,target)
		locate_queen.icon_state = "trackon"

/mob/living/carbon/Xenomorph/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = maxHealth - getFireLoss() - getBruteLoss() //Xenos can only take brute and fire damage.

	if(health <= -100 && stat != DEAD) //We'll put a death check here for safety.
		death()
		blinded = 1
		silent = 0
		return