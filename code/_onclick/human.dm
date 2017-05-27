
/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/


/mob/living/carbon/human

	ClickOn(var/atom/A, params)
		if(machine && machine.flags_atom == RELAY_CLICK) //Fix works, should just normally allow you click on world objects, at worst a second click. Also no longer spams runtime errors.
			machine.handle_click(machine.operator, A, params)
			return
		else
			..()

	var/last_chew = 0
	RestrainedClickOn(var/atom/A) //chewing your handcuffs
		if (A != src) return ..()
		var/mob/living/carbon/human/H = A

		if (last_chew + 75 > world.time)
			H << "\red You can't bite your hand again yet..."
			return


		if (!H.handcuffed) return
		if (H.a_intent != "hurt") return
		if (H.zone_selected != "mouth") return
		if (H.wear_mask) return
		if (istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket)) return

		var/datum/organ/external/O = H.organs_by_name[H.hand?"l_hand":"r_hand"]
		if (!O) return

		var/s = "\red [H.name] chews on \his [O.display_name]!"
		H.visible_message(s, "\red You chew on your [O.display_name]!")
		H.attack_log += text("\[[time_stamp()]\] <font color='red'>[s] ([H.ckey])</font>")
		log_attack("[s] ([H.ckey])")

		if(O.take_damage(1,0,1,1,"teeth marks"))
			H.UpdateDamageIcon()

		last_chew = world.time

	UnarmedAttack(var/atom/A, var/proximity)
		var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines

		// Special glove functions:
		// If the gloves do anything, have them return 1 to stop
		// normal attack_hand() here.
		if(proximity && istype(G) && G.Touch(A,1))
			return

		A.attack_hand(src)

	RangedAttack(var/atom/A)
		if(!gloves && !mutations.len) return
		var/obj/item/clothing/gloves/G = gloves
		if((LASER in mutations) && a_intent == "hurt")
			LaserEyes(A) // moved into a proc below

		else if(istype(G) && G.Touch(A,0)) // for magic gloves
			return

		else if(TK in mutations)
			switch(get_dist(src,A))
				if(1 to 5) // not adjacent may mean blocked by window
					next_move += 2
				if(5 to 7)
					next_move += 5
				if(8 to 15)
					next_move += 10
				if(16 to 128)
					return
			A.attack_tk(src)

// This was also the next define. Didn't know if you wanted this in setup or not.
//Made it a /obj/ thing so it can be used for more things.
/obj/proc/handle_click(var/mob/living/carbon/human/user, var/atom/A, var/params) //Heres our handle click relay proc thing.
	return

/atom/proc/attack_hand(mob/user as mob)
	return
