

/obj/item/frame/light_fixture
	name = "light fixture frame"
	desc = "Used for building lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "tube-construct-item"
	flags_atom = CONDUCT
	var/fixture_type = "tube"
	var/sheets_refunded = 2

/obj/item/frame/light_fixture/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswrench(I))
		new /obj/item/stack/sheet/metal(loc, sheets_refunded)
		qdel(src)

/obj/item/frame/light_fixture/proc/try_build(turf/on_wall, mob/user)
	if(get_dist(on_wall, user) > 1)
		return
	var/ndir = get_dir(user, on_wall)
	if(!(ndir in GLOB.cardinals))
		return
	var/turf/loc = get_turf(user)
	if(!isfloorturf(loc))
		loc.balloon_alert(user, "bad spot")
		return

	user.balloon_alert_to_viewers("attaching")
	playsound(src.loc, 'sound/machines/click.ogg', 15, 1)
	var/constrdir = user.dir
	var/constrloc = user.loc
	if(!do_after(user, 30, NONE, on_wall, BUSY_ICON_BUILD))
		return

	var/obj/machinery/light/newlight
	switch(fixture_type)
		if("bulb")
			newlight = new /obj/machinery/light_construct/small(constrloc)
		if("tube")
			newlight = new /obj/machinery/light_construct(constrloc)
	newlight.setDir(constrdir)

	user.visible_message("[user.name] attaches [src] to the wall.", \
		"You attach [src] to the wall.")
	qdel(src)

/obj/item/frame/light_fixture/small
	name = "small light fixture frame"
	desc = "Used for building small lights."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb-construct-item"
	fixture_type = "bulb"
	sheets_refunded = 1
