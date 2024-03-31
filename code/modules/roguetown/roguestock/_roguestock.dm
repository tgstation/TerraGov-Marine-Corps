/datum/roguestock
	var/name = ""
	var/desc = ""
	var/item_type = null
	var/held_items = 0
	var/payout_price = 1
	var/withdraw_price = 1
	var/withdraw_disabled = FALSE
	var/demand = 100
	//v may send it to a place instead like treasures to horde. If false, will increment held_items and delete the item instead
	var/transport_item = FALSE
	//SStreasury.queens_tax is used in getting import price
	var/export_price = 1
	//how many of the items are consumed/spawned when exporting/importing
	var/importexport_amt = 10
	var/import_only = FALSE //for importing crackers, etc
	var/stable_price = FALSE
	var/percent_bounty = FALSE

/datum/roguestock/New()
	..()
	if(!stable_price)
		demand = rand(60,140)
	return

/datum/roguestock/proc/get_payout_price(obj/item/I) //treasures modify this based on the price of the treasure
//	var/taxes = SStreasury.tax_value
//	var/taxed_amount = round(payout_price * taxes)
//	taxed_amount = max(payout_price - taxed_amount, 0)
//	return taxed_amount
	return payout_price

/datum/roguestock/proc/check_item(obj/item/I) //for checking monster heads if they belong to monsters and other stuff
	if(import_only) //so you can't submit crackers to stockpile
		return FALSE
	return TRUE

/datum/roguestock/proc/get_export_price()
	var/taxed_amount = round((export_price*importexport_amt) * (demand/100))
	taxed_amount = taxed_amount - round(SStreasury.queens_tax*taxed_amount)
	return max(taxed_amount, 0)

/datum/roguestock/proc/get_import_price()
	var/taxed_amount = round((export_price*importexport_amt) * (demand/100))
	taxed_amount = taxed_amount + round(SStreasury.queens_tax*taxed_amount)
	return max(taxed_amount, 5)

/datum/roguestock/proc/lower_demand()
	if(stable_price)
		return
	demand = max(demand-3,10)

/datum/roguestock/proc/raise_demand()
	if(stable_price)
		return
	demand = min(demand+1,200)

/datum/roguestock/proc/demand2word()
	switch(demand)
		if(160 to 200)
			return "Scarce"
		if(130 to 160)
			return "High"
		if(110 to 130)
			return "Growing"
		if(90 to 110)
			return "Normal"
		if(70 to 90)
			return "Falling"
		if(40 to 70)
			return "Low"
		if(1 to 40)
			return "Excess"
