/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "smartfridge"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 100
	var/global/max_n_of_items = 999 // Sorry but the BYOND infinite loop detector doesn't look things over 1000.
	var/icon_on = "smartfridge"
	var/icon_off = "smartfridge-off"
	var/icon_panel = "smartfridge-panel"
	var/item_quants = list()
	var/is_secure_fridge = 0
	var/seconds_electrified = 0;
	var/shoot_inventory = 0
	var/locked = 0


/obj/machinery/smartfridge/Initialize()
	. = ..()
	create_reagents(100, NO_REACT)

/obj/machinery/smartfridge/proc/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/reagent_container/food/snacks/grown/) || istype(O,/obj/item/seeds/))
		return 1
	return 0

/obj/machinery/smartfridge/process()
	if(machine_stat & NOPOWER)
		return
	if(src.seconds_electrified > 0)
		src.seconds_electrified--
	if(src.shoot_inventory && prob(2))
		src.throw_item()

/obj/machinery/smartfridge/update_icon()
	if( !(machine_stat & NOPOWER) )
		icon_state = icon_on
	else
		icon_state = icon_off

/*******************
*   Item Adding
********************/

/obj/machinery/smartfridge/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/emag))
		if(!is_secure_fridge || CHECK_BITFIELD(obj_flags, EMAGGED))
			return

		ENABLE_BITFIELD(obj_flags, EMAGGED)
		locked = FALSE
		to_chat(user, "You short out the product lock on [src].")

	else if(isscrewdriver(I))
		TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
		to_chat(user, "You [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "open" : "close"] the maintenance panel.")
		overlays.Cut()
		if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			overlays += image(icon, icon_panel)
		SSnano.update_uis(src)

	else if(ismultitool(I) || iswirecutter(I))
		if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			return
		
		attack_hand(user)

	else if(machine_stat & NOPOWER)
		to_chat(user, "<span class='notice'>\The [src] is unpowered and useless.</span>")
		return

	if(accept_check(I))
		if(length(contents) >= max_n_of_items)
			to_chat(user, "<span class='notice'>\The [src] is full.</span>")
			return TRUE
		else if(!user.drop_held_item())
			return TRUE

		I.forceMove(src)

		if(item_quants[I.name])
			item_quants[I.name]++
		else
			item_quants[I.name] = 1

		user.visible_message("<span class='notice'>[user] has added \the [I] to \the [src].", \
							"<span class='notice'>You add \the [I] to \the [src].")
		SSnano.update_uis(src)

	else if(istype(I, /obj/item/storage/bag/plants))
		var/obj/item/storage/bag/plants/P = I
		var/plants_loaded = 0
		for(var/obj/G in P.contents)
			if(!accept_check(G))
				continue

			if(contents.len >= max_n_of_items)
				to_chat(user, "<span class='notice'>\The [src] is full.</span>")
				return TRUE

			P.remove_from_storage(G, src)
			if(item_quants[G.name])
				item_quants[G.name]++
			else
				item_quants[G.name] = 1
			plants_loaded++

		if(plants_loaded)
			user.visible_message("<span class='notice'>[user] loads \the [src] with \the [P].</span>", \
				"<span class='notice'>You load \the [src] with \the [P].</span>")

			if(length(P.contents) > 0)
				to_chat(user, "<span class='notice'>Some items are refused.</span>")

		SSnano.update_uis(src)

	else
		to_chat(user, "<span class='notice'>\The [src] smartly refuses [I].</span>")
		return TRUE

/obj/machinery/smartfridge/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/smartfridge/attack_ai(mob/user)
	return 0

/obj/machinery/smartfridge/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(machine_stat & NOPOWER)
		to_chat(user, "<span class='warning'>[src] has no power.</span>")
		return
	if(seconds_electrified != 0)
		if(shock(user, 100))
			return

	ui_interact(user)

/*******************
*   SmartFridge Menu
********************/

/obj/machinery/smartfridge/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_interaction(src)

	var/data[0]
	data["contents"] = null
	data["panel_open"] = CHECK_BITFIELD(machine_stat, PANEL_OPEN)
	data["electrified"] = seconds_electrified > 0
	data["shoot_inventory"] = shoot_inventory
	data["locked"] = locked
	data["secure"] = is_secure_fridge

	var/list/items[0]
	for (var/i=1 to length(item_quants))
		var/K = item_quants[i]
		var/count = item_quants[K]
		if (count > 0)
			items.Add(list(list("display_name" = html_encode(capitalize(K)), "vend" = i, "quantity" = count)))

	if (items.len > 0)
		data["contents"] = items

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "smartfridge.tmpl", src.name, 400, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/smartfridge/Topic(href, href_list)
	. = ..()
	if(.) 
		return

	var/mob/user = usr
	var/datum/nanoui/ui = SSnano.get_open_ui(user, src, "main")


	if (href_list["close"])
		user.unset_interaction()
		ui.close()
		return 0

	if (href_list["vend"])
		if(machine_stat & NOPOWER)
			to_chat(usr, "<span class='warning'>[src] has no power.</span>.")
			return 0
		if (!in_range(src, usr))
			return 0
		if(is_secure_fridge)
			if(!allowed(usr) && !CHECK_BITFIELD(obj_flags, EMAGGED) && locked != -1)
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				return 0
		var/index = text2num(href_list["vend"])
		var/amount = text2num(href_list["amount"])
		var/K = item_quants[index]
		var/count = item_quants[K]

		// Sanity check, there are probably ways to press the button when it shouldn't be possible.
		if(count > 0)
			item_quants[K] = max(count - amount, 0)

			var/i = amount
			for(var/obj/O in contents)
				if(O.name == K)
					O.loc = loc
					i--
					if (i <= 0)
						return 1

		return 1

/obj/machinery/smartfridge/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for (var/O in item_quants)
		if(item_quants[O] <= 0) //Try to use a record that actually has something to dump.
			continue

		item_quants[O]--
		for(var/obj/T in contents)
			if(T.name == O)
				T.loc = src.loc
				throw_item = T
				break
		break
	if(!throw_item)
		return 0
	spawn(0)
		throw_item.throw_at(target,16,3,src)
	src.visible_message("<span class='danger'>[src] launches [throw_item.name] at [target.name]!</span>")
	return 1




/********************
*	Smartfridge types
*********************/

/obj/machinery/smartfridge/seeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "seeds"
	icon_on = "seeds"
	icon_off = "seeds-off"

/obj/machinery/smartfridge/seeds/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/seeds/))
		return 1
	return 0

//the secure subtype does nothing, I'm only keeping it to avoid conflicts with maps.
/obj/machinery/smartfridge/secure/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_state = "smartfridge" //To fix the icon in the map editor.
	icon_on = "smartfridge"
	icon_off = "smartfridge-off"
	is_secure_fridge = TRUE
	req_one_access_txt = "5;33"

/obj/machinery/smartfridge/secure/medbay/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/reagent_container/glass/))
		return 1
	if(istype(O,/obj/item/storage/pill_bottle/))
		return 1
	if(istype(O,/obj/item/reagent_container/pill/))
		return 1
	return 0


/obj/machinery/smartfridge/secure/virology
	name = "\improper Refrigerated Virus Storage"
	desc = "A refrigerated storage unit for storing viral material."
	is_secure_fridge = TRUE
	req_access_txt = "39"
	icon_state = "smartfridge"
	icon_on = "smartfridge"
	icon_off = "smartfridge-off"

/obj/machinery/smartfridge/secure/virology/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/reagent_container/glass/beaker/vial/))
		return 1
	return 0


/obj/machinery/smartfridge/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."
	is_secure_fridge = TRUE
	req_one_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_MEDPREP) //Medics can now access the fridge

/obj/machinery/smartfridge/chemistry/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/storage/pill_bottle) || istype(O,/obj/item/reagent_container))
		return 1
	return 0


/obj/machinery/smartfridge/chemistry/virology
	name = "\improper Smart Virus Storage"
	desc = "A refrigerated storage unit for volatile sample storage."


/obj/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."

/obj/machinery/smartfridge/drinks/accept_check(obj/item/O as obj)
	if(istype(O,/obj/item/reagent_container/glass) || istype(O,/obj/item/reagent_container/food/drinks) || istype(O,/obj/item/reagent_container/food/condiment))
		return 1
