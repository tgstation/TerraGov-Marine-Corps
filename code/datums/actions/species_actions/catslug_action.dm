/datum/action/ability/activable/catslug
	action_icon = 'icons/mob/catslug_icons.dmi'

// ***************************************
// *********** Rock throw
// ***************************************
/datum/action/ability/activable/catslug/rockthrow
	name = "Rock Throw"
	action_icon_state = "rock_throw"
	desc = "Throw a sharpened pre-prepared rock."
	cooldown_duration = 10 SECONDS
	target_flags = ABILITY_TURF_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_ABILITY_ROCKTHROW,
	)

/datum/action/ability/activable/catslug/rockthrow/use_ability(atom/target)
	var/mob/living/carbon/human/X = owner

	if(!do_after(X, 0.5 SECONDS, NONE, target, BUSY_ICON_DANGER))
		return fail_activate()

	//Shoot at the thing
	playsound(X.loc, 'sound/weapons/heavyhit.ogg', 50, 1)

	var/datum/ammo/bullet/rock = GLOB.ammo_list[/datum/ammo/bullet/rock]

	var/obj/projectile/newrock = new /obj/projectile(get_turf(X))
	newrock.generate_bullet(rock, rock.damage)
	newrock.def_zone = X.get_limbzone_target()

	newrock.fire_at(target, X, null, newrock.ammo.max_range)

	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.catslug_rock_throw++ //Statistics
	SSblackbox.record_feedback("tally", "round_statistics", 1, "catslug_rock_throw")

/datum/action/ability/activable/catslug/rock_throw/on_cooldown_finish()
	to_chat(owner, span_xenodanger("Our arm recovers enough to throw again."))
	return ..()
