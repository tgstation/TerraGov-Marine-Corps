#define CAT_NORMAL 0
#define CAT_HIDDEN 1
#define CAT_COIN 2

#define MAKE_VENDING_RECORD_DATA(record) list(\
		"product_name" = adminscrub(record.product_name),\
		"product_color" = record.display_color,\
		"prod_price" = record.price,\
		"prod_desc" = initial(record.product_path.desc),\
		"ref" = REF(record),\
		"tab" = record.tab,\
	)

/datum/vending_product
	///Name of the product
	var/product_name = "generic"
	///Path of the item this product makes
	var/atom/product_path = null
	///How much of this product there is
	var/amount = 0
	///The price of this product if any.
	var/price = 0
	///What color it stays on the vend button, considering just nuking this.
	var/display_color = "white"
	///What category it belongs to, Normal, contraband or coin.
	var/category = CAT_NORMAL
	///Incase its a tabbed vendor what tab this belongs to.
	var/tab

/datum/vending_product/New(name, atom/typepath, product_amount, product_price, product_display_color, category = CAT_NORMAL, tab)

	product_path = typepath
	amount = product_amount
	price = product_price
	src.category = category
	src.tab = tab

	if(!name)
		product_name = initial(typepath.name)
	else
		product_name = name

	if(product_display_color)
		display_color = product_display_color
	else if(ispath(typepath, /obj/item/ammo_magazine))
		display_color = "black"
	else
		display_color = "white"

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
	interaction_flags = INTERACT_MACHINE_TGUI
	wrenchable = TRUE

	///Whether this vendor is active or not.
	var/active = TRUE
	///If the vendor is ready to vend.
	var/vend_ready = TRUE
	///How long it takes to vend an item, vend_ready is false during that.
	var/vend_delay = 10
	/// A /datum/vending_product instance of what we're paying for right now.
	var/datum/vending_product/currently_vending = null
	///If this vendor uses a global list for items.
	var/isshared = FALSE

	/*These are lists that are made null after they're used, their use is solely to fill the inventory of the vendor on Init.
	They use the following pattern in case if it doenst pertain to a tab:
	list(
		/type/path = amount,
		/type/path2 = amount2,
	)
	if you want the item to pertain to a tab you use:
	list(
		"Tab1" = list(
			/type/path = amount.
			/type/path2 = amount2,
		),
		"Tab2" = list(
			/type/path3 = amount3,
			/type/path4 = amount4,
		)
	)
	*/
	/// Normal products that are always available on the vendor.
	var/list/products = list()
	/** List of seasons whose products are added to the vendor's.
	 *	Format for each entry is SEASON_NAME = "tab name"
	 */
	var/list/seasonal_items = list()
	/// Contraband products that are only available on vendor when hacked.
	var/list/contraband = list()
	/// Premium products that are only available when using a coin to pay for it.
	var/list/premium = list()
	/// Prices for each item, list(/type/path = price), items not in the list don't have a price.
	var/list/prices = list()

	/// String of slogans separated by semicolons, optional
	var/product_slogans = ""
	///String of small ad messages in the vending screen - random chance
	var/product_ads = ""

	//These are where the vendor holds their item info with /datum/vending_product

	///list of /datum/vending_product's that are always available on the vendor
	var/list/product_records = list()
	///list of /datum/vending_product's that are available when vendor is hacked.
	var/list/hidden_records = list()
	///list of /datum/vending_product's that are available on the vendor when a coin is used.
	var/list/coin_records = list()

	var/list/slogan_list = list()
	/// small ad messages in the vending screen - random chance of popping up whenever you open it
	var/list/small_ads = list()
	///Message spoken by the vending machine when a item is vended
	var/vend_reply
	///When was last time we spoke when vending
	var/last_reply = 0
	///Last time we spoke our slogan
	var/last_slogan = 0
	///The interval between slogans.
	var/slogan_delay = 1 MINUTES
	///Icon state when successfuly vending
	var/icon_vend
	///Icon state when failing to vend, be it by no access or money.
	var/icon_deny
	///how many seconds(duh) we have left electrified.
	var/seconds_electrified = 0
	///If we should fire items at customers! We're broken!
	var/shoot_inventory = FALSE
	///If true the machine won't be speaking slogans randomly. Stop spouting those godawful pitches!
	var/shut_up = FALSE
	///If the vending machine is hacked, makes the items on contraband list available.
	var/extended_inventory = FALSE
	///Whatever coin we have inside, should totally be replaced by something else.
	var/obj/item/coin/coin
	///What type of token we support.
	var/tokensupport = TOKEN_GENERAL

	/// 1 = requires PIN and checks accounts.  0 = You slide an ID, it vends, SPACE COMMUNISM!
	var/check_accounts = 0
	///Current cash card.
	var/obj/item/spacecash/ewallet/ewallet
	///How much tipped we are.
	var/tipped_level = 0
	///Stops the machine from being hacked to shoot inventory or allow all access
	var/hacking_safety = FALSE

	var/scan_id = TRUE

	/// How much damage we can take before tipping over.
	var/knockdown_threshold = 100


/obj/machinery/vending/Initialize(mapload, ...)
	. = ..()
	wires = new /datum/wires/vending(src)
	slogan_list = text2list(product_slogans, ";")

	// So not all machines speak at the exact same time.
	// The first time this machine says something will be at slogantime + this random value,
	// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
	last_slogan = world.time + rand(0, slogan_delay)

	build_seasonal_tabs()

	if(isshared)
		build_shared_inventory()
	else
		build_inventory(products)
		build_inventory(contraband, CAT_HIDDEN)
		build_inventory(premium, CAT_COIN)

	// we won't use these anymore so we can just null them
	premium = null
	products = null
	contraband = null
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
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)
		if(EXPLODE_LIGHT)
			if(prob(25))
				INVOKE_ASYNC(src, .proc/malfunction)

/**
 * Builds shared vendors inventory
 * the first vendor that calls this uses build_inventory and makes their records in GLOB.vending_records[type] or premium or contraband, etc.
 * the rest of vendors of same type just set all their records to the respective global lists
 */
/obj/machinery/vending/proc/build_shared_inventory()
	if(!GLOB.vending_records[type])
		build_inventory(products)
		GLOB.vending_records[type] = product_records
	else
		product_records = GLOB.vending_records[type]

	if(!GLOB.vending_hidden_records[type])
		build_inventory(contraband, CAT_HIDDEN)
		GLOB.vending_hidden_records[type] = hidden_records
	else
		hidden_records = GLOB.vending_hidden_records[type]

	if(!GLOB.vending_coin_records[type])
		build_inventory(premium, CAT_COIN)
		GLOB.vending_coin_records[type] = coin_records
	else
		coin_records = GLOB.vending_coin_records[type]

///Builds a vending machine inventory from the given list into their records depending of category.
/obj/machinery/vending/proc/build_inventory(list/productlist, category = CAT_NORMAL)
	var/list/recordlist = product_records
	if(category == CAT_HIDDEN)
		recordlist = hidden_records
	if(category == CAT_COIN)
		recordlist = coin_records

	for(var/entry in productlist)
		//if this is true then this is supposed to be tab dependant.
		if(islist(productlist[entry]))
			for(var/typepath in productlist[entry])
				var/amount = productlist[entry][typepath]
				if(isnull(amount))
					amount = 1
				var/datum/vending_product/record = new(typepath = typepath, product_amount = amount, product_price = prices[typepath], category = category, tab = entry)
				recordlist += record
			continue
		//This item is not tab dependent
		var/amount = productlist[entry]
		if(isnull(amount))
			amount = 1
		var/datum/vending_product/record = new(typepath = entry, product_amount = amount, product_price = prices[entry], category = category)
		recordlist += record

///Makes additional tabs/adds to the tabs based on the seasonal_items vendor specification
/obj/machinery/vending/proc/build_seasonal_tabs()
	for(var/season in seasonal_items)
		products[seasonal_items[season]] += SSpersistence.season_items[season]

/obj/machinery/vending/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(tipped_level)
		to_chat(X, "<span class='warning'>There's no reason to bother with that old piece of trash.</span>")
		return FALSE

	if(X.a_intent == INTENT_HARM)
		X.do_attack_animation(src, ATTACK_EFFECT_SMASH)
		if(prob(X.xeno_caste.melee_damage))
			playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
			X.visible_message("<span class='danger'>\The [X] smashes \the [src] beyond recognition!</span>", \
			"<span class='danger'>We enter a frenzy and smash \the [src] apart!</span>", null, 5)
			malfunction()
			return TRUE
		else
			X.visible_message("<span class='danger'>[X] slashes \the [src]!</span>", \
			"<span class='danger'>We slash \the [src]!</span>", null, 5)
			playsound(loc, 'sound/effects/metalhit.ogg', 25, 1)
		return TRUE

	X.visible_message("<span class='warning'>\The [X] begins to lean against \the [src].</span>", \
	"<span class='warning'>You begin to lean against \the [src].</span>", null, 5)
	tipped_level = 1
	var/shove_time = 1 SECONDS
	if(X.mob_size == MOB_SIZE_BIG)
		shove_time = 5 SECONDS
	if(istype(X,/mob/living/carbon/xenomorph/crusher))
		shove_time = 1.5 SECONDS
	if(do_after(X, shove_time, FALSE, src, BUSY_ICON_HOSTILE))
		X.visible_message("<span class='danger'>\The [X] knocks \the [src] down!</span>", \
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

/obj/machinery/vending/proc/flip_back()
	icon_state = initial(icon_state)
	tipped_level = 0
	density = TRUE
	var/matrix/A = matrix()
	transform = A

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

	else if(istype(I, /obj/item))
		var/obj/item/to_stock = I
		stock(to_stock, user)

/obj/machinery/vending/proc/scan_card(obj/item/card/I)
	if(!currently_vending)
		return
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
	vend(currently_vending, usr)
	currently_vending = null

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

/**
 * Used only when vendor is tipped to put it back up
 * Normal usage is in ui_interact
 */
/obj/machinery/vending/interact(mob/user)
	. = ..()
	if(.) // Handled by ui_interact
		return
	if(tipped_level != 2) // only fix when fully tipped
		return

	if(!iscarbon(user)) // AI can't heave remotely
		return
	user.visible_message("<span class='notice'> [user] begins to heave the vending machine back into place!</span>","<span class='notice'> You start heaving the vending machine back into place..</span>")
	if(!do_after(user, 80, FALSE, src, BUSY_ICON_FRIENDLY))
		return FALSE
	user.visible_message("<span class='notice'> [user] rights the [src]!</span>","<span class='notice'> You right the [src]!</span>")
	flip_back()
	return TRUE

/obj/machinery/vending/ui_interact(mob/user, datum/tgui/ui)
	if(tipped_level != 0) // Don't show when tipped or being tipped
		return

	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "Vending", name)
		ui.open()

/obj/machinery/vending/ui_static_data(mob/user)
	. = list()
	.["vendor_name"] = name
	.["displayed_records"] = list()
	.["hidden_records"] = list()
	.["coin_records"] = list()
	.["tabs"] = list()

	for(var/datum/vending_product/R AS in product_records)
		if(R.tab && !(R.tab in .["tabs"]))
			.["tabs"] += R.tab
		.["displayed_records"] += list(MAKE_VENDING_RECORD_DATA(R))

	for(var/datum/vending_product/R AS in hidden_records)
		if(R.tab && !(R.tab in .["tabs"]))
			.["tabs"] += R.tab
		.["hidden_records"] += list(MAKE_VENDING_RECORD_DATA(R))

	for(var/datum/vending_product/R AS in coin_records)
		if(R.tab && !(R.tab in .["tabs"]))
			.["tabs"] += R.tab
		.["coin_records"] += list(MAKE_VENDING_RECORD_DATA(R))

/obj/machinery/vending/ui_data(mob/user)
	. = list()
	.["stock"] = list()

	for(var/datum/vending_product/R AS in product_records + hidden_records + coin_records)
		.["stock"][R.product_name] = R.amount

	if(currently_vending)
		.["currently_vending"] = MAKE_VENDING_RECORD_DATA(currently_vending)
	.["extended"] = extended_inventory
	.["coin"] = coin ? coin.name : null
	.["isshared"] = isshared

/obj/machinery/vending/ui_act(action, list/params)
	. = ..()
	if(.)
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

			var/datum/vending_product/R = locate(params["vend"]) in product_records | hidden_records | coin_records
			if(!istype(R) || !R.product_path || R.amount == 0)
				return

			if(R.price == null)
				vend(R, usr)
			else
				currently_vending = R
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

/obj/machinery/vending/proc/vend(datum/vending_product/R, mob/user)
	if(!allowed(user) && (!wires.is_cut(WIRE_IDSCAN) || hacking_safety)) //For SECURE VENDING MACHINES YEAH
		to_chat(user, "<span class='warning'>Access denied.</span>")
		flick(src.icon_deny,src)
		return

	if(R.category == CAT_HIDDEN && !extended_inventory)
		return

	if(R.category == CAT_COIN)
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

	var/obj/item/new_item = release_item(R, vend_delay)
	if(istype(new_item))
		user.put_in_any_hand_if_possible(new_item, warning = FALSE)
	vend_ready = 1
	updateUsrDialog()

/obj/machinery/vending/proc/release_item(datum/vending_product/R, delay_vending = 0, dump_product = 0)
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
	SSblackbox.record_feedback("tally", "vendored", 1, R.product_name)
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
	//More accurate comparison between absolute paths.
	for(var/datum/vending_product/R AS in product_records + hidden_records + coin_records)
		if(item_to_stock.type != R.product_path || istype(item_to_stock, /obj/item/storage)) //Nice try, specialists/engis
			continue
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
		else if(istype(item_to_stock, /obj/item/cell))
			var/obj/item/cell/cell = item_to_stock
			if(cell.charge < cell.maxcharge)
				to_chat(user, "<span class='warning'>\The [cell] isn't full. You must recharge it before you can restock it.</span>")
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
		if(R.amount >= 0) //R negative means infinite item, no need to restock
			R.amount++
		updateUsrDialog()
		return //We found our item, no reason to go on.

/obj/machinery/vending/process()
	if(machine_stat & (BROKEN|NOPOWER))
		return

	if(!active)
		return

	if(seconds_electrified > 0)
		seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(((last_slogan + slogan_delay) <= world.time) && (slogan_list.len > 0) && (!shut_up) && prob(5))
		var/slogan = pick(slogan_list)
		speak(slogan)
		last_slogan = world.time

	if(shoot_inventory && prob(2) && !hacking_safety)
		throw_item()

/obj/machinery/vending/proc/speak(message)
	if(machine_stat & NOPOWER)
		return

	if (!message)
		return

	say(message)

/obj/machinery/vending/update_icon()
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else if( !(machine_stat & NOPOWER) )
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

//Oh no we're malfunctioning!  Dump out some product and break.
/obj/machinery/vending/proc/malfunction()
	for(var/datum/vending_product/R AS in product_records)
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

	for(var/datum/vending_product/R AS in product_records)
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
