/obj/structure/barricade/handrail
	name = "handrail"
	desc = "A railing, for your hands. Woooow."
	icon = 'icons/obj/structures/handrail.dmi'
	icon_state = "handrail_a_0"
	barricade_type = "handrail"
	stack_type = /obj/item/stack/sheet/metal
	stack_amount = 2
	destroyed_stack_amount = 1
	can_wire = FALSE
	coverage = 10
	var/build_state = BARRICADE_BSTATE_SECURED
	var/reinforced = FALSE //Reinforced to be a cade or not
	var/can_be_reinforced = TRUE //can we even reinforce this handrail or not?

/obj/structure/barricade/handrail/update_icon()
	overlays.Cut()
	switch(dir)
		if(SOUTH)
			layer = ABOVE_MOB_LAYER
		if(NORTH)
			layer = initial(layer) - 0.01
		else
			layer = initial(layer)
	if(!anchored)
		layer = initial(layer)
	if(build_state == BARRICADE_BSTATE_FORTIFIED)
		if(reinforced)
			overlays += image('icons/obj/structures/handrail.dmi', icon_state = "[barricade_type]_reinforced_[damage_state]")
		else
			overlays += image('icons/obj/structures/handrail.dmi', icon_state = "[barricade_type]_welder_step")

	for(var/datum/effects/E in effects_list)
		if(E.icon_path && E.obj_icon_state_path)
			overlays += image(E.icon_path, icon_state = E.obj_icon_state_path)

/obj/structure/barricade/handrail/get_examine_text(mob/user)
	. = ..()
	switch(build_state)
		if(BARRICADE_BSTATE_SECURED)
			. += span_info("The [barricade_type] is safely secured to the ground.")
		if(BARRICADE_BSTATE_UNSECURED)
			. += span_info("The bolts nailing it to the ground has been unsecured.")
		if(BARRICADE_BSTATE_FORTIFIED)
			if(reinforced)
				. += span_info("The [barricade_type] has been reinforced with metal.")
			else
				. += span_info("Metal has been laid across the [barricade_type]. Weld it to secure it.")

/obj/structure/barricade/handrail/proc/reinforce()
	if(reinforced)
		if(obj_integrity == max_integrity) // Drop metal if full hp when unreinforcing
			new /obj/item/stack/sheet/metal(loc)
		obj_integrity = initial(obj_integrity)
		max_integrity = initial(max_integrity)
		coverage = initial(coverage)
	else
		obj_integrity = 350
		max_integrity = 350
		coverage = 30
	reinforced = !reinforced
	update_icon()

/obj/structure/barricade/handrail/attackby(obj/item/item, mob/user)
	for(var/obj/effect/xenomorph/acid/A in src.loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	switch(build_state)
		if(BARRICADE_BSTATE_SECURED) //Non-reinforced. Wrench to unsecure. Screwdriver to disassemble into metal. 1 metal to reinforce.
			if(HAS_TRAIT(item, TRAIT_TOOL_WRENCH)) // Make unsecure
				if(user.action_busy)
					return
				if(!skillcheck(user, SKILL_CONSTRUCTION, SKILL_CONSTRUCTION_TRAINED))
					to_chat(user, SPAN_WARNING("You are not trained to unsecure [src]..."))
					return
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(!do_after(user, 10 SECONDS, NONE, src, BUSY_ICON_BUILD))
					return
				user.visible_message(span_notice("[user] loosens [src]'s anchor bolts."),
				span_notice("You loosen [src]'s anchor bolts."))
				anchored = FALSE
				build_state = BARRICADE_BSTATE_UNSECURED
				update_icon()
				return
			if(istype(item, /obj/item/stack/sheet/metal)) // Start reinforcing
				if(!can_be_reinforced)
					return
				if(user.action_busy)
					return
				if(!skillcheck(user, SKILL_CONSTRUCTION, SKILL_CONSTRUCTION_TRAINED))
					to_chat(user, SPAN_WARNING("You are not trained to reinforce [src]..."))
					return
				var/obj/item/stack/sheet/metal/M = item
				playsound(src.loc, 'sound/items/Screwdriver2.ogg', 25, 1)
				if(M.amount >= 1 && do_after(user, 30, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD)) //Shouldnt be possible, but doesnt hurt to check
					if(!M.use(1))
						return
					build_state = BARRICADE_BSTATE_FORTIFIED
					update_icon()
				else
					to_chat(user, SPAN_WARNING("You need at least one metal sheet to do this."))
				return

		if(BARRICADE_BSTATE_UNSECURED)
			if(HAS_TRAIT(item, TRAIT_TOOL_WRENCH)) // Secure again
				if(user.action_busy)
					return
				if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_METAL)
					var/fumbling_time = 1 SECONDS * ( SKILL_ENGINEER_PLASTEEL - user.skills.getRating(SKILL_ENGINEER) )
					if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
						return
				playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(!do_after(user, 10, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src)) return
				user.visible_message(span_notice("[user] tightens [src]'s anchor bolts."),
				span_notice("You tighten [src]'s anchor bolts."))
				anchored = TRUE
				build_state = BARRICADE_BSTATE_SECURED
				update_icon()
				return
			if(HAS_TRAIT(item, TRAIT_TOOL_SCREWDRIVER)) // Disassemble into metal
				if(user.action_busy)
					return
				if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_METAL)
					var/fumbling_time = 1 SECONDS * ( SKILL_ENGINEER_PLASTEEL - user.skills.getRating(SKILL_ENGINEER) )
					if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
						return
				user.visible_message(span_notice("[user] starts unscrewing [src]'s panels."),
				span_notice("You remove [src]'s panels and start taking it apart."))
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
				if(!do_after(user, 10, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src)) return
				user.visible_message(span_notice("[user] takes apart [src]."),
				span_notice("You take apart [src]."))
				playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
				deconstruct(TRUE)
				return

		if(BARRICADE_BSTATE_FORTIFIED)
			if(reinforced)
				if(HAS_TRAIT(item, TRAIT_TOOL_CROWBAR)) // Un-reinforce
					if(user.action_busy)
						return
					if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_METAL)
						var/fumbling_time = 1 SECONDS * ( SKILL_ENGINEER_PLASTEEL - user.skills.getRating(SKILL_ENGINEER) )
						if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
							return
					playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
					if(!do_after(user, 10 SECONDS, NONE, src, BUSY_ICON_BUILD))
						return
					user.visible_message(span_notice("[user] pries off [src]'s extra metal panel."),
					span_notice("You pry off [src]'s extra metal panel."))
					build_state = BARRICADE_BSTATE_SECURED
					reinforce()
					return
			else
				if(iswelder(item)) // Finish reinforcing
					if(user.skills.getRating(SKILL_ENGINEER) < SKILL_ENGINEER_METAL)
						var/fumbling_time = 1 SECONDS * ( SKILL_ENGINEER_PLASTEEL - user.skills.getRating(SKILL_ENGINEER) )
						if(!do_after(user, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
							return
					playsound(src.loc, 'sound/items/Welder.ogg', 25, 1)
					if(!do_after(user, 10, INTERRUPT_ALL|BEHAVIOR_IMMOBILE, BUSY_ICON_BUILD, src)) return
					user.visible_message(span_notice("[user] secures [src]'s metal panel."),
					span_notice("You secure [src]'s metal panel."))
					reinforce()
					return
	. = ..()

/obj/structure/barricade/handrail/type_b
	icon_state = "handrail_b_0"

/obj/structure/barricade/handrail/strata
	icon_state = "handrail_strata"

/obj/structure/barricade/handrail/medical
	icon_state = "handrail_med"

/obj/structure/barricade/handrail/kutjevo
	icon_state = "hr_kutjevo"

/obj/structure/barricade/handrail/wire
	icon_state = "wire_rail"

/obj/structure/barricade/handrail/sandstone
	name = "sandstone handrail"
	icon_state = "hr_sandstone"
	can_be_reinforced = FALSE
	stack_type = /obj/item/stack/sheet/mineral/sandstone

/obj/structure/barricade/handrail/sandstone/b
	icon_state = "hr_sandstone_b"

/obj/structure/barricade/handrail/pizza
	name = "\improper diner half-wall"
	icon_state = "hr_sandstone" //temp, getting sprites soontm
	color = "#b51c0b"
	can_be_reinforced = FALSE
	layer = MOB_LAYER + 0.01
