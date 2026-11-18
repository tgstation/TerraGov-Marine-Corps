//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/healing_jab
	name = "Healing Jab"
	desc = "The effects of Jab from Conqueror's Will is replaced. It will instead heal you for 10% of your maximum health."
	/// The multiplier of the owner's maximium health that Jab from Conqueror's Will will heal.
	var/percentage = 0.1 // 1 = 100%. 0.01 = 1%

/datum/mutation_upgrade/shell/healing_jab/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/conqueror_will/will_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_will]
	if(!will_ability)
		return
	will_ability.jab_damage_multiplier = 0
	will_ability.jab_heal_percentage += percentage

/datum/mutation_upgrade/shell/healing_jab/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/conqueror_will/will_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_will]
	if(!will_ability)
		return
	will_ability.jab_damage_multiplier = initial(will_ability.jab_damage_multiplier)
	will_ability.jab_heal_percentage += percentage

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/telefrag
	name = "Telefrag"
	desc = "Domination's radius is reduced by 1, but knocked down for 0.8 seconds longer."
	/// The amount to change Domination's radius by.
	var/radius_change = -1
	/// The amount of deciseconds to add to Domination's knockdown duration.
	var/additional_duration = 0.8 SECONDS

/datum/mutation_upgrade/spur/telefrag/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/conqueror_domination/domination_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_domination]
	if(!domination_ability)
		return
	domination_ability.radius += radius_change
	domination_ability.knockdown_duration += additional_duration

/datum/mutation_upgrade/spur/telefrag/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/conqueror_domination/domination_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/conqueror_domination]
	if(!domination_ability)
		return
	domination_ability.radius -= radius_change
	domination_ability.knockdown_duration -= additional_duration

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/dasher
	name = "Dasher"
	desc = "Dash can be activated at will as long it has charges. It can store up to 3 charges which are given at the rate of 200% of the ability's original cooldown."
	/// The multiplier of Dash's initial cooldown in which a charge will be restored.
	var/cooldown_multiplier = 2
	/// The amount of charges to add to Dash.
	var/additional_charges = 2

/datum/mutation_upgrade/veil/dasher/on_mutation_enabled()
	var/datum/action/ability/xeno_action/conqueror_dash/dash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/conqueror_dash]
	if(!dash_ability)
		return
	dash_ability.cooldown_duration = 0.1 SECONDS
	dash_ability.set_maximum_charges(1 + additional_charges, initial(dash_ability.cooldown_duration) * cooldown_multiplier)

/datum/mutation_upgrade/veil/dasher/on_mutation_disabled()
	var/datum/action/ability/xeno_action/conqueror_dash/dash_ability = xenomorph_owner.actions_by_path[/datum/action/ability/xeno_action/conqueror_dash]
	if(!dash_ability)
		return
	dash_ability.cooldown_duration = initial(dash_ability.cooldown_duration)
	dash_ability.set_maximum_charges(1)
