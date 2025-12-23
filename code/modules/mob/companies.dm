/mob/living/carbon/human/verb/create_company()
	set name = "Create Company"
	set category = "IC.Company"

	if(!ishuman(src))
		return

	// Check if player already has a company
	if(has_company())
		to_chat(src, span_warning("You already own a company!"))
		return

	var/choosename = input(src, "Choose a name for the company") as text|null
	create_company_pr(choosename)
	return

/mob/living/carbon/human/proc/create_company_pr(var/newname = "none")
	if (!ishuman(src))
		return

	var/mob/living/carbon/human/H = src

	if (newname != null && newname != "none")
		// Check if company name already exists
		if(newname in GLOB.custom_company_names)
			to_chat(usr, span_warning("A company with that name already exists!"))
			return

		// Add company to global lists
		GLOB.custom_company_names += newname
		GLOB.custom_companies[newname] = list(H, 100, 0) // owner, ownership_percentage, company_points

		// Initialize company points in SSpoints
		SSpoints.company_supply_points[newname] = 0
		to_chat(usr, span_info("DEBUG: Created company [newname] in SSpoints.company_supply_points"))
		to_chat(usr, span_info("DEBUG: SSpoints.company_supply_points now contains: [SSpoints.company_supply_points]"))

		to_chat(usr, "<big>You now own <b>100%</b> of the new company [newname].</big>")
		return
	else
		return

/// Get the company name that a mob owns
/mob/living/carbon/human/proc/get_company_name()
	to_chat(src, span_info("DEBUG: get_company_name() called for [src.real_name]"))
	to_chat(src, span_info("DEBUG: GLOB.custom_companies has [length(GLOB.custom_companies)] entries"))
	for(var/company_name in GLOB.custom_companies)
		var/list/company_data = GLOB.custom_companies[company_name]
		to_chat(src, span_info("DEBUG: Checking company [company_name], owner: [company_data[1]]"))
		if(company_data[1] == src) // Check if this mob is the owner
			to_chat(src, span_info("DEBUG: Found matching company: [company_name]"))
			return company_name
	to_chat(src, span_info("DEBUG: No company found for [src.real_name]"))
	return null

/// Check if a mob owns a company
/mob/living/carbon/human/proc/has_company()
	var/result = get_company_name() != null
	to_chat(src, span_info("DEBUG: has_company() = [result]"))
	return result

/// Get company points for a specific company
/proc/get_company_points(company_name)
	if(!(company_name in SSpoints.company_supply_points))
		return 0
	return SSpoints.company_supply_points[company_name]

/// Add points to a company
/proc/add_company_points(company_name, amount)
	to_chat(world, span_info("DEBUG: add_company_points called for [company_name] with amount [amount]"))
	to_chat(world, span_info("DEBUG: SSpoints.company_supply_points keys: [SSpoints.company_supply_points]"))

	if(!(company_name in SSpoints.company_supply_points))
		to_chat(world, span_info("DEBUG: Company [company_name] not found in company_supply_points!"))
		return FALSE

	to_chat(world, span_info("DEBUG: Before adding: [company_name] has [SSpoints.company_supply_points[company_name]] points"))
	SSpoints.company_supply_points[company_name] += amount
	to_chat(world, span_info("DEBUG: After adding: [company_name] has [SSpoints.company_supply_points[company_name]] points"))
	return TRUE

/// Check company balance command
/mob/living/carbon/human/verb/check_company_balance()
	set name = "Check Company Balance"
	set category = "IC.Company"

	if(!has_company())
		to_chat(src, span_warning("You don't own a company!"))
		return

	var/company_name = get_company_name()
	var/balance = get_company_points(company_name)
	to_chat(src, span_notice("Your company [company_name] has [balance] points."))

/// Check all company points (for debugging)
/mob/living/carbon/human/verb/check_all_company_points()
	set name = "Check All Company Points"
	set category = "IC.Company"

	to_chat(src, span_notice("=== Company Points ==="))
	for(var/company_name in SSpoints.company_supply_points)
		var/points = SSpoints.company_supply_points[company_name]
		to_chat(src, span_info("[company_name]: [points] points"))

/// Show company info
/mob/living/carbon/human/verb/show_company_info()
	set name = "Company Info"
	set category = "IC.Company"

	if(!has_company())
		to_chat(src, span_warning("You don't own a company! Use 'Create Company' to start one."))
		return

	var/company_name = get_company_name()
	var/balance = get_company_points(company_name)
	to_chat(src, span_notice("=== [company_name] ==="))
	to_chat(src, span_info("Owner: [src.real_name]"))
	to_chat(src, span_info("Balance: [balance] points"))
	to_chat(src, span_info("Status: Active"))
