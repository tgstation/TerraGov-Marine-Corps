// ***************************************
// *********** Toxic Spit
// ***************************************
/datum/action/xeno_action/activable/xeno_spit/toxic_spit
	name = "Toxic Spit"
	mechanics_text = "Spit a toxin at your target up to 7 tiles away, inflicting the Intoxicated debuff and dealing damage over time."
	ability_name = "toxic spit"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOXIC_SPIT,
	)

/datum/ammo/xeno/acid/toxic_spit
	name = "toxic spit"
	icon_state = "xeno_toxic"
	bullet_color = COLOR_PALE_GREEN_GRAY
	damage = 12
	spit_cost = 30
	flags_ammo_behavior = AMMO_XENO|AMMO_EXPLOSIVE|AMMO_SKIPS_ALIENS

/datum/ammo/xeno/acid/toxic_spit/upgrade1
	damage = 14

/datum/ammo/xeno/acid/toxic_spit/upgrade2
	damage = 15

/datum/ammo/xeno/acid/toxic_spit/upgrade3
	damage = 16

/datum/ammo/xeno/acid/toxic_spit/on_hit_mob(mob/M, obj/projectile/P)
	if(istype(M,/mob/living/carbon))
		var/mob/living/carbon/C = M
		if(C.issamexenohive(P.firer))
			return
		if(HAS_TRAIT(C, TRAIT_INTOXICATION_IMMUNE))
			return
		if(C.has_status_effect(STATUS_EFFECT_INTOXICATED))
			var/datum/status_effect/stacking/intoxicated/debuff = C.has_status_effect(STATUS_EFFECT_INTOXICATED)
			debuff.add_stacks(SENTINEL_TOXIC_SPIT_STACKS_PER)
		C.apply_status_effect(STATUS_EFFECT_INTOXICATED, SENTINEL_TOXIC_SPIT_STACKS_PER)

// ***************************************
// *********** Toxic Slash
// ***************************************
/datum/action/xeno_action/toxic_slash
	name = "Toxic Slash"
	action_icon_state = "neuroclaws_off"
	mechanics_text = "Imbue your claws with acid for a short duration, inflicting lasting effects on your victims."
	ability_name = "toxic slash"
	cooldown_timer = 10 SECONDS
	plasma_cost = 100
	//use_state_flags = XACT_USE_BUCKLED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOXIC_SLASH,
	)
	/// The remaining amount of Toxic Slashes.
	var/remaining_slashes = 0
	/// Timer for the ability; we reference this to delete the timer if the effect lapses before the timer does.
	var/ability_duration
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/xeno_action/toxic_slash/action_activate()
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	remaining_slashes = SENTINEL_TOXIC_SLASH_COUNT
	ability_duration = addtimer(CALLBACK(src, .proc/toxic_slash_deactivate, X), SENTINEL_TOXIC_SLASH_DURATION, TIMER_STOPPABLE) //Initiate the timer and set the timer ID for reference
	RegisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/toxic_slash)
	X.balloon_alert(X, "Toxic Slash active")
	X.playsound_local(X, 'sound/voice/alien_drool2.ogg', 25)
	action_icon_state = "neuroclaws_on"
	particle_holder = new(owner, /particles/toxic_slash)
	particle_holder.pixel_x = 9
	particle_holder.pixel_y = 2
	succeed_activate()
	add_cooldown()

///Called when Toxic Slash is active.
/datum/action/xeno_action/toxic_slash/proc/toxic_slash(datum/source, mob/living/target, damage, list/damage_mod, list/armor_mod)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/C = target
	if(HAS_TRAIT(C, TRAIT_INTOXICATION_IMMUNE))
		C.balloon_alert(X, "Immune to Intoxication")
		return
	playsound(C, 'sound/effects/spray3.ogg', 20, TRUE)
	if(C.has_status_effect(STATUS_EFFECT_INTOXICATED))
		var/datum/status_effect/stacking/intoxicated/debuff = C.has_status_effect(STATUS_EFFECT_INTOXICATED)
		debuff.add_stacks(SENTINEL_TOXIC_SLASH_STACKS_PER)
	C.apply_status_effect(STATUS_EFFECT_INTOXICATED, SENTINEL_TOXIC_SLASH_STACKS_PER)
	remaining_slashes-- //Decrement the toxic slash count
	if(!remaining_slashes) //Deactivate if we have no toxic slashes remaining
		toxic_slash_deactivate(X)

///Called when Toxic Slash expires.
/datum/action/xeno_action/toxic_slash/proc/toxic_slash_deactivate(mob/living/carbon/xenomorph/X)
	UnregisterSignal(X, COMSIG_XENOMORPH_ATTACK_LIVING)
	remaining_slashes = 0
	deltimer(ability_duration) // Delete the timer so we don't have mismatch issues, and so we don't potentially try to deactivate the ability twice
	ability_duration = null
	QDEL_NULL(particle_holder)
	X.balloon_alert(X, "Toxic Slash over") //Let the user know
	X.playsound_local(X, 'sound/voice/hiss5.ogg', 25)
	action_icon_state = "neuroclaws_off"

/datum/action/xeno_action/toxic_slash/on_cooldown_finish()
	owner.playsound_local(owner, 'sound/effects/xeno_newlarva.ogg', 25, 0, 1)
	owner.balloon_alert(owner, "Toxic Slash ready")
	return ..()

/particles/toxic_slash
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "x"
	width = 100
	height = 100
	count = 1000
	spawning = 4
	lifespan = 9
	fade = 10
	grow = 0.2
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 10, 10, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.15), list(0, 0.15))
	gravity = list(0, 0.4)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(0.9,0.9), NORMAL_RAND)
	rotation = 0
	spin = generator(GEN_NUM, 10, 20)
	color = "#7DCC00"

// ***************************************
// *********** Drain Sting
// ***************************************
/datum/action/xeno_action/activable/drain_sting
	name = "Drain Sting"
	action_icon_state = "neuro_sting"
	mechanics_text = "Sting your victim, draining them and gaining benefits if they are Intoxicated."
	ability_name = "drain sting"
	cooldown_timer = 25 SECONDS
	plasma_cost = 75
	target_flags = XABB_MOB_TARGET
	use_state_flags = XACT_USE_BUCKLED
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_DRAIN_STING,
	)

/datum/action/xeno_action/activable/drain_sting/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!istype(A, /mob/living/carbon/human))
		if(!silent)
			owner.balloon_alert(owner, "Cannot sting")
		return FALSE
	var/mob/living/carbon/C = A
	if(!owner.Adjacent(C))
		owner.balloon_alert(owner, "Cannot reach")
		return FALSE
	if(HAS_TRAIT(C, TRAIT_INTOXICATION_IMMUNE))
		C.balloon_alert(owner, "Immune to intoxication")
		return FALSE
	if(!C.has_status_effect(STATUS_EFFECT_INTOXICATED))
		owner.balloon_alert(owner, "Not intoxicated")
		return FALSE

/datum/action/xeno_action/activable/drain_sting/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/C = A
	var/datum/status_effect/stacking/intoxicated/debuff = C.has_status_effect(STATUS_EFFECT_INTOXICATED)
	var/drain_potency = debuff.stacks * SENTINEL_DRAIN_MULTIPLIER
	if(debuff.stacks > debuff.max_stacks - 10)
		X.apply_status_effect(STATUS_EFFECT_DRAIN_SURGE)
	C.adjustFireLoss(drain_potency / 5)
	C.AdjustKnockdown(debuff.stacks - 10)
	HEAL_XENO_DAMAGE(X, drain_potency, FALSE)
	X.gain_plasma(drain_potency * 3.5)
	X.do_attack_animation(C, ATTACK_EFFECT_REDSTAB)
	playsound(owner.loc, 'sound/effects/alien_tail_swipe1.ogg', 30)
	debuff.stacks -= round(debuff.stacks * 0.7)
	succeed_activate()
	add_cooldown()

/datum/action/xeno_action/activable/drain_sting/on_cooldown_finish()
	playsound(owner.loc, 'sound/voice/alien_drool1.ogg', 50, 1)
	owner.balloon_alert(owner, "Drain Sting ready")
	return ..()

// ***************************************
// *********** Toxic Grenade
// ***************************************
/datum/action/xeno_action/activable/toxic_grenade
	name = "Toxic grenade"
	action_icon_state = "gas mine"
	mechanics_text = "Throws a lump of compressed acidic gases, which will inflict damage over time and Intoxicate victims."
	plasma_cost = 200
	cooldown_timer = 50 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_TOXIC_GRENADE,
	)

/datum/action/xeno_action/activable/toxic_grenade/use_ability(atom/A)
	. = ..()
	succeed_activate()
	add_cooldown()
	var/obj/item/explosive/grenade/smokebomb/xeno/nade = new(get_turf(owner))
	nade.throw_at(A, 5, 1, owner, TRUE)
	nade.activate(owner)
	owner.visible_message(span_warning("[owner] vomits up a bulbous lump and throws it at [A]!"), span_warning("We vomit up a bulbous lump and throw it at [A]!"))

/obj/item/explosive/grenade/smokebomb/xeno
	name = "toxic grenade"
	desc = "A fleshy mass that bounces along the ground. It seems to be heating up."
	greyscale_colors = "#42A500"
	greyscale_config = /datum/greyscale_config/xenogrenade
	det_time = 15
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/xeno/toxic
	arm_sound = 'sound/voice/alien_yell_alt.ogg'
	smokeradius = 4

/obj/item/explosive/grenade/smokebomb/xeno/update_overlays()
	. = ..()
	if(active)
		. += image('icons/obj/items/grenade.dmi', "xenonade_active")
