
/proc/send_ooc_note(msg, name, job)
	var/list/names_to = list()
	if(name)
		names_to += name
	if(job)
		var/list/L = list()
		if(islist(job))
			L = job
		else
			L += job
		for(var/J in L)
			for(var/mob/living/carbon/human/X in GLOB.human_list)
				if(X.job == J)
					names_to |= X.real_name
	if(names_to.len)
		for(var/mob/living/carbon/human/X in GLOB.human_list)
			if(X.real_name in names_to)
				if(!X.stat)
					to_chat(X, "<span class='info'>[msg]</span>")

SUBSYSTEM_DEF(treasury)
	name = "treasury"
	wait = 1
	priority = FIRE_PRIORITY_WATER_LEVEL
	var/tax_value = 0.11
	var/queens_tax = 0.15
	var/treasury_value = 0
	var/list/bank_accounts = list()
	var/list/stockpile_datums = list()
	var/next_treasury_check = 0
	var/list/acceptable_treasure_typecache = list()
	var/list/log_entries = list()


/datum/controller/subsystem/treasury/Initialize()
	treasury_value = rand(800,1500)
	queens_tax = pick(0.09, 0.15, 0.21, 0.30)

	for(var/path in subtypesof(/datum/roguestock/bounty))
		var/datum/D = new path
		stockpile_datums += D
	for(var/path in subtypesof(/datum/roguestock/stockpile))
		var/datum/D = new path
		stockpile_datums += D
	for(var/path in subtypesof(/datum/roguestock/import))
		var/datum/D = new path
		stockpile_datums += D
	return ..()

/datum/controller/subsystem/treasury/fire(resumed = 0)
	if(world.time > next_treasury_check)
		next_treasury_check = world.time + rand(5 MINUTES, 8 MINUTES)
		if(SSticker.current_state == GAME_STATE_PLAYING)
			for(var/datum/roguestock/X in stockpile_datums)
				if(!X.stable_price && !X.transport_item)
					if(X.demand < initial(X.demand))
						X.demand += rand(5,15)
					if(X.demand > initial(X.demand))
						X.demand -= rand(5,15)
		var/area/A = GLOB.areas_by_type[/area/rogue/indoors/town/vault]
		var/amt_to_generate = 0
		for(var/obj/item/I in A)
			if(!isturf(I.loc))
				return
			if(!(I.type in acceptable_treasure_typecache))
				return
			if(I.get_real_price() <= 0)
				return
			if(!I.submitted_to_stockpile)
				I.submitted_to_stockpile = TRUE
			amt_to_generate += (I.get_real_price()*0.25)
		amt_to_generate = amt_to_generate - (amt_to_generate * queens_tax)
		amt_to_generate = round(amt_to_generate)
		give_money_treasury(amt_to_generate, "wealth horde")
		for(var/mob/living/carbon/human/X in GLOB.human_list)
			if(X.job == "King" || X.job == "Queen")
				send_ooc_note("Income from wealth horde: +[amt_to_generate]", name = X.real_name)
				return

/datum/controller/subsystem/treasury/proc/create_bank_account(name, initial_deposit)
	if(!name)
		return
	if(name in bank_accounts)
		return
	bank_accounts += name
	if(initial_deposit)
		bank_accounts[name] = initial_deposit
	else
		bank_accounts[name] = 0
	return TRUE

//increments the treasury directly (tax collection)
/datum/controller/subsystem/treasury/proc/give_money_treasury(amt, source)
	if(!amt)
		return
	treasury_value += amt
	if(source)
		log_to_steward("+[amt] to treasury ([source])")
	else
		log_to_steward("+[amt] to treasury")

//pays to account from treasury (payroll)
/datum/controller/subsystem/treasury/proc/give_money_account(amt, name, source)
	if(!amt)
		return
	if(!name)
		return
	var/found_account
	for(var/X in bank_accounts)
		if(X == name)
			bank_accounts[X] += amt
			found_account = TRUE
			break
	if(!found_account)
		return
	if(amt>0)
		if(source)
			send_ooc_note("<b>The Bank:</b> You recieved money. ([source])", name = name)
			log_to_steward("+[amt] from treasury to [name] ([source])")
		else
			send_ooc_note("<b>The Bank:</b> You recieved money.", name = name)
			log_to_steward("+[amt] from treasury to [name]")
	else
		if(source)
			send_ooc_note("<b>The Bank:</b> You were fined. ([source])", name = name)
			log_to_steward("[name] was fined [amt] ([source])")
		else
			send_ooc_note("<b>The Bank:</b> You were fined.", name = name)
			log_to_steward("[name] was fined [amt]")
	return TRUE

//increments the treasury and gives the money to the account (deposits)
/datum/controller/subsystem/treasury/proc/generate_money_account(amt, name, source)
	if(!amt)
		return
	treasury_value += amt
	var/found_account
	for(var/X in bank_accounts)
		if(X == name)
			bank_accounts[X] += amt
			found_account = TRUE
			break
	if(!found_account)
		log_to_steward("+[amt] deposited by anonymous.")
		return
	if(source)
		log_to_steward("+[amt] deposited by [name] ([source])")
	else
		log_to_steward("+[amt] deposited by [name]")
	return TRUE

/datum/controller/subsystem/treasury/proc/withdraw_money_account(amt, name)
	if(!amt)
		return
	if(treasury_value-amt < 0)
		return
	var/found_account
	for(var/X in bank_accounts)
		if(X == name)
			bank_accounts[X] -= amt
			found_account = TRUE
			break
	if(!found_account)
		return
	treasury_value -= amt
	log_to_steward("-[amt] withdrawn by [name]")
	return TRUE

/datum/controller/subsystem/treasury/proc/log_to_steward(log)
	log_entries += log
	return
