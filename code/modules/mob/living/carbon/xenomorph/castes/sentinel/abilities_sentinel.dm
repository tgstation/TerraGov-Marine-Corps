
/datum/action/xeno_action/activable/neurogas_grenade
	name = "Throw neurogas grenade"
	action_icon_state = "gas mine"
	mechanics_text = "Throws a gas emitting grenade at your enemies."
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_NEUROGAS_GRENADE,
	)
	plasma_cost = 300
	cooldown_timer = 1 MINUTES

/datum/action/xeno_action/activable/neurogas_grenade/use_ability(atom/A)
	. = ..()
	succeed_activate()
	add_cooldown()

	var/obj/item/explosive/grenade/smokebomb/xeno/nade = new(get_turf(owner))
	nade.throw_at(A, 5, 1, owner, TRUE)
	nade.activate(owner)

	owner.visible_message(span_warning("[owner] vomits up a bulbous lump and throws it at [A]!"), span_warning("We vomit up a bulbous lump and throw it at [A]!"))


/obj/item/explosive/grenade/smokebomb/xeno
	name = "neurogas grenade"
	desc = "A fleshy mass that bounces along the ground. It seems to be heating up."
	greyscale_colors = "#f0be41"
	greyscale_config = /datum/greyscale_config/xenogrenade
	det_time = 20
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/xeno/neuro/medium
	arm_sound = 'sound/voice/alien_yell_alt.ogg'
	smokeradius = 3

/obj/item/explosive/grenade/smokebomb/xeno/update_overlays()
	. = ..()
	if(active)
		. += image('icons/obj/items/grenade.dmi', "xenonade_active")
