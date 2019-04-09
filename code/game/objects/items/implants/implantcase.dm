//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/implantcase
	name = "glass case"
	desc = "A case containing an implant."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/obj/item/implant/imp = null

/obj/item/implantcase/Initialize(mapload, ...)
	. = ..()
	if(imp)
		imp = new imp(src)
		update()

/obj/item/implantcase/proc/update()
	if (imp)
		icon_state = "implantcase-[imp.implant_color]"
	else
		icon_state = "implantcase-0"
	return

/obj/item/implantcase/attackby(obj/item/I as obj, mob/user as mob)
	..()
	if (istype(I, /obj/item/tool/pen))
		var/t = stripped_input(user, "What would you like the label to be?", text("[]", src.name), null)
		if (user.get_active_held_item() != I)
			return
		if((!in_range(src, usr) && loc != user))
			return
		if(t)
			name = text("glass case - '[]'", t)
		else
			name = "glass case"
	else if(istype(I, /obj/item/reagent_container/syringe))
		if(!imp?.allow_reagents)
			return
		if(imp.reagents.total_volume >= imp.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		else
			spawn(5)
				I.reagents.trans_to(imp, 5)
				to_chat(user, "<span class='notice'>You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units.</span>")
	else if (istype(I, /obj/item/implanter))
		var/obj/item/implanter/M = I
		if (M.imp)
			if ((imp || M.imp.implanted))
				return
			M.imp.loc = src
			imp = M.imp
			M.imp = null
			update()
			M.update()
		else
			if (imp)
				if (M.imp)
					return
				imp.loc = M
				M.imp = imp
				imp = null
				update()
			M.update()
	return


/obj/item/implantcase/tracking
	name = "glass case - 'Tracking'"
	desc = "A case containing a tracking implant."
	icon_state = "implantcase-b"
	imp = /obj/item/implant/tracking

/obj/item/implantcase/explosive
	name = "glass case - 'Explosive'"
	desc = "A case containing an explosive implant."
	icon_state = "implantcase-r"
	imp = /obj/item/implant/explosive

/obj/item/implantcase/chem
	name = "glass case - 'Chem'"
	desc = "A case containing a chemical implant."
	icon_state = "implantcase-b"
	imp = /obj/item/implant/chem

/obj/item/implantcase/loyalty
	name = "glass case - 'Loyalty'"
	desc = "A case containing a loyalty implant."
	icon_state = "implantcase-r"
	imp = /obj/item/implant/loyalty

/obj/item/implantcase/death_alarm
	name = "glass case - 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	icon_state = "implantcase-b"
	imp = /obj/item/implant/death_alarm

/obj/item/implantcase/freedom
	name = "glass case - 'Freedom'"
	desc = "A case containing a freedom implant."
	icon_state = "implantcase-r"
	imp = /obj/item/implant/freedom

/obj/item/implantcase/adrenalin
	name = "glass case - 'Adrenalin'"
	desc = "A case containing an adrenalin implant."
	icon_state = "implantcase-b"
	imp = /obj/item/implant/adrenalin

/obj/item/implantcase/dexplosive
	name = "glass case - 'Explosive'"
	desc = "A case containing an explosive."
	icon_state = "implantcase-r"
	imp = /obj/item/implant/dexplosive

/obj/item/implantcase/health
	name = "glass case - 'Health'"
	desc = "A case containing a health tracking implant."
	icon_state = "implantcase-b"
	imp = /obj/item/implant/health
