/datum/action/ability/activable/catslug
	action_icon = 'icons/mob/catslug_icons.dmi'

// ***************************************
// *********** Rock throw
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
