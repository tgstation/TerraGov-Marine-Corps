//Xenomorph Life - Colonial Marines - Apophis775 - Last Edit: 03JAN2015

/mob/living/carbon/Xenomorph/Life()

	set invisibility = 0
	set background = 1

	if(monkeyizing)
		return
	if(!loc)
		return

	..()

	if(is_zoomed)
		if(zoom_turf)
			if(loc != zoom_turf)
				zoom_out()

		if(stat || lying)
			zoom_out()

	if(stat != DEAD) //Stop if dead. Performance boost

		update_progression()

		if(client && ckey) // stop evolve progress for ssd/ghosted xenos
			if(hivenumber && hivenumber <= hive_datum.len)
				var/datum/hive_status/hive = hive_datum[hivenumber]

				if(evolution_allowed && evolution_stored < evolution_threshold && hive.living_xeno_queen && hive.living_xeno_queen.ovipositor)
					evolution_stored = min(evolution_stored + 1, evolution_threshold)
					if(evolution_stored == evolution_threshold - 1)
						src << "<span class='xenodanger'>Your carapace crackles and your tendons strengthen. You are ready to evolve!</span>" //Makes this bold so the Xeno doesn't miss it
						src << sound('sound/effects/xeno_evolveready.ogg')

		//Status updates, death etc.
		handle_regular_status_updates()
		update_canmove()
		update_icons()
		if(loc)
			handle_environment()
		if(client)
			handle_regular_hud_updates()

/mob/living/carbon/Xenomorph/proc/handle_regular_status_updates()

	if(status_flags & GODMODE)
		return 0

	if(on_fire)
		SetLuminosity(min(fire_stacks,5)) // light up xenos
		var/obj/item/clothing/mask/facehugger/F = get_active_hand()
		var/obj/item/clothing/mask/facehugger/G = get_inactive_hand()
		if(istype(F))
			F.Die()
			drop_inv_item_on_ground(F)
		if(istype(G))
			G.Die()
			drop_inv_item_on_ground(G)
		if(!fire_immune)
			adjustFireLoss(fire_stacks + 3)

	else
		if(isXenoBoiler(src))
			SetLuminosity(3) // needs a less hacky way of doing this, like a default luminosity var
		else
			SetLuminosity(0)

	if(health <= 0) //Sleeping Xenos are also unconscious, but all crit Xenos are under 0 HP. Go figure
		var/turf/T = loc
		if(istype(T))
			if(!locate(/obj/effect/alien/weeds) in T) //In crit, damage is maximal if you're caught off weeds
				adjustBruteLoss(2.5 - warding_aura*0.5) //Warding can heavily lower the impact of bleedout. Halved at 2.5 phero, stopped at 5 phero
			else
				adjustBruteLoss(-warding_aura*0.5) //Warding pheromones provides 0.25 HP per second per step, up to 2.5 HP per tick.

	//Rollercoaster of fucking stupid because Xeno life ticks aren't synchronised properly and values reset just after being applied
	//At least it's more efficient since only Xenos with an aura do this, instead of all Xenos
	//Basically, we use a special tally var so we don't reset the actual aura value before making sure they're not affected
	//Now moved out of healthy only state, because crit xenos can def still be affected by pheros

	if(stat != DEAD) //Dead Xenos don't emit or receive pheromones, ever
		if(current_aura && !stat && plasma_stored > 5)
			if(caste == "Queen" && anchored) //stationary queen's pheromone apply around the observed xeno.
				var/mob/living/carbon/Xenomorph/Queen/Q = src
				var/atom/phero_center = Q
				if(Q.observed_xeno)
					phero_center = Q.observed_xeno
				var/pheromone_range = round(6 + aura_strength * 2)
				for(var/mob/living/carbon/Xenomorph/Z in range(pheromone_range, phero_center)) //Goes from 8 for Queen to 16 for Ancient Queen
					if(current_aura == "frenzy" && aura_strength > Z.frenzy_new && hivenumber == Z.hivenumber)
						Z.frenzy_new = aura_strength
					if(current_aura == "warding" && aura_strength > Z.warding_new && hivenumber == Z.hivenumber)
						Z.warding_new = aura_strength
					if(current_aura == "recovery" && aura_strength > Z.recovery_new && hivenumber == Z.hivenumber)
						Z.recovery_new = aura_strength
			else
				var/pheromone_range = round(6 + aura_strength * 2)
				for(var/mob/living/carbon/Xenomorph/Z in range(pheromone_range, src)) //Goes from 7 for Young Drone to 16 for Ancient Queen
					if(current_aura == "frenzy" && aura_strength > Z.frenzy_new && hivenumber == Z.hivenumber)
						Z.frenzy_new = aura_strength
					if(current_aura == "warding" && aura_strength > Z.warding_new && hivenumber == Z.hivenumber)
						Z.warding_new = aura_strength
					if(current_aura == "recovery" && aura_strength > Z.recovery_new && hivenumber == Z.hivenumber)
						Z.recovery_new = aura_strength

		if(leader_current_aura && !stat)
			var/pheromone_range = round(6 + leader_aura_strength * 2)
			for(var/mob/living/carbon/Xenomorph/Z in range(pheromone_range, src)) //Goes from 7 for Young Drone to 16 for Ancient Queen
				if(leader_current_aura == "frenzy" && leader_aura_strength > Z.frenzy_new && hivenumber == Z.hivenumber)
					Z.frenzy_new = leader_aura_strength
				if(leader_current_aura == "warding" && leader_aura_strength > Z.warding_new && hivenumber == Z.hivenumber)
					Z.warding_new = leader_aura_strength
				if(leader_current_aura == "recovery" && leader_aura_strength > Z.recovery_new && hivenumber == Z.hivenumber)
					Z.recovery_new = leader_aura_strength

		if(frenzy_aura != frenzy_new || warding_aura != warding_new || recovery_aura != recovery_new)
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

		//Deal with dissolving/damaging stuff in stomach.
		if(stomach_contents.len)
			for(var/atom/movable/M in stomach_contents)
				if(world.time > devour_timer && ishuman(M))
					devour_timer = world.time + 500 + rand(0,200) // 50-70 seconds
					var/mob/living/carbon/human/H = M
					var/limb_name = H.remove_random_limb(1)
					if(limb_name)
						H << "<span class='danger'>Your [limb_name] dissolved in the acid!</span>"
					if(prob(50))
						stomach_contents.Remove(M)
						M.acid_damage = 0
						if(M.loc != src)
							continue
						M.forceMove(loc)

				M.acid_damage++
				if(M.acid_damage > 300)
					src << "<span class='xenodanger'>\The [M] is dissolved in your gut with a gurgle.</span>"
					stomach_contents.Remove(M)
					cdel(M)
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
			if(plasma_max) //No divide by zeros please
				switch(round(plasma_stored * 100 / plasma_max))
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


	if(stat != DEAD)
		if(blinded)
			overlay_fullscreen("blind", /obj/screen/fullscreen/blind)
		else
			clear_fullscreen("blind")

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
adjustBruteLoss(-((maxHealth / 70) + 0.5 + (maxHealth / 70) * recovery_aura/2)*(m)); \
adjustFireLoss(-(maxHealth / 60 + 0.5 + (maxHealth / 60) * recovery_aura/2)*(m)); \
adjustOxyLoss(-(maxHealth * 0.1 + 0.5 + (maxHealth * 0.1) * recovery_aura/2)*(m)); \
adjustToxLoss(-(maxHealth / 5 + 0.5 + (maxHealth / 5) * recovery_aura/2)*(m)); \
updatehealth()


/mob/living/carbon/Xenomorph/proc/handle_environment()
	var/turf/T = loc

	var/env_temperature = loc.return_temperature()
	if(!fire_immune)
		if(env_temperature > (T0C + 66))
			adjustFireLoss((env_temperature - (T0C + 66)) / 5) //Might be too high, check in testing.
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
			plasma_stored += plasma_gain
			if(recovery_aura)
				plasma_stored += round(plasma_gain * recovery_aura/4) //Divided by four because it gets massive fast. 1 is equivalent to weed regen! Only the strongest pheromones should bypass weeds
			if(health < maxHealth)
				var/datum/hive_status/hive = hive_datum[hivenumber]
				if(innate_healing || !hive.living_xeno_queen || hive.living_xeno_queen.loc.z == loc.z)
					if(lying || resting)
						if(health > -100 && health < 0) //Unconscious
							XENO_HEAL_WOUNDS(0.33) //Healing is much slower. Warding pheromones make up for the rest if you're curious
						else
							XENO_HEAL_WOUNDS(1)
					else if(isXenoCrusher() || isXenoRavager())
						XENO_HEAL_WOUNDS(0.66)
					else
						XENO_HEAL_WOUNDS(0.33) //Major healing nerf if standing


				updatehealth()

		else //Xenos restore plasma VERY slowly off weeds, regardless of health, as long as they are not using special abilities
			if(prob(50) && !is_runner_hiding && !current_aura)
				plasma_stored++

		if(isXenoHivelord(src))
			var/mob/living/carbon/Xenomorph/Hivelord/H = src
			if(H.speed_activated)
				plasma_stored -= 30
				if(plasma_stored < 0)
					H.speed_activated = 0
					src << "<span class='warning'>You feel dizzy as the world slows down.</span>"

		if(current_aura)
			plasma_stored -= 5

	//START HARDCORE //This needs to be removed.
	else if(!is_robotic && hardcore)//Robot no heal
		if(locate(/obj/effect/alien/weeds) in T)
			if(health > 0)
				plasma_stored += plasma_gain
				if(recovery_aura)
					plasma_stored += (recovery_aura * 2)
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
				plasma_stored++
			if(recovery_aura)
				adjustBruteLoss(-(maxHealth / 80) - 1 - recovery_aura)
				plasma_stored += round(recovery_aura + 1)
				updatehealth()

		if(isXenoHivelord(src))
			var/mob/living/carbon/Xenomorph/Hivelord/H = src
			if(H.speed_activated)
				plasma_stored -= 30
				if(plasma_stored < 0)
					H.speed_activated = 0
					src << "<span class='warning'>You feel dizzy as the world slows down.</span>"

		if(current_aura)
			plasma_stored -= 5
		//END HARDCORE

	if(plasma_stored > plasma_max)
		plasma_stored = plasma_max
	if(plasma_stored < 0)
		plasma_stored = 0
		if(current_aura)
			current_aura = null
			src << "<span class='warning'>You have run out of pheromones and stopped emitting pheromones.</span>"

	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_icon()

	hud_set_plasma() //update plasma amount on the plasma mob_hud



/mob/living/carbon/Xenomorph/proc/queen_locator()
	if(!hud_used || !hud_used.locate_leader) return

	var/datum/hive_status/hive
	if(hivenumber && hivenumber <= hive_datum.len)
		hive = hive_datum[hivenumber]
	else
		return

	if(!hive.living_xeno_queen || is_intelligent)
		hud_used.locate_leader.icon_state = "trackoff"
		return

	if(hive.living_xeno_queen.loc.z != loc.z || get_dist(src,hive.living_xeno_queen) < 1 || src == hive.living_xeno_queen)
		hud_used.locate_leader.icon_state = "trackondirect"
	else
		var/area/A = get_area(loc)
		var/area/QA = get_area(hive.living_xeno_queen.loc)
		if(A.fake_zlevel == QA.fake_zlevel)
			hud_used.locate_leader.dir = get_dir(src,hive.living_xeno_queen)
			hud_used.locate_leader.icon_state = "trackon"
		else
			hud_used.locate_leader.icon_state = "trackondirect"

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
