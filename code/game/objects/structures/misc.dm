/obj/structure/showcase
	name = "Showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1

/obj/structure/showcase/ex_act(severity)
	switch(severity)
		if(1)
			cdel(src)
		if(2)
			if(prob(50))
				cdel(src)

/obj/structure/monorail
	name = "monorail track"
	icon = 'icons/obj/structures/structures.dmi'
	icon_state = "monorail"
	density = 0
	anchored = 1
	layer = ATMOS_PIPE_LAYER + 0.01

/obj/structure/mopbucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	anchored = 0
	pressure_resistance = 5
	flags_atom = FPRINT|OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //Shit I dunno, adding this so syringes stop runtime erroring. --NeoFite

/obj/structure/mopbucket/New()
	..()
	create_reagents(100)

/obj/structure/mopbucket/examine(mob/user)
	..()
	user << "It contains [reagents.total_volume] unit\s of water!"

/obj/structure/mopbucket/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/tool/mop))
		if(reagents.total_volume < 1)
			user << "<span class='warning'>[src] is out of water!</span>"
		else
			reagents.trans_to(I, 5)
			user << "<span class='notice'>You wet [I] in [src].</span>"
			playsound(loc, 'sound/effects/slosh.ogg', 25, 1)
