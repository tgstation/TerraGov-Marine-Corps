// =================== CONTRACTS SYSTEM ===================

// trying to make ui but i am too unskilled at ui
// /mob/living/carbon/human/verb/open_simple_ui()
// 	set name = "Simple UI Test"
// 	set category = "IC.Contracts"

// 	if(!ishuman(src))
// 		return

// 	var/datum/simple_contracts_ui/ui = new(src)
// 	ui.ui_interact(src)

/mob/living/carbon/human/verb/create_contract()
	set name = "Create Contract"
	set category = "IC.Contracts"

	if(!ishuman(src))
		return

	var/choosename = input(src, "Choose a name for the contract") as text|null
	var/choosedesc = input(src, "Choose a description for the contract") as text|null
	var/chooseprice = input(src, "Choose a price for the contract") as num|null
	if(chooseprice <= 0)
		return // проверка на валидность
	create_contract_pr(choosename, choosedesc, chooseprice)
	return

/mob/living/carbon/human/proc/create_contract_pr(var/newname = "none", var/newdesc = "none", var/newprice = "none")
	if (!ishuman(src))
		return

	var/mob/living/carbon/human/H = src

	GLOB.custom_contracts_names += newname
	GLOB.custom_contracts[newname] = list(H, newdesc, newprice) // owner, ownership_percentage, company_points

	to_chat(usr, "<big>Contract [newname] has been created.</big>")
	return

/// Check all company points (for debugging)
/mob/living/carbon/human/verb/check_all_contracts()
	set name = "Check All Contracts"
	set category = "IC.Contracts"

	to_chat(src, span_notice("=== Contracts Info ==="))
	for(var/contract_name in GLOB.custom_contracts)
		var/contract_data = GLOB.custom_contracts[contract_name]

		to_chat(src, span_info("<b>[contract_name]<b>"))
		to_chat(src, span_info("Owner: [contract_data[1].real_name] | Description: [contract_data[2]] | Price: [contract_data[3]]"))
