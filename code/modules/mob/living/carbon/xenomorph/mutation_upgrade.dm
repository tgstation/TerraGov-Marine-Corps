/datum/mutation_upgrade
	/// The name that is displayed in the TGUI.
	var/name
	/// The description that is displayed in the TGUI.
	var/desc
	/// The category slot that this upgrade takes. This prevents the owner from buying additional mutation that have the same category.
	var/category
	/// The structure that needs to exist for a successful purchase.
	var/required_structure
	/// The typepath of the status effect to be applied.
	var/datum/status_effect/status_effect
	/// The applied status effect that was given to the owner.
	var/datum/status_effect/applied_status_effect
	/// The xenomorph owner of this mutation upgrade.
	var/mob/living/carbon/xenomorph/xenomorph_owner
	/// If the prospective xenomorph_owner already has one of these mutation types, they cannot get this mutation.
	var/list/datum/mutation_upgrade/conflicting_mutation_types = list()

/// Sets up the owner, applies the status effect for having the mutation, registers various signals, and then updates with current structure count.
/datum/mutation_upgrade/New(mob/living/carbon/xenomorph/new_xenomorph_owner)
	if(!new_xenomorph_owner)
		CRASH("/datum/mutation_upgrade created with no owner.")
	xenomorph_owner = new_xenomorph_owner
	xenomorph_owner.owned_mutations += src
	applied_status_effect = xenomorph_owner.apply_status_effect(status_effect)
	switch(required_structure)
		if(MUTATION_SHELL)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SHELL, PROC_REF(on_structure_change))
		if(MUTATION_SPUR)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SPUR, PROC_REF(on_structure_change))
		if(MUTATION_VEIL)
			RegisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_VEIL, PROC_REF(on_structure_change))
	RegisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE, TYPE_PROC_REF(/datum/mutation_upgrade, on_xenomorph_upgrade))
	on_structure_change(null, MUTATION_CHAMBER_MINIMUM, get_total_structures())

/// Removes the status effect for having the mutation, unregisters various signals, and then updates with zero structures.
/datum/mutation_upgrade/Destroy(force, ...)
	if(applied_status_effect)
		xenomorph_owner.remove_status_effect(status_effect)
	if(xenomorph_owner.owned_mutations.Find(src))
		xenomorph_owner.owned_mutations -= src
	switch(required_structure)
		if(MUTATION_SHELL)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SHELL)
		if(MUTATION_SPUR)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_SPUR)
		if(MUTATION_VEIL)
			UnregisterSignal(SSdcs, COMSIG_MUTATION_CHAMBER_VEIL)
	UnregisterSignal(xenomorph_owner, COMSIG_XENOMORPH_ABILITY_ON_UPGRADE)
	on_structure_change(null, get_total_structures())
	return ..()

/// Called whenever the mutation is created/deleted or when the amount of structures has changed.
/datum/mutation_upgrade/proc/on_structure_change(datum/source, previous_amount, new_amount)
	SIGNAL_HANDLER
	if(previous_amount == new_amount) // No change.
		return FALSE
	if(!previous_amount && new_amount) // The mutation is now enabled.
		on_mutation_enabled()
	if(previous_amount && !new_amount) // The mutation is now disabled.
		on_mutation_disabled()
	on_structure_update(previous_amount, new_amount)
	if(applied_status_effect?.linked_alert)
		handle_status_effect_alert(applied_status_effect.linked_alert, new_amount)
	return TRUE

/// Called whenever the mutation becomes enabled (going from zero structures to non-zero structures).
/datum/mutation_upgrade/proc/on_mutation_enabled()
	return TRUE

/// Called whenever the mutation becomes disabled (going from non-zero structures to zero structures).
/datum/mutation_upgrade/proc/on_mutation_disabled()
	return TRUE

/// Called whenever when the amount of structures has changed.
/datum/mutation_upgrade/proc/on_structure_update(previous_amount, new_amount)
	return TRUE

/// Updates the status effect alert's name and description.
/datum/mutation_upgrade/proc/handle_status_effect_alert(atom/movable/screen/alert/status_effect/alert, new_amount)
	alert.name = get_name_for_alert(new_amount)
	alert.desc = get_desc_for_alert(new_amount)

/// The name that the alert will have after updating.
/datum/mutation_upgrade/proc/get_name_for_alert(new_amount)
	return name

/// The desc that the alert will have after updating.
/datum/mutation_upgrade/proc/get_desc_for_alert(new_amount)
	if(!new_amount)
		return "This mutation has no effect as there are are no active [category] structures!"
	return desc

/// Called whenever the xenomorph owner is upgraded (e.g. normal to primordial).
/datum/mutation_upgrade/proc/on_xenomorph_upgrade()
	return TRUE

/// Gets the total amount of structures for the mutation.
/datum/mutation_upgrade/proc/get_total_structures()
	if(!xenomorph_owner || !required_structure)
		return 0
	switch(required_structure)
		if(MUTATION_SHELL)
			return clamp(length(xenomorph_owner.hive.shell_chambers), MUTATION_CHAMBER_MINIMUM, MUTATION_CHAMBER_MAXIMUM)
		if(MUTATION_SPUR)
			return clamp(length(xenomorph_owner.hive.spur_chambers), MUTATION_CHAMBER_MINIMUM, MUTATION_CHAMBER_MAXIMUM)
		if(MUTATION_VEIL)
			return clamp(length(xenomorph_owner.hive.veil_chambers), MUTATION_CHAMBER_MINIMUM, MUTATION_CHAMBER_MAXIMUM)

/datum/mutation_upgrade/shell
	category = MUTATION_SHELL
	required_structure = MUTATION_SHELL
	status_effect = STATUS_EFFECT_MUTATION_SHELL

/datum/mutation_upgrade/spur
	category = MUTATION_SPUR
	required_structure = MUTATION_SPUR
	status_effect = STATUS_EFFECT_MUTATION_SPUR

/datum/mutation_upgrade/veil
	category = MUTATION_VEIL
	required_structure = MUTATION_VEIL
	status_effect = STATUS_EFFECT_MUTATION_VEIL
