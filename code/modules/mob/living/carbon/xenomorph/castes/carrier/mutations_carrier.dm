//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/shared_jelly
	name = "Shared Jelly"
	desc = "If you are under the effect of Resin Jelly, all thrown huggers gain fire immunity. Each thrown hugger reduce the duration of the effect by 2 seconds."
	/// The amount of deciseconds that Throw Facehugger will decrease the owner's Resin Jelly Coating status effect by.
	var/duration_reduction = 2 SECONDS

/datum/mutation_upgrade/shell/shared_jelly/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fire_immunity_transfer += duration_reduction

/datum/mutation_upgrade/shell/shared_jelly/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fire_immunity_transfer -= duration_reduction

/datum/mutation_upgrade/shell/hugger_overflow
	name = "Hugger Overflow"
	desc = "While you have 7 or more stored huggers, you will automatically drop one underneath you when you become staggered."
	/// The threshold of stored huggers that the owner must reach in order to drop one when staggered.
	var/threshold = 7

/datum/mutation_upgrade/shell/hugger_overflow/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, COMSIG_LIVING_STATUS_STAGGER, PROC_REF(on_staggered))

/datum/mutation_upgrade/shell/hugger_overflow/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_STATUS_STAGGER)

/// If the owner is staggered and the threshold of stored huggers is reached, drop a larval hugger.
/datum/mutation_upgrade/shell/hugger_overflow/proc/on_staggered(datum/source, amount, ignore_canstun)
	if(threshold > xenomorph_owner.huggers)
		return
	var/obj/item/clothing/mask/facehugger/new_hugger = new /obj/item/clothing/mask/facehugger/larval(get_turf(xenomorph_owner), xenomorph_owner.hivenumber, xenomorph_owner)
	step_away(new_hugger, xenomorph_owner, 1)
	addtimer(CALLBACK(new_hugger, TYPE_PROC_REF(/obj/item/clothing/mask/facehugger, go_active), TRUE), new_hugger.jump_cooldown)
	xenomorph_owner.huggers--

/datum/mutation_upgrade/shell/recurring_panic
	name = "Recurring Panic"
	desc = "If you're not resting, Carrier Panic will automatically attempt to activate when possible. The cooldown duration is set to 20% of its original value. It only consumes 40% of your maximum plasma."
	/// The multiplier to add to Carrier Panic's plasma consumption. 1 = 100% of the owner's maximum plasma. 0.1 = 10% of the owner's maximum plasma.
	var/multiplier = -0.6

/datum/mutation_upgrade/shell/recurring_panic/on_mutation_enabled()
	RegisterSignal(xenomorph_owner, list(COMSIG_LIVING_UPDATE_HEALTH), PROC_REF(on_update_health))
	var/datum/action/ability/xeno_action/carrier_panic/panic_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/carrier_panic]
	if(!panic_ability)
		return
	panic_ability.cooldown_duration -= initial(panic_ability.cooldown_duration) * 0.8
	panic_ability.succeed_cost += multiplier
	panic_ability.update_button_icon()

/datum/mutation_upgrade/shell/recurring_panic/on_mutation_disabled()
	UnregisterSignal(xenomorph_owner, COMSIG_LIVING_UPDATE_HEALTH)
	var/datum/action/ability/xeno_action/carrier_panic/panic_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/carrier_panic]
	if(!panic_ability)
		return
	panic_ability.cooldown_duration += initial(panic_ability.cooldown_duration) * 0.8
	panic_ability.succeed_cost -= multiplier
	panic_ability.update_button_icon()

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
	desc = "Thrown huggers can now leap 1 tile at a time. All activation times are 0.7x of their original value, but will never be faster than 0.5s."
	/// The leap range modified to bring it down to 1. This is used to add back range if the mutation is removed.
	var/leap_range_modified = 0
	/// The multiplier to add towards the various activation times that thrown facehuggers via Throw Facehugger will have.
	var/multiplier = -0.3

/datum/mutation_upgrade/spur/leapfrog/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	leap_range_modified = (hugger_ability.leapping_range - 1)
	hugger_ability.leapping_range -= leap_range_modified
	hugger_ability.activation_time_multiplier += multiplier

/datum/mutation_upgrade/spur/leapfrog/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.leapping_range += leap_range_modified
	leap_range_modified = 0
	hugger_ability.activation_time_multiplier -= multiplier

/datum/mutation_upgrade/spur/claw_delivered
	name = "Claw Delivered"
	desc = "Huggers from your eggs now have a reduced cast time against humans. The cast time is set to 50% of its original value."
	/// The multiplier to add to the Hugger's cast time when trying to attach to humans manually.
	var/multiplier = -0.5

/datum/mutation_upgrade/spur/claw_delivered/on_mutation_enabled()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	egg_ability.hand_attach_time_multiplier += multiplier

/datum/mutation_upgrade/spur/claw_delivered/on_mutation_disabled()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(!egg_ability)
		return
	egg_ability.hand_attach_time_multiplier -= multiplier

/datum/mutation_upgrade/spur/fake_huggers
	name = "Fake Huggers"
	desc = "Thrown huggers will accompanied by a fake facehugger which will mimic their behavior. Their color will be changed to match 70% of the original hugger's color."
	/// The amount to add to Throw Huggers' gradiant to be applied to the fake huggers.
	var/gradiant = 0.7

/datum/mutation_upgrade/spur/fake_huggers/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fake_hugger_gradiant_percentage += gradiant

/datum/mutation_upgrade/spur/fake_huggers/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/throw_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/throw_hugger]
	if(!hugger_ability)
		return
	hugger_ability.fake_hugger_gradiant_percentage -= gradiant

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/oviposition
	name = "Oviposition"
	desc = "Egg Lay now creates eggs with your selected type of hugger inside. The plasma cost is set to 40% of its their original value and its cooldown is set to 50% of its original value. You lose the ability, Spawn Huggers."
	/// The ability to be given back if the mutation is disabled.
	var/datum/action/ability/xeno_action/spawn_hugger/removed_ability
	/// The multiplier that will be added to the ability cost of Egg Lay.
	var/multiplier = -0.6

/datum/mutation_upgrade/veil/oviposition/on_mutation_enabled()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(egg_ability)
		egg_ability.use_selected_hugger = TRUE
		egg_ability.cooldown_duration -= initial(egg_ability.cooldown_duration) * 0.5
		egg_ability.ability_cost += initial(egg_ability.ability_cost) * multiplier
	var/datum/action/ability/xeno_action/spawn_hugger/spawn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(spawn_ability)
		removed_ability = spawn_ability
		removed_ability.remove_action(xenomorph_owner)

/datum/mutation_upgrade/veil/oviposition/on_mutation_disabled()
	var/datum/action/ability/xeno_action/lay_egg/egg_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/lay_egg]
	if(egg_ability)
		egg_ability.use_selected_hugger = initial(egg_ability.use_selected_hugger)
		egg_ability.cooldown_duration += initial(egg_ability.cooldown_duration) * 0.5
		egg_ability.ability_cost -= initial(egg_ability.ability_cost) * multiplier
	if(removed_ability)
		removed_ability.give_action(xenomorph_owner)
		removed_ability = null

/datum/mutation_upgrade/veil/oviposition/on_xenomorph_upgrade()
	var/datum/action/ability/xeno_action/spawn_hugger/spawn_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(spawn_ability)
		xenomorph_owner.remove_ability(spawn_ability) // Upgrading gives abilities we have removed, thus we need to delete them.

/datum/mutation_upgrade/veil/life_for_life
	name = "Life for Life"
	desc = "Spawn Facehugger's cooldown is set to 70% of its original value and costs zero plasma, but will deal 40 true damage to you."
	/// The amount of true damage to deal.
	var/damage = 40

/datum/mutation_upgrade/veil/life_for_life/on_mutation_enabled()
	var/datum/action/ability/xeno_action/spawn_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!hugger_ability)
		return
	hugger_ability.ability_cost -= initial(hugger_ability.ability_cost)
	hugger_ability.cooldown_duration -= initial(hugger_ability.cooldown_duration) * 0.3
	hugger_ability.health_cost += damage

/datum/mutation_upgrade/veil/life_for_life/on_mutation_disabled()
	var/datum/action/ability/xeno_action/spawn_hugger/hugger_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/spawn_hugger]
	if(!hugger_ability)
		return
	hugger_ability.ability_cost += initial(hugger_ability.ability_cost)
	hugger_ability.cooldown_duration += initial(hugger_ability.cooldown_duration) * 0.3
	hugger_ability.health_cost -= damage

/datum/mutation_upgrade/veil/swarm_trap
	name = "Swarm Trap"
	desc = "Your newly created traps can fit an additional 2 huggers, but the stun duration divided by the amount of the hugger inside the trap."
	/// The additional amount of huggers that can be stored in the traps.
	var/huggers = 2

/datum/mutation_upgrade/veil/swarm_trap/on_mutation_enabled()
	var/datum/action/ability/xeno_action/place_trap/trap_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_trap]
	if(!trap_ability)
		return
	trap_ability.trap_hugger_limit += huggers

/datum/mutation_upgrade/veil/swarm_trap/on_mutation_disabled()
	var/datum/action/ability/xeno_action/place_trap/trap_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/place_trap]
	if(!trap_ability)
		return
	trap_ability.trap_hugger_limit -= huggers
