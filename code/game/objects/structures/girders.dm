/obj/structure/girder
	name = "girder"
	icon_state = "girder-0"
	icon = 'icons/obj/smooth_objects/girder.dmi'
	desc = "A large structural assembly made out of metal. It requires some layers of metal before it can be considered a wall."
	anchored = TRUE
	density = TRUE
	layer = OBJ_LAYER
	resistance_flags = XENO_DAMAGEABLE
	hit_sound = 'sound/effects/metalhit.ogg'
	max_integrity = 150
	integrity_failure = 25
	var/girder_state = GIRDER_NORMAL
	var/reinforcement = null
	var/icon_prefix = "girder"
	smoothing_flags = SMOOTH_BITMASK
	canSmoothWith = list(SMOOTH_GROUP_GIRDER,SMOOTH_GROUP_SURVIVAL_TITANIUM_WALLS)
	smoothing_groups = list(SMOOTH_GROUP_GIRDER)
	base_icon_state = "girder"

/obj/structure/girder/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_SPARKS, -15, 8, 1)

#define GIRDER_DECONSTRUCTING (new_state < girder_state)

/obj/structure/girder/proc/change_state(new_state, mob/user)
	if(new_state == girder_state)
		return
	switch(new_state)
		if(GIRDER_BROKEN)
			if(girder_state != GIRDER_BROKEN_PATCHED)
				modify_max_integrity(50, FALSE)
		if(GIRDER_NORMAL)
			if(GIRDER_DECONSTRUCTING)
				reinforcement = null
			else
				modify_max_integrity(150)
		if(GIRDER_BUILDING1_SECURED)
			if(GIRDER_DECONSTRUCTING)
				modify_max_integrity(150)
		if(GIRDER_BUILDING1_WELDED)
			if(!GIRDER_DECONSTRUCTING)
				modify_max_integrity((reinforcement == GIRDER_REINF_PLASTEEL) ? 600 : 300)
		if(GIRDER_WALL_BUILT)
			user.record_structures_built()
			return build_wall()
	girder_state = new_state
	density = (girder_state >= GIRDER_NORMAL)
	update_icon()

#undef GIRDER_DECONSTRUCTING


/obj/structure/girder/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, GIRDER_REINF_METAL) || istype(I, GIRDER_REINF_PLASTEEL))
		if(user.do_actions)
			return TRUE //no afterattack
		if(!anchored)
			return FALSE
		switch(girder_state)
			if(GIRDER_BROKEN)
				if(istype(I, GIRDER_REINF_PLASTEEL))
					return FALSE //Ugly, but eh.
				var/obj/item/stack/sheet/stack = I
				if(stack.amount < 2)
					return
				to_chat(user, span_notice("Now adding plating..."))
				if(!do_after(user, 4 SECONDS, NONE, src, BUSY_ICON_BUILD))
					return TRUE
				if(QDELETED(stack) || stack.amount < 2 || girder_state != GIRDER_BROKEN)
					return TRUE
				stack.use(2)
				to_chat(user, span_notice("You added the metal to the girder!"))
				change_state(GIRDER_BROKEN_PATCHED)
				return TRUE
			if(GIRDER_NORMAL)
				var/obj/item/stack/sheet/stack = I
				var/reinforced = istype(I, GIRDER_REINF_PLASTEEL)
				if(stack.amount < (reinforced ? 15 : 2))
					return TRUE
				to_chat(user, span_notice("Now adding plating..."))
				if(!do_after(user, 4 SECONDS * (reinforced ? 2 : 1), NONE, src, BUSY_ICON_BUILD))
					return TRUE
				if(QDELETED(stack) || stack.amount < (reinforced ? 15 : 2) || girder_state != GIRDER_NORMAL)
					return TRUE
				stack.use(reinforced ? 15 : 2)
				to_chat(user, span_notice("You added the plating!"))
				change_state(GIRDER_BUILDING1_LOOSE)
				reinforcement = (reinforced ? GIRDER_REINF_PLASTEEL : GIRDER_REINF_METAL)
				return TRUE
			if(GIRDER_BUILDING1_WELDED)
				if(!istype(I, reinforcement))
					return FALSE
				var/obj/item/stack/sheet/stack = I
				var/reinforced = (reinforcement == GIRDER_REINF_PLASTEEL)
				if(stack.amount < (reinforced ? 15 : 2))
					return TRUE
				var/old_girder_state = girder_state
				to_chat(user, span_notice("Now adding plating..."))
				if(!do_after(user, 4 SECONDS * (reinforced ? 2 : 1), NONE, src, BUSY_ICON_BUILD))
					return TRUE
				if(QDELETED(stack) || stack.amount < (reinforced ? 15 : 2) || girder_state != old_girder_state)
					return TRUE
				stack.use(reinforced ? 15 : 2)
				to_chat(user, span_notice("You added the plating!"))
				change_state(girder_state + 1)
				return TRUE
		return FALSE


/obj/structure/girder/welder_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	var/obj/item/tool/weldingtool/welder = I
	if(!welder.isOn())
		return FALSE
	switch(girder_state)
		if(GIRDER_BUILDING1_SECURED, GIRDER_BUILDING2_SECURED)
			var/old_girder_state = girder_state
			var/work_time = 3 SECONDS
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				work_time += 3 SECONDS
			if(!do_after(user, work_time, NONE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != old_girder_state)
				return TRUE
			if(!welder.remove_fuel(1, user))
				return TRUE
			playsound(loc, 'sound/items/welder2.ogg', 25, 1)
			to_chat(user, span_notice("You weld the [girder_state == GIRDER_BROKEN_PATCHED ? "girder together" : "metal to the girder"]!"))
			change_state(girder_state + 1, user)
			return TRUE
	return FALSE


/obj/structure/girder/wrench_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	switch(girder_state)
		if(GIRDER_BROKEN)
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			to_chat(user, span_notice("Now unbolting the remaining girder base."))
			if(!do_after(user, 1.5 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != GIRDER_BROKEN)
				return TRUE
			to_chat(user, span_notice("You scrap what is left from the girder!"))
			new /obj/item/stack/sheet/metal(loc)
			qdel(src)
			return TRUE
		if(GIRDER_NORMAL)
			var/turf/T = get_turf(src)
			if(anchored)
				return FALSE
			if(!isfloorturf(T) && !isbasalt(T) && !islavacatwalk(T) && !isopengroundturf(T))
				to_chat(usr, span_warning("The girder must be secured on the floor!"))
				return FALSE
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			to_chat(user, span_notice("Now securing the girder"))
			if(!do_after(user, 4 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE
			if(anchored || girder_state != GIRDER_NORMAL)
				return TRUE
			to_chat(user, span_notice("You secured the girder!"))
			anchored = TRUE
			modify_max_integrity(150)
			update_icon()
			return TRUE
	return FALSE

/obj/structure/girder/crowbar_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	switch(girder_state)
		if(GIRDER_NORMAL)
			if(!anchored)
				return FALSE
			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			to_chat(user, span_notice("Now dislodging the girder..."))
			if(!do_after(user, 4 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE
			if(!anchored || girder_state != GIRDER_NORMAL)
				return TRUE
			to_chat(user, span_notice("You dislodged the girder!"))
			anchored = FALSE
			modify_max_integrity(50)
			update_icon()
			return TRUE
		if(GIRDER_BUILDING1_LOOSE, GIRDER_BUILDING2_LOOSE)
			var/old_girder_state = girder_state
			var/work_time = 3 SECONDS
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				work_time += 3 SECONDS
			if(!do_after(user, work_time, NONE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != old_girder_state)
				return TRUE
			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			to_chat(user, span_notice("You pry the external reinforcement layer out of the girder!"))
			new reinforcement(loc) //This should come before change_state() as the var may get nulled there.
			change_state(girder_state - 1)
			return TRUE
	return FALSE


/obj/structure/girder/screwdriver_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	switch(girder_state)
		if(GIRDER_NORMAL)
			if(anchored)
				return FALSE
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			to_chat(user, span_notice("Now dissassembling the girder"))
			if(!do_after(user, 4 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE
			if(anchored || girder_state != GIRDER_NORMAL)
				return TRUE
			to_chat(user, span_notice("You finished dissassembling the girder!"))
			new /obj/item/stack/sheet/metal(loc)
			qdel(src)
			return TRUE
		if(GIRDER_BUILDING1_LOOSE, GIRDER_BUILDING2_LOOSE)
			to_chat(user, span_notice("Now securing support struts"))
			var/old_girder_state = girder_state
			var/work_time = 3 SECONDS
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				work_time += 3 SECONDS
			if(!do_after(user, work_time, NONE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != old_girder_state)
				return TRUE
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			to_chat(user, span_notice("You secured the support struts!"))
			change_state(girder_state + 1)
			return TRUE
		if(GIRDER_BUILDING1_SECURED, GIRDER_BUILDING2_SECURED)
			to_chat(user, span_notice("Now unsecuring support struts"))
			var/old_girder_state = girder_state
			var/work_time = 3 SECONDS
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				work_time += 3 SECONDS
			if(!do_after(user, work_time, NONE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != old_girder_state)
				return TRUE
			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			to_chat(user, span_notice("You unsecured the support struts!"))
			change_state(girder_state - 1)
			return TRUE
	return FALSE


/obj/structure/girder/wirecutter_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	switch(girder_state)
		if(GIRDER_BROKEN_PATCHED)
			playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
			to_chat(user, span_notice("Now cutting the metal plate..."))
			if(!do_after(user, 4 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return TRUE
			to_chat(user, span_notice("You finished cutting the metal plate!"))
			deconstruct()
			return TRUE
		if(GIRDER_BUILDING1_WELDED)
			var/old_girder_state = girder_state
			var/work_time = 3 SECONDS
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				work_time += 3 SECONDS
			to_chat(user, span_notice("Now cutting the support struts..."))
			if(!do_after(user, 4 SECONDS, NONE, src, BUSY_ICON_BUILD))
				return
			if(girder_state != old_girder_state)
				return TRUE
			playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
			to_chat(user, span_notice("You've cut the support struts!"))
			change_state(girder_state - 1)
	return FALSE


/obj/structure/girder/proc/build_wall()
	if(!reinforcement)
		reinforcement = GIRDER_REINF_METAL
	var/turf/source_turf = get_turf(src)
	source_turf.PlaceOnTop(reinforcement_to_wall(reinforcement))
	qdel(src)


/obj/structure/girder/proc/reinforcement_to_wall(reinforcement)
	switch(reinforcement)
		if(GIRDER_REINF_METAL)
			return /turf/closed/wall
		if(GIRDER_REINF_PLASTEEL)
			return /turf/closed/wall/r_wall


/obj/structure/girder/examine(mob/user)
	. = ..()
	switch(girder_state)
		if(GIRDER_BROKEN)
			. += "It's broken, but can be mended by applying a metal plate then welding it together. Or scrapped for metal by wrenching it loose."
		if(GIRDER_BROKEN_PATCHED)
			. += "It's broken, but can be mended by welding it. Or scrapped by cutting out the metal plate with a wirecutter."
		if(GIRDER_NORMAL)
			if(anchored)
				. += "To start building the wall, add a two sheets of metal or fifteen of plasteel plate to the girder. To unanchor it, use a crowbar."
			else
				. += "To anchor it, wrench it down. Do disassemble it, use a screwdriver."
		if(GIRDER_BUILDING1_LOOSE)
			. += "To continue building the wall, secure the inner plate layer with a screwdriver. To deconstruct it, pry it off with a crowbar."
		if(GIRDER_BUILDING1_SECURED)
			. += "To continue building the wall, secure the inner plate layer by welding. To deconstruct it, use a screwdriver."
		if(GIRDER_BUILDING1_WELDED)
			. += "To continue building the wall, add [reinforcement == GIRDER_REINF_PLASTEEL ? "fifteen sheets of plasteel" : "two sheets of metal"] plates to the outer plate layer. To deconstruct it, use wirecutters."
		if(GIRDER_BUILDING2_LOOSE)
			. += "To continue building the wall, secure the outer plate layer with a screwdriver. To deconstruct it, pry it off with a crowbar."
		if(GIRDER_BUILDING2_SECURED)
			. += "To finish building the wall, secure the outer plate layer by welding. To begin deconstructing it, use a screwdriver."


/obj/structure/girder/obj_break()
	change_state(GIRDER_BROKEN)


/obj/structure/girder/deconstruct(disassembled = TRUE)
	if(disassembled)
		if(reinforcement)
			new reinforcement(loc)
		else
			new /obj/item/stack/sheet/metal(loc)
	return ..()


/obj/structure/girder/update_icon_state()
	switch(girder_state)
		if(GIRDER_BROKEN, GIRDER_BROKEN_PATCHED)
			icon = 'icons/obj/smooth_objects/girder_broke.dmi'
		if(GIRDER_NORMAL)
			if(!anchored)
				icon_state = "displaced"
				return
			icon = 'icons/obj/smooth_objects/girder.dmi'
		if(GIRDER_BUILDING1_LOOSE, GIRDER_BUILDING1_SECURED, GIRDER_BUILDING1_WELDED, GIRDER_BUILDING2_LOOSE, GIRDER_BUILDING2_SECURED)
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				icon_state = "reinforced"
				return
			icon = 'icons/obj/smooth_objects/girder.dmi'


/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			take_damage(200, BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(25, BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(15, BRUTE, BOMB)


/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = FALSE


/obj/structure/girder/reinforced
	icon_state = "reinforced"
	girder_state = GIRDER_BUILDING1_WELDED
	reinforcement = GIRDER_REINF_PLASTEEL
	max_integrity = 500
