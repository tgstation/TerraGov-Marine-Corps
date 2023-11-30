// points per minute
#define DROPSHIP_POINT_RATE 18 * (GLOB.current_orbit/3)
#define SUPPLY_POINT_RATE 20 * (GLOB.current_orbit/3)

SUBSYSTEM_DEF(points)
	name = "Points"

	priority = FIRE_PRIORITY_POINTS
	flags = SS_KEEP_TIMING

	wait = 10 SECONDS
	var/dropship_points = 0
	///Assoc list of supply points
	var/supply_points = list()
	///Assoc list of xeno points: xeno_points_by_hive["hivenum"]
	var/list/xeno_points_by_hive = list()

	var/ordernum = 1					//order number given to next order

	var/list/supply_packs = list()
	var/list/supply_packs_ui = list()
	var/list/supply_packs_contents = list()
	///Assoc list of item ready to be sent, categorised by faction
	var/list/shoppinglist = list()
	var/list/shopping_history = list()
	var/list/shopping_cart = list()
	var/list/export_history = list()
	var/list/requestlist = list()
	var/list/deniedrequests = list()
	var/list/approvedrequests = list()

	var/list/request_shopping_cart = list()

/datum/controller/subsystem/points/Recover()
	ordernum = SSpoints.ordernum
	supply_packs = SSpoints.supply_packs
	supply_packs_ui = SSpoints.supply_packs_ui
	supply_packs_contents = SSpoints.supply_packs_contents
	shoppinglist = SSpoints.shoppinglist
	shopping_history = SSpoints.shopping_history
	shopping_cart = SSpoints.shopping_cart
	export_history = SSpoints.export_history
	requestlist = SSpoints.requestlist
	deniedrequests = SSpoints.deniedrequests
	approvedrequests = SSpoints.approvedrequests
	request_shopping_cart = SSpoints.request_shopping_cart

/datum/controller/subsystem/points/Initialize()
	ordernum = rand(1, 9000)
	return SS_INIT_SUCCESS

/// Prepare the global supply pack list at the gamemode start
/datum/controller/subsystem/points/proc/prepare_supply_packs_list(is_human_req_only = FALSE)
	for(var/pack in subtypesof(/datum/supply_packs))
		var/datum/supply_packs/P = pack
		if(!initial(P.cost))
			continue
		if(is_human_req_only && initial(P.available_against_xeno_only))
			continue
		P = new pack()
		if(!P.contains)
			continue
		supply_packs[pack] = P
		LAZYADD(supply_packs_ui[P.group], pack)
		var/list/containsname = list()
		for(var/i in P.contains)
			var/atom/movable/path = i
			if(!path)	continue
			if(!containsname[path])
				containsname[path] = list("name" = initial(path.name), "count" = 1)
			else
				containsname[path]["count"]++
		supply_packs_contents[pack] = list("name" = P.name, "container_name" = initial(P.containertype.name), "cost" = P.cost, "contains" = containsname)

/datum/controller/subsystem/points/fire(resumed = FALSE)
	dropship_points += DROPSHIP_POINT_RATE / (1 MINUTES / wait)

	for(var/key in supply_points)
		supply_points[key] += SUPPLY_POINT_RATE / (1 MINUTES / wait)

///Add amount of psy points to the selected hive only if the gamemode support psypoints
/datum/controller/subsystem/points/proc/add_psy_points(hivenumber, amount)
	if(!CHECK_BITFIELD(SSticker.mode.flags_round_type, MODE_PSY_POINTS))
		return
	xeno_points_by_hive[hivenumber] += amount


/datum/controller/subsystem/points/proc/approve_request(datum/supply_order/O, mob/living/user)
	var/cost = 0
	for(var/i in O.pack)
		var/datum/supply_packs/SP = i
		cost += SP.cost
	if(cost > supply_points[user.faction])
		return
	var/obj/docking_port/mobile/supply_shuttle = SSshuttle.getShuttle(SHUTTLE_SUPPLY)
	if(length(shoppinglist[O.faction]) >= supply_shuttle.return_number_of_turfs())
		return
	requestlist -= "[O.id]"
	deniedrequests -= "[O.id]"
	approvedrequests["[O.id]"] = O
	O.authorised_by = user.real_name
	supply_points[user.faction] -= cost
	LAZYADDASSOCSIMPLE(shoppinglist[O.faction], "[O.id]", O)
	if(GLOB.directory[O.orderer])
		to_chat(GLOB.directory[O.orderer], span_notice("Your request [O.id] has been approved!"))
	if(GLOB.personal_statistics_list[O.orderer_ckey])
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[O.orderer_ckey]
		personal_statistics.req_points_used += cost

/datum/controller/subsystem/points/proc/deny_request(datum/supply_order/O)
	requestlist -= "[O.id]"
	deniedrequests["[O.id]"] = O
	O.authorised_by = "denied"
	if(GLOB.directory[O.orderer])
		to_chat(GLOB.directory[O.orderer], span_notice("Your request [O.id] has been denied!"))

/datum/controller/subsystem/points/proc/copy_order(datum/supply_order/O)
	var/datum/supply_order/NO = new
	NO.id = ++ordernum
	NO.orderer_ckey = O.orderer_ckey
	NO.orderer = O.orderer
	NO.orderer_rank = O.orderer_rank
	NO.faction = O.faction
	return NO

/datum/controller/subsystem/points/proc/process_cart(mob/living/user, list/cart)
	. = list()
	var/datum/supply_order/O = new
	O.id = ++ordernum
	O.orderer_ckey = user.ckey
	O.orderer = user.real_name
	O.pack = list()
	O.faction = user.faction
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		O.orderer_rank = H.get_assignment()
	var/list/access_packs = list()
	for(var/i in cart)
		var/datum/supply_packs/SP = supply_packs[i]
		for(var/num in 1 to cart[i])
			if(SP.containertype != null)
				if(SP.access)
					LAZYADD(access_packs["[SP.access]"], SP)
				else
					O.pack += SP
				continue
			var/datum/supply_order/NO = copy_order(O)
			NO.pack = list(SP)
			. += NO

	for(var/access in access_packs)
		var/datum/supply_order/AO = copy_order(O)
		AO.pack = list()
		. += AO
		for(var/pack in access_packs[access])
			AO.pack += pack

	if(length(O.pack))
		. += O
	else
		qdel(O)

/datum/controller/subsystem/points/proc/buy_cart(mob/living/user)
	var/cost = 0
	for(var/i in shopping_cart)
		var/datum/supply_packs/SP = supply_packs[i]
		cost += SP.cost * shopping_cart[i]
	if(cost > supply_points[user.faction])
		return
	var/list/datum/supply_order/orders = process_cart(user, shopping_cart)
	for(var/i in 1 to length(orders))
		orders[i].authorised_by = user.real_name
		LAZYADDASSOCSIMPLE(shoppinglist[user.faction], "[orders[i].id]", orders[i])
	supply_points[user.faction] -= cost
	shopping_cart.Cut()

/datum/controller/subsystem/points/proc/submit_request(mob/living/user, reason)
	var/list/ckey_shopping_cart = request_shopping_cart[user.ckey]
	if(!length(ckey_shopping_cart))
		return
	if(length(ckey_shopping_cart) > 20)
		return
	if(NON_ASCII_CHECK(reason))
		return
	if(length(reason) > MAX_LENGTH_REQ_REASON)
		reason = copytext(reason, 1, MAX_LENGTH_REQ_REASON)
	var/list/datum/supply_order/orders = process_cart(user, ckey_shopping_cart)
	for(var/i in 1 to length(orders))
		orders[i].reason = reason
		requestlist["[orders[i].id]"] = orders[i]
	ckey_shopping_cart.Cut()
