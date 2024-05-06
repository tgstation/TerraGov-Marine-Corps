/**
 * # Component
 *
 * The component datum
 *
 * A component should be a single standalone unit
 * of functionality, that works by receiving signals from it's parent
 * object to provide some single functionality (i.e a slippery component)
 * that makes the object it's attached to cause people to slip over.
 * Useful when you want shared behaviour independent of type inheritance
 */
/datum/component
	/**
	  * Defines how duplicate existing components are handled when added to a datum
	  *
	  * See [COMPONENT_DUPE_*][COMPONENT_DUPE_ALLOWED] definitions for available options
	  */
	var/dupe_mode = COMPONENT_DUPE_HIGHLANDER

	/**
	  * The type to check for duplication
	  *
	  * `null` means exact match on `type` (default)
	  *
	  * Any other type means that and all subtypes
	  */
	var/dupe_type

	/// The datum this components belongs to
	var/datum/parent

	/**
	  * Only set to true if you are able to properly transfer this component
	  *
	  * At a minimum [RegisterWithParent][/datum/component/proc/RegisterWithParent] and [UnregisterFromParent][/datum/component/proc/UnregisterFromParent] should be used
	  *
	  * Make sure you also implement [PostTransfer][/datum/component/proc/PostTransfer] for any post transfer handling
	  */
	var/can_transfer = FALSE

	/// A lazy list of the sources for this component
	var/list/sources

/**
 * Create a new component.
 *
 * Additional arguments are passed to [Initialize()][/datum/component/proc/Initialize]
 *
 * Arguments:
 * * datum/P the parent datum this component reacts to signals from
 */
/datum/component/New(list/raw_args)
	parent = raw_args[1]
	var/list/arguments = raw_args.Copy(2)
	if(Initialize(arglist(arguments)) == COMPONENT_INCOMPATIBLE)
		qdel(src, TRUE, TRUE)
		CRASH("Incompatible [type] assigned to a [parent.type]! args: [json_encode(arguments)]")

	_JoinParent(parent)

/**
 * Called during component creation with the same arguments as in new excluding parent.
 *
 * Do not call `qdel(src)` from this function, `return COMPONENT_INCOMPATIBLE` instead
 */
/datum/component/proc/Initialize(...)
	return

/**
 * Properly removes the component from `parent` and cleans up references
 *
 * Arguments:
 * * force - makes it not check for and remove the component from the parent
 * * silent - deletes the component without sending a [COMSIG_COMPONENT_REMOVING] signal
 */
/datum/component/Destroy(force=FALSE, silent=FALSE)
	if(!force && parent)
		_RemoveFromParent()
	if(!silent)
		SEND_SIGNAL(parent, COMSIG_COMPONENT_REMOVING, src)
	parent = null
	return ..()

/**
 * Internal proc to handle behaviour of components when joining a parent
 */
/datum/component/proc/_JoinParent()
	var/datum/P = parent
	//lazy init the parent's dc list
	var/list/dc = P._datum_components
	if(!dc)
		P._datum_components = dc = list()

	//set up the typecache
	var/our_type = type
	for(var/I in _GetInverseTypeList(our_type))
		var/test = dc[I]
		if(test)	//already another component of this type here
			var/list/components_of_type
			if(!length(test))
				components_of_type = list(test)
				dc[I] = components_of_type
			else
				components_of_type = test
			if(I == our_type)	//exact match, take priority
				var/inserted = FALSE
				for(var/J in 1 to length(components_of_type))
					var/datum/component/C = components_of_type[J]
					if(C.type != our_type) //but not over other exact matches
						components_of_type.Insert(J, I)
						inserted = TRUE
						break
				if(!inserted)
					components_of_type += src
			else	//indirect match, back of the line with ya
				components_of_type += src
		else	//only component of this type, no list
			dc[I] = src

	RegisterWithParent()

/**
 * Internal proc to handle behaviour when being removed from a parent
 */
/datum/component/proc/_RemoveFromParent()
	var/datum/P = parent
	var/list/dc = P._datum_components
	for(var/I in _GetInverseTypeList())
		var/list/components_of_type = dc[I]
		if(length(components_of_type))	//
			var/list/subtracted = components_of_type - src
			if(length(subtracted) == 1)	//only 1 guy left
				dc[I] = subtracted[1]	//make him special
			else
				dc[I] = subtracted
		else	//just us
			dc -= I
	if(!length(dc))
		P._datum_components = null

	UnregisterFromParent()

/**
 * Register the component with the parent object
 *
 * Use this proc to register with your parent object
 *
 * Overridable proc that's called when added to a new parent
 */
/datum/component/proc/RegisterWithParent()
	return

/**
 * Unregister from our parent object
 *
 * Use this proc to unregister from your parent object
 *
 * Overridable proc that's called when removed from a parent
 * *
 */
/datum/component/proc/UnregisterFromParent()
	return

/**
 * Called when the component has a new source registered.
 * Return COMPONENT_INCOMPATIBLE to signal that the source is incompatible and should not be added
 */
/datum/component/proc/on_source_add(source, ...)
	SHOULD_CALL_PARENT(TRUE)
	if(dupe_mode != COMPONENT_DUPE_SOURCES)
		return COMPONENT_INCOMPATIBLE
	LAZYOR(sources, source)

/**
 * Called when the component has a source removed.
 * You probably want to call parent after you do your logic because at the end of this we qdel if we have no sources remaining!
 */
/datum/component/proc/on_source_remove(source)
	SHOULD_CALL_PARENT(TRUE)
	if(dupe_mode != COMPONENT_DUPE_SOURCES)
		CRASH("Component '[type]' does not use sources but is trying to remove a source")
	LAZYREMOVE(sources, source)
	if(!LAZYLEN(sources))
		qdel(src)

/**
 * Called on a component when a component of the same type was added to the same parent
 *
 * See [/datum/component/var/dupe_mode]
 *
 * `C`'s type will always be the same of the called component
 */
/datum/component/proc/InheritComponent(datum/component/C, i_am_original)
	return


/**
 * Called on a component when a component of the same type was added to the same parent with [COMPONENT_DUPE_SELECTIVE]
 *
 * See [/datum/component/var/dupe_mode]
 *
 * `C`'s type will always be the same of the called component
 *
 * return TRUE if you are absorbing the component, otherwise FALSE if you are fine having it exist as a duplicate component
 */
/datum/component/proc/CheckDupeComponent(datum/component/C, ...)
	return


/**
 * Callback Just before this component is transferred
 *
 * Use this to do any special cleanup you might need to do before being deregged from an object
 */
/datum/component/proc/PreTransfer()
	return

/**
 * Callback Just after a component is transferred
 *
 * Use this to do any special setup you need to do after being moved to a new object
 *
 * Do not call `qdel(src)` from this function, `return COMPONENT_INCOMPATIBLE` instead
 */
/datum/component/proc/PostTransfer()
	return COMPONENT_INCOMPATIBLE //Do not support transfer by default as you must properly support it

/**
 * Internal proc to create a list of our type and all parent types
 */
/datum/component/proc/_GetInverseTypeList(our_type = type)
	//we can do this one simple trick
	var/current_type = parent_type
	. = list(our_type, current_type)
	//and since most components are root level + 1, this won't even have to run
	while (current_type != /datum/component)
		current_type = type2parent(current_type)
		. += current_type

// The type arg is casted so initial works, you shouldn't be passing a real instance into this
/**
 * Return any component assigned to this datum of the given type
 *
 * This will throw an error if it's possible to have more than one component of that type on the parent
 *
 * Arguments:
 * * datum/component/c_type The typepath of the component you want to get a reference to
 */
/datum/proc/GetComponent(datum/component/c_type)
	RETURN_TYPE(c_type)
	if(initial(c_type.dupe_mode) == COMPONENT_DUPE_ALLOWED || initial(c_type.dupe_mode) == COMPONENT_DUPE_SELECTIVE)
		stack_trace("GetComponent was called to get a component of which multiple copies could be on an object. This can easily break and should be changed. Type: \[[c_type]\]")
	var/list/dc = _datum_components
	if(!dc)
		return null
	. = dc[c_type]
	if(length(.))
		return .[1]

// The type arg is casted so initial works, you shouldn't be passing a real instance into this
/**
 * Return any component assigned to this datum of the exact given type
 *
 * This will throw an error if it's possible to have more than one component of that type on the parent
 *
 * Arguments:
 * * datum/component/c_type The typepath of the component you want to get a reference to
 */
/datum/proc/GetExactComponent(datum/component/c_type)
	RETURN_TYPE(c_type)
	if(initial(c_type.dupe_mode) == COMPONENT_DUPE_ALLOWED || initial(c_type.dupe_mode) == COMPONENT_DUPE_SELECTIVE)
		stack_trace("GetComponent was called to get a component of which multiple copies could be on an object. This can easily break and should be changed. Type: \[[c_type]\]")
	var/list/dc = _datum_components
	if(!dc)
		return null
	var/datum/component/C = dc[c_type]
	if(C)
		if(length(C))
			C = C[1]
		if(C.type == c_type)
			return C
	return null

/**
 * Get all components of a given type that are attached to this datum
 *
 * Arguments:
 * * c_type The component type path
 */
/datum/proc/GetComponents(c_type)
	var/list/dc = _datum_components
	if(!dc)
		return null
	. = dc[c_type]
	if(!length(.))
		return list(.)

/**
 * Creates an instance of `new_type` in the datum and attaches to it as parent
 *
 * Sends the [COMSIG_COMPONENT_ADDED] signal to the datum
 *
 * Returns the component that was created. Or the old component in a dupe situation where [COMPONENT_DUPE_UNIQUE] was set
 *
 * If this tries to add an component to an incompatible type, the component will be deleted and the result will be `null`. This is very unperformant, try not to do it
 *
 * Properly handles duplicate situations based on the `dupe_mode` var
 */
/datum/proc/_AddComponent(list/raw_args, source)
	var/original_type = raw_args[1]
	var/datum/component/component_type = original_type

	if(QDELING(src))
		CRASH("Attempted to add a new component of type \[[component_type]\] to a qdeleting parent of type \[[type]\]!")

	var/datum/component/new_component

	if(!ispath(component_type, /datum/component))
		if(!istype(component_type, /datum/component))
			CRASH("Attempted to instantiate \[[component_type]\] as a component added to parent of type \[[type]\]!")
		else
			new_component = component_type
			component_type = new_component.type
	else if(component_type == /datum/component)
		CRASH("[component_type] attempted instantiation!")

	var/dupe_mode = initial(component_type.dupe_mode)
	var/dupe_type = initial(component_type.dupe_type)
	var/uses_sources = (dupe_mode == COMPONENT_DUPE_SOURCES)
	if(uses_sources && !source)
		CRASH("Attempted to add a sourced component of type '[component_type]' to '[type]' without a source!")
	else if(!uses_sources && source)
		CRASH("Attempted to add a normal component of type '[component_type]' to '[type]' with a source!")

	var/datum/component/old_component

	raw_args[1] = src
	if(dupe_mode != COMPONENT_DUPE_ALLOWED && dupe_mode != COMPONENT_DUPE_SELECTIVE && dupe_mode != COMPONENT_DUPE_SOURCES)
		if(!dupe_type)
			old_component = GetExactComponent(component_type)
		else
			old_component = GetComponent(dupe_type)

		if(old_component)
			switch(dupe_mode)
				if(COMPONENT_DUPE_UNIQUE)
					if(!new_component)
						new_component = new component_type(raw_args)
					if(!QDELETED(new_component))
						old_component.InheritComponent(new_component, TRUE)
						QDEL_NULL(new_component)

				if(COMPONENT_DUPE_HIGHLANDER)
					if(!new_component)
						new_component = new component_type(raw_args)
					if(!QDELETED(new_component))
						new_component.InheritComponent(old_component, FALSE)
						QDEL_NULL(old_component)

				if(COMPONENT_DUPE_UNIQUE_PASSARGS)
					if(!new_component)
						var/list/arguments = raw_args.Copy(2)
						arguments.Insert(1, null, TRUE)
						old_component.InheritComponent(arglist(arguments))
					else
						old_component.InheritComponent(new_component, TRUE)

				if(COMPONENT_DUPE_SOURCES)
					if(source in old_component.sources)
						return old_component // source already registered, no work to do

					if(old_component.on_source_add(arglist(list(source) + raw_args.Copy(2))) == COMPONENT_INCOMPATIBLE)
						stack_trace("incompatible source added to a [old_component.type]. Args: [json_encode(raw_args)]")
						return null

		else if(!new_component)
			new_component = new component_type(raw_args) // There's a valid dupe mode but there's no old component, act like normal

	else if(dupe_mode == COMPONENT_DUPE_SELECTIVE)
		var/list/arguments = raw_args.Copy()
		arguments[1] = new_component
		var/make_new_component = TRUE
		for(var/datum/component/existing_component as anything in GetComponents(original_type))
			if(existing_component.CheckDupeComponent(arglist(arguments)))
				make_new_component = FALSE
				QDEL_NULL(new_component)
				break
		if(!new_component && make_new_component)
			new_component = new component_type(raw_args)

	else if(dupe_mode == COMPONENT_DUPE_SOURCES)
		new_component = new component_type(raw_args)
		if(new_component.on_source_add(arglist(list(source) + raw_args.Copy(2))) == COMPONENT_INCOMPATIBLE)
			stack_trace("incompatible source added to a [new_component.type]. Args: [json_encode(raw_args)]")
			return null

	else if(!new_component)
		new_component = new component_type(raw_args) // Dupes are allowed, act like normal

	if(!old_component && !QDELETED(new_component)) // Nothing related to duplicate components happened and the new component is healthy
		SEND_SIGNAL(src, COMSIG_COMPONENT_ADDED, new_component)
		return new_component

	return old_component

/**
 * Removes a component source from this datum
 */
/datum/proc/RemoveComponentSource(source, datum/component/component_type)
	if(ispath(component_type))
		component_type = GetExactComponent(component_type)
	if(!component_type)
		return
	component_type.on_source_remove(source)

/**
 * Get existing component of type, or create it and return a reference to it
 *
 * Use this if the item needs to exist at the time of this call, but may not have been created before now
 *
 * Arguments:
 * * component_type The typepath of the component to create or return
 * * ... additional arguments to be passed when creating the component if it does not exist
 */
/datum/proc/_LoadComponent(list/arguments)
	. = GetComponent(arguments[1])
	if(!.)
		return _AddComponent(arguments)

/**
 * Removes the component from parent, ends up with a null parent
 */
/datum/component/proc/RemoveComponent()
	if(!parent)
		return
	var/datum/old_parent = parent
	PreTransfer()
	_RemoveFromParent()
	parent = null
	SEND_SIGNAL(old_parent, COMSIG_COMPONENT_REMOVING, src)

/**
 * Transfer this component to another parent
 *
 * Component is taken from source datum
 *
 * Arguments:
 * * datum/component/target Target datum to transfer to
 */
/datum/proc/TakeComponent(datum/component/target)
	if(!target || target.parent == src)
		return
	if(target.parent)
		target.RemoveComponent()
	target.parent = src
	var/result = target.PostTransfer()
	switch(result)
		if(COMPONENT_INCOMPATIBLE)
			var/c_type = target.type
			qdel(target)
			CRASH("Incompatible [c_type] transfer attempt to a [type]!")

	if(target == AddComponent(target))
		target._JoinParent()

/**
 * Transfer all components to target
 *
 * All components from source datum are taken
 *
 * Arguments:
 * * /datum/target the target to move the components to
 */
/datum/proc/TransferComponents(datum/target)
	var/list/dc = _datum_components
	if(!dc)
		return
	var/comps = dc[/datum/component]
	if(islist(comps))
		for(var/datum/component/I in comps)
			if(I.can_transfer)
				target.TakeComponent(I)
	else
		var/datum/component/C = comps
		if(C.can_transfer)
			target.TakeComponent(comps)

/**
 * Return the object that is the host of any UI's that this component has
 */
/datum/component/ui_host()
	return parent
