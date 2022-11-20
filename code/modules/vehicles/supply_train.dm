//handles movement
/obj/vehicle/train_engine
	name = "Train engine car"
	desc = "A supply train engine car that pulls cargo cars"
	icon =
	icon_state =
	resistance_flags = RESIST_ALL

//handles cargo, abstract
/obj/vehicle/cargo_wagon
	name = "Train cargo car"
	desc = "A supply train cargo car that is used to store and transport material resources"
	icon =
	icon_state =
	resistance_flags = RESIST_ALL

//handles loading the train
/obj/machinery/train_loader
	name = "Supply train loader"
	desc = "A loader that loads cargo cars with valuable resource materials"
	icon =
	icon_state =
	layer = BELOW_OBJ_LAYER
	verb_say = "beeps"
	verb_yell = "blares"
	anchored = FALSE
	destroy_sound = 'sound/effects/metal_crash.ogg'
	interaction_flags = INTERACT_MACHINE_DEFAULT

// handles unloading the train
/obj/structure/train_unloader
	name = "Supply train unloader"
	desc = "An unloader for unloading resource materials from a supply train cargo car"
	icon =
	icon_state =
	layer = BELOW_OBJ_LAYER
	verb_say = "beeps"
	verb_yell = "blares"
	anchored = FALSE
	destroy_sound = 'sound/effects/metal_crash.ogg'
	interaction_flags = INTERACT_MACHINE_DEFAULT

// proc to load the cargo thingies, called by loader
/obj/vehicle/cargo_wagon/proc/load()

// proc to unload the cargo thingies, called by unloader
/obj/vehicle/cargo_wagon/proc/unload()
