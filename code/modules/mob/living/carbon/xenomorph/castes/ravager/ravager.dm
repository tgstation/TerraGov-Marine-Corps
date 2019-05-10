/mob/living/carbon/Xenomorph/Ravager
	caste_base_type = /mob/living/carbon/Xenomorph/Ravager
	name = "Ravager"
	desc = "A huge, nasty red alien with enormous scythed claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Ravager Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	xeno_explosion_resistance = 1 //can't be gibbed from explosions
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16
	old_x = -16
	//Ravager vars
	var/rage = 0
	var/rage_resist = 1.00
	var/last_rage = null
	var/last_damage = null

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/activable/charge,
		/datum/action/xeno_action/activable/ravage,
		/datum/action/xeno_action/activable/second_wind,
		)

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/Xenomorph/Ravager/movement_delay()
	. = ..()

	if(rage)
		. -= round(rage * 0.012,0.01) //Ravagers gain 0.016 units of speed per unit of rage; min -0.012, max -0.6

/mob/living/carbon/Xenomorph/Ravager/Bump(atom/A)
	if(!throwing || !usedPounce || !throw_source || !thrower) //Must currently be charging to knock aside and slice marines in it's path
		return ..() //It's not pouncing; do regular Bump() IE body block but not throw_impact() because ravager isn't being thrown
	if(!ishuman(A)) //Must also be a human; regular Bump() will default to throw_impact() which means ravager will plow through tables but get stopped by cades and walls
		return ..()
	var/mob/living/carbon/human/H = A
	var/extra_dam = rand(xeno_caste.melee_damage_lower, xeno_caste.melee_damage_upper) * (1 + round(rage * 0.04) ) //+4% bonus damage per point of Rage.relative to base melee damage.
	H.attack_alien(src,  extra_dam, FALSE, TRUE, FALSE, TRUE, INTENT_HARM) //Location is always random, cannot crit, harm only
	var/target_turf = get_step_away(src, H, rand(1, 3)) //This is where we blast our target
	target_turf =  get_step_rand(target_turf) //Scatter
	H.throw_at(get_turf(target_turf), RAV_CHARGEDISTANCE, RAV_CHARGESPEED, H)
	H.KnockDown(1)
	rage = 0
	return

/mob/living/carbon/Xenomorph/Ravager/handle_status_effects()
	if(rage) //Rage increases speed, attack speed, armor and fire resistance, and stun/knockdown recovery; speed is handled under movement_delay() in XenoProcs.dm
		if(world.time > last_rage + 30) //Decrement Rage if it's been more than 3 seconds since we last raged.
			rage = CLAMP(rage - 5,0,50) //Rage declines over time.
		AdjustStunned( round(-rage * 0.1,0.01) ) //Recover 0.1 more stun stacks per unit of rage; min 0.1, max 5
		AdjustKnockeddown( round(-rage * 0.1, 0.01 ) ) //Recover 0.1 more knockdown stacks per unit of rage; min 0.1, max 5
		adjust_slowdown( round(-rage * 0.1,0.01) ) //Recover 0.1 more stagger stacks per unit of rage; min 0.1, max 5
		adjust_stagger( round(-rage * 0.1,0.01) ) //Recover 0.1 more stagger stacks per unit of rage; min 0.1, max 5
		rage_resist = CLAMP(1-round(rage * 0.014,0.01),0.3,1) //+1.4% damage resist per point of rage, max 70%
		fire_resist_modifier = CLAMP(round(rage * -0.01,0.01),-0.5,0) //+1% fire resistance per stack of rage, max +50%; initial resist is 50%
		attack_delay = initial(attack_delay) - round(rage * 0.05,0.01) //-0.05 attack delay to a maximum reduction of -2.5
	return ..()

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/Xenomorph/Ravager/Stat()
	. = ..()

	if(statpanel("Stats"))
		stat(null, "Rage: [rage] / [RAVAGER_MAX_RAGE]")

// ***************************************
// *********** Rage
// ***************************************
/mob/living/carbon/Xenomorph/Ravager/process_rage_damage(damage)
	if(damage < 1 || world.time < last_damage)
		return damage
	rage += round(damage * RAV_DAMAGE_RAGE_MULITPLIER)
	last_rage = world.time //We incremented rage, so bookmark this.
	last_damage = world.time + 2 //Limit how often this proc can trigger; once per 0.2 seconds
	damage *= rage_resist //reduce damage by rage resist %
	rage_resist = CLAMP(1-round(rage * 0.014,0.01),0.3,1) //Update rage resistance _after_ we take damage
	return damage

/mob/living/carbon/Xenomorph/Ravager/process_ravager_charge(hit = TRUE, mob/living/carbon/M = null)
	if(hit)
		var/extra_dam = rand(xeno_caste.melee_damage_lower, xeno_caste.melee_damage_upper) * (1 + round(rage * 0.04) ) //+4% bonus damage per point of Rage.relative to base melee damage.
		M.attack_alien(src,  extra_dam, FALSE, TRUE, FALSE, TRUE, INTENT_HARM) //Location is always random, cannot crit, harm only
		var/target_turf = get_step_away(src,M,rand(1,3)) //This is where we blast our target
		target_turf =  get_step_rand(target_turf) //Scatter
		throw_at(get_turf(target_turf), RAV_CHARGEDISTANCE, RAV_CHARGESPEED, M)
		M.KnockDown(1)
		rage = 0
	else
		rage *= 0.5 //Halve rage instead of 0ing it out if we miss.

/mob/living/carbon/Xenomorph/Ravager/process_rage_attack()
	rage += RAV_RAGE_ON_HIT
	last_rage = world.time //We incremented rage, so bookmark this.


