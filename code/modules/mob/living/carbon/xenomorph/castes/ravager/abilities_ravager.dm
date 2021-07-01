// ***************************************
// *********** Charge
// ***************************************
/datum/action/xeno_action/activable/charge
	name = "Eviscerating Charge"
	action_icon_state = "charge"
	mechanics_text = "Charge up to 4 tiles and viciously attack your target."
	ability_name = "charge"
	cooldown_timer = 20 SECONDS
	plasma_cost = 500 //Can't ignore pain/Charge and ravage in the same timeframe, but you can combo one of them.
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_RAVAGER_CHARGE

/datum/action/xeno_action/activable/charge/proc/charge_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_XENO_NONE_THROW_HIT, COMSIG_XENO_LIVING_THROW_HIT))

/datum/action/xeno_action/activable/charge/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/ravager/X = owner
	if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack))
		var/obj/structure/S = target
		X.visible_message("<span class='danger'>[X] plows straight through [S]!</span>", null, null, 5)
		S.deconstruct(FALSE) //We want to continue moving, so we do not reset throwing.
		return //stay registered
	else
		target.hitby(X, speed) //This resets throwing.
	charge_complete()

/datum/action/xeno_action/activable/charge/proc/mob_hit(datum/source, mob/M)
	SIGNAL_HANDLER
	if(M.stat || isxeno(M))
		return
	return COMPONENT_KEEP_THROWING //Ravagers plow straight through humans; we only stop on hitting a dense turf

/datum/action/xeno_action/activable/charge/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE

/datum/action/xeno_action/activable/charge/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>Our exoskeleton quivers as we get ready to use Eviscerating Charge again.</span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	var/mob/living/carbon/xenomorph/ravager/X = owner
	X.usedPounce = FALSE
	return ..()

/datum/action/xeno_action/activable/charge/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	RegisterSignal(X, COMSIG_XENO_OBJ_THROW_HIT, .proc/obj_hit)
	RegisterSignal(X, COMSIG_XENO_NONE_THROW_HIT, .proc/charge_complete)
	RegisterSignal(X, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)

	X.visible_message("<span class='danger'>[X] charges towards \the [A]!</span>", \
	"<span class='danger'>We charge towards \the [A]!</span>" )
	X.emote("roar") //heheh
	X.usedPounce = TRUE //This has to come before throw_at, which checks impact. So we don't do end-charge specials when thrown
	succeed_activate()

	X.throw_at(A, RAV_CHARGEDISTANCE, RAV_CHARGESPEED, X)

	add_cooldown()

/datum/action/xeno_action/activable/charge/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/charge/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 4)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE


// ***************************************
// *********** Ravage
// ***************************************
/datum/action/xeno_action/activable/ravage
	name = "Ravage"
	action_icon_state = "ravage"
	mechanics_text = "Attacks and knockbacks enemies in the direction your facing."
	ability_name = "ravage"
	plasma_cost = 200
	cooldown_timer = 6 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY | XACT_IGNORE_SELECTED_ABILITY
	keybind_signal = COMSIG_XENOABILITY_RAVAGE
	alternate_keybind_signal = COMSIG_XENOABILITY_RAVAGE_SELECT

/datum/action/xeno_action/activable/ravage/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We gather enough strength to Ravage again.</span>")
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	return ..()

/datum/action/xeno_action/activable/ravage/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/ravager/X = owner

	X.emote("roar")
	X.visible_message("<span class='danger'>\The [X] thrashes about in a murderous frenzy!</span>", \
	"<span class='xenowarning'>We thrash about in a murderous frenzy!</span>")

	X.face_atom(A)
	var/sweep_range = 1
	var/list/L = orange(sweep_range, X) // Not actually the fruit
	var/victims = 0
	var/target_facing
	for(var/mob/living/carbon/human/H in L)
		if(victims >= 3) //Max 3 victims
			break
		target_facing = get_dir(X, H)
		if(target_facing != X.dir && target_facing != turn(X.dir,45) && target_facing != turn(X.dir,-45) ) //Have to be actually facing the target
			continue
		if(H.stat != DEAD && !isnestedhost(H)) //No bully
			H.attack_alien_harm(X, X.xeno_caste.melee_damage * 0.25, FALSE, TRUE, FALSE, TRUE)
			victims++
			step_away(H, X, sweep_range, 2)
			shake_camera(H, 2, 1)
			H.Paralyze(1 SECONDS)

	succeed_activate()
	add_cooldown()


/datum/action/xeno_action/activable/ravage/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/ravage/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 1)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE


// ***************************************
// *********** Endure
// ***************************************
/datum/action/xeno_action/endure
	name = "Endure"
	action_icon_state = "ignore_pain"
	mechanics_text = "For the next few moments you will not go into crit and become resistant to explosives and immune to stagger and slowdown, but you still die if you take damage exceeding your crit health."
	ability_name = "Endure"
	plasma_cost = 200
	cooldown_timer = 60 SECONDS
	keybind_signal = COMSIG_XENOABILITY_ENDURE
	use_state_flags = XACT_USE_STAGGERED //Can use this while staggered

/datum/action/xeno_action/endure/on_cooldown_finish()
	to_chat(owner, "<span class='xenodanger'>We feel able to imbue ourselves with plasma to Endure once again!</span>")
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	return ..()

/datum/action/xeno_action/endure/action_activate()
	var/mob/living/carbon/xenomorph/ravager/X = owner

	X.emote("roar")
	X.visible_message("<span class='danger'>\The skin on the [X] begins to glow!</span>", \
	"<span class='xenowarning'>We feel the plasma coursing through our veins!</span>")

	X.endure = TRUE

	X.add_filter("ravager_endure_outline", 4, outline_filter(1, COLOR_PURPLE)) //Set our cool aura; also confirmation we have the buff

	addtimer(CALLBACK(src, .proc/endure_warning), RAVAGER_ENDURE_DURATION * RAVAGER_ENDURE_DURATION_WARNING) //Warn the runner when the duration is about to expire.
	addtimer(CALLBACK(src, .proc/endure_deactivate), RAVAGER_ENDURE_DURATION)

	X.stagger = 0 //Remove stagger
	X.set_slowdown(0) //Remove slowdown
	X.soft_armor = X.soft_armor.setRating(bomb = XENO_BOMB_RESIST_3) //Improved explosion resistance
	ADD_TRAIT(X, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT) //Can now endure impacts/damages that would make lesser xenos flinch
	ADD_TRAIT(X, TRAIT_SLOWDOWNIMMUNE, ENDURE_TRAIT) //Can now endure slowdown

	RegisterSignal(X, COMSIG_XENOMORPH_TAKING_DAMAGE, .proc/damage_taken) //Warns us if our health is critically low

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.ravager_endures++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "ravager_endures")

///Warns the player when Endure is about to end
/datum/action/xeno_action/endure/proc/endure_warning()
	to_chat(owner,"<span class='highdanger'>We feel the plasma draining from our veins... [ability_name] will last for only [RAVAGER_ENDURE_DURATION * (1-RAVAGER_ENDURE_DURATION_WARNING) * 0.1] more seconds!</span>")
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Turns off the Endure buff
/datum/action/xeno_action/endure/proc/endure_deactivate()
	var/mob/living/carbon/xenomorph/X = owner

	UnregisterSignal(X, COMSIG_XENOMORPH_TAKING_DAMAGE)

	X.do_jitter_animation(1000)
	X.endure = FALSE
	X.remove_filter("ravager_endure_outline")
	if(X.health < X.get_crit_threshold()) //If we have less health than our death threshold, but more than our Endure death threshold, set our HP to just a hair above insta dying
		var/total_damage = X.getFireLoss() + X.getBruteLoss()
		var/burn_percentile_damage = X.getFireLoss() / total_damage
		var/brute_percentile_damage = X.getBruteLoss() / total_damage
		X.setBruteLoss((X.xeno_caste.max_health - X.get_crit_threshold()-1) * brute_percentile_damage)
		X.setFireLoss((X.xeno_caste.max_health - X.get_crit_threshold()-1) * burn_percentile_damage)

	X.soft_armor = X.soft_armor.setRating(bomb = XENO_BOMB_RESIST_1) //Remove resistances/immunities
	REMOVE_TRAIT(X, TRAIT_STAGGERIMMUNE, ENDURE_TRAIT)
	REMOVE_TRAIT(X, TRAIT_SLOWDOWNIMMUNE, ENDURE_TRAIT)

	to_chat(owner,"<span class='highdanger'>The last of the plasma drains from our body... We can no longer endure beyond our normal limits!</span>")
	owner.playsound_local(owner, 'sound/voice/hiss4.ogg', 50, 0, 1)

///Warns us when our health is critically low and tells us exactly how much more punishment we can take
/datum/action/xeno_action/endure/proc/damage_taken(mob/living/carbon/xenomorph/X, damage_taken)
	SIGNAL_HANDLER
	if(X.health < 0)
		to_chat(X, "<span class='xenohighdanger' style='color: red;'>We are critically wounded! We can only withstand [(RAVAGER_ENDURE_HP_LIMIT-X.health) * -1] more damage before we perish!</span>")


/datum/action/xeno_action/endure/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/endure/ai_should_use(target)
	var/mob/living/carbon/xenomorph/ravager/X = owner
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > WORLD_VIEW_NUM) // If we can be seen.
		return ..()
	if(X.health > 50)
		return ..()
	if(!can_use_action(override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE
