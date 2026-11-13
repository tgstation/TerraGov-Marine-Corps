//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/flame_dance
	name = "Flame Dance"
	desc = "If you are on fire, Tail Trip and Tail Hook will extinguishes you and inflict nearby humans with an equal amount of melting fire. Your fire armor is reduced by 10."
	/// The amount of fire armor that should be given for having this mutation.
	var/armor = -10
	/// Armor attached to the xenomorph owner, if any.
	var/datum/armor/attached_armor

/datum/mutation_upgrade/shell/flame_dance/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/tail_trip/trip_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_trip]
	if(!trip_ability)
		return
	var/datum/action/ability/activable/xeno/tail_hook/hook_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!hook_ability)
		return
	trip_ability.spreads_fire = TRUE
	hook_ability.spreads_fire = TRUE
	if(!attached_armor)
		attached_armor = getArmor(fire = armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(attached_armor)

/datum/mutation_upgrade/shell/flame_dance/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/tail_trip/trip_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_trip]
	if(!trip_ability)
		return
	var/datum/action/ability/activable/xeno/tail_hook/hook_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!hook_ability)
		return
	trip_ability.spreads_fire = initial(trip_ability.spreads_fire)
	hook_ability.spreads_fire = initial(hook_ability.spreads_fire)
	if(attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(attached_armor)
		attached_armor = null

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/bob_and_weave
	name = "Bob and Weave"
	desc = "Tail Hook now pushes humans away instead of pulling them in. It deals 4 additional damage."
	/// The amount to increase the damage that Tail Hook deals by.
	var/damage = 4

/datum/mutation_upgrade/spur/bob_and_weave/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/tail_hook/hook_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!hook_ability)
		return
	hook_ability.bonus_damage += damage
	hook_ability.pull_distance *= -1 // Makes it negative (pushes them away).

/datum/mutation_upgrade/spur/bob_and_weave/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/tail_hook/hook_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/tail_hook]
	if(!hook_ability)
		return
	hook_ability.bonus_damage += damage
	hook_ability.pull_distance *= -1 // Makes it positive (pushes them in).

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/eb_and_flow
	name = "Eb and Flow"
	desc = "Dodge now lets you walk over structures such as tables and window frames. It now costs 1.75x of its original cost."
	/// The multiplier to add as Dodge's initial ability cost to the ability.
	var/cost_multiplier = 0.75

/datum/mutation_upgrade/veil/eb_and_flow/on_mutation_enabled()
	var/datum/action/ability/xeno_action/dodge/dodge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dodge]
	if(!dodge_ability)
		return
	if(dodge_ability.particle_holder) // This means it is active.
		dodge_ability.xeno_owner.allow_pass_flags |= PASS_LOW_STRUCTURE
		dodge_ability.xeno_owner.add_pass_flags(PASS_LOW_STRUCTURE, dodge_ability.type)
	dodge_ability.dodge_pass_flags |= PASS_LOW_STRUCTURE
	dodge_ability.ability_cost += initial(dodge_ability.ability_cost) * cost_multiplier

/datum/mutation_upgrade/veil/eb_and_flow/on_mutation_disabled()
	var/datum/action/ability/xeno_action/dodge/dodge_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/dodge]
	if(!dodge_ability)
		return
	if(dodge_ability.particle_holder) // This means it is active.
		dodge_ability.xeno_owner.allow_pass_flags &= ~(PASS_LOW_STRUCTURE)
		dodge_ability.xeno_owner.remove_pass_flags(PASS_LOW_STRUCTURE, dodge_ability.type)
	dodge_ability.dodge_pass_flags &= ~(PASS_LOW_STRUCTURE)
	dodge_ability.ability_cost -= initial(dodge_ability.ability_cost) * cost_multiplier
