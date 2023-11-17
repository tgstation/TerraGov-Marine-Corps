#define MINDMELD_RANGE 8

/datum/action/ability/activable/mindmeld
	name = "Mindmeld"
	action_icon_state = "healing_infusion"
	desc = "Merge minds with the target, empowering both."
	cooldown_duration = 60 SECONDS
	target_flags = XABB_MOB_TARGET
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ENHANCEMENT,
	)
	/// Used to determine whether Enhancement is already active or not. Also allows access to its vars.
	//var/datum/status_effect/mindmeld/existing_mindmeld
	var/mob/living/carbon/melded_mob
	/// Damage bonus given by this ability.
	//var/damage_multiplier = 1.15
	/// Speed bonus given by this ability.
	var/speed_addition = -0.4

	var/health_mod = 50

/datum/action/ability/activable/mindmeld/can_use_action()
	var/mob/living/carbon/carbon_owner = owner
	if(melded_mob)
		return FALSE
	if(HAS_TRAIT(carbon_owner, TRAIT_MINDMELDED))
		return FALSE
	return ..()

/datum/action/ability/activable/mindmeld/can_use_ability(atom/A, silent = FALSE, override_flags)
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
	if((A.z != owner.z) || !line_of_sight(owner, A, MINDMELD_RANGE))
		if(!silent)
			owner.balloon_alert(owner, "Out of sight!")
		return FALSE

	if(carbon_target.stat == DEAD)
		if(!silent)
			carbon_target.balloon_alert(owner, "already dead")
		return FALSE

/datum/action/ability/activable/mindmeld/use_ability(atom/target)
	var/mob/living/carbon/carbon_owner = owner
	melded_mob = target
	melded_mob.balloon_alert_to_viewers("mindmelded")
	owner.balloon_alert_to_viewers("mindmelded")
	playsound(melded_mob, 'sound/effects/off_guard_ability.ogg', 50)

	melded_mob.apply_status_effect(STATUS_EFFECT_MINDMEND, carbon_owner, src)
	carbon_owner.apply_status_effect(STATUS_EFFECT_MINDMEND, melded_mob, src)

	add_cooldown()

/// Ends the ability if the Enhancement buff is removed.
/datum/action/ability/activable/mindmeld/proc/end_ability()
	var/mob/living/carbon/carbon_owner = owner
	add_cooldown()
	carbon_owner.remove_status_effect(STATUS_EFFECT_MINDMEND)
	if(!melded_mob)
		return
	melded_mob.remove_status_effect(STATUS_EFFECT_MINDMEND)
	melded_mob = null


#define MINDFRAY_RANGE 8
/datum/action/ability/activable/mindfray
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

/datum/action/ability/activable/mindfray/can_use_ability(atom/A, silent = FALSE, override_flags)
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

/datum/action/ability/activable/mindfray/use_ability(atom/target)
	var/mob/living/carbon/carbon_target = target
	carbon_target.apply_status_effect(STATUS_EFFECT_GUN_SKILL_SCATTER_DEBUFF, 100)
	carbon_target.apply_status_effect(STATUS_EFFECT_CONFUSED, 40)
	carbon_target.apply_damage(damage, BURN, updating_health = TRUE)
	carbon_target.log_message("has been mindfrayed by [owner]", LOG_ATTACK, color="pink")
	carbon_target.balloon_alert_to_viewers("confused")
	playsound(carbon_target, 'sound/effects/off_guard_ability.ogg', 50)

	add_cooldown()

///knockoff psyblast
/datum/action/ability/activable/psy_blast_sectoid
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

/datum/action/ability/activable/psy_blast_sectoid/New(Target)
	selected_ammo = GLOB.ammo_list[ammo_types[1]]
	return ..()

/datum/action/ability/activable/psy_blast_sectoid/on_cooldown_finish()
	owner.balloon_alert(owner, "Psy blast ready")
	return ..()

/datum/action/ability/activable/psy_blast_sectoid/action_activate()
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


/datum/action/ability/activable/psy_blast_sectoid/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.incapacitated() || carbon_owner.lying_angle)
		return FALSE

/datum/action/ability/activable/psy_blast_sectoid/use_ability(atom/A)
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

	succeed_activate()

	var/obj/projectile/hitscan/projectile = new /obj/projectile/hitscan(carbon_owner.loc)
	projectile.effect_icon = initial(selected_ammo.hitscan_effect_icon)
	projectile.generate_bullet(selected_ammo)
	projectile.fire_at(A, carbon_owner, null, projectile.ammo.max_range, projectile.ammo.shell_speed)
	playsound(carbon_owner, 'sound/weapons/guns/fire/volkite_4.ogg', 40)

	add_cooldown()
	update_button_icon()
	REMOVE_TRAIT(carbon_owner, TRAIT_IMMOBILE, PSYCHIC_BLAST_ABILITY_TRAIT)
	addtimer(CALLBACK(src, PROC_REF(end_channel)), 5)

/datum/action/ability/activable/psy_blast_sectoid/update_button_icon()
	action_icon_state = selected_ammo.icon_state
	return ..()

//Generates particles and directs them towards target
/datum/action/ability/activable/psy_blast_sectoid/proc/generate_particles(atom/target, velocity)
	var/angle = Get_Angle(get_turf(owner), get_turf(target)) //pixel offsets effect angles
	var/x_component = sin(angle) * velocity
	var/y_component = cos(angle) * velocity

	particle_holder = new(owner, particle_type)

	particle_holder.particles.velocity = list(x_component * 0.5, y_component * 0.5)
	particle_holder.particles.gravity = list(x_component, y_component)
	particle_holder.particles.rotation = angle

///Cleans up when the channel finishes or is cancelled
/datum/action/ability/activable/psy_blast_sectoid/proc/end_channel()
	QDEL_NULL(particle_holder)
	//var/mob/living/carbon/carbon_owner = owner
	//carbon_owner.update_glow()
