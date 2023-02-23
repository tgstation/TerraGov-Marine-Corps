
/datum/component/linked_invincibility
	/// list of objects that we want to link to that need to be killed before parent can be attacked
	var/list/linked_objects
	/// original resistance flags when this component is attached
	var/resist_flags_initial

/datum/component/linked_invincibility/Initialize(list/attached_list)
	. = ..()
	if(!isatom(parent) || !length(attached_list))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent
	resist_flags_initial = atom_parent.resistance_flags
	atom_parent.resistance_flags = RESIST_ALL
	atom_parent.add_filter("invincibility_indicator", 1, outline_filter(1, COLOR_TEAL))
	linked_objects = attached_list.Copy()
	for(var/atom/target AS in linked_objects)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/on_qdel)

///handles checking if the target is still invincible as well as removing the destroyed object
/datum/component/linked_invincibility/proc/on_qdel(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	linked_objects -= source
	if(length(linked_objects))
		return
	qdel(src)

/datum/component/linked_invincibility/UnregisterFromParent()
	for(var/atom/target AS in linked_objects)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	linked_objects = null
	var/atom/atom_parent = parent
	atom_parent.resistance_flags = resist_flags_initial
	atom_parent.remove_filter("invincibility_indicator")
