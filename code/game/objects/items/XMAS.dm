
/obj/item/m_gift //Marine Gift
	name = "Present"
	desc = "One, standard issue USCM Present"
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
			M << "\blue It's a brand new, un-restricted, THERMOBARIC ROCKET LAUNCHER!!!!!!  What are the chances???"
			gift_type = /obj/item/weapon/gun/launcher/rocket/m57a4/XMAS
			var/obj/item/I = new gift_type(M)
			M.temp_drop_inv_item(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			cdel(src)
			return
		else if(exFancy == 10)
			M << "\blue It's a brand new, un-restricted, ANTI-MATERIAL SNIPER RIFLE!!!!!!  What are the chances???"
			gift_type = /obj/item/weapon/gun/rifle/sniper/elite/XMAS
			var/obj/item/I = new gift_type(M)
			M.temp_drop_inv_item(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			cdel(src)
			return
		else if(exFancy == 20)
			M << "\blue Just what the fuck is it???"
			gift_type = /obj/item/clothing/mask/facehugger/lamarr
			var/obj/item/I = new gift_type(M)
			M.temp_drop_inv_item(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			cdel(src)
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
			M << "\blue It's a REAL gift!!!"
			var/obj/item/I = new gift_type(M)
			M.temp_drop_inv_item(src)
			M.put_in_hands(I)
			I.add_fingerprint(M)
			cdel(src)
			return
	else if (fancy <=5)
		M << "\blue It's fucking EMPTY.  Man, Fuck CM."
		M.temp_drop_inv_item(src)
		cdel(src)
		return


	gift_type = pick(
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/belt/champion,
		/obj/item/tool/soap/deluxe,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/contraband/poster,
		/obj/item/toy/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/weapon/banhammer,
		/obj/item/toy/crossbow,
		/obj/item/toy/gun,
		/obj/item/toy/katana,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/toy/spinningtoy,
		/obj/item/clothing/tie/horrible,
		/obj/item/attachable/suppressor,
		/obj/item/attachable/bayonet,
		/obj/item/attachable/reddot,
		/obj/item/attachable/foregrip,
		/obj/item/attachable/flashlight,
		/obj/item/attachable/bipod,
		/obj/item/attachable/quickfire,
		/obj/item/attachable/magnetic_harness,
		/obj/item/attachable/stock/rifle,
		/obj/item/attachable/scope)

	if(!ispath(gift_type,/obj/item))	return
	M << "\blue At least it's something..."
	var/obj/item/I = new gift_type(M)
	M.temp_drop_inv_item(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	cdel(src)
	return








/obj/item/weapon/gun/launcher/rocket/m57a4/XMAS
	..()
	flags_gun_features = GUN_INTERNAL_MAG
	able_to_fire(mob/living/user)
		var/turf/current_turf = get_turf(user)
		if (current_turf.z == 3 || current_turf.z == 4) //Can't fire on the Almayer, bub.
			click_empty(user)
			user << "<span class='warning'>You can't fire that here!</span>"
			return 0
		else
			return 1

/obj/item/weapon/gun/rifle/sniper/elite/XMAS
	..()
	flags_gun_features = GUN_INTERNAL_MAG

	able_to_fire(mob/living/user)
		return 1