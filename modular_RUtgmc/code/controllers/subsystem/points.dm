/datum/controller/subsystem/points
	///Assoc list of personal supply points
	var/personal_supply_points = list()
	///Personal supply points gain modifier
	var/psp_multiplier = 0.075
	///Personal supply points limit
	var/psp_limit = 600
	///Var used to calculate points difference between updates
	var/supply_points_old = 0

/datum/controller/subsystem/points/fire(resumed = FALSE)
	. = ..()

	for(var/key in supply_points)
		for(var/mob/living/account in GLOB.alive_human_list_faction[key])
			if(account.job.title in GLOB.jobs_marines)
				personal_supply_points[account.ckey] = min(personal_supply_points[account.ckey] + max(supply_points[key] - supply_points_old, 0) * psp_multiplier, psp_limit)
		supply_points_old = supply_points[key]

/datum/controller/subsystem/points/proc/buy_using_psp(mob/living/user)
	var/cost = 0
	var/list/ckey_shopping_cart = request_shopping_cart[user.ckey]
	if(!length_char(ckey_shopping_cart))
		return
	if(length_char(ckey_shopping_cart) > 20)
		return
	for(var/i in ckey_shopping_cart)
		var/datum/supply_packs/SP = supply_packs[i]
		cost += SP.cost * ckey_shopping_cart[i]
	if(cost > personal_supply_points[user.ckey])
		return
	var/list/datum/supply_order/orders = process_cart(user, ckey_shopping_cart)
	for(var/i in 1 to length_char(orders))
		orders[i].authorised_by = user.real_name
		LAZYADDASSOCSIMPLE(shoppinglist[user.faction], "[orders[i].id]", orders[i])
	personal_supply_points[user.ckey] -= cost
	ckey_shopping_cart.Cut()
