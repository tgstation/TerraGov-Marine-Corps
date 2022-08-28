/atom
	layer = TURF_LAYER
	plane = GAME_PLANE
	appearance_flags = TILE_BOUND
	var/level = 2

	var/flags_atom = NONE
	var/datum/reagents/reagents = null

	var/list/fingerprints
	var/blood_color
	var/list/blood_DNA

	var/flags_pass = NONE
	///whether projectiles and the like can bypass this atom even if its dense
	var/throwpass = FALSE

	var/resistance_flags = PROJECTILE_IMMUNE

	var/germ_level = GERM_LEVEL_AMBIENT // The higher the germ level, the more germ on the atom.

	///If non-null, overrides a/an/some in all cases
	var/article

	///overlays that should remain on top and not normally removed when using cut_overlay functions, like c4.
	var/list/priority_overlays
	///a very temporary list of overlays to remove
	var/list/remove_overlays
	///a very temporary list of overlays to add
	var/list/add_overlays

	///Lazy assoc list for managing filters attached to us
	var/list/filter_data

	var/list/display_icons // related to do_after/do_mob overlays, I can't get my hopes high.

	var/list/atom_colours	 //used to store the different colors on an atom
							//its inherent color, the colored paint applied on it, special color effect etc...

	///This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list

	///How much does this atom block the explosion's shock wave.
	var/explosion_block = 0

	var/list/managed_overlays //overlays managed by update_overlays() to prevent removing overlays that weren't added by the same proc

	var/datum/component/orbiter/orbiters
	var/datum/proximity_monitor/proximity_monitor

	var/datum/wires/wires = null

	//light stuff

	///Light systems, only one of the three should be active at the same time.
	var/light_system = STATIC_LIGHT
	///Range of the light in tiles. Zero means no light.
	var/light_range = 0
	///Intensity of the light. The stronger, the less shadows you will see on the lit area.
	var/light_power = 1
	///Hexadecimal RGB string representing the colour of the light. White by default.
	var/light_color = COLOR_WHITE
	///Boolean variable for toggleable lights. Has no effect without the proper light_system, light_range and light_power values.
	var/light_on = FALSE
	///Our light source. Don't fuck with this directly unless you have a good reason!
	var/tmp/datum/dynamic_light_source/light
	///Any light sources that are "inside" of us, for example, if src here was a mob that's carrying a flashlight, that flashlight's light source would be part of this list.
	var/tmp/list/hybrid_light_sources

	///The config type to use for greyscaled sprites. Both this and greyscale_colors must be assigned to work.
	var/greyscale_config
	///A string of hex format colors to be used by greyscale sprites, ex: "#0054aa#badcff"
	var/greyscale_colors

	//Values should avoid being close to -16, 16, -48, 48 etc.
	//Best keep them within 10 units of a multiple of 32, as when the light is closer to a wall, the probability
	//that a shadow extends to opposite corners of the light mask square is increased, resulting in more shadow
	//overlays.
	///x offset for dynamic lights on this atom
	var/light_pixel_x
	///y offset for dynamic lights on this atom
	var/light_pixel_y
	///typepath for the lighting maskfor dynamic light sources
	var/light_mask_type = null

	// popup chat messages
	/// Last name used to calculate a color for the chatmessage overlays
	var/chat_color_name
	/// Last color calculated for the the chatmessage overlays
	var/chat_color
	/// A luminescence-shifted value of the last color calculated for chatmessage overlays
	var/chat_color_darkened
	///HUD images that this mob can provide.
	var/list/hud_possible

	///Whether this atom smooths with things around it, and what type of smoothing if any.
	var/smoothing_behavior = NO_SMOOTHING
	///Bitflags to mark the members of specific smoothing groups, in where they all smooth with each other.
	var/smoothing_groups = NONE

	///The color this atom will be if we choose to draw it on the minimap
	var/minimap_color = MINIMAP_SOLID

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
	SEND_SIGNAL(src, COMSIG_ATOM_BUMPED, AM)


///Can the mover object pass this atom, while heading for the target turf
/atom/proc/CanPass(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(TRUE)
	. = CanAllowThrough(mover, target)
	// This is cheaper than calling the proc every time since most things dont override CanPassThrough
	if(!mover.generic_canpass)
		return mover.CanPassThrough(src, target, .)

/// Returns true or false to allow the mover to move through src
/atom/proc/CanAllowThrough(atom/movable/mover, turf/target)
	SHOULD_CALL_PARENT(TRUE)
	return !density


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
/mob/verb/examinate(atom/examinify as mob|obj|turf in view())
	set name = "Examine"
	set category = "IC"

	if(is_blind(src))
		to_chat(src, span_notice("Something is there but you can't see it."))
		return

	face_atom(examinify)
	var/list/result = examinify.examine(src) // if a tree is examined but no client is there to see it, did the tree ever really exist?

	to_chat(src, span_infoplain(result.Join("\n")))
	SEND_SIGNAL(src, COMSIG_MOB_EXAMINATE, examinify)

/**
 * Get the name of this object for examine
 *
 * You can override what is returned from this proc by registering to listen for the
 * [COMSIG_ATOM_GET_EXAMINE_NAME] signal
 */
/atom/proc/get_examine_name(mob/user)
	. = "\a [src]"
	var/list/override = list(gender == PLURAL ? "some" : "a", " ", "[name]")
	if(article)
		. = "[article] [src]"
		override[EXAMINE_POSITION_ARTICLE] = article
	if(SEND_SIGNAL(src, COMSIG_ATOM_GET_EXAMINE_NAME, user, override) & COMPONENT_EXNAME_CHANGED)
		. = override.Join("")

///Generate the full examine string of this atom (including icon for goonchat)
/atom/proc/get_examine_string(mob/user, thats = FALSE)
	return "[icon2html(src, user)] [thats? "That's ":""][get_examine_name(user)]"

/atom/proc/examine(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	. = list("[get_examine_string(user, TRUE)].")

	if(desc)
		. += desc
	if(user.can_use_codex() && SScodex.get_codex_entry(get_codex_value()))
		. += span_notice("The codex has <a href='?_src_=codex;show_examined_info=[REF(src)];show_to=[REF(user)]'>relevant information</a> available.")

	if((get_dist(user,src) <= 2) && reagents)
		if(reagents.reagent_flags & TRANSPARENT)
			. += "It contains:"
			if(length(reagents.reagent_list)) // TODO: Implement scan_reagent and can_see_reagents() to show each individual reagent
				var/total_volume = 0
				for(var/datum/reagent/R in reagents.reagent_list)
					total_volume += R.volume
				. +=  span_notice("[total_volume] units of various reagents.")
			else
				. += "Nothing."
		else if(CHECK_BITFIELD(reagents.reagent_flags, AMOUNT_VISIBLE))
			if(reagents.total_volume)
				. += span_notice("It has [reagents.total_volume] unit\s left.")
			else
				. += span_warning("It's empty.")
		else if(CHECK_BITFIELD(reagents.reagent_flags, AMOUNT_SKILLCHECK))
			if(isxeno(user))
				return
			if(user.skills.getRating("medical") >= SKILL_MEDICAL_NOVICE)
				. += "It contains these reagents:"
				if(length(reagents.reagent_list))
					for(var/datum/reagent/R in reagents.reagent_list)
						. += "[R.volume] units of [R.name]"
				else
					. += "Nothing."
			else
				. += "You don't know what's in it."
		else if(reagents.reagent_flags & AMOUNT_ESTIMEE)
			var/obj/item/reagent_containers/C = src
			if(!reagents.total_volume)
				. += span_notice("\The [src] is empty!")
			else if (reagents.total_volume<= C.volume*0.3)
				. += span_notice("\The [src] is almost empty!")
			else if (reagents.total_volume<= C.volume*0.6)
				. += span_notice("\The [src] is half full!")
			else if (reagents.total_volume<= C.volume*0.9)
				. += span_notice("\The [src] is almost full!")
			else
				. += span_notice("\The [src] is full!")

	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)


/// Updates the icon of the atom
/atom/proc/update_icon()
	var/signalOut = SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_ICON)

	if(!(signalOut & COMSIG_ATOM_NO_UPDATE_ICON_STATE))
		update_icon_state()

	if(!(signalOut & COMSIG_ATOM_NO_UPDATE_OVERLAYS))
		var/list/new_overlays = update_overlays()
		if(managed_overlays)
			cut_overlay(managed_overlays)
			managed_overlays = null
		if(length(new_overlays))
			managed_overlays = new_overlays
			add_overlay(new_overlays)

/// Updates the icon state of the atom
/atom/proc/update_icon_state()

/// Updates the overlays of the atom
/atom/proc/update_overlays()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	SEND_SIGNAL(src, COMSIG_ATOM_UPDATE_OVERLAYS, .)

/// Checks if the colors given are different and if so causes a greyscale icon update
/// The colors argument can be either a list or the full color string
/atom/proc/set_greyscale_colors(list/colors, update=TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if(istype(colors))
		colors = colors.Join("")
	if(greyscale_colors == colors)
		return
	greyscale_colors = colors
	if(!greyscale_config)
		return
	if(update)
		update_greyscale()

/// Checks if the greyscale config given is different and if so causes a greyscale icon update
/atom/proc/set_greyscale_config(new_config, update=TRUE)
	if(greyscale_config == new_config)
		return
	greyscale_config = new_config
	if(update)
		update_greyscale()

/// Checks if this atom uses the GAS system and if so updates the icon
/atom/proc/update_greyscale()
	if(greyscale_config && greyscale_colors)
		icon = SSgreyscale.GetColoredIconByType(greyscale_config, greyscale_colors)

// called by mobs when e.g. having the atom as their machine, pulledby, loc (AKA mob being inside the atom) or buckled var set.
// see code/modules/mob/mob_movement.dm for more.
/atom/proc/relaymove()
	return

/**
 * A special case of relaymove() in which the person relaying the move may be "driving" this atom
 *
 * This is a special case for vehicles and ridden animals where the relayed movement may be handled
 * by the riding component attached to this atom. Returns TRUE as long as there's nothing blocking
 * the movement, or FALSE if the signal gets a reply that specifically blocks the movement
 */
/atom/proc/relaydrive(mob/living/user, direction)
	return !(SEND_SIGNAL(src, COMSIG_RIDDEN_DRIVER_MOVE, user, direction) & COMPONENT_DRIVER_BLOCK_MOVE)

/**
 * React to being hit by an explosion
 *
 * Default behaviour is to call [contents_explosion][/atom/proc/contents_explosion] and send the [COMSIG_ATOM_EX_ACT] signal
 */
/atom/proc/ex_act(severity, epicenter_dist, impact_range)
	if(!(flags_atom & PREVENT_CONTENTS_EXPLOSION))
		contents_explosion(severity, epicenter_dist, impact_range)
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, epicenter_dist, impact_range)

/atom/proc/fire_act()
	return


/atom/proc/hitby(atom/movable/AM)
	if(density)
		AM.set_throwing(FALSE)


/atom/proc/GenerateTag()
	return


/atom/proc/prevent_content_explosion()
	return FALSE


/atom/proc/contents_explosion(severity)
	return //For handling the effects of explosions on contents that would not normally be effected


///Generalized Fire Proc. Burn level is the base fire damage being received.
/atom/proc/flamer_fire_act(burnlevel)
	return


//This proc is called on the location of an atom when the atom is Destroy()'d
/atom/proc/handle_atom_del(atom/A)
	SEND_SIGNAL(src, COMSIG_ATOM_CONTENTS_DEL, A)


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
		if(LOG_XOOC)
			log_xooc(log_text)
		if(LOG_MOOC)
			log_mooc(log_text)
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
		if(LOG_MECHA)
			log_mecha(log_text)
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
	if ((user && SEND_SIGNAL(user, COMSIG_COMBAT_LOG)) | (target && SEND_SIGNAL(target, COMSIG_COMBAT_LOG)) & DONT_LOG)
		return

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
		var/reverse_message = "has been [what_done] by [ssource][postfix] in [AREACOORD(user)]"
		target.log_message(reverse_message, LOG_ATTACK, color = "#eabd7e", log_globally = FALSE)


/atom/New(loc, ...)
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		GLOB._preloader.load(src)

	if(datum_flags & DF_USE_TAG)
		GenerateTag()

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, FALSE, args))
			//we were deleted
			return

///Add filters by priority to an atom
/atom/proc/add_filter(name,priority,list/params)
	LAZYINITLIST(filter_data)
	var/list/p = params.Copy()
	p["priority"] = priority
	filter_data[name] = p
	update_filters()

///Sorts our filters by priority and reapplies them
/atom/proc/update_filters()
	filters = null
	filter_data = sortTim(filter_data, /proc/cmp_filter_data_priority, TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		filters += filter(arglist(arguments))
	UNSETEMPTY(filter_data)

/atom/proc/transition_filter(name, time, list/new_params, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return

	var/list/old_filter_data = filter_data[name]

	var/list/params = old_filter_data.Copy()
	for(var/thing in new_params)
		params[thing] = new_params[thing]

	animate(filter, new_params, time = time, easing = easing, loop = loop)
	for(var/param in params)
		filter_data[name][param] = params[param]

/atom/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return

	filter_data[name]["priority"] = new_priority
	update_filters()

/obj/item/update_filters()
	. = ..()
	for(var/datum/action/A AS in actions)
		A.update_button_icon()

///returns a filter in the managed filters list by name
/atom/proc/get_filter(name)
	if(filter_data && filter_data[name])
		return filters[filter_data.Find(name)]

///removes a filter from the atom
/atom/proc/remove_filter(name_or_names)
	if(!filter_data)
		return
	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/atom/proc/clear_filters()
	filter_data = null
	filters = null

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

/**
 * The primary method that objects are setup in SS13 with
 *
 * we don't use New as we have better control over when this is called and we can choose
 * to delay calls or hook other logic in and so forth
 *
 * During roundstart map parsing, atoms are queued for intialization in the base atom/New(),
 * After the map has loaded, then Initalize is called on all atoms one by one. NB: this
 * is also true for loading map templates as well, so they don't Initalize until all objects
 * in the map file are parsed and present in the world
 *
 * If you're creating an object at any point after SSInit has run then this proc will be
 * immediately be called from New.
 *
 * mapload: This parameter is true if the atom being loaded is either being intialized during
 * the Atom subsystem intialization, or if the atom is being loaded from the map template.
 * If the item is being created at runtime any time after the Atom subsystem is intialized then
 * it's false.
 *
 * You must always call the parent of this proc, otherwise failures will occur as the item
 * will not be seen as initalized (this can lead to all sorts of strange behaviour, like
 * the item being completely unclickable)
 *
 * You must not sleep in this proc, or any subprocs
 *
 * Any parameters from new are passed through (excluding loc), naturally if you're loading from a map
 * there are no other arguments
 *
 * Must return an [initialization hint][INITIALIZE_HINT_NORMAL] or a runtime will occur.
 *
 * Note: the following functions don't call the base for optimization and must copypasta handling:
 * * [/turf/Initialize]
 * * [/turf/open/space/Initialize]
 */
/atom/proc/Initialize(mapload, ...)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	if(flags_atom & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_atom |= INITIALIZED

	update_greyscale()

	if(light_system != MOVABLE_LIGHT && light_power && light_range)
		update_light()
	if(loc)
		SEND_SIGNAL(loc, COMSIG_ATOM_INITIALIZED_ON, src) //required since spawning something doesn't call Move hence it doesn't call Entered.
		if(isturf(loc))
			if(opacity)
				var/turf/T = loc
				T.directional_opacity = ALL_CARDINALS // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

			if(smoothing_behavior)
				smooth_self()
				smooth_neighbors()

	return INITIALIZE_HINT_NORMAL


///called if Initialize returns INITIALIZE_HINT_LATELOAD
/atom/proc/LateInitialize(mapload)
	set waitfor = FALSE


///called when the turf the atom resides on is ChangeTurfed
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
	.["Modify Filters"] = "?_src_=vars;[HrefToken()];filteredit=[REF(src)]"
	.["Modify Greyscale Colors"] = "?_src_=vars;[HrefToken()];modify_greyscale=[REF(src)]"

/atom/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SEND_SIGNAL(src, COMSIG_ATOM_ENTERED, arrived, old_loc, old_locs)


/**
 * An atom is attempting to exit this atom's contents
 *
 * Default behaviour is to send the [COMSIG_ATOM_EXIT]
 */
/atom/Exit(atom/movable/leaving, direction, list/knownblockers = list())
	// Don't call `..()` here, otherwise `Uncross()` gets called.
	// See the doc comment on `Uncross()` to learn why this is bad.
	if(SEND_SIGNAL(src, COMSIG_ATOM_EXIT, leaving, direction, knownblockers) & COMPONENT_ATOM_BLOCK_EXIT)
		for(var/atom/movable/thing AS in knownblockers)
			var/signalreturn = SEND_SIGNAL(leaving, COMSIG_MOVABLE_PREBUMP_EXIT_MOVABLE, thing)
			if(signalreturn & COMPONENT_MOVABLE_PREBUMP_STOPPED)
				return FALSE
			if(signalreturn & COMPONENT_MOVABLE_PREBUMP_PLOWED)
				continue // no longer in the way
			leaving.Bump(thing)
			return FALSE
		return FALSE
	return TRUE

/atom/Exited(atom/movable/AM, direction)
	SEND_SIGNAL(src, COMSIG_ATOM_EXITED, AM, direction)


// Stacks and storage redefined procs.

/atom/proc/max_stack_merging(obj/item/stack/S)
	return FALSE //But if they do, limit is not an issue.

/atom/proc/recalculate_storage_space()
	return //Nothing to see here.

// Tool-specific behavior procs. To be overridden in subtypes.
/atom/proc/crowbar_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/multitool_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/multitool_check_buffer(user, obj/item/I, silent = FALSE)
	if(!istype(I, /obj/item/multitool))
		if(user && !silent)
			to_chat(user, span_warning("[I] has no data buffer!"))
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

/atom/proc/fulton_act(mob/living/user, obj/item/I)
	if(!isturf(loc))
		return FALSE //Storage screens, worn containers, anything we want to be able to interact otherwise.
	to_chat(user, span_warning("Cannot extract [src]."))
	return TRUE

///This proc is called on atoms when they are loaded into a shuttle
/atom/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	return


//the vision impairment to give to the mob whose perspective is set to that atom (e.g. an unfocused camera giving you an impaired vision when looking through it)
/atom/proc/get_remote_view_fullscreens(mob/user)
	return


//the sight changes to give to the mob whose perspective is set to that atom (e.g. A mob with nightvision loses its nightvision while looking through a normal camera)
/atom/proc/update_remote_sight(mob/living/user)
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
	if(.)
		return

	add_fingerprint(usr, "topic")


/atom/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if((interaction_flags & INTERACT_REQUIRES_DEXTERITY) && !user.dextrous)
		return FALSE

	if((interaction_flags & INTERACT_CHECK_INCAPACITATED) && user.incapacitated())
		return FALSE

	return TRUE


// For special click interactions (take first item out of container, quick-climb, etc.)
/atom/proc/specialclick(mob/living/carbon/user)
	return


//Consolidating HUD infrastructure
/atom/proc/prepare_huds()
	hud_list = new
	for(var/hud in hud_possible) //Providing huds.
		hud_list[hud] = image('icons/mob/hud.dmi', src, "")

/**
 * If this object has lights, turn it on/off.
 * user: the mob actioning this
 * toggle_on: if TRUE, will try to turn ON the light. Opposite if FALSE
 * cooldown: how long until you can toggle the light on/off again
 * sparks: if a spark effect will be generated
 * forced: if TRUE and toggle_on = FALSE, will cause the light to turn on in cooldown second
 * originated_turf: if not null, will check if the obj_turf is closer than distance_max to originated_turf, and the proc will return if not
 * distance_max: used to check if originated_turf is close to obj.loc
*/
/atom/proc/turn_light(mob/user = null, toggle_on , cooldown = 1 SECONDS, sparks = FALSE, forced = FALSE, light_again = FALSE)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_LIGHT) && !forced)
		return STILL_ON_COOLDOWN
	if(cooldown <= 0)
		cooldown = 1 SECONDS
	TIMER_COOLDOWN_START(src, COOLDOWN_LIGHT, cooldown)
	if(toggle_on == light_on)
		return NO_LIGHT_STATE_CHANGE
	if(light_again && !toggle_on) //Is true when turn light is called by nightfall and the light is already on
		addtimer(CALLBACK(src, .proc/reset_light), cooldown + 1)
	if(sparks && light_on)
		var/datum/effect_system/spark_spread/spark_system = new
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
		spark_system.start(src)
	return CHECKS_PASSED

///Turn on the light, should be called by a timer
/atom/proc/reset_light()
	turn_light(null, TRUE, 1 SECONDS, FALSE, TRUE)

/**
 * Recursive getter method to return a list of all ghosts orbitting this atom
 *
 * This will work fine without manually passing arguments.
 */
/atom/proc/get_all_orbiters(list/processed, source = TRUE)
	var/list/output = list()
	if (!processed)
		processed = list()
	if (src in processed)
		return output
	if (!source)
		output += src
	processed += src
	for (var/atom/atom_orbiter AS in orbiters?.orbiters)
		output += atom_orbiter.get_all_orbiters(processed, source = FALSE)
	return output
