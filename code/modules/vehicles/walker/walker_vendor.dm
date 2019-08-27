/obj/machinery/mech_vendor
	name = "ColMarTech Automated Mech Vendor"
	desc = "This vendor is connected to main ship storage, allows to fetch one hardpoint module per category for free."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "engi"
	density = TRUE

	var/list/vendor_role = list(WALKER_PILOT) //everyone else, mind your business
	var/return_timer = 30 MINUTES


	var/list/aval_tank_mod = list("weapon" = 2, "ammo" = 7, "armor" = 1, "misc" = 0)

	var/list/listed_products = list(
							list("WEAPONS (choose 2)", null, null, "misc", null),
							list("M56 Double-Barrel Mounted Smartgun", 1, /obj/item/walker_hardpoint/gun/smartgun, "weapon", "orange"),
							list("M30 Machine Gun", 1, /obj/item/walker_hardpoint/gun/hmg, "weapon", "black"),
							list("F40 \"Hellfire\" Flamethower", 1, /obj/item/walker_hardpoint/gun/flamer, "weapon", "black"),
							list("AMMUNITION", null, null, "misc", null),
							list("M56 Magazine", 1, /obj/item/ammo_magazine/walker/smartgun, "ammo", "black"),
							list("M30 Magazine", 2, /obj/item/ammo_magazine/walker/hmg, "ammo", "black"),
							list("F40 Canister", 2, /obj/item/ammo_magazine/walker/flamer, "ammo", "black"),
							list("ARMOR", null, null, "misc", null),
							list("Heavy Armor", 1, /obj/item/walker_hardpoint/armor/light, "armor", "black"),
							list("Light Armor", 1, /obj/item/walker_hardpoint/armor/heavy, "armor", "black"),
							list("Hazmat Armor", 1, /obj/item/walker_hardpoint/armor/acid, "armor", "black"),
						)

/obj/machinery/mech_vendor/attack_hand(mob/user)

	if(..())
		return

	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return

	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return

	if(!vendor_role.Find(I.rank))
		to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
		return

	user.set_interaction(src)
	ui_interact(user)

/obj/machinery/mech_vendor/attackby(obj/item/W, mob/user)
	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user
	var/obj/item/card/id/I = H.wear_id
	if(!istype(I)) //not wearing an ID
		to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
		return

	if(I.registered_name != H.real_name)
		to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
		return

	if(!vendor_role.Find(I.rank))
		to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
		return

	if(world.time > return_timer)
		to_chat(H, "<span class='warning'>Operation has begun, you can't swap modules anymore.</span>")
		return

	if(istype(W, /obj/item/walker_hardpoint/gun))
		if(aval_tank_mod["weapon"] >= 2)
			to_chat(H, "<span class='warning'>Can't accept this. Nothing was taken from this category.</span>")
			return
		aval_tank_mod["weapon"] += 1
		user.temporarilyRemoveItemFromInventory(W, 0)
		to_chat(user, "<span class='notice'>With a clank you insert the [W.name] into the vendor.</span>")
		qdel(W)
		return

	if(istype(W, /obj/item/ammo_magazine/walker))
		if(aval_tank_mod["ammo"] >= 5)
			to_chat(H, "<span class='warning'>Can't accept this. Nothing was taken from this category.</span>")
			return
		if(istype(W, /obj/item/ammo_magazine/walker/smartgun))
			aval_tank_mod["ammo"] += 1
		else
			aval_tank_mod["ammo"] += 2
		user.temporarilyRemoveItemFromInventory(W, 0)
		to_chat(user, "<span class='notice'>With a clank you insert the [W.name] into the vendor.</span>")
		qdel(W)
		return

	to_chat(user, "<span class='warning'>This is not walker hardpoint module or its ammo.</span>")
	return

/obj/machinery/mech_vendor/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)

	if(!ishuman(user)) return

	var/list/display_list = list()

	for(var/i in 1 to listed_products.len)
		var/list/myprod = listed_products[i]
		var/p_name = myprod[1]
		var/p_weight = myprod[2]
		if(p_weight > 0)
			p_name += " ([p_weight] RW)"

		var/prod_available = FALSE
		if(aval_tank_mod[myprod[4]] >= p_weight)
			prod_available = TRUE

								//place in main list, name with Relative Weight, available or not, color.
		display_list += list(list("prod_index" = i, "prod_name" = p_name, "prod_available" = prod_available, "prod_color" = myprod[5]))


	var/list/data = list(
		"vendor_name" = name,
		"displayed_records" = display_list,
	)

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "mech_vendor.tmpl", name , 600, 700)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/mech_vendor/Topic(href, href_list)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(usr.incapacitated())
		return

	if (in_range(src, usr) && isturf(loc) && ishuman(usr))
		usr.set_interaction(src)
		if (href_list["vend"])

			var/idx=text2num(href_list["vend"])

			var/list/L = listed_products[idx]
			var/mob/living/carbon/human/H = usr

			var/obj/item/card/id/I = H.wear_id
			if(!istype(I)) //not wearing an ID
				to_chat(H, "<span class='warning'>Access denied. No ID card detected</span>")
				return

			if(I.registered_name != H.real_name)
				to_chat(H, "<span class='warning'>Wrong ID card owner detected.</span>")
				return

			if(!vendor_role.Find(I.rank))
				to_chat(H, "<span class='warning'>This machine isn't for you.</span>")
				return

			if(aval_tank_mod[L[4]] >= L[2])
				aval_tank_mod[L[4]] -= L[2]
				var/type_p = L[3]
				var/obj/item/IT = new type_p(loc)
				IT.add_fingerprint(usr)
				H.update_action_buttons()
			else
				to_chat(H, "<span class='warning'>Not enough points in this category remain.</span>")
				return
		src.add_fingerprint(usr)
		ui_interact(usr) //updates the nanoUI window