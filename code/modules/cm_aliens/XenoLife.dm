//Xenomorph Life - Colonial Marines - Apophis775 - Last Edit: 03JAN2015

/mob/living/carbon/Xenomorph/Life()

	set invisibility = 0
	set background = 1

	if(monkeyizing)
		return
	if(!loc)
		return

	..()

	if(zoom_turf)
		if(loc != zoom_turf && is_zoomed)
			zoom_out()

	if(stat || lying)
		zoom_out()

	if(stat != DEAD) //Stop if dead. Performance boost

		update_progression()

		if(jelly && jellyGrow < jellyMax && is_queen_alive())
			jellyGrow++
			if(jellyGrow == jellyMax - 1)
				src << "\green Your carapace crackles and your tendons strengthen. You are ready to evolve!"

		//Status updates, death etc.
		handle_regular_status_updates()
		update_canmove()
		handle_statuses() //Deals with stunned, etc
		update_icons()
		if(loc)
			handle_environment(loc.return_air())
		if(client)
			handle_regular_hud_updates()

/mob/living/carbon/Xenomorph/proc/handle_regular_status_updates()

	if(status_flags & GODMODE)
		return 0

	if(on_fire)
		if(!fire_stacks)
			on_fire = 0
		else
			if(stat != DEAD && !fire_immune)
				adjustFireLoss(fire_stacks + 3)
			update_fire()
			updatehealth()
			fire_stacks--
	if(health > -100 && health < 0) //Unconscious
		if(readying_tail)
			readying_tail = 0
		blinded = 1
		see_in_dark = 5
		Paralyse(4)
		if(isXenoRunner(src) && layer != initial(layer)) //Unhide
			layer = MOB_LAYER
		var/turf/T = loc
		if(istype(T))
			if(!locate(/obj/effect/alien/weeds) in T) //In crit, only take damage when not on weeds.
				adjustBruteLoss(5)
				updatehealth()
	else						//Alive! Yey! Turn on their vision.
		if(isXenoBoiler(src))
			see_in_dark = 20
		else
			see_in_dark = 8

		updatehealth()

		if(readying_tail && readying_tail < 20)
			readying_tail += rand(1, 2)
			if(isXenoHunter(src))
				readying_tail++ //Hunters get a speed bonus.
			if(readying_tail >= 20)
				readying_tail = 20
				src << "<span class='notice'>Your tail is now fully poised to impale some unfortunate target.</span>"

		if(stat != DEAD)
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
				if(mind)
					if((mind.active && client != null) || immune_to_ssd)
						sleeping = max(sleeping - 1, 0)
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

		if(isXenoCrusher(src) && !stat) //Handle crusher stuff.
			var/mob/living/carbon/Xenomorph/Crusher/X = src
			if(X.momentum > 2 && X.charge_dir != dir)
				X.charge_timer = 0
				X.stop_momentum()
			if(X.charge_timer)
				X.charge_timer--
				if(X.charge_timer == 0 && X.momentum > 2)
					X.stop_momentum()

		frenzy_aura = 0
		guard_aura = 0
		recovery_aura = 0

		for(var/mob/living/carbon/Xenomorph/Z in range(7, src))
			if(isnull(Z.current_aura))
				continue
			if(Z.current_aura == "frenzy" && !Z.stat && Z.storedplasma > 5)
				frenzy_aura++
			if(Z.current_aura == "guard"&& !Z.stat && Z.storedplasma > 5)
				guard_aura++
			if(Z.current_aura == "recovery"&& !Z.stat && Z.storedplasma > 5)
				recovery_aura++

		update_icons()

		//Deal with dissolving/damaging stuff in stomach.
		if(stomach_contents.len)
			for(var/mob/living/M in src)
				if(!isnull(M) && M in stomach_contents)
					M.acid_damage++
					if(M.stat != DEAD)
						M.adjustToxLoss(1)
						if(prob(50))
							M.adjustFireLoss(1)
							if(prob(10))
								M << "\green <b>You are burned by stomach acids!</b>"
						M.updatehealth()
					if(M.acid_damage > 240)
						src << "\green [M] is dissolved in your gut with a gurgle."
						stomach_contents.Remove(M)
						M.loc = locate(138,136,2)

	return 1

/mob/living/carbon/Xenomorph/proc/handle_regular_hud_updates()

	if(healths)
		if(stat != DEAD)
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
		if(stat != DEAD)
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

	if(client)
		client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask, global_hud.nvg, global_hud.thermal, global_hud.meson)

	if(blind && stat != DEAD)
		if(blinded)
			blind.plane = 0
		else
			blind.plane = -80

	if(!stat && prob(25)) //Only a 25% chance of proccing the queen locator, since it is expensive and we don't want it firing every tick
		queen_locator()

	if(stat != DEAD) //Ladders have cameras now.
		if(machine)
			if(!machine.check_eye(src))
				reset_view(null)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return 1

/mob/living/carbon/Xenomorph/proc/handle_environment(var/datum/gas_mixture/environment)
	var/turf/T = loc
	if(environment && !fire_immune)
		if(environment.temperature > (T0C + 66))
			adjustFireLoss((environment.temperature - (T0C + 66)) / 5) //Might be too high, check in testing.
			updatehealth() //Make sure their actual health updates immediately
			if(fire)
				fire.icon_state = "fire2"
			if(prob(20))
				src << "<span class='warning'>You feel a searing heat!</span>"
		else
			if(fire)
				fire.icon_state = "fire0"

	if(!T || !istype(T))
		return

	var/is_runner_hiding

	if(isXenoRunner(src) && layer != initial(layer))
		is_runner_hiding = 1

	if(!is_robotic && !hardcore) //Robot no heal
		if(locate(/obj/effect/alien/weeds) in T)
			if(health >= maxHealth)
				if(!readying_tail && !is_runner_hiding) //Readying tail = no plasma increase.
					storedplasma += plasma_gain
					if(recovery_aura)
						storedplasma += (recovery_aura * 2)
			else
				adjustBruteLoss(-(maxHealth / 70) - 1) //Heal 1/60th of your max health in brute per tick. -2 as a bonus, to help smaller pools.
				if(recovery_aura)
					adjustBruteLoss(-(recovery_aura))
				adjustFireLoss(-(maxHealth / 60)) //Heal from fire half as fast
				adjustOxyLoss(-(maxHealth / 10)) //Xenos don't actually take oxyloss, oh well
				adjustToxLoss(-(maxHealth / 5)) //hmmmm, this is probably unnecessary
				updatehealth() //Make sure their actual health updates immediately.

		else //Xenos restore plasma VERY slowly off weeds, regardless of health
			if(prob(50))
				storedplasma += 1
			if(recovery_aura)
				adjustBruteLoss(-(maxHealth / 80) - 1 - recovery_aura)
				storedplasma += round(recovery_aura + 1)
				updatehealth()

		if(isXenoHivelord(src))
			var/mob/living/carbon/Xenomorph/Hivelord/H = src
			if(H.speed_activated)
				storedplasma -= 30
				if(storedplasma < 0)
					H.speed_activated = 0
					src << "<span class='warning'>You feel dizzy as the world slows down.</span>"

		if(readying_tail)
			storedplasma -= 3
		if(current_aura)
			storedplasma -= 5

	//START HARDCORE //This needs to be removed.
	else if(!is_robotic && hardcore)//Robot no heal
		if(locate(/obj/effect/alien/weeds) in T)
			if(health > 0)
				if(!readying_tail && !is_runner_hiding) //Readying tail = no plasma increase.
					storedplasma += plasma_gain
					if(recovery_aura)
						storedplasma += (recovery_aura * 2)
			if(health < 35) //Barely enough to stay near critical if saved
				adjustBruteLoss(-(maxHealth / 70) - 1) //Heal 1/60th of your max health in brute per tick. -2 as a bonus, to help smaller pools.
				if(recovery_aura)
					adjustBruteLoss(-(recovery_aura))
				adjustFireLoss(-(maxHealth / 60)) //Heal from fire half as fast
				adjustOxyLoss(-(maxHealth / 10)) //Xenos don't actually take oxyloss, oh well
				adjustToxLoss(-(maxHealth / 5)) //hmmmm, this is probably unnecessary
				updatehealth() //Make sure their actual health updates immediately.

		else //Xenos restore plasma VERY slowly off weeds
			if(prob(50))
				storedplasma += 1
			if(recovery_aura)
				adjustBruteLoss(-(maxHealth / 80) - 1 - recovery_aura)
				storedplasma += round(recovery_aura + 1)
				updatehealth()

		if(isXenoHivelord(src))
			var/mob/living/carbon/Xenomorph/Hivelord/H = src
			if(H.speed_activated)
				storedplasma -= 30
				if(storedplasma < 0)
					H.speed_activated = 0
					src << "<span class='warning'>You feel dizzy as the world slows down.</span>"

		if(readying_tail)
			storedplasma -= 3
		if(current_aura)
			storedplasma -= 5
		//END HARDCORE

	if(storedplasma > maxplasma)
		storedplasma = maxplasma
	if(storedplasma < 0)
		storedplasma = 0
		if(current_aura)
			current_aura = null
			src << "<span class='warning'>Having run out of plasma, you stop emitting pheromones.</span>"
		if(readying_tail)
			readying_tail = 0
			src << "<span class='warning'>You feel your tail relax.</span>"

/mob/living/carbon/Xenomorph/gib()
	var/to_flick = "gibbed-a"
	var/obj/effect/decal/remains/xeno/remains = new(get_turf(src))
	remains.icon = icon
	remains.pixel_x = pixel_x //For 2x2.

	switch(type) //This will need to be changed later, when we have proper xeno pathing. Might do it on caste or something.
		if(/mob/living/carbon/Xenomorph/Boiler)
			var/mob/living/carbon/Xenomorph/Boiler/B = src
			visible_message("<span class='danger'>[src] begins to bulge grotesquely, and explodes in a cloud of corrosive gas!</span>")
			B.smoke.set_up(6, 0, get_turf(src))
			B.smoke.start()
			remains.icon_state = "gibbed-a-corpse"
		if(/mob/living/carbon/Xenomorph/Runner)
			to_flick = "gibbed-a-corpse-runner"
			remains.icon_state = "gibbed-a-corpse-runner"
		if(/mob/living/carbon/Xenomorph/Larva)
			to_flick = "larva_gib"
			remains.icon_state = "larva_gib_corpse"
		else remains.icon_state = "gibbed-a-corpse"

	..(to_flick, 0, icon) //We're spawning our own gibs, no need to do the human kind.
	xgibs(get_turf(src))

/mob/living/carbon/Xenomorph/death(gibbed)
	var/msg = !is_robotic ? "lets out a waning guttural screech, green blood bubbling from its maw." : "begins to shudder, and the lights go out in its eyes as it lies still."
	. = ..(gibbed,msg)
	if(!.) return //If they're already dead, it will return.

	if(!gibbed) icon_state = "[caste] Dead"

	if(istype(src,/mob/living/carbon/Xenomorph/Queen))
		playsound(loc, 'sound/voice/alien_queen_died.ogg', 100, 0, 20)
		xeno_message("<span class='xenodanger'>A sudden tremor ripples through the hive... the Queen has been slain! Vengeance!</span>",3)
		xeno_message("<span class='danger'>The slashing of hosts is now permitted.</span>",2)
		slashing_allowed = 1
		if(ticker && ticker.mode) ticker.mode.check_queen_status(queen_time)
	else
		playsound(loc, prob(50) == 1 ? 'sound/voice/alien_death.ogg' : 'sound/voice/alien_death2.ogg', 50, 1, 1)
		var/area/A = get_area(src)
		xeno_message("<span class='xenonotice'>Hive: A [name] has <b>died</b>[A? " at [sanitize(A.name)]":""]!</span>",3)

	for(var/atom/movable/A in stomach_contents)
		stomach_contents -= A
		A.loc = loc

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

/mob/living/carbon/Xenomorph/updatehealth(gib_bonus = 0)
	var/gib_prob = gib_chance + gib_bonus
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else health = maxHealth - getFireLoss() - getBruteLoss() //Xenos can only take brute and fire damage.

	if(health <= crit_health)
		if(prob(gib_prob)) 	gib()
		else 				death()
