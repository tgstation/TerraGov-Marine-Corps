/mob/living/carbon/xenomorph/ravager
	caste_base_type = /mob/living/carbon/xenomorph/ravager
	name = "Ravager"
	desc = "A huge, nasty red alien with enormous scythed claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Ravager Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16
	old_x = -16
	//Ravager vars
	var/rage = 0
	var/last_rage = null
	var/next_damage = null


// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/ravager/Initialize(mapload, can_spawn_in_centcomm)
	. = ..()
	RegisterSignal(src, list(
		COMSIG_XENOMORPH_BRUTE_DAMAGE,
		COMSIG_XENOMORPH_BURN_DAMAGE), 
		.proc/process_rage_damage)

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/ravager/movement_delay()
	. = ..()

	if(rage)
		. -= round(rage * 0.012,0.01) //Ravagers gain 0.016 units of speed per unit of rage; min -0.012, max -0.6

/mob/living/carbon/xenomorph/ravager/Bump(atom/A)
	if(!throwing || !usedPounce || !throw_source || !thrower) //Must currently be charging to knock aside and slice marines in it's path
		return ..() //It's not pouncing; do regular Bump() IE body block but not throw_impact() because ravager isn't being thrown
	if(!ishuman(A)) //Must also be a human; regular Bump() will default to throw_impact() which means ravager will plow through tables but get stopped by cades and walls
		return ..()
	var/mob/living/carbon/human/H = A
	var/extra_dam = xeno_caste.melee_damage * (1 + round(rage * 0.04) ) //+4% bonus damage per point of Rage.relative to base melee damage.
	H.attack_alien(src,  extra_dam, FALSE, TRUE, FALSE, TRUE, INTENT_HARM) //Location is always random, cannot crit, harm only
	var/target_turf = get_step_away(src, H, rand(1, 3)) //This is where we blast our target
	target_turf =  get_step_rand(target_turf) //Scatter
	H.throw_at(get_turf(target_turf), RAV_CHARGEDISTANCE, RAV_CHARGESPEED, H)
	H.knock_down(1)
	rage = 0
	return

/mob/living/carbon/xenomorph/ravager/handle_status_effects()
	if(rage) //Rage increases speed, attack speed, armor and fire resistance, and stun/knockdown recovery; speed is handled under movement_delay() in XenoProcs.dm
		rage = CLAMP(rage,0,50)
		adjust_stunned( round(-rage * 0.1,0.01) ) //Recover 0.1 more stun stacks per unit of rage; min 0.1, max 5
		adjust_knocked_down( round(-rage * 0.1, 0.01 ) ) //Recover 0.1 more knockdown stacks per unit of rage; min 0.1, max 5
		adjust_slowdown( round(-rage * 0.1,0.01) ) //Recover 0.1 more stagger stacks per unit of rage; min 0.1, max 5
		adjust_stagger( round(-rage * 0.1,0.01) ) //Recover 0.1 more stagger stacks per unit of rage; min 0.1, max 5
		attack_delay = initial(attack_delay) - round(rage * 0.05,0.01) //-0.05 attack delay to a maximum reduction of -2.5
	return ..()

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/ravager/Stat()
	. = ..()

	if(statpanel("Stats"))
		stat(null, "Rage: [rage] / [RAVAGER_MAX_RAGE]")

// ***************************************
// *********** Rage
// ***************************************
/mob/living/carbon/xenomorph/ravager/proc/process_rage_damage(datum/source, damage, list/damage_mod)
	if(damage < 1 || cooldowns[COOLDOWN_RAV_NEXT_DAMAGE])
		return
	rage += round(damage * RAV_DAMAGE_RAGE_MULITPLIER)
	
	cooldowns[COOLDOWN_RAV_NEXT_DAMAGE] = addtimer(VARSET_LIST_CALLBACK(cooldowns, COOLDOWN_RAV_NEXT_DAMAGE, null), 0.2 SECONDS)  // Limit how often this proc can trigger; once per 0.2 seconds
