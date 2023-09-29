/obj/structure/dispenser
	name = "tank storage unit"
	desc = "A simple yet bulky storage device for gas tanks. Has room for up to ten oxygen tanks, and ten phoron tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = TRUE
	anchored = TRUE
	coverage = 45
	var/oxygentanks = 10
	var/phorontanks = 10
	var/list/oxytanks = list()	//sorry for the similar var names
	var/list/platanks = list()


/obj/structure/dispenser/oxygen
	phorontanks = 0

/obj/structure/dispenser/phoron
	oxygentanks = 0


/obj/structure/dispenser/Initialize(mapload)
	. = ..()
	update_icon()


/obj/structure/dispenser/update_icon()
	overlays.Cut()
	switch(oxygentanks)
		if(1 to 3)	overlays += "oxygen-[oxygentanks]"
		if(4 to INFINITY) overlays += "oxygen-4"
	switch(phorontanks)
		if(1 to 4)	overlays += "phoron-[phorontanks]"
		if(5 to INFINITY) overlays += "phoron-5"

/obj/structure/dispenser/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat
	dat += "Oxygen tanks: [oxygentanks] - [oxygentanks ? "<A href='?src=[text_ref(src)];oxygen=1'>Dispense</A>" : "empty"]<br>"
	dat += "Phoron tanks: [phorontanks] - [phorontanks ? "<A href='?src=[text_ref(src)];phoron=1'>Dispense</A>" : "empty"]"

	var/datum/browser/popup = new(user, "dispense", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open()


/obj/structure/dispenser/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tank/oxygen) || istype(I, /obj/item/tank/air) || istype(I, /obj/item/tank/anesthetic))
		if(oxygentanks >= 10)
			to_chat(user, span_notice("[src] is full."))
			return

		user.drop_held_item()
		I.forceMove(src)
		oxytanks += I
		oxygentanks++
		to_chat(user, span_notice("You put [I] in [src]."))
		if(oxygentanks < 5)
			update_icon()

	else if(istype(I, /obj/item/tank/phoron))
		if(phorontanks >= 10)
			to_chat(user, span_notice("[src] is full."))
			return

		user.drop_held_item()
		I.forceMove(src)
		platanks += I
		phorontanks++
		to_chat(user, span_notice("You put [I] in [src]."))
		if(oxygentanks < 6)
			update_icon()


/obj/structure/dispenser/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["oxygen"])
		if(oxygentanks > 0)
			var/obj/item/tank/oxygen/O
			if(length(oxytanks) == oxygentanks)
				O = oxytanks[1]
				oxytanks.Remove(O)
			else
				O = new /obj/item/tank/oxygen(loc)
			O.loc = loc
			to_chat(usr, span_notice("You take [O] out of [src]."))
			oxygentanks--
			update_icon()
	if(href_list["phoron"])
		if(phorontanks > 0)
			var/obj/item/tank/phoron/P
			if(length(platanks) == phorontanks)
				P = platanks[1]
				platanks.Remove(P)
			else
				P = new /obj/item/tank/phoron(loc)
			P.loc = loc
			to_chat(usr, span_notice("You take [P] out of [src]."))
			phorontanks--
			update_icon()

	updateUsrDialog()
