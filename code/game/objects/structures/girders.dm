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


/obj/structure/girder/proc/change_state(new_state, update_integrity = TRUE)
	if(new_state == girder_state)
		return
	var/deconstructing = (new_state < girder_state)
	if(update_integrity)
		switch(new_state)
			if(GIRDER_BROKEN)
				if(girder_state != GIRDER_BROKEN_PATCHED)
					modify_max_integrity(50, FALSE)
			if(GIRDER_NORMAL)
				if(!deconstructing)
					modify_max_integrity(150)
			if(GIRDER_BUILDING1_LOOSE)
				if(deconstructing)
					modify_max_integrity(150)
			if(GIRDER_BUILDING1)
				if(!deconstructing)
					modify_max_integrity((reinforcement == GIRDER_REINF_PLASTEEL) ? 300 : 200)
			if(GIRDER_BUILDING2_LOOSE)
				if(deconstructing)
					modify_max_integrity((reinforcement == GIRDER_REINF_PLASTEEL) ? 300 : 200)
			if(GIRDER_BUILDING2)
				if(!deconstructing)
					modify_max_integrity((reinforcement == GIRDER_REINF_PLASTEEL) ? 600 : 300)
			if(GIRDER_WALL_BUILT)
				return build_wall()
	girder_state = new_state
	density = (girder_state >= GIRDER_NORMAL)
	update_icon()



/obj/structure/girder/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, GIRDER_REINF_METAL) || istype(I, GIRDER_REINF_PLASTEEL))
		if(user.action_busy)
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
				if(stack.amount < (reinforced ? 2 : 1))
					return TRUE
				to_chat(user, "<span class='notice'>Now adding plating...</span>")
				if(!do_after(user, 4 SECONDS * (reinforced ? 2 : 1), TRUE, src, BUSY_ICON_BUILD))
					return TRUE
				if(QDELETED(stack) || stack.amount < (reinforced ? 2 : 1) || girder_state != GIRDER_NORMAL)
					return TRUE
				stack.use(reinforced ? 2 : 1)
				to_chat(user, "<span class='notice'>You added the plating!</span>")
				change_state(GIRDER_BUILDING1_LOOSE)
				reinforcement = (reinforced ? GIRDER_REINF_PLASTEEL : GIRDER_REINF_METAL)
				return TRUE
			if(GIRDER_BUILDING1, GIRDER_BUILDING2)
				var/obj/item/stack/sheet/stack = I
				var/reinforced = istype(I, GIRDER_REINF_PLASTEEL)
				if(stack.amount < (reinforced ? 2 : 1))
					return TRUE
				var/old_girder_state = girder_state
				to_chat(user, "<span class='notice'>Now adding plating...</span>")
				if(!do_after(user, 4 SECONDS * (reinforced ? 2 : 1), TRUE, src, BUSY_ICON_BUILD))
					return TRUE
				if(QDELETED(stack) || stack.amount < (reinforced ? 2 : 1) || girder_state != old_girder_state)
					return TRUE
				stack.use(reinforced ? 2 : 1)
				to_chat(user, "<span class='notice'>You added the plating!</span>")
				change_state(girder_state + 1)
				return TRUE
		return FALSE


/obj/structure/girder/welder_act(mob/living/user, obj/item/I)
	if(user.action_busy)
		return FALSE
	var/obj/item/tool/weldingtool/welder = I
	if(!welder.isOn()) 
		return FALSE
	switch(girder_state)
		if(GIRDER_BROKEN_PATCHED, GIRDER_BUILDING1_LOOSE, GIRDER_BUILDING2_LOOSE, GIRDER_BUILDING3_LOOSE)
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
	if(user.action_busy)
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
			if(anchored)
				return FALSE
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			to_chat(user, "<span class='notice'>Now securing the girder</span>")
			if(!do_after(user, 4 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			if(anchored || girder_state != GIRDER_NORMAL)
				return TRUE
			to_chat(user, "<span class='notice'>You secured the girder!</span>")
			anchored = TRUE
			update_icon()
			return TRUE
	return FALSE


/obj/structure/girder/crowbar_act(mob/living/user, obj/item/I)
	if(user.action_busy)
		return FALSE
	switch(girder_state)
		if(GIRDER_BUILDING1, GIRDER_BUILDING2)
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
			change_state(girder_state + 1)
			return TRUE
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
			update_icon()
			return TRUE
	return FALSE


/obj/structure/girder/screwdriver_act(mob/living/user, obj/item/I)
	if(user.action_busy)
		return FALSE
	switch(girder_state)
		if(GIRDER_NORMAL)
			if(anchored)
				return FALSE
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			to_chat(user, "<span class='notice'>Now dissassembling the girder</span>")
			if(!do_after(user, 4 SECONDS, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			to_chat(user, "<span class='notice'>You finished dissassembling the girder!</span>")
			new /obj/item/stack/sheet/metal(loc)
			qdel(src)
			return TRUE
		if(GIRDER_BUILDING1_LOOSE, GIRDER_BUILDING2_LOOSE, GIRDER_BUILDING3_LOOSE)
			playsound(loc, 'sound/items/screwdriver.ogg', 25, 1)
			to_chat(user, "<span class='notice'>Now unsecuring support struts</span>")
			var/old_girder_state = girder_state
			var/work_time = 3 SECONDS
			if(reinforcement == GIRDER_REINF_PLASTEEL)
				work_time += 3 SECONDS
			if(!do_after(user, work_time, TRUE, src, BUSY_ICON_BUILD))
				return TRUE
			if(girder_state != old_girder_state)
				return TRUE
			to_chat(user, "<span class='notice'>You unsecured the support struts!</span>")
			change_state(girder_state - 1)
			new reinforcement(loc)
			if(girder_state == GIRDER_NORMAL)
				reinforcement = null
			return TRUE
		if(GIRDER_BUILDING1, GIRDER_BUILDING2)
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
			change_state(girder_state + 1)
			new reinforcement(loc)
			return TRUE
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
			to_chat(user, "It's broken, but can be mended by welding it. Or scrapped for metal by unscrewing the metal plate.")
		if(GIRDER_NORMAL)
			if(anchored)
				to_chat(user, "To continue building the wall, add a metal or plasteel plate to the girder. To unanchor it, use a crowbar.")
			else
				to_chat(user, "To anchor it, wrench it down. Do disassemble it, use a screwdriver.")
		if(GIRDER_BUILDING1_LOOSE)
			to_chat(user, "To continue building the wall, secure the plates to the wall by welding. This step will have to be repeated twice after to finish it. To deconstruct it, use a screwdriver.")
		if(GIRDER_BUILDING1)
			to_chat(user, "To continue building the wall, add more [(istype(reinforcement, GIRDER_REINF_PLASTEEL)) ? "plasteel" : "metal"] plates to the girder. This step will have to be repeated once after. To deconstruct it, use a crowbar to pry them off.")
		if(GIRDER_BUILDING2_LOOSE)
			to_chat(user, "To continue building the wall, secure the plates to the wall by welding. This step will have to be repeated once after to finish it. To deconstruct it, use a screwdriver.")
		if(GIRDER_BUILDING2)
			to_chat(user, "To continue building the wall, add more [(istype(reinforcement, GIRDER_REINF_PLASTEEL)) ? "plasteel" : "metal"] plates to the girder. To deconstruct it, use a crowbar to pry them off.")
		if(GIRDER_BUILDING3_LOOSE)
			to_chat(user, "To finish building the wall, secure the plates to the wall by welding. To begin deconstructing it, use a screwdriver.")


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
		if(GIRDER_BUILDING1_LOOSE, GIRDER_BUILDING1, GIRDER_BUILDING2_LOOSE, GIRDER_BUILDING2, GIRDER_BUILDING3_LOOSE)
			if(istype(reinforcement, GIRDER_REINF_PLASTEEL))
				icon_state = "reinforced"
				return
			icon_state = icon_prefix


/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1)
			deconstruct(FALSE)
		if(2)
			take_damage(200)
		if(3)
			take_damage(25)


/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = FALSE


/obj/structure/girder/reinforced
	icon_state = "reinforced"
	girder_state = GIRDER_BUILDING2
	reinforcement = GIRDER_REINF_PLASTEEL
	max_integrity = 600
