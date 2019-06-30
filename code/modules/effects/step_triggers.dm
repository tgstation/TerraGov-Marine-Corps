/* Simple object type, calls a proc when "stepped" on by something */

/obj/effect/step_trigger
	var/affect_ghosts = 0
	var/stopper = 1 // stops throwers
	invisibility = INVISIBILITY_MAXIMUM // nope cant see this shit
	anchored = TRUE

/obj/effect/step_trigger/proc/Trigger(atom/movable/A)
	return 0

/obj/effect/step_trigger/Crossed(H as mob|obj)
	..()
	if(!H)
		return
	if(isobserver(H) && !affect_ghosts)
		return
	Trigger(H)



/* Tosses things in a certain direction */

/obj/effect/step_trigger/thrower
	var/direction = SOUTH // the direction of throw
	var/tiles = 3	// if 0: forever until atom hits a stopper
	var/immobilize = 1 // if nonzero: prevents mobs from moving while they're being flung
	var/speed = 1	// delay of movement
	var/facedir = 0 // if 1: atom faces the direction of movement
	var/nostop = 0 // if 1: will only be stopped by teleporters
	var/list/affecting = list()

	Trigger(var/atom/A)
		if(!A || !ismovableatom(A))
			return

		if(!istype(A,/obj) && !istype(A,/mob)) //mobs and objects only.
			return
		if(istype(A,/obj/effect)) return

		var/atom/movable/AM = A
		var/curtiles = 0
		var/stopthrow = 0
		for(var/obj/effect/step_trigger/thrower/T in orange(2, src))
			if(AM in T.affecting)
				return

		if(ismob(AM))
			var/mob/M = AM
			if(immobilize)
				M.canmove = 0

		affecting.Add(AM)
		while(AM && !stopthrow)
			if(tiles)
				if(curtiles >= tiles)
					break
			if(AM.z != src.z)
				break

			curtiles++

			sleep(speed)

			// Calculate if we should stop the process
			if(!nostop)
				for(var/obj/effect/step_trigger/T in get_step(AM, direction))
					if(T.stopper && T != src)
						stopthrow = 1
			else
				for(var/obj/effect/step_trigger/teleporter/T in get_step(AM, direction))
					if(T.stopper)
						stopthrow = 1

			if(AM)
				var/predir = AM.dir
				step(AM, direction)
				if(!facedir)
					AM.setDir(predir)



		affecting.Remove(AM)

		if(ismob(AM))
			var/mob/M = AM
			if(immobilize)
				M.canmove = 1

/* Stops things thrown by a thrower, doesn't do anything */

/obj/effect/step_trigger/stopper

/* Instant teleporter */

/obj/effect/step_trigger/teleporter
	var/teleport_x = 0	// teleportation coordinates (if one is null, then no teleport!)
	var/teleport_y = 0
	var/teleport_z = 0

	Trigger(var/atom/movable/A, teleportation_type)

		set waitfor = 0

		if(!istype(A,/obj) && !istype(A,/mob)) //mobs and objects only.
			return

		if(istype(A,/obj/effect) || A.anchored)
			return

		if(teleport_x && teleport_y && teleport_z)

			switch(teleportation_type)
				if(1)
					sleep(animation_teleport_quick_out(A)) //Sleep for the duration of the animation.
				if(2)
					sleep(animation_teleport_magic_out(A))
				if(3)
					sleep(animation_teleport_spooky_out(A))

			if(A && A.loc)
				A.x = teleport_x
				A.y = teleport_y
				A.z = teleport_z

				switch(teleportation_type)
					if(1)
						animation_teleport_quick_in(A)
					if(2)
						animation_teleport_magic_in(A)
					if(3)
						animation_teleport_spooky_in(A)


/* Random teleporter, teleports atoms to locations ranging from teleport_x - teleport_x_offset, etc */

/obj/effect/step_trigger/teleporter/random
	var/teleport_x_offset = 0
	var/teleport_y_offset = 0
	var/teleport_z_offset = 0

	Trigger(var/atom/movable/A)
		if(istype(A, /obj)) //mobs and objects only.
			if(istype(A, /obj/effect)) return
			qdel(A)
		else if(isliving(A)) //Hacked it up so it just deletes it
			to_chat(A, "<span class='danger'>You get lost into the depths of space, never to be seen again.</span>")
			qdel(A)

