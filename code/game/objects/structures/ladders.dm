/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "ladder11"
	var/id = null
	var/height = 0							//The 'height' of the ladder. higher numbers are considered physically higher
	var/obj/structure/ladder/down = null	//The ladder below this one
	var/obj/structure/ladder/up = null		//The ladder above this one
	anchored = 1
	unacidable = 1
	layer = LADDER_LAYER
	var/is_watching = 0
	var/obj/machinery/camera/cam
	var/busy = 0 //Ladders are wonderful creatures, only one person can use it at a time

/obj/structure/ladder/New()
	..()
	spawn(8)
		cam = new /obj/machinery/camera(src)
		cam.network = list("LADDER")
		cam.c_tag = name

		for(var/obj/structure/ladder/L in structure_list)
			if(L.id == id)
				if(L.height == (height - 1))
					down = L
					continue
				if(L.height == (height + 1))
					up = L
					continue

			if(up && down)	//If both our connections are filled
				break
		update_icon()

/obj/structure/ladder/Dispose()
	if(down)
		down.up = null
		down = null
	if(up)
		up.down = null
		up = null
	if(cam)
		cdel(cam)
		cam = null
	. = ..()

/obj/structure/ladder/update_icon()
	if(up && down)
		icon_state = "ladder11"

	else if(up)
		icon_state = "ladder10"

	else if(down)
		icon_state = "ladder01"

	else	//wtf make your ladders properly assholes
		icon_state = "ladder00"

/obj/structure/ladder/attack_hand(mob/user)
	if(user.stat || get_dist(user, src) > 1 || user.blinded || user.lying || user.buckled || user.anchored) return
	if(busy)
		user << "<span class='warning'>Someone else is currently using [src].</span>"
		return
	var/ladder_dir_name
	var/obj/structure/ladder/ladder_dest
	if(up && down)
		ladder_dir_name = alert("Go up or down the ladder?", "Ladder", "Up", "Down", "Cancel")
		if(ladder_dir_name == "Cancel")
			return
		ladder_dir_name = lowertext(ladder_dir_name)
		if(ladder_dir_name == "up") ladder_dest = up
		else ladder_dest = down
	else if(up)
		ladder_dir_name = "up"
		ladder_dest = up
	else if(down)
		ladder_dir_name = "down"
		ladder_dest = down
	else return //just in case

	step(user, get_dir(user, src))
	user.visible_message("<span class='notice'>[user] starts climbing [ladder_dir_name] [src].</span>",
	"<span class='notice'>You start climbing [ladder_dir_name] [src].</span>")
	busy = 1
	if(do_after(user, 20, FALSE, 5, BUSY_ICON_GENERIC))
		if(!user.is_mob_incapacitated() && get_dist(user, src) <= 1 && !user.blinded && !user.lying && !user.buckled && !user.anchored)
			//TODO: Using forceMove is desirable here, but this breaks the pull. If you know how to preserve the pull, this would be nice!
			user.loc = ladder_dest.loc //Cannot use forceMove method on pulls! Move manually //Make sure we move before we broadcast the message
			visible_message("<span class='notice'>[user] climbs [ladder_dir_name] [src].</span>") //Hack to give a visible message to the people here without duplicating user message
			user.visible_message("<span class='notice'>[user] climbs [ladder_dir_name] [src].</span>",
			"<span class='notice'>You climb [ladder_dir_name] [src].</span>")
			ladder_dest.add_fingerprint(user)
			if(user.pulling && get_dist(src, user.pulling) <= 2)
				user.pulling.loc = ladder_dest.loc //Cannot use forceMove method on pulls! Move manually
				if(isobj(user.pulling))
					var/obj/O = user.pulling
					if(O.buckled_mob)
						O.buckled_mob.loc = ladder_dest.loc //Cannot use forceMove method on pulls! Move manually
	busy = 0
	add_fingerprint(user)

/obj/structure/ladder/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/ladder/check_eye(mob/user)
	//Are we capable of looking?
	if(user.is_mob_incapacitated() || get_dist(user, src) > 1 || user.blinded || user.lying || !user.client)
		user.unset_interaction()

	//Are ladder cameras ok?
	else if (is_watching == 1)
		if (!down || !down.cam || !down.cam.can_use()) //Camera doesn't work or is gone
			user.unset_interaction()
	else if (is_watching == 2)
		if (!up || !up.cam || !up.cam.can_use()) //Camera doesn't work or is gone
			user.unset_interaction()



/obj/structure/ladder/on_set_interaction(mob/user)
	if (is_watching == 1)
		if (down || down.cam || down.cam.can_use()) //Camera works
			user.reset_view(down.cam)
			return
	else if (is_watching == 2)
		if (up || up.cam || up.cam.can_use())
			user.reset_view(up.cam)
			return

	user.unset_interaction() //No usable cam, we stop interacting right away



/obj/structure/ladder/on_unset_interaction(mob/user)
	..()
	is_watching = 0
	user.reset_view(null)

//Peeking up/down
/obj/structure/ladder/MouseDrop(over_object, src_location, over_location)
	if((over_object == usr && (in_range(src, usr))))
		if(isXenoLarva(usr) || isobserver(usr) || usr.is_mob_incapacitated() || usr.blinded || usr.lying)
			usr << "You can't do that in your current state."
			return
		if(is_watching)
			usr << "Someone's already looking through [src]."
			return
		if(up && down)
			switch( alert("Look up or down the ladder?", "Ladder", "Up", "Down", "Cancel") )
				if("Up")
					usr.visible_message("<span class='notice'>[usr] looks up [src]!</span>",
					"<span class='notice'>You look up [src]!</span>")
					is_watching = 2
					usr.set_interaction(src)

				if("Down")
					usr.visible_message("<span class='notice'>[usr] looks down [src]!</span>",
					"<span class='notice'>You look down [src]!</span>")
					is_watching = 1
					usr.set_interaction(src)

				if("Cancel")
					return

		else if(up)
			usr.visible_message("<span class='notice'>[usr] looks up [src]!</span>",
			"<span class='notice'>You look up [src]!</span>")
			is_watching = 2
			usr.set_interaction(src)


		else if(down)
			usr.visible_message("<span class='notice'>[usr] looks down [src]!</span>",
			"<span class='notice'>You look down [src]!</span>")
			is_watching = 1
			usr.set_interaction(src)

	add_fingerprint(usr)

/obj/structure/ladder/attack_robot(mob/user as mob)
	return attack_hand(user)

/obj/structure/ladder/ex_act(severity)
	return

//Throwing Shiet
/obj/structure/ladder/attackby(obj/item/W, mob/user)
	//Throwing Grenades
	if(istype(W,/obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/G = W
		var/ladder_dir_name
		var/obj/structure/ladder/ladder_dest
		if(up && down)
			ladder_dir_name = alert("Throw up or down?", "Ladder", "Up", "Down", "Cancel")
			if(ladder_dir_name == "Cancel")
				return
			ladder_dir_name = lowertext(ladder_dir_name)
			if(ladder_dir_name == "up") ladder_dest = up
			else ladder_dest = down
		else if(up)
			ladder_dir_name = "up"
			ladder_dest = up
		else if(down)
			ladder_dir_name = "down"
			ladder_dest = down
		else return //just in case

		user.visible_message("<span class='warning'>[user] takes position to throw [G] [ladder_dir_name] [src].</span>",
		"<span class='warning'>You take position to throw [G] [ladder_dir_name] [src].</span>")
		if(do_after(user, 10, TRUE, 5, BUSY_ICON_HOSTILE))
			user.visible_message("<span class='warning'>[user] throws [G] [ladder_dir_name] [src]!</span>",
			"<span class='warning'>You throw [G] [ladder_dir_name] [src]</span>")
			user.drop_held_item()
			G.forceMove(ladder_dest.loc)
			G.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			step_away(G, src, rand(1, 5))
			if(!G.active)
				G.activate(user)

	//Throwing Flares and flashlights
	else if(istype(W,/obj/item/device/flashlight))
		var/obj/item/device/flashlight/F = W
		var/ladder_dir_name
		var/obj/structure/ladder/ladder_dest
		if(up && down)
			ladder_dir_name = alert("Throw up or down?", "Ladder", "Up", "Down", "Cancel")
			if(ladder_dir_name == "Cancel")
				return
			ladder_dir_name = lowertext(ladder_dir_name)
			if(ladder_dir_name == "up") ladder_dest = up
			else ladder_dest = down
		else if(up)
			ladder_dir_name = "up"
			ladder_dest = up
		else if(down)
			ladder_dir_name = "down"
			ladder_dest = down
		else return //just in case

		user.visible_message("<span class='warning'>[user] takes position to throw [F] [ladder_dir_name] [src].</span>",
		"<span class='warning'>You take position to throw [F] [ladder_dir_name] [src].</span>")
		if(do_after(user, 10, TRUE, 5, BUSY_ICON_HOSTILE))
			user.visible_message("<span class='warning'>[user] throws [F] [ladder_dir_name] [src]!</span>",
			"<span class='warning'>You throw [F] [ladder_dir_name] [src]</span>")
			user.drop_held_item()
			F.forceMove(ladder_dest.loc)
			F.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			step_away(F,src,rand(1, 5))
	else
		return attack_hand(user)
