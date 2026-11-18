//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/unmoving_link
	name = "Unmoving Link"
	desc = "While Psychic Link is active, you gain maximum movement resistance and gain 15 armor."
	///The amount of soft armor that Psychic Link grants while it is active.
	var/armor = 15

/datum/mutation_upgrade/shell/unmoving_link/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!link_ability)
		return
	link_ability.armor_amount += armor
	link_ability.movement_resistance = MOVE_FORCE_OVERPOWERING
	if(!link_ability.psychic_link_status_effect)
		return
	xenomorph_owner.set_move_resist(link_ability.movement_resistance)
	if(!link_ability.attached_armor)
		link_ability.attached_armor = getArmor(link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount, link_ability.armor_amount)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.attachArmor(link_ability.attached_armor)

/datum/mutation_upgrade/shell/unmoving_link/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!link_ability)
		return
	link_ability.armor_amount -= armor
	link_ability.movement_resistance = initial(link_ability.movement_resistance)
	if(!link_ability.psychic_link_status_effect)
		return
	xenomorph_owner.set_move_resist(initial(xenomorph_owner.move_resist))
	if(link_ability.attached_armor)
		xenomorph_owner.soft_armor = xenomorph_owner.soft_armor.detachArmor(link_ability.attached_armor)
		link_ability.attached_armor = null

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/necrotic_link
	name = "Necrotic Link"
	desc = "Psychic Link no longer forces you to rest. While it is active, Drain is only 30% effective on corpses."
	/// The multiplier to add to Drain's corpse healing while Psychic Link is active.
	var/multiplier = -0.7

/datum/mutation_upgrade/spur/necrotic_link/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!link_ability)
		return
	link_ability.set_required_rest(FALSE)
	link_ability.drain_healing_multiplier += multiplier

/datum/mutation_upgrade/spur/necrotic_link/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_link/link_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_link]
	if(!link_ability)
		return
	link_ability.set_required_rest(initial(link_ability.required_rest))
	link_ability.drain_healing_multiplier -= multiplier

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/burst_healing
	name = "Burst Healing"
	desc = "Transfusion heals an additional 12% maximum health. The plasma cost is set to 175% of its their original value."
	/// The multiplier to increase Transfusion's plasma cost by.
	var/cost_multiplier = 0.75
	/// The percentage to add to Transfusion's maximum health healing percentage. 1 = 100% of maximum health, 0.01 = 1% of maximum health.
	var/heal_percentage = 0.12

/datum/mutation_upgrade/veil/burst_healing/on_mutation_enabled()
	. = ..()
	var/datum/action/ability/activable/xeno/transfusion/transfusion_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/transfusion]
	if(!transfusion_ability)
		return
	transfusion_ability.ability_cost += initial(transfusion_ability.ability_cost) * cost_multiplier
	transfusion_ability.heal_percentage += heal_percentage

/datum/mutation_upgrade/veil/burst_healing/on_mutation_disabled()
	. = ..()
	var/datum/action/ability/activable/xeno/transfusion/transfusion_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/transfusion]
	if(!transfusion_ability)
		return
	transfusion_ability.ability_cost -= initial(transfusion_ability.ability_cost) * cost_multiplier
	transfusion_ability.heal_percentage -= heal_percentage
