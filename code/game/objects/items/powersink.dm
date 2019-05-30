// Powersink - used to drain station power

/obj/item/powersink
	desc = "A nulling power sink which drains energy from electrical systems."
	name = "power sink"
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = 4.0
	flags_atom = CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2

	matter = list("metal" = 750,"waste" = 750)

	origin_tech = "powerstorage=3;syndicate=5"
	var/drain_rate = 600000		// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 1e8		// maximum power that can be drained before exploding
	var/mode = 0		// 0 = off, 1=clamped (off), 2=operating


	var/obj/structure/cable/attached		// the attached cable

	attackby(var/obj/item/I, var/mob/user)
		if(isscrewdriver(I))
			if(mode == 0)
				var/turf/T = loc
				if(isturf(T) && !T.intact_tile)
					attached = locate() in T
					if(!attached)
						to_chat(user, "No exposed cable here to attach to.")
						return
					else
						anchored = 1
						mode = 1
						user.visible_message("[user] attaches the power sink to the cable.", "You attach the device to the cable.")
						return
				else
					to_chat(user, "Device must be placed over an exposed cable to attach to it.")
					return
			else
				if (mode == 2)
					STOP_PROCESSING(SSobj, src) // Now the power sink actually stops draining the station's power if you unhook it. --NeoFite
				anchored = 0
				mode = 0
				user.visible_message("[user] detaches the power sink from the cable.", "You detach the device from the cable.")
				SetLuminosity(0)
				icon_state = "powersink0"

				return
		else
			..()



	attack_paw()
		return

	attack_ai()
		return

	attack_hand(var/mob/user)
		switch(mode)
			if(0)
				..()

			if(1)
				user.visible_message("[user] activates the power sink!", "You activate the device!")
				mode = 2
				icon_state = "powersink1"
				START_PROCESSING(SSobj, src)

			if(2)  //This switch option wasn't originally included. It exists now. --NeoFite
				user.visible_message("[user] deactivates the power sink!", "You deactivate the device!")
				mode = 1
				SetLuminosity(0)
				icon_state = "powersink0"
				STOP_PROCESSING(SSobj, src)

	process()
		if(attached)
			var/datum/powernet/PN = attached.powernet
			if(PN)
				SetLuminosity(12)

				// found a powernet, so drain up to max power from it

				var/drained = min ( drain_rate, PN.avail )
				attached.add_delayedload(drained)
				power_drained += drained

				// if tried to drain more than available on powernet
				// now look for APCs and drain their cells
				if(drained < drain_rate)
					for(var/obj/machinery/power/terminal/T in PN.nodes)
						if(istype(T.master, /obj/machinery/power/apc))
							var/obj/machinery/power/apc/A = T.master
							if(A.operating && A.cell)
								A.cell.charge = max(0, A.cell.charge - 50)
								power_drained += 50


			if(power_drained > max_power * 0.95)
				playsound(src, 'sound/effects/screech.ogg', 75, 1, 20)
			if(power_drained >= max_power)
				STOP_PROCESSING(SSobj, src)
				explosion(src.loc, 3,6,9,12)
				qdel(src)
