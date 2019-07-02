/////////////////////////////////////////////
//Guest pass ////////////////////////////////
/////////////////////////////////////////////
/obj/item/card/id/guest
	name = "guest pass"
	desc = "Allows temporary access to station areas. It looks like its broken."
	icon_state = "guest"

	var/reason = "NOT SPECIFIED"

/obj/item/card/id/guest/examine(mob/user)
	..()
	to_chat(user, "This card looks like its been sitting here for some time.")

/obj/item/card/id/guest/read()
	return

/////////////////////////////////////////////
//Guest pass terminal////////////////////////
/////////////////////////////////////////////

/obj/machinery/computer/guestpass
	name = "guest pass terminal"
	icon_state = "guest"
	density = FALSE
