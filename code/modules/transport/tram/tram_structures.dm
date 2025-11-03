/**
 * the tram has a few objects mapped onto it at roundstart, by default many of those objects have unwanted properties
 * for example grilles and windows have the atmos_sensitive element applied to them, which makes them register to
 * themselves moving to re register signals onto the turf via connect_loc. this is bad and dumb since it makes the tram
 * more expensive to move.
 *
 * if you map something on to the tram, make SURE if possible that it doesnt have anything reacting to its own movement
 * it will make the tram more expensive to move and we dont want that because we dont want to return to the days where
 * the tram took a third of the tick per movement when it's just carrying its default mapped in objects
 */

/obj/structure/tram
	name = "tram wall"
	desc = "A lightweight titanium composite structure with titanium silicate panels."
	icon = 'icons/obj/tram/tram_structure.dmi'
	icon_state = "tram-part-0"
	base_icon_state = "tram-part"
	max_integrity = 150
	layer = TRAM_WALL_LAYER
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	atom_flags = PREVENT_CLICK_UNDER
	pass_flags = PASS_GLASS
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TRAM_STRUCTURE
	canSmoothWith = SMOOTH_GROUP_TRAM_STRUCTURE
	explosion_block = 3
	/// What state of de/construction it's in
	var/state = TRAM_SCREWED_TO_FRAME
	/// Mineral to return when deconstructed
	var/mineral = /obj/item/stack/sheet/plasteel
	/// Amount of mineral to return when deconstructed
	var/mineral_amount = 2
	/// Type of structure made out of girder
	var/tram_wall_type = /obj/structure/tram
	/// Type of girder made when deconstructed
	var/girder_type = /obj/structure/girder
	var/mutable_appearance/damage_overlay
	/// Sound when it breaks
	var/break_sound = SFX_SHATTER
	/// Sound when hit without combat mode
	var/knock_sound = 'sound/effects/glassknock.ogg'
	/// Sound when hit with combat mode
	var/bash_sound = 'sound/effects/Glasshit.ogg'

/obj/structure/tram/split
	base_icon_state = "tram-split"

/datum/armor/tram_structure
	melee = 40
	bullet = 10
	laser = 10
	bomb = 45
	fire = 90
	acid = 100

/obj/structure/tram/Initialize(mapload)
//	AddElement(/datum/element/blocks_explosives)
	. = ..()

/obj/structure/tram/examine(mob/user)
	. = ..()
	switch(state)
		if(TRAM_SCREWED_TO_FRAME)
			. += span_notice("The panel is [EXAMINE_HINT("screwed")] to the frame. To dismantle use a [EXAMINE_HINT("screwdriver.")]")
		if(TRAM_IN_FRAME)
			. += span_notice("The panel is [EXAMINE_HINT("unscrewed,")] but [EXAMINE_HINT("pried")] into the frame. To dismantle use a [EXAMINE_HINT("crowbar.")]")
		if(TRAM_OUT_OF_FRAME)
			. += span_notice("The panel is [EXAMINE_HINT("pried")] out of the frame, but still[EXAMINE_HINT("wired.")] To dismantle use [EXAMINE_HINT("wirecutters.")]")

/obj/structure/tram/update_overlays(updates = ALL)
	. = ..()
	var/ratio = obj_integrity / max_integrity
	ratio = CEILING(ratio * 4, 1) * 25
	if(ratio > 75)
		return
	// tivi todo does this look ok check with actual walls
	var/alpha_inc = 256 * ratio
	damage_overlay = image(icon = 'icons/turf/walls.dmi', icon_state = "overlay_damage")
	damage_overlay.blend_mode = BLEND_MULTIPLY
	damage_overlay.alpha = (alpha_inc) - 1
	. += damage_overlay

/obj/structure/tram/attack_hand(mob/living/user, list/modifiers)
	. = ..()

	if(user.a_intent != INTENT_HARM)
		user.visible_message(span_notice("[user] knocks on [src]."), \
			span_notice("You knock on [src]."))
		playsound(src, knock_sound, 50, TRUE)
	else
		user.visible_message(span_warning("[user] bashes [src]!"), \
			span_warning("You bash [src]!"))
		playsound(src, bash_sound, 100, TRUE)

/obj/structure/tram/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	. = ..()
	if(.) //received damage
		update_appearance()

/obj/structure/tram/welder_act(mob/living/user, obj/item/tool)
	if(obj_integrity >= max_integrity)
		to_chat(user, span_warning("[src] is already in good condition!"))
		return TRUE
	if(!tool.tool_start_check(user, amount = 0))
		return FALSE
	to_chat(user, span_notice("You begin repairing [src]..."))
	if(tool.use_tool(src, user, 4 SECONDS, volume = 50))
		obj_integrity = max_integrity
		to_chat(user, span_notice("You repair [src]."))
		update_appearance()
	return TRUE

/obj/structure/tram/attackby_alternate(obj/item/attacking_item, mob/user, params)
	switch(state)
		if(TRAM_SCREWED_TO_FRAME)
			if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(span_notice("[user] begins to unscrew the tram panel from the frame..."),
				span_notice("You begin to unscrew the tram panel from the frame..."))
				if(attacking_item.use_tool(src, user, 1 SECONDS, volume = 50))
					state = TRAM_IN_FRAME
					to_chat(user, span_notice("The screws come out, and a gap forms around the edge of the pane."))
					return TRUE

			if(attacking_item.tool_behaviour)
				to_chat(user, span_warning("The security screws need to be removed first!"))

		if(TRAM_IN_FRAME)
			if(attacking_item.tool_behaviour == TOOL_CROWBAR)
				user.visible_message(span_notice("[user] wedges \the [attacking_item] into the tram panel's gap in the frame and starts prying..."),
				span_notice("You wedge \the [attacking_item] into the tram panel's gap in the frame and start prying..."))
				if(attacking_item.use_tool(src, user, 1 SECONDS, volume = 50))
					state = TRAM_OUT_OF_FRAME
					to_chat(user, span_notice("The panel pops out of the frame, exposing some cabling that look like they can be cut."))
					return TRUE

			if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
				user.visible_message(span_notice("[user] resecures the tram panel to the frame..."),
				span_notice("You resecure the tram panel to the frame..."))
				state = TRAM_SCREWED_TO_FRAME
				return TRUE

		if(TRAM_OUT_OF_FRAME)
			if(attacking_item.tool_behaviour == TOOL_WIRECUTTER)
				user.visible_message(span_notice("[user] starts cutting the connective cabling on \the [src]..."),
				span_notice("You start cutting the connective cabling on \the [src]"))
				if(attacking_item.use_tool(src, user, 1 SECONDS, volume = 50))
					to_chat(user, span_notice("The panels falls out of the way exposing the frame backing."))
					deconstruct(disassembled = TRUE)

			if(attacking_item.tool_behaviour == TOOL_CROWBAR)
				user.visible_message(span_notice("[user] snaps the tram panel into place."),
				span_notice("You snap the tram panel into place..."))
				state = TRAM_IN_FRAME
				return TRUE

			if(attacking_item.tool_behaviour)
				to_chat(user, span_warning("The cabling need to be cut first!"))

	return ..()

/obj/structure/tram/deconstruct(disassembled, mob/living/blame_mob)
	. = ..()
	if(disassembled)
		new girder_type(loc)
	if(mineral_amount)
		for(var/i in 1 to mineral_amount)
			new mineral(loc)

/*
/obj/structure/tram/attackby(obj/item/item, mob/user, params)
	. = ..()

	if(istype(item, /obj/item/wallframe/tram))
		try_wallmount(item, user)

/obj/structure/tram/proc/try_wallmount(obj/item/wallmount, mob/user)
	if(!istype(wallmount, /obj/item/wallframe/tram))
		return

	var/obj/item/wallframe/frame = wallmount
	if(frame.try_build(src, user))
		frame.attach(src, user)

	return
*/
/*
 * Other misc tramwall types
 */

/obj/structure/tram/alt

/*
/obj/structure/tram/alt/titanium
	name = "solid tram"
	desc = "A lightweight titanium composite structure. There is further solid plating where the panels usually attach to the frame."
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "shuttle_wall-0"
	base_icon_state = "shuttle_wall"
	mineral = /obj/item/stack/sheet/mineral/titanium
	tram_wall_type = /obj/structure/tram/alt/titanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TITANIUM_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_TITANIUM_WALLS

/obj/structure/tram/alt/plastitanium
	name = "reinforced tram"
	desc = "An evil tram of plasma and titanium."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	mineral = /obj/item/stack/sheet/mineral/plastitanium
	tram_wall_type = /obj/structure/tram/alt/plastitanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PLASTITANIUM_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_PLASTITANIUM_WALLS

/obj/structure/tram/alt/gold
	name = "gold tram"
	desc = "A solid gold tram. Swag!"
	icon = 'icons/turf/walls/gold_wall.dmi'
	icon_state = "gold_wall-0"
	base_icon_state = "gold_wall"
	mineral = /obj/item/stack/sheet/mineral/gold
	tram_wall_type = /obj/structure/tram/alt/gold
	explosion_block = 0 //gold is a soft metal you dingus.
	smoothing_groups = SMOOTH_GROUP_GOLD_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_GOLD_WALLS
	custom_materials = list(/datum/material/gold = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/tram/alt/silver
	name = "silver tram"
	desc = "A solid silver tram. Shiny!"
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver_wall-0"
	base_icon_state = "silver_wall"
	mineral = /obj/item/stack/sheet/mineral/silver
	tram_wall_type = /obj/structure/tram/alt/silver
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SILVER_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_SILVER_WALLS
	custom_materials = list(/datum/material/silver = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/tram/alt/diamond
	name = "diamond tram"
	desc = "A composite structure with diamond-plated panels. Looks awfully sharp..."
	icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond_wall-0"
	base_icon_state = "diamond_wall"
	mineral = /obj/item/stack/sheet/mineral/diamond
	tram_wall_type = /obj/structure/tram/alt/diamond //diamond wall takes twice as much time to slice
	max_integrity = 800
	explosion_block = 3
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_DIAMOND_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_DIAMOND_WALLS
	custom_materials = list(/datum/material/diamond = SHEET_MATERIAL_AMOUNT * 2)

/obj/structure/tram/alt/bananium
	name = "bananium tram"
	desc = "A composite structure with bananium plating. Honk!"
	icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium_wall-0"
	base_icon_state = "bananium_wall"
	mineral = /obj/item/stack/sheet/mineral/bananium
	tram_wall_type = /obj/structure/tram/alt/bananium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_BANANIUM_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_BANANIUM_WALLS
	custom_materials = list(/datum/material/bananium = SHEET_MATERIAL_AMOUNT*2)

/obj/structure/tram/alt/sandstone
	name = "sandstone tram"
	desc = "A composite structure with sandstone plating. Rough."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone_wall-0"
	base_icon_state = "sandstone_wall"
	mineral = /obj/item/stack/sheet/mineral/sandstone
	tram_wall_type = /obj/structure/tram/alt/sandstone
	explosion_block = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SANDSTONE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_SANDSTONE_WALLS
	custom_materials = list(/datum/material/sandstone = SHEET_MATERIAL_AMOUNT*2)

/obj/structure/tram/alt/uranium
	article = "a"
	name = "uranium tram"
	desc = "A composite structure with uranium plating. This is probably a bad idea."
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium_wall-0"
	base_icon_state = "uranium_wall"
	mineral = /obj/item/stack/sheet/mineral/uranium
	tram_wall_type = /obj/structure/tram/alt/uranium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_URANIUM_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_URANIUM_WALLS
	custom_materials = list(/datum/material/uranium = SHEET_MATERIAL_AMOUNT*2)

/obj/structure/tram/alt/plasma
	name = "plasma tram"
	desc = "A composite structure with plasma plating. This is definitely a bad idea."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma_wall-0"
	base_icon_state = "plasma_wall"
	mineral = /obj/item/stack/sheet/mineral/plasma
	tram_wall_type = /obj/structure/tram/alt/plasma
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PLASMA_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_PLASMA_WALLS
	custom_materials = list(/datum/material/plasma = SHEET_MATERIAL_AMOUNT*2)

/obj/structure/tram/alt/wood
	name = "wooden tram"
	desc = "A tram with wooden framing. Flammable. There's a reason we use metal now."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	mineral = /obj/item/stack/sheet/mineral/wood
	tram_wall_type = /obj/structure/tram/alt/wood
	explosion_block = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT*2)

/obj/structure/tram/alt/bamboo
	name = "bamboo tram"
	desc = "A tram with a bamboo framing."
	icon = 'icons/turf/walls/bamboo_wall.dmi'
	icon_state = "bamboo_wall-0"
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_BAMBOO_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_BAMBOO_WALLS
	mineral = /obj/item/stack/sheet/mineral/bamboo
	tram_wall_type = /obj/structure/tram/alt/bamboo

/obj/structure/tram/alt/iron
	name = "rough iron tram"
	desc = "A composite structure with rough iron plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron_wall-0"
	base_icon_state = "iron_wall"
	mineral = /obj/item/stack/rods
	mineral_amount = 5
	tram_wall_type = /obj/structure/tram/alt/iron
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_IRON_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_IRON_WALLS
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 2.5)

/obj/structure/tram/alt/abductor
	name = "alien tram"
	desc = "A composite structure made of some kind of alien alloy."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor_wall-0"
	base_icon_state = "abductor_wall"
	mineral = /obj/item/stack/sheet/mineral/abductor
	tram_wall_type = /obj/structure/tram/alt/abductor
	explosion_block = 3
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_WALLS
	custom_materials = list(/datum/material/alloy/alien = SHEET_MATERIAL_AMOUNT*2)
*/

/obj/structure/tram/spoiler
	name = "tram spoiler"
	icon = 'icons/obj/tram/tram_structure.dmi'
	desc = "Nanotrasen bought the luxury package under the impression titanium spoilers make the tram go faster. They're just for looks, or potentially stabbing anybody who gets in the way."
	icon_state = "tram-spoiler-retracted"
	max_integrity = 400
	obj_flags = CAN_BE_HIT
	girder_type = /obj/structure/girder
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	/// Position of the spoiler
	var/deployed = FALSE
	/// Locked in position
	var/locked = FALSE
	/// Weakref to the tram piece we control
	var/datum/weakref/tram_ref
	/// The tram we're attached to
	var/tram_id = TRAMSTATION_LINE_1

/obj/structure/tram/spoiler/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/tram/spoiler/LateInitialize()
	RegisterSignal(SStransport, COMSIG_TRANSPORT_ACTIVE, PROC_REF(set_spoiler))

/obj/structure/tram/spoiler/examine(mob/user)
	. = ..()
/*
	if(obj_flags & EMAGGED)
		. += span_warning("The electronics panel is sparking occasionally. It can be reset with a [EXAMINE_HINT("multitool.")]")
*/
	if(locked)
		. += span_warning("The spoiler is [EXAMINE_HINT("welded")] in place!")
	else
		. += span_notice("The spoiler can be locked in place with a [EXAMINE_HINT("welder.")]")

/obj/structure/tram/spoiler/proc/set_spoiler(source, controller, controller_active, controller_status, travel_direction)
	SIGNAL_HANDLER

	var/spoiler_direction = travel_direction
	if(locked || controller_status & COMM_ERROR)
		if(!deployed)
			// Bring out the blades
			if(locked)
				visible_message(span_danger("\the [src] locks up due to its servo overheating!"))
			do_sparks(3, FALSE, src)
			deploy_spoiler()
		return

	if(!controller_active)
		return

	switch(spoiler_direction)
		if(SOUTH, EAST)
			switch(dir)
				if(NORTH, EAST)
					retract_spoiler()
				if(SOUTH, WEST)
					deploy_spoiler()

		if(NORTH, WEST)
			switch(dir)
				if(NORTH, EAST)
					deploy_spoiler()
				if(SOUTH, WEST)
					retract_spoiler()
	return

/obj/structure/tram/spoiler/proc/deploy_spoiler()
	if(deployed)
		return
	flick("tram-spoiler-deploying", src)
	icon_state = "tram-spoiler-deployed"
	deployed = TRUE
	update_appearance()

/obj/structure/tram/spoiler/proc/retract_spoiler()
	if(!deployed)
		return
	flick("tram-spoiler-retracting", src)
	icon_state = "tram-spoiler-retracted"
	deployed = FALSE
	update_appearance()

/obj/structure/tram/spoiler/welder_act(mob/living/user, obj/item/tool)
	if(!tool.tool_start_check(user, amount = 1))
		return FALSE

	if(obj_integrity >= max_integrity)
		to_chat(user, span_warning("You begin to weld \the [src], [locked ? "repairing damage" : "preventing retraction"]."))
		if(!tool.use_tool(src, user, 4 SECONDS, volume = 50))
			return
		locked = !locked
		user.visible_message(span_warning("[user] [locked ? "welds \the [src] in place" : "repairs \the [src]"] with [tool]."), \
			span_warning("You finish welding \the [src], [locked ? "locking it in place." : "it can move freely again!"]"), null, COMBAT_MESSAGE_RANGE)

		if(locked)
			deploy_spoiler()

		update_appearance()
		return TRUE

	to_chat(user, span_notice("You begin repairing [src]..."))
	if(!tool.use_tool(src, user, 4 SECONDS, volume = 50))
		return
	repair_damage(max_integrity)
	to_chat(user, span_notice("You repair [src]."))
	update_appearance()
	return TRUE

/obj/structure/tram/spoiler/update_overlays()
	. = ..()
	if(deployed && locked)
		. += mutable_appearance(icon, "tram-spoiler-welded")

/obj/structure/chair/sofa/bench/tram
	name = "bench"
	desc = "Perfectly designed to be comfortable to sit on, and hellish to sleep on."
	icon_state = "bench_middle"
	greyscale_config = /datum/greyscale_config/bench_middle
	greyscale_colors = COLOR_TRAM_BLUE

/obj/structure/chair/sofa/bench/tram/left
	icon_state = "bench_left"
	greyscale_config = /datum/greyscale_config/bench_left

/obj/structure/chair/sofa/bench/tram/right
	icon_state = "bench_right"
	greyscale_config = /datum/greyscale_config/bench_right

/obj/structure/chair/sofa/bench/tram/corner
	icon_state = "bench_corner"
	greyscale_config = /datum/greyscale_config/bench_corner

/obj/structure/chair/sofa/bench/tram/solo
	icon_state = "bench_solo"
	greyscale_config = /datum/greyscale_config/bench_solo
