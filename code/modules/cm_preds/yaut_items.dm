//Items specific to yautja. Other people can use em, they're not restricted or anything.

/obj/item/weapon/twohanded/glaive
	icon = 'icons/Predator/items.dmi'
	icon_state = "glaive"
	item_state = "glaive"
	name = "Yautja glaive"
	desc = "A huge, powerful blade on a metallic pole. Mysterious writing is carved into the weapon."
	force = 24
	w_class = 4.0
	slot_flags = SLOT_BACK
	force_unwielded = 24
	force_wielded = 56
	throwforce = 28
	throw_speed = 2
	edge = 1
	sharp = 1
	flags = NOSHIELD
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")

/obj/item/weapon/twohanded/glaive/update_icon()
	if(wielded)
		item_state = "glaive-wield"
	else
		item_state = "glaive"
	return

/obj/item/clothing/head/helmet/space/yautja
	icon = 'icons/Predator/items.dmi'
	icon_state = "pred_mask1"
	item_state = "helmet"
	icon_override = 'icons/Predator/items.dmi'
	name = "Yautja clan mask"
	desc = "A beautifully designed metallic face mask, both ornate and functional."
	armor = list(melee = 85, bullet = 75, laser = 80,energy = 60, bomb = 75, bio = 100, rad = 100)
	anti_hug = 5
	flags = FPRINT|TABLEPASS
	species_restricted = null
	body_parts_covered = HEAD|FACE
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE

	New()
		spawn(0)
			var/mask = rand(1,3)
			icon_state = "pred_mask[mask]"

/obj/item/clothing/suit/armor/yautja
	name = "Yautja clan armor"
	desc = "A suit of armor with heavy padding. It looks old, yet functional."
	icon = 'icons/Predator/items.dmi'
	icon_state = "predarmor"
	item_state = "armor"
	icon_override = 'icons/Predator/items.dmi'
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	armor = list(melee = 80, bullet = 40, laser = 10, energy = 10, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.2
	slowdown = 0
	allowed = list(/obj/item/weapon/gun,/obj/item/weapon/harpoon, /obj/item/weapon/twohanded/glaive)

/obj/item/weapon/harpoon/yautja
	name = "alien harpoon"
	desc = "A huge metal spike, with a hook at the end. It's carved with mysterious alien writing."
	force = 25
	throwforce = 55
	attack_verb = list("jabbed","stabbed","ripped", "skewered")

/obj/item/weapon/wristblades
	name = "wrist blades"
	desc = "A pair of huge, serrated blades extending from a metal gauntlet."
	icon = 'icons/Predator/items.dmi'
	icon_state = "wrist"
	item_state = "wristblades"
	force = 48
	w_class = 5.0
	edge = 1
	sharp = 1
	flags = NOSHIELD
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("sliced", "slashed", "jabbed", "torn", "gored")
	canremove = 0

	dropped(var/mob/living/carbon/human/mob)
		mob << "The wrist blades retract back into your armband."
		del(src)

/obj/item/clothing/shoes/yautja
	name = "armored boots"
	icon = 'icons/Predator/items.dmi'
	icon_state = "yautja"
	icon_override = 'icons/Predator/items.dmi'
	desc = "A pair of armored, perfectly balanced boots. Perfect for running through the jungle."
//	item_state = "yautja"

	permeability_coefficient = 0.01
	flags = NOSLIP
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0.2
	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null

/obj/item/clothing/under/chainshirt
	name = "chain-mesh shirt"
	icon = 'icons/Predator/items.dmi'
	desc = "A set of very fine chainlink in a meshwork for comfort and utility."
	icon_state = "mesh_shirt"
	icon_override = 'icons/Predator/items.dmi'
	has_sensor = 0
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9
	species_restricted = null

/obj/item/clothing/gloves/yautja
	name = "Yautja bracers"
//	icon = 'icons/Predator/items.dmi'
//	icon_state = "bracers"
	desc = "An extremely complex, yet simple-to-operate set of armored bracers worn by the Yautja. It has many functions, activate them to use some."
	icon_state = "s-ninja"//placeholder
	item_state = "s-ninja"
	species_restricted = null
	icon_action_button = "action_flashlight" //Adds it to the quick-icon list
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	var/charge = 1000
	var/charge_max = 1000
	var/cloaked = 0
	var/selfdestruct = 0
	var/blades_active = 0


	//Should put a cool menu here, like ninjas. Or maybe in the wrist bracers....
	verb/wristblades()
		set name = "Use Wrist Blades"
		set desc = "Extend your wrist blades. They cannot be dropped, but can be retracted."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(M.species && M.species.name != "Yautja")
			usr << "You have no idea how to work these things."
			return

		if(charge < 50)
			usr << "Your wrist bracers are out of power. Let them recharge a bit first."
			return
		var/obj/item/weapon/wristblades/R = usr.r_hand
		var/obj/item/weapon/wristblades/L = usr.l_hand
		if(blades_active) //Turn it off.
			var/found = 0
			if(R && istype(R))
				found = 1
				usr.r_hand = null
				if(R) del(R)
				usr.update_inv_r_hand()
			if(L && istype(L))
				found = 1
				usr.l_hand = null
				if(L) del(L)
				usr.update_inv_l_hand()
			if(found)
				usr << "You retract your wrist blades."
				playsound(src.loc,'sound/weapons/slice.ogg', 20, 1)
				blades_active = 0
				charge -= 50
			return
		else //Turn it on!
			if(usr.get_active_hand())
				usr << "Your hand must be free to activate your wrist blades."
				return
			var/obj/item/weapon/wristblades/W = new(usr)
			usr.put_in_active_hand(W)
			blades_active = 1
			charge -= 50
			usr << "You activate your wrist blades."
			playsound(src,'sound/weapons/slice.ogg', 20, 1)
			usr.update_icons()
		return 1

	verb/cloaker()
		set name = "Toggle Cloaking Device"
		set desc = "Activate your suit's cloaking device. It will malfunction if the suit takes damage or gets excessively wet."
		set category = "Yautja"

		if(!usr || usr.stat) return
		var/mob/living/carbon/human/M = usr
		if(!istype(M)) return
		if(M.species && M.species.name != "Yautja")
			usr << "You have no idea how to work these things."
			return
		if(cloaked) //Turn it off.
			decloak(usr)
		else //Turn it on!
			if(charge < 50)
				usr << "Your wrist bracers are out of power. Let them recharge a bit first."
				return
			charge -= 50
			cloaked = 1
			usr << "\blue You are now invisible to normal detection."
			for(var/mob/O in oviewers(usr))
				O.show_message("[usr.name] vanishes into thin air!",1)
			playsound(usr.loc,'sound/effects/EMPulse.ogg', 50, 1)
			usr.update_icons()
			spawn(1)
				anim(usr.loc,usr,'icons/mob/mob.dmi',,"cloak",,usr.dir)

		return 1

	proc/decloak(var/mob/user)
		if(!user) return
		user << "Your cloaking device deactivates."
		cloaked = 0
		for(var/mob/O in oviewers(user))
			O.show_message("[user.name] wavers into existence!",1)
		playsound(user.loc,'sound/effects/EMPulse.ogg', 50, 1)
		user.update_icons()
		spawn(1)
			if(user)
				anim(user.loc,user,'icons/mob/mob.dmi',,"uncloak",,user.dir)
		return