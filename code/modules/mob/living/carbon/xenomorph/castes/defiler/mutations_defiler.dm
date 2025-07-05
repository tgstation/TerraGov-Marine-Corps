//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/panic_gas
	name = "Panic Gas"
	desc = "Getting staggered will consume 50% of your maximum plasma to release non-opaque gas of your last selected gas. This only works if you have 100/75/50% of your maximum plasma remaining. This resets upon reaching maximum health."
	/// For the first structure, the percentage amount of maximum plasma required to trigger this.
	var/max_plasma_percentage_initial = 1.25
	/// For each structure, the additional percentage amount of maximum plasma required to trigger this.
	var/max_plasma_percentage_per_structure = -0.25

	var/max_plasma_to_consume = 0.5
	/// Can this be activated?
	var/can_be_activated = FALSE

/datum/mutation_upgrade/shell/panic_gas/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Getting staggered will consume [PERCENT(max_plasma_to_consume)] of your maximum plasma to release non-opaque gas of your last selected gas if you have at least [PERCENT(max_plasma_percentage_initial + (max_plasma_percentage_per_structure * new_amount))]% of your maximum plasma remaining. This resets upon reaching maximum health."

/datum/mutation_upgrade/shell/panic_gas/on_mutation_enabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_STATUS_STAGGER, PROC_REF(on_staggered))
	can_be_activated = xenomorph_owner.health >= xenomorph_owner.maxHealth
	return ..()

/datum/mutation_upgrade/shell/panic_gas/on_mutation_disabled()
	RegisterSignals(xenomorph_owner, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(on_damage))
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_STATUS_STAGGER)
	can_be_activated = FALSE
	return ..()

/// If it isn't ready to activate and they have full health, make it ready to activate.
/datum/mutation_upgrade/shell/panic_gas/proc/on_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(!can_be_activated && xenomorph_owner.health >= xenomorph_owner.maxHealth)
		can_be_activated = TRUE

/// If it is ready to activate and reaches the threshold, do the acid effect.
/datum/mutation_upgrade/shell/panic_gas/proc/on_staggered(datum/source, amount, ignore_canstun)
	if(!can_be_activated || !isturf(xenomorph_owner.loc) || xenomorph_owner.stat != CONSCIOUS)
		return
	var/datum/effect_system/smoke_spread/emitted_gas
	switch(xenomorph_owner.selected_reagent)
		if(/datum/reagent/toxin/xeno_neurotoxin)
			emitted_gas = new /datum/effect_system/smoke_spread/xeno/neuro/light(xenomorph_owner)
		if(/datum/reagent/toxin/xeno_hemodile)
			emitted_gas = new /datum/effect_system/smoke_spread/xeno/hemodile/light(xenomorph_owner)
		if(/datum/reagent/toxin/xeno_transvitox)
			emitted_gas = new /datum/effect_system/smoke_spread/xeno/transvitox/light(xenomorph_owner)
		if(/datum/reagent/toxin/xeno_ozelomelyn)
			emitted_gas = new /datum/effect_system/smoke_spread/xeno/ozelomelyn/light(xenomorph_owner)
	emitted_gas.set_up(2, get_turf(xenomorph_owner))
	emitted_gas.start()
	xenomorph_owner.use_plasma(xenomorph_owner.xeno_caste.plasma_max * 0.50)
	can_be_activated = FALSE

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/envenomed
	name = "Envenomed"
	desc = "You no longer have the ability, Reagent Slash. All slashes against humans will consume 20 plasma and inject your selected reagent equal to 20/35/50% of a regular reagent slash."
	/// For the first structure, the percentage amount of reagents to transfer on slash.
	var/reagent_percentage_initial = 0.05
	/// For each structure, the additional percentage amount of reagents to transfer on slash.
	var/reagent_percentage_per_structure = 0.15
	/// The amount of plasma used per slash.
	var/plasma_consumed_per_slash = 20
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/mutation_upgrade/spur/envenomed/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "You no longer have the ability, Reagent Slash. All slashes against humans will consume [plasma_consumed_per_slash] plasma and inject your selected reagent equal to [PERCENT(reagent_percentage_initial + (reagent_percentage_per_structure * new_amount))]% of a regular reagent slash."

/datum/mutation_upgrade/spur/envenomed/on_mutation_enabled()
	var/datum/action/ability/xeno_action/reagent_slash/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/reagent_slash]
	if(ability)
		ability.remove_action(xenomorph_owner)
	RegisterSignal(xenomorph_owner, COMSIG_XENO_SELECTED_REAGENT_CHANGED, PROC_REF(on_selected_reagent))
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ATTACK_LIVING, PROC_REF(on_attack_living))
	return ..()

/datum/mutation_upgrade/spur/envenomed/on_mutation_disabled()
	if(particle_holder)
		QDEL_NULL(particle_holder)
	var/datum/action/ability/xeno_action/reagent_slash/ability = new()
	ability.give_action(xenomorph_owner)
	UnregisterSignal(xenomorph_owner, list(COMSIG_XENO_SELECTED_REAGENT_CHANGED, COMSIG_XENOMORPH_ATTACK_LIVING))
	return ..()

/datum/mutation_upgrade/spur/envenomed/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/reagent_slash/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/reagent_slash]
	if(ability)
		ability.remove_action(xenomorph_owner)

/datum/mutation_upgrade/spur/envenomed/proc/on_selected_reagent(datum/source, datum/reagent/old_reagent_typepath, datum/reagent/new_reagent_typepath)
	SIGNAL_HANDLER
	if(particle_holder)
		QDEL_NULL(particle_holder)
	switch(new_reagent_typepath)
		if(/datum/reagent/toxin/xeno_neurotoxin)
			particle_holder = new(xenomorph_owner, /particles/xeno_slash/neurotoxin)
		if(/datum/reagent/toxin/xeno_hemodile)
			particle_holder = new(xenomorph_owner, /particles/xeno_slash/hemodile)
		if(/datum/reagent/toxin/xeno_transvitox)
			particle_holder = new(xenomorph_owner, /particles/xeno_slash/transvitox)
		if(/datum/reagent/toxin/xeno_ozelomelyn)
			particle_holder = new(xenomorph_owner, /particles/xeno_slash/ozelomelyn)
	particle_holder.pixel_x = 16
	particle_holder.pixel_y = 12

/datum/mutation_upgrade/spur/envenomed/proc/on_attack_living(mob/living/attacked_mob, damage, damage_mod, armor_mod)
	SIGNAL_HANDLER
	if(!iscarbon(attacked_mob) || !attacked_mob.can_sting())
		return
	var/mob/living/carbon/attacked_carbon = attacked_mob
	attacked_carbon.reagents.add_reagent(xenomorph_owner.selected_reagent, DEFILER_REAGENT_SLASH_INJECT_AMOUNT * (reagent_percentage_initial + (reagent_percentage_per_structure * get_total_structures())))
	playsound(attacked_carbon, 'sound/effects/spray3.ogg', 8, TRUE, 2)
	xenomorph_owner.visible_message(attacked_carbon, span_danger("[attacked_carbon] is lightly pricked by [xenomorph_owner]'s spines!"), null, 3)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/wide_gas
	name = "Wide Gas"
	desc = "Emit Noxious Gas now emits non-opaque gas instead. The radius of the gas is increased by 0.6/1.2/1.8 tiles."
	/// For each structure, the additional radius to increase the ability by.
	var/radius_per_structure = 0.6

/datum/mutation_upgrade/veil/wide_gas/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Emit Noxious Gas now emits non-opaque gas instead. The radius of the gas is increased by [radius_per_structure * new_amount] tiles."

/datum/mutation_upgrade/veil/wide_gas/on_mutation_enabled()
	var/datum/action/ability/xeno_action/emit_neurogas/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/emit_neurogas]
	if(!ability)
		return FALSE
	ability.opaque_smoke = FALSE
	return ..()

/datum/mutation_upgrade/veil/wide_gas/on_mutation_disabled()
	var/datum/action/ability/xeno_action/emit_neurogas/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/emit_neurogas]
	if(!ability)
		return FALSE
	ability.opaque_smoke = initial(ability.opaque_smoke)
	return ..()

/datum/mutation_upgrade/veil/wide_gas/on_structure_update(previous_amount, new_amount)
	. = ..()
	if(!.)
		return
	var/datum/action/ability/xeno_action/emit_neurogas/ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/emit_neurogas]
	if(!ability)
		return FALSE
	ability.smoke_radius += (new_amount - previous_amount) * radius_per_structure
