// Microwaving doesn't use recipes, instead it calls the microwave_act of the objects.
// For food, this creates something based on the food's cooked_type

/// Values based on microwave success
#define MICROWAVE_NORMAL 0
#define MICROWAVE_MUCK 1
#define MICROWAVE_PRE 2

/// Values for how broken the microwave is
#define NOT_BROKEN 0
#define KINDA_BROKEN 1
#define REALLY_BROKEN 2

/// The max amount of dirtiness a microwave can be
#define MAX_MICROWAVE_DIRTINESS 100

/// For the wireless version, and display fluff
#define TIER_1_CELL_CHARGE_RATE (0.25 * STANDARD_CELL_CHARGE)

/obj/machinery/microwave
	name = "microwave oven"
	desc = "Cooks and boils stuff."
	icon = 'icons/obj/machines/microwave.dmi'
	base_icon_state = ""
	icon_state = "mw_complete"
	appearance_flags = KEEP_TOGETHER | LONG_GLIDE | PIXEL_SCALE
	layer = BELOW_OBJ_LAYER
	density = TRUE
	circuit = /obj/item/circuitboard/machine/microwave
	pass_flags = PASS_LOW_STRUCTURE
	light_color = LIGHT_COLOR_YELLOW
	light_power = 3
	/// Is its function wire cut?
	var/wire_disabled = FALSE
	/// Wire cut to run mode backwards
	var/wire_mode_swap = FALSE
	/// Fail due to inserted PDA
	var/pda_failure = FALSE
	var/operating = FALSE
	/// How dirty is it?
	var/dirty = 0
	var/dirty_anim_playing = FALSE
	/// How broken is it? NOT_BROKEN, KINDA_BROKEN, REALLY_BROKEN
	var/broken = NOT_BROKEN
	/// Microwave door position
	var/open = FALSE
	/// Microwave max capacity
	var/max_n_of_items = 10
	/// Microwave efficiency (power) based on the stock components
	var/efficiency = 0
	var/datum/looping_sound/microwave/soundloop
	/// May only contain /atom/movables
	var/list/ingredients = list()
	/// When this is the nth ingredient, whats its pixel_x?
	var/list/ingredient_shifts_x = list(
		-2,
		1,
		-5,
		2,
		-6,
		0,
		-4,
	)
	/// When this is the nth ingredient, whats its pixel_y?
	var/list/ingredient_shifts_y = list(
		-4,
		-2,
		-3,
	)
	var/static/radial_examine = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_examine")
	var/static/radial_eject = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_eject")
	var/static/radial_cook = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_cook")

	// we show the button even if the proc will not work
	var/static/list/radial_options = list("eject" = radial_eject, "cook" = radial_cook)
	var/static/list/ai_radial_options = list("eject" = radial_eject, "cook" = radial_cook, "examine" = radial_examine)

/obj/machinery/microwave/Initialize(mapload)
	. = ..()
	create_reagents(100)
	soundloop = new(src, FALSE)
	update_appearance(UPDATE_ICON)

/obj/machinery/microwave/Exited(atom/movable/gone, direction)
	if(gone in ingredients)
		ingredients -= gone
		if(!QDELING(gone) && ingredients.len && isitem(gone))
			var/obj/item/itemized_ingredient = gone
			itemized_ingredient.pixel_x = itemized_ingredient.pixel_x + rand(-6, 6)
			itemized_ingredient.pixel_y = itemized_ingredient.pixel_y + rand(-5, 6)
	return ..()

/obj/machinery/microwave/on_deconstruction(disassembled)
	eject()
	return ..()

/obj/machinery/microwave/Destroy()
	QDEL_LIST(ingredients)
	QDEL_NULL(wires)
	QDEL_NULL(soundloop)
	QDEL_NULL(particles)
	return ..()


/obj/machinery/microwave/RefreshParts()
	. = ..()
	efficiency = 0
	for(var/obj/item/stock_parts/micro_laser/micro_laser in component_parts)
		efficiency += micro_laser.rating
	for(var/obj/item/stock_parts/matter_bin/matter_bin in component_parts)
		max_n_of_items = 10 * matter_bin.rating
		break

/obj/machinery/microwave/examine(mob/user)
	. = ..()

	if(!in_range(user, src) && !issilicon(user) && !isobserver(user))
		. += span_warning("You're too far away to examine [src]'s contents and display!")
		return
	if(operating)
		. += span_notice("\The [src] is operating.")
		return

	if(length(ingredients))
		if(issilicon(user))
			. += span_notice("\The [src] camera shows:")
		else
			. += span_notice("\The [src] contains:")
		var/list/items_counts = new
		for(var/i in ingredients)
			if(isstack(i))
				var/obj/item/stack/item_stack = i
				items_counts[item_stack.name] += item_stack.amount
			else
				var/atom/movable/single_item = i
				items_counts[single_item.name]++
		for(var/item in items_counts)
			. += span_notice("- [items_counts[item]]x [item].")
	else
		. += span_notice("\The [src] is empty.")

	if(!(machine_stat & (NOPOWER|BROKEN)))
		. += "[span_notice("The status display reads:")]\n"+\
		"[span_notice("- Capacity: <b>[max_n_of_items]</b> items.")]\n"

#define MICROWAVE_INGREDIENT_OVERLAY_SIZE 24

/obj/machinery/microwave/update_overlays()
	. = ..()

	// All of these will use a full icon state instead
	if(panel_open || dirty >= MAX_MICROWAVE_DIRTINESS || broken || dirty_anim_playing)
		return .

	var/ingredient_count = 0

	for(var/atom/movable/ingredient as anything in ingredients)
		var/image/ingredient_overlay = image(ingredient, src)

		ingredient_overlay.pixel_x = ingredient_shifts_x[(ingredient_count % ingredient_shifts_x.len) + 1]
		ingredient_overlay.pixel_y = ingredient_shifts_y[(ingredient_count % ingredient_shifts_y.len) + 1]
		ingredient_overlay.layer = FLOAT_LAYER
		ingredient_overlay.plane = FLOAT_PLANE
		ingredient_overlay.blend_mode = BLEND_INSET_OVERLAY

		ingredient_count += 1

		. += ingredient_overlay

	var/border_icon_state
	var/door_icon_state

	if(open)
		door_icon_state = "[base_icon_state]door_open"
		border_icon_state = "[base_icon_state]mwo"
	else if(operating)
		door_icon_state = "[base_icon_state]door_on"
		border_icon_state = "[base_icon_state]mw1"
	else
		door_icon_state = "[base_icon_state]door_off"
		border_icon_state = "[base_icon_state]mw"


	. += mutable_appearance(
		icon,
		door_icon_state,
	)

	. += border_icon_state

	if(!open)
		. += "[base_icon_state]door_handle"

	if(!(machine_stat & NOPOWER))
		. += emissive_appearance(icon, "emissive_[border_icon_state]", src, alpha = src.alpha)
	return .

#undef MICROWAVE_INGREDIENT_OVERLAY_SIZE

/obj/machinery/microwave/update_icon_state()
	if(broken)
		icon_state = "[base_icon_state]mwb"
	else if(dirty_anim_playing)
		icon_state = "[base_icon_state]mwbloody1"
	else if(dirty >= MAX_MICROWAVE_DIRTINESS)
		icon_state = open ? "[base_icon_state]mwbloodyo" : "[base_icon_state]mwbloody"
	else if(operating)
		icon_state = "[base_icon_state]back_on"
	else if(open)
		icon_state = "[base_icon_state]back_open"
	else if(panel_open)
		icon_state = "[base_icon_state]mw-o"
	else
		icon_state = "[base_icon_state]back_off"

	return ..()

/obj/machinery/microwave/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool))
		update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/crowbar_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_crowbar(tool))
		return
	return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/screwdriver_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/wirecutter_act(mob/living/user, obj/item/tool)
	if(broken != REALLY_BROKEN)
		return NONE

	user.visible_message(
		span_notice("[user] starts to fix part of [src]."),
		span_notice("You start to fix part of [src]..."),
	)

	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(
		span_notice("[user] fixes part of [src]."),
		span_notice("You fix part of [src]."),
	)
	broken = KINDA_BROKEN // Fix it a bit
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/welder_act(mob/living/user, obj/item/tool)
	if(broken != KINDA_BROKEN)
		return NONE

	user.visible_message(
		span_notice("[user] starts to fix part of [src]."),
		span_notice("You start to fix part of [src]..."),
	)

	if(!tool.use_tool(src, user, 2 SECONDS, amount = 1, volume = 50))
		return ITEM_INTERACT_BLOCKING

	user.visible_message(
		span_notice("[user] fixes [src]."),
		span_notice("You fix [src]."),
	)
	broken = NOT_BROKEN
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/attackby(mob/living/user, obj/item/attacking_item, params)
	if(operating)
		return NONE

	if(broken > NOT_BROKEN)
		balloon_alert(user, "it's broken!")
		return ITEM_INTERACT_BLOCKING
	if(!anchored)
		balloon_alert(user, "not secured!")
		return ITEM_INTERACT_BLOCKING

	if(dirty >= MAX_MICROWAVE_DIRTINESS) // The microwave is all dirty so can't be used!
		balloon_alert(user, "it's too dirty!")
		return ITEM_INTERACT_BLOCKING

	if(istype(attacking_item, /obj/item/storage))
		var/obj/item/storage/tray = attacking_item
		var/loaded = 0

		if(!istype(attacking_item, /obj/item/storage/bag/tray))
			// Non-tray dumping requires a do_after
			to_chat(user, span_notice("You start dumping out the contents of [attacking_item] into [src]..."))
			if(!do_after(user, 2 SECONDS, target = tray))
				return ITEM_INTERACT_BLOCKING

		for(var/obj/tray_item in tray.contents)
			if(!IS_EDIBLE(tray_item))
				continue
			if(ingredients.len >= max_n_of_items)
				balloon_alert(user, "it's full!")
				return ITEM_INTERACT_BLOCKING
			if(tray.storage_datum.remove_from_storage(tray_item, src, user))
				loaded++
				ingredients += tray_item
		if(loaded)
			open(autoclose = 0.6 SECONDS)
			to_chat(user, span_notice("You insert [loaded] items into \the [src]."))
			update_appearance()
		return ITEM_INTERACT_SUCCESS

	if(attacking_item.w_class <= WEIGHT_CLASS_NORMAL && user.a_intent == INTENT_HELP)
		if(ingredients.len >= max_n_of_items)
			balloon_alert(user, "it's full!")
			return ITEM_INTERACT_BLOCKING
		if(!user.transferItemToLoc(attacking_item, src))
			balloon_alert(user, "it's stuck to your hand!")
			return ITEM_INTERACT_BLOCKING

		ingredients += attacking_item
		open(autoclose = 0.6 SECONDS)
		user.visible_message(span_notice("[user] adds \a [attacking_item] to \the [src]."), span_notice("You add [attacking_item] to \the [src]."))
		update_appearance()
		return ITEM_INTERACT_SUCCESS

/obj/machinery/microwave/ui_interact(mob/user)
	. = ..()

	if(!anchored)
		balloon_alert(user, "not secured!")
		return
	if(operating || panel_open)
		return
	if((machine_stat & NOPOWER))
		return
	if(!length(ingredients))
		balloon_alert(user, "it's empty!")
		return

	var/choice = show_radial_menu(user, src, radial_options, require_near = TRUE)

	// post choice verification
	if(operating || panel_open || !anchored)
		return
	if(machine_stat & NOPOWER)
		return

	switch(choice)
		if("eject")
			eject()
		if("cook")
			start_cycle(user)
		if("examine")
			examine(user)

/obj/machinery/microwave/wash(clean_types)
	. = ..()
	if(operating)
		return .

	dirty = 0
	update_appearance()
	return . || TRUE

/obj/machinery/microwave/proc/eject()
	var/atom/drop_loc = drop_location()
	for(var/obj/item/item_ingredient as anything in ingredients)
		item_ingredient.forceMove(drop_loc)
		item_ingredient.dropped() //Mob holders can be on the ground if we don't do this
	open(autoclose = 1.4 SECONDS)

/obj/machinery/microwave/proc/start_cycle(mob/user)
	if(wire_mode_swap)
		spark()
	else
		cook(user)

/**
 * Begins the process of cooking the included ingredients.
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/cook(mob/cooker)
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(operating || broken > 0 || panel_open || !anchored || dirty >= MAX_MICROWAVE_DIRTINESS)
		return

	if(wire_disabled)
		audible_message("[src] buzzes.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		return

	if(prob(max((5 / efficiency) - 5, dirty * 5))) //a clean unupgraded microwave has no risk of failure
		muck()
		return

	// How many items are we cooking that aren't already food items
	var/non_food_ingedients = length(ingredients)
	for(var/atom/movable/potential_fooditem as anything in ingredients)
		if(IS_EDIBLE(potential_fooditem))
			non_food_ingedients--
	// If we're cooking non-food items we can fail randomly
	if(length(non_food_ingedients) && prob(min(dirty * 5, 100)))
		start_can_fail(cooker)
		return

	start(cooker)

/obj/machinery/microwave/proc/wzhzhzh()

	visible_message(span_notice("\The [src] turns on."), null, span_hear("You hear a microwave humming."))
	operating = TRUE
	set_light(l_range = 1.5, l_power = 1.2)
	soundloop.start()
	update_appearance()

/obj/machinery/microwave/proc/spark()
	visible_message(span_warning("Sparks fly around [src]!"))
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(2, 1, src)
	sparks.start()

/**
 * The start of the cook loop
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/start(mob/cooker)
	wzhzhzh()
	cook_loop(type = MICROWAVE_NORMAL, cycles = 10, cooker = cooker)

/**
 * The start of the cook loop, but can fail (result in a splat / dirty microwave)
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/start_can_fail(mob/cooker)
	wzhzhzh()
	cook_loop(type = MICROWAVE_PRE, cycles = 4, cooker = cooker)

/obj/machinery/microwave/proc/muck()
	wzhzhzh()
	playsound(loc, 'sound/effects/splat.ogg', 50, TRUE)
	dirty_anim_playing = TRUE
	update_appearance()
	cook_loop(type = MICROWAVE_MUCK, cycles = 4)

/**
 * The actual cook loop started via [proc/start] or [proc/start_can_fail]
 *
 * * type - the type of cooking, determined via how this iteration of cook_loop is called, and determines the result
 * * time - how many loops are left, base case for recursion
 * * wait - deciseconds between loops
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/cook_loop(type, cycles, wait = max(12 - 2 * efficiency, 2), mob/cooker) // standard wait is 10
	if((machine_stat & BROKEN) && type == MICROWAVE_PRE)
		pre_fail()
		return

	if(cycles <= 0 || !length(ingredients))
		switch(type)
			if(MICROWAVE_NORMAL)
				loop_finish(cooker)
			if(MICROWAVE_MUCK)
				muck_finish()
			if(MICROWAVE_PRE)
				pre_success(cooker)
		return

	cycles--
	use_power(active_power_usage)
	addtimer(CALLBACK(src, PROC_REF(cook_loop), type, cycles, wait, cooker), wait)

/obj/machinery/microwave/proc/remove_smoke()
	QDEL_NULL(particles)

/obj/machinery/microwave/power_change()
	. = ..()

	if((machine_stat & NOPOWER) && operating)
		pre_fail()
		eject()

/**
 * Called when the cook_loop is done successfully, no dirty mess or whatever
 *
 * * cooker - The mob that initiated the cook cycle, can be null if no apparent mob triggered it (such as via emp)
 */
/obj/machinery/microwave/proc/loop_finish(mob/cooker)
	operating = FALSE
	if(pda_failure)
		spark()
		pda_failure = FALSE // in case they repair it after this, reset
		broken = REALLY_BROKEN
		explosion(src, heavy_impact_range = 1, light_impact_range = 2, flame_range = 1)
	for(var/obj/item/cooked_item in ingredients)
		var/sigreturn = cooked_item.microwave_act(src, cooker, randomize_pixel_offset = ingredients.len)
		if(sigreturn & COMPONENT_MICROWAVE_SUCCESS)
			if(isstack(cooked_item))
				var/obj/item/stack/cooked_stack = cooked_item
				dirty += cooked_stack.amount
			else
				dirty++
	after_finish_loop()

/obj/machinery/microwave/proc/pre_fail()
	broken = REALLY_BROKEN
	operating = FALSE
	spark()
	after_finish_loop()

/obj/machinery/microwave/proc/pre_success(mob/cooker)
	cook_loop(type = MICROWAVE_NORMAL, cycles = 10, cooker = cooker)

/obj/machinery/microwave/proc/muck_finish()
	visible_message(span_warning("\The [src] gets covered in muck!"))

	dirty = MAX_MICROWAVE_DIRTINESS
	dirty_anim_playing = FALSE
	operating = FALSE

	after_finish_loop()

/obj/machinery/microwave/proc/after_finish_loop()
	set_light_on(FALSE)
	soundloop.stop()
	eject()
	open(autoclose = 2 SECONDS)

/obj/machinery/microwave/proc/open(autoclose = 2 SECONDS)
	open = TRUE
	playsound(loc, 'sound/machines/click.ogg', 15, TRUE, -3)
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(close)), autoclose)

/obj/machinery/microwave/proc/close()
	open = FALSE
	update_appearance()

/obj/machinery/microwave/power_change()
	. = ..()
	if((machine_stat & NOPOWER) && operating)
		pre_fail()
		eject()

#undef MICROWAVE_NORMAL
#undef MICROWAVE_MUCK
#undef MICROWAVE_PRE

#undef NOT_BROKEN
#undef KINDA_BROKEN
#undef REALLY_BROKEN

#undef MAX_MICROWAVE_DIRTINESS
#undef TIER_1_CELL_CHARGE_RATE
