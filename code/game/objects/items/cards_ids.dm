/* Cards
* Contains:
*		DATA CARD
*		ID CARD
*		FINGERPRINT CARD HOLDER
*		FINGERPRINT CARD
*/



/*
* DATA CARDS - Used for the teleporter
*/
/obj/item/card
	name = "card"
	desc = "Does card things."
	icon = 'icons/obj/items/card.dmi'
	item_state_worn = TRUE
	w_class = WEIGHT_CLASS_TINY
	var/associated_account_number = 0

	var/list/files = list(  )

/obj/item/card/data
	name = "data disk"
	desc = "A disk of data."
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"

/obj/item/card/data/verb/label(t as text)
	set name = "Label Disk"
	set category = "Object"
	set src in usr

	if (t)
		name = text("data disk- '[]'", t)
	else
		name = "data disk"

/obj/item/card/data/clown
	name = "\proper the coordinates to clown planet"
	icon_state = "data"
	item_state = "card-id"
	layer = OBJ_LAYER
	level = 2
	desc = "This card contains coordinates to the fabled Clown Planet. Handle with care."
	function = "teleporter"
	data = "Clown Land"

/*
* ID CARDS
*/

/obj/item/card/emag_broken
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks too busted to be used for anything but salvage."
	name = "broken cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"


/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	flags_item = NOBLUDGEON


/obj/item/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access to a large array of machinery."
	icon_state = "id"
	item_state = "card-id"
	var/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
	flags_equip_slot = ITEM_SLOT_ID

	var/blood_type = "\[UNSET\]"

	///How many points you can use to buy items
	var/marine_points = list(
		CAT_MEDSUP = 0,
		CAT_MEDINJ = 0,
		CAT_ENGSUP = 0,
		CAT_LEDSUP = 0,
		CAT_
	)
	///What category of items can you buy
	var/marine_buy_flags = MARINE_CAN_BUY_ALL

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/dorm = 0		// determines if this ID has claimed a dorm already
	var/paygrade = null  // Marine's paygrade

	var/assigned_fireteam = "" //which fire team this ID belongs to, only used by squad marines.
	/// Iff bitfield to determines hit and misses
	var/iff_signal = NONE


/obj/item/card/id/Initialize()
	. = ..()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/H = loc
	blood_type = H.blood_type
	GLOB.id_card_list += src

/obj/item/card/id/Destroy()
	GLOB.id_card_list -= src
	return ..()

/obj/item/card/id/attack_self(mob/user as mob)
	user.visible_message("[user] shows you: [icon2html(src, viewers(user))] [name]: assignment: [assignment]")


/obj/item/card/id/proc/update_label(newname, newjob)
	if(newname || newjob)
		name = "[(!newname)	? "identification card"	: "[newname]'s ID Card"][(!newjob) ? "" : " ([newjob])"]"
		return

	name = "[(!registered_name)	? "identification card"	: "[registered_name]'s ID Card"][(!assignment) ? "" : " ([assignment])"]"
	if(isliving(loc))
		var/mob/living/L = loc
		L.name = L.get_visible_name()


/obj/item/card/id/verb/read()
	set name = "Read ID Card"
	set category = "Object"
	set src in usr

	to_chat(usr, "[icon2html(src, usr)] [name]: The current assignment on the card is [assignment].")
	to_chat(usr, "The blood type on the card is [blood_type].")


/obj/item/card/id/silver
	name = "identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver_id"

/obj/item/card/id/gold
	name = "identification card"
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	item_state = "gold_id"

/obj/item/card/id/syndicate
	name = "agent card"
	access = list(ACCESS_ILLEGAL_PIRATE)
	var/registered_user=null

/obj/item/card/id/syndicate/Initialize(mapload)
	. = ..()
	if(ismob(loc)) // Runtime prevention on laggy starts or where users log out because of lag at round start.
		var/mob/user = loc
		registered_name = ishuman(user) ? user.real_name : user.name
	else
		registered_name = "Agent Card"
	assignment = "Agent"
	name = "[registered_name]'s ID Card ([assignment])"


/obj/item/card/id/syndicate/attack_self(mob/user as mob)
	if(!src.registered_name)
		//Stop giving the players unsanitized unputs! You are giving ways for players to intentionally crash clients! -Nodrak
		var/newname = reject_bad_name(tgui_input_text(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name))
		if(!newname) //Same as mob/new_player/prefrences.dm
			alert("Invalid name.")
			return
		src.registered_name = newname

		var/newjob = stripped_input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Agent")
		if(!newjob)
			alert("Invalid assignment.")
			src.registered_name = ""
			return
		src.assignment = newjob
		src.name = "[src.registered_name]'s ID Card ([src.assignment])"
		to_chat(user, span_notice("You successfully forge the ID card."))
		registered_user = user
	else if(!registered_user || registered_user == user)

		if(!registered_user) registered_user = user  //

		switch(tgui_alert(user, "Would you like to display the ID, or retitle it?", "Choose.", list("Rename","Show")))
			if("Rename")
				var/newname = stripped_input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name, max_length = 26)
				if(!newname || newname == "Unknown" || newname == "floor" || newname == "wall" || newname == "r-wall") //Same as mob/new_player/prefrences.dm
					alert("Invalid name.")
					return
				src.registered_name = newname

				var/newjob = stripped_input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Assistant")
				if(!newjob)
					alert("Invalid assignment.")
					return
				src.assignment = newjob
				src.name = "[src.registered_name]'s ID Card ([src.assignment])"
				to_chat(user, span_notice("You successfully forge the ID card."))
				return
			if("Show")
				..()
	else
		..()



/obj/item/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	access = list(ACCESS_ILLEGAL_PIRATE)


/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the High Lord himself."
	icon_state = "gold"
	item_state = "gold_id"
	registered_name = CAPTAIN
	assignment = CAPTAIN
	access = ALL_MARINE_ACCESS


/obj/item/card/id/equipped(mob/living/carbon/human/H, slot)
	if(istype(H))
		H.update_inv_head() //updating marine helmet squad coloring
		H.update_inv_wear_suit()
	..()

/obj/item/card/id/dropped(mob/user)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_head() //Don't do a full update yet
		H.update_inv_wear_suit()
	..()



/obj/item/card/id/dogtag
	name = "dog tag"
	desc = "A marine dog tag."
	icon_state = "dogtag"
	item_state = "dogtag"
	iff_signal = TGMC_LOYALIST_IFF
	var/dogtag_taken = FALSE

// Vendor points for job override
/obj/item/card/id/dogtag/corpsman
	marine_points = MEDIC_TOTAL_BUY_POINTS
/obj/item/card/id/dogtag/engineer
	marine_points = ENGINEER_TOTAL_BUY_POINTS

/obj/item/card/id/dogtag/som
	name = "\improper Sons of Mars dogtag"
	desc = "Used by the Sons of Mars."
	icon_state = "dogtag_som"
	item_state = "dogtag_som"
	iff_signal = SON_OF_MARS_IFF


/obj/item/card/id/dogtag/examine(mob/user)
	. = ..()
	if(ishuman(user))
		. += span_notice("It reads \"[registered_name] - [assignment] - [blood_type]\"")


/obj/item/dogtag
	name = "information dog tag"
	desc = "A fallen marine's information dog tag."
	icon_state = "dogtag_taken"
	icon = 'icons/obj/items/card.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/fallen_names[0]
	var/fallen_assignements[0]

/obj/item/dogtag/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/dogtag))
		var/obj/item/dogtag/D = I
		to_chat(user, span_notice("You join the two tags together."))
		name = "information dog tags"
		if(D.fallen_names)
			fallen_names += D.fallen_names
		if(D.fallen_assignements)
			fallen_assignements += D.fallen_assignements
		qdel(D)
		return TRUE

/obj/item/dogtag/examine(mob/user)
	. = ..()
	if(ishuman(user) && fallen_names && fallen_names.len)
		if(fallen_names.len == 1)
			to_chat(user, span_notice("It reads: \"[fallen_names[1]] - [fallen_assignements[1]]\"."))
		else
			var/msg = "<span class='notice'> It reads: "
			for(var/x = 1 to length(fallen_names))
				if (x == length(fallen_names))
					msg += "\"[fallen_names[x]] - [fallen_assignements[x]]\""
				else
					msg += "\"[fallen_names[x]] - [fallen_assignements[x]]\", "

			msg += ".</span>"

			to_chat(user, msg)


/obj/item/card/id/vv_edit_var(var_name, var_value)
	. = ..()
	if(.)
		switch(var_name)
			if("assignment", "registered_name")
				update_label()
