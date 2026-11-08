//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/shared_jelly
	name = "Shared Jelly"
	desc = "If you are under the effect of Resin Jelly, all thrown huggers gain fire immunity. Each thrown hugger reduce the duration of the effect by 3/2/1 seconds."
	/// For the first structure, the length in deciseconds that Throw Facehugger will decrease the owner's Resin Jelly Coating status effect by.
	var/length_initial = 4 SECONDS
	/// For each structure, the length in deciseconds that Throw Facehugger will decrease the owner's Resin Jelly Coating status effect by.
	var/length_per_structure = -1 SECONDS

/datum/mutation_upgrade/shell/shared_jelly/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If you are under the effect of Resin Jelly, all thrown huggers gain fire immunity. Each thrown hugger reduce the duration of the effect by [get_length(new_amount) / 10] seconds."

/datum/mutation_upgrade/shell/shared_jelly/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fire_immunity_transfer += get_length(0)
	return ..()

/datum/mutation_upgrade/shell/shared_jelly/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fire_immunity_transfer -= get_length(0)

/datum/mutation_upgrade/shell/shared_jelly/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fire_immunity_transfer += get_length(new_amount - previous_amount, FALSE)

/// Returns the length in deciseconds that Throw Facehugger will decrease the owner's Resin Jelly Coating status effect by.
/datum/mutation_upgrade/shell/shared_jelly/proc/get_length(structure_count, include_initial = TRUE)
	return (include_initial ? length_initial : 0) + (length_per_structure * structure_count)

/datum/mutation_upgrade/shell/hugger_overflow
	name = "Hugger Overflow"
	desc = "While you have 8/7/6 or more stored huggers, you will automatically drop one underneath you when you become staggered."
	/// For the first structure, the threshold of stored huggers that the owner must reach in order to drop one when staggered.
	var/threshold_initial = 9
	/// For each structure,  the amount to add to the threshold of stored huggers that the owner must reach in order to drop one when staggered.
	var/threshold_per_structure = -1

/datum/mutation_upgrade/shell/hugger_overflow/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "While you have [get_threshold(new_amount)] or more stored huggers, you will automatically drop a larval hugger underneath you when you become staggered."

/datum/mutation_upgrade/shell/hugger_overflow/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_STATUS_STAGGER, PROC_REF(on_staggered))
	return ..()

/datum/mutation_upgrade/shell/hugger_overflow/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_STATUS_STAGGER)
	return ..()

/// If the owner is reached and the threshold of stored huggers is reached, drop a larval hugger.
/datum/mutation_upgrade/shell/hugger_overflow/proc/on_staggered(datum/source, amount, ignore_canstun)
	if(get_threshold(get_total_structures()) > xenomorph_owner.huggers)
		return
	var/obj/item/clothing/mask/facehugger/new_hugger = new /obj/item/clothing/mask/facehugger/larval(get_turf(xenomorph_owner), xenomorph_owner.hivenumber, xenomorph_owner)
	step_away(new_hugger, xenomorph_owner, 1)
	addtimer(CALLBACK(new_hugger, TYPE_PROC_REF(/obj/item/clothing/mask/facehugger, go_active), TRUE), new_hugger.jump_cooldown)
	xenomorph_owner.huggers--

/// Returns the threshold of stored huggers that the owner must reach in order to drop one when staggered.
/datum/mutation_upgrade/shell/hugger_overflow/proc/get_threshold(structure_count, include_initial = TRUE)
	return (include_initial ? threshold_initial : 0) + (threshold_per_structure * structure_count)

/datum/mutation_upgrade/shell/recurring_panic
	name = "Recurring Panic"
	desc = "If you're not resting, Carrier Panic will automatically attempt to activate when possible. The cooldown duration is set to 20% of its original value. It only consumes 50/40/30% of your maximum plasma."
	/// For each structure, the multiplier to add to Carrier Panic's plasma consumption. 1 = 100% of the owner's maximum plasma. 0.1 = 10% of the owner's maximum plasma.
	var/multiplier_initial = -0.4
	/// For each structure, the multiplier to add to Carrier Panic's plasma consumption.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/shell/recurring_panic/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "If you're not resting, Carrier Panic will automatically attempt to activate when possible. The cooldown duration is to 20% of its original value. It only consumes [PERCENT(1 + get_multiplier(new_amount))]% of your maximum plasma."

/datum/mutation_upgrade/shell/recurring_panic/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/carrier_panic/panic_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/carrier_panic]
	if(!panic_ability)
		return
	RegisterSignal(xenomorph_owner, list(COMSIG_LIVING_UPDATE_HEALTH), PROC_REF(on_update_health))
	panic_ability.cooldown_duration -= initial(panic_ability.cooldown_duration) * 0.8
	panic_ability.succeed_cost += get_multiplier(0)

/datum/mutation_upgrade/shell/recurring_panic/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/carrier_panic/panic_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/carrier_panic]
	if(!panic_ability)
		return
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH)
	panic_ability.cooldown_duration += initial(panic_ability.cooldown_duration) * 0.8
	panic_ability.succeed_cost -= get_multiplier(0)

/datum/mutation_upgrade/shell/recurring_panic/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/carrier_panic/panic_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/carrier_panic]
	if(!panic_ability)
		return
	panic_ability.succeed_cost += get_multiplier(new_amount - previous_amount, FALSE)
	panic_ability.update_button_icon()

/// Returns the multiplier of Carrier Panic's initial plasma cost to add to the ability.
/datum/mutation_upgrade/shell/recurring_panic/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/// Checks if Carrier Panic can be activated and not resting. If so, activate it.
/datum/mutation_upgrade/shell/recurring_panic/proc/on_update_health()
	SIGNAL_HANDLER
	var/health = (xenomorph_owner.status_flags & GODMODE) ? xenomorph_owner.maxHealth : (xenomorph_owner.maxHealth - xenomorph_owner.getFireLoss() - xenomorph_owner.getBruteLoss())
	if(health <= xenomorph_owner.get_death_threshold())
		return
	var/datum/action/ability/xeno_action/carrier_panic/panic_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/carrier_panic]
	if(!panic_ability)
		return
	if(xenomorph_owner.resting || !panic_ability.action_cooldown_finished() || !panic_ability.can_use_action(silent = TRUE))
		return
	panic_ability.action_activate()

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/leapfrog
	name = "Leapfrog"
	desc = "Thrown huggers can now leap 1 tile at a time. All activation times are 0.8/0.7/0.6x of their original value, but will never be faster than 0.5s."
	/// The leap range modified to bring it down to 1. This is used to add back range if the mutation is removed.
	var/leap_range_modified = 0
	/// For the first structure, the multiplier to add towards the various activation times that thrown facehuggers via Throw Facehugger will have.
	var/multiplier_initial = -0.1
	/// For each structure, the multiplier to add towards the various activation times that thrown facehuggers via Throw Facehugger will have.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/spur/leapfrog/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Thrown huggers can now leap 1 tile at a time. All activation times are [1 + get_multiplier(new_amount)]x of their original value, but will never be faster than 0.5s."

/datum/mutation_upgrade/spur/leapfrog/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	leap_range_modified = (hugger_ability.leapping_range - 1)
	hugger_ability.leapping_range -= leap_range_modified
	hugger_ability.activation_time_multiplier += get_multiplier(0)

/datum/mutation_upgrade/spur/leapfrog/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.leapping_range += leap_range_modified
	leap_range_modified = 0
	hugger_ability.activation_time_multiplier -= get_multiplier(0)

/datum/mutation_upgrade/spur/leapfrog/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.activation_time_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add towards the various activation times that thrown facehuggers via Throw Facehugger will have.
/datum/mutation_upgrade/spur/leapfrog/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/spur/claw_delivered
	name = "Claw Delivered"
	desc = "Huggers from your eggs now have a reduced cast time against humans. The cast time is set to 60/50/40% of its original value."
	/// For the first structure, the multiplier to add to the Hugger's cast time when trying to attach to humans manually.
	var/multiplier_initial = -0.3
	/// For each structure, the multiplier to add to the Hugger's cast time when trying to attach to humans manually.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/spur/claw_delivered/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Huggers from your eggs now have a reduced cast time against humans. The cast time is set to [PERCENT(1 + get_multiplier(new_amount))]% of its original value."

/datum/mutation_upgrade/spur/claw_delivered/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	egg_ability.hand_attach_time_multiplier += get_multiplier(0)

/datum/mutation_upgrade/spur/claw_delivered/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	egg_ability.hand_attach_time_multiplier -= get_multiplier(0)

/datum/mutation_upgrade/spur/claw_delivered/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	egg_ability.hand_attach_time_multiplier += get_multiplier(new_amount - previous_amount, FALSE)

/// Returns the multiplier to add to the Hugger's cast time when trying to attach to humans manually.
/datum/mutation_upgrade/spur/claw_delivered/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/spur/fake_huggers
	name = "Fake Huggers"
	desc = "Thrown huggers will accompanied by a fake facehugger which will mimic their behavior. Their color will be changed to match 50/70/90% of the original hugger's color."
	/// For the first structure, the amount to add to Throw Huggers' gradiant to be applied to the fake huggers.
	var/gradiant_initial = 0.3
	/// For each structure, the amount to add to Throw Huggers' gradiant to be applied to the fake huggers.
	var/gradiant_per_structure = 0.2

/datum/mutation_upgrade/spur/fake_huggers/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Thrown huggers will accompanied by a fake facehugger which will mimic their behavior. Their color will be changed to match [PERCENT(get_gradiant(new_amount))]% of the original hugger's color."

/datum/mutation_upgrade/spur/fake_huggers/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fake_hugger_gradiant_percentage += get_gradiant(0)

/datum/mutation_upgrade/spur/fake_huggers/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fake_hugger_gradiant_percentage -= get_gradiant(0)

/datum/mutation_upgrade/spur/fake_huggers/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fake_hugger_gradiant_percentage += get_gradiant(new_amount - previous_amount, FALSE)

/// Returns the amount to add to Throw Huggers' gradiant to be applied to the fake huggers.
/datum/mutation_upgrade/spur/fake_huggers/proc/get_gradiant(structure_count, include_initial = TRUE)
	return (include_initial ? gradiant_initial : 0) + (gradiant_per_structure * structure_count)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/oviposition
	name = "Oviposition"
	desc = "Egg Lay now creates eggs with your selected type of hugger inside. The plasma cost is set to 50/40/30% of its their original value and its cooldown is set to 50% of its original value. You lose the ability, Spawn Huggers."
	/// For the first structure, the multiplier that will be added to the ability cost of Egg Lay.
	var/multiplier_initial = -0.4
	/// For each structure, the multiplier that will be added to the ability cost of Egg Lay.
	var/multiplier_per_structure = -0.1

/datum/mutation_upgrade/veil/oviposition/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Egg Lay now creates eggs with your selected type of hugger inside. The plasma cost is set to [PERCENT(1 + get_multiplier(new_amount))]% of its their original value and its cooldown is set to 50% of its original value. You lose the ability, Spawn Huggers."

/datum/mutation_upgrade/veil/oviposition/on_mutation_enabled()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	var/datum/action/ability/xeno_action/spawn_hugger/spawn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(spawn_ability)
		spawn_ability.remove_action(xenomorph_owner)
	egg_ability.use_selected_hugger = TRUE
	egg_ability.cooldown_duration -= initial(egg_ability.cooldown_duration) * 0.5
	egg_ability.ability_cost += initial(egg_ability.ability_cost) * get_multiplier(0)
	return ..()

/datum/mutation_upgrade/veil/oviposition/on_mutation_disabled()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	var/datum/action/ability/xeno_action/spawn_hugger/spawn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!spawn_ability)
		spawn_ability = new()
		spawn_ability.give_action(xenomorph_owner)
	egg_ability.use_selected_hugger = initial(egg_ability.use_selected_hugger)
	egg_ability.cooldown_duration += initial(egg_ability.cooldown_duration) * 0.5
	egg_ability.ability_cost -= initial(egg_ability.ability_cost) * get_multiplier(0)
	return ..()

/datum/mutation_upgrade/veil/oviposition/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	egg_ability.ability_cost += initial(egg_ability.ability_cost) * get_multiplier(new_amount - previous_amount, FALSE)

/datum/mutation_upgrade/veil/oviposition/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/spawn_hugger/spawn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(spawn_ability)
		spawn_ability.remove_action(xenomorph_owner)

/// Returns the multiplier that will be added to the ability cost of Egg Lay.
/datum/mutation_upgrade/veil/oviposition/proc/get_multiplier(structure_count, include_initial = TRUE)
	return (include_initial ? multiplier_initial : 0) + (multiplier_per_structure * structure_count)

/datum/mutation_upgrade/veil/life_for_life
	name = "Life for Life"
	desc = "Spawn Facehugger's cooldown is set to 70% of its original value and costs zero plasma, but will deal 50/40/30 true damage to you."
	/// For the first structure, the amount of damage.
	var/damage_initial = 60
	/// For each structure, the additional amount of damage.
	var/damage_per_structure = -10

/datum/mutation_upgrade/veil/life_for_life/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Spawn Facehugger's cooldown is set to 70% of its original value and costs zero plasma, but will deal [get_damage(new_amount)] true damage to you."

/datum/mutation_upgrade/veil/life_for_life/on_mutation_enabled()
	var/datum/action/ability/xeno_action/spawn_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!hugger_ability)
		return FALSE
	hugger_ability.ability_cost -= initial(hugger_ability.ability_cost)
	hugger_ability.cooldown_duration -= initial(hugger_ability.cooldown_duration) * 0.3
	hugger_ability.health_cost += get_damage(0)
	return ..()

/datum/mutation_upgrade/veil/life_for_life/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/xeno_action/spawn_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!hugger_ability)
		return
	hugger_ability.ability_cost += initial(hugger_ability.ability_cost)
	hugger_ability.cooldown_duration += initial(hugger_ability.cooldown_duration) * 0.3
	hugger_ability.health_cost -= get_damage(0)

/datum/mutation_upgrade/veil/life_for_life/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/spawn_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!hugger_ability)
		return
	hugger_ability.health_cost += get_damage(new_amount - previous_amount, FALSE)

/// Returns the multiplier that will be added to the ability cost of Egg Lay.
/datum/mutation_upgrade/veil/life_for_life/proc/get_damage(structure_count, include_initial = TRUE)
	return (include_initial ? damage_initial : 0) + (damage_per_structure * structure_count)

/datum/mutation_upgrade/veil/swarm_trap
	name = "Swarm Trap"
	desc = "Your newly created traps can fit an additional 1/2/3 huggers, but the stun duration divided by the amount of the hugger inside the trap."
	/// For each structure, the additional amount of huggers that can be stored in the traps.
	var/huggers_per_structure = 1

/datum/mutation_upgrade/veil/swarm_trap/get_desc_for_alert(new_amount)
	if(!new_amount)
		return ..()
	return "Your newly created traps can fit an additional [get_huggers(new_amount)] huggers, but the stun duration divided by the amount of the hugger inside the trap."

/datum/mutation_upgrade/veil/swarm_trap/on_structure_update(previous_amount, new_amount)
	. = ..()
	var/datum/action/ability/xeno_action/place_trap/trap_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_trap]
	if(!trap_ability)
		return
	trap_ability.trap_hugger_limit += get_huggers(new_amount - previous_amount)

/// Returns the additional amount of huggers that can be stored in the traps.
/datum/mutation_upgrade/veil/swarm_trap/proc/get_huggers(structure_count)
	return huggers_per_structure * structure_count

