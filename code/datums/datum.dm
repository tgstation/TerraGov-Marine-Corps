/datum
	var/gc_destroyed //Time when this object was destroyed.
	var/list/active_timers  //for SStimer
	var/list/status_traits
	var/datum_flags = NONE
	var/datum/weakref/weak_reference
	var/hidden_from_codex = FALSE //set to TRUE if you want something to be hidden.
	var/interaction_flags = NONE //Defined at the datum level since some can be interacted with.

	/**
	  * Components attached to this datum
	  *
	  * Lazy associated list in the structure of `type:component/list of components`
	  */
	var/list/datum_components
	/**
	  * Any datum registered to receive signals from this datum is in this list
	  *
	  * Lazy associated list in the structure of `signal:registree/list of registrees`
	  */
	var/list/comp_lookup
	/// Lazy associated list in the structure of `signals:proctype` that are run when the datum receives that signal
	var/list/list/datum/callback/signal_procs
	/**
	  * Is this datum capable of sending signals?
	  *
	  * Set to true when a signal has been registered
	  */
	var/signal_enabled = FALSE

#ifdef TESTING
	var/running_find_references
	var/last_find_references = 0
#endif

#ifdef DATUMVAR_DEBUGGING_MODE
	var/list/cached_vars
#endif

// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy(force=FALSE, ...)
	SHOULD_CALL_PARENT(TRUE)
	tag = null
	datum_flags &= ~DF_USE_TAG //In case something tries to REF us
	weak_reference = null	//ensure prompt GCing of weakref.

	var/list/timers = active_timers
	active_timers = null
	for(var/thing in timers)
		var/datum/timedevent/timer = thing
		if (timer.spent)
			continue
		qdel(timer)

	return QDEL_HINT_QUEUE

#ifdef DATUMVAR_DEBUGGING_MODE
/datum/proc/save_vars()
	cached_vars = list()
	for(var/i in vars)
		if(i == "cached_vars")
			continue
		cached_vars[i] = vars[i]

/datum/proc/check_changed_vars()
	. = list()
	for(var/i in vars)
		if(i == "cached_vars")
			continue
		if(cached_vars[i] != vars[i])
			.[i] = list(cached_vars[i], vars[i])

/datum/proc/txt_changed_vars()
	var/list/l = check_changed_vars()
	var/t = "[src]([REF(src)]) changed vars:"
	for(var/i in l)
		t += "\"[i]\" \[[l[i][1]]\] --> \[[l[i][2]]\] "
	t += "."

/datum/proc/to_chat_check_changed_vars(target = world)
	to_chat(target, txt_changed_vars())
#endif

//Return a LIST for serialize_datum to encode! Not the actual json!
/datum/proc/serialize_list(list/options)
	CRASH("Attempted to serialize datum [src] of type [type] without serialize_list being implemented!")

//Accepts a LIST from deserialize_datum. Should return src or another datum.
/datum/proc/deserialize_list(json, list/options)
	CRASH("Attempted to deserialize datum [src] of type [type] without deserialize_list being implemented!")

//Serializes into JSON. Does not encode type.
/datum/proc/serialize_json(list/options)
	. = serialize_list(options)
	if(!islist(.))
		. = null
	else
		. = json_encode(.)

//Deserializes from JSON. Does not parse type.
/datum/proc/deserialize_json(list/input, list/options)
	var/list/jsonlist = json_decode(input)
	. = deserialize_list(jsonlist)
	if(!istype(., /datum))
		. = null

/proc/json_serialize_datum(datum/D, list/options)
	if(!istype(D))
		return
	var/list/jsonlist = D.serialize_list(options)
	if(islist(jsonlist))
		jsonlist["DATUM_TYPE"] = D.type
	return json_encode(jsonlist)

/proc/json_deserialize_datum(list/jsonlist, list/options, target_type, strict_target_type = FALSE)
	if(!islist(jsonlist))
		if(!istext(jsonlist))
			CRASH("Invalid JSON")
		jsonlist = json_decode(jsonlist)
		if(!islist(jsonlist))
			CRASH("Invalid JSON")
	if(!jsonlist["DATUM_TYPE"])
		return
	if(!ispath(jsonlist["DATUM_TYPE"]))
		if(!istext(jsonlist["DATUM_TYPE"]))
			return
		jsonlist["DATUM_TYPE"] = text2path(jsonlist["DATUM_TYPE"])
		if(!ispath(jsonlist["DATUM_TYPE"]))
			return
	if(target_type)
		if(!ispath(target_type))
			return
		if(strict_target_type)
			if(target_type != jsonlist["DATUM_TYPE"])
				return
		else if(!ispath(jsonlist["DATUM_TYPE"], target_type))
			return
	var/typeofdatum = jsonlist["DATUM_TYPE"]			//BYOND won't directly read if this is just put in the line below, and will instead runtime because it thinks you're trying to make a new list?
	var/datum/D = new typeofdatum
	var/datum/returned = D.deserialize_list(jsonlist, options)
	if(!istype(returned, /datum))
		qdel(D)
	else
		return returned


/datum/Topic(href, list/href_list)
	. = ..()
	if(.)
		return

	if(!can_interact(usr))
		return TRUE

	SEND_SIGNAL(src, COMSIG_TOPIC, usr, href_list)


/datum/proc/can_interact(mob/user)
	if(!user.can_interact_with(src))
		return FALSE
	return TRUE


/datum/proc/on_set_interaction(mob/user)
	return


/datum/proc/on_unset_interaction(mob/user)
	return


/datum/proc/check_eye()
	return


/datum/proc/interact(mob/user) //Return value = handled (same as attack_hand)
	user.set_interaction(src)
	if(interaction_flags & INTERACT_UI_INTERACT)
		return ui_interact(user)
	return FALSE
