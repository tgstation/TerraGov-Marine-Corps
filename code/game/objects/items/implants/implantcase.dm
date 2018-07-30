//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/implantcase
	name = "Glass Case"
	desc = "A case containing an implant."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/obj/item/implant/imp = null

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
		if (user.get_active_hand() != I)
			return
		if((!in_range(src, usr) && src.loc != user))
			return
		if(t)
			src.name = text("Glass Case - '[]'", t)
		else
			src.name = "Glass Case"
	else if(istype(I, /obj/item/reagent_container/syringe))
		if(!src.imp)	return
		if(!src.imp.allow_reagents)	return
		if(src.imp.reagents.total_volume >= src.imp.reagents.maximum_volume)
			user << "\red [src] is full."
		else
			spawn(5)
				I.reagents.trans_to(src.imp, 5)
				user << "\blue You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units."
	else if (istype(I, /obj/item/implanter))
		var/obj/item/implanter/M = I
		if (M.imp)
			if ((src.imp || M.imp.implanted))
				return
			M.imp.loc = src
			src.imp = M.imp
			M.imp = null
			src.update()
			M.update()
		else
			if (src.imp)
				if (M.imp)
					return
				src.imp.loc = M
				M.imp = src.imp
				src.imp = null
				update()
			M.update()
	return


/obj/item/implantcase/tracking
	name = "Glass Case - 'Tracking'"
	desc = "A case containing a tracking implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/tracking/New()
	src.imp = new /obj/item/implant/tracking( src )
	..()
	return


/obj/item/implantcase/explosive
	name = "Glass Case - 'Explosive'"
	desc = "A case containing an explosive implant."
	icon_state = "implantcase-r"

/obj/item/implantcase/explosive/New()
	src.imp = new /obj/item/implant/explosive( src )
	..()
	return


/obj/item/implantcase/chem
	name = "Glass Case - 'Chem'"
	desc = "A case containing a chemical implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/chem/New()
	src.imp = new /obj/item/implant/chem( src )
	..()
	return


/obj/item/implantcase/loyalty
	name = "Glass Case - 'W-Y'"
	desc = "A case containing a W-Y implant."
	icon_state = "implantcase-r"

/obj/item/implantcase/loyalty/New()
	src.imp = new /obj/item/implant/loyalty( src )
	..()
	return


/obj/item/implantcase/death_alarm
	name = "Glass Case - 'Death Alarm'"
	desc = "A case containing a death alarm implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/death_alarm/New()
	src.imp = new /obj/item/implant/death_alarm( src )
	..()
	return


/obj/item/implantcase/freedom
	name = "Glass Case - 'Freedom'"
	desc = "A case containing a freedom implant."
	icon_state = "implantcase-r"

/obj/item/implantcase/freedom/New()
	src.imp = new /obj/item/implant/freedom( src )
	..()
	return


/obj/item/implantcase/adrenalin
	name = "Glass Case - 'Adrenalin'"
	desc = "A case containing an adrenalin implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/adrenalin/New()
	src.imp = new /obj/item/implant/adrenalin( src )
	..()
	return


/obj/item/implantcase/dexplosive
	name = "Glass Case - 'Explosive'"
	desc = "A case containing an explosive."
	icon_state = "implantcase-r"

/obj/item/implantcase/dexplosive/New()
	src.imp = new /obj/item/implant/dexplosive( src )
	..()
	return


/obj/item/implantcase/health
	name = "Glass Case - 'Health'"
	desc = "A case containing a health tracking implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/health/New()
	src.imp = new /obj/item/implant/health( src )
	..()
	return
