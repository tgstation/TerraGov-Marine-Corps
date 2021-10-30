#define DEBUG_XENO_LIFE 0
#define XENO_RESTING_HEAL 1.1
#define XENO_STANDING_HEAL 0.2
#define XENO_CRIT_DAMAGE 5

#define XENO_HUD_ICON_BUCKETS 16  // should equal the number of icons you use to represent health / plasma (from 0 -> X)

/mob/living/carbon/xenomorph/Life()

	if(!loc)
		return

	..()

	if(notransform) //If we're in true stasis don't bother processing life
		return

	if(stat == DEAD) //Dead, nothing else to do but this.
		if(plasma_stored && !(xeno_caste.caste_flags & CASTE_DECAY_PROOF))
			handle_decay()
		else
			SSmobs.stop_processing(src)
		return
	if(stat == UNCONSCIOUS)
		if(is_zoomed)
			zoom_out()
	else
		if(is_zoomed)
			if(loc != zoom_turf || lying_angle)
				zoom_out()
		update_progression()
		update_evolving()
		handle_aura_emiter()

	handle_aura_receiver()
	handle_living_sunder_updates()
	handle_living_health_updates()
	handle_living_plasma_updates()
	update_action_button_icons()
	update_icons()

/mob/living/carbon/xenomorph/handle_status_effects()
	. = ..()
	handle_stagger() // 1 each time
	handle_slowdown() // 0.4 each time

/mob/living/carbon/xenomorph/handle_fire()
	. = ..()
	if(.)
		return
	if(!(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE) && on_fire) //Sanity check; have to be on fire to actually take the damage.
		SEND_SIGNAL(src, COMSIG_XENOMORPH_FIRE_BURNING)
		adjustFireLoss((fire_stacks + 3) * get_fire_resist() )

/mob/living/carbon/xenomorph/proc/handle_living_health_updates()
	if(health < 0)
		handle_critical_health_updates()
		return
	if((health >= maxHealth) || xeno_caste.hardcore || on_fire) //can't regenerate.
		updatehealth() //Update health-related stats, like health itself (using brute and fireloss), health HUD and status.
		return
	var/turf/T = loc
	if(!istype(T))
		return

	var/ruler_healing_penalty = 0.5
	if(hive?.living_xeno_ruler?.loc?.z == T.z || xeno_caste.caste_flags & CASTE_CAN_HEAL_WITHOUT_QUEEN || (SSticker?.mode.flags_round_type & MODE_XENO_RULER)) //if the living queen's z-level is the same as ours.
		ruler_healing_penalty = 1
	var/obj/effect/alien/weeds/weed = locate() in T
	if(weed || xeno_caste.caste_flags & CASTE_INNATE_HEALING) //We regenerate on weeds or can on our own.
		if(lying_angle || resting || xeno_caste.caste_flags & CASTE_QUICK_HEAL_STANDING)
			heal_wounds(XENO_RESTING_HEAL * ruler_healing_penalty * weed ? weed.resting_buff : 1, TRUE)
		else
			heal_wounds(XENO_STANDING_HEAL * ruler_healing_penalty, TRUE) //Major healing nerf if standing.
	updatehealth()

///Handles sunder modification/recovery during life.dm for xenos
/mob/living/carbon/xenomorph/proc/handle_living_sunder_updates()

	if(!sunder || on_fire) //No sunder, no problem; or we're on fire and can't regenerate.
		return

	var/sunder_recov = xeno_caste.sunder_recover * -0.5 //Baseline

	if(resting) //Resting doubles sunder recovery
		sunder_recov *= 2

	if(locate(/obj/effect/alien/weeds/resting) in loc) //Resting weeds double sunder recovery
		sunder_recov *= 2

	if(recovery_aura)
		sunder_recov *= 1 + recovery_aura * 0.1 //10% bonus per rank of recovery aura

	SEND_SIGNAL(src, COMSIG_XENOMORPH_SUNDER_REGEN, src)

	adjust_sunder(sunder_recov)

/mob/living/carbon/xenomorph/proc/handle_critical_health_updates()
	var/turf/T = loc
	if((istype(T) && locate(/obj/effect/alien/weeds) in T))
		heal_wounds(XENO_RESTING_HEAL)
	else if(!endure) //If we're not Enduring we bleed out
		adjustBruteLoss(XENO_CRIT_DAMAGE)

/mob/living/carbon/xenomorph/proc/heal_wounds(multiplier = XENO_RESTING_HEAL, scaling = FALSE)
	var/amount = 1 + (maxHealth * 0.0375) // 1 damage + 3.75% max health, with scaling power.
	if(recovery_aura)
		amount += recovery_aura * maxHealth * 0.01 // +1% max health per recovery level, up to +5%
	if(scaling)
		if(recovery_aura)
			regen_power = clamp(regen_power + xeno_caste.regen_ramp_amount*30,0,1) //Ignores the cooldown, and gives a 50% boost.
		else if(regen_power < 0) // We're not supposed to regenerate yet. Start a countdown for regeneration.
			regen_power += 2 SECONDS //Life ticks are 2 seconds.
			return
		else
			regen_power = min(regen_power + xeno_caste.regen_ramp_amount*20,1)
		amount *= regen_power
	amount *= multiplier * GLOB.xeno_stat_multiplicator_buff

	var/list/heal_data = list(amount)
	SEND_SIGNAL(src, COMSIG_XENOMORPH_HEALTH_REGEN, heal_data)

	var/remainder = max(0, heal_data[1]-getBruteLoss())
	adjustBruteLoss(-amount)
	adjustFireLoss(-remainder)

/mob/living/carbon/xenomorph/proc/handle_living_plasma_updates()
	var/turf/T = loc
	if(!T || !istype(T))
		return
	if(plasma_stored >= xeno_caste.plasma_max * xeno_caste.plasma_regen_limit)
		return

	if(current_aura)
		if(plasma_stored < 5)
			use_plasma(plasma_stored)
			current_aura = null
			to_chat(src, span_warning("We have run out of plasma and stopped emitting pheromones."))
		else
			use_plasma(5)

	if(HAS_TRAIT(src, TRAIT_NOPLASMAREGEN))
		hud_set_plasma()
		return

	var/obj/effect/alien/weeds/weeds = locate() in T

	if(!weeds && !(xeno_caste.caste_flags & CASTE_INNATE_PLASMA_REGEN))
		hud_set_plasma() // since we used some plasma via the aura
		return

	var/plasma_gain = xeno_caste.plasma_gain

	if(lying_angle || resting)
		plasma_gain *= 2  // Doubled for resting

	plasma_gain *= weeds ? weeds.resting_buff : 1

	var/list/plasma_mod = list(plasma_gain)

	SEND_SIGNAL(src, COMSIG_XENOMORPH_PLASMA_REGEN, plasma_mod)

	gain_plasma(plasma_mod[1])
	hud_set_plasma() //update plasma amount on the plasma mob_hud

/mob/living/carbon/xenomorph/proc/handle_aura_emiter()
	//Rollercoaster of fucking stupid because Xeno life ticks aren't synchronised properly and values reset just after being applied
	//At least it's more efficient since only Xenos with an aura do this, instead of all Xenos
	//Basically, we use a special tally var so we don't reset the actual aura value before making sure they're not affected

	if(!current_aura && !leader_current_aura) //Gotta be emitting some pheromones to actually do something
		return

	if(on_fire) //Can't output pheromones if on fire
		return

	if(current_aura) //Plasma costs are already checked beforehand
		var/phero_range = round(6 + xeno_caste.aura_strength * 2) //Don't need to do the distance math over and over for each xeno
		if(isxenoqueen(src) && anchored) //stationary queen's pheromone apply around the observed xeno.
			var/mob/living/carbon/xenomorph/queen/Q = src
			if(Q.observed_xeno)
				//The reason why we don't check the hive of observed_xeno is just in case the watched xeno isn't of the same hive for whatever reason
				for(var/xenos in Q.hive.get_all_xenos())
					var/mob/living/carbon/xenomorph/Z = xenos
					if(get_dist(Q.observed_xeno, Z) <= phero_range && (Q.observed_xeno.z == Z.z) && !Z.on_fire) //We don't need to check to see if it's dead or if it's the same hive as the list we're pulling from only contain alive xenos of the same hive
						switch(current_aura)
							if("frenzy")
								if(xeno_caste.aura_strength > Z.frenzy_new)
									Z.frenzy_new = xeno_caste.aura_strength
							if("warding")
								if(xeno_caste.aura_strength > Z.warding_new)
									Z.warding_new = xeno_caste.aura_strength
							if("recovery")
								if(xeno_caste.aura_strength > Z.recovery_new)
									Z.recovery_new = xeno_caste.aura_strength

		else
			for(var/xenos in hive.get_all_xenos())
				var/mob/living/carbon/xenomorph/Z = xenos
				if(get_dist(src, Z) <= phero_range && (z == Z.z) && !Z.on_fire)
					switch(current_aura)
						if("frenzy")
							if(xeno_caste.aura_strength > Z.frenzy_new)
								Z.frenzy_new = xeno_caste.aura_strength
						if("warding")
							if(xeno_caste.aura_strength > Z.warding_new)
								Z.warding_new = xeno_caste.aura_strength
						if("recovery")
							if(xeno_caste.aura_strength > Z.recovery_new)
								Z.recovery_new = xeno_caste.aura_strength
	if(leader_current_aura)
		var/phero_range = round(6 + leader_aura_strength * 2)
		for(var/xenos in hive.get_all_xenos())
			var/mob/living/carbon/xenomorph/Z = xenos
			if(get_dist(src, Z) <= phero_range && (z == Z.z) && !Z.on_fire)
				switch(leader_current_aura)
					if("frenzy")
						if(leader_aura_strength > Z.frenzy_new)
							Z.frenzy_new = leader_aura_strength
					if("warding")
						if(leader_aura_strength > Z.warding_new)
							Z.warding_new = leader_aura_strength
					if("recovery")
						if(leader_aura_strength > Z.recovery_new)
							Z.recovery_new = leader_aura_strength

/mob/living/carbon/xenomorph/proc/handle_aura_receiver()
	if(frenzy_aura != frenzy_new || warding_aura != warding_new || recovery_aura != recovery_new)
		set_frenzy_aura(frenzy_new)
		if(warding_aura != warding_new)
			soft_armor = soft_armor.modifyAllRatings(-warding_aura * 2.5)
			warding_aura = warding_new
			soft_armor = soft_armor.modifyAllRatings(warding_aura * 2.5)
		else
			warding_aura = warding_new
		recovery_aura = recovery_new
	hud_set_pheromone()
	frenzy_new = 0
	warding_new = 0
	recovery_new = 0

/mob/living/carbon/xenomorph/handle_regular_hud_updates()
	if(!client)
		return FALSE

	// Sanity checks
	if(!maxHealth)
		stack_trace("[src] called handle_regular_hud_updates() while having [maxHealth] maxHealth.")
		return
	if(!xeno_caste.plasma_max)
		stack_trace("[src] called handle_regular_hud_updates() while having [xeno_caste.plasma_max] xeno_caste.plasma_max.")
		return

	// Health Hud
	if(hud_used && hud_used.healths)
		if(stat != DEAD)
			var/bucket = get_bucket(XENO_HUD_ICON_BUCKETS, maxHealth, health, get_crit_threshold(), list("full", "critical"))
			hud_used.healths.icon_state = "health[bucket]"
		else
			hud_used.healths.icon_state = "health_dead"

	// Plasma Hud
	if(hud_used && hud_used.alien_plasma_display)
		if(stat != DEAD)
			var/bucket = get_bucket(XENO_HUD_ICON_BUCKETS, xeno_caste.plasma_max, plasma_stored, 0, list("full", "empty"))
			hud_used.alien_plasma_display.icon_state = "power_display_[bucket]"
		else
			hud_used.alien_plasma_display.icon_state = "power_display_empty"


	interactee?.check_eye(src)

	return TRUE

/mob/living/carbon/xenomorph/proc/handle_environment() //unused while atmos is not on
	var/env_temperature = loc.return_temperature()
	if(!(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE))
		if(env_temperature > (T0C + 66))
			adjustFireLoss((env_temperature - (T0C + 66) ) * 0.2 * clamp(xeno_caste.fire_resist + fire_resist_modifier, 0, 1)) //Might be too high, check in testing.
			updatehealth() //unused while atmos is off
			if(hud_used && hud_used.fire_icon)
				hud_used.fire_icon.icon_state = "fire2"
			if(prob(20))
				to_chat(src, span_warning("We feel a searing heat!"))
		else
			if(hud_used && hud_used.fire_icon)
				hud_used.fire_icon.icon_state = "fire0"

/mob/living/carbon/xenomorph/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return
	health = maxHealth - getFireLoss() - getBruteLoss() //Xenos can only take brute and fire damage.
	med_hud_set_health()
	update_stat()
	update_wounds()

/mob/living/carbon/xenomorph/handle_slowdown()
	if(slowdown)
		#if DEBUG_XENO_LIFE
		world << span_debuginfo("Regen: Initial slowdown is: <b>[slowdown]</b>")
		#endif
		adjust_slowdown(-XENO_SLOWDOWN_REGEN)
		#if DEBUG_XENO_LIFE
		world << span_debuginfo("Regen: Final slowdown is: <b>[slowdown]</b>")
		#endif
	return slowdown

/mob/living/carbon/xenomorph/adjust_stagger(amount)
	if(is_charging >= CHARGE_ON) //If we're charging we don't accumulate more stagger stacks.
		return FALSE
	return ..()

/mob/living/carbon/xenomorph/proc/set_frenzy_aura(new_aura)
	if(frenzy_aura == new_aura)
		return
	frenzy_aura = new_aura
	if(frenzy_aura)
		add_movespeed_modifier(MOVESPEED_ID_FRENZY_AURA, TRUE, 0, NONE, TRUE, -frenzy_aura * 0.06)
		return
	remove_movespeed_modifier(MOVESPEED_ID_FRENZY_AURA)
