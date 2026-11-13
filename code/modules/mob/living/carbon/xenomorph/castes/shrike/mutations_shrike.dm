//*********************//
//        Shell        //
//*********************//
/datum/mutation_upgrade/shell/lone_healer
	name = "Lone Healer"
	desc = "Psychic Cure can now target yourself. Healing yourself is only 60% as effective."
	/// The multiplier of Psychic Cure's initial healing power to add to the ability.
	var/self_heal_multiplier = -0.4

/datum/mutation_upgrade/shell/lone_healer/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.use_state_flags |= ABILITY_TARGET_SELF
	cure_ability.self_heal_multiplier += self_heal_multiplier

/datum/mutation_upgrade/shell/lone_healer/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.use_state_flags &= ~(ABILITY_TARGET_SELF)
	cure_ability.self_heal_multiplier -= self_heal_multiplier

/datum/mutation_upgrade/shell/shared_cure
	name = "Shared Cure"
	desc = "35% of the health restored from Psychic Cure is reapplied to you."
	/// The percentage of restored health from Psychic Cure to heal the owner. 1 = 100%, 0.01 = 1%.
	var/percentage = 0.35

/datum/mutation_upgrade/shell/shared_cure/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.rebound_percentage += percentage

/datum/mutation_upgrade/shell/shared_cure/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.rebound_percentage -= percentage

/datum/mutation_upgrade/shell/resistant_cure
	name = "Resistant Cure"
	desc = "Psychic Cure now also applies the effects of resin jelly to you and your target for 50 seconds."
	/// The amount of deciseconds that Psychic Cure will give fire immunity.
	var/duration = 50 SECONDS

/datum/mutation_upgrade/shell/resistant_cure/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.resin_jelly_duration += duration

/datum/mutation_upgrade/shell/resistant_cure/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.resin_jelly_duration -= duration

//*********************//
//         Spur        //
//*********************//
/datum/mutation_upgrade/spur/smashing_fling
	name = "Smashing Fling"
	desc = "Psychic Fling deals 175% damage equal to your melee damage, enables collusions, but no longer immediately stuns. If the target collides with a human, object, or wall: both are briefly paralyzed and dealt damage again."
	/// The multiplier of the owner's melee damage to deal as both immediate and collusion damage.
	var/multiplier = 1.75

/datum/mutation_upgrade/spur/smashing_fling/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!fling_ability)
		return
	fling_ability.stun_duration = 0 SECONDS
	fling_ability.damage_multiplier += multiplier
	fling_ability.collusion_paralyze_duration = 0.1 SECONDS // This is honestly flavor.
	fling_ability.collusion_damage_multiplier += multiplier

/datum/mutation_upgrade/spur/smashing_fling/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!fling_ability)
		return
	fling_ability.stun_duration = initial(fling_ability.stun_duration)
	fling_ability.damage_multiplier -= multiplier
	fling_ability.collusion_paralyze_duration = initial(fling_ability.collusion_paralyze_duration)
	fling_ability.collusion_damage_multiplier -= multiplier

/datum/mutation_upgrade/spur/gravity_tide
	name = "Gravity Tide"
	desc = "Unrelenting Force pulls things towards you then pushes them away. The distance they are thrown is increased by 3."
	/// The amount of distance that Unrelenting Force will throw things.
	var/distance = 3

/datum/mutation_upgrade/spur/gravity_tide/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/unrelenting_force/force_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/unrelenting_force]
	if(!force_ability)
		return
	force_ability.rebound_throwing = TRUE
	force_ability.throwing_distance += distance

/datum/mutation_upgrade/spur/gravity_tide/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/unrelenting_force/force_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/unrelenting_force]
	if(!force_ability)
		return
	force_ability.rebound_throwing = initial(force_ability.rebound_throwing)
	force_ability.throwing_distance -= distance

/datum/mutation_upgrade/spur/body_fling
	name = "Body Fling"
	desc = "Psychic Fling can be used on yourself and allied xenomorphs. Humans who are hit by a flung xenomorph are paralyzed for 2 seconds and dealt 175% of your slash damage."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/veil/psychic_choke
	)
	/// The multiplier of the owner's slash damage dealt when a xenomorph flung by Psychic Fling collides with a human.
	var/multiplier = 1.75

/datum/mutation_upgrade/spur/body_fling/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!fling_ability)
		return
	fling_ability.use_state_flags |= ABILITY_TARGET_SELF
	fling_ability.collusion_damage_multiplier += multiplier
	fling_ability.collusion_paralyze_duration += 2 SECONDS
	fling_ability.collusion_xenos_only = TRUE

/datum/mutation_upgrade/spur/body_fling/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!fling_ability)
		return
	fling_ability.use_state_flags &= ~ABILITY_TARGET_SELF
	fling_ability.collusion_damage_multiplier -= multiplier
	fling_ability.collusion_paralyze_duration -= 2 SECONDS
	fling_ability.collusion_xenos_only = initial(fling_ability.collusion_xenos_only)

//*********************//
//         Veil        //
//*********************//
/datum/mutation_upgrade/veil/delayed_condition
	name = "Delayed Condition"
	desc = "Psychic Heal grants slowdown immunity and delays all inbound stun, knockdown, and stagger effects caused to your target by 10 seconds. At the end of this duration, delayed status effects are reapplied."
	/// The amount of deciseconds that Psychic Cure will delay various status effects by.
	var/duration = 10 SECONDS

/datum/mutation_upgrade/veil/delayed_condition/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.delayed_status_duration += duration

/datum/mutation_upgrade/veil/delayed_condition/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_cure/cure_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_cure]
	if(!cure_ability)
		return
	cure_ability.delayed_status_duration -= duration


/datum/mutation_upgrade/veil/deflective_force
	name = "Deflective Force"
	desc = "Unrelenting Force now reflects all projectiles in its affected area. Reflecting more than 50 projectile damage resets Psychic Scream's cooldown to 40% of its original value."
	/// The amount to multiply Psychic Scream's cooldown by if enough projectile damage was reflected.
	var/multiplier_initial = 0.4

/datum/mutation_upgrade/veil/deflective_force/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/unrelenting_force/force_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/unrelenting_force]
	if(!force_ability)
		return
	force_ability.projectile_cooldown_mulitplier += multiplier_initial

/datum/mutation_upgrade/veil/deflective_force/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/unrelenting_force/force_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/unrelenting_force]
	if(!force_ability)
		return
	force_ability.projectile_cooldown_mulitplier -= multiplier_initial

/datum/mutation_upgrade/veil/psychic_choke
	name = "Psychic Choke"
	desc = "You lose the ability Psychic Fling in exchange for the ability Psychic Choke. Psychic Choke lets you paralyze a marine as long you channel it. The damage threshold to disrupt Psychic Choke is 35."
	conflicting_mutation_types = list(
		/datum/mutation_upgrade/spur/body_fling
	)
	/// The amount to increase Psychic Choke's damage threshold.
	var/threshold = 35
	/// The ability to be given back if the mutation is disabled.
	var/datum/action/ability/activable/xeno/psychic_choke/removed_ability

/datum/mutation_upgrade/veil/psychic_choke/on_mutation_enabled()
	var/datum/action/ability/activable/xeno/psychic_choke/choke_ability = new()
	choke_ability.give_action(xenomorph_owner)
	var/datum/action/ability/activable/xeno/psychic_fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(fling_ability)
		removed_ability = fling_ability
		removed_ability.remove_action(xenomorph_owner)

/datum/mutation_upgrade/veil/psychic_choke/on_mutation_disabled()
	var/datum/action/ability/activable/xeno/psychic_choke/choke_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_choke]
	if(choke_ability)
		xenomorph_owner.remove_ability(choke_ability)
	if(removed_ability)
		removed_ability.give_action(xenomorph_owner)
		removed_ability = null

/datum/mutation_upgrade/veil/psychic_choke/on_xenomorph_upgrade()
	var/datum/action/ability/activable/xeno/psychic_fling/fling_ability = xenomorph_owner.actions_by_path[/datum/action/ability/activable/xeno/psychic_fling]
	if(!fling_ability)
		return
	xenomorph_owner.remove_ability(fling_ability) // Upgrading gives abilities we have removed, thus we need to delete them.
