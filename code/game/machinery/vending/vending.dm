#define CAT_NORMAL 0
#define CAT_HIDDEN 1
#define CAT_COIN   2

/datum/data/vending_product
	var/product_name = "generic"
	var/product_path = null
	var/amount = 0
	var/price = 0
	var/display_color = "white"
	var/category = CAT_NORMAL

/obj/machinery/vending
	name = "Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "generic"
	anchored = 1
	density = 1
	layer = BELOW_OBJ_LAYER

	use_power = 1
	idle_power_usage = 10
	var/vend_power_usage = 150 //actuators and stuff

	var/active = 1 //No sales pitches if off!
	var/delay_product_spawn // If set, uses sleep() in product spawn proc (mostly for seeds to retrieve correct names).
	var/vend_ready = 1 //Are we ready to vend?? Is it time??
	var/vend_delay = 10 //How long does it take to vend?
	var/datum/data/vending_product/currently_vending = null // A /datum/data/vending_product instance of what we're paying for right now.

	// To be filled out at compile time
	var/list/products	= list() // For each, use the following pattern:
	var/list/contraband	= list() // list(/type/path = amount,/type/path2 = amount2)
	var/list/premium 	= list() // No specified amount = only one in stock
	var/list/prices     = list() // Prices for each item, list(/type/path = price), items not in the list don't have a price.

	var/product_slogans = "" //String of slogans separated by semicolons, optional
	var/product_ads = "" //String of small ad messages in the vending screen - random chance
	var/list/product_records = list()
	var/list/hidden_records = list()
	var/list/coin_records = list()
	var/list/slogan_list = list()
	var/list/small_ads = list() // small ad messages in the vending screen - random chance of popping up whenever you open it
	var/vend_reply //Thank you for shopping!
	var/last_reply = 0
	var/last_slogan = 0 //When did we last pitch?
	var/slogan_delay = 600 //How long until we can pitch again?
	var/icon_vend //Icon_state when vending!
	var/icon_deny //Icon_state when vending!
	//var/emagged = 0 //Ignores if somebody doesn't have card access to that machine.
	var/seconds_electrified = 0 //Shock customers like an airlock.
	var/shoot_inventory = 0 //Fire items at customers! We're broken!
	var/shut_up = 0 //Stop spouting those godawful pitches!
	var/extended_inventory = 0 //can we access the hidden inventory?
	var/panel_open = 0 //Hacking that vending machine. Gonna get a free candy bar.
	var/wires = 15
	var/obj/item/coin/coin
	var/const/WIRE_EXTEND = 1
	var/const/WIRE_SCANID = 2
	var/const/WIRE_SHOCK = 3
	var/const/WIRE_SHOOTINV = 4

	var/check_accounts = 0		// 1 = requires PIN and checks accounts.  0 = You slide an ID, it vends, SPACE COMMUNISM!
	var/obj/item/spacecash/ewallet/ewallet
	var/tipped_level = 0
	var/hacking_safety = 0 //1 = Will never shoot inventory or allow all access
	var/wrenchable = TRUE

/obj/machinery/vending/New()
	..()
	spawn(4)
		src.slogan_list = text2list(src.product_slogans, ";")

		// So not all machines speak at the exact same time.
		// The first time this machine says something will be at slogantime + this random value,
		// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
		src.last_slogan = world.time + rand(0, slogan_delay)

		src.build_inventory(products)
		 //Add hidden inventory
		src.build_inventory(contraband, 1)
		src.build_inventory(premium, 0, 1)
		power_change()
		start_processing()
		return

	return

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1)
			cdel(src)
		if(2)
			if(prob(50))
				cdel(src)
		if(3)
			if(prob(25))
				spawn(0)
					malfunction()

/obj/machinery/vending/proc/select_gamemode_equipment(gamemode)
	return

/obj/machinery/vending/proc/build_inventory(var/list/productlist,hidden=0,req_coin=0)

	if(delay_product_spawn)
		sleep(15) //Make ABSOLUTELY SURE the seed datum is properly populated.

	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		var/price = prices[typepath]
		if(isnull(amount)) amount = 1

		var/obj/item/temp_path = typepath
		var/datum/data/vending_product/R = new /datum/data/vending_product()

		R.product_path = typepath
		R.amount = amount
		R.price = price

		if(ispath(typepath,/obj/item/weapon/gun) || ispath(typepath,/obj/item/ammo_magazine) || ispath(typepath,/obj/item/explosive/grenade) || ispath(typepath,/obj/item/weapon/gun/flamer) || ispath(typepath,/obj/item/storage) )
			R.display_color = "black"
//		else if(ispath(typepath,/obj/item/clothing) || ispath(typepath,/obj/item/storage))
//			R.display_color = "white"
//		else if(ispath(typepath,/obj/item/reagent_container) || ispath(typepath,/obj/item/stack/medical))
//			R.display_color = "blue"
		else
			R.display_color = "white"

		if(hidden)
			R.category=CAT_HIDDEN
			hidden_records += R
		else if(req_coin)
			R.category=CAT_COIN
			coin_records += R
		else
			R.category=CAT_NORMAL
			product_records += R

		if(delay_product_spawn)
			sleep(5) //sleep(1) did not seem to cut it, so here we are.

		R.product_name = initial(temp_path.name)

//		world << "Added: [R.product_name]] - [R.amount] - [R.product_path]"
	return

/obj/machinery/vending/attackby(obj/item/W, mob/user)
	if(tipped_level)
		user << "Tip it back upright first!"
		return

	if (istype(W, /obj/item/card/emag))
		src.emagged = 1
		user << "You short out the product lock on [src]"
		return
	else if(istype(W, /obj/item/tool/screwdriver))
		src.panel_open = !src.panel_open
		user << "You [src.panel_open ? "open" : "close"] the maintenance panel."
		src.overlays.Cut()
		if(src.panel_open)
			src.overlays += image(src.icon, "[initial(icon_state)]-panel")
		src.updateUsrDialog()
		return
	else if(istype(W, /obj/item/device/multitool)||istype(W, /obj/item/tool/wirecutters))
		if(src.panel_open)
			attack_hand(user)
		return
	else if(istype(W, /obj/item/coin))
		if(user.drop_inv_item_to_loc(W, src))
			coin = W
			user << "\blue You insert the [W] into the [src]"
		return
	else if(istype(W, /obj/item/card))
		var/obj/item/card/I = W
		scan_card(I)
		return
	else if (istype(W, /obj/item/spacecash/ewallet))
		if(user.drop_inv_item_to_loc(W, src))
			ewallet = W
			user << "\blue You insert the [W] into the [src]"
		return

	else if(istype(W, /obj/item/tool/wrench))
		if(!wrenchable) return

		if(do_after(user, 20, TRUE, 5, BUSY_ICON_BUILD))
			if(!src) return
			playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
			switch (anchored)
				if (0)
					anchored = 1
					user.visible_message("[user] tightens the bolts securing \the [src] to the floor.", "You tighten the bolts securing \the [src] to the floor.")
				if (1)
					user.visible_message("[user] unfastens the bolts securing \the [src] to the floor.", "You unfasten the bolts securing \the [src] to the floor.")
					anchored = 0
		return

	..()

/obj/machinery/vending/proc/scan_card(var/obj/item/card/I)
	if(!currently_vending) return
	if (istype(I, /obj/item/card/id))
		var/obj/item/card/id/C = I
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		var/datum/money_account/CH = get_account(C.associated_account_number)
		if (CH) // Only proceed if card contains proper account number.
			if(!CH.suspended)
				if(CH.security_level != 0) //If card requires pin authentication (ie seclevel 1 or 2)
					if(vendor_account)
						var/attempt_pin = input("Enter pin code", "Vendor transaction") as num
						var/datum/money_account/D = attempt_account_access(C.associated_account_number, attempt_pin, 2)
						transfer_and_vend(D)
					else
						usr << "\icon[src]<span class='warning'>Unable to access account. Check security settings and try again.</span>"
				else
					//Just Vend it.
					transfer_and_vend(CH)
			else
				usr << "\icon[src]<span class='warning'>Connected account has been suspended.</span>"
		else
			usr << "\icon[src]<span class='warning'>Error: Unable to access your account. Please contact technical support if problem persists.</span>"

/obj/machinery/vending/proc/transfer_and_vend(var/datum/money_account/acc)
	if(acc)
		var/transaction_amount = currently_vending.price
		if(transaction_amount <= acc.money)

			//transfer the money
			acc.money -= transaction_amount
			vendor_account.money += transaction_amount

			//create entries in the two account transaction logs
			var/datum/transaction/T = new()
			T.target_name = "[vendor_account.owner_name] (via [src.name])"
			T.purpose = "Purchase of [currently_vending.product_name]"
			if(transaction_amount > 0)
				T.amount = "([transaction_amount])"
			else
				T.amount = "[transaction_amount]"
			T.source_terminal = src.name
			T.date = current_date_string
			T.time = worldtime2text()
			acc.transaction_log.Add(T)
							//
			T = new()
			T.target_name = acc.owner_name
			T.purpose = "Purchase of [currently_vending.product_name]"
			T.amount = "[transaction_amount]"
			T.source_terminal = src.name
			T.date = current_date_string
			T.time = worldtime2text()
			vendor_account.transaction_log.Add(T)

			// Vend the item
			src.vend(src.currently_vending, usr)
			currently_vending = null
		else
			usr << "\icon[src]<span class='warning'>You don't have that much money!</span>"
	else
		usr << "\icon[src]<span class='warning'>Error: Unable to access your account. Please contact technical support if problem persists.</span>"


/obj/machinery/vending/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/vending/proc/GetProductIndex(var/datum/data/vending_product/P)
	var/list/plist
	switch(P.category)
		if(CAT_NORMAL)
			plist=product_records
		if(CAT_HIDDEN)
			plist=hidden_records
		if(CAT_COIN)
			plist=coin_records
		else
			warning("UNKNOWN CATEGORY [P.category] IN TYPE [P.product_path] INSIDE [type]!")
	return plist.Find(P)

/obj/machinery/vending/proc/GetProductByID(var/pid, var/category)
	switch(category)
		if(CAT_NORMAL)
			return product_records[pid]
		if(CAT_HIDDEN)
			return hidden_records[pid]
		if(CAT_COIN)
			return coin_records[pid]
		else
			warning("UNKNOWN PRODUCT: PID: [pid], CAT: [category] INSIDE [type]!")
			return null

/obj/machinery/vending/attack_hand(mob/user as mob)
	if(tipped_level == 2)
		tipped_level = 1
		user.visible_message("\blue [user] begins to heave the vending machine back into place!","\blue You start heaving the vending machine back into place..")
		if(do_after(user,80, FALSE, 5, BUSY_ICON_FRIENDLY))
			user.visible_message("\blue [user] rights the [src]!","\blue You right the [src]!")
			flip_back()
			return
		else
			tipped_level = 2
			return

	if(stat & (BROKEN|NOPOWER))
		return

	user.set_interaction(src)

	if(src.seconds_electrified != 0)
		if(shock(user, 100))
			return


	if(panel_open)
		var/dat = ""
		var/list/vendwires = list(
			"Violet" = 1,
			"Orange" = 2,
			"Goldenrod" = 3,
			"Green" = 4,
		)
		dat += "<br><hr><br><B>Access Panel</B><br>"
		for(var/wiredesc in vendwires)
			var/is_uncut = src.wires & APCWireColorToFlag[vendwires[wiredesc]]
			dat += "[wiredesc] wire: "
			if(!is_uncut)
				dat += "<a href='?src=\ref[src];cutwire=[vendwires[wiredesc]]'>Mend</a>"
			else
				dat += "<a href='?src=\ref[src];cutwire=[vendwires[wiredesc]]'>Cut</a> "
				dat += "<a href='?src=\ref[src];pulsewire=[vendwires[wiredesc]]'>Pulse</a> "
			dat += "<br>"

		dat += "<br>"
		dat += "The orange light is [(src.seconds_electrified == 0) ? "off" : "on"].<BR>"
		dat += "The red light is [src.shoot_inventory ? "off" : "blinking"].<BR>"
		dat += "The green light is [src.extended_inventory ? "on" : "off"].<BR>"
		dat += "The [(src.wires & WIRE_SCANID) ? "purple" : "yellow"] light is on.<BR>"

		if (product_slogans != "")
			dat += "The speaker switch is [src.shut_up ? "off" : "on"]. <a href='?src=\ref[src];togglevoice=[1]'>Toggle</a>"

		user << browse(dat, "window=vending")
		onclose(user, "vending")


	ui_interact(user)




/obj/machinery/vending/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 0)

	var/list/display_list = list()
	var/list/display_records = list()
	display_records += product_records
	if(extended_inventory)
		display_records += hidden_records
	if(coin)
		display_records += coin_records
	for (var/datum/data/vending_product/R in display_records)
		var/prodname = adminscrub(R.product_name)
		if(R.amount) prodname += ": [R.amount]"
		else prodname += ": SOLD OUT"
		if(R.price) prodname += " (Price: [R.price])"
		prodname = "<color = [R.display_color]>[prodname]</color>"
		display_list += list(list("product_name" = prodname, "product_color" = R.display_color, "amount" = R.amount, "prod_index" = GetProductIndex(R), "prod_cat" = R.category))

	var/list/data = list(
		"vendor_name" = name,
		"currently_vending_name" = currently_vending ? sanitize(currently_vending.product_name) : null,
		"premium_length" = premium.len,
		"ewallet" = ewallet ? ewallet.name : null,
		"ewallet_worth" = ewallet ? ewallet.worth : null,
		"coin" = coin ? coin.name : null,
		"displayed_records" = display_list,
	)

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "vending_machine.tmpl", name , 450, 600)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/vending/Topic(href, href_list)
	if(stat & (BROKEN|NOPOWER))
		return
	if(usr.is_mob_incapacitated())
		return

	if(href_list["remove_coin"] && !istype(usr,/mob/living/silicon))
		if(!coin)
			usr << "There is no coin in this machine."
			return

		coin.loc = src.loc
		if(!usr.get_active_hand())
			usr.put_in_hands(coin)
		usr << "\blue You remove the [coin] from the [src]"
		coin = null

	if(href_list["remove_ewallet"] && !istype(usr,/mob/living/silicon))
		if (!ewallet)
			usr << "There is no charge card in this machine."
			return
		ewallet.loc = src.loc
		if(!usr.get_active_hand())
			usr.put_in_hands(ewallet)
		usr << "\blue You remove the [ewallet] from the [src]"
		ewallet = null

	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.set_interaction(src)
		if ((href_list["vend"]) && vend_ready && !currently_vending)

			if(!allowed(usr) && !emagged && (wires & WIRE_SCANID || hacking_safety)) //For SECURE VENDING MACHINES YEAH. Hacking safety always prevents bypassing emag or access
				usr << "<span class='warning'>Access denied.</span>" //Unless emagged of course
				flick(src.icon_deny,src)
				return

			var/idx=text2num(href_list["vend"])
			var/cat=text2num(href_list["cat"])

			var/datum/data/vending_product/R = GetProductByID(idx,cat)
			if (!R || !istype(R) || !R.product_path || R.amount <= 0)
				return

			if(R.price == null)
				src.vend(R, usr)
			else
				if (ewallet)
					if (R.price <= ewallet.worth)
						ewallet.worth -= R.price
						src.vend(R, usr)
					else
						usr << "\red The ewallet doesn't have enough money to pay for that."
						src.currently_vending = R
						src.updateUsrDialog()
				else
					src.currently_vending = R
					src.updateUsrDialog()
			return

		else if (href_list["cancel_buying"])
			src.currently_vending = null
			src.updateUsrDialog()
			return

		else if ((href_list["cutwire"]) && (src.panel_open))
			var/twire = text2num(href_list["cutwire"])
			if(usr.mind && usr.mind.cm_skills && usr.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				usr << "<span class='warning'>You don't understand anything about this wiring...</span>"
				return 0
			if (!( istype(usr.get_active_hand(), /obj/item/tool/wirecutters) ))
				usr << "You need wirecutters!"
				return
			if (src.isWireColorCut(twire))
				src.mend(twire)
			else
				src.cut(twire)

		else if ((href_list["pulsewire"]) && (src.panel_open))
			var/twire = text2num(href_list["pulsewire"])
			if(usr.mind && usr.mind.cm_skills && usr.mind.cm_skills.engineer < SKILL_ENGINEER_ENGI)
				usr << "<span class='warning'>You don't understand anything about this wiring...</span>"
				return 0
			if (!istype(usr.get_active_hand(), /obj/item/device/multitool))
				usr << "You need a multitool!"
				return
			if (src.isWireColorCut(twire))
				usr << "You can't pulse a cut wire."
				return
			else
				src.pulse(twire)

		else if ((href_list["togglevoice"]) && (src.panel_open))
			src.shut_up = !src.shut_up

		src.add_fingerprint(usr)
		ui_interact(usr) //updates the nanoUI window
		updateUsrDialog() //updates the wires window
	else
		usr << browse(null, "window=vending")


/obj/machinery/vending/proc/vend(datum/data/vending_product/R, mob/user)
	if(!allowed(user) && !emagged && (wires & WIRE_SCANID || hacking_safety)) //For SECURE VENDING MACHINES YEAH
		user << "<span class='warning'>Access denied.</span>" //Unless emagged of course
		flick(src.icon_deny,src)
		return

	if (R in coin_records)
		if(!coin)
			user << "\blue You need to insert a coin to get this item."
			return
		if(coin.string_attached)
			if(prob(50))
				user << "\blue You successfully pull the coin out before the [src] could swallow it."
			else
				user << "\blue You weren't able to pull the coin out fast enough, the machine ate it, string and all."
				cdel(coin)
				coin = null
		else
			cdel(coin)
			coin = null

	vend_ready = 0 //One thing at a time!!
	R.amount--

	if(((src.last_reply + (src.vend_delay + 200)) <= world.time) && src.vend_reply)
		spawn(0)
			src.speak(src.vend_reply)
			src.last_reply = world.time


	release_item(R, vend_delay)
	vend_ready = 1
	updateUsrDialog()

/obj/machinery/vending/proc/release_item(datum/data/vending_product/R, delay_vending = 0, dump_product = 0)
	set waitfor = 0
	if(delay_vending)
		use_power(vend_power_usage)	//actuators and stuff
		if (icon_vend) flick(icon_vend,src) //Show the vending animation if needed
		sleep(delay_vending)
	if(ispath(R.product_path,/obj/item/weapon/gun)) . = new R.product_path(get_turf(src),1)
	else . = new R.product_path(get_turf(src))

/obj/machinery/vending/MouseDrop_T(var/atom/movable/A, mob/user)

	if(stat & (BROKEN|NOPOWER))
		return

	if(user.stat || user.is_mob_restrained() || user.lying)
		return

	if(get_dist(user, src) > 1 || get_dist(src, A) > 1)
		return

	if(istype(A, /obj/item))
		var/obj/item/I = A
		stock(I, user)

/obj/machinery/vending/proc/stock(obj/item/item_to_stock, mob/user)
	var/datum/data/vending_product/R //Let's try with a new datum.
	 //More accurate comparison between absolute paths.
	for(R in (product_records + hidden_records + coin_records))
		if(item_to_stock.type == R.product_path && !istype(item_to_stock,/obj/item/storage)) //Nice try, specialists/engis
			if(istype(item_to_stock, /obj/item/weapon/gun))
				var/obj/item/weapon/gun/G = item_to_stock
				if(G.in_chamber || (G.current_mag && !istype(G.current_mag, /obj/item/ammo_magazine/internal)) || (istype(G.current_mag, /obj/item/ammo_magazine/internal) && G.current_mag.current_rounds > 0) )
					user << "<span class='warning'>[G] is still loaded. Unload it before you can restock it.</span>"
					return
				for(var/obj/item/attachable/A in G.contents) //Search for attachments on the gun. This is the easier method
					if((A.flags_attach_features & ATTACH_REMOVABLE) && !(is_type_in_list(A, G.starting_attachment_types))) //There are attachments that are default and others that can't be removed
						user << "<span class='warning'>[G] has non-standard attachments equipped. Detach them before you can restock it.</span>"
						return

			if(istype(item_to_stock, /obj/item/ammo_magazine))
				var/obj/item/ammo_magazine/A = item_to_stock
				if(A.current_rounds < A.max_rounds)
					user << "<span class='warning'>[A] isn't full. Fill it before you can restock it.</span>"
					return
			if(item_to_stock.loc == user) //Inside the mob's inventory
				if(item_to_stock.flags_item & WIELDED)
					item_to_stock.unwield(user)
				user.temp_drop_inv_item(item_to_stock)

			if(istype(item_to_stock.loc, /obj/item/storage)) //inside a storage item
				var/obj/item/storage/S = item_to_stock.loc
				S.remove_from_storage(item_to_stock, user.loc)

			cdel(item_to_stock)
			user.visible_message("<span class='notice'>[user] stocks [src] with \a [R.product_name].</span>",
			"<span class='notice'>You stock [src] with \a [R.product_name].</span>")
			R.amount++
			updateUsrDialog()
			return //We found our item, no reason to go on.

/obj/machinery/vending/process()
	if(stat & (BROKEN|NOPOWER))
		return

	if(!src.active)
		return

	if(src.seconds_electrified > 0)
		src.seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(((src.last_slogan + src.slogan_delay) <= world.time) && (src.slogan_list.len > 0) && (!src.shut_up) && prob(5))
		var/slogan = pick(src.slogan_list)
		src.speak(slogan)
		src.last_slogan = world.time

	if(src.shoot_inventory && prob(2) && !hacking_safety)
		src.throw_item()

	return

/obj/machinery/vending/proc/speak(var/message)
	if(stat & NOPOWER)
		return

	if (!message)
		return

	for(var/mob/O in hearers(src, null))
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",2)
	return

/obj/machinery/vending/power_change()
	..()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if( !(stat & NOPOWER) )
			icon_state = initial(icon_state)
		else
			spawn(rand(0, 15))
				src.icon_state = "[initial(icon_state)]-off"

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	for(var/datum/data/vending_product/R in src.product_records)
		if (R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if (!dump_path)
			continue

		while(R.amount>0)
			release_item(R, 0)
			R.amount--
		break

	stat |= BROKEN
	src.icon_state = "[initial(icon_state)]-broken"
	return

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return 0

	for(var/datum/data/vending_product/R in product_records)
		if (R.amount <= 0) //Try to use a record that actually has something to dump.
			continue
		var/dump_path = R.product_path
		if (!dump_path)
			continue

		R.amount--
		throw_item = release_item(R, 0)
		break
	if (!throw_item)
		return 0
	spawn(0)
		throw_item.throw_at(target, 16, 3, src)
	src.visible_message("<span class='warning'>[src] launches [throw_item.name] at [target]!</span>")
	return 1

/obj/machinery/vending/proc/isWireColorCut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/isWireCut(var/wireIndex)
	var/wireFlag = APCIndexToFlag[wireIndex]
	return ((src.wires & wireFlag) == 0)

/obj/machinery/vending/proc/cut(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor]
	src.wires &= ~wireFlag
	switch(wireIndex)
		if(WIRE_EXTEND)
			src.extended_inventory = 0
		if(WIRE_SHOCK)
			src.seconds_electrified = -1
		if (WIRE_SHOOTINV)
			if(!src.shoot_inventory)
				src.shoot_inventory = 1


/obj/machinery/vending/proc/mend(var/wireColor)
	var/wireFlag = APCWireColorToFlag[wireColor]
	var/wireIndex = APCWireColorToIndex[wireColor] //not used in this function
	src.wires |= wireFlag
	switch(wireIndex)
		if(WIRE_SHOCK)
			src.seconds_electrified = 0
		if (WIRE_SHOOTINV)
			src.shoot_inventory = 0

/obj/machinery/vending/proc/pulse(var/wireColor)
	var/wireIndex = APCWireColorToIndex[wireColor]
	switch(wireIndex)
		if(WIRE_EXTEND)
			src.extended_inventory = !src.extended_inventory
		if (WIRE_SHOCK)
			src.seconds_electrified = 30
		if (WIRE_SHOOTINV)
			src.shoot_inventory = !src.shoot_inventory
