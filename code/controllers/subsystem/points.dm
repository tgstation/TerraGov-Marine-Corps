// points per minute
#define DROPSHIP_POINT_RATE 18
#define SUPPLY_POINT_RATE 4

#define POINTS_PER_SLIP 1
#define POINTS_PER_PHORON 20
#define POINTS_PER_CRATE 5
#define POINTS_PER_PLATINUM 40

SUBSYSTEM_DEF(points)
	name = "Points"

	priority = FIRE_PRIORITY_POINTS
	flags = SS_KEEP_TIMING | SS_NO_TICK_CHECK

	wait = 10 SECONDS

	var/dropship_points = 0
	var/supply_points = 120

	var/ordernum = 1					//order number given to next order

	var/list/supply_packs = list()
	var/list/supply_packs_ui = list()
	var/list/supply_packs_contents = list()
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

/datum/controller/subsystem/points/Initialize(timeofday)
	ordernum = rand(1, 9000)

	for(var/pack in subtypesof(/datum/supply_packs))
		var/datum/supply_packs/P = pack
		if(!initial(P.cost))
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
		supply_packs_contents[pack] = list("name" = P.name, "container_name" = initial(P.containertype.name), "cost" = P.cost, "hidden" = P.hidden, "contains" = containsname)

	return ..()

/datum/controller/subsystem/points/fire(resumed = FALSE)
	dropship_points += DROPSHIP_POINT_RATE / (1 MINUTES / wait)

	supply_points += SUPPLY_POINT_RATE / (1 MINUTES / wait)

/datum/controller/subsystem/points/proc/scale_supply_points(scale)
	supply_points = round(supply_points * scale)

/datum/controller/subsystem/points/proc/approve_request(datum/supply_order/O, mob/user)
	var/cost = 0
	for(var/i in O.pack)
		var/datum/supply_packs/SP = i
		cost += SP.cost
	if(cost > supply_points)
		return
	if(length(shoppinglist) >= SSshuttle.supply?.return_number_of_turfs())
		return
	requestlist -= "[O.id]"
	deniedrequests -= "[O.id]"
	approvedrequests["[O.id]"] = O
	O.authorised_by = user.real_name
	supply_points -= cost
	shoppinglist["[O.id]"] = O
	if(GLOB.directory[O.orderer_ckey])
		to_chat(GLOB.directory[O.orderer_ckey], "<span class='notice'>Your request [O.id] has been approved!</span>")

/datum/controller/subsystem/points/proc/deny_request(datum/supply_order/O)
	requestlist -= "[O.id]"
	deniedrequests["[O.id]"] = O
	O.authorised_by = "denied"
	if(GLOB.directory[O.orderer_ckey])
		to_chat(GLOB.directory[O.orderer_ckey], "<span class='notice'>Your request [O.id] has been denied!</span>")

/datum/controller/subsystem/points/proc/copy_order(datum/supply_order/O)
	var/datum/supply_order/NO = new
	NO.id = ++ordernum
	NO.orderer_ckey = O.orderer_ckey
	NO.orderer = O.orderer
	NO.orderer_rank = O.orderer_rank
	return NO

/datum/controller/subsystem/points/proc/process_cart(mob/user, list/cart)
	. = list()
	var/datum/supply_order/O = new
	O.id = ++ordernum
	O.orderer_ckey = user.ckey
	O.orderer = user.real_name
	O.pack = list()
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

/datum/controller/subsystem/points/proc/buy_cart(mob/user)
	var/cost = 0
	for(var/i in shopping_cart)
		var/datum/supply_packs/SP = supply_packs[i]
		cost += SP.cost * shopping_cart[i]
	if(cost > supply_points)
		return
	var/list/datum/supply_order/orders = process_cart(user, shopping_cart)
	for(var/i in 1 to length(orders))
		orders[i].authorised_by = user.real_name
		shoppinglist["[orders[i].id]"] = orders[i]
	supply_points -= cost
	shopping_cart.Cut()

/datum/controller/subsystem/points/proc/submit_request(mob/user, reason)
	var/list/ckey_shopping_cart = request_shopping_cart[user.ckey]
	if(!length(ckey_shopping_cart))
		return
	var/list/datum/supply_order/orders = process_cart(user, ckey_shopping_cart)
	for(var/i in 1 to length(orders))
		orders[i].reason = reason
		requestlist["[orders[i].id]"] = orders[i]
	ckey_shopping_cart.Cut()
