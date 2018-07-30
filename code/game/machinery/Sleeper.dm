/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/sleeper/connected = null
	anchored = 1 //About time someone fixed this.
	density = 0
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"

	use_power = 1
	idle_power_usage = 40

/obj/machinery/sleep_console/process()
	if(stat & (NOPOWER|BROKEN))
		return
	updateUsrDialog()
	return

/obj/machinery/sleep_console/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			cdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				cdel(src)
				return
		else
	return

/obj/machinery/sleep_console/New()
	..()
	spawn( 5 )
		if(orient == "RIGHT")
			icon_state = "sleeperconsole-r"
			connected = locate(/obj/machinery/sleeper, get_step(src, EAST))
			connected.connected = src
		else
			connected = locate(/obj/machinery/sleeper, get_step(src, WEST))
			connected.connected = src
		return
	return

/obj/machinery/sleep_console/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/sleep_console/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/sleep_console/attack_hand(mob/user as mob)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return
	var/dat = ""
	if (!src.connected || (connected.stat & (NOPOWER|BROKEN)))
		dat += "This console is not connected to a sleeper or the sleeper is non-functional."
	else
		var/mob/living/occupant = src.connected.occupant
		dat += "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
		if (occupant)
			var/t1
			switch(occupant.stat)
				if(0)
					t1 = "Conscious"
				if(1)
					t1 = "<font color='blue'>Unconscious</font>"
				if(2)
					t1 = "<font color='red'>*dead*</font>"
				else
			dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
			if(iscarbon(occupant))
				var/mob/living/carbon/C = occupant
				dat += text("[]\t-Pulse, bpm: []</FONT><BR>", (C.pulse == PULSE_NONE || C.pulse == PULSE_THREADY ? "<font color='red'>" : "<font color='blue'>"), C.get_pulse(GETPULSE_TOOL))
			dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
			dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
			dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
			dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())
			dat += text("<HR>Knocked Out Summary %: [] ([] seconds left!)<BR>", occupant.knocked_out, round(occupant.knocked_out / 4))
			if(occupant.reagents)
				for(var/chemical in connected.available_chemicals)
					dat += "[connected.available_chemicals[chemical]]: [occupant.reagents.get_reagent_amount(chemical)] units<br>"
			dat += "<A href='?src=\ref[src];refresh=1'>Refresh Meter Readings</A><BR>"
			if(connected.beaker)
				dat += "<HR><A href='?src=\ref[src];removebeaker=1'>Remove Beaker</A><BR>"
				if(ishuman(occupant))
					if(src.connected.filtering)
						dat += "<A href='?src=\ref[src];togglefilter=1'>Stop Dialysis</A><BR>"
						dat += "Output Beaker has [connected.beaker.reagents.maximum_volume - connected.beaker.reagents.total_volume] units of free space remaining<BR><HR>"
					else
						dat += "<HR><A href='?src=\ref[src];togglefilter=1'>Start Dialysis</A><BR>"
						dat += "Output Beaker has [connected.beaker.reagents.maximum_volume - connected.beaker.reagents.total_volume] units of free space remaining<BR><HR>"
				else
					dat += "<HR>Dialysis Disabled - Non-human present.<BR><HR>"

			else
				dat += "<HR>No Dialysis Output Beaker is present.<BR><HR>"

			for(var/chemical in connected.available_chemicals)
				dat += "Inject [connected.available_chemicals[chemical]]: "
				for(var/amount in connected.amounts)
					dat += "<a href ='?src=\ref[src];chemical=[chemical];amount=[amount]'>[amount] units</a><br> "


			dat += "<HR><A href='?src=\ref[src];ejectify=1'>Eject Patient</A>"
		else
			dat += "The sleeper is empty."
	dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)
	user << browse(dat, "window=sleeper;size=400x500")
	onclose(user, "sleeper")
	return

/obj/machinery/sleep_console/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.set_interaction(src)
		if (href_list["chemical"])
			if (src.connected)
				if (src.connected.occupant)
					if (src.connected.occupant.stat == DEAD)
						usr << "\red \b This person has no life for to preserve anymore. Take them to a department capable of reanimating them."
					else if(src.connected.occupant.health > 0 || href_list["chemical"] == "inaprovaline")
						src.connected.inject_chemical(usr,href_list["chemical"],text2num(href_list["amount"]))
					else
						usr << "\red \b This person is not in good enough condition for sleepers to be effective! Use another means of treatment, such as cryogenics!"
					src.updateUsrDialog()
		if (href_list["refresh"])
			src.updateUsrDialog()
		if (href_list["removebeaker"])
			src.connected.remove_beaker()
			src.updateUsrDialog()
		if (href_list["togglefilter"])
			src.connected.toggle_filter()
			src.updateUsrDialog()
		if (href_list["ejectify"])
			src.connected.eject()
			src.updateUsrDialog()
		src.add_fingerprint(usr)
	return









/////////////////////////////////////////
// THE SLEEPER ITSELF
/////////////////////////////////////////

/obj/machinery/sleeper
	name = "Sleeper"
	desc = "A fancy bed with built-in injectors, a dialysis machine, and a limited health scanner."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1
	var/orient = "LEFT" // "RIGHT" changes the dir suffix to "-r"
	var/mob/living/carbon/human/occupant = null
	var/available_chemicals = list("inaprovaline" = "Inaprovaline", "stoxin" = "Soporific", "paracetamol" = "Paracetamol", "anti_toxin" = "Dylovene", "dexalin" = "Dexalin", "tricordrazine" = "Tricordrazine")
	var/amounts = list(5, 10)
	var/obj/item/reagent_container/glass/beaker = null
	var/filtering = 0
	var/obj/machinery/sleep_console/connected

	use_power = 1
	idle_power_usage = 15
	active_power_usage = 200 //builtin health analyzer, dialysis machine, injectors.


/obj/machinery/sleeper/New()
	..()
	beaker = new /obj/item/reagent_container/glass/beaker/large()
	spawn( 5 )
		if(orient == "RIGHT")
			icon_state = "sleeper_0-r"
		return
	return


/obj/machinery/sleeper/allow_drop()
	return 0


/obj/machinery/sleeper/on_stored_atom_del(atom/movable/AM)
	if(AM == beaker)
		beaker = null

/obj/machinery/sleeper/process()
	if (stat & (NOPOWER|BROKEN))
		return

	if(filtering > 0)
		if(beaker)
			if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
				for(var/datum/reagent/x in src.occupant.reagents.reagent_list)
					src.occupant.reagents.trans_to(beaker, 3)


	src.updateUsrDialog()


/obj/machinery/sleeper/attackby(var/obj/item/W, var/mob/living/user)
	if(istype(W, /obj/item/reagent_container/glass))
		if(!beaker)
			if(user.drop_inv_item_to_loc(W, src))
				beaker = W
				user.visible_message("[user] adds \a [W] to \the [src]!", "You add \a [W] to \the [src]!")
				updateUsrDialog()
			return
		else
			user << "\red The sleeper has a beaker already."
			return

	else if(istype(W, /obj/item/grab))
		if(isXeno(user)) return
		var/obj/item/grab/G = W
		if(!ismob(G.grabbed_thing))
			return

		if(src.occupant)
			user << "\blue <B>The sleeper is already occupied!</B>"
			return

		visible_message("[user] starts putting [G.grabbed_thing] into the sleeper.", 3)

		if(do_after(user, 20, TRUE, 5, BUSY_ICON_GENERIC))
			if(src.occupant)
				user << "\blue <B>The sleeper is already occupied!</B>"
				return
			if(!G || !G.grabbed_thing) return
			var/mob/M = G.grabbed_thing
			M.forceMove(src)
			update_use_power(2)
			src.occupant = M
			start_processing()
			connected.start_processing()
			src.icon_state = "sleeper_1"
			if(orient == "RIGHT")
				icon_state = "sleeper_1-r"

			src.add_fingerprint(user)



/obj/machinery/sleeper/ex_act(severity)
	if(filtering)
		toggle_filter()
	switch(severity)
		if(1)
			cdel(src)
		if(2)
			if(prob(50))
				cdel(src)
		if(3)
			if(prob(25))
				cdel(src)


/obj/machinery/sleeper/emp_act(severity)
	if(filtering)
		toggle_filter()
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		go_out()
	..()

/obj/machinery/sleeper/alter_health(mob/living/M)
	if (M.health > 0)
		if (M.getOxyLoss() >= 10)
			var/amount = max(0.15, 1)
			M.adjustOxyLoss(-amount)
		else
			M.adjustOxyLoss(-12)
		M.updatehealth()
	M.AdjustKnockedout(-4)
	M.AdjustKnockeddown(-4)
	M.AdjustStunned(-4)
	M.KnockOut(1)
	M.KnockDown(1)
	M.Stun(1)
	if (M:reagents.get_reagent_amount("inaprovaline") < 5)
		M:reagents.add_reagent("inaprovaline", 5)


/obj/machinery/sleeper/proc/toggle_filter()
	if(!src.occupant)
		filtering = 0
		return
	if(filtering)
		filtering = 0
	else
		filtering = 1

/obj/machinery/sleeper/proc/go_out()
	if(filtering)
		toggle_filter()
	if(!src.occupant)
		return
	if(src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	stop_processing()
	connected.stop_processing()
	update_use_power(1)
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
	return


/obj/machinery/sleeper/proc/inject_chemical(mob/living/user as mob, chemical, amount)
	if(src.occupant && src.occupant.reagents)
		if(src.occupant.reagents.get_reagent_amount(chemical) + amount <= 20)
			src.occupant.reagents.add_reagent(chemical, amount)
			user << "Occupant now has [src.occupant.reagents.get_reagent_amount(chemical)] units of [available_chemicals[chemical]] in his/her bloodstream."
			return
	user << "There's no occupant in the sleeper or the subject has too many chemicals!"
	return


/obj/machinery/sleeper/proc/check(mob/living/user as mob)
	if(occupant)
		user << text("\blue <B>Occupant ([]) Statistics:</B>", src.occupant)
		var/t1
		switch(occupant.stat)
			if(0)
				t1 = "Conscious"
			if(1)
				t1 = "Unconscious"
			if(2)
				t1 = "*dead*"
			else
		user << text("[]\t Health %: [] ([])", (src.occupant.health > 50 ? "\blue " : "\red "), src.occupant.health, t1)
		user << text("[]\t -Core Temperature: []&deg;C ([]&deg;F)</FONT><BR>", (src.occupant.bodytemperature > 50 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.bodytemperature-T0C, src.occupant.bodytemperature*1.8-459.67)
		user << text("[]\t -Brute Damage %: []", (src.occupant.getBruteLoss() < 60 ? "\blue " : "\red "), src.occupant.getBruteLoss())
		user << text("[]\t -Respiratory Damage %: []", (src.occupant.getOxyLoss() < 60 ? "\blue " : "\red "), src.occupant.getOxyLoss())
		user << text("[]\t -Toxin Content %: []", (src.occupant.getToxLoss() < 60 ? "\blue " : "\red "), src.occupant.getToxLoss())
		user << text("[]\t -Burn Severity %: []", (src.occupant.getFireLoss() < 60 ? "\blue " : "\red "), src.occupant.getFireLoss())
		user << "\blue Expected time till occupant can safely awake: (note: If health is below 20% these times are inaccurate)"
		user << "\blue \t [occupant.knocked_out / 5] second\s (if around 1 or 2 the sleeper is keeping them asleep.)"
		if(beaker)
			user << "\blue \t Dialysis Output Beaker has [beaker.reagents.maximum_volume - beaker.reagents.total_volume] of free space remaining."
		else
			user << "\blue No Dialysis Output Beaker loaded."
	else
		user << "\blue There is no one inside!"
	return


/obj/machinery/sleeper/verb/eject()
	set name = "Eject Sleeper"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(orient == "RIGHT")
		icon_state = "sleeper_0-r"
	src.icon_state = "sleeper_0"
	src.go_out()
	add_fingerprint(usr)


/obj/machinery/sleeper/verb/remove_beaker()
	set name = "Remove Beaker"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return
	if(beaker)
		filtering = 0
		beaker.loc = usr.loc
		beaker = null
	add_fingerprint(usr)


/obj/machinery/sleeper/verb/move_inside()
	set name = "Enter Sleeper"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !(ishuman(usr) || ismonkey(usr)))
		return

	if(src.occupant)
		usr << "\blue <B>The sleeper is already occupied!</B>"
		return

	visible_message("[usr] starts climbing into the sleeper.", 3)
	if(usr.pulledby)
		if(ismob(usr.pulledby))
			var/mob/grabmob = usr.pulledby
			grabmob.stop_pulling()
	if(do_after(usr, 20, FALSE, 5, BUSY_ICON_GENERIC))
		if(src.occupant)
			usr << "\blue <B>The sleeper is already occupied!</B>"
			return
		usr.stop_pulling()
		if(usr.pulledby)
			if(ismob(usr.pulledby))
				var/mob/grabmob = usr.pulledby
				grabmob.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		update_use_power(2)
		src.occupant = usr
		start_processing()
		connected.start_processing()
		src.icon_state = "sleeper_1"
		if(orient == "RIGHT")
			icon_state = "sleeper_1-r"

		for(var/obj/O in src)
			cdel(O)
		src.add_fingerprint(usr)
