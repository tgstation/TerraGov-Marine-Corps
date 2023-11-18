/datum/action/ability/activable/sectoid/mindmeld
	name = "Mindmeld"
	action_icon_state = "healing_infusion"
	desc = "Merge minds with the target, empowering both."
	cooldown_duration = 60 SECONDS
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ENHANCEMENT,
	)
	var/mob/living/carbon/melded_mob
	///Range the linkees must be to each other to benefit
	var/max_range = 6
	///Projectile accuracy buff
	var/accuracy_mod = 25
	///Max health buff
	var/health_mod = 50
	///Movement speed buff
	var/speed_mod = -0.4
	///% chance to ignore stuns
	var/stun_resistance = 0

/datum/action/ability/activable/sectoid/mindmeld/remove_action(mob/living/carbon/carbon_owner)
	end_ability()
	return ..()

/datum/action/ability/activable/sectoid/mindmeld/can_use_action()
	var/mob/living/carbon/carbon_owner = owner
	if(melded_mob)
		return FALSE
	if(HAS_TRAIT(carbon_owner, TRAIT_MINDMELDED))
		return FALSE
	return ..()

/datum/action/ability/activable/sectoid/mindmeld/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!iscarbon(A))
		if(!silent)
			A.balloon_alert(owner, "not living")
		return FALSE
	var/mob/living/carbon/carbon_target = A
	if(owner.faction != carbon_target.faction)
		if(!silent)
			A.balloon_alert(owner, "hostile!")
		return FALSE
	if(HAS_TRAIT(carbon_target, TRAIT_MINDMELDED))
		if(!silent)
			A.balloon_alert(owner, "already melded!")
		return FALSE
	if((A.z != owner.z) || !line_of_sight(owner, A, max_range))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE
	if(carbon_target.stat == DEAD)
		if(!silent)
			carbon_target.balloon_alert(owner, "already dead")
		return FALSE

/datum/action/ability/activable/sectoid/mindmeld/use_ability(atom/target)
	var/mob/living/carbon/carbon_owner = owner
	melded_mob = target
	melded_mob.balloon_alert_to_viewers("mindmelded")
	owner.balloon_alert_to_viewers("mindmelded")
	playsound(melded_mob, 'sound/effects/off_guard_ability.ogg', 50)

	melded_mob.apply_status_effect(STATUS_EFFECT_MINDMEND, carbon_owner, max_range, accuracy_mod, health_mod, speed_mod, stun_resistance)
	carbon_owner.apply_status_effect(STATUS_EFFECT_MINDMEND, carbon_owner, max_range, accuracy_mod, health_mod, speed_mod, stun_resistance)
	RegisterSignal(melded_mob, COMSIG_MOB_DEATH, PROC_REF(end_ability))
	RegisterSignal(carbon_owner, COMSIG_MOB_DEATH, PROC_REF(end_ability))

	succeed_activate()
	add_cooldown()

/// Ends the ability if the Enhancement buff is removed.
/datum/action/ability/activable/sectoid/mindmeld/proc/end_ability()
	SIGNAL_HANDLER
	var/mob/living/carbon/carbon_owner = owner
	add_cooldown()
	carbon_owner.remove_status_effect(STATUS_EFFECT_MINDMEND)
	if(!melded_mob)
		return
	melded_mob.remove_status_effect(STATUS_EFFECT_MINDMEND)
	melded_mob = null

/datum/action/ability/activable/sectoid/mindmeld/greater
	name = "Greater Mindmeld"
	desc = "Merge minds with the target, greatly empowering both."
	max_range = 12
	accuracy_mod = 40
	health_mod = 70
	speed_mod = -0.5
	stun_resistance = 50

#define MINDFRAY_RANGE 8
/datum/action/ability/activable/sectoid/mindfray
	name = "Mindfray"
	action_icon_state = "off_guard"
	desc = "Muddles the mind of an enemy, making it harder for them to focus their aim for a while."
	cooldown_duration = 20 SECONDS
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_OFFGUARD,
	)
	///damage of this ability
	var/damage = 20

/datum/action/ability/activable/sectoid/mindfray/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!iscarbon(A))
		if(!silent)
			A.balloon_alert(owner, "not living")
		return FALSE
	if(!line_of_sight(owner, A, 9))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE
	if((A.z != owner.z) || get_dist(owner, A) > MINDFRAY_RANGE)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	var/mob/living/carbon/carbon_target = A
	if(carbon_target.stat == DEAD)
		if(!silent)
			carbon_target.balloon_alert(owner, "already dead")
		return FALSE

/datum/action/ability/activable/sectoid/mindfray/use_ability(atom/target)
	var/mob/living/carbon/carbon_target = target
	carbon_target.apply_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF, 10 SECPMDS)
	carbon_target.apply_status_effect(STATUS_EFFECT_CONFUSED, 40)
	carbon_target.apply_damage(damage, BURN, updating_health = TRUE)
	carbon_target.log_message("has been mindfrayed by [owner]", LOG_ATTACK, color="pink")
	carbon_target.balloon_alert_to_viewers("confused")
	playsound(carbon_target, 'sound/effects/off_guard_ability.ogg', 50)

	add_cooldown()
	succeed_activate()
	update_button_icon()

///knockoff psyblast
/datum/action/ability/activable/sectoid/psyblast
	name = "Psychic Blast"
	action_icon_state = "psy_blast"
	desc = "Launch a blast of psychic energy that deals light damage and knocks back enemies in its AOE. Must remain stationary for a few seconds to use."
	cooldown_duration = 6 SECONDS
	ability_cost = 230
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_BLAST,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder
	///The particle type that will be created when using this ability
	var/particles/particle_type = /particles/warlock_charge/psy_blast
	///ammo types available
	var/list/ammo_types = list(
		/datum/ammo/energy/xeno/psy_blast,
		/datum/ammo/energy/xeno/psy_blast/psy_lance,
	)
	///currently loaded
	var/datum/ammo/energy/xeno/selected_ammo

/datum/action/ability/activable/sectoid/psyblast/New(Target)
	selected_ammo = GLOB.ammo_list[ammo_types[1]]
	return ..()

/datum/action/ability/activable/sectoid/psyblast/on_cooldown_finish()
	owner.balloon_alert(owner, "Psy blast ready")
	return ..()

/datum/action/ability/activable/sectoid/psyblast/action_activate()
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.selected_ability == src)
		if(length(ammo_types) <= 1)
			return ..()
		var/found_pos = ammo_types.Find(selected_ammo.type)
		if(!found_pos)
			selected_ammo = GLOB.ammo_list[ammo_types[1]]
		else
			selected_ammo = GLOB.ammo_list[ammo_types[(found_pos%length(ammo_types))+1]]	//Loop around if we would exceed the length
		ability_cost = selected_ammo.ability_cost
		particle_type = selected_ammo.channel_particle
		owner.balloon_alert(owner, "[selected_ammo]")
		update_button_icon()
	return ..()


/datum/action/ability/activable/sectoid/psyblast/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.incapacitated() || carbon_owner.lying_angle)
		return FALSE

/datum/action/ability/activable/sectoid/psyblast/use_ability(atom/A)
	var/mob/living/carbon/carbon_owner = owner
	var/turf/target_turf = get_turf(A)

	owner.balloon_alert(owner, "We channel our psychic power")

	generate_particles(A, 7)
	ADD_TRAIT(carbon_owner, TRAIT_IMMOBILE, PSYCHIC_BLAST_ABILITY_TRAIT)
	//carbon_owner.update_glow(3, 3, selected_ammo.glow_color)

	if(!do_after(carbon_owner, 1 SECONDS, FALSE, target_turf, BUSY_ICON_DANGER) || !can_use_ability(A, FALSE))
		owner.balloon_alert(owner, "Our focus is disrupted")
		end_channel()
		REMOVE_TRAIT(carbon_owner, TRAIT_IMMOBILE, PSYCHIC_BLAST_ABILITY_TRAIT)
		return fail_activate()

	var/obj/projectile/hitscan/projectile = new /obj/projectile/hitscan(carbon_owner.loc)
	projectile.effect_icon = initial(selected_ammo.hitscan_effect_icon)
	projectile.generate_bullet(selected_ammo)
	projectile.fire_at(A, carbon_owner, null, projectile.ammo.max_range, projectile.ammo.shell_speed)
	playsound(carbon_owner, 'sound/weapons/guns/fire/volkite_4.ogg', 40)

	add_cooldown()
	succeed_activate()
	update_button_icon()
	REMOVE_TRAIT(carbon_owner, TRAIT_IMMOBILE, PSYCHIC_BLAST_ABILITY_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(end_channel)), 5)

/datum/action/ability/activable/sectoid/psyblast/update_button_icon()
	action_icon_state = selected_ammo.icon_state
	return ..()

//Generates particles and directs them towards target
/datum/action/ability/activable/sectoid/psyblast/proc/generate_particles(atom/target, velocity)
	var/angle = Get_Angle(get_turf(owner), get_turf(target)) //pixel offsets effect angles
	var/x_component = sin(angle) * velocity
	var/y_component = cos(angle) * velocity

	particle_holder = new(owner, particle_type)

	particle_holder.particles.velocity = list(x_component * 0.5, y_component * 0.5)
	particle_holder.particles.gravity = list(x_component, y_component)
	particle_holder.particles.rotation = angle

///Cleans up when the channel finishes or is cancelled
/datum/action/ability/activable/sectoid/psyblast/proc/end_channel()
	QDEL_NULL(particle_holder)
	//var/mob/living/carbon/carbon_owner = owner
	//carbon_owner.update_glow()


// ***************************************
// *********** Stasis
// ***************************************

#define SECTOID_STASIS_RANGE 7
/datum/action/ability/activable/sectoid/stasis
	name = "stasis"
	action_icon_state = "off_guard"
	desc = "Muddles the mind of an enemy, making it harder for them to focus their aim for a while."
	cooldown_duration = 20 SECONDS
	target_flags = XABB_MOB_TARGET
	use_state_flags = XACT_TARGET_SELF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_OFFGUARD,
	)
	///Duration of effect
	var/stasis_duration = 5 SECONDS
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/activable/sectoid/stasis/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!iscarbon(A))
		if(!silent)
			A.balloon_alert(owner, "not living")
		return FALSE
	if((A.z != owner.z) || get_dist(owner, A) > SECTOID_STASIS_RANGE)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	if(!line_of_sight(owner, A, SECTOID_STASIS_RANGE))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE
	var/mob/living/carbon/carbon_target = A
	if(carbon_target.stat == DEAD)
		if(!silent)
			carbon_target.balloon_alert(owner, "already dead")
		return FALSE

/datum/action/ability/activable/sectoid/stasis/use_ability(atom/target)
	particle_holder = new(owner, /particles/drone_enhancement)
	particle_holder.pixel_x = 0
	particle_holder.pixel_y = -3
	particle_holder.particles.velocity = list(0, 1.5)
	particle_holder.particles.gravity = list(0, 2)

	if(!do_after(owner, 0.5 SECONDS, FALSE, target, BUSY_ICON_DANGER, ignore_turf_checks = TRUE) || !can_use_ability(target))
		owner.balloon_alert(owner, "Our focus is disrupted")
		QDEL_NULL(particle_holder)
		return fail_activate()

	var/mob/living/carbon/carbon_target = target
	playsound(owner, 'sound/effects/petrify_activate.ogg', 50)

	carbon_target.notransform = TRUE
	carbon_target.status_flags |= GODMODE
	ADD_TRAIT(carbon_target, TRAIT_HANDS_BLOCKED, REF(src))
	carbon_target.move_resist = MOVE_FORCE_OVERPOWERING
	carbon_target.add_atom_colour(COLOR_GRAY, TEMPORARY_COLOUR_PRIORITY)
	carbon_target.log_message("has been petrified by [owner] for [stasis_duration] ticks", LOG_ATTACK, color="pink")

	var/image/stone_overlay = image('icons/effects/effects.dmi', null, "petrified_overlay")
	stone_overlay.filters += filter(arglist(alpha_mask_filter(render_source="*[REF(carbon_target)]",flags=MASK_INVERSE)))

	var/mutable_appearance/mask = mutable_appearance()
	mask.appearance = carbon_target.appearance
	mask.render_target = "*[REF(carbon_target)]"
	mask.alpha = 125
	stone_overlay.overlays += mask

	carbon_target.overlays += stone_overlay
	addtimer(CALLBACK(src, PROC_REF(end_effects), carbon_target, stone_overlay), stasis_duration)
	QDEL_NULL(particle_holder)
	add_cooldown()
	update_button_icon()
	succeed_activate()

///ends all combat-relazted effects
/datum/action/ability/activable/sectoid/stasis/proc/end_effects(mob/living/carbon/carbon_target, image/stone_overlay)
	carbon_target.notransform = FALSE
	carbon_target.status_flags &= ~GODMODE
	REMOVE_TRAIT(carbon_target, TRAIT_HANDS_BLOCKED, REF(src))
	carbon_target.move_resist = initial(carbon_target.move_resist)
	carbon_target.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_GRAY)
	carbon_target.overlays -= stone_overlay

// ***************************************
// *********** Reknit form
// ***************************************

#define SECTOID_REKNIT_RANGE 4
/datum/action/ability/activable/sectoid/reknit_form
	name = "Reknit Form"
	action_icon_state = "off_guard"
	desc = "Flesh and bone runs like water at our will, healing horrendous damage with the power of our mind."
	cooldown_duration = 60 SECONDS
	target_flags = XABB_MOB_TARGET
	use_state_flags = XACT_TARGET_SELF
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_OFFGUARD,
	)
	///damage of this ability
	var/reknit_duration = 3 SECONDS
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/activable/sectoid/reknit_form/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if(!isliving(A))
		if(!silent)
			A.balloon_alert(owner, "not living")
		return FALSE
	if((A.z != owner.z) || get_dist(owner, A) > SECTOID_REKNIT_RANGE)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	if(!line_of_sight(owner, A, SECTOID_REKNIT_RANGE))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE

/datum/action/ability/activable/sectoid/reknit_form/use_ability(atom/target)
	particle_holder = new(owner, /particles/drone_enhancement)
	particle_holder.pixel_x = 0
	particle_holder.pixel_y = -3
	particle_holder.particles.velocity = list(0, 1.5)
	particle_holder.particles.gravity = list(0, 2)

	if(!do_after(owner, 0.5 SECONDS, FALSE, target, BUSY_ICON_DANGER, ignore_turf_checks = TRUE) || !can_use_ability(target))
		owner.balloon_alert(owner, "Our focus is disrupted")
		QDEL_NULL(particle_holder)
		return fail_activate()

	var/mob/living/living_target = target
	living_target.apply_status_effect(STATUS_EFFECT_REKNIT_FORM, reknit_duration)
	QDEL_NULL(particle_holder)
	playsound(owner, 'sound/effects/petrify_activate.ogg', 50)
	add_cooldown()
	update_button_icon()
	succeed_activate()

/datum/action/ability/activable/sectoid/reknit_form/greater
	name = "Greater Reknit Form"
	reknit_duration = 6 SECONDS

// ***************************************
// *********** Fuse
// ***************************************

#define SECTOID_FUSE_RANGE 6
/datum/action/ability/activable/sectoid/fuse
	name = "Fuse"
	action_icon_state = "off_guard"
	desc = "We reach out with our mind to trigger an explosive device."
	cooldown_duration = 45 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_OFFGUARD,
	)
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/action/ability/activable/sectoid/fuse/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return
	if((A.z != owner.z) || get_dist(owner, A) > SECTOID_FUSE_RANGE)
		if(!silent)
			A.balloon_alert(owner, "too far")
		return FALSE
	if(!line_of_sight(owner, A, SECTOID_FUSE_RANGE))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE

/datum/action/ability/activable/sectoid/fuse/use_ability(atom/target)
	particle_holder = new(owner, /particles/drone_enhancement)
	particle_holder.pixel_x = 0
	particle_holder.pixel_y = -3
	particle_holder.particles.velocity = list(0, 1.5)
	particle_holder.particles.gravity = list(0, 2)

	if(!do_after(owner, 0.5 SECONDS, FALSE, target, BUSY_ICON_DANGER, ignore_turf_checks = TRUE) || !can_use_ability(target))
		owner.balloon_alert(owner, "Our focus is disrupted")
		QDEL_NULL(particle_holder)
		return fail_activate()

	var/obj/item/explosive/grenade/grenade_target
	if(isgrenade(target))
		grenade_target = target
	else
		grenade_target = locate(/obj/item/explosive) in target
		if(!grenade_target)
			for(var/obj/item/storage/target_storage in target)
				grenade_target = locate(/obj/item/explosive) in target_storage
				if(grenade_target)
					break
			if(!grenade_target)
				target.balloon_alert(owner, "no grenade found")
				return fail_activate()

	grenade_target.activate(owner)
	QDEL_NULL(particle_holder)
	playsound(owner, 'sound/effects/petrify_activate.ogg', 50)
	add_cooldown()
	update_button_icon()
	succeed_activate()
