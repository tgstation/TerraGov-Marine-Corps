/obj/item/weapon/melee/defibrillator
	name = "emergency defibrillator"
	desc = "A handheld emergency defibrillator, used to bring people back from the brink of death or put them there."
	icon_state = "defib_full"
	item_state = "defib"
	flags = FPRINT | TABLEPASS
	slot_flags = SLOT_BELT
	force = 5
	throwforce = 5
	w_class = 3
	var/emagged = 1 //Because defibs that only save people are boring.  Let's have it start dangerous.  Everything should be a potential weapon.
	var/status = 0
	var/graceperiod = 400
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread
	var/charge_cost = 100 //How much energy is used.
	var/obj/item/weapon/cell/dcell = null
	origin_tech = "biotech=3"

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is putting the live paddles on \his chest! It looks like \he's trying to commit suicide.</b>"
		return (OXYLOSS)

	proc/toolate(mob/living/carbon/human/M as mob)
		if(world.time <= M.timeofdeath + graceperiod)
			return 1
		else
			return 0

/obj/item/weapon/melee/defibrillator/New()
	dcell = new/obj/item/weapon/cell(src)
	update_icon()

/obj/item/weapon/melee/defibrillator/update_icon()
	if(dcell)
		if(dcell.charge)
			if(!status)
				switch(round(dcell.charge * 100 / dcell.maxcharge))
					if(66 to INFINITY)
						icon_state = "defib_full"
					if(36 to 65)
						icon_state = "defib_half"
					if(1 to 35)
						icon_state = "defib_low"
			else
				switch(round(dcell.charge * 100 / dcell.maxcharge))
					if(66 to INFINITY)
						icon_state = "defibpaddleout_full"
					if(36 to 65)
						icon_state = "defibpaddleout_half"
					if(1 to 35)
						icon_state = "defibpaddleout_low"
		else
			icon_state = "defib_empty"
	else
		icon_state = "defib_empty"

/obj/item/weapon/melee/defibrillator/attack_self(mob/user as mob)
/*	if(status && (M_CLUMSY in user.mutations) && prob(50))
		spark_system.attach(user)
		spark_system.set_up(5, 0, src)
		spark_system.start()
		user << "\red You touch the paddles together shorting the device."
		user.Weaken(5)
		charges--
		if(charges < 1)
			status = 0
			update_icon()
		return*/
	if(dcell.charge >= charge_cost)
		status = !status
		user << "<span class='notice'>\The [src] is now [status ? "on" : "off"].</span>"
		playsound(get_turf(src), "sparks", 75, 1, -1)
		update_icon()
	else
		status = 0
		user << "<span class='warning'>\The [src] is out of charge.</span>"
	add_fingerprint(user)

/obj/item/weapon/melee/defibrillator/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/card/emag))
		var/image/I = image("icon" = "icons/obj/weapons.dmi", "icon_state" = "defib_emag")
		if(emagged == 0)
			emagged = 1
			usr << "\red [W] unlocks [src]'s safety protocols"
			overlays += I
		else
			emagged = 0
			usr << "\blue [W] sets [src]'s safety protocols"
			overlays -= I

/obj/item/weapon/melee/defibrillator/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	var/mob/living/carbon/human/H = M
	if(!ishuman(M))
		..()
		return
	if(status)
		if(user.a_intent == "hurt" && emagged)
			H.visible_message("<span class='danger'>[M.name] has been touched by the defibrillator paddles by [user]!</span>")
			if(dcell.charge >= charge_cost*2)
				H.Weaken(10)
				H.adjustOxyLoss(10)
				H.apply_damage(10, BURN, "chest")
			else
				H.Weaken(5)
				H.adjustOxyLoss(5)
				H.apply_damage(5, BURN, "chest")
			H.updatehealth() //forces health update before next life tick
			spark_system.attach(M)
			spark_system.set_up(5, 0, M)
			spark_system.start()
			dcell.use(charge_cost*2)
			if(!dcell.charge)
				status = 0
			update_icon()
			playsound(get_turf(src), 'sound/weapons/Egloves.ogg', 50, 1, -1)
			user.attack_log += "\[[time_stamp()]\]<font color='red'> Defibrillated [H.name] ([H.ckey]) with [src.name]</font>"
			H.attack_log += "\[[time_stamp()]\]<font color='orange'> Defibrillated by [user.name] ([user.ckey]) with [src.name]</font>"
			log_attack("<font color='red'>[user.name] ([user.ckey]) defibrillated [H.name] ([H.ckey]) with [src.name]</font>" )
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user
			return
		H.visible_message("\blue [user] places the defibrillator paddles on [M.name]'s chest.", "\blue You place the defibrillator paddles on [M.name]'s chest.")
		if(do_after(user, 10))
			if((H.stat == 2 || H.stat == DEAD) && H.chestburst == 0)
				var/uni = 0
				var/armor = 0
				//We want to heal these
				var/brute = H.getBruteLoss()
				var/burn = H.getFireLoss()
				var/oxygen = H.getOxyLoss()
				var/toxin = H.getToxLoss()

				for(var/obj/item/carried_item in H.contents)
					if(istype(carried_item, /obj/item/clothing/under))
						uni = 1
					if(istype(carried_item, /obj/item/clothing/suit/armor))
						armor = 1
				if(uni && armor && toolate(M))
					if(prob(30))
						spark_system.attach(M)
						spark_system.start()
					if(prob(25))
						if(oxygen)
							H.adjustOxyLoss(-8)
						else if(toxin)
							H.adjustToxLoss(-8)
						else if(brute)
							H.adjustBruteLoss(-8)
						else if(burn)
							H.adjustFireLoss(-8)
				else if((uni || armor) && toolate(M))
					if(prob(30))
						spark_system.attach(M)
						spark_system.start()
					if(prob(40))
						if(oxygen)
							H.adjustOxyLoss(-8)
						else if(toxin)
							H.adjustToxLoss(-8)
						else if(brute)
							H.adjustBruteLoss(-8)
						else if(burn)
							H.adjustFireLoss(-8)
				else
					if(toolate(M))
						if(oxygen)
							H.adjustOxyLoss(-8)
						else if(toxin)
							H.adjustToxLoss(-8)
						else if(brute)
							H.adjustBruteLoss(-8)
						else if(burn)
							H.adjustFireLoss(-8)
				H.updatehealth() //forces a health update
				M.visible_message("\red [M]'s body convulses a bit.")
				playsound(get_turf(src), 'sound/weapons/Egloves.ogg', 50, 1, -1)
				var/datum/organ/external/temp = H.get_organ("head")
				if(H.health > -100 && !(temp.status & ORGAN_DESTROYED) && !H.suiciding && toolate(M)) //!(M_NOCLONE in H.mutations) && We don't have this.
					viewers(M) << "\blue \icon[src] beeps: Resuscitation successful."
					spawn(0)
						H.stat = 1
						dead_mob_list -= H
						living_mob_list += H
						H.emote("gasp")
						H.hud_updateflag |= 1 << HEALTH_HUD
						H.hud_updateflag |= 1 << STATUS_HUD
						H.tod = null
						H.timeofdeath = 0
				else
					viewers(M) << "\red \icon[src] beeps: Resuscitation failed."
				dcell.use(charge_cost)
				if(dcell.charge < charge_cost)
					dcell.charge = 0
					status = 0
				update_icon()
			else
				user.visible_message("\red \icon[src] beeps: Patient is not in a valid state.")