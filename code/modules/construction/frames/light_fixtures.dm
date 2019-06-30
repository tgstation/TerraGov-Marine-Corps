

/obj/item/frame/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	flags_atom = CONDUCT
	var/fixture_type = "tube"
	var/obj/machinery/light/newlight = null
	var/sheets_refunded = 2

/obj/item/frame/light_fixture/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		new /obj/item/stack/sheet/metal(loc, sheets_refunded)
		qdel(src)

/obj/item/frame/light_fixture/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in GLOB.cardinals))
		return
	var/turf/loc = get_turf(usr)
	if (!isfloorturf(loc))
		to_chat(usr, "<span class='warning'>[src.name] cannot be placed on this spot.</span>")
		return
	to_chat(usr, "Attaching [src] to the wall.")
	playsound(src.loc, 'sound/machines/click.ogg', 15, 1)
	var/constrdir = usr.dir
	var/constrloc = usr.loc
	if (!do_after(usr, 30, TRUE, on_wall, BUSY_ICON_BUILD))
		return
	switch(fixture_type)
		if("bulb")
			newlight = new /obj/machinery/light_construct/small(constrloc)
		if("tube")
			newlight = new /obj/machinery/light_construct(constrloc)
	newlight.setDir(constrdir)

	usr.visible_message("[usr.name] attaches [src] to the wall.", \
		"You attach [src] to the wall.")
	qdel(src)

/obj/item/frame/light_fixture/small
	name = "small light fixture frame"
	desc = "Used for building small lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-item"
	fixture_type = "bulb"
	sheets_refunded = 1