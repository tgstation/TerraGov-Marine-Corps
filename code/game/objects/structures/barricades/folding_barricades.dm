
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
	barricade_flags = parent_type::barricade_flags|BARRICADE_CAN_WIRE|BARRICADE_CAN_MOVE|BARRICADE_STANDARD_REPAIR
	skill_level = SKILL_ENGINEER_PLASTEEL
	///wether we react with other cades next to us ie when opening or so
	var/linked = FALSE
	///If we can be linked to nearby cades of the sametype
	var/linkable = TRUE

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

/obj/structure/barricade/folding/crowbar_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return
	if(build_state != BARRICADE_FIRM)
		return FALSE
	if(!linkable)
		return FALSE
	balloon_alert_to_viewers("[linked ? "un" : "" ]linked")
	linked = !linked
	for(var/direction in LeftAndRightOfDir(dir))
		for(var/obj/structure/barricade/folding/cade in get_step(src, direction))
			if(cade.dir != dir)
				continue
			cade.update_appearance(UPDATE_ICON)
	update_appearance(UPDATE_ICON)
	return TRUE

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

///Toggle open or closed
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
	skill_level = SKILL_ENGINEER_METAL
	soft_armor = list(MELEE = 0, BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 0, BIO = 100, FIRE = 80, ACID = 40)
