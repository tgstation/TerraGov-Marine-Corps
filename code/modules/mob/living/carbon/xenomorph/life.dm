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

		if(evolution_allowed && evolution_stored < evolution_threshold && living_xeno_queen)
			evolution_stored = min(evolution_stored + 1, evolution_threshold)
			if(evolution_stored == evolution_threshold - 1)
				src << "<span class='xenodanger'>Your carapace crackles and your tendons strengthen. You are ready to evolve!</span>" //Makes this bold so the Xeno doesn't miss it
				src << sound('sound/effects/xeno_evolveready.ogg')

		//Status updates, death etc.
		handle_regular_status_updates()
		update_canmove()
		update_icons()
		if(loc)
			handle_environment(loc.return_air())
		if(client)
			handle_regular_hud_updates()

/mob/living/carbon/Xenomorph/proc/handle_regular_status_updates()

	if(status_flags & GODMODE)
		return 0

	if(on_fire)
		if(!fire_immune)
			adjustFireLoss(fire_stacks + 3)

	if(health <= 0) //Sleeping Xenos are also unconscious, but all crit Xenos are under 0 HP. Go figure
		var/turf/T = loc
		if(istype(T))
			if(!locate(/obj/effect/alien/weeds) in T) //In crit, damage is maximal if you're caught off weeds
				adjustBruteLoss(2.5 - warding_aura/2) //You can reduce and even stop crit loss above 2.5 aura_strength //Can now heal damage outright
			else
				adjustBruteLoss(-warding_aura) //You can at best stop it, if you have full warding pheromones. Get to weeds fast

	updatehealth()

	if(health <= crit_health) //dead
		if(prob(gib_chance + 0.5*(crit_health - health)))
			gib()
		else
			death()
		return

	else if(health <= 0) //in crit
		stat = UNCONSCIOUS
		blinded = 1
		see_in_dark = 5
		if(isXenoRunner(src) && layer != initial(layer)) //Unhide
			layer = MOB_LAYER

	else						//alive and not in crit! Turn on their vision.
		if(isXenoBoiler(src))
			see_in_dark = 20
		else
			see_in_dark = 8

		ear_deaf = 0 //All this stuff is prob unnecessary
		ear_damage = 0
		eye_blind = 0
		eye_blurry = 0

		if(knocked_out) //If they're down, make sure they are actually down.
			AdjustKnockedout(-3)
			blinded = 1
			stat = UNCONSCIOUS
			if(halloss > 0)
				adjustHalLoss(-3)
		else if(sleeping)
			if(halloss > 0)
				adjustHalLoss(-3)
			if(mind)
				if((mind.active && client != null) || immune_to_ssd)
					sleeping = max(sleeping - 1, 0)
			blinded = 1
			stat = UNCONSCIOUS
		else
			blinded = 0
			stat = CONSCIOUS
			if(halloss > 0)
				if(resting)
					adjustHalLoss(-3)
				else
					adjustHalLoss(-1)

		handle_statuses()//natural decrease of stunned, knocked_down, etc...

		if(isXenoCrusher(src) && !stat) //Handle crusher stuff.
			var/mob/living/carbon/Xenomorph/Crusher/X = src
			if(X.momentum > 2 && X.charge_dir != dir)
				X.charge_timer = 0
				X.stop_momentum()
			if(X.charge_timer)
				X.charge_timer--
				if(X.charge_timer == 0 && X.momentum > 2)
					X.stop_momentum()

		//Rollercoaster of fucking stupid because Xeno life ticks aren't synchronised properly and values reset just after being applied
		//At least it's more efficient since only Xenos with an aura do this, instead of all Xenos
		//Basically, we use a special tally var so we don't reset the actual aura value before making sure they're not affected

		if(current_aura && !stat && storedplasma > 5)
			var/pheromone_range = round(6 + aura_strength * 2)
			for(var/mob/living/carbon/Xenomorph/Z in range(pheromone_range, src)) //Goes from 7 for Young Drone to 16 for Ancient Queen
				if(current_aura == "frenzy" && aura_strength > Z.frenzy_new)
					Z.frenzy_new = aura_strength
				if(current_aura == "warding" && aura_strength > Z.warding_new)
					Z.warding_new = aura_strength
				if(current_aura == "recovery" && aura_strength > Z.recovery_new)
					Z.recovery_new = aura_strength

		frenzy_aura = frenzy_new
		warding_aura = warding_new
		recovery_aura = recovery_new
		hud_set_pheromone()

		frenzy_new = 0
		warding_new = 0
		recovery_new = 0

		armor_bonus = 0

		if(warding_aura > 0)
			armor_bonus = warding_aura * 3 //Bonus armor from pheromones, no matter what the armor was previously. Was 5

		update_icons()

		//Deal with dissolving/damaging stuff in stomach.
		if(stomach_contents.len)
			for(var/atom/movable/M in stomach_contents)
				M.acid_damage++
				if(M.acid_damage > 300)
					src << "<span class='xenodanger'>\The [M] is dissolved in your gut with a gurgle.</span>"
					stomach_contents.Remove(M)
					M.loc = locate(138, 136, 2)
	return 1

/mob/living/carbon/Xenomorph/proc/handle_regular_hud_updates()

	if(hud_used && hud_used.healths)
		if(stat != DEAD)
			switch(round(health * 100 / maxHealth)) //Maxhealth should never be zero or this will generate runtimes.
				if(100 to INFINITY)
					hud_used.healths.icon_state = "health_full"
				if(94 to 99)
					hud_used.healths.icon_state = "health_16"
				if(88 to 93)
					hud_used.healths.icon_state = "health_15"
				if(82 to 87)
					hud_used.healths.icon_state = "health_14"
				if(76 to 81)
					hud_used.healths.icon_state = "health_13"
				if(70 to 75)
					hud_used.healths.icon_state = "health_12"
				if(64 to 69)
					hud_used.healths.icon_state = "health_11"
				if(58 to 63)
					hud_used.healths.icon_state = "health_10"
				if(52 to 57)
					hud_used.healths.icon_state = "health_9"
				if(46 to 51)
					hud_used.healths.icon_state = "health_8"
				if(40 to 45)
					hud_used.healths.icon_state = "health_7"
				if(34 to 39)
					hud_used.healths.icon_state = "health_6"
				if(28 to 33)
					hud_used.healths.icon_state = "health_5"
				if(22 to 27)
					hud_used.healths.icon_state = "health_4"
				if(16 to 21)
					hud_used.healths.icon_state = "health_3"
				if(10 to 15)
					hud_used.healths.icon_state = "health_2"
				if(4 to 9)
					hud_used.healths.icon_state = "health_1"
				if(0 to 3)
					hud_used.healths.icon_state = "health_0"
				else
					hud_used.healths.icon_state = "health_critical"
		else
			hud_used.healths.icon_state = "health_dead"

	if(hud_used && hud_used.alien_plasma_display)
		if(stat != DEAD)
			if(maxplasma) //No divide by zeros please
				switch(round(storedplasma * 100 / maxplasma))
					if(100 to INFINITY)
						hud_used.alien_plasma_display.icon_state = "power_display_full"
					if(94 to 99)
						hud_used.alien_plasma_display.icon_state = "power_display_16"
					if(88 to 93)
						hud_used.alien_plasma_display.icon_state = "power_display_15"
					if(82 to 87)
						hud_used.alien_plasma_display.icon_state = "power_display_14"
					if(76 to 81)
						hud_used.alien_plasma_display.icon_state = "power_display_13"
					if(70 to 75)
						hud_used.alien_plasma_display.icon_state = "power_display_12"
					if(64 to 69)
						hud_used.alien_plasma_display.icon_state = "power_display_11"
					if(58 to 63)
						hud_used.alien_plasma_display.icon_state = "power_display_10"
					if(52 to 57)
						hud_used.alien_plasma_display.icon_state = "power_display_9"
					if(46 to 51)
						hud_used.alien_plasma_display.icon_state = "power_display_8"
					if(40 to 45)
						hud_used.alien_plasma_display.icon_state = "power_display_7"
					if(34 to 39)
						hud_used.alien_plasma_display.icon_state = "power_display_6"
					if(28 to 33)
						hud_used.alien_plasma_display.icon_state = "power_display_5"
					if(22 to 27)
						hud_used.alien_plasma_display.icon_state = "power_display_4"
					if(16 to 21)
						hud_used.alien_plasma_display.icon_state = "power_display_3"
					if(10 to 15)
						hud_used.alien_plasma_display.icon_state = "power_display_2"
					if(4 to 9)
						hud_used.alien_plasma_display.icon_state = "power_display_1"
					if(0 to 3)
						hud_used.alien_plasma_display.icon_state = "power_display_0"
					else
						hud_used.alien_plasma_display.icon_state = "power_display_empty"
			else
				hud_used.alien_plasma_display.icon_state = "power_display_empty"
		else
			hud_used.alien_plasma_display.icon_state = "power_display_empty"

	if(client)
		client.screen.Remove(global_hud.blurry, global_hud.druggy, global_hud.vimpaired, global_hud.darkMask, global_hud.nvg, global_hud.thermal, global_hud.meson)

	if(hud_used && hud_used.blind_icon && stat != DEAD)
		if(blinded)
			hud_used.blind_icon.plane = 0
		else
			hud_used.blind_icon.plane = -80

	if(!stat && prob(25)) //Only a 25% chance of proccing the queen locator, since it is expensive and we don't want it firing every tick
		queen_locator()

	if(stat != DEAD) //Ladders have cameras now.
		if(interactee)
			interactee.check_eye(src)
		else
			if(client && !client.adminobs)
				reset_view(null)

	return 1

/*Heal 1/70th of your max health in brute per tick. 1 as a bonus, to help smaller pools.
Additionally, recovery pheromones mutiply this base healing, up to 2.5 times faster at level 5
Modified via m, to multiply the number of wounds healed.
Heal from fire half as fast
Xenos don't actually take oxyloss, oh well
hmmmm, this is probably unnecessary
Make sure their actual health updates immediately.*/

#define XENO_HEAL_WOUNDS(m) \
adjustBruteLoss(-((maxHealth / 70) + 1 + (maxHealth / 70) * recovery_aura)*(m)); \
adjustFireLoss(-(maxHealth / 60 + (maxHealth / 60) * recovery_aura)*(m)); \
adjustOxyLoss(-(maxHealth * 0.1 + (maxHealth * 0.1) * recovery_aura)*(m)); \
adjustToxLoss(-(maxHealth / 5 + (maxHealth / 5) * recovery_aura)*(m)); \
updatehealth()


/mob/living/carbon/Xenomorph/proc/handle_environment(var/datum/gas_mixture/environment)
	var/turf/T = loc
	if(environment && !fire_immune)
		if(environment.temperature > (T0C + 66))
			adjustFireLoss((environment.temperature - (T0C + 66)) / 5) //Might be too high, check in testing.
			updatehealth() //Make sure their actual health updates immediately
			if(hud_used && hud_used.fire_icon)
				hud_used.fire_icon.icon_state = "fire2"
			if(prob(20))
				src << "<span class='warning'>You feel a searing heat!</span>"
		else
			if(hud_used && hud_used.fire_icon)
				hud_used.fire_icon.icon_state = "fire0"

	if(!T || !istype(T))
		return

	var/is_runner_hiding

	if(isXenoRunner(src) && layer != initial(layer))
		is_runner_hiding = 1

	if(!is_robotic && !hardcore) //Robot no heal
		if(innate_healing || (locate(/obj/effect/alien/weeds) in T))
			storedplasma += plasma_gain
			if(recovery_aura)
				storedplasma += round(plasma_gain * recovery_aura/2) //Divided by two because it gets massive fast. Even 1 is equivalent to weed regen!
			if(health < maxHealth)
				if(lying || resting)
					if(health > -100 && health < 0) //Unconscious
						XENO_HEAL_WOUNDS(0.33) //Healing is much slower. Warding pheromones make up for the rest if you're curious
					else
						XENO_HEAL_WOUNDS(1)
				else if (isXenoCrusher() || isXenoRavager())
					XENO_HEAL_WOUNDS(0.66)
				else
					XENO_HEAL_WOUNDS(0.33) //Major healing nerf if standing


				updatehealth()

		else //Xenos restore plasma VERY slowly off weeds, regardless of health, as long as they are not using special abilities
			if(prob(50) && !is_runner_hiding && !current_aura)
				storedplasma++

		if(isXenoHivelord(src))
			var/mob/living/carbon/Xenomorph/Hivelord/H = src
			if(H.speed_activated)
				storedplasma -= 30
				if(storedplasma < 0)
					H.speed_activated = 0
					src << "<span class='warning'>You feel dizzy as the world slows down.</span>"

		if(current_aura)
			storedplasma -= 5

	//START HARDCORE //This needs to be removed.
	else if(!is_robotic && hardcore)//Robot no heal
		if(locate(/obj/effect/alien/weeds) in T)
			if(health > 0)
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

		else //Xenos restore plasma VERY slowly off weeds, regardless of health, as long as they are not using special abilities
			if(prob(50) && !is_runner_hiding && !current_aura)
				storedplasma++
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

		if(current_aura)
			storedplasma -= 5
		//END HARDCORE

	if(storedplasma > maxplasma)
		storedplasma = maxplasma
	if(storedplasma < 0)
		storedplasma = 0
		if(current_aura)
			current_aura = null
			src << "<span class='warning'>You have run out of pheromones and stopped emitting pheromones.</span>"

	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()

	hud_set_plasma() //update plasma amount on the plasma mob_hud

/mob/living/carbon/Xenomorph/gib()
	var/to_flick = "gibbed-a"
	var/obj/effect/decal/remains/xeno/remains = new(get_turf(src))
	remains.icon = icon
	remains.pixel_x = pixel_x //For 2x2.

	switch(caste) //This will need to be changed later, when we have proper xeno pathing. Might do it on caste or something.
		if("Boiler")
			var/mob/living/carbon/Xenomorph/Boiler/B = src
			visible_message("<span class='danger'>[src] begins to bulge grotesquely, and explodes in a cloud of corrosive gas!</span>")
			B.smoke.set_up(2, 0, get_turf(src))
			B.smoke.start()
			remains.icon_state = "gibbed-a-corpse"
		if("Runner")
			to_flick = "gibbed-a-corpse-runner"
			remains.icon_state = "gibbed-a-corpse-runner"
		if("Bloody Larva","Predalien Larva")
			to_flick = "larva_gib"
			remains.icon_state = "larva_gib_corpse"
		else remains.icon_state = "gibbed-a-corpse"

	..(to_flick, 0, icon) //We're spawning our own gibs, no need to do the human kind.
	check_blood_splash(35, BURN, 65, 2) //Some testing numbers. 35 burn, 65 chance.
	xgibs(get_turf(src))

/mob/living/carbon/Xenomorph/death(gibbed)
	var/msg = !is_robotic ? "lets out a waning guttural screech, green blood bubbling from its maw." : "begins to shudder, and the lights go out in its eyes as it lies still."
	. = ..(gibbed,msg)
	if(!.) return //If they're already dead, it will return.

	if(is_zoomed)
		zoom_out()

	if(!gibbed)
		if(hud_used && hud_used.healths)
			hud_used.healths.icon_state = "health_dead"
		if(hud_used && hud_used.alien_plasma_display)
			hud_used.alien_plasma_display.icon_state = "power_display_empty"
		update_icons()

	if(z != ADMIN_Z_LEVEL) //so xeno players don't get death messages from admin tests
		switch(caste)
			if("Queen")
				playsound(loc, 'sound/voice/alien_queen_died.ogg', 75, 0)
				if(living_xeno_queen == src)
					xeno_message("<span class='xenoannounce'>A sudden tremor ripples through the hive... the Queen has been slain! Vengeance!</span>",3)
					xeno_message("<span class='xenoannounce'>The slashing of hosts is now permitted.</span>",2)
					slashing_allowed = 1
					living_xeno_queen = null
					//on the off chance there was somehow two queen alive
					for(var/mob/living/carbon/Xenomorph/Queen/Q in living_mob_list)
						if(!isnull(Q) && Q != src && Q.stat != DEAD)
							living_xeno_queen = Q
							break
					if(ticker && ticker.mode)
						ticker.mode.check_queen_status(queen_time)
			else
				if(caste == "Predalien") playsound(loc, 'sound/voice/predalien_death.ogg', 75, 1)
				else playsound(loc, prob(50) == 1 ? 'sound/voice/alien_death.ogg' : 'sound/voice/alien_death2.ogg', 25, 1)
				var/area/A = get_area(src)
				xeno_message("Hive: \The [src] has <b>died</b>[A? " at [sanitize(A.name)]":""]!", 3)

	for(var/atom/movable/A in stomach_contents)
		stomach_contents -= A
		A.acid_damage = 0 //Reset the acid damage
		A.loc = loc

	round_statistics.total_xeno_deaths++



/mob/living/carbon/Xenomorph/proc/queen_locator()
	if(!hud_used || !hud_used.locate_leader) return

	if(!living_xeno_queen || is_intelligent)
		hud_used.locate_leader.icon_state = "trackoff"
		return

	if(living_xeno_queen.z != src.z || get_dist(src,living_xeno_queen) < 1 || src == living_xeno_queen)
		hud_used.locate_leader.icon_state = "trackondirect"
	else
		hud_used.locate_leader.dir = get_dir(src,living_xeno_queen)
		hud_used.locate_leader.icon_state = "trackon"

/mob/living/carbon/Xenomorph/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else health = maxHealth - getFireLoss() - getBruteLoss() //Xenos can only take brute and fire damage.

	med_hud_set_health()




/mob/living/carbon/Xenomorph/handle_stunned()
	if(stunned)
		AdjustStunned(-2)
	return stunned

/mob/living/carbon/Xenomorph/handle_knocked_down()
	if(knocked_down && client)
		knocked_down = max(knocked_down-2,0)
	return knocked_down
