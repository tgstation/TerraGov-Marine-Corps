
/obj/item/m_gift //Marine Gift
	name = "Present"
	desc = "One, standard issue TGMC Present"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift1"
	item_state = "gift1"

/obj/item/m_gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	if(w_class > 0 && w_class < 4)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"
	return

/obj/item/m_gift/attack_self(mob/M as mob)
	var fancy = rand(1,100) //Check if it has the possibility of being a FANCY present
	var exFancy = rand(1,20) // Checks if it might be one of the ULTRA fancy presents.
	var gift_type = /obj/item/storage/fancy/crayons   //Default, just in case

	if(fancy > 95)
		if(exFancy == 1)
			to_chat(M, "<span class='notice'>It's a brand new, un-restricted, THERMOBARIC ROCKET LAUNCHER!  What are the chances?</span>")
			gift_type = /obj/item/weapon/gun/launcher/rocket/m57a4/XMAS
			var/obj/item/I = new gift_type(M)
			M.temporarilyRemoveItemFromInventory(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			qdel(src)
			return
		else if(exFancy == 10)
			to_chat(M, "<span class='notice'>It's a brand new, un-restricted, ANTI-MATERIAL SNIPER RIFLE!  What are the chances?</span>")
			gift_type = /obj/item/weapon/gun/rifle/sniper/elite/XMAS
			var/obj/item/I = new gift_type(M)
			M.temporarilyRemoveItemFromInventory(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			qdel(src)
			return
		else if(exFancy == 20)
			to_chat(M, "<span class='notice'>Just what the fuck is it?</span>")
			gift_type = /obj/item/clothing/mask/facehugger/lamarr
			var/obj/item/I = new gift_type(M)
			M.temporarilyRemoveItemFromInventory(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			qdel(src)
			return
		else
			gift_type = pick(
			/obj/item/weapon/gun/revolver/mateba,
			/obj/item/weapon/gun/pistol/heavy,
			/obj/item/weapon/claymore,
			/obj/item/weapon/energy/sword/green,
			/obj/item/weapon/energy/sword/red,
			/obj/item/attachable/heavy_barrel,
			/obj/item/attachable/extended_barrel,
			/obj/item/attachable/burstfire_assembly,
			)
			to_chat(M, "<span class='notice'>It's a REAL gift!</span>")
			var/obj/item/I = new gift_type(M)
			M.temporarilyRemoveItemFromInventory(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			qdel(src)
			return
	else if (fancy <=5)
		to_chat(M, "<span class='notice'>It's fucking EMPTY.</span>")
		M.temporarilyRemoveItemFromInventory(src)
		qdel(src)
		return


	gift_type = pick(
		/obj/item/clothing/tie/horrible,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/verticalgrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/rifle,
		/obj/item/attachable/scope)

	if(!ispath(gift_type,/obj/item))	return
	to_chat(M, "<span class='notice'>At least it's something...</span>")
	var/obj/item/I = new gift_type(M)
	M.temporarilyRemoveItemFromInventory(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return

/obj/item/weapon/gun/launcher/rocket/m57a4/XMAS
	flags_gun_features = GUN_INTERNAL_MAG

/obj/item/weapon/gun/launcher/rocket/m57a4/XMAS/able_to_fire(mob/living/user)
	var/turf/current_turf = get_turf(user)
	if (is_mainship_or_low_orbit_level(current_turf.z)) //Can't fire on the Theseus, bub.
		click_empty(user)
		to_chat(user, "<span class='warning'>You can't fire that here!</span>")
		return FALSE
	else
		return TRUE

/obj/item/weapon/gun/rifle/sniper/elite/XMAS
	flags_gun_features = GUN_INTERNAL_MAG

/obj/item/weapon/gun/rifle/sniper/elite/XMAS/able_to_fire(mob/living/user)
	return TRUE