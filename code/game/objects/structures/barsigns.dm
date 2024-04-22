/obj/structure/sign/barsign // All Signs are 64 by 32 pixels, they take two tiles
	name = "bar sign"
	desc = ""
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "empty"
	req_access = list(ACCESS_BAR)
	max_integrity = 500
	integrity_failure = 0.5
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	buildable_sign = 0

	var/panel_open = FALSE
	var/datum/barsign/chosen_sign

/obj/structure/sign/barsign/Initialize()
	. = ..()
	set_sign(new /datum/barsign/hiddensigns/signoff)

/obj/structure/sign/barsign/proc/set_sign(datum/barsign/sign)
	if(!istype(sign))
		return

	icon_state = sign.icon

	if(sign.name)
		name = "[initial(name)] ([sign.name])"
	else
		name = "[initial(name)]"

	if(sign.desc)
		desc = sign.desc

	if(sign.rename_area && sign.name)
		rename_area(src, sign.name)

	return sign

/obj/structure/sign/barsign/proc/set_sign_by_name(sign_name)
	for(var/d in subtypesof(/datum/barsign))
		var/datum/barsign/D = d
		if(initial(D.name) == sign_name)
			var/new_sign = new D
			return set_sign(new_sign)

/obj/structure/sign/barsign/obj_break(damage_flag)
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		broken = TRUE
	..()

/obj/structure/sign/barsign/deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/metal(drop_location(), 2)
	new /obj/item/stack/cable_coil(drop_location(), 2)
	qdel(src)

/obj/structure/sign/barsign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src.loc, 'sound/blank.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/blank.ogg', 100, TRUE)

/obj/structure/sign/barsign/attack_ai(mob/user)
	return attack_hand(user)

/obj/structure/sign/barsign/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!allowed(user))
		to_chat(user, "<span class='info'>Access denied.</span>")
		return
	if(broken)
		to_chat(user, "<span class='danger'>The controls seem unresponsive.</span>")
		return
	pick_sign(user)

/obj/structure/sign/barsign/attackby(obj/item/I, mob/user)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(!panel_open)
			to_chat(user, "<span class='notice'>I open the maintenance panel.</span>")
			set_sign(new /datum/barsign/hiddensigns/signoff)
			panel_open = TRUE
		else
			to_chat(user, "<span class='notice'>I close the maintenance panel.</span>")
			if(!broken)
				if(!chosen_sign)
					set_sign(new /datum/barsign/hiddensigns/signoff)
				else
					set_sign(chosen_sign)
			else
				set_sign(new /datum/barsign/hiddensigns/empbarsign)
			panel_open = FALSE

	else if(istype(I, /obj/item/stack/cable_coil) && panel_open)
		var/obj/item/stack/cable_coil/C = I
		if(!broken)
			to_chat(user, "<span class='warning'>This sign is functioning properly!</span>")
			return

		if(C.use(2))
			to_chat(user, "<span class='notice'>I replace the burnt wiring.</span>")
			broken = FALSE
		else
			to_chat(user, "<span class='warning'>I need at least two lengths of cable!</span>")
	else
		return ..()


/obj/structure/sign/barsign/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	set_sign(new /datum/barsign/hiddensigns/empbarsign)
	broken = TRUE

/obj/structure/sign/barsign/emag_act(mob/user)
	if(broken)
		to_chat(user, "<span class='warning'>Nothing interesting happens!</span>")
		return
	to_chat(user, "<span class='notice'>I load an illegal barsign into the memory buffer...</span>")
	sleep(10 SECONDS)
	chosen_sign = set_sign(new /datum/barsign/hiddensigns/syndibarsign)


/obj/structure/sign/barsign/proc/pick_sign(mob/user)
	var/picked_name = input(user, "Available Signage", "Bar Sign", name) as null|anything in sortList(get_bar_names())
	if(!picked_name)
		return
	chosen_sign = set_sign_by_name(picked_name)
	SSblackbox.record_feedback("tally", "barsign_picked", 1, chosen_sign.type)

/proc/get_bar_names()
	var/list/names = list()
	for(var/d in subtypesof(/datum/barsign))
		var/datum/barsign/D = d
		if(initial(D.name) && !initial(D.hidden))
			names += initial(D.name)
	. = names

/datum/barsign
	var/name = "Name"
	var/icon = "Icon"
	var/desc = ""
	var/hidden = FALSE
	var/rename_area = TRUE

/datum/barsign/New()
	if(!desc)
		desc = ""

// Specific bar signs.

/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	icon = "maltesefalcon"
	desc = ""

/datum/barsign/thebark
	name = "The Bark"
	icon = "thebark"
	desc = ""

/datum/barsign/harmbaton
	name = "The Harmbaton"
	icon = "theharmbaton"
	desc = ""

/datum/barsign/thesingulo
	name = "The Singulo"
	icon = "thesingulo"
	desc = ""

/datum/barsign/thedrunkcarp
	name = "The Drunk Carp"
	icon = "thedrunkcarp"
	desc = ""

/datum/barsign/scotchservinwill
	name = "Scotch Servin Willy's"
	icon = "scotchservinwill"
	desc = ""

/datum/barsign/officerbeersky
	name = "Officer Beersky's"
	icon = "officerbeersky"
	desc = ""

/datum/barsign/thecavern
	name = "The Cavern"
	icon = "thecavern"
	desc = ""

/datum/barsign/theouterspess
	name = "The Outer Spess"
	icon = "theouterspess"
	desc = ""

/datum/barsign/slipperyshots
	name = "Slippery Shots"
	icon = "slipperyshots"
	desc = ""

/datum/barsign/thegreytide
	name = "The Grey Tide"
	icon = "thegreytide"
	desc = ""

/datum/barsign/honkednloaded
	name = "Honked 'n' Loaded"
	icon = "honkednloaded"
	desc = ""

/datum/barsign/thenest
	name = "The Nest"
	icon = "thenest"
	desc = ""

/datum/barsign/thecoderbus
	name = "The Coderbus"
	icon = "thecoderbus"
	desc = ""

/datum/barsign/theadminbus
	name = "The Adminbus"
	icon = "theadminbus"
	desc = ""

/datum/barsign/oldcockinn
	name = "The Old Cock Inn"
	icon = "oldcockinn"
	desc = ""

/datum/barsign/thewretchedhive
	name = "The Wretched Hive"
	icon = "thewretchedhive"
	desc = ""

/datum/barsign/robustacafe
	name = "The Robusta Cafe"
	icon = "robustacafe"
	desc = ""

/datum/barsign/emergencyrumparty
	name = "The Emergency Rum Party"
	icon = "emergencyrumparty"
	desc = ""

/datum/barsign/combocafe
	name = "The Combo Cafe"
	icon = "combocafe"
	desc = ""

/datum/barsign/vladssaladbar
	name = "Vlad's Salad Bar"
	icon = "vladssaladbar"
	desc = ""

/datum/barsign/theshaken
	name = "The Shaken"
	icon = "theshaken"
	desc = ""

/datum/barsign/thealenath
	name = "The Ale' Nath"
	icon = "thealenath"
	desc = ""

/datum/barsign/thealohasnackbar
	name = "The Aloha Snackbar"
	icon = "alohasnackbar"
	desc = ""

/datum/barsign/thenet
	name = "The Net"
	icon = "thenet"
	desc = ""

/datum/barsign/maidcafe
	name = "Maid Cafe"
	icon = "maidcafe"
	desc = ""

/datum/barsign/the_lightbulb
	name = "The Lightbulb"
	icon = "the_lightbulb"
	desc = ""

/datum/barsign/goose
	name = "The Loose Goose"
	icon = "goose"
	desc = ""

/datum/barsign/hiddensigns
	hidden = TRUE


//Hidden signs list below this point



/datum/barsign/hiddensigns/empbarsign
	name = null
	icon = "empbarsign"
	desc = ""
	rename_area = FALSE

/datum/barsign/hiddensigns/syndibarsign
	name = "Syndi Cat"
	icon = "syndibarsign"
	desc = ""

/datum/barsign/hiddensigns/signoff
	name = null
	icon = "empty"
	desc = ""
	rename_area = FALSE
