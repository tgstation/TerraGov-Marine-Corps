#define SHOWCASE_CONSTRUCTED 1
#define SHOWCASE_SCREWDRIVERED 2

/*Completely generic structures for use by mappers to create fake objects, i.e. display rooms*/
/obj/structure/showcase
	name = "showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = ""
	density = TRUE
	anchored = TRUE
	var/deconstruction_state = SHOWCASE_CONSTRUCTED

/obj/structure/showcase/fakeid
	name = "\improper CentCom identification console"
	desc = ""
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"

/obj/structure/showcase/fakeid/Initialize()
	. = ..()
	add_overlay("id")
	add_overlay("id_key")

/obj/structure/showcase/fakesec
	name = "\improper CentCom security records"
	desc = ""
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"

/obj/structure/showcase/fakesec/Initialize()
	. = ..()
	add_overlay("security")
	add_overlay("security_key")

/obj/structure/showcase/horrific_experiment
	name = "horrific experiment"
	desc = ""
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_g"

/obj/structure/showcase/machinery/oldpod
	name = "damaged cryogenic pod"
	desc = ""
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper-open"

/obj/structure/showcase/machinery/oldpod/used
	name = "opened cryogenic pod"
	desc = ""

/obj/structure/showcase/cyborg/old
	name = "Cyborg Statue"
	desc = ""
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot_old"
	density = FALSE

/obj/structure/showcase/mecha/marauder
	name = "combat mech exhibit"
	desc = ""
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "marauder"

/obj/structure/showcase/mecha/ripley
	name = "construction mech exhibit"
	desc = ""
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "firefighter"

/obj/structure/showcase/machinery/implanter
	name = "Nanotrasen automated mindshield implanter exhibit"
	desc = ""
	icon = 'icons/obj/machines/implantchair.dmi'
	icon_state = "implantchair"

/obj/structure/showcase/machinery/microwave
	name = "Nanotrasen-brand microwave"
	desc = ""
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "mw"

/obj/structure/showcase/machinery/cloning_pod
	name = "cloning pod exhibit"
	desc = ""
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"

/obj/structure/showcase/perfect_employee
	name = "'Perfect Man' employee exhibit"
	desc = ""

/obj/structure/showcase/machinery/tv
	name = "Nanotrasen corporate newsfeed"
	desc = ""
	icon = 'icons/obj/computer.dmi'
	icon_state = "television"

/obj/structure/showcase/machinery/signal_decrypter
	name = "subsystem signal decrypter"
	desc = ""
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "processor"



//Deconstructing
//Showcases can be any sprite, so it makes sense that they can't be constructed.
//However if a player wants to move an existing showcase or remove one, this is for that.

/obj/structure/showcase/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER && !anchored)
		if(deconstruction_state == SHOWCASE_SCREWDRIVERED)
			to_chat(user, "<span class='notice'>I screw the screws back into the showcase.</span>")
			W.play_tool_sound(src, 100)
			deconstruction_state = SHOWCASE_CONSTRUCTED
		else if (deconstruction_state == SHOWCASE_CONSTRUCTED)
			to_chat(user, "<span class='notice'>I unscrew the screws.</span>")
			W.play_tool_sound(src, 100)
			deconstruction_state = SHOWCASE_SCREWDRIVERED

	if(W.tool_behaviour == TOOL_CROWBAR && deconstruction_state == SHOWCASE_SCREWDRIVERED)
		if(W.use_tool(src, user, 20, volume=100))
			to_chat(user, "<span class='notice'>I start to crowbar the showcase apart...</span>")
			new /obj/item/stack/sheet/metal(drop_location(), 4)
			qdel(src)

	if(deconstruction_state == SHOWCASE_CONSTRUCTED && default_unfasten_wrench(user, W))
		return

//Feedback is given in examine because showcases can basically have any sprite assigned to them

/obj/structure/showcase/examine(mob/user)
	. = ..()

	switch(deconstruction_state)
		if(SHOWCASE_CONSTRUCTED)
			. += "The showcase is fully constructed."
		if(SHOWCASE_SCREWDRIVERED)
			. += "The showcase has its screws loosened."
		else
			. += "If you see this, something is wrong."
