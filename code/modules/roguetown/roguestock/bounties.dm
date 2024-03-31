/datum/roguestock/bounty/treasure
	name = "Collectable Treasures"
	desc = "Treasures are sent to the vault, where they accrue value over time. Payout is a percentage is based on the price of the treasure, with taxes removed from the payout after."
	item_type = /obj/item
	payout_price = 10
	transport_item = /area/rogue/indoors/town/vault
	percent_bounty = TRUE

/datum/roguestock/bounty/treasure/get_payout_price(obj/item/I)
	if(!I)
		return ..()
	var/bounty_percent = (payout_price/100) * I.get_real_price()
	bounty_percent = round(bounty_percent)
	if(bounty_percent < 1)
		return 0
	return bounty_percent
//	var/taxes_amount = bounty_percent * SStreasury.tax_value
//	taxes_amount = max(bounty_percent - taxes_amount, 0)
//	if(I.submitted_to_stockpile)
//		return 0
//	return taxes_amount

/obj/item
	var/submitted_to_stockpile

/datum/roguestock/bounty/treasure/check_item(obj/item/I)
	if(!I)
		return
	if(I.get_real_price() > 0)
		if(istype(I, /obj/item/roguestatue))
			return TRUE
		if(istype(I, /obj/item/reagent_containers/glass/cup))
			return TRUE
		if(istype(I, /obj/item/roguegem))
			return TRUE
