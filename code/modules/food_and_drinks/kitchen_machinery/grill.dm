//I JUST WANNA GRILL FOR GOD'S SAKE

#define GRILL_FUELUSAGE_IDLE 0.5
#define GRILL_FUELUSAGE_ACTIVE 5

/obj/machinery/grill
	name = "grill"
	desc = "Just like the old days."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grill_open"
	density = TRUE
	layer = BELOW_OBJ_LAYER
	use_power = NO_POWER_USE
	var/grill_fuel = 0
	var/obj/item/reagent_containers/food/grilled_item
	var/grill_time = 0
	var/datum/looping_sound/grill/grill_loop

/obj/machinery/grill/Initialize(mapload)
	. = ..()
	grill_loop = new(null, FALSE)
	START_PROCESSING(SSmachines, src)

/obj/machinery/grill/Destroy()
	QDEL_NULL(grill_loop)
	grilled_item = null
	return ..()

/obj/machinery/grill/update_icon_state()
	if(grilled_item)
		icon_state = "grill"
		return ..()
	if(grill_fuel > 0)
		icon_state = "grill_on"
		return ..()
	icon_state = "grill_open"
	return ..()

/obj/machinery/grill/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/sheet/wood))
		var/obj/item/stack/S = I
		var/stackamount = S.get_amount()
		to_chat(user, span_notice("You put [stackamount] [I]s in [src]."))
		grill_fuel += (100 * stackamount)
		S.use(stackamount)
		update_icon()
		return

	if(grill_fuel <= 0)
		to_chat(user, span_warning("No fuel!"))
		return ..()

	if(isgrabitem(I))
		var/obj/item/grab/grab_item = I
		if(!isliving(grab_item.grabbed_thing))
			return
		var/mob/living/living_victim = grab_item.grabbed_thing
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, span_warning("You need a better grip to do that!"))
			return
		if(user.do_actions)
			return

		user.visible_message(span_danger("[user] starts to press [living_victim] onto the [src]!"))

		if(!do_after(user, 0.5 SECONDS, NONE, living_victim, BUSY_ICON_DANGER) || QDELETED(src))
			return

		user.visible_message(span_danger("[user] slams [living_victim] onto the [src]!"))
		living_victim.apply_damage(40, BURN, BODY_ZONE_HEAD, FIRE, updating_health = TRUE)
		playsound(src, "sound/machines/grill/frying.ogg", 100, null, 9)
		living_victim.emote("scream")
		return

	if(I.resistance_flags & INDESTRUCTIBLE)
		to_chat(user, span_warning("You don't feel it would be wise to grill [I]..."))
		return ..()

	//else if(IS_EDIBLE(I))
	else if(istype(I, /obj/item/reagent_containers/food))
		if(HAS_TRAIT(I, TRAIT_NODROP) || (I.flags_item & (ITEM_ABSTRACT|DELONDROP)))
			return ..()
		else if(HAS_TRAIT(I, TRAIT_FOOD_GRILLED))
			to_chat(user, span_notice("[I] has already been grilled!"))
			return
		else if(grill_fuel <= 0)
			to_chat(user, span_warning("There is not enough fuel!"))
			return
		else if(!grilled_item && user.transferItemToLoc(I, src))
			grilled_item = I
			RegisterSignal(grilled_item, COMSIG_GRILL_COMPLETED, PROC_REF(GrillCompleted))
			ADD_TRAIT(grilled_item, TRAIT_FOOD_GRILLED, "boomers")
			to_chat(user, span_notice("You put the [grilled_item] on [src]."))
			update_icon()
			grill_loop.start(src)

			return

	return ..()

/obj/machinery/grill/process(delta_time)
	..()
	update_icon()
	if(grill_fuel <= 0)
		return
	else
		grill_fuel -= GRILL_FUELUSAGE_IDLE * 2
		if(prob(5))
			var/datum/effect_system/smoke_spread/bad/smoke = new
			smoke.set_up(1, loc)
			smoke.start()
	if(grilled_item)
		SEND_SIGNAL(grilled_item, COMSIG_ITEM_GRILLED, src, 2)
		grill_time += 2
		grill_fuel -= GRILL_FUELUSAGE_ACTIVE * 2
		grilled_item.AddComponent(/datum/component/sizzle)

/obj/machinery/grill/Exited(atom/movable/gone, direction)
	if(gone == grilled_item)
		finish_grill()
		grilled_item = null
	return ..()


/obj/machinery/grill/handle_atom_del(atom/A)
	if(A == grilled_item)
		grilled_item = null
	return ..()

/obj/machinery/grill/wrench_act(mob/living/user, obj/item/I)
	..()
	balloon_alert(user, "You begin [anchored ? "un" : ""]securing...")
	I.play_tool_sound(src, 50)
	//as long as we're the same anchored state and we're either on a floor or are anchored, toggle our anchored state
	if(!I.use_tool(src, user, 2 SECONDS))
		return FALSE
	balloon_alert(user, "You [anchored ? "un" : ""]secure.")
	anchored = !anchored
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	return TRUE

/obj/machinery/grill/deconstruct(disassembled = TRUE)
	finish_grill()
	if(!(flags_atom & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 5)
		new /obj/item/stack/rods(loc, 5)
	..()

/obj/machinery/grill/attack_ai(mob/user)
	return

/obj/machinery/grill/attack_hand(mob/user, list/modifiers)
	if(grilled_item)
		to_chat(user, span_notice("You take out [grilled_item] from [src]."))
		grilled_item.forceMove(drop_location())
		update_icon()
		return
	return ..()

/obj/machinery/grill/proc/finish_grill()
	switch(grill_time) //no 0-20 to prevent spam
		if(20 to 30)
			grilled_item.name = "lightly-grilled [grilled_item.name]"
			grilled_item.desc = "[grilled_item.desc] It's been lightly grilled."
		if(30 to 80)
			grilled_item.name = "grilled [grilled_item.name]"
			grilled_item.desc = "[grilled_item.desc] It's been grilled."
			//grilled_item.foodtype |= FRIED
		if(80 to 100)
			grilled_item.name = "heavily grilled [grilled_item.name]"
			grilled_item.desc = "[grilled_item.desc] It's been heavily grilled."
			//grilled_item.foodtype |= FRIED
		if(100 to INFINITY) //grill marks reach max alpha
			grilled_item.name = "Powerfully Grilled [grilled_item.name]"
			grilled_item.desc = "A [grilled_item.name]. Reminds you of your wife, wait, no, it's prettier!"
			//grilled_item.foodtype |= FRIED
	grill_time = 0
	UnregisterSignal(grilled_item, COMSIG_GRILL_COMPLETED)
	grill_loop.stop()

///Called when a food is transformed by the grillable component
/obj/machinery/grill/proc/GrillCompleted(obj/item/source, atom/grilled_result)
	SIGNAL_HANDLER
	grilled_item = grilled_result //use the new item!!

/obj/machinery/grill/unwrenched
	anchored = FALSE

#undef GRILL_FUELUSAGE_IDLE
#undef GRILL_FUELUSAGE_ACTIVE
