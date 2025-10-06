#define DEBUG_XENO_LIFE 0
#define XENO_RESTING_HEAL 1.1
#define XENO_STANDING_HEAL 0.2
#define XENO_CRIT_DAMAGE 5

/mob/living/carbon/xenomorph/Life(seconds_per_tick, times_fired)

	if(!loc)
		return

	..()

	if(notransform) //If we're in true stasis don't bother processing life
		return

	if(stat == DEAD)
		SSmobs.stop_processing(src)
		return
	if(stat == UNCONSCIOUS)
		if(xeno_flags & XENO_ZOOMED)
			zoom_out()
	else
		if(xeno_flags & XENO_ZOOMED && loc != zoom_turf)
			zoom_out()
		update_progression(seconds_per_tick)
		update_evolving(seconds_per_tick)

	handle_living_sunder_updates(seconds_per_tick)
	handle_living_health_updates(seconds_per_tick)
	handle_living_plasma_updates(seconds_per_tick)
	update_action_button_icons()
	update_icons(FALSE)

/mob/living/carbon/xenomorph/handle_fire()
	. = ..()
	if(.)
		if(resting && fire_stacks > 0)
			adjust_fire_stacks(-1)	//Passively lose firestacks when not on fire while resting and having firestacks built up.
		return
	if(!(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE) && on_fire) //Sanity check; have to be on fire to actually take the damage.
		apply_damage((fire_stacks + 3), BURN, blocked = FIRE)

/mob/living/carbon/xenomorph/proc/handle_living_health_updates(seconds_per_tick)
	if(health < 0)
		handle_critical_health_updates(seconds_per_tick)
		return
	if((health >= maxHealth) || on_fire) //can't regenerate.
		return
	var/turf/T = loc
	if(!istype(T))
		return

	var/ruler_healing_penalty = 0.5
	if(hive?.living_xeno_ruler?.loc?.z == T.z || xeno_caste.can_flags & CASTE_CAN_HEAL_WITHOUT_QUEEN || (SSticker?.mode.round_type_flags & MODE_XENO_RULER)) //if the living queen's z-level is the same as ours.
		ruler_healing_penalty = 1
	if(loc_weeds_type || HAS_TRAIT(src, TRAIT_INNATE_HEALING)) //We regenerate on weeds or can on our own.
		if(lying_angle || resting || xeno_caste.caste_flags & CASTE_QUICK_HEAL_STANDING)
			heal_wounds(XENO_RESTING_HEAL * ruler_healing_penalty * loc_weeds_type ? initial(loc_weeds_type.resting_buff) : 1, TRUE, seconds_per_tick)
		else
			heal_wounds(XENO_STANDING_HEAL * ruler_healing_penalty, TRUE, seconds_per_tick) //Major healing nerf if standing.
	updatehealth()

///Handles sunder modification/recovery during life.dm for xenos
/mob/living/carbon/xenomorph/proc/handle_living_sunder_updates(seconds_per_tick)

	if(!sunder || on_fire) //No sunder, no problem; or we're on fire and can't regenerate.
		return

	var/sunder_recov = xeno_caste.sunder_recover * -0.5 * seconds_per_tick * XENO_PER_SECOND_LIFE_MOD //Baseline

	if(resting) //Resting doubles sunder recovery
		sunder_recov *= 2

	if(ispath(loc_weeds_type, /obj/alien/weeds/resting)) //Resting weeds double sunder recovery
		sunder_recov *= 2

	if(recovery_aura)
		sunder_recov *= 1 + recovery_aura * 0.1 //10% bonus per rank of recovery aura

	SEND_SIGNAL(src, COMSIG_XENOMORPH_SUNDER_REGEN, seconds_per_tick)

	adjust_sunder(sunder_recov)

/mob/living/carbon/xenomorph/proc/handle_critical_health_updates(seconds_per_tick)
	if(loc_weeds_type)
		heal_wounds(XENO_RESTING_HEAL, FALSE, seconds_per_tick) // healing in critical while on weeds ignores scaling
	else if(!endure) //If we're not Enduring we bleed out
		adjustBruteLoss(XENO_CRIT_DAMAGE * seconds_per_tick * XENO_PER_SECOND_LIFE_MOD)

/mob/living/carbon/xenomorph/proc/heal_wounds(multiplier = XENO_RESTING_HEAL, scaling = FALSE, seconds_per_tick = 2)
	var/amount = 1 + (maxHealth * 0.0375) // 1 damage + 3.75% max health, with scaling power.
	if(recovery_aura)
		amount += recovery_aura * maxHealth * 0.01 // +1% max health per recovery level, up to +5%
	if(scaling)
		var/time_modifier = seconds_per_tick * XENO_PER_SECOND_LIFE_MOD
		if(recovery_aura)
			regen_power = clamp(regen_power + xeno_caste.regen_ramp_amount * time_modifier * 30, 0, 1) //Ignores the cooldown, and gives a 50% boost.
		else if(regen_power < 0) // We're not supposed to regenerate yet. Start a countdown for regeneration.
			regen_power = (regen_power + seconds_per_tick SECONDS >= 0) ? 0 : regen_power + seconds_per_tick SECONDS
			return
		else
			regen_power = min(regen_power + xeno_caste.regen_ramp_amount * time_modifier * 20, 1)
		amount *= regen_power
	amount *= multiplier * GLOB.xeno_stat_multiplicator_buff * seconds_per_tick * XENO_PER_SECOND_LIFE_MOD

	var/list/heal_data = list(amount, amount)
	SEND_SIGNAL(src, COMSIG_XENOMORPH_HEALTH_REGEN, heal_data, seconds_per_tick)
	HEAL_XENO_DAMAGE(src, heal_data[1], TRUE)
	return heal_data // [1] = amount of unused healing, [2] = raw healing

/mob/living/carbon/xenomorph/proc/handle_living_plasma_updates(seconds_per_tick)
	var/turf/T = loc
	if(!istype(T)) //This means plasma doesn't update while you're in things like a vent, but since you don't have weeds in a vent or can actually take advantage of pheros, this is fine
		return

	if(!current_aura && (plasma_stored >= xeno_caste.plasma_max * xeno_caste.plasma_regen_limit)) //no loss or gain
		return

	if(current_aura)
		if(plasma_stored < pheromone_cost)
			use_plasma(plasma_stored, FALSE)
			QDEL_NULL(current_aura)
			src.balloon_alert(src, "no plasma, emitting stopped!")
		else
			use_plasma(pheromone_cost * seconds_per_tick * XENO_PER_SECOND_LIFE_MOD, FALSE)

	if(HAS_TRAIT(src, TRAIT_NOPLASMAREGEN) || !loc_weeds_type && !(xeno_caste.caste_flags & CASTE_INNATE_PLASMA_REGEN))
		if(current_aura) //we only need to update if we actually used plasma from pheros
			hud_set_plasma()
		return

	var/plasma_gain = xeno_caste.plasma_gain

	if(lying_angle || resting)
		plasma_gain *= 2  // Doubled for resting

	plasma_gain *= loc_weeds_type ? initial(loc_weeds_type.resting_buff) : 1

	plasma_gain *= seconds_per_tick * XENO_PER_SECOND_LIFE_MOD

	var/list/plasma_mod = list(plasma_gain)

	SEND_SIGNAL(src, COMSIG_XENOMORPH_PLASMA_REGEN, plasma_mod, seconds_per_tick)

	plasma_mod[1] = clamp(plasma_mod[1], 0, xeno_caste.plasma_max * xeno_caste.plasma_regen_limit - plasma_stored)

	gain_plasma(plasma_mod[1])

/mob/living/carbon/xenomorph/can_receive_aura(aura_type, atom/source, datum/aura_bearer/bearer)
	. = ..()
	if(!(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE) && on_fire) //Xenos on fire cannot receive pheros.
		return FALSE

/mob/living/carbon/xenomorph/finish_aura_cycle()
	if(!(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE) && on_fire) //Has to be here to prevent desyncing between phero and life, despite making more sense in handle_fire()
		if(current_aura)
			current_aura.suppressed = TRUE
		if(leader_current_aura)
			leader_current_aura.suppressed = TRUE

	if(frenzy_aura != (received_auras[AURA_XENO_FRENZY] || 0))
		set_frenzy_aura(received_auras[AURA_XENO_FRENZY] || 0)

	if(warding_aura != (received_auras[AURA_XENO_WARDING] || 0))
		if(warding_aura) //If either the new or old warding is 0, we can skip adjusting armor for it.
			soft_armor = soft_armor.modifyAllRatings(-warding_aura * 2.5)
		warding_aura = received_auras[AURA_XENO_WARDING] || 0
		if(warding_aura)
			soft_armor = soft_armor.modifyAllRatings(warding_aura * 2.5)

	recovery_aura = received_auras[AURA_XENO_RECOVERY] || 0

	hud_set_pheromone()
	..()

/mob/living/carbon/xenomorph/handle_regular_hud_updates()
	return

/mob/living/carbon/xenomorph/proc/handle_environment() //unused while atmos is not on
	var/env_temperature = loc.return_temperature()
	if(!(xeno_caste.caste_flags & CASTE_FIRE_IMMUNE))
		if(env_temperature > (T0C + 66))
			apply_damage(((env_temperature - (T0C + 66) ) * 0.2), BURN, blocked = FIRE)
			updatehealth() //unused while atmos is off
			throw_alert(ALERT_FIRE, /atom/movable/screen/alert/fire)
			if(prob(20))
				to_chat(src, span_warning("We feel a searing heat!"))
		else
			clear_alert(ALERT_FIRE)

/mob/living/carbon/xenomorph/updatehealth()
	. = ..()
	if(!. || QDELING(src)) // For godmode / if they got gibbed via update_stat.
		return
	med_hud_set_health() // Todo: Make all damage update health so we can just kill pointless life updates entirely.
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

/mob/living/carbon/xenomorph/proc/set_frenzy_aura(new_aura)
	if(frenzy_aura == new_aura)
		return
	frenzy_aura = new_aura
	if(frenzy_aura)
		add_movespeed_modifier(MOVESPEED_ID_FRENZY_AURA, TRUE, 0, NONE, TRUE, -frenzy_aura * 0.06)
		return
	remove_movespeed_modifier(MOVESPEED_ID_FRENZY_AURA)
