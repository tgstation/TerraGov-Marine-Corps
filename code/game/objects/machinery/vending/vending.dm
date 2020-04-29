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
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER

	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	interaction_flags = INTERACT_MACHINE_NANO

	var/active = TRUE //No sales pitches if off!
	var/vend_ready = TRUE //Are we ready to vend?? Is it time??
	var/vend_delay = 10 //How long does it take to vend?
	var/datum/data/vending_product/currently_vending = null // A /datum/data/vending_product instance of what we're paying for right now.
	var/currently_vending_index

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
	var/seconds_electrified = 0 //Shock customers like an airlock.
	var/shoot_inventory = FALSE //Fire items at customers! We're broken!
	var/shut_up = FALSE //Stop spouting those godawful pitches!
	var/extended_inventory = FALSE //can we access the hidden inventory?
	var/obj/item/coin/coin
	var/tokensupport = TOKEN_GENERAL

	var/check_accounts = 0		// 1 = requires PIN and checks accounts.  0 = You slide an ID, it vends, SPACE COMMUNISM!
	var/obj/item/spacecash/ewallet/ewallet
	var/tipped_level = 0
	var/hacking_safety = FALSE //1 = Will never shoot inventory or allow all access
	wrenchable = TRUE
	var/isshared = FALSE
	var/scan_id = TRUE

	var/knockdown_threshold = 100

	ui_x = 450
	ui_y = 600


/obj/machinery/vending/Initialize(mapload, ...)
	. = ..()
	wires = new /datum/wires/vending(src)
	src.slogan_list = text2list(src.product_slogans, ";")

	// So not all machines speak at the exact same time.
	// The first time this machine says something will be at slogantime + this random value,
	// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
	src.last_slogan = world.time + rand(0, slogan_delay)

	src.build_inventory(products)
		//Add hidden inventory
	src.build_inventory(contraband, 1)
	src.build_inventory(premium, 0, 1)
	start_processing()
	return INITIALIZE_HINT_LATELOAD


/obj/machinery/vending/LateInitialize()
	. = ..()
	power_change()


/obj/machinery/vending/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/vending/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				qdel(src)
		if(3)
			if(prob(25))
				INVOKE_ASYNC(src, .proc/malfunction)

/obj/machinery/vending/proc/select_gamemode_equipment(gamemode)
	return

GLOBAL_LIST_INIT(vending_white_items, typecacheof(list(
	/obj/item/ammo_magazine/pistol/standard_pistol,
	/obj/item/ammo_magazine/revolver/standard_revolver,
	/obj/item/weapon/gun/smg/standard_smg,
	/obj/item/weapon/gun/rifle/standard_carbine,
	/obj/item/weapon/gun/rifle/standard_assaultrifle,
	/obj/item/weapon/gun/rifle/standard_lmg,
	/obj/item/weapon/gun/rifle/standard_dmr,
	/obj/item/weapon/gun/energy/lasgun/lasrifle,
	/obj/item/weapon/gun/shotgun/pump/t35,
	/obj/item/weapon/gun/rifle/standard_autoshotgun,
	/obj/item/ammobox,
	/obj/item/shotgunbox,
	/obj/item/smartgun_powerpack,
	/obj/item/weapon/combat_knife,
	/obj/item/radio/headset/mainship/marine,
	/obj/item/clothing/gloves/marine,
	/obj/item/clothing/shoes/marine,
	/obj/item/clothing/under/marine,
	/obj/item/storage/backpack/marine/satchel,
	/obj/item/clothing/suit/storage/marine,
	/obj/item/storage/belt/marine,
	/obj/item/storage/pouch/flare,
	/obj/item/storage/pouch/firstaid
)))

/obj/machinery/vending/proc/build_inventory(list/productlist,hidden=0,req_coin=0)

	for(var/typepath in productlist)
		var/amount = productlist[typepath]
		var/price = prices[typepath]
		if(isnull(amount)) amount = 1

		var/obj/item/temp_path = typepath
		var/datum/data/vending_product/R = new /datum/data/vending_product()

		R.product_path = typepath
		R.amount = amount
		R.price = price

		if(is_type_in_typecache(typepath, GLOB.vending_white_items))
			R.display_color = "white"
//		else if(ispath(typepath,/obj/item/clothing) || ispath(typepath,/obj/item/storage))
//			R.display_color = "white"
//		else if(ispath(typepath,/obj/item/reagent_containers) || ispath(typepath,/obj/item/stack/medical))
//			R.display_color = "blue"
		else
			R.display_color = "black"

		if(hidden)
			R.category=CAT_HIDDEN
			hidden_records += R
		else if(req_coin)
			R.category=CAT_COIN
			coin_records += R
		else
			R.category=CAT_NORMAL
			product_records += R

		if(ispath(typepath, /obj/item/seeds))
			var/obj/item/seeds/S = typepath
			var/datum/seed/SD = GLOB.seed_types[initial(S.seed_type)]
			R.product_name = "packet of [SD.seed_name] [SD.seed_noun]"
			continue

		R.product_name = initial(temp_path.name)


/obj/machinery/vending/attack_alien(mob/living/carbon/xenomorph/M)
	if(tipped_level)
		to_chat(M, "<span class='warning'>There's no reason to bother with that old piece of trash.</span>")
		return FALSE

	if(M.a_intent == INTENT_HARM)
		M.do_attack_animation(src, ATTACK_EFFECT_SMASH)
		if(prob(M.xeno_caste.melee_damage))
			playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
			M.visible_message("<span class='danger'>\The [M] smashes \the [src] beyond recognition!</span>", \
			"<span class='danger'>We enter a frenzy and smash \the [src] apart!</span>", null, 5)
			malfunction()
			return TRUE
		else
			M.visible_message("<span class='danger'>[M] slashes \the [src]!</span>", \
			"<span class='danger'>We slash \the [src]!</span>", null, 5)
			playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
		return TRUE

	M.visible_message("<span class='warning'>\The [M] begins to lean against \the [src].</span>", \
	"<span class='warning'>You begin to lean against \the [src].</span>", null, 5)
	tipped_level = 1
	var/shove_time = 100
	if(M.mob_size == MOB_SIZE_BIG)
		shove_time = 50
	if(istype(M,/mob/living/carbon/xenomorph/crusher))
		shove_time = 15
	if(do_after(M, shove_time, FALSE, src, BUSY_ICON_HOSTILE))
		M.visible_message("<span class='danger'>\The [M] knocks \the [src] down!</span>", \
		"<span class='danger'>You knock \the [src] down!</span>", null, 5)
		tip_over()
	else
		tipped_level = 0

/obj/machinery/vending/proc/tip_over()
	var/matrix/A = matrix()
	tipped_level = 2
	density = FALSE
	A.Turn(90)
	transform = A
	malfunction()

/obj/machinery/vending/proc/flip_back()
	icon_state = initial(icon_state)
	tipped_level = 0
	density = TRUE
	var/matrix/A = matrix()
	transform = A
	machine_stat &= ~BROKEN //Remove broken. MAGICAL REPAIRS

/obj/machinery/vending/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(tipped_level)
		to_chat(user, "Tip it back upright first!")

	else if(isscrewdriver(I))
		TOGGLE_BITFIELD(machine_stat, PANEL_OPEN)
		to_chat(user, "You [CHECK_BITFIELD(machine_stat, PANEL_OPEN) ? "open" : "close"] the maintenance panel.")
		overlays.Cut()
		if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			overlays += image(icon, "[initial(icon_state)]-panel")
		updateUsrDialog()

	else if(ismultitool(I) || iswirecutter(I))
		if(!CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			return

		attack_hand(user)

	else if(istype(I, /obj/item/coin))
		var/obj/item/coin/C = I

		if(coin)
			to_chat(user, "<span class='warning'>[src] already has [coin] inserted</span>")

		else if(!length(premium) && !isshared)
			to_chat(user, "<span class='warning'>[src] doesn't have a coin slot.</span>")

		else if(C.flags_token & tokensupport)
			if(!user.transferItemToLoc(C, src))
				return

			coin = C
			to_chat(user, "<span class='notice'>You insert \the [C] into \the [src]</span>")

		else
			to_chat(user, "<span class='warning'>\The [src] rejects \the [C].</span>")

	else if(istype(I, /obj/item/card))
		var/obj/item/card/C = I
		scan_card(C)

	else if(istype(I, /obj/item/spacecash/ewallet))
		if(!user.transferItemToLoc(I, src))
			return

		ewallet = I
		to_chat(user, "<span class='notice'>You insert the [I] into the [src]</span>")

	else if(iswrench(I))
		if(!wrenchable)
			return

		if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
			return

		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		anchored = !anchored
		if(anchored)
			user.visible_message("[user] tightens the bolts securing \the [src] to the floor.", "You tighten the bolts securing \the [src] to the floor.")
		else
			user.visible_message("[user] unfastens the bolts securing \the [src] to the floor.", "You unfasten the bolts securing \the [src] to the floor.")


/obj/machinery/vending/proc/scan_card(obj/item/card/I)
	if(!currently_vending) return
	if (istype(I, /obj/item/card/id))
		var/obj/item/card/id/C = I
		visible_message("<span class='info'>[usr] swipes a card through [src].</span>")
		var/datum/money_account/CH = get_account(C.associated_account_number)
		if(CH) // Only proceed if card contains proper account number.
			if(!CH.suspended)
				if(CH.security_level != 0) //If card requires pin authentication (ie seclevel 1 or 2)
					var/attempt_pin = input("Enter pin code", "Vendor transaction") as num
					var/datum/money_account/D = attempt_account_access(C.associated_account_number, attempt_pin, 2)
					transfer_and_vend(D)
				else
					//Just Vend it.
					transfer_and_vend(CH)
			else
				to_chat(usr, "[icon2html(src, usr)]<span class='warning'>Connected account has been suspended.</span>")
		else
			to_chat(usr, "[icon2html(src, usr)]<span class='warning'>Error: Unable to access your account. Please contact technical support if problem persists.</span>")

/obj/machinery/vending/proc/transfer_and_vend(datum/money_account/acc)
	if(!acc)
		to_chat(usr, "[icon2html(src, usr)]<span class='warning'>Error: Unable to access your account. Please contact technical support if problem persists.</span>")
		return

	var/transaction_amount = currently_vending.price
	if(transaction_amount > acc.money)
		to_chat(usr, "[icon2html(src, usr)]<span class='warning'>You don't have that much money!</span>")
		return

	//transfer the money
	acc.money -= transaction_amount

	//create entries in the two account transaction logs
	var/datum/transaction/T = new()
	T.purpose = "Purchase of [currently_vending.product_name]"
	if(transaction_amount > 0)
		T.amount = "([transaction_amount])"
	else
		T.amount = "[transaction_amount]"
	T.source_terminal = src.name
	T.date = GLOB.current_date_string
	T.time = worldtime2text()
	acc.transaction_log.Add(T)

	// Vend the item
	src.vend(src.currently_vending, usr)
	currently_vending = null
	currently_vending_index = null


/obj/machinery/vending/proc/GetProductIndex(datum/data/vending_product/P)
	var/list/plist
	switch(P.category)
		if(CAT_NORMAL)
			plist=product_records
		if(CAT_HIDDEN)
			plist=hidden_records
		if(CAT_COIN)
			plist=coin_records
		else
			stack_trace("UNKNOWN CATEGORY [P.category] IN TYPE [P.product_path] INSIDE [type]!")
	return plist.Find(P)

/obj/machinery/vending/proc/GetProductByID(pid, category)
	switch(category)
		if(CAT_NORMAL)
			return product_records[pid]
		if(CAT_HIDDEN)
			return hidden_records[pid]
		if(CAT_COIN)
			return coin_records[pid]
		else
			stack_trace("UNKNOWN PRODUCT: PID: [pid], CAT: [category] INSIDE [type]!")
			return null

/obj/machinery/vending/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(tipped_level == 2)
		user.visible_message("<span class='notice'> [user] begins to heave the vending machine back into place!</span>","<span class='notice'> You start heaving the vending machine back into place..</span>")
		if(!do_after(user,80, FALSE, src, BUSY_ICON_FRIENDLY))
			return FALSE

		user.visible_message("<span class='notice'> [user] rights the [src]!</span>","<span class='notice'> You right the [src]!</span>")
		flip_back()
		return TRUE

	return TRUE

/obj/machinery/vending/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "Vending", name, ui_x, ui_y, master_ui, state)
		ui.open()

/obj/machinery/vending/ui_data(mob/user)
	var/list/display_list = list()
	var/list/hidden_list = list()
	var/list/coin_list = list()
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
		switch(R.category)
			if(CAT_NORMAL)
				display_list += list(list("product_name" = prodname, "product_color" = R.display_color, "amount" = R.amount, "prod_index" = GetProductIndex(R), "prod_cat" = R.category))
			if(CAT_HIDDEN)
				hidden_list += list(list("product_name" = prodname, "product_color" = R.display_color, "amount" = R.amount, "prod_index" = GetProductIndex(R), "prod_cat" = R.category))
			if(CAT_COIN)
				coin_list += list(list("product_name" = prodname, "product_color" = R.display_color, "amount" = R.amount, "prod_index" = GetProductIndex(R), "prod_cat" = R.category))
		

	var/list/data = list(
		"vendor_name" = name,
		"currently_vending_name" = currently_vending ? sanitize(currently_vending.product_name) : null,
		"currently_vending_index" = currently_vending_index,
		"premium_length" = premium.len,
		"coin" = coin ? coin.name : null,
		"displayed_records" = display_list,
		"hidden_records" = hidden_list,
		"coin_records" = coin_list,
		"isshared" = isshared
	)
	return data

/obj/machinery/vending/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("remove_coin")
			if(!coin)
				to_chat(usr, "There is no coin in this machine.")
				return

			coin.forceMove(loc)
			coin = null
			usr.put_in_hands(coin)
			to_chat(usr, "<span class='notice'>You remove the [coin] from the [src]</span>")
			. = TRUE

		if("vend")
			if(!allowed(usr) && (!wires.is_cut(WIRE_IDSCAN) || hacking_safety))
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				flick(icon_deny, src)
				return

			var/idx = text2num(params["vend"])
			var/cat = text2num(params["cat"])

			var/datum/data/vending_product/R = GetProductByID(idx,cat)
			if(!istype(R) || !R.product_path || R.amount <= 0)
				return

			if(R.price == null)
				vend(R, usr)
			else
				currently_vending = R
				currently_vending_index = idx
			. = TRUE

		if("cancel_buying")
			currently_vending = null
			. = TRUE

		if("swipe")
			if(!ishuman(usr))
				return
			var/mob/living/carbon/human/H = usr
			scan_card(H.wear_id)
			. = TRUE

	updateUsrDialog()

/obj/machinery/vending/proc/vend(datum/data/vending_product/R, mob/user)
	if(!allowed(user) && (!wires.is_cut(WIRE_IDSCAN) || hacking_safety)) //For SECURE VENDING MACHINES YEAH
		to_chat(user, "<span class='warning'>Access denied.</span>")
		flick(src.icon_deny,src)
		return

	if (R in coin_records)
		if(!coin)
			to_chat(user, "<span class='notice'>You need to insert a coin to get this item.</span>")
			return
		if(coin.string_attached)
			if(prob(50))
				to_chat(user, "<span class='notice'>You successfully pull the coin out before the [src] could swallow it.</span>")
			else
				to_chat(user, "<span class='notice'>You weren't able to pull the coin out fast enough, the machine ate it, string and all.</span>")
				qdel(coin)
				coin = null
		else
			qdel(coin)
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
		if(powered(power_channel))
			use_power(active_power_usage)	//actuators and stuff
			if (icon_vend)
				flick(icon_vend, src) //Show the vending animation if needed
			sleep(delay_vending)
		else if(machine_current_charge > active_power_usage) //if no power, use the machine's battery.
			machine_current_charge -= min(machine_current_charge, active_power_usage) //Sterilize with min; no negatives allowed.
			//to_chat(world, "<span class='warning'>DEBUG: Machine Auto_Use_Power: Vend Power Usage: [active_power_usage] Machine Current Charge: [machine_current_charge].</span>")
			if (icon_vend)
				flick(icon_vend,src) //Show the vending animation if needed
			sleep(delay_vending)
		else
			return
	SSblackbox.record_feedback("tally", "vendored", 1, R.name)
	if(ispath(R.product_path,/obj/item/weapon/gun))
		return new R.product_path(get_turf(src), 1)
	else
		return new R.product_path(get_turf(src))


/obj/machinery/vending/MouseDrop_T(atom/movable/A, mob/user)

	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(user.stat || user.restrained() || user.lying_angle)
		return

	if(get_dist(user, src) > 1 || get_dist(src, A) > 1)
		return

	if(istype(A, /obj/item))
		var/obj/item/I = A
		stock(I, user)

/obj/machinery/vending/proc/stock(obj/item/item_to_stock, mob/user, recharge = FALSE)
	var/datum/data/vending_product/R //Let's try with a new datum.
	//More accurate comparison between absolute paths.
	for(R in (product_records + hidden_records + coin_records))
		if(item_to_stock.type == R.product_path && !istype(item_to_stock,/obj/item/storage)) //Nice try, specialists/engis
			if(istype(item_to_stock, /obj/item/weapon/gun))
				var/obj/item/weapon/gun/G = item_to_stock
				if(G.in_chamber || (G.current_mag && !istype(G.current_mag, /obj/item/ammo_magazine/internal)) || (istype(G.current_mag, /obj/item/ammo_magazine/internal) && G.current_mag.current_rounds > 0) )
					to_chat(user, "<span class='warning'>[G] is still loaded. Unload it before you can restock it.</span>")
					return
				for(var/obj/item/attachable/A in G.contents) //Search for attachments on the gun. This is the easier method
					if((A.flags_attach_features & ATTACH_REMOVABLE) && !(is_type_in_list(A, G.starting_attachment_types))) //There are attachments that are default and others that can't be removed
						to_chat(user, "<span class='warning'>[G] has non-standard attachments equipped. Detach them before you can restock it.</span>")
						return

			else if(istype(item_to_stock, /obj/item/ammo_magazine))
				var/obj/item/ammo_magazine/A = item_to_stock
				if(A.current_rounds < A.max_rounds)
					to_chat(user, "<span class='warning'>[A] isn't full. Fill it before you can restock it.</span>")
					return
			else if(istype(item_to_stock, /obj/item/smartgun_powerpack))
				var/obj/item/smartgun_powerpack/P = item_to_stock
				if(!P.pcell)
					to_chat(user, "<span class='warning'>The [P] doesn't have a cell. You must put one in before you can restock it.</span>")
					return
				if(P.pcell.charge < P.pcell.maxcharge)
					to_chat(user, "<span class='warning'>The [P] cell isn't full. You must recharge it before you can restock it.</span>")
					return
			if(item_to_stock.loc == user) //Inside the mob's inventory
				if(item_to_stock.flags_item & WIELDED)
					item_to_stock.unwield(user)
				user.temporarilyRemoveItemFromInventory(item_to_stock)

			if(istype(item_to_stock.loc, /obj/item/storage)) //inside a storage item
				var/obj/item/storage/S = item_to_stock.loc
				S.remove_from_storage(item_to_stock, user.loc)

			qdel(item_to_stock)
			if(!recharge)
				user.visible_message("<span class='notice'>[user] stocks [src] with \a [R.product_name].</span>",
				"<span class='notice'>You stock [src] with \a [R.product_name].</span>")
			R.amount++
			updateUsrDialog()
			return //We found our item, no reason to go on.

/obj/machinery/vending/process()
	if(machine_stat & (BROKEN|NOPOWER))
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

/obj/machinery/vending/proc/speak(message)
	if(machine_stat & NOPOWER)
		return

	if (!message)
		return

	visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"</span>")

/obj/machinery/vending/update_icon()
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else if( !(machine_stat & NOPOWER) )
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

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

	machine_stat |= BROKEN
	src.icon_state = "[initial(icon_state)]-broken"

//Somebody cut an important wire and now we're following a new definition of "pitch."
/obj/machinery/vending/proc/throw_item()
	var/obj/throw_item = null
	var/mob/living/target = locate() in view(7,src)
	if(!target)
		return FALSE

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
		return FALSE
	spawn(0)
		throw_item.throw_at(target, 16, 3, src)
	src.visible_message("<span class='warning'>[src] launches [throw_item.name] at [target]!</span>")
	. = TRUE


/obj/machinery/vending/take_damage(dam)
	if(density && dam >= knockdown_threshold)
		tip_over()
	return ..()
