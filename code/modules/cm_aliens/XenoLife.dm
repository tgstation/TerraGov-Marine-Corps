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
		if(jellyGrow > jellyMax)
			src << "\green You feel the royal jelly swirl in your veins.."
			jellyGrow = jellyMax

	if(loc)
		handle_environment(loc.return_air())

	//Status updates, death etc.
	handle_regular_status_updates()
	update_canmove()
	update_icons()
	handle_statuses() //Deals with stunned, etc


	if(client)
		handle_regular_hud_updates()




/mob/living/carbon/Xenomorph/proc/handle_regular_status_updates()

	if(status_flags & GODMODE)	return 0

	if(stat == DEAD)
		blinded = 1
		silent = 0
	else
		updatehealth()

		if(health <= -100)
			death()
			blinded = 1
			silent = 0
			return 1
		else if(health > -100 && health < 0)
			Paralyse(4)
			health -= rand(0,4)

		ear_deaf = 0
		ear_damage = 0
		eye_blind = 0
		eye_blurry = 0

		if(weakened)
			weakened--

		if(paralysis)
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

	//This should give full x-ray vision for the time being. Fuckin sight code god damn it
	sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
	see_in_dark = 8
	blind = 0

	if (healths)
		if (stat != 2)
			switch(health * 100 / maxHealth)
				if(100 to INFINITY)
					healths.icon_state = "health0"
				if(80 to 100)
					healths.icon_state = "health1"
				if(60 to 80)
					healths.icon_state = "health2"
				if(40 to 60)
					healths.icon_state = "health3"
				if(20 to 40)
					healths.icon_state = "health4"
				if(0 to 20)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

	if(alien_plasma_display)
		if (stat != 2)
			if(maxplasma) //No divide by zeros please
				switch(storedplasma * 100 / maxplasma)
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
						alien_plasma_display.icon_state = "power_display2"
			else
				alien_plasma_display.icon_state = "power_display2"
		else
			alien_plasma_display.icon_state = "power_display2"

	if(pullin)
		pullin.icon_state = "pull[pulling ? 1 : 0]"

	if (client)
		client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask, global_hud.nvg, global_hud.thermal, global_hud.meson)

//	if ((blind && stat != 2))
//		if ((blinded))
//			blind.layer = 18
//		else
//			blind.layer = 0
//			if (disabilities & NEARSIGHTED)
//				client.screen += global_hud.vimpaired
//			if (eye_blurry)
//				client.screen += global_hud.blurry
//			if (druggy)
//				client.screen += global_hud.druggy

	if(!stat && rand(20)) //Only a 20% chance of proccing the queen locator, since it is expensive and we don't want it firing every tick
		queen_locator()

	if (stat != 2)
		if (machine)
			if (!( machine.check_eye(src) ))
				reset_view(null)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return 1

/mob/living/carbon/Xenomorph/proc/handle_environment(var/datum/gas_mixture/environment)
	// Both alien subtypes survive in vaccum and suffer in high temperatures,
	// so I'll just define this once, for both (see radiation comment above)

	var/turf/T = src.loc
	if(environment)
		if(environment.temperature > (T0C+66))
			adjustFireLoss((environment.temperature - (T0C+66))/5) // Might be too high, check in testing.
			if (fire) fire.icon_state = "fire2"
			if(prob(20))
				src << "\red You feel a searing heat!"
		else
			if (fire) fire.icon_state = "fire0"

	if(!T || !istype(T)) return

	if(locate(/obj/effect/alien/weeds) in T)
		if(health >= maxHealth - getCloneLoss())
			storedplasma += plasma_gain
		else
			adjustBruteLoss(-(maxHealth / 40)) //Heal 1/40th of your max health in brute per tick.
			adjustFireLoss(-(maxHealth / 50)) //Heal from fire half as fast
			adjustOxyLoss(-(maxHealth / 10)) //Xenos don't actually take oxyloss, oh well
			adjustToxLoss(-(maxHealth / 5)) //hmmmm, this is probably unnecessary
			storedplasma += plasma_gain
		if(storedplasma > maxplasma) storedplasma = maxplasma
	else //Xenos restore plasma VERY slowly off weeds, and only at full health
		if(health >= maxHealth - getCloneLoss())
			if(rand(0,2) == 0) storedplasma += 1
			if(storedplasma > maxplasma) storedplasma = maxplasma
	//..()

/mob/living/carbon/Xenomorph/death(gibbed)
	if(!gibbed)
		icon_state = "[caste] Dead"
	playsound(loc, 'sound/voice/hiss6.ogg', 50, 1, 1)
	return ..(gibbed,"lets out a waning guttural screech, green blood bubbling from its maw.")

/mob/living/carbon/Xenomorph/proc/queen_locator()
	var/mob/living/carbon/Xenomorph/Queen/target = null

	if(locate_queen)
		for(var/mob/living/carbon/Xenomorph/Queen/M in living_mob_list)
			if(M && !M.stat)
				target = M
				break

	if(!target || !istype(target))
		locate_queen.icon_state = "trackoff"
		return

	if(target.z != src.z || get_dist(src,target) < 1 || src == target)
		locate_queen.icon_state = "trackondirect"
	else
		locate_queen.dir = get_dir(src,target)
		locate_queen.icon_state = "trackon"