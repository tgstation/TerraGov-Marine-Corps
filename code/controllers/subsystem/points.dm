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

/datum/controller/subsystem/points/Initialize(timeofday)
	ordernum = rand(1, 9000)

	for(var/pack in subtypesof(/datum/supply_packs) - /datum/supply_packs/gun - /datum/supply_packs/gun_holster)
		var/datum/supply_packs/P = new pack()
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
