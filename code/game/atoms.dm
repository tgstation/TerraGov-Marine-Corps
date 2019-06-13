/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	var/level = 2

	var/flags_atom = NONE
	var/datum/reagents/reagents = null

	var/list/fingerprints
	var/blood_color
	var/list/blood_DNA

	var/flags_pass = NONE
	var/throwpass = FALSE

	var/germ_level = GERM_LEVEL_AMBIENT // The higher the germ level, the more germ on the atom.

	var/list/priority_overlays	//overlays that should remain on top and not normally removed when using cut_overlay functions, like c4.
	var/list/remove_overlays // a very temporary list of overlays to remove
	var/list/add_overlays // a very temporary list of overlays to add

	var/list/display_icons // related to do_after/do_mob overlays, I can't get my hopes high.

	var/list/atom_colours	 //used to store the different colors on an atom
							//its inherent color, the colored paint applied on it, special color effect etc...

	var/list/image/hud_list //This atom's HUD (med/sec, etc) images. Associative list.

	var/datum/component/orbiter/orbiters
	var/datum/proximity_monitor/proximity_monitor

/*
We actually care what this returns, since it can return different directives.
Not specifically here, but in other variations of this. As a general safety,
Make sure the return value equals the return value of the parent so that the
directive is properly returned.
*/
//===========================================================================
/atom/Destroy()
	if(reagents)
		qdel(reagents)

	orbiters = null // The component is attached to us normaly and will be deleted elsewhere

	LAZYCLEARLIST(overlays)
	LAZYCLEARLIST(priority_overlays)

	QDEL_NULL(light)

	if(isturf(loc))
		loc.fingerprints = fingerprints

	return ..()

//===========================================================================



//atmos procs

//returns the atmos info relevant to the object (gas type, temperature, and pressure)
/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null


/atom/proc/return_pressure()
	if(loc)
		return loc.return_pressure()

/atom/proc/return_temperature()
	if(loc)
		return loc.return_temperature()

//returns the gas mix type
/atom/proc/return_gas()
	if(loc)
		return loc.return_gas()




/atom/proc/on_reagent_change()
	return

/atom/proc/Bumped(atom/movable/AM)
	return

/atom/proc/CanPass(atom/movable/mover, turf/target)
	//Purpose: Determines if the object can pass this atom.
	//Called by: Movement.
	//Inputs: The moving atom (optional), target turf
	//Outputs: Boolean if can pass.
	if(density)
		if( (flags_atom & ON_BORDER) && !(get_dir(loc, target) & dir) )
			return 1
		else
			return 0
	else
		return 1


/atom/proc/CheckExit(atom/movable/mover, turf/target)
	if(!density || !(flags_atom & ON_BORDER) || !(get_dir(mover.loc, target) & dir))
		return 1
	else
		return 0


// Convenience proc for reagents handling.
/atom/proc/is_open_container()
	return is_refillable() && is_drainable()

/atom/proc/is_injectable(allowmobs = TRUE)
	return reagents && CHECK_BITFIELD(reagents.reagent_flags, INJECTABLE | REFILLABLE)

/atom/proc/is_drawable(allowmobs = TRUE)
	return reagents && CHECK_BITFIELD(reagents.reagent_flags, DRAWABLE | DRAINABLE)

/atom/proc/is_refillable()
	return reagents && CHECK_BITFIELD(reagents.reagent_flags, REFILLABLE)

/atom/proc/is_drainable()
	return reagents && CHECK_BITFIELD(reagents.reagent_flags, DRAINABLE)


/atom/proc/HasProximity(atom/movable/AM)
	return


/atom/proc/emp_act(severity)
	return


/atom/proc/effect_smoke(obj/effect/particle_effect/smoke/S)
	if(S.lifetime < 1)
		return FALSE
	return TRUE


/*
 *	atom/proc/search_contents_for(path,list/filter_path=null)
 * Recursevly searches all atom contens (including contents contents and so on).
 *
 * ARGS: path - search atom contents for atoms of this type
 *	   list/filter_path - if set, contents of atoms not of types in this list are excluded from search.
 *
 * RETURNS: list of found atoms
 */

/atom/proc/search_contents_for(path,list/filter_path=null)
	var/list/found = list()
	for(var/atom/A in src)
		if(istype(A, path))
			found += A
		if(filter_path)
			var/pass = 0
			for(var/type in filter_path)
				pass |= istype(A, type)
			if(!pass)
				continue
		if(A.contents.len)
			found += A.search_contents_for(path,filter_path)
	return found


//mob verbs are faster than object verbs. See https://secure.byond.com/forum/?post=1326139&page=2#comment8198716 for why this isn't atom/verb/examine()
/mob/verb/examinate(atom/A as mob|obj|turf in view())
	set name = "Examine"
	set category = "IC"

	if(is_blind(src))
		to_chat(src, "<span class='notice'>Something is there but you can't see it.</span>")
		return

	face_atom(A)
	A.examine(src)


/atom/proc/examine(mob/user)
	if(!istype(src, /obj/item))
		to_chat(user, "[icon2html(src, user)] That's \a [src].")

	else // No component signaling, dropping it here.
		var/obj/item/I = src
		var/size
		switch(I.w_class)
			if(1)
				size = "tiny"
			if(2)
				size = "small"
			if(3)
				size = "normal-sized"
			if(4 to 5)
				size = "bulky"
			if(6 to INFINITY)
				size = "huge"
		to_chat(user, "This is a [blood_color ? blood_color != "#030303" ? "bloody " : "oil-stained " : ""][icon2html(src, user)][src.name]. It is a [size] item.")


	if(desc)
		to_chat(user, desc)

	if(get_dist(user,src) <= 2)
		if(reagents)
			if(CHECK_BITFIELD(reagents.reagent_flags, TRANSPARENT))
				to_chat(user, "It contains:")
				if(reagents.reagent_list.len) // TODO: Implement scan_reagent and can_see_reagents() to show each individual reagent
					var/total_volume = 0
					for(var/datum/reagent/R in reagents.reagent_list)
						total_volume += R.volume
					to_chat(user, "<span class='notice'>[total_volume] units of various reagents.</span>")
				else
					to_chat(user, "<span class='notice'>Nothing.")
			else if(CHECK_BITFIELD(reagents.reagent_flags, AMOUNT_VISIBLE))
				if(reagents.total_volume)
					to_chat(user, "<span class='notice'>It has [reagents.total_volume] unit\s left.</span>")
				else
					to_chat(user, "<span class='warning'>It's empty.</span>")
			else if(CHECK_BITFIELD(reagents.reagent_flags, AMOUNT_SKILLCHECK))
				if(isxeno(user))
					return
				if(!user.mind || !user.mind.cm_skills || user.mind.cm_skills.medical >= SKILL_MEDICAL_NOVICE) // If they have no skillset(admin-spawn, etc), or are properly skilled.
					to_chat(user, "It contains:")
					if(reagents.reagent_list.len)
						for(var/datum/reagent/R in reagents.reagent_list)
							to_chat(user, "[R.volume] units of [R.name]")
					else
						to_chat(user, "Nothing.")
				else
					to_chat(user, "You don't know what's in it.")
			else if(reagents.reagent_flags & AMOUNT_ESTIMEE)
				var/obj/item/reagent_container/C = src
				if(!reagents.total_volume)
					to_chat(user, "<span class='notice'>\The [src] is empty!</span>")
				else if (reagents.total_volume<= C.volume*0.3)
					to_chat(user, "<span class='notice'>\The [src] is almost empty!</span>")
				else if (reagents.total_volume<= C.volume*0.6)
					to_chat(user, "<span class='notice'>\The [src] is half full!</span>")
				else if (reagents.total_volume<= C.volume*0.9)
					to_chat(user, "<span class='notice'>\The [src] is almost full!</span>")
				else
					to_chat(user, "<span class='notice'>\The [src] is full!</span>")

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user)


// called by mobs when e.g. having the atom as their machine, pulledby, loc (AKA mob being inside the atom) or buckled var set.
// see code/modules/mob/mob_movement.dm for more.
/atom/proc/relaymove()
	return

/atom/proc/ex_act()
	return

/atom/proc/fire_act()
	return

/atom/proc/hitby(atom/movable/AM)
	if(density)
		AM.throwing = FALSE
	return


/atom/proc/GenerateTag()
	return


/atom/proc/prevent_content_explosion()
	return FALSE


//Generalized Fire Proc.
/atom/proc/flamer_fire_act()
	return


//things that object need to do when a movable atom inside it is deleted
/atom/proc/on_stored_atom_del(atom/movable/AM)
	return


// Generic logging helper
/atom/proc/log_message(message, message_type, color, log_globally = TRUE)
	if(!log_globally)
		return

	var/log_text = "[key_name(src)] [message] [AREACOORD(src)]"
	switch(message_type)
		if(LOG_ATTACK)
			log_attack(log_text)
		if(LOG_SAY)
			log_say(log_text)
		if(LOG_TELECOMMS)
			log_telecomms(log_text)
		if(LOG_WHISPER)
			log_whisper(log_text)
		if(LOG_HIVEMIND)
			log_hivemind(log_text)
		if(LOG_EMOTE)
			log_emote(log_text)
		if(LOG_DSAY)
			log_dsay(log_text)
		if(LOG_OOC)
			log_ooc(log_text)
		if(LOG_ADMIN)
			log_admin(log_text)
		if(LOG_LOOC)
			log_looc(log_text)
		if(LOG_ADMIN_PRIVATE)
			log_admin_private(log_text)
		if(LOG_ASAY)
			log_admin_private_asay(log_text)
		if(LOG_GAME)
			log_game(log_text)
		else
			stack_trace("Invalid individual logging type: [message_type]. Defaulting to [LOG_GAME] (LOG_GAME).")
			log_game(log_text)


// Helper for logging chat messages or other logs wiht arbitrary inputs (e.g. announcements)
/atom/proc/log_talk(message, message_type, tag, log_globally = TRUE)
	var/prefix = tag ? "([tag]) " : ""
	log_message("[prefix]\"[message]\"", message_type, log_globally=log_globally)


// Helper for logging of messages with only one sender and receiver
/proc/log_directed_talk(atom/source, atom/target, message, message_type, tag)
	if(!tag)
		stack_trace("Unspecified tag for private message")
		tag = "UNKNOWN"

	source.log_talk(message, message_type, tag="[tag] to [key_name(target)]")
	if(source != target)
		target.log_talk(message, message_type, tag="[tag] from [key_name(source)]", log_globally=FALSE)

/*
Proc for attack log creation, because really why not
1 argument is the actor performing the action
2 argument is the target of the action
3 is a verb describing the action (e.g. punched, throwed, kicked, etc.)
4 is a tool with which the action was made (usually an item)
5 is any additional text, which will be appended to the rest of the log line
*/

/proc/log_combat(atom/user, atom/target, what_done, atom/object, addition)
	var/ssource = key_name(user)
	var/starget = key_name(target)

	var/mob/living/living_target = target
	var/hp = istype(living_target) ? " (NEWHP: [living_target.health]) " : ""

	var/sobject = ""
	if(object)
		sobject = " with [key_name(object)]"
	var/saddition = ""
	if(addition)
		saddition = " [addition]"

	var/postfix = "[sobject][saddition][hp]"

	var/message = "has [what_done] [starget][postfix]"
	user.log_message(message, LOG_ATTACK, color = "#f46666")

	if(target && user != target)
		var/reverse_message = "has been [what_done] by [ssource][postfix]"
		target.log_message(reverse_message, LOG_ATTACK, color = "#eabd7e", log_globally = FALSE)


/atom/New(loc, ...)
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		GLOB._preloader.load(src)

	if(datum_flags & DF_USE_TAG)
		GenerateTag()

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			//we were deleted
			return

/*
	Atom Colour Priority System
	A System that gives finer control over which atom colour to colour the atom with.
	The "highest priority" one is always displayed as opposed to the default of
	"whichever was set last is displayed"
*/


/*
	Adds an instance of colour_type to the atom's atom_colours list
*/
/atom/proc/add_atom_colour(coloration, colour_priority)
	if(!atom_colours || !atom_colours.len)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > atom_colours.len)
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()


/*
	Removes an instance of colour_type from the atom's atom_colours list
*/
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	if(colour_priority > atom_colours.len)
		return
	if(coloration && atom_colours[colour_priority] != coloration)
		return //if we don't have the expected color (for a specific priority) to remove, do nothing
	atom_colours[colour_priority] = null
	update_atom_colour()


/*
	Resets the atom's color to null, and then sets it to the highest priority
	colour available
*/
/atom/proc/update_atom_colour()
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOUR_PRIORITY_AMOUNT //four priority levels currently.
	color = null
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(L.len)
				color = L
				return
		else if(C)
			color = C
			return

//Called after New if the map is being loaded. mapload = TRUE
//Called from base of New if the map is not being loaded. mapload = FALSE
//This base must be called or derivatives must set initialized to TRUE
//must not sleep
//Other parameters are passed from New (excluding loc), this does not happen if mapload is TRUE
//Must return an Initialize hint. Defined in __DEFINES/subsystems.dm

//Note: the following functions don't call the base for optimization and must copypasta:
// /turf/Initialize
// /turf/open/space/Initialize

/atom/proc/Initialize(mapload, ...)
	if(flags_atom & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_atom |= INITIALIZED

	return INITIALIZE_HINT_NORMAL


//called if Initialize returns INITIALIZE_HINT_LATELOAD
/atom/proc/LateInitialize()
	return


//called when the turf the atom resides on is ChangeTurfed
/atom/proc/HandleTurfChange(turf/T)
	for(var/a in src)
		var/atom/A = a
		A.HandleTurfChange(T)


//Hook for running code when a dir change occurs
/atom/proc/setDir(newdir)
	SEND_SIGNAL(src, COMSIG_ATOM_DIR_CHANGE, dir, newdir)
	dir = newdir


/atom/vv_get_dropdown()
	. = ..()
	. += "---"
	var/turf/curturf = get_turf(src)
	if(curturf)
		.["Jump to"] = "?_src_=holder;[HrefToken()];observecoordjump=1;X=[curturf.x];Y=[curturf.y];Z=[curturf.z]"
	.["Modify Transform"] = "?_src_=vars;[HrefToken()];modtransform=[REF(src)]"
	.["Add reagent"] = "?_src_=vars;[HrefToken()];addreagent=[REF(src)]"


/atom/Entered(atom/movable/AM, atom/oldloc)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, AM, oldloc)


/atom/Exit(atom/movable/AM, atom/newloc)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, AM, newloc) & COMPONENT_ATOM_BLOCK_EXIT)
		return FALSE


/atom/Exited(atom/movable/AM, atom/newloc)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, newloc)


// Stacks and storage redefined procs.

/atom/proc/max_stack_merging(obj/item/stack/S)
	return FALSE //But if they do, limit is not an issue.

/atom/proc/recalculate_storage_space()
	return //Nothing to see here.

// Tool behavior procedure. Redirects to tool-specific procs by default.
// You can override it to catch all tool interactions, for use in complex deconstruction procs.
// Just don't forget to return ..() in the end.
/atom/proc/tool_act(mob/living/user, obj/item/I, tool_type)
	switch(tool_type)
		if(TOOL_CROWBAR)
			return crowbar_act(user, I)
		if(TOOL_MULTITOOL)
			return multitool_act(user, I)
		if(TOOL_SCREWDRIVER)
			return screwdriver_act(user, I)
		if(TOOL_WRENCH)
			return wrench_act(user, I)
		if(TOOL_WIRECUTTER)
			return wirecutter_act(user, I)
		if(TOOL_WELDER)
			return welder_act(user, I)
		if(TOOL_WELD_CUTTER)
			return weld_cut_act(user, I)
		if(TOOL_ANALYZER)
			return analyzer_act(user, I)


// Tool-specific behavior procs. To be overridden in subtypes.
/atom/proc/crowbar_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/multitool_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/multitool_check_buffer(user, obj/item/I, silent = FALSE)
	if(!istype(I, /obj/item/multitool))
		if(user && !silent)
			to_chat(user, "<span class='warning'>[I] has no data buffer!</span>")
		return FALSE
	return TRUE


/atom/proc/screwdriver_act(mob/living/user, obj/item/I)
	SEND_SIGNAL(src, COMSIG_ATOM_SCREWDRIVER_ACT, user, I)

/atom/proc/wrench_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/wirecutter_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/welder_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/weld_cut_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/analyzer_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	return


//the vision impairment to give to the mob whose perspective is set to that atom (e.g. an unfocused camera giving you an impaired vision when looking through it)
/atom/proc/get_remote_view_fullscreens(mob/user)
	return


//the sight changes to give to the mob whose perspective is set to that atom (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
/atom/proc/update_remote_sight(mob/living/user)
	return


//when a mob interact with something that gives them a special view,
//check_eye() is called to verify that they're still eligible.
//if they are not check_eye() usually reset the mob's view.
/atom/proc/check_eye(mob/user)
	return


/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.AllowDrop() ? L : L.drop_location()


/atom/proc/AllowDrop()
	return FALSE


/atom/proc/add_fingerprint(mob/M, type, special)
	if(!islist(fingerprints))
		fingerprints = list()

	if(!type)
		CRASH("Attempted to add fingerprint without an action type.")

	if(!istype(M))
		CRASH("Invalid mob type [M]([M.type]) when attempting to add fingerprint of type [type].")

	if(!M.key)
		return

	var/current_time = stationTimestamp()

	if(!LAZYACCESS(fingerprints, M.key))
		LAZYSET(fingerprints, M.key, "First: [M.real_name] | [current_time] | [type] [special ? "| [special]" : ""]")
	else
		var/laststamppos = findtext(LAZYACCESS(fingerprints, M.key), " Last: ")
		if(laststamppos)
			LAZYSET(fingerprints, M.key, copytext(fingerprints[M.key], 1, laststamppos))
		fingerprints[M.key] += " Last: [M.real_name] | [current_time] | [type] [special ? " | [special]" : ""]"
	
	return TRUE


/atom/Topic(href, href_list)
	. = ..()
	add_fingerprint(usr, "topic")