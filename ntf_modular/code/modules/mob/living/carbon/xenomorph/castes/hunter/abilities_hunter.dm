//assassin things

// ***************************************
// *********** Lunge
// ***************************************

/datum/action/ability/activable/xeno/pounce/lunge
	name = "Lunge"
	action_icon = 'icons/Xeno/actions/hunter.dmi'
	action_icon_state = "assassin_lunge"
	desc = "Swiftly lunge at your destination, if on a target, attack them."
	ability_cost = 10
	cooldown_duration = 6 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HUNTER_LUNGE,
	)
	use_state_flags = ABILITY_USE_BUCKLED

//Triggers the effect of a successful pounce on the target.
/datum/action/ability/activable/xeno/pounce/lunge/trigger_pounce_effect(mob/living/living_target)
	playsound(get_turf(living_target), 'sound/voice/alien/roar4.ogg', 25, TRUE)
	var/mob/living/carbon/xenomorph/xeno_owner = owner
	xeno_owner.UnarmedAttack(living_target)
	step_away(living_target, xeno_owner, 1, 3)
	xeno_owner.face_atom(living_target)

#define ASSASSIN_SNEAK_SLASH_ARMOR_PEN 30

// ***************************************
// *********** Phase Out
// ***************************************

/datum/action/ability/xeno_action/stealth/phaseout
	name = "Phase Out"
	action_icon_state = "hunter_invisibility"
	action_icon = 'icons/Xeno/actions/hunter.dmi'
	desc = "Become fully invisible for 6 seconds, or until damaged. Attacking does not break invisibility."
	ability_cost = 10
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOGGLE_PHASEOUT,
	)
	cooldown_duration = 6 SECONDS
	var/stealth_duration = 6 SECONDS
	disable_on_signals = list(
		COMSIG_LIVING_IGNITED,
		COMSIG_LIVING_ADD_VENTCRAWL,
	)
	stealth_flags = DIS_POUNCE_SLASH
	sneak_attack_armor_pen = ASSASSIN_SNEAK_SLASH_ARMOR_PEN

///Updates or cancels stealth
/datum/action/ability/xeno_action/stealth/phaseout/handle_stealth()
	var/mob/living/carbon/xenomorph/xenoowner = owner
	xenoowner.alpha = HUNTER_STEALTH_STILL_ALPHA * stealth_alpha_multiplier // instant full stealth regardless of movement.
/datum/action/ability/xeno_action/stealth/phaseout/action_activate()
	. = ..()
	if(stealth_duration != -1)
		stealth_timer = addtimer(CALLBACK(src, PROC_REF(cancel_stealth)), stealth_duration, TIMER_STOPPABLE)

///Duration for the mark.
#define DEATH_MARK_TIMEOUT 15 SECONDS
///Charge-up duration of the mark where you need to stay still for it to apply.
#define DEATH_MARK_CHARGEUP 2 SECONDS

// ***************************************
// *********** Death Mark
// ***************************************
/datum/action/ability/activable/xeno/hunter_mark/assassin
	name = "Death Mark"
	action_icon_state = "death_mark"
	action_icon = 'icons/Xeno/actions/hunter.dmi'
	desc = "Psionically disturb a creature for 15 seconds, allowing you to deal a stronger sneak attack. They will know you are coming for them."
	ability_cost = 50
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_HUNTER_MARK,
	)
	cooldown_duration = 30 SECONDS
	require_los = FALSE

/datum/action/ability/activable/xeno/hunter_mark/assassin/can_use_ability(atom/A, silent = FALSE, override_flags)
	var/mob/living/carbon/xenomorph/X = owner
	if(require_los && !line_of_sight(X, A)) //Need line of sight.
		if(!silent)
			to_chat(X, span_xenowarning("We require line of sight to mark them!"))
		return FALSE
	return ..()


/datum/action/ability/activable/xeno/hunter_mark/assassin/use_ability(atom/A)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	if(!do_after(X, DEATH_MARK_CHARGEUP, IGNORE_TARGET_LOC_CHANGE, A, BUSY_ICON_HOSTILE, NONE, PROGRESS_GENERIC))
		return

	RegisterSignal(marked_target, COMSIG_QDELETING, PROC_REF(unset_target)) //For var clean up

	to_chat(X, span_xenodanger("We will be able to maintain the mark for [DEATH_MARK_TIMEOUT / 10] seconds."))
	addtimer(CALLBACK(src, PROC_REF(unset_target)), DEATH_MARK_TIMEOUT)

	playsound(marked_target, 'sound/effects/alien/new_larva.ogg', 50, 0, 1)
	to_chat(marked_target, span_danger("You feel uneasy."))

///Nulls the target of our hunter's mark
/datum/action/ability/activable/xeno/hunter_mark/assassin/proc/unset_target()
	SIGNAL_HANDLER
	to_chat(owner, span_xenodanger("We cannot maintain our focus on [marked_target] any longer."))
	owner.balloon_alert(owner, "Death mark expired!")
	UnregisterSignal(marked_target, COMSIG_QDELETING)
	marked_target = null //Nullify hunter's mark target and clear the var

// ***************************************
// *********** Displacement
// ***************************************

/datum/action/ability/xeno_action/displacement
	name = "Displacement"
	action_icon_state = "hunter_invisibility"
	action_icon = 'icons/Xeno/actions/hunter.dmi'
	desc = "Physically disappear, become incorporeal until you decide to reappear somewhere else, reappearing on lighted areas will disorient you and flicker the lights."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOMORPH_HUNTER_DISPLACEMENT,
	)
	use_state_flags = ABILITY_USE_SOLIDOBJECT

/datum/action/ability/xeno_action/displacement/action_activate()
	var/mob/living/carbon/xenomorph/xenomorph_owner = owner
	change_form(xenomorph_owner)

/datum/action/ability/xeno_action/displacement/proc/change_form(mob/living/carbon/xenomorph/X)
	if(!X.loc_weeds_type)
		X.balloon_alert(X, "We need to be on weeds.")
		return
	X.wound_overlay.icon_state = "none"
	var/turf/whereweat = get_turf(X)
	if(X.status_flags & INCORPOREAL) //will alert if the xeno will get disoriented due lit turf, if phasing in.
		if(whereweat.get_lumcount() > 0.3) //is it a lit turf
			X.balloon_alert(X, "We will be disoriented and sensed in this light.") //so its more visible to xeno.
			//Marines can sense the manifestation if it's in lit-enough turf nearby.
			X.visible_message(span_danger("Something begins to manifest nearby!"), span_xenodanger("We begin to manifest in the light... talls sense us!"))
	else
		if(whereweat.get_lumcount() > 0.4) //cant shift out a lit turf.
			X.balloon_alert(X, "We need a darker spot.") //so its more visible to xeno.
			return
	if(do_after(X, 3 SECONDS, IGNORE_HELD_ITEM, X, BUSY_ICON_BAR, NONE, PROGRESS_GENERIC)) //dont move
		do_change_form(X)

///Finish the form changing of the hunter and give the needed stats
/datum/action/ability/xeno_action/displacement/proc/do_change_form(mob/living/carbon/xenomorph/X)
	playsound(get_turf(X), 'sound/effects/alien/new_larva.ogg', 25, 0, 1)
	if(X.status_flags & INCORPOREAL)
		var/turf/whereweat = get_turf(X)
		if(whereweat.get_lumcount() > 0.3) //is it a lit turf
			X.balloon_alert(X, "Light disorients us!")
			X.adjust_stagger(6 SECONDS)
			X.add_slowdown(4)
		for(var/obj/machinery/light/lightie in range(rand(7,10), whereweat))
			lightie.set_flicker(2 SECONDS, 1.5, 2.5, rand(1,2))
		X.status_flags = initial(X.status_flags)
		X.pass_flags = initial(X.pass_flags)
		X.density = TRUE
		REMOVE_TRAIT(X, TRAIT_HANDS_BLOCKED, X)
		X.alpha = 255
		X.update_wounds()
		X.update_icon()
		X.update_action_buttons()
		return
	var/turf/whereweat = get_turf(X)
	for(var/obj/machinery/light/lightie in range(rand(7,10), whereweat))
		lightie.set_flicker(2 SECONDS, 1, 2, rand(1,2))
	ADD_TRAIT(X, TRAIT_HANDS_BLOCKED, X)
	X.status_flags = INCORPOREAL
	X.alpha = 0
	X.pass_flags = PASS_MOB|PASS_XENO
	X.density = FALSE
	X.update_wounds()
	X.update_icon()
	X.update_action_buttons()
