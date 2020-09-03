#define DEBUG_XENO_LIFE	0
#if DEBUG_XENO_LIFE
#define LIFE_DEBUG(msg) to_chat(world, "<span class='debuginfo'>[msg]</span>")
#else
#define LIFE_DEBUG(msg)
#endif
#define XENO_RESTING_HEAL 1.1
#define XENO_STANDING_HEAL 0.2
#define XENO_CRIT_DAMAGE 5

#define XENO_HUD_ICON_BUCKETS 16  // should equal the number of icons you use to represent health / plasma (from 0 -> X)

/mob/living/carbon/xenomorph/Life()
	if(!loc)
		return

	..()

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

	var/sunder_recov = xeno_caste.sunder_recover * -1
	if(resting)
		sunder_recov -= 0.5
	adjust_sunder(sunder_recov)
	handle_living_health_updates()
	handle_living_plasma_updates()
	update_action_button_icons()
	update_icons()
	LIFE_DEBUG("life update finished")


/mob/living/carbon/xenomorph/update_stat()
	. = ..()
	if(.)
		return

	//Deal with devoured things and people
	if(LAZYLEN(stomach_contents) && world.time > devour_timer && !is_ventcrawling)
		empty_gut()


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
		adjustFireLoss((fire_stacks + 3) * clamp(xeno_caste.fire_resist + fire_resist_modifier, 0, 1) ) // modifier is negative

/mob/living/carbon/xenomorph/proc/handle_living_health_updates()
	if(health < 0)
		handle_critical_health_updates()
		LIFE_DEBUG("critical health update")
		return
	if(health >= maxHealth || xeno_caste.hardcore || on_fire) //can't regenerate.
		updatehealth() //Update health-related stats, like health itself (using brute and fireloss), health HUD and status.
		LIFE_DEBUG("can't heal")
		return
	var/turf/T = loc
	if(!T || !istype(T))
		return
	var/ruler_healing_penalty = 0.5
	if(hive?.living_xeno_ruler?.loc?.z == T.z || xeno_caste.caste_flags & CASTE_CAN_HEAL_WITHOUT_QUEEN) //if the living queen's z-level is the same as ours.
		ruler_healing_penalty = 1
	var/heal_multi = ruler_healing_penalty
	if(!(locate(/obj/effect/alien/weeds) in T) && !(xeno_caste.caste_flags & CASTE_INNATE_HEALING))
		updatehealth()
		LIFE_DEBUG("No weeds, or self-healing.")
		return // We need weeds, or self healing...
	if(lying_angle || resting || xeno_caste.caste_flags & CASTE_QUICK_HEAL_STANDING)
		heal_multi *= XENO_RESTING_HEAL
	else
		heal_multi *= XENO_STANDING_HEAL
	heal_wounds(heal_multi)
	updatehealth()
	LIFE_DEBUG("normal health update of [heal_multi]")

/mob/living/carbon/xenomorph/proc/handle_critical_health_updates()
	var/turf/T = loc
	var/datum/status_effect/aura/warding/ward_aura = has_status_effect(STATUS_EFFECT_AURA_WARDING)
	var/warding_aura = ward_aura ? ward_aura.strength : 0
	if((istype(T) && locate(/obj/effect/alien/weeds) in T))
		LIFE_DEBUG("Healing critical wounds (weeds) for [XENO_RESTING_HEAL + warding_aura * 0.5]")
		heal_wounds(XENO_RESTING_HEAL + warding_aura * 0.5) //Warding pheromones provides 0.25 HP per second per step, up to 2.5 HP per tick.
	else
		LIFE_DEBUG("Healing critical wounds for [XENO_CRIT_DAMAGE - warding_aura]")
		adjustBruteLoss(XENO_CRIT_DAMAGE - warding_aura) //Warding can heavily lower the impact of bleedout. Halved at 2.5 phero, stopped at 5 phero
	updatehealth()

/mob/living/carbon/xenomorph/proc/heal_wounds(multiplier = XENO_RESTING_HEAL)
	var/datum/status_effect/aura/recov_aura = has_status_effect(STATUS_EFFECT_AURA_RECOVERY)
	var/recovery_aura = recov_aura ? recov_aura.strength : 0

	var/amount = (1 + (maxHealth * 0.03) ) // 1 damage + 3% max health
	if(recovery_aura)
		amount += recovery_aura * maxHealth * 0.008 // +0.8% max health per recovery level, up to +4%
	amount *= multiplier
	LIFE_DEBUG("Healing brute and fire for [-amount]")
	adjustBruteLoss(-amount)
	adjustFireLoss(-amount)

/mob/living/carbon/xenomorph/proc/handle_living_plasma_updates()
	var/turf/T = loc
	if(!T || !istype(T))
		return
	if(plasma_stored == xeno_caste.plasma_max)
		return

	var/datum/component/aura/emitter = GetComponent(/datum/component/aura)
	if(emitter && emitter.active)
		if(plasma_stored < 5)
			LIFE_DEBUG("Active aura, using all available plasma [plasma_stored]")
			use_plasma(plasma_stored)
			emitter.toggle_active(FALSE)
			to_chat(src, "<span class='warning'>We have run out of plasma and stopped emitting pheromones.</span>")
		else
			LIFE_DEBUG("Active aura, using 5 plasma")
			use_plasma(5)

	var/list/plasma_mod = list()

	SEND_SIGNAL(src, COMSIG_XENOMORPH_PLASMA_REGEN, plasma_mod)

	var/plasma_gain_multiplier = 1
	for(var/i in plasma_mod)
		plasma_gain_multiplier *= i

	if(!(locate(/obj/effect/alien/weeds) in T) && !(xeno_caste.caste_flags & CASTE_INNATE_PLASMA_REGEN))
		hud_set_plasma() // since we used some plasma via the aura
		return
	var/plasma_gain = xeno_caste.plasma_gain

	if(lying_angle || resting)
		plasma_gain *= 2  // Doubled for resting

	gain_plasma(plasma_gain * plasma_gain_multiplier)
	hud_set_plasma() //update plasma amount on the plasma mob_hud

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
			adjustFireLoss((env_temperature - (T0C + 66) ) * 0.2 * clamp(xeno_caste.fire_resist + fire_resist_modifier, 0, 1) ) //Might be too high, check in testing.
			updatehealth() //unused while atmos is off
			if(hud_used && hud_used.fire_icon)
				hud_used.fire_icon.icon_state = "fire2"
			if(prob(20))
				to_chat(src, "<span class='warning'>We feel a searing heat!</span>")
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
		LIFE_DEBUG("<span class='debuginfo'>Regen: Initial slowdown is: <b>[slowdown]</b></span>")
		adjust_slowdown(-XENO_SLOWDOWN_REGEN)
		LIFE_DEBUG("<span class='debuginfo'>Regen: Final slowdown is: <b>[slowdown]</b></span>")
	return slowdown

/mob/living/carbon/xenomorph/adjust_stagger(amount)
	if(is_charging >= CHARGE_ON) //If we're charging we don't accumulate more stagger stacks.
		return FALSE
	return ..()
