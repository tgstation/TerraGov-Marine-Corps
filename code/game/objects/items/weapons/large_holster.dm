

/obj/item/weapon/large_holster
	name = "\improper Rifle Holster"
	desc = "holster"
	icon = 'icons/obj/storage.dmi'
	w_class = 4
	flags_equip_slot = SLOT_BACK
	var/base_icon = "m37_holster"
	var/drawSound = 'sound/weapons/gun_rifle_draw.ogg'
	var/obj/item/weapon/holstered_weapon
	var/list/accepted_weapon_types = list()


	update_icon()
		var/mob/user = loc
		icon_state = "[base_icon][holstered_weapon?"_full":""]"
		item_state = icon_state
		if(istype(user)) user.update_inv_back()
		if(istype(user)) user.update_inv_s_store()

	attack_hand(mob/user)
		if(loc == user) //holster on the mob
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				var/datum/organ/external/temp
				if (user.hand)
					temp = H.organs_by_name["l_hand"]
				else
					temp = H.organs_by_name["r_hand"]
				if(temp && !temp.is_usable())
					user << "<span class='warning'>You try to move your [temp.display_name], but cannot!</span>"
					return
				if(holstered_weapon)
					holstered_weapon.attack_hand(H)
					if(loc == H) //just to be sure we managed to pick it up
						holstered_weapon = null
						if(drawSound)
							playsound(src,drawSound, 15, 1)
						update_icon()
				else H << "<span class='warning'>[src] is empty.</span>"
		else
			..()

	attackby(obj/item/I, mob/user)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(loc == H && !holstered_weapon)
				for(var/w_type in accepted_weapon_types)
					if(ispath(I.type, w_type))
						user.temp_drop_inv_item(I)
						holstered_weapon = I
						I.forceMove(src)
						if(drawSound)
							playsound(src,drawSound, 15, 1)
						update_icon()
						H << "<span class='notice'>You sheath [I] into [src].</span>"
						return 1

	MouseDrop(obj/over_object)
		if (ishuman(usr))

			if (!istype(over_object, /obj/screen))
				return ..()

			if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
				return

			if (loc == usr) //equipped
				if (!usr.is_mob_restrained() && !usr.stat)
					switch(over_object.name)
						if("r_hand")
							usr.drop_inv_item_on_ground(src)
							usr.put_in_r_hand(src)
						if("l_hand")
							usr.drop_inv_item_on_ground(src)
							usr.put_in_l_hand(src)
					add_fingerprint(usr)


	equipped(mob/user, slot)
		if(ishuman(user) && (slot == WEAR_BACK || slot == WEAR_J_STORE))
			mouse_opacity = 2 //so it's easier to click when properly equipped.
		..()

	dropped(mob/user)
		mouse_opacity = initial(mouse_opacity)
		..()


/obj/item/weapon/large_holster/m37
	name = "\improper L44 M37A2 scabbard"
	desc = "A large leather holster allowing the storage of an M37A2 Shotgun. It contains harnesses that allow it to be secured to the back for easy storage."
	icon_state = "m37_holster"
	item_state = "m37_holster"
	accepted_weapon_types = list(
		/obj/item/weapon/gun/shotgun/pump,
		/obj/item/weapon/gun/shotgun/combat
		)

/obj/item/weapon/large_holster/m37/full/New()
	..()
	icon_state = "m37_holster_full"
	item_state = "m37_holster_full"
	holstered_weapon = new /obj/item/weapon/gun/shotgun/pump(src)

/obj/item/weapon/large_holster/machete
	name = "\improper H5 pattern M2132 machete scabbard"
	desc = "A large leather scabbard used to carry a M2132 machete. It can be strapped to the back or the armor."
	base_icon = "machete_holster"
	icon_state = "machete_holster"
	item_state = "machete_holster"
	accepted_weapon_types = list(/obj/item/weapon/claymore/mercsword/machete)

/obj/item/weapon/large_holster/machete/full/New()
	..()
	icon_state = "machete_holster_full"
	item_state = "machete_holster_full"
	holstered_weapon = new /obj/item/weapon/claymore/mercsword/machete(src)

/obj/item/weapon/large_holster/katana
	name = "\improper katana scabbard"
	desc = "A large, vibrantly colored katana scabbard used to carry a japanese sword. It can be strapped to the back or the armor."
	base_icon = "katana_holster"
	icon_state = "katana_holster"
	item_state = "katana_holster"
	flags_equip_slot = SLOT_WAIST|SLOT_BACK
	accepted_weapon_types = list(/obj/item/weapon/katana)

/obj/item/weapon/large_holster/katana/full/New()
	..()
	icon_state = "katana_holster_full"
	item_state = "katana_holster_full"
	holstered_weapon = new /obj/item/weapon/katana(src)


/obj/item/weapon/large_holster/m39
	name = "\improper M276 pattern M39 holster rig"
	desc = "The M276 is the standard load-bearing equipment of the USCM. It consists of a modular belt with various clips. This version is designed for the M39 SMG, and features a larger frame to support the gun. Due to its unorthodox design, it isn't a very common sight, and is only specially issued."
	icon_state = "m39_holster"
	item_state = "m39_holster"
	icon = 'icons/obj/clothing/belts.dmi'
	base_icon = "m39_holster"
	flags_equip_slot = SLOT_WAIST
	accepted_weapon_types = list(/obj/item/weapon/gun/smg/m39)

	update_icon()
		var/mob/user = loc
		if(holstered_weapon)
			icon_state = "[base_icon]_full_[holstered_weapon.icon_state]"
			item_state = "[base_icon]_full"
		else
			icon_state = base_icon
			item_state = base_icon
		if(istype(user)) user.update_inv_belt()

	equipped(mob/user, slot)
		if(ishuman(user) && slot == WEAR_WAIST)
			mouse_opacity = 2 //so it's easier to click when properly equipped.
		..()

/obj/item/weapon/large_holster/m39/full/New()
	..()
	icon_state = "m39_holster_full_m39"
	item_state = "m39_holster_full"
	holstered_weapon = new /obj/item/weapon/gun/smg/m39(src)
