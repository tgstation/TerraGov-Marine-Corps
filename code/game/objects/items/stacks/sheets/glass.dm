/* Glass stack types
* Contains:
*		Glass sheets
*		Reinforced glass sheets
*		Phoron Glass Sheets
*		Reinforced Phoron Glass Sheets (AKA Holy fuck strong windows)
*		Glass shards - TODO: Move this into code/game/object/item/weapons
*/

/*
* Glass sheets
*/
/obj/item/stack/sheet/glass
	name = "glass"
	desc = "Glass is a non-crystalline solid, made out of silicate, the primary constituent of sand. It is valued for its transparency, albeit it is not too resistant to damage."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	matter = list("glass" = 3750)
	origin_tech = "materials=1"
	merge_type = /obj/item/stack/sheet/glass

	var/created_window = /obj/structure/window
	var/reinforced_type = /obj/item/stack/sheet/glass/reinforced
	var/is_reinforced = 0
	var/list/construction_options = list("One Direction", "Full Window")

/obj/item/stack/sheet/glass/cyborg
	matter = null

/obj/item/stack/sheet/glass/attack_self(mob/user)
	construct_window(user)

/obj/item/stack/sheet/glass/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(is_reinforced)
		return

	if(istype(I, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = I

		if(get_amount() < 1 || CC.get_amount() < 5)
			to_chat(user, "<span class='warning'>You need five lengths of coil and one sheet of glass to make wired glass.</span>")
			return

		CC.use(5)
		new /obj/item/stack/light_w(user.loc, 1)
		use(1)
		to_chat(user, "<span class='notice'>You attach wire to the [name].</span>")

	else if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/V  = I
		if(V.get_amount() < 1 || get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one rod and one sheet of glass to make reinforced glass.</span>")
			return

		var/obj/item/stack/sheet/glass/RG = new reinforced_type(user.loc)
		RG.add_to_stacks(user)
		use(1)
		V.use(1)
		if(!src && !RG)
			user.put_in_hands(RG)


/obj/item/stack/sheet/glass/proc/construct_window(mob/user)
	if(!user || !src)	return 0
	if(!istype(user.loc,/turf)) return 0
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0
	if(ishuman(user) && user.mind && user.mind.cm_skills && user.mind.cm_skills.construction < SKILL_CONSTRUCTION_PLASTEEL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to build with [src].</span>",
		"<span class='notice'>You fumble around figuring out how to build with [src].</span>")
		var/fumbling_time = 100 - 20 * user.mind.cm_skills.construction
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_UNSKILLED))
			return
	var/title = "Sheet-[name]"
	title += " ([src.amount] sheet\s left)"
	switch(input(title, "What would you like to construct?") as null|anything in construction_options)
		if("One Direction")
			if(!src)	return 1
			if(src.loc != user)	return 1

			var/list/directions = new/list(GLOB.cardinals)
			var/i = 0
			for (var/obj/structure/window/win in user.loc)
				i++
				if(i >= 4)
					to_chat(user, "<span class='warning'>There are too many windows in this location.</span>")
					return 1
				directions-=win.dir
				if(!(win.dir in GLOB.cardinals))
					to_chat(user, "<span class='warning'>Can't let you do that.</span>")
					return 1

			//Determine the direction. It will first check in the direction the person making the window is facing, if it finds an already made window it will try looking at the next cardinal direction, etc.
			var/dir_to_set = 2
			for(var/direction in list( user.dir, turn(user.dir,90), turn(user.dir,180), turn(user.dir,270) ))
				var/found = 0
				for(var/obj/structure/window/WT in user.loc)
					if(WT.dir == direction)
						found = 1
				if(!found)
					dir_to_set = direction
					break
			new created_window( user.loc, dir_to_set, 1 )
			src.use(1)
		if("Full Window")
			if(!src)	return 1
			if(src.loc != user)	return 1
			if(src.amount < 4)
				to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
				return 1
			if(locate(/obj/structure/window) in user.loc)
				to_chat(user, "<span class='warning'>There is a window in the way.</span>")
				return 1
			new created_window( user.loc, SOUTHWEST, 1 )
			src.use(4)
		if("Windoor")
			if(!is_reinforced) return 1

			if(!src || src.loc != user) return 1

			if(isturf(user.loc) && locate(/obj/structure/windoor_assembly/, user.loc))
				to_chat(user, "<span class='warning'>There is already a windoor assembly in that location.</span>")
				return 1

			if(isturf(user.loc) && locate(/obj/machinery/door/window/, user.loc))
				to_chat(user, "<span class='warning'>There is already a windoor in that location.</span>")
				return 1

			if(src.amount < 5)
				to_chat(user, "<span class='warning'>You need more glass to do that.</span>")
				return 1

			new /obj/structure/windoor_assembly(user.loc, user.dir, 1)
			src.use(5)

	return 0


/obj/item/stack/sheet/glass/large_stack
	amount = 50


/*
* Reinforced glass sheets
*/
/obj/item/stack/sheet/glass/reinforced
	name = "reinforced glass"
	desc = "Reinforced glass is made out of squares of regular silicate glass layered on a metallic rod matrice. This glass is more resistant to direct impacts, even if it may crack."
	singular_name = "reinforced glass sheet"
	icon_state = "sheet-rglass"


	matter = list("metal" = 1875,"glass" = 3750)
	origin_tech = "materials=2"

	created_window = /obj/structure/window/reinforced
	is_reinforced = 1
	construction_options = list("One Direction", "Full Window", "Windoor")

/obj/item/stack/sheet/glass/reinforced/cyborg
	matter = null

/*
* Phoron Glass sheets
*/
/obj/item/stack/sheet/glass/phoronglass
	name = "phoron glass"
	desc = "Phoron glass is a silicate-phoron alloy turned into a non-crystalline solid. It is transparent just like glass, even if visibly tainted pink, and very resistant to damage and heat."
	singular_name = "phoron glass sheet"
	icon_state = "sheet-phoronglass"
	matter = list("glass" = 7500)
	origin_tech = "materials=3;phorontech=2"
	created_window = /obj/structure/window/phoronbasic
	reinforced_type = /obj/item/stack/sheet/glass/phoronrglass

/*
* Reinforced phoron glass sheets
*/
/obj/item/stack/sheet/glass/phoronrglass
	name = "reinforced phoron glass"
	desc = "Reinforced phoron glass is made out of squares of silicate-phoron alloy glass layered on a metallic rod matrice. It is insanely resistant to both physical shock and heat."
	singular_name = "reinforced phoron glass sheet"
	icon_state = "sheet-phoronrglass"
	matter = list("glass" = 7500,"metal" = 1875)

	origin_tech = "materials=4;phorontech=2"
	created_window = /obj/structure/window/phoronreinforced
	is_reinforced = 1
