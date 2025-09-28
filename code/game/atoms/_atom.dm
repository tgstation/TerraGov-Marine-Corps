/atom
	layer = ABOVE_NORMAL_TURF_LAYER
	plane = GAME_PLANE
	appearance_flags = TILE_BOUND|LONG_GLIDE
	var/level = 2

	var/atom_flags = NONE
	var/datum/reagents/reagents = null

	var/list/fingerprints
	var/blood_color
	var/list/blood_DNA

	///Things can move past this atom if they have the corrosponding flag
	var/allow_pass_flags = NONE

	var/resistance_flags = PROJECTILE_IMMUNE

	///a very temporary list of overlays to remove
	var/list/remove_overlays
	///a very temporary list of overlays to add
	var/list/add_overlays

	///Related to do_after/do_mob overlays, I can't get my hopes high.
	var/list/display_icons

	///used to store the different colors on an atom. its inherent color, the colored paint applied on it, special color effect etc...
	var/list/atom_colours

	///This atom's HUD (med/sec, etc) images. Associative list.
	var/list/image/hud_list

	///How much does this atom block the explosion's shock wave.
	var/explosion_block = 0

	var/datum/component/orbiter/orbiters

	var/datum/wires/wires = null

	///Used for changing icon states for different base sprites.
	var/base_icon_state

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

	///Icon-smoothing behavior.
	var/smoothing_flags = NONE
	///What directions this is currently smoothing with. IMPORTANT: This uses the smoothing direction flags as defined in icon_smoothing.dm, instead of the BYOND flags.
	var/smoothing_junction = NONE
	///Smoothing variable
	var/top_left_corner
	///Smoothing variable
	var/top_right_corner
	///Smoothing variable
	var/bottom_left_corner
	///Smoothing variable
	var/bottom_right_corner
	///What smoothing groups does this atom belongs to, to match canSmoothWith. If null, nobody can smooth with it.
	var/list/smoothing_groups = null
	///List of smoothing groups this atom can smooth with. If this is null and atom is smooth, it smooths only with itself.
	var/list/canSmoothWith = null

	///The color this atom will be if we choose to draw it on the minimap
	var/minimap_color = MINIMAP_SOLID

	///Cooldown for telling someone they're buckled
	COOLDOWN_DECLARE(buckle_message_cooldown)

	///vis overlays managed by SSvis_overlays to automaticaly turn them like other overlays.
	var/list/managed_vis_overlays
	///The list of alternate appearances for this atom
	var/list/alternate_appearances
	///var containing our storage, see atom/proc/create_storage()
	var/datum/storage/storage_datum

/*
We actually care what this returns, since it can return different directives.
Not specifically here, but in other variations of this. As a general safety,
Make sure the return value equals the return value of the parent so that the
directive is properly returned.
*/
//===========================================================================
/atom/Destroy()
	if(reagents)
		QDEL_NULL(reagents)

	if(storage_datum)
		QDEL_NULL(storage_datum)

	orbiters = null // The component is attached to us normaly and will be deleted elsewhere

	LAZYCLEARLIST(overlays)

	QDEL_NULL(light)

	if(isturf(loc))
		loc.fingerprints = fingerprints

	if(alternate_appearances)
		for(var/K in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
			AA.remove_from_hud(src)

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

/**
 * Ensure a list of atoms/reagents exists inside this atom
 *
 * Goes throught he list of passed in parts, if they're reagents, adds them to our reagent holder
 * creating the reagent holder if it exists.
 *
 * If the part is a moveable atom and the  previous location of the item was a mob/living,
 * it calls the inventory handler transferItemToLoc for that mob/living and transfers the part
 * to this atom
 *
 * Otherwise it simply forceMoves the atom into this atom
 */
/atom/proc/CheckParts(list/parts_list, datum/crafting_recipe/current_recipe)
	SEND_SIGNAL(src, COMSIG_ATOM_CHECKPARTS, parts_list, current_recipe)
	if(!parts_list)
		return
	for(var/part in parts_list)
		if(istype(part, /datum/reagent))
			if(!reagents)
				reagents = new()
			reagents.reagent_list.Add(part)
		else if(ismovable(part))
			var/atom/movable/object = part
			if(isliving(object.loc))
				var/mob/living/living = object.loc
				living.transferItemToLoc(object, src)
			else
				object.forceMove(src)
			SEND_SIGNAL(object, COMSIG_ATOM_USED_IN_CRAFT, src)
	parts_list.Cut()

/// Convenience proc for reagents handling.
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
	SEND_SIGNAL(src, COMSIG_ATOM_EMP_ACT, severity)
	return


/atom/proc/effect_smoke(obj/effect/particle_effect/smoke/S)
	if(S.lifetime < 1)
		return FALSE
	return TRUE


/**
 * atom/proc/search_contents_for(path,list/filter_path=null)
 * Recursevly searches all atom contens (including contents contents and so on).
 *
 * ARGS:
 * path - search atom contents for atoms of this type
 * list/filter_path - if set, contents of atoms not of types in this list are excluded from search.
 *
 * RETURNS: list of found atoms
 */
/atom/proc/search_contents_for(path, list/filter_path = null)
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
		if(length(A.contents))
			found += A.search_contents_for(path,filter_path)
	return found

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
/atom/proc/relaymove(mob/living/user, direct)
	if(COOLDOWN_FINISHED(src, buckle_message_cooldown))
		COOLDOWN_START(src, buckle_message_cooldown, 2.5 SECONDS)
		balloon_alert(user, "Can't move while buckled!")
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
	if(!(atom_flags & PREVENT_CONTENTS_EXPLOSION))
		contents_explosion(severity, epicenter_dist, impact_range)
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, epicenter_dist, impact_range)

///Effects of fire
/atom/proc/fire_act(burn_level)
	return

///Effects of lava. Return true where we want the lava to keep processing
/atom/proc/lava_act()
	if(resistance_flags & INDESTRUCTIBLE)
		return FALSE
	fire_act(LAVA_BURN_LEVEL)
	return TRUE

/atom/proc/hitby(atom/movable/AM, speed = 5)
	if(density)
		AM.set_throwing(FALSE)
		return TRUE

///Psionic interaction with this atom
/atom/proc/psi_act(psi_power, mob/living/user)
	return

/atom/proc/prevent_content_explosion()
	return FALSE


/atom/proc/contents_explosion(severity)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_CONTENTS_EX_ACT, severity)
	return //For handling the effects of explosions on contents that would not normally be effected

//This proc is called on the location of an atom when the atom is Destroy()'d
/atom/proc/handle_atom_del(atom/A)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_CONTENTS_DEL, A)

/**
 * Called when an atom is created in byond (built in engine proc)
 *
 * Not a lot happens here in SS13 code, as we offload most of the work to the
 * [Initialization][/atom/proc/Initialize] proc, mostly we run the preloader
 * if the preloader is being used and then call [InitAtom][/datum/controller/subsystem/atoms/proc/InitAtom] of which the ultimate
 * result is that the Initialize proc is called.
 *
 */
/atom/New(loc, ...)
	//atom creation method that preloads variables at creation
	if(GLOB.use_preloader && src.type == GLOB._preloader_path)//in case the instantiated atom is creating other atoms in New()
		world.preloader_load(src)

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, FALSE, args))
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
	if(!atom_colours || !length(atom_colours))
		atom_colours = list()
		atom_colours.len = COLOR_PRIORITY_AMOUNT //four priority levels currently.
	if(!coloration)
		return
	if(colour_priority > length(atom_colours))
		return
	atom_colours[colour_priority] = coloration
	update_atom_colour()


/*
	Removes an instance of colour_type from the atom's atom_colours list
*/
/atom/proc/remove_atom_colour(colour_priority, coloration)
	if(!atom_colours)
		atom_colours = list()
		atom_colours.len = COLOR_PRIORITY_AMOUNT //four priority levels currently.
	if(colour_priority > length(atom_colours))
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
		atom_colours.len = COLOR_PRIORITY_AMOUNT //four priority levels currently.
	color = null
	for(var/C in atom_colours)
		if(islist(C))
			var/list/L = C
			if(length(L))
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
	if(atom_flags & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	atom_flags |= INITIALIZED

	SET_PLANE_IMPLICIT(src, plane)

	update_greyscale()

	if(light_system != MOVABLE_LIGHT && light_power && light_range)
		update_light()
	if(loc)
		SEND_SIGNAL(loc, COMSIG_ATOM_INITIALIZED_ON, src) //required since spawning something doesn't call Move hence it doesn't call Entered.
		if(isturf(loc) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
			QUEUE_SMOOTH(src)
			QUEUE_SMOOTH_NEIGHBORS(src)

	if(length(smoothing_groups))
		sortTim(smoothing_groups) //In case it's not properly ordered, let's avoid duplicate entries with the same values.
		SET_BITFLAG_LIST(smoothing_groups)
	if(length(canSmoothWith))
		sortTim(canSmoothWith)
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)

	return INITIALIZE_HINT_NORMAL


///called if Initialize returns INITIALIZE_HINT_LATELOAD
/atom/proc/LateInitialize()
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

/**
 * Wash this atom
 *
 * This will clean it off any temporary stuff like blood. Override this in your item to add custom cleaning behavior.
 * Returns true if any washing was necessary and thus performed
 */
/atom/proc/wash()
	SHOULD_CALL_PARENT(TRUE)
	if(SEND_SIGNAL(src, COMSIG_COMPONENT_CLEAN_ACT) & COMPONENT_CLEANED)
		return TRUE

	// Basically "if has washable coloration"
	if(length(atom_colours) >= WASHABLE_COLOR_PRIORITY && atom_colours[WASHABLE_COLOR_PRIORITY])
		remove_atom_colour(WASHABLE_COLOR_PRIORITY)
		return TRUE
	if(clean_blood())
		return TRUE
	return FALSE

/atom/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_ATOM_JUMP_TO, "Jump To")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_TRANSFORM, "Modify Transform")
	VV_DROPDOWN_OPTION(VV_HK_ADD_REAGENT, "Add reagent")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_FILTERS, "Modify Filters")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_GREYSCALE_COLORS, "Modify Greyscale Colors")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_COLOR_MATRIX, "Edit Color as Matrix")
	VV_DROPDOWN_OPTION(VV_HK_TEST_MATRIXES, "Test Matrices")

/atom/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_ATOM_JUMP_TO])
		if(!check_rights(NONE))
			return
		var/target = GET_VV_TARGET
		if(!target)
			return
		var/turf/target_turf = get_turf(target)
		if(!target_turf)
			return
		var/client/C = usr.client

		var/message
		if(!isobserver(usr))
			SSadmin_verbs.dynamic_invoke_verb(C, /datum/admin_verb/aghost)
			message = TRUE

		var/mob/dead/observer/O = C.mob
		O.forceMove(target_turf)

		if(message)
			log_admin("[key_name(O)] jumped to coordinates [AREACOORD(target_turf)].")
			message_admins("[ADMIN_TPMONTY(O)] jumped to coordinates [ADMIN_VERBOSEJMP(target_turf)].")

	if(href_list[VV_HK_MODIFY_TRANSFORM])
		if(!check_rights(R_DEBUG))
			return
		if(!istype(src))
			return
		var/result = input(usr, "Choose the transformation to apply", "Modify Transform") as null|anything in list("Scale","Translate","Rotate")
		var/matrix/M = src.transform
		switch(result)
			if("Scale")
				var/x = input(usr, "Choose x mod", "Modify Transform") as null|num
				var/y = input(usr, "Choose y mod", "Modify Transform") as null|num
				if(x == 0 || y == 0)
					if(alert("You've entered 0 as one of the values, are you sure?", "Modify Transform", "Yes", "No") != "Yes")
						return
				if(!isnull(x) && !isnull(y))
					src.transform = M.Scale(x,y)
			if("Translate")
				var/x = input(usr, "Choose x mod", "Modify Transform") as null|num
				var/y = input(usr, "Choose y mod", "Modify Transform") as null|num
				if(x == 0 && y == 0)
					return
				if(!isnull(x) && !isnull(y))
					src.transform = M.Translate(x,y)
			if("Rotate")
				var/angle = input(usr, "Choose angle to rotate", "Modify Transform") as null|num
				if(angle == 0)
					if(alert("You've entered 0 as one of the values, are you sure?", "Warning", "Yes", "No") != "Yes")
						return
				if(!isnull(angle))
					src.transform = M.Turn(angle)
		log_admin("[key_name(usr)] has used [result] transformation on [src].")
		message_admins("[ADMIN_TPMONTY(usr)] has used [result] transformation on [src].")

	if(href_list[VV_HK_ADD_REAGENT])
		if(!check_rights(R_VAREDIT))
			return
		if(!reagents)
			var/amount = input(usr, "Specify the reagent size of [src]", "Set Reagent Size", 50) as num
			if(amount)
				create_reagents(amount)
		if(reagents)
			var/chosen_id
			var/list/reagent_options = sortList(GLOB.chemical_reagents_list)
			switch(alert(usr, "Choose a method.", "Add Reagents", "Enter ID", "Choose ID"))
				if("Enter ID")
					var/valid_id
					while(!valid_id)
						chosen_id = stripped_input(usr, "Enter the ID of the reagent you want to add.")
						if(!chosen_id) //Get me out of here!
							break
						for(var/ID in reagent_options)
							if(ID == chosen_id)
								valid_id = TRUE
						if(!valid_id)
							to_chat(usr, span_warning("A reagent with that ID doesn't exist!"))
				if("Choose ID")
					chosen_id = input(usr, "Choose a reagent to add.", "Add Reagent") as null|anything in reagent_options
			if(chosen_id)
				var/amount = input(usr, "Choose the amount to add.", "Add Reagent", reagents.maximum_volume) as num
				if(amount)
					reagents.add_reagent(chosen_id, amount)
					log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to [src].")
					message_admins("[ADMIN_TPMONTY(usr)] has added [amount] units of [chosen_id] to [src].")

	if(href_list[VV_HK_MODIFY_FILTERS])
		if(!check_rights(R_VAREDIT))
			return
		var/client/C = usr.client
		C?.open_filter_editor(src)

	if(href_list[VV_HK_MODIFY_GREYSCALE_COLORS])
		if(!check_rights(R_DEBUG))
			return
		var/datum/greyscale_modify_menu/menu = new(usr)
		menu.ui_interact(usr)

	if(href_list[VV_HK_EDIT_COLOR_MATRIX])
		if(!check_rights(R_VAREDIT))
			return
		usr.client?.open_color_matrix_editor(src)

	if(href_list[VV_HK_TEST_MATRIXES])
		if(!check_rights(R_VAREDIT))
			return
		usr.client?.open_matrix_tester(src)

/atom/vv_get_header()
	. = ..()
	var/refid = REF(src)
	. += "[VV_HREF_TARGETREF(refid, VV_HK_AUTO_RENAME, "<b id='name'>[src]</b>")]"
	. += "<br><font size='1'><a href='byond://?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=left'><<</a> <a href='byond://?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(dir) || dir]</a> <a href='byond://?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=right'>>></a></font>"

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
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, ATOM_MAX_STACK_MERGING, S)
	return FALSE //But if they do, limit is not an issue.

/atom/proc/recalculate_storage_space()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, ATOM_RECALCULATE_STORAGE_SPACE)
	return //Nothing to see here.

// Tool-specific behavior procs. To be overridden in subtypes.
/atom/proc/crowbar_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/multitool_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/multitool_check_buffer(user, obj/item/I, silent = FALSE)
	if(!istype(I, /obj/item/tool/multitool))
		if(user && !silent)
			to_chat(user, span_warning("[I] has no data buffer!"))
		return FALSE
	return TRUE


/atom/proc/screwdriver_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/wrench_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/wirecutter_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/welder_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/analyzer_act(mob/living/user, obj/item/I)
	return FALSE

/atom/proc/fulton_act(mob/living/user, obj/item/I)
	if(!isturf(loc))
		return FALSE //Storage screens, worn containers, anything we want to be able to interact otherwise.
	to_chat(user, span_warning("Cannot extract [src]."))
	return TRUE

/atom/proc/plasmacutter_act(mob/living/user, obj/item/I)
	return FALSE

///This proc is called on atoms when they are loaded into a shuttle
/atom/proc/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	return


/atom/proc/intercept_zImpact(list/falling_movables, levels = 1)
	SHOULD_CALL_PARENT(TRUE)
	. |= SEND_SIGNAL(src, COMSIG_ATOM_INTERCEPT_Z_FALL, falling_movables, levels)

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
	if(usr?.client)
		var/client/usr_client = usr.client
		var/list/paramslist = list()

		if(href_list["statpanel_item_click"])
			switch(href_list["statpanel_item_click"])
				if("left")
					paramslist[LEFT_CLICK] = "1"
				if("right")
					paramslist[RIGHT_CLICK] = "1"
				if("middle")
					paramslist[MIDDLE_CLICK] = "1"
				else
					return

			if(href_list["statpanel_item_shiftclick"])
				paramslist[SHIFT_CLICK] = "1"
			if(href_list["statpanel_item_ctrlclick"])
				paramslist[CTRL_CLICK] = "1"
			if(href_list["statpanel_item_altclick"])
				paramslist[ALT_CLICK] = "1"

			var/mouseparams = list2params(paramslist)
			usr_client.Click(src, loc, null, mouseparams)
			. = TRUE

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

/atom/proc/prepare_huds()
	for(var/key in hud_list)
		var/image/removee = hud_list[key]
		LAZYREMOVE(update_on_z, removee)
	hud_list = list()
	var/static/list/higher_hud_list = HUDS_LAYERING_HIGH
	for(var/hud in hud_possible) //Providing huds.
		var/hint = hud_possible[hud]
		switch(hint)
			if(HUD_LIST_LIST)
				hud_list[hud] = list()
			else
				var/image/I = image('icons/mob/hud/human.dmi', src, "")
				I.appearance_flags = RESET_COLOR|RESET_TRANSFORM|KEEP_APART
				if(hud in higher_hud_list)
					SET_PLANE_EXPLICIT(I, POINT_PLANE, src)
					LAZYADD(update_on_z, I)
				hud_list[hud] = I

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
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_LIGHT) && !forced)
		return STILL_ON_COOLDOWN
	if(cooldown <= 0)
		cooldown = 1 SECONDS
	TIMER_COOLDOWN_START(src, COOLDOWN_LIGHT, cooldown)
	if(toggle_on == light_on)
		return NO_LIGHT_STATE_CHANGE
	if(light_again && !toggle_on) //Is true when turn light is called by nightfall and the light is already on
		addtimer(CALLBACK(src, PROC_REF(reset_light)), cooldown + 1)
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

/**
 * Function that determines if we can slip when we walk over this atom.
 *
 * Returns true if we can, false if we can't. Put your special checks here.
 */

/atom/proc/can_slip()
	return TRUE

///Adds the debris element for projectile impacts
/atom/proc/add_debris_element()
	AddElement(/datum/element/debris, null, -40, 8, 0.7)

/**
	Returns a number after taking into account both soft and hard armor for the specified damage type, usually damage

	Arguments
	* Damage_amount: The original unmodified damage
	* armor_type: The type of armor by which the damage will be modified
	* penetration: How much the damage source might bypass the armour value (optional)
	* def_zone: What part of the body we want to check the armor of (optional)
	* attack_dir: What direction the attack was from (optional)

	Hard armor reduces penetration by a flat amount, and sunder in the case of xenos
	Penetration reduces soft armor by a flat amount.
	Damage cannot go into the negative, or exceed the original amount.
*/
/atom/proc/modify_by_armor(damage_amount, armor_type, penetration, def_zone, attack_dir)
	penetration = max(0, penetration - get_hard_armor(armor_type, def_zone))
	return clamp((damage_amount * (1 - ((get_soft_armor(armor_type, def_zone) - penetration) * 0.01))), 0, damage_amount)

///Returns the soft armor for the given atom. If human and a limb is specified, gets the armor for that specific limb.
/atom/proc/get_soft_armor(armor_type, proj_def_zone)
	return

///Returns the hard armor for the given atom. If human and a limb is specified, gets the armor for that specific limb.
/atom/proc/get_hard_armor(armor_type, proj_def_zone)
	return

///Interaction for using a grab on an atom
/atom/proc/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	return

///Checks if there is acid melting this atom
/atom/proc/get_self_acid()
	var/list/acid_list = list()
	SEND_SIGNAL(src, COMSIG_ATOM_GET_SELF_ACID, acid_list)
	if(!length(acid_list))
		return
	return acid_list[1]

///returns if we can melt an object, but also the speed at which it happens. 1 just means we melt it. 0,5 means we need a higher strength acid. higher than 1 just makes it melt faster
/atom/proc/dissolvability(acid_strength)
	return 1

//returns how long it takes to apply acid on this atom
/atom/proc/get_acid_delay()
	return 1 SECONDS

///returns if we are able to apply acid to the atom, also checks if there is already a stronger acid on this atom
/atom/proc/should_apply_acid(acid_strength)
	if(resistance_flags & UNACIDABLE || !dissolvability(acid_strength))
		return ATOM_CANNOT_ACID
	var/obj/effect/xenomorph/acid/current_acid = get_self_acid()
	if(acid_strength <= current_acid?.acid_strength)
		return ATOM_STRONGER_ACID
	return ATOM_CAN_ACID

///What happens when with atom is melted by acid
/atom/proc/do_acid_melt()
	visible_message(span_xenodanger("[src] collapses under its own weight into a puddle of goop and undigested debris!"))
	playsound(src, SFX_ACID_HIT, 25)
