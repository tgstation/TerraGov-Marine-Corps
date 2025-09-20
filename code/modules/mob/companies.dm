/mob/living/carbon/human/create_company()
	set name = "Create Company"
	/mob/living/carbon/human/U

	if (istype(src, /mob/living/carbon/human))
		U = src
	else

	var/choosename = input(U, "Choose a name for the company:") as text|null
	create_company_pr(choosename)

/mob/living/carbon/human/proc/create_company_pr(var/newname = "none")
	if (!ishuman(src))
		return

	var/mob/living/human/H = src

	if (newname != null && newname != "none")
		map.custom_company_nr += newname
		var/list/newnamev = list("[newname]" = list(list(H,100,0)))
		map.custom_company += newnamev
		to_chat(usr, "<big>You now own <b>100%</b> of the new company [newname].</big>")
		return
	else
		return
