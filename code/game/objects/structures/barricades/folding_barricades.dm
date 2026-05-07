
#define BARRICADE_PLASTEEL_LOOSE 0
#define BARRICADE_PLASTEEL_ANCHORED 1
#define BARRICADE_PLASTEEL_FIRM 2

/obj/structure/barricade/folding
	name = "folding plasteel barricade"
	desc = "A very sturdy barricade made out of plasteel panels, the pinnacle of strongpoints. Use a blowtorch to repair. Can be flipped down to create a path."
	icon = 'icons/obj/structures/barricades/plasteel.dmi'
	icon_state = "folding_plasteel_0"
	max_integrity = 550
	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 80, ACID = 50)
	coverage = 128
	stack_type = /obj/item/stack/sheet/plasteel
	stack_amount = BUILD_COST_PLASTEEL_CADE_FOLDABLE
	destroyed_stack_amount = 2
	hit_sound = "sound/effects/metalhit.ogg"
	base_icon_state = "folding_plasteel"
	barricade_flags = parent_type::barricade_flags|BARRICADE_CAN_WIRE
	COOLDOWN_DECLARE(tool_cooldown) //Delay to apply tools to prevent spamming
	///What state is our barricade in for construction steps?
	var/build_state = BARRICADE_PLASTEEL_FIRM
	///Whether something is happening with the cade currently
	var/busy = FALSE
	///wether we react with other cades next to us ie when opening or so
	var/linked = FALSE
	///If we can be linked to nearby cades of the sametype
	var/linkable = TRUE
	///The skill type of this cade, used for fumble checks
	var/skilltype = SKILL_ENGINEER_PLASTEEL

/obj/structure/barricade/folding/Initialize(mapload, mob/user)
	. = ..()
	if(!user || !HAS_TRAIT(user, TRAIT_SUPERIOR_BUILDER))
		return
	modify_max_integrity(max_integrity + 100)

/obj/structure/barricade/folding/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -40, 8, 1)

/obj/structure/barricade/folding/handle_barrier_chance(mob/living/M)
	if(barricade_flags & BARRICADE_OPEN)
		return FALSE
	return ..()

/obj/structure/barricade/folding/examine(mob/user)
	. = ..()

	switch(build_state)
		if(BARRICADE_PLASTEEL_FIRM)
			. += span_info("The protection panel is still tighly screwed in place.")
		if(BARRICADE_PLASTEEL_ANCHORED)
			. += span_info("The protection panel has been removed, you can see the anchor bolts.")
		if(BARRICADE_PLASTEEL_LOOSE)
			. += span_info("The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.")

/obj/structure/barricade/folding/welder_act(mob/living/user, obj/item/I)
	. = welder_repair_act(user, I, 85, 2.5 SECONDS, 0.3, skilltype, 1)
	if(. == BELOW_INTEGRITY_THRESHOLD)
		balloon_alert(user, "too damaged, need [BARRICADE_REPAIR_STACK_AMOUNT] [stack_type::name] sheets!")

/obj/structure/barricade/folding/screwdriver_act(mob/living/user, obj/item/I)
	if(!isscrewdriver(I))
		return

	if(busy || !COOLDOWN_FINISHED(src, tool_cooldown))
		return

	if(LAZYACCESS(user.do_actions, src))
		return

	COOLDOWN_START(src, tool_cooldown, 1 SECONDS)

	switch(build_state)
		if(BARRICADE_PLASTEEL_FIRM) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(user.skills.getRating(SKILL_ENGINEER) < skilltype)
				var/fumbling_time = 1 SECONDS * ( skilltype - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return

			for(var/obj/structure/barricade/B in loc)
				if(B != src && B.dir == dir)
					balloon_alert(user, "already a barricade here!")
					return

			if(!do_after(user, 1, NONE, src, BUSY_ICON_BUILD))
				return

			balloon_alert_to_viewers("bolt protection panel removed")
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			build_state = BARRICADE_PLASTEEL_ANCHORED
		if(BARRICADE_PLASTEEL_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(user.skills.getRating(SKILL_ENGINEER) < skilltype)
				var/fumbling_time = 1 SECONDS * ( skilltype - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			balloon_alert_to_viewers("bolt protection panel replaced")
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			build_state = BARRICADE_PLASTEEL_FIRM

/obj/structure/barricade/folding/crowbar_act(mob/living/user, obj/item/I)
	if(!iscrowbar(I))
		return

	if(busy || !COOLDOWN_FINISHED(src, tool_cooldown))
		return

	if(LAZYACCESS(user.do_actions, src))
		return

	COOLDOWN_START(src, tool_cooldown, 1 SECONDS)

	switch(build_state)
		if(BARRICADE_PLASTEEL_FIRM)
			if(linkable)
				balloon_alert_to_viewers("[linked ? "un" : "" ]linked")
				linked = !linked
				for(var/direction in GLOB.cardinals)
					for(var/obj/structure/barricade/folding/cade in get_step(src, direction))
						cade.update_appearance(UPDATE_ICON)
				update_appearance(UPDATE_ICON)
		if(BARRICADE_PLASTEEL_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing.
			if(user.skills.getRating(SKILL_ENGINEER) < skilltype)
				var/fumbling_time = 5 SECONDS * ( skilltype - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			balloon_alert_to_viewers("disassembling...")
			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			busy = TRUE

			if(!do_after(user, 5 SECONDS, NONE, src, BUSY_ICON_BUILD))
				busy = FALSE
				return

			busy = FALSE
			user.visible_message(span_notice("[user] takes [src]'s panels apart."),
			span_notice("You take [src]'s panels apart."))
			playsound(loc, 'sound/items/deconstruct.ogg', 25, 1)
			deconstruct(!get_self_acid())

/obj/structure/barricade/folding/wrench_act(mob/living/user, obj/item/I)
	if(!iswrench(I))
		return

	if(busy || !COOLDOWN_FINISHED(src, tool_cooldown))
		return

	if(LAZYACCESS(user.do_actions, src))
		return

	COOLDOWN_START(src, tool_cooldown, 1 SECONDS)

	switch(build_state)
		if(BARRICADE_PLASTEEL_ANCHORED) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(user.skills.getRating(SKILL_ENGINEER) < skilltype)
				var/fumbling_time = 1 SECONDS * ( skilltype - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			balloon_alert_to_viewers("anchor bolts loosened")
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			anchored = FALSE
			modify_max_integrity(initial(max_integrity) * 0.5)
			build_state = BARRICADE_PLASTEEL_LOOSE
			update_appearance(UPDATE_ICON) //unanchored changes layer
		if(BARRICADE_PLASTEEL_LOOSE) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to rescure anchor bolts
			var/turf/mystery_turf = get_turf(src)
			if(!isopenturf(mystery_turf))
				balloon_alert(user, "can't anchor here!")
				return

			var/turf/open/T = mystery_turf
			var/area/area = get_area(T)
			if(!T.allow_construction || area.area_flags & NO_CONSTRUCTION) //We shouldn't be able to anchor in areas we're not supposed to build; loophole closed.
				balloon_alert(user, "can't anchor here!")
				return

			if(user.skills.getRating(SKILL_ENGINEER) < skilltype)
				var/fumbling_time = 1 SECONDS * ( skilltype - user.skills.getRating(SKILL_ENGINEER) )
				if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
					return
			balloon_alert_to_viewers("secured bolts")
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			anchored = TRUE
			modify_max_integrity(initial(max_integrity))
			build_state = BARRICADE_PLASTEEL_ANCHORED
			update_appearance(UPDATE_ICON) //unanchored changes layer

/obj/structure/barricade/folding/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(!istype(I, stack_type))
		return
	var/obj/item/stack/sheet/stack = I
	if(obj_integrity >= max_integrity * 0.3)
		return

	if(stack.get_amount() < 2)
		balloon_alert(user, "[BARRICADE_REPAIR_STACK_AMOUNT] [stack_type::name] sheets required!")
		return

	if(LAZYACCESS(user.do_actions, src))
		return

	balloon_alert_to_viewers("repairing base...")

	if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_FRIENDLY) || obj_integrity >= max_integrity * 0.3)
		return

	if(get_self_acid())
		balloon_alert(user, "it's melting!")
		return TRUE

	if(!stack.use(2))
		return

	repair_damage(max_integrity * 0.3, user)
	balloon_alert_to_viewers("base repaired")
	update_appearance(UPDATE_ICON)

/obj/structure/barricade/folding/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	toggle_open(null, user)

/obj/structure/barricade/folding/proc/toggle_open(state, atom/user)
	if(state == (barricade_flags & BARRICADE_OPEN))
		return
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	TOGGLE_BITFIELD(barricade_flags, BARRICADE_OPEN)
	density = !density

	user?.visible_message(span_notice("[user] flips [src] [(barricade_flags & BARRICADE_OPEN) ? "open" :"closed"]."),
		span_notice("You flip [src] [(barricade_flags & BARRICADE_OPEN) ? "open" :"closed"]."))

	if(!linked || !linkable)
		update_appearance(UPDATE_ICON)
		return
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/barricade/folding/cade in get_step(src, direction))
			if(((dir & (NORTH|SOUTH) && get_dir(src, cade) & (EAST|WEST)) || (dir & (EAST|WEST) && get_dir(src, cade) & (NORTH|SOUTH))) && dir == cade.dir && cade.linked)
				cade.toggle_open(barricade_flags & BARRICADE_OPEN)

	update_appearance(UPDATE_ICON)

/obj/structure/barricade/folding/update_overlays()
	. = ..()
	if(!linked)
		return
	for(var/direction in LeftAndRightOfDir(dir))
		for(var/obj/structure/barricade/folding/cade in get_step(src, direction))
			if(dir != cade.dir)
				continue
			if(!cade.linked)
				continue
			if((barricade_flags & BARRICADE_OPEN) != (cade.barricade_flags & BARRICADE_OPEN))
				continue
			. += image(icon, icon_state = "[base_icon_state]_[(barricade_flags & BARRICADE_OPEN) ? "open" : "closed"]_connection_[get_dir(src, cade)]")

/obj/structure/barricade/folding/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(rand(450, 650), BRUTE, BOMB)
		if(EXPLODE_HEAVY)
			take_damage(rand(200, 400), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 150), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(rand(25, 75), BRUTE, BOMB)

	update_appearance(UPDATE_ICON)

/obj/structure/barricade/folding/capsule
	name = "capsule-deployed folding plasteel barricade"
	desc = parent_type::desc + " Deconstruction will yield less materials due to being deployed via capsule."
	stack_amount = 4

/obj/structure/barricade/folding/metal
	name = "folding metal barricade"
	desc = "A folding barricade made out of metal, making it slightly stronger than a normal metal barricade. Use a blowtorch to repair. Can be flipped down to create a path."
	icon_state = "folding_metal_0"
	icon = 'icons/obj/structures/barricades/metal.dmi'
	max_integrity = 350
	stack_type = /obj/item/stack/sheet/metal
	stack_amount = BUILD_COST_METAL_CADE_FOLDABLE
	destroyed_stack_amount = 3
	base_icon_state = "folding_metal"
	linkable = FALSE
	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 80, ACID = 40)

#undef BARRICADE_PLASTEEL_LOOSE
#undef BARRICADE_PLASTEEL_ANCHORED
#undef BARRICADE_PLASTEEL_FIRM
