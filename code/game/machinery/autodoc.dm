//New Update not only for this whiskey outpost but the jungle one as well.
//Autodoc
/obj/machinery/autodoc
	name = "\improper Autodoc Medical System"
	desc = "A fancy machine developed to be capable of operating on people with minimal human intervention. The interface is rather complex and would only be useful to trained Doctors however."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1
	var/mob/living/carbon/human/occupant = null
	var/surgery_t = 0 //Surgery timer in seconds.
	var/surgery = 0 //Are we operating or no? 0 for no, 1 for yes
	var/surgery_mod = 1 //What multiple to increase the surgery timer? This is used for any non-WO maps or events that are done.

	//It uses power
	use_power = 1
	idle_power_usage = 15
	active_power_usage = 450 //Capable of doing various activities

	allow_drop()
		return 0

	process()
		updateUsrDialog()
		return

	proc/scan_occupant(mob/living/carbon/M as mob)
		surgery_t = 0
		if(M.stat == 2)
			visible_message("[src] buzzes.")
			go_out() // If dead, eject them from the start.
			return
		if(M.health <= -160)
			visible_message("[src] flashes <span class='notice'>'UNOPERABLE:CRITICAL HEALTH'</span>") //make sure the docs heal them a bit than just throw them near dead.
			go_out() //Eject them for immediate treatment.
			return
		visible_message("[src] scans the occupant.")
		var/internal_t_dam = 0 //Making these guys a bit more seperate because its a bit easier to track.
		var/implants_t_dam = 0
		var/broken_t_dam = 0
		for(var/datum/internal_organ/I in M.internal_organs)
			internal_t_dam += (I.damage * 5) // This makes massive internal organ damage be more severe to repair. 20*5 = 100, 1:40 min to repair.
		for(var/datum/limb/O in src.occupant.limbs)
			for(var/obj/S in O.implants)
				if(istype(S))
					implants_t_dam += 20 // 20 seconds per shrapnel piece stuck inside.
			if(O.status & LIMB_BROKEN)
				broken_t_dam += 30 //30 seconds per broken bone should be better.
		if(M.getOxyLoss() > 50) //Make sure they don't DIE in here, also starts assisted breathing instantly.
			M.setOxyLoss(rand(0,25)) //Set it to 25 to not ded.
			visible_message("[src] begins assisted breathing support.")

		//Now how to balance out the damages done. 2 seconds per brute damage, 3 seconds per burn damage. 4 for toxins (filter them out), 2 for oxy-loss.
		surgery_t += (M.getBruteLoss() + (M.getFireLoss()*2) + (M.getToxLoss()*4) + (M.getOxyLoss()*2))
		surgery_t += internal_t_dam + implants_t_dam + broken_t_dam
		surgery_t = surgery_t*surgery_mod*10 //Now make it actual seconds.
		if(surgery_t < 1200) surgery_t = 1200
		return


	proc/surgery_op(mob/living/carbon/M as mob)
		if(M.stat == 2)
			visible_message("[src] buzzes.")
			src.go_out() //kick them out too.
			return
		visible_message("[src] begins to operate, loud audiable clicks lock the pod.")
		surgery = 1
		//Give our first boost of healing, mainly so they don't die instantly
		M.setOxyLoss(0) //Fix our breathing issues
		M.heal_limb_damage(25,25)
		sleep(surgery_t * 0.5) //Fix their organs now  so it makes sense halfway through
		if(!occupant) return
		M.setOxyLoss(0) //Fix our breathing issues
		M.heal_limb_damage(25,25)
		for(var/datum/internal_organ/I in M.internal_organs) //Fix the organs
			I.damage = 0
		for(var/datum/limb/O in occupant.limbs) //Remove all the friendly fire.
			if(istype(O, /datum/limb/head))
				var/datum/limb/head/H = O
				if(H.disfigured)	H.disfigured = 0
			for(var/obj/S in O.implants)
				if(istype(S))
					S.loc = src.loc
					O.implants -= S

		sleep(surgery_t * 0.5) // Fully heal them now.
		if(!occupant) return
		M.setOxyLoss(0) //Fix our breathing issues
		M.adjustToxLoss(-70) // Help out with toxins
		M.eye_blurry = 0 //fix our eyes
		M.eye_blind = 0 //fix our eyes
		M.heal_limb_damage(25,25) // I think it caps out at like roughly 25, its really werid.
		M.heal_limb_damage(25,25)
		M.restore_all_organs()
		M.UpdateDamageIcon()
		sleep(5)
		visible_message("The Med-Pod clicks and opens up revealing a healed human")
		go_out()
		icon_state = "sleeper_0"
		surgery = 0
		return

//MSD is a nerd, leaving this here for him to find later.

	verb/eject()
		set name = "Eject Med-Pod"
		set category = "Object"
		set src in oview(1)
		if(surgery) return
		if(usr.stat != 0) return
		go_out()
		add_fingerprint(usr)
		return

	verb/manual_eject()
		set name = "Manual Eject Med-Pod"
		set category = "Object"
		set src in oview(1)
		if(surgery) surgery = 0
		go_out()
		add_fingerprint(usr)
		return

	verb/move_inside()
		set name = "Enter Med-Pod"
		set category = "Object"
		set src in oview(1)

		if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr))) return

		if(occupant)
			usr << "<span class='notice'>The sleeper is already occupied!</span>"
			return

		if(stat & (NOPOWER|BROKEN))
			usr << "<span class='notice'>The Med-Pod is non-functional!</span>"
			return

		visible_message("[usr] starts climbing into the sleeper.", 3)
		if(do_after(usr, 20, FALSE, 5, BUSY_ICON_CLOCK))
			if(occupant)
				usr << "<span class='notice'>The sleeper is already occupied!</span>"
				return
			usr.stop_pulling()
			usr.client.perspective = EYE_PERSPECTIVE
			usr.client.eye = src
			usr.loc = src
			update_use_power(2)
			occupant = usr
			icon_state = "sleeper_1"
			scan_occupant(occupant) // Make it scan them when they get in to set our timer.

			for(var/obj/O in src)
				cdel(O)
			add_fingerprint(usr)
			return
		return

	proc/go_out()
		if(!occupant) return
		occupant.forceMove(loc)
		occupant = null
		update_use_power(1)
		icon_state = "sleeper_0"
		return

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if(istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if(!ismob(G.grabbed_thing))
				return
			var/mob/M = G.grabbed_thing
			if(src.occupant)
				user << "<span class='notice'>The Med-Pod is already occupied!</span>"
				return

			if(stat & (NOPOWER|BROKEN))
				user << "<span class='notice'>The Med-Pod is non-functional!</span>"
				return

			visible_message("[user] starts putting [M] into the Med-Pod.", 3)

			if(do_after(user, 20, FALSE, 5, BUSY_ICON_CLOCK))
				if(src.occupant)
					user << "<span class='notice'>The Med-Pod is already occupied!</span>"
					return
				if(!G || !G.grabbed_thing) return
				M.forceMove(src)
				update_use_power(2)
				occupant = M
				icon_state = "sleeper_1"

				add_fingerprint(user)
				scan_occupant(occupant) // Make it scan them when they get in to set our timer.


/////////////////////////////////////////////////////////////

//Auto Doc console that links up to it.
/obj/machinery/autodoc_console
	name = "Med-Pod Console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/autodoc/connected = null
	anchored = 1 //About time someone fixed this.
	density = 0

	use_power = 1
	idle_power_usage = 40

	New()
		..()
		spawn( 5 )
			connected = locate(/obj/machinery/autodoc, get_step(src, WEST))
			return
		return

	process()
		if(stat & (NOPOWER|BROKEN))
			if(icon_state != "sleeperconsole-p")
				icon_state = "sleeperconsole-p"
			return
		if(icon_state != "sleeperconsole")
			icon_state = "sleeperconsole"
		updateUsrDialog()
		return

	attack_hand(mob/user as mob)
		if(..())
			return
		var/dat = ""
		if (!src.connected || (connected.stat & (NOPOWER|BROKEN)))
			dat += "This console is not connected to a Med-Pod or the Med-Pod is non-functional."
			user << "This console seems to be powered down."
		else
			var/mob/living/occupant = connected.occupant
			dat += "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
			if (occupant)
				var/t1
				switch(occupant.stat)
					if(0)	t1 = "Conscious"
					if(1)	t1 = "<font color='blue'>Unconscious</font>"
					if(2)	t1 = "<font color='red'>*dead*</font>"
				var/operating
				switch(connected.surgery)
					if(0) operating = "Not in surgery"
					if(1) operating = "IN SURGERY: DO NOT MANUALLY EJECT OR PATIENT HARM WILL BE CAUSED"
				dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
				if(iscarbon(occupant))
					var/mob/living/carbon/C = occupant
					dat += text("[]\t-Pulse, bpm: []</FONT><BR>", (C.pulse == PULSE_NONE || C.pulse == PULSE_THREADY ? "<font color='red'>" : "<font color='blue'>"), C.get_pulse(GETPULSE_TOOL))
				dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
				dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
				dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
				dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())
				dat += text("<HR> Surgery Estimate: [] seconds<BR>", (connected.surgery_t * 0.1))
				dat += text("<HR> Med-Pod Status: [] ", operating)
				dat += "<HR><A href='?src=\ref[src];refresh=1'>Refresh Menu</A>"
				dat += "<HR><A href='?src=\ref[src];surgery=1'>Start Surgery</A>"
				dat += "<HR><A href='?src=\ref[src];ejectify=1'>Eject Patient</A>"
			else
				dat += "The Med-Pod is empty."
		dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)
		user << browse(dat, "window=sleeper;size=400x500")
		onclose(user, "sleeper")
		return

	Topic(href, href_list)
		if(..())
			return
		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
			usr.set_interaction(src)
			if (href_list["refresh"])
				updateUsrDialog()
			if (href_list["surgery"])
				connected.surgery_op(src.connected.occupant)
				updateUsrDialog()
			if (href_list["ejectify"])
				connected.eject()
				updateUsrDialog()
			add_fingerprint(usr)
		return
