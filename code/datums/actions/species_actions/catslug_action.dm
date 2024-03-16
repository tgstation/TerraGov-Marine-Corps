/datum/action/ability/activable/catslug
	action_icon = 'icons/mob/catslug_icons.dmi'

// ***************************************
// *********** Spear Throw
// ***************************************
/datum/action/ability/activable/catslug/spearthrow
	name = "Spear Throw"
	action_icon_state = "spear_throw"
	desc = "Throw a sharpened spear."
	cooldown_duration = 15 SECONDS
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_SPEARTHROW,
	)

/datum/action/ability/activable/catslug/spearthrow/use_ability(atom/target)
	var/mob/living/carbon/human/X = owner

	if(!do_after(X, 0.5 SECONDS, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	//Shoot at the thing
	playsound(X.loc, 'sound/weapons/heavyhit.ogg', 50, 1)

	var/datum/ammo/bullet/spear = GLOB.ammo_list[/datum/ammo/bullet/spear]

	var/obj/projectile/newspear = new /obj/projectile(get_turf(X))
	newspear.generate_bullet(spear, spear.damage)
	newspear.def_zone = X.get_limbzone_target()

	newspear.fire_at(target, X, null, newspear.ammo.max_range)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.catslug_spear_throw++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "catslug_spear_throw")

/datum/action/ability/activable/catslug/spearthrow/on_cooldown_finish()
	to_chat(owner, span_xenodanger("Our arm recovers enough to throw again."))
	return ..()

// ***************************************
// *********** Healing Touch
// ***************************************
/datum/action/ability/activable/catslug/healingtouch
	name = "Healing Touch"
	action_icon_state = "heal_human"
	desc = "Apply a minor heal to the target."
	cooldown_duration = 10 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_HEALINGTOUCH,
	)
	target_flags = ABILITY_MOB_TARGET

/datum/action/ability/activable/catslug/healingtouch/use_ability(atom/target)
	var/mob/living/carbon/human/H = owner
	if(H.do_actions)
		return FALSE
	if(!do_after(H, 1 SECONDS, NONE, target, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
		return FALSE
	H.visible_message(span_xenowarning("\the [H] spreads regenerative slime over [target], mending their wounds!"))
	owner.changeNext_move(CLICK_CD_RANGE)
	salve_healing(target)
	succeed_activate()
	add_cooldown()
	if(owner.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[owner.ckey]
		personal_statistics.heals++

/datum/action/ability/activable/catslug/healingtouch/on_cooldown_finish()
	to_chat(owner, span_notice("We gather enough slime to use again."))
	return ..()

/// Heals the target and gives them a regenerative buff, if applicable.
/datum/action/ability/activable/catslug/healingtouch/proc/salve_healing(mob/living/carbon/human/target)
	playsound(target, "alien_drool", 25)
	new /obj/effect/temp_visual/telekinesis(get_turf(target))
	var/heal_amount = 12
	target.adjustFireLoss(-heal_amount, TRUE)
	target.adjustBruteLoss(-heal_amount, TRUE)

