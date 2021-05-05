/obj/structure/girder
	name = "girder"
	icon_state = "girder"
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


#define GIRDER_DECONSTRUCTING (new_state < girder_state)

/obj/structure/girder/proc/change_state(new_state)
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
				to_chat(user, "<span class='notice'>Now adding plating...</span>")
				if(!do_after(user, 4 SECONDS, TRUE, src, BUSY_ICON_BUILD))
					return TRUE
				if(QDELETED(stack) || stack.amount < 2 || girder_state != GIRDER_BROKEN)
					return TRUE
				stack.use(2)
				to_chat(user, "<span class='notice'>You added the metal to the girder!</span>")
				change_state(GIRDER_BROKEN_PATCHED)
				return TRUE
			if(GIRDER_NORMAL)
				var/obj/item/stack/sheet/stack = I
				var/reinforced = istype(I, GIRDER_REINF_PLASTEEL)
				if(stack.amount < (reinforced ? 15 : 2))
					return TRUE
				to_chat(user, "<span class='notice'>Now adding plating...</span>")
				if(!do_after(user, 4 SECONDS * (reinforced ? 2 : 1), TRUE, src, BUSY_ICON_BUILD))
					return TRUE
				if(QDELETED(stack) || stack.amount < (reinforced ? 15 : 2) || girder_state != GIRDER_NORMAL)
					return TRUE
				stack.use(reinforced ? 15 : 2)
				to_chat(user, "<span class='notice'>You added the plating!</span>")
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
				to_chat(user, "<span class='notice'>Now adding plating...</span>")
				if(!do_after(user, 4 SECONDS * (reinforced ? 2 : 1), TRUE, src, BUSY_ICON_BUILD))
					return TRUE
				if(QDELETED(stack) || stack.amount < (reinforced ? 15 : 2) || girder_state != old_girder_state)
					return TRUE
				stack.use(reinforced ? 15 : 2)
				to_chat(user, "<span class='notice'>You added the plating!</span>")
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
			if(!do_after(user, work_time, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != old_girder_state)
				return TRUE
			if(!welder.remove_fuel(1, user))
				return TRUE
			playsound(loc, 'sound/items/welder2.ogg', 25, 1)
			to_chat(user, "<span class='notice'>You weld the [girder_state == GIRDER_BROKEN_PATCHED ? "girder together" : "metal to the girder"]!</span>")
			change_state(girder_state + 1)
			return TRUE
	return FALSE


/obj/structure/girder/wrench_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	switch(girder_state)
		if(GIRDER_BROKEN)
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			to_chat(user, "<span class='notice'>Now unbolting the remaining girder base.</span>")
			if(!do_after(user, 1.5 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != GIRDER_BROKEN)
				return TRUE
			to_chat(user, "<span class='notice'>You scrap what is left from the girder!</span>")
			new /obj/item/stack/sheet/metal(loc)
			qdel(src)
			return TRUE
		if(GIRDER_NORMAL)
			var/turf/T = get_turf(src)
			if(anchored)
				return FALSE
			if(!isfloorturf(T) && !isbasalt(T) && !islavacatwalk(T) && !isopengroundturf(T))
				to_chat(usr, "<span class='warning'>The girder must be secured on the floor!</span>")
				return FALSE
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			to_chat(user, "<span class='notice'>Now securing the girder</span>")
			if(!do_after(user, 4 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			if(anchored || girder_state != GIRDER_NORMAL)
				return TRUE
			to_chat(user, "<span class='notice'>You secured the girder!</span>")
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
			to_chat(user, "<span class='notice'>Now dislodging the girder...</span>")
			if(!do_after(user, 4 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			if(!anchored || girder_state != GIRDER_NORMAL)
				return TRUE
			to_chat(user, "<span class='notice'>You dislodged the girder!</span>")
			anchored = FALSE
			modify_max_integrity(50)
			update_icon()
			return TRUE
		if(GIRDER_BUILDING1_LOOSE, GIRDER_BUILDING2_LOOSE)
			var/old_girder_state = girder_state
			var/work_time = 3 SECONDS
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				work_time += 3 SECONDS
			if(!do_after(user, work_time, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != old_girder_state)
				return TRUE
			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			to_chat(user, "<span class='notice'>You pry the external reinforcement layer out of the girder!</span>")
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
			to_chat(user, "<span class='notice'>Now dissassembling the girder</span>")
			if(!do_after(user, 4 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			if(anchored || girder_state != GIRDER_NORMAL)
				return TRUE
			to_chat(user, "<span class='notice'>You finished dissassembling the girder!</span>")
			new /obj/item/stack/sheet/metal(loc)
			qdel(src)
			return TRUE
		if(GIRDER_BUILDING1_LOOSE, GIRDER_BUILDING2_LOOSE)
			to_chat(user, "<span class='notice'>Now securing support struts</span>")
			var/old_girder_state = girder_state
			var/work_time = 3 SECONDS
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				work_time += 3 SECONDS
			if(!do_after(user, work_time, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != old_girder_state)
				return TRUE
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			to_chat(user, "<span class='notice'>You secured the support struts!</span>")
			change_state(girder_state + 1)
			return TRUE
		if(GIRDER_BUILDING1_SECURED, GIRDER_BUILDING2_SECURED)
			to_chat(user, "<span class='notice'>Now unsecuring support struts</span>")
			var/old_girder_state = girder_state
			var/work_time = 3 SECONDS
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				work_time += 3 SECONDS
			if(!do_after(user, work_time, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != old_girder_state)
				return TRUE
			playsound(loc, 'sound/items/crowbar.ogg', 25, 1)
			to_chat(user, "<span class='notice'>You unsecured the support struts!</span>")
			change_state(girder_state - 1)
			return TRUE
	return FALSE


/obj/structure/girder/wirecutter_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE
	switch(girder_state)
		if(GIRDER_BROKEN_PATCHED)
			playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
			to_chat(user, "<span class='notice'>Now cutting the metal plate...</span>")
			if(!do_after(user, 4 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			to_chat(user, "<span class='notice'>You finished cutting the metal plate!</span>")
			deconstruct()
			return TRUE
		if(GIRDER_BUILDING1_WELDED)
			var/old_girder_state = girder_state
			var/work_time = 3 SECONDS
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				work_time += 3 SECONDS
			to_chat(user, "<span class='notice'>Now cutting the support struts...</span>")
			if(!do_after(user, 4 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return
			if(girder_state != old_girder_state)
				return TRUE
			playsound(loc, 'sound/items/wirecutter.ogg', 25, 1)
			to_chat(user, "<span class='notice'>You've cut the support struts!</span>")
			change_state(girder_state - 1)
	return FALSE


/obj/structure/girder/proc/build_wall()
	if(!reinforcement)
		reinforcement = GIRDER_REINF_METAL
	var/turf/source_turf = get_turf(src)
	source_turf.ChangeTurf(reinforcement_to_wall(reinforcement))
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
			to_chat(user, "It's broken, but can be mended by applying a metal plate then welding it together. Or scrapped for metal by wrenching it loose.")
		if(GIRDER_BROKEN_PATCHED)
			to_chat(user, "It's broken, but can be mended by welding it. Or scrapped by cutting out the metal plate with a wirecutter.")
		if(GIRDER_NORMAL)
			if(anchored)
				to_chat(user, "To start building the wall, add a two sheets of metal or fifteen of plasteel plate to the girder. To unanchor it, use a crowbar.")
			else
				to_chat(user, "To anchor it, wrench it down. Do disassemble it, use a screwdriver.")
		if(GIRDER_BUILDING1_LOOSE)
			to_chat(user, "To continue building the wall, secure the inner plate layer with a screwdriver. To deconstruct it, pry it off with a crowbar.")
		if(GIRDER_BUILDING1_SECURED)
			to_chat(user, "To continue building the wall, secure the inner plate layer by welding. To deconstruct it, use a screwdriver.")
		if(GIRDER_BUILDING1_WELDED)
			to_chat(user, "To continue building the wall, add [reinforcement == GIRDER_REINF_PLASTEEL ? "fifteen sheets of plasteel" : "two sheets of metal"] plates to the outer plate layer. To deconstruct it, use wirecutters.")
		if(GIRDER_BUILDING2_LOOSE)
			to_chat(user, "To continue building the wall, secure the outer plate layer with a screwdriver. To deconstruct it, pry it off with a crowbar.")
		if(GIRDER_BUILDING2_SECURED)
			to_chat(user, "To finish building the wall, secure the outer plate layer by welding. To begin deconstructing it, use a screwdriver.")


/obj/structure/girder/obj_break()
	change_state(GIRDER_BROKEN)


/obj/structure/girder/deconstruct(disassembled = TRUE)
	if(disassembled)
		if(reinforcement)
			new reinforcement(loc)
		else
			new /obj/item/stack/sheet/metal(loc)
	return ..()


/obj/structure/girder/update_icon()
	switch(girder_state)
		if(GIRDER_BROKEN, GIRDER_BROKEN_PATCHED)
			icon_state = "[icon_prefix]_damaged"
		if(GIRDER_NORMAL)
			if(!anchored)
				icon_state = "displaced"
				return
			icon_state = icon_prefix
		if(GIRDER_BUILDING1_LOOSE, GIRDER_BUILDING1_SECURED, GIRDER_BUILDING1_WELDED, GIRDER_BUILDING2_LOOSE, GIRDER_BUILDING2_SECURED)
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				icon_state = "reinforced"
				return
			icon_state = icon_prefix


/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			deconstruct(FALSE)
		if(EXPLODE_HEAVY)
			take_damage(200)
		if(EXPLODE_LIGHT)
			take_damage(25)


/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = FALSE


/obj/structure/girder/reinforced
	icon_state = "reinforced"
	girder_state = GIRDER_BUILDING1_WELDED
	reinforcement = GIRDER_REINF_PLASTEEL
	max_integrity = 500
