

/obj/item/frame/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	flags_atom = FPRINT|CONDUCT
	var/fixture_type = "tube"
	var/obj/machinery/light/newlight = null
	var/sheets_refunded = 2

/obj/item/frame/light_fixture/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/tool/wrench))
		new /obj/item/stack/sheet/metal( get_turf(src.loc), sheets_refunded )
		cdel(src)
		return
	..()

/obj/item/frame/light_fixture/proc/try_build(turf/on_wall)
	if (get_dist(on_wall,usr)>1)
		return
	var/ndir = get_dir(usr,on_wall)
	if (!(ndir in cardinal))
		return
	var/turf/loc = get_turf(usr)
	if (!istype(loc, /turf/open/floor))
		usr << "\red [src.name] cannot be placed on this spot."
		return
	usr << "Attaching [src] to the wall."
	playsound(src.loc, 'sound/machines/click.ogg', 15, 1)
	var/constrdir = usr.dir
	var/constrloc = usr.loc
	if (!do_after(usr, 30, TRUE, 5, BUSY_ICON_BUILD))
		return
	switch(fixture_type)
		if("bulb")
			newlight = new /obj/machinery/light_construct/small(constrloc)
		if("tube")
			newlight = new /obj/machinery/light_construct(constrloc)
	newlight.dir = constrdir
	newlight.fingerprints = src.fingerprints
	newlight.fingerprintshidden = src.fingerprintshidden
	newlight.fingerprintslast = src.fingerprintslast

	usr.visible_message("[usr.name] attaches [src] to the wall.", \
		"You attach [src] to the wall.")
	cdel(src)

/obj/item/frame/light_fixture/small
	name = "small light fixture frame"
	desc = "Used for building small lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-item"
	fixture_type = "bulb"
	sheets_refunded = 1