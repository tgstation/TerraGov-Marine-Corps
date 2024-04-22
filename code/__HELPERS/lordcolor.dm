GLOBAL_LIST_EMPTY(lordcolor)

GLOBAL_VAR(lordprimary)
GLOBAL_VAR(lordsecondary)

/obj/proc/lordcolor(primary,secondary)
	color = primary

/obj/item/clothing/cloak/lordcolor(primary,secondary)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_cloak()


/turf/proc/lordcolor(primary,secondary)
	color = primary

/mob/proc/lord_color_choice()
	if(!client)
		addtimer(CALLBACK(src, PROC_REF(lord_color_choice)), 50)
		return
	var/list/lordcolors = list(
"PURPLE"="#865c9c",
"RED"="#933030",
"BLACK"="#2f352f",
"BROWN"="#685542",
"GREEN"="#79763f",
"BLUE"="#395480",
"YELLOW"="#b5b004",
"TEAL"="#249589",
"WHITE"="#ffffff",
"ORANGE"="#b86f0c",
"MAJENTA"="#962e5c")
	var/prim
	var/sec
	var/choice = input(src, "Choose a Primary Color", "ROGUETOWN") as anything in lordcolors
	if(choice)
		prim = lordcolors[choice]
		lordcolors -= choice
	choice = input(src, "Choose a Secondary Color", "ROGUETOWN") as anything in lordcolors
	if(choice)
		sec = lordcolors[choice]
	if(!prim || !sec)
		GLOB.lordcolor = list()
		return
	GLOB.lordprimary = prim
	GLOB.lordsecondary = sec
	for(var/obj/O in GLOB.lordcolor)
		O.lordcolor(prim,sec)
		GLOB.lordcolor -= O
	for(var/turf/T in GLOB.lordcolor)
		T.lordcolor(prim,sec)
		GLOB.lordcolor -= T