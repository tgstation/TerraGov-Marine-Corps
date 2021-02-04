/obj/vehicle/train/cargo/engine
	name = "cargo train tug"
	desc = "A ridable electric car designed for pulling cargo trolleys."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "cargo_engine"
	on = 0
	powered = 1
	locked = 0
	charge_use = 15

	var/car_limit = 3		//how many cars an engine can pull before performance degrades
	active_engines = 1
	var/obj/item/key/cargo_train/key

/obj/item/key/cargo_train
	name = "key"
	desc = "A keyring with a small steel key, and a yellow fob reading \"Choo Choo!\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "train_keys"
	w_class = WEIGHT_CLASS_TINY

/obj/vehicle/train/cargo/trolley
	name = "cargo train trolley"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "cargo_trailer"
	anchored = FALSE
	locked = 0

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/train/cargo/engine/Initialize()
	. = ..()
	cell = new /obj/item/cell/apc
	key = new()
	var/image/I = new(icon = 'icons/obj/vehicles.dmi', icon_state = "cargo_engine_overlay", layer = src.layer + 0.2) //over mobs
	overlays += I
	turn_off()	//so engine verbs are correctly set

/obj/vehicle/train/cargo/engine/Move()
	if(on && cell.charge < charge_use)
		turn_off()
		update_stats()

	if(is_train_head() && !on)
		return FALSE

	return ..()


/obj/vehicle/train/cargo/engine/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/key/cargo_train))
		if(key)
			return

		user.transferItemToLoc(I, src)
		key = I
		verbs += /obj/vehicle/train/cargo/engine/verb/remove_key


/obj/vehicle/train/cargo/update_icon()
	if(open)
		icon_state = initial(icon_state) + "_open"
	else
		icon_state = initial(icon_state)

/obj/vehicle/train/cargo/trolley/insert_cell(obj/item/cell/C, mob/living/carbon/human/H)
	return

/obj/vehicle/train/cargo/engine/insert_cell(obj/item/cell/C, mob/living/carbon/human/H)
	..()
	update_stats()

/obj/vehicle/train/cargo/engine/remove_cell(mob/living/carbon/human/H)
	..()
	update_stats()



//-------------------------------------------
// Train procs
//-------------------------------------------
/obj/vehicle/train/cargo/engine/turn_on()
	if(!key)
		return
	else
		..()
		update_stats()

		verbs -= /obj/vehicle/train/cargo/engine/verb/stop_engine
		verbs -= /obj/vehicle/train/cargo/engine/verb/start_engine

		if(on)
			verbs += /obj/vehicle/train/cargo/engine/verb/stop_engine
		else
			verbs += /obj/vehicle/train/cargo/engine/verb/start_engine

/obj/vehicle/train/cargo/engine/turn_off()
	..()

	verbs -= /obj/vehicle/train/cargo/engine/verb/stop_engine
	verbs -= /obj/vehicle/train/cargo/engine/verb/start_engine

	if(!on)
		verbs += /obj/vehicle/train/cargo/engine/verb/start_engine
	else
		verbs += /obj/vehicle/train/cargo/engine/verb/stop_engine


//-------------------------------------------
// Interaction procs
//-------------------------------------------
/obj/vehicle/train/cargo/engine/relaymove(mob/user, direction)
	if(!(user in buckled_mobs))
		return FALSE

	if(is_train_head())
		if(direction == REVERSE_DIR(dir) && tow)
			return 0
	return ..()

/obj/vehicle/train/cargo/engine/examine(mob/user)
	..()
	if(!ishuman(user))
		return
	if(get_dist(user,src) <= 1)
		to_chat(user, "The power light is [on ? "on" : "off"].\nThere are[key ? "" : " no"] keys in the ignition.")
		to_chat(user, "The charge meter reads [cell? round(cell.percent(), 0.01) : 0]%")

/obj/vehicle/train/cargo/engine/verb/start_engine()
	set name = "Start engine"
	set category = "Object"
	set src in view(1)

	if(!ishuman(usr))
		return

	if(on)
		to_chat(usr, "The engine is already running.")
		return

	turn_on()
	if (on)
		to_chat(usr, "You start [src]'s engine.")
	else
		if (cell)
			if(cell.charge < charge_use)
				to_chat(usr, "[src] is out of power.")
			else
				to_chat(usr, "[src]'s engine won't start.")
		else
			to_chat(usr, "[src]'s engine won't start.")

/obj/vehicle/train/cargo/engine/verb/stop_engine()
	set name = "Stop engine"
	set category = "Object"
	set src in view(1)

	if(!ishuman(usr))
		return

	if(!on)
		to_chat(usr, "The engine is already stopped.")
		return

	turn_off()
	if (!on)
		to_chat(usr, "You stop [src]'s engine.")

/obj/vehicle/train/cargo/engine/verb/remove_key()
	set name = "Remove key"
	set category = "Object"
	set src in view(1)

	if(!ishuman(usr))
		return

	if(!key || !(usr in buckled_mobs))
		return

	if(on)
		turn_off()

	key.loc = usr.loc
	if(!usr.get_active_held_item())
		usr.put_in_hands(key)
	key = null

	verbs -= /obj/vehicle/train/cargo/engine/verb/remove_key


//-------------------------------------------------------
// Stat update procs
//
// Update the trains stats for speed calculations.
// The longer the train, the slower it will go. car_limit
// sets the max number of cars one engine can pull at
// full speed. Adding more cars beyond this will slow the
// train proportionate to the length of the train. Adding
// more engines increases this limit by car_limit per
// engine.
//-------------------------------------------------------
/obj/vehicle/train/cargo/engine/update_car(train_length, active_engines)
	src.train_length = train_length
	src.active_engines = active_engines															//makes cargo trains 10% slower than running when not overweight

/obj/vehicle/train/cargo/trolley/update_car(train_length, active_engines)
	src.train_length = train_length
	src.active_engines = active_engines

	if(!lead && !tow)
		anchored = FALSE
	else
		anchored = TRUE
