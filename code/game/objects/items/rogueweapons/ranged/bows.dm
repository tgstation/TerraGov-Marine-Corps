
/obj/item/gun/ballistic/revolver/grenadelauncher/bow
	name = "bow"
	desc = ""
	icon = 'icons/roguetown/weapons/32.dmi'
	icon_state = "bow"
	item_state = "bow"
	possible_item_intents = list(/datum/intent/shoot/bow, /datum/intent/arc/bow,INTENT_GENERIC)
	mag_type = /obj/item/ammo_box/magazine/internal/shot/bow
	fire_sound = 'sound/combat/Ranged/flatbow-shot-01.ogg'
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_BULKY
	randomspread = 0
	spread = 0
	can_parry = TRUE
	pin = /obj/item/firing_pin
	force = 10
	verbage = "nock"
	cartridge_wording = "arrow"
	load_sound = 'sound/foley/nockarrow.ogg'
	associated_skill = /datum/skill/combat/bows

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.7,"sx" = -3,"sy" = 0,"nx" = 6,"ny" = 1,"wx" = -1,"wy" = 1,"ex" = -2,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 9,"sturn" = -100,"wturn" = -102,"eturn" = 10,"nflip" = 1,"sflip" = 8,"wflip" = 8,"eflip" = 1)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
			if("onback")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)


/obj/item/gun/ballistic/revolver/grenadelauncher/bow/shoot_with_empty_chamber()
	return

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/dropped()
	..()
	if(chambered)
		chambered = null
		var/num_unloaded = 0
		for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
			CB.forceMove(drop_location())
//			CB.bounce_away(FALSE, NONE)
			num_unloaded++
		if (num_unloaded)
			update_icon()

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(user.get_num_arms(FALSE) < 2)
		return FALSE
	if(user.get_inactive_held_item())
		return FALSE
	if(user.client)
		if(user.client.chargedprog >= 100)
			spread = 0
		else
			spread = 150 - (150 * (user.client.chargedprog / 100))
	else
		spread = 0
	for(var/obj/item/ammo_casing/CB in get_ammo_list(FALSE, TRUE))
		var/obj/projectile/BB = CB.BB
		if(user.client.chargedprog < 100)
			BB.damage = BB.damage - (BB.damage * (user.client.chargedprog / 100))
			BB.embedchance = 5
		else
			BB.damage = BB.damage
			BB.embedchance = 100
		BB.damage = BB.damage * (user.STAPER / 10)
	..()

/obj/item/gun/ballistic/revolver/grenadelauncher/bow/update_icon()
	. = ..()
	cut_overlays()
	if(chambered)
		var/obj/item/I = chambered
		I.pixel_x = 0
		I.pixel_y = 0
		add_overlay(new /mutable_appearance(I))
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()

/obj/item/ammo_box/magazine/internal/shot/bow
	ammo_type = /obj/item/ammo_casing/caseless/rogue/arrow
	caliber = "arrow"
	max_ammo = 1
	start_empty = TRUE

/datum/intent/shoot/bow
	chargetime = 1
	chargedrain = 2
	charging_slowdown = 3

/datum/intent/shoot/bow/can_charge()
	if(mastermob)
		if(mastermob.get_num_arms(FALSE) < 2)
			return FALSE
		if(mastermob.get_inactive_held_item())
			return FALSE
	return TRUE

/datum/intent/shoot/bow/prewarning()
	if(mastermob)
		mastermob.visible_message("<span class='warning'>[mastermob] draws [masteritem]!</span>")
		playsound(mastermob, pick('sound/combat/Ranged/bow-draw-01.ogg'), 100, FALSE)

/datum/intent/shoot/bow/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = 0
		//skill block
		newtime = newtime + 10
		newtime = newtime - (mastermob.mind.get_skill_level(/datum/skill/combat/bows) * (10/6))
		//str block //rtd replace 10 with drawdiff on bows that are hard and scale str more (10/20 = 0.5)
		newtime = newtime + 10
		newtime = newtime - (mastermob.STASTR * (10/20))
		//per block
		newtime = newtime + 20
		newtime = newtime - (mastermob.STAPER * 1) //20/20 is 1
		if(newtime > 0)
			return newtime
		else
			return 0.1
	return chargetime

/datum/intent/arc/bow
	chargetime = 1
	chargedrain = 2
	charging_slowdown = 3

/datum/intent/arc/bow/can_charge()
	if(mastermob)
		if(mastermob.get_num_arms(FALSE) < 2)
			return FALSE
		if(mastermob.get_inactive_held_item())
			return FALSE
	return TRUE

/datum/intent/arc/bow/prewarning()
	if(mastermob)
		mastermob.visible_message("<span class='warning'>[mastermob] draws [masteritem]!</span>")
		playsound(mastermob, pick('sound/combat/Ranged/bow-draw-01.ogg'), 100, FALSE)

/datum/intent/arc/bow/get_chargetime()
	if(mastermob && chargetime)
		var/newtime = 0
		//skill block
		newtime = newtime + 10
		newtime = newtime - (mastermob.mind.get_skill_level(/datum/skill/combat/bows) * (10/6))
		//str block //rtd replace 10 with drawdiff on bows that are hard and scale str more (10/20 = 0.5)
		newtime = newtime + 10
		newtime = newtime - (mastermob.STASTR * (10/20))
		//per block
		newtime = newtime + 20
		newtime = newtime - (mastermob.STAPER * 1) //20/20 is 1
		if(newtime > 0)
			return newtime
		else
			return 1
	return chargetime