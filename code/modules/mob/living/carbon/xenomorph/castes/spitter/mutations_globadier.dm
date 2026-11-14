//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/self_explosion
	name = "Self Explosion"
	desc = "Toss Grenade can target yourself. Targeting yourself will toss the grenade under you and reduce the detonation time by 0.75 seconds. The resulting detonation time can never go under 0.5 seconds."
	/// The amount of deciseconds to increase the detonation time by.
	var/duration_change = -0.75 SECONDS

/datum/mutation_upgrade/shell/self_explosion/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.use_state_flags |= ABILITY_TARGET_SELF
	grenade_ability.bonus_self_detonation_time += duration_change

/datum/mutation_upgrade/shell/self_explosion/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.use_state_flags &= ~ABILITY_TARGET_SELF
	grenade_ability.bonus_self_detonation_time -= duration_change

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/blood_grenades
	name = "Blood Grenades"
	desc = "Toss Grenade will deal damage equal to 17.5% of your maximum health and allow you to throw a non-healing grenade if you had none."
	/// The percentage of maximum health to lose.
	var/percentage = 0.175 // 1 = 100%, 0.01 = 1%

/datum/mutation_upgrade/spur/blood_grenades/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.health_loss_percentage_per_grenade += percentage

/datum/mutation_upgrade/spur/blood_grenades/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.health_loss_percentage_per_grenade -= percentage

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/repurposed_capacity
	name = "Repurposed Capacity"
	desc = "Toss Grenade stores 2 less grenades, but recharges a grenade 4 seconds faster."
	/// The amount to increase Toss Grenade's maximum grenade capacity by.
	var/capacity = -2
	/// The amount of deciseconds to increase Toss Grenade's recharge cooldown by.
	var/recharge = -4 SECONDS

/datum/mutation_upgrade/veil/repurposed_capacity/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.max_grenades += capacity
	grenade_ability.grenade_cooldown += recharge
	grenade_ability.current_grenades = min(grenade_ability.current_grenades, grenade_ability.max_grenades)

/datum/mutation_upgrade/veil/repurposed_capacity/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/toss_grenade/grenade_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/toss_grenade]
	if(!grenade_ability)
		return
	grenade_ability.max_grenades -= capacity
	grenade_ability.grenade_cooldown -= recharge
