// ***************************************
// *********** Agility
// ***************************************
/datum/action/xeno_action/toggle_agility
	name = "Toggle Agility"
	action_icon_state = "agility_on"
	mechanics_text = "Move an all fours for greater speed. Cannot use abilities while in this mode."
	ability_name = "toggle agility"
	cooldown_timer = 0.5 SECONDS
	use_state_flags = XACT_USE_AGILITY
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_AGILITY
	var/last_agility_bonus = 0

/datum/action/xeno_action/toggle_agility/on_xeno_upgrade()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.agility)
		var/armor_change = X.xeno_caste.agility_speed_armor
		X.soft_armor = X.soft_armor.modifyAllRatings(armor_change)
		last_agility_bonus = armor_change
		X.add_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY , TRUE, 0, NONE, TRUE, X.xeno_caste.agility_speed_increase)

/datum/action/xeno_action/toggle_agility/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, "<span class='notice'>We can [X.agility ? "raise ourselves back up" : "lower ourselves back down"] again.</span>")
	return ..()

/datum/action/xeno_action/toggle_agility/action_activate()
	var/mob/living/carbon/xenomorph/X = owner

	X.agility = !X.agility

	GLOB.round_statistics.warrior_agility_toggles++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_agility_toggles")
	if(X.agility)
		to_chat(X, "<span class='xenowarning'>We lower ourselves to all fours and loosen our armored scales to ease our movement.</span>")
		X.add_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY , TRUE, 0, NONE, TRUE, X.xeno_caste.agility_speed_increase)
		var/armor_change = X.xeno_caste.agility_speed_armor
		X.soft_armor = X.soft_armor.modifyAllRatings(armor_change)
		last_agility_bonus = armor_change
	else
		to_chat(X, "<span class='xenowarning'>We raise ourselves to stand on two feet, hard scales setting back into place.</span>")
		X.remove_movespeed_modifier(MOVESPEED_ID_WARRIOR_AGILITY)
		X.soft_armor = X.soft_armor.modifyAllRatings(-last_agility_bonus)
		last_agility_bonus = 0
	X.update_icons()
	add_cooldown()
	return succeed_activate()

// ***************************************
// *********** Lunge
// ***************************************
/datum/action/xeno_action/activable/lunge
	name = "Lunge"
	action_icon_state = "lunge"
	mechanics_text = "Pounce up to 5 tiles and grab a target, knocking them down and putting them in your grasp."
	ability_name = "lunge"
	plasma_cost = 25
	cooldown_timer = 20 SECONDS
	keybind_signal = COMSIG_XENOABILITY_LUNGE
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/lunge/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We ready ourselves to lunge again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/activable/lunge/proc/neck_grab(mob/living/owner, mob/living/L)
	SIGNAL_HANDLER
	if(!can_use_ability(L, FALSE, XACT_IGNORE_DEAD_TARGET))
		return COMSIG_WARRIOR_CANT_NECKGRAB


/datum/action/xeno_action/activable/lunge/give_action(mob/living/L)
	. = ..()
	RegisterSignal(owner, COMSIG_WARRIOR_USED_GRAB, .proc/add_cooldown)
	RegisterSignal(owner, COMSIG_WARRIOR_NECKGRAB, .proc/neck_grab)


/datum/action/xeno_action/activable/lunge/remove_action(mob/living/L)
	UnregisterSignal(owner, COMSIG_WARRIOR_USED_GRAB)
	UnregisterSignal(owner, COMSIG_WARRIOR_NECKGRAB)
	return ..()


/datum/action/xeno_action/activable/lunge/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!isliving(A)) //We can only lunge at the living; expanded to xenos in order to allow for supportive applications; lunging > throwing to safety
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>We can't [name] at that!</span>")
		return FALSE

/datum/action/xeno_action/activable/lunge/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/lunge/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 2)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE

/datum/action/xeno_action/activable/lunge/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, "<span class='xenodanger'>We are ready to lunge again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/activable/lunge/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner

	GLOB.round_statistics.warrior_lunges++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_lunges")
	X.visible_message("<span class='xenowarning'>\The [X] lunges towards [A]!</span>", \
	"<span class='xenowarning'>We lunge at [A]!</span>")

	X.add_filter("warrior_lunge", 2, list("type" = "blur", 3))
	var/distance = get_dist(X, A)

	X.throw_at(get_step_towards(A, X), 6, 2, X)

	if(distance - 1 > 0) //No zero timers
		addtimer(CALLBACK(src, .proc/lunge_grab, X, A), min(0.1 SECONDS * max(0.01, distance - 1), 1 SECONDS)) //Minor delay so we're guaranteed to grab
	else
		lunge_grab(X,A)

	succeed_activate()
	add_cooldown()
	return TRUE

/datum/action/xeno_action/activable/lunge/proc/lunge_grab(mob/living/carbon/xenomorph/X, atom/A)
	if (X.Adjacent(A))
		X.swap_hand()
		X.start_pulling(A, TRUE)
		X.swap_hand()
		X.remove_filter("warrior_lunge")

// ***************************************
// *********** Fling
// ***************************************
/datum/action/xeno_action/activable/fling
	name = "Fling"
	action_icon_state = "fling"
	mechanics_text = "Knock a target flying up to 5 tiles away."
	ability_name = "fling"
	plasma_cost = 18
	cooldown_timer = 20 SECONDS //Shared cooldown with Grapple Toss
	keybind_signal = COMSIG_XENOABILITY_FLING
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/fling/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We gather enough strength to fling something again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/activable/fling/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

	if(!owner.Adjacent(A))
		return FALSE

	if(!isliving(A))
		return FALSE

/datum/action/xeno_action/activable/fling/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/victim = A
	var/facing = get_dir(X, victim)
	var/fling_distance = 4
	var/stun_duration = 0.5 SECONDS

	X.face_atom(victim) //Face towards the victim

	GLOB.round_statistics.warrior_flings++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_flings")

	X.visible_message("<span class='xenowarning'>\The [X] effortlessly flings [victim] away!</span>", \
	"<span class='xenowarning'>We effortlessly fling [victim] away!</span>")
	playsound(victim,'sound/weapons/alien_claw_block.ogg', 75, 1)

	if(victim.mob_size >= MOB_SIZE_BIG) //Penalize fling distance for big creatures
		fling_distance = FLOOR(fling_distance * 0.5, 1)

	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/x_victim
		if(X.issamexenohive(x_victim)) //We don't fuck up friendlies
			stun_duration = 0

	victim.ParalyzeNoChain(stun_duration)
	shake_camera(victim, 2, 1)

	var/turf/T = X.loc
	var/turf/temp = X.loc

	for (var/x in 1 to fling_distance)
		temp = get_step(T, facing)
		if (!temp)
			break
		T = temp
	X.do_attack_animation(victim, ATTACK_EFFECT_DISARM2)
	victim.throw_at(T, fling_distance, 1, X, 1)

	succeed_activate()
	add_cooldown()

	var/datum/action/xeno_action/activable/toss/throw_cooldown = locate(/datum/action/xeno_action/activable/toss) in X.xeno_abilities //Shared cooldown with Throw
	throw_cooldown.add_cooldown()

/datum/action/xeno_action/activable/fling/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/fling/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 1)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE

// ***************************************
// *********** Grapple Toss
// ***************************************
/datum/action/xeno_action/activable/toss
	name = "Grapple Toss"
	action_icon_state = "grapple_toss"
	mechanics_text = "Throw a creature you're grappling up to 5 tiles away."
	ability_name = "grapple toss"
	plasma_cost = 18
	cooldown_timer = 20 SECONDS //Shared cooldown with Fling
	keybind_signal = COMSIG_XENOABILITY_GRAPPLE_TOSS
	target_flags = XABB_TURF_TARGET

/datum/action/xeno_action/activable/toss/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We gather enough strength to toss something again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/activable/toss/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE

	if(!owner.pulling) //If we're not grappling something, we should be flinging something living and adjacent
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>We have nothing to toss!</span>")
		return FALSE

	if(!A)
		if(!silent)
			to_chat(owner, "<span class='xenodanger'>We can't toss [owner.pulling] there!</span>")
		return FALSE

/datum/action/xeno_action/activable/toss/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/atom/movable/target = owner.pulling
	var/facing = get_dir(X, A)
	var/fling_distance = 5
	var/stagger_slow_stacks = 3
	var/stun_duration = 1 SECONDS


	X.face_atom(A)

	GLOB.round_statistics.warrior_flings++ //I'm going to consider this a fling for the purpose of statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_flings")

	X.visible_message("<span class='xenowarning'>\The [X] throws [target] away!</span>", \
	"<span class='xenowarning'>We throw [target] away!</span>")
	playsound(target,'sound/weapons/alien_claw_block.ogg', 75, 1)

	if(isliving(target))
		var/mob/living/victim = target

		if(victim.mob_size >= MOB_SIZE_BIG) //Penalize fling distance for big creatures
			fling_distance = FLOOR(fling_distance * 0.5, 1)

		if(isxeno(victim))
			var/mob/living/carbon/xenomorph/x_victim
			if(X.issamexenohive(x_victim)) //We don't fuck up friendlies
				stagger_slow_stacks = 0
				stun_duration = 0

		victim.adjust_stagger(stagger_slow_stacks)
		victim.add_slowdown(stagger_slow_stacks)
		victim.adjust_blurriness(stagger_slow_stacks) //Cosmetic eye blur SFX
		victim.ParalyzeNoChain(stun_duration)
		shake_camera(victim, 2, 1)

	var/turf/T = X.loc
	var/turf/temp = X.loc

	for (var/x in 1 to fling_distance)
		temp = get_step(T, facing)
		if(locate(X) in temp) //Allows us to fluidly toss the target behind us
			target.forceMove(temp)
		if (!temp)
			break
		T = temp
	X.do_attack_animation(target, ATTACK_EFFECT_DISARM2)
	target.throw_at(T, fling_distance, 1, X, 1)

	succeed_activate()
	add_cooldown()

	var/datum/action/xeno_action/activable/fling/fling_cooldown = locate(/datum/action/xeno_action/activable/fling) in X.xeno_abilities //Shared cooldown with Fling
	fling_cooldown.add_cooldown()

// ***************************************
// *********** Punch
// ***************************************
/datum/action/xeno_action/activable/punch
	name = "Punch"
	action_icon_state = "punch"
	mechanics_text = "Strike a target up to 1 tile away, inflicting stamina damage, stagger and slowdown. Deals extra damage, stagger and slowdown to grappled targets."
	ability_name = "punch"
	plasma_cost = 12
	cooldown_timer = 10 SECONDS
	keybind_signal = COMSIG_XENOABILITY_PUNCH
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/punch/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, "<span class='xenodanger'>We gather enough strength to punch again.</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/activable/punch/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(A))
		return FALSE
	if(!owner.Adjacent(A))
		return FALSE
	var/mob/living/L = A
	if(L.stat == DEAD || isnestedhost(L)) //Can't bully the dead/nested hosts.
		return FALSE

/datum/action/xeno_action/activable/punch/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/M = A
	if(X.issamexenohive(M))
		X.changeNext_move(CLICK_CD_MELEE) // Add a delaay in to avoid spam
		return M.attack_alien(X) //harmless nibbling.

	GLOB.round_statistics.warrior_punches++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "warrior_punches")


	var/target_zone = check_zone(X.zone_selected)
	if(!target_zone)
		target_zone = "chest"
	var/damage = X.xeno_caste.melee_damage

	M.punch_act(X, damage, target_zone)


	succeed_activate()
	add_cooldown()


/mob/living/proc/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone)
	apply_damage(damage, BRUTE, target_zone, run_armor_check(target_zone))
	UPDATEHEALTH(src)

/mob/living/carbon/human/punch_act(mob/living/carbon/xenomorph/X, damage, target_zone)
	var/datum/limb/L = get_limb(target_zone)

	if (!L || (L.limb_status & LIMB_DESTROYED))
		to_chat(X, "<span class='xenodanger'>We can't punch that which doesn't exist!</span>")
		return FALSE

	var/stagger_stacks = 3
	var/slowdown_stacks = 3
	var/punch_description = "powerful"
	var/S = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')

	if(pulledby == X) //If we're being grappled by the Warrior punching us, it's gonna do extra damage and debuffs; combolicious
		damage *= 2
		slowdown_stacks *= 2
		stagger_stacks *= 2
		ParalyzeNoChain(0.5 SECONDS)
		punch_description = "devastating"

	playsound(src, S, 50, 1)
	X.face_atom(src) //Face the target so you don't look like an idiot
	X.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)

	X.visible_message("<span class='xenowarning'>\The [X] hits [src] in the [L.display_name] with a [punch_description] punch!</span>", \
		"<span class='xenowarning'>We hit [src] in the [L.display_name] with a [punch_description] punch!</span>", visible_message_flags = COMBAT_MESSAGE)

	if(L.limb_status & LIMB_SPLINTED) //If they have it splinted, the splint won't hold.
		L.remove_limb_flags(LIMB_SPLINTED)
		to_chat(src, "<span class='danger'>The splint on your [L.display_name] comes apart!</span>")

	L.take_damage_limb(damage, 0, FALSE, FALSE, run_armor_check(target_zone))

	adjust_stagger(stagger_stacks)
	add_slowdown(slowdown_stacks)
	adjust_blurriness(slowdown_stacks) //Cosmetic eye blur SFX

	apply_damage(damage, STAMINA) //Armor penetrating stamina also applies.
	shake_camera(src, 2, 1)

	X.do_attack_animation(src, ATTACK_EFFECT_DISARM2)

	var/facing = get_dir(X, src)
	if(src.loc == X.loc) //If they're sharing our location we still want to punch them away
		facing = X.dir

	var/turf/T = X.loc
	var/turf/temp = X.loc

	for (var/x in 1 to 2)
		temp = get_step(T, facing)
		if (!temp)
			break
		T = temp

	throw_at(T, 2, 1, X, 1) //Punch em away

	UPDATEHEALTH(src)
	return TRUE

/datum/action/xeno_action/activable/punch/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/punch/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 1)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE
