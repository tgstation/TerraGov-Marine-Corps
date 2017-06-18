/obj/structure/ladder
	name = "ladder"
	desc = "A sturdy metal ladder."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder11"
	var/id = null
	var/height = 0							//the 'height' of the ladder. higher numbers are considered physically higher
	var/obj/structure/ladder/down = null	//the ladder below this one
	var/obj/structure/ladder/up = null		//the ladder above this one
	anchored = 1
	unacidable = 1
	var/is_watching = 0
	var/obj/machinery/camera/cam

/obj/structure/ladder/New()
	spawn(8)
		cam = new /obj/machinery/camera(src)
		cam.network = list("LADDER")
		cam.c_tag = name

		for(var/obj/structure/ladder/L in world)
			if(L.id == id)
				if(L.height == (height - 1))
					down = L
					continue
				if(L.height == (height + 1))
					up = L
					continue

			if(up && down)	//if both our connections are filled
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

/obj/structure/ladder/attack_hand(mob/user as mob)
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

	user.visible_message("<span class='notice'>[user] starts climbing [ladder_dir_name] [src].</span>",
	"<span class='notice'>You start climbing [ladder_dir_name] the ladder.</span>")
	if(do_after(user, 20, FALSE, 5, BUSY_ICON_CLOCK))

		user.loc = get_turf(ladder_dest) //Make sure we move before we broadcast the message
		visible_message("<span class='notice'>[user] climbs [ladder_dir_name] [src].</span>") //Hack to give a visible message to the people here without duplicating user message
		user.visible_message("<span class='notice'>[user] climbs [ladder_dir_name] [src].</span>",
		"<span class='notice'>You climb [ladder_dir_name] [src].</span>")
		ladder_dest.add_fingerprint(user)
		if(user.pulling && get_dist(src, user.pulling) <= 2)
			user.pulling.loc = ladder_dest.loc

	add_fingerprint(user)

/obj/structure/ladder/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/ladder/check_eye(var/mob/user as mob)
	//Are we capable of looking?
	if (is_watching)
		if (user.stat || get_dist(user, src) > 1 || user.blinded || user.lying)
			user.unset_machine()
			is_watching = 0

	//Are ladder cameras ok?
	if (is_watching == 1)
		if (!down || !down.cam || !down.cam.can_use()) //camera doesn't work or is gone
			is_watching = 0
			user.unset_machine()
	else if (is_watching == 2)
		if (!up || !up.cam || !up.cam.can_use()) //camera doesn't work or is gone
			is_watching = 0
			user.unset_machine()

	//Where are we looking? 			//THIS NEEDS TO BE OPTIMISED!
	if(is_watching == 1)					//IT RESETS VIEW EVERY TICK EVEN IF NOT NEEDED
		user.reset_view(down.cam)
	else if(is_watching == 2)
		user.reset_view(up.cam)
	else if (!is_watching)
		user.reset_view(null) //Stop the camera if they move away.
	return 1


//Peeking up/down
/obj/structure/ladder/MouseDrop(over_object, src_location, over_location)
	if((over_object == usr && (in_range(src, usr))))
		if(isXenoLarva(usr) || isobserver(usr) || usr.stat)
			usr << "You can't do that. Just use the ladder."
			return
		if(up && down)
			switch( alert("Look up or down the ladder?", "Ladder", "Up", "Down", "Cancel") )
				if("Up")
					usr.visible_message("<span class='notice'>[usr] looks up \the [src]!</span>", \
										 "<span class='notice'>You look up \the [src]!</span>")
					usr.set_machine(src)
					is_watching = 2
					check_eye(usr)

				if("Down")
					usr.visible_message("<span class='notice'>[usr] looks down \the [src]!</span>", \
										 "<span class='notice'>You look down \the [src]!</span>")
					usr.set_machine(src)
					is_watching = 1
					check_eye(usr)

				if("Cancel")
					return

		else if(up)
			usr.visible_message("<span class='notice'>[usr] looks up \the [src]!</span>", \
								 "<span class='notice'>You look up \the [src]!</span>")
			usr.set_machine(src)
			is_watching = 2
			check_eye(usr)

		else if(down)
			usr.visible_message("<span class='notice'>[usr] looks down \the [src]!</span>", \
								 "<span class='notice'>You look down \the [src]!</span>")
			usr.set_machine(src)
			is_watching = 1
			check_eye(usr)

	add_fingerprint(usr)

/obj/structure/ladder/attack_robot(mob/user as mob)
	return attack_hand(user)

/obj/structure/ladder/ex_act(severity)
	return

//Throwing Shiet
/obj/structure/ladder/attackby(obj/item/weapon/W, mob/user as mob)
	if(W && !isnull(W))
		//Throwing Grenades
		if(istype(W,/obj/item/weapon/grenade))
			var/obj/item/weapon/grenade/G = W
			if(!G.active)
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

				user << "You take the position to throw the [G]."
				if(do_after(user,10, TRUE, 5, BUSY_ICON_CLOCK))
					user.visible_message("<span class='warning'>[user] throws [G] [ladder_dir_name] [src]!</span>", \
										 "<span class='warning'>You throw [G] [ladder_dir_name] [src]</span>")
					user.drop_held_item()
					G.loc = get_turf(ladder_dest)
					G.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
					step_away(G,src,rand(1,5))
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

			user << "You take the position to throw the [F]."
			if(do_after(user,10, TRUE, 5, BUSY_ICON_CLOCK))
				user.visible_message("<span class='warning'>[user] throws [F] [ladder_dir_name] [src]!</span>", \
									 "<span class='warning'>You throw [F] [ladder_dir_name] [src]</span>")
				user.drop_held_item()
				F.loc = get_turf(ladder_dest)
				F.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
				step_away(F,src,rand(1,5))
				F.SetLuminosity(0)
				if(F.on && loc != user)
					F.SetLuminosity(F.brightness_on)
		else
			return attack_hand(user)
	else
		return attack_hand(user)
