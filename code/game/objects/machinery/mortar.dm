//The Marine mortar, the M402 Mortar
//Works like a contemporary crew weapon mortar

/obj/machinery/deployable/mortar

	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER //So you can't hide it under corpses
	/// list of the target x and y, and the dialing we can do to them
	var/list/coords = list("name"= "", "targ_x" = 0, "targ_y" = 0, "dial_x" = 0, "dial_y" = 0)
	/// saved last three inputs that were actually used to fire a round
	var/list/last_three_inputs = list(
		"coords_one" = list("name"="Target 1", "targ_x" = 0, "targ_y" = 0, "dial_x" = 0, "dial_y" = 0),
		"coords_two" = list("name"="Target 2", "targ_x" = 0, "targ_y" = 0, "dial_x" = 0, "dial_y" = 0),
		"coords_three" = list("name"="Target 3", "targ_x" = 0, "targ_y" = 0, "dial_x" = 0, "dial_y" = 0)
		)
	var/offset_x = 0 //Automatic offset from target
	var/offset_y = 0
	var/offset_per_turfs = 10 //Number of turfs to offset from target by 1
	var/travel_time = 45 //Constant, assuming perfect parabolic trajectory. ONLY THE DELAY BEFORE INCOMING WARNING WHICH ADDS 45 TICKS
	var/busy = 0
	var/firing = 0 //Used for deconstruction and aiming sanity

	use_power = NO_POWER_USE

/obj/machinery/deployable/mortar/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(busy)
		to_chat(user, "<span class='warning'>Someone else is currently using [src].</span>")
		return
	if(firing)
		to_chat(user, "<span class='warning'>[src]'s barrel is still steaming hot. Wait a few seconds and stop firing it.</span>")
		return

	ui_interact(user)


/obj/machinery/deployable/mortar/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Mortar", name)
		ui.open()

/obj/machinery/deployable/mortar/ui_data(mob/user)
	. = list()
	.["X"] = coords["targ_x"]
	.["Y"] = coords["targ_y"]
	.["DX"] = coords["dial_x"]
	.["DY"] = coords["dial_y"]
	.["last_three_inputs"] = last_three_inputs

/obj/machinery/deployable/mortar/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	. = TRUE
	var/new_name = ""
	switch(action)
		if("change_target_x")
			coords["targ_x"] = clamp(text2num(params["target_x"]), 0, world.maxx)
		if("change_target_y")
			coords["targ_y"] = clamp(text2num(params["target_y"]), 0, world.maxy)
		if("change_dial_x")
			coords["dial_x"] = clamp(text2num(params["dial_one"]), -10, 10)
		if("change_dial_y")
			coords["dial_y"] = clamp(text2num(params["dial_two"]), -10, 10)
		if("set_saved_coord_one")
			coords = get_new_list("coords_one")
		if("set_saved_coord_two")
			coords = get_new_list("coords_two")
		if("set_saved_coord_three")
			coords = get_new_list("coords_three")
		if("change_saved_coord_one")
			new_name = params["name"]
			coords["name"] = new_name
			last_three_inputs["coords_one"] = get_new_list("coords")
		if("change_saved_coord_two")
			new_name = params["name"]
			coords["name"] = new_name
			last_three_inputs["coords_two"] = get_new_list("coords")
		if("change_saved_coord_three")
			new_name = params["name"]
			coords["name"] = new_name
			last_three_inputs["coords_three"] = get_new_list("coords")
		if("change_saved_one_name")
			new_name = params["name"]
			last_three_inputs["coords_one"]["name"] = new_name
		if("change_saved_two_name")
			new_name = params["name"]
			last_three_inputs["coords_two"]["name"] = new_name
		if("change_saved_three_name")
			new_name = params["name"]
			last_three_inputs["coords_three"]["name"] = new_name
	if((coords["targ_x"] != 0 && coords["targ_y"] != 0))
		usr.visible_message("<span class='notice'>[usr] adjusts [src]'s firing angle and distance.</span>",
		"<span class='notice'>You adjust [src]'s firing angle and distance to match the new coordinates.</span>")
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		// allows for offsetting using the dial, I had accidentally misplaced this.
		var/offset_x_max = round(abs((coords["targ_x"] + coords["dial_x"]) - x)/offset_per_turfs) //Offset of mortar shot, grows by 1 every 10 tiles travelled
		var/offset_y_max = round(abs((coords["targ_y"] + coords["dial_y"]) - y)/offset_per_turfs)
		offset_x = rand(-offset_x_max, offset_x_max)
		offset_y = rand(-offset_y_max, offset_y_max)

/**
 * this proc is used because pointers suck and references would break the saving of coordinates.
 *
 */
/obj/machinery/deployable/mortar/proc/get_new_list(str)
	. = list()
	switch(str)
		if("coords_three")
			. += last_three_inputs["coords_three"]
		if("coords_two")
			. += last_three_inputs["coords_two"]
		if("coords_one")
			. += last_three_inputs["coords_one"]
		if("coords")
			. += coords

/**
 * checks if we are entering in the exact same coordinates,
 * and does not save them again.
 */
/obj/machinery/deployable/mortar/proc/check_bombard_spam()
	var/list/temp = get_new_list("coords")
	for(var/i in temp)
		if(!(last_three_inputs["coords_one"][i] == temp[i]) && !(last_three_inputs["coords_two"][i] == temp[i]) && !(last_three_inputs["coords_three"][i] == temp[i]))
			return FALSE
	return TRUE

/obj/machinery/deployable/mortar/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/mortal_shell))
		var/obj/item/mortal_shell/mortar_shell = I

		if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
			to_chat(user, "<span class='warning'>Your programming restricts operating heavy weaponry.</span>")
			return

		if(busy)
			to_chat(user, "<span class='warning'>Someone else is currently using [src].</span>")
			return

		if(!is_ground_level(z))
			to_chat(user, "<span class='warning'>You cannot fire [src] here.</span>")
			return

		if(coords["targ_x"] == 0 && coords["targ_y"] == 0) //Mortar wasn't set
			to_chat(user, "<span class='warning'>[src] needs to be aimed first.</span>")
			return

		var/turf/selfown = locate((coords["targ_x"] + coords["dial_x"]), (coords["targ_y"] + coords["dial_y"]), z)
		if(get_dist(loc, selfown) < 7)
			to_chat(usr, "<span class='warning'>You cannot target this coordinate, it is too close to your mortar.</span>")
			return

		var/turf/T = locate(coords["targ_x"] + coords["dial_x"] + offset_x, coords["targ_y"]  + coords["dial_x"] + offset_y, z)
		if(!isturf(T))
			to_chat(user, "<span class='warning'>You cannot fire [src] to this target.</span>")
			return

		var/area/A = get_area(T)
		if(istype(A) && A.ceiling >= CEILING_UNDERGROUND)
			to_chat(user, "<span class='warning'>You cannot hit the target. It is probably underground.</span>")
			return

		user.visible_message("<span class='notice'>[user] starts loading \a [mortar_shell.name] into [src].</span>",
		"<span class='notice'>You start loading \a [mortar_shell.name] into [src].</span>")
		playsound(loc, 'sound/weapons/guns/interact/mortar_reload.ogg', 50, 1)
		busy = TRUE
		if(!do_after(user, 15, TRUE, src, BUSY_ICON_HOSTILE))
			busy = FALSE
			return

		busy = FALSE

		user.visible_message("<span class='notice'>[user] loads \a [mortar_shell.name] into [src].</span>",
		"<span class='notice'>You load \a [mortar_shell.name] into [src].</span>")
		visible_message("[icon2html(src, viewers(src))] <span class='danger'>The [name] fires!</span>")
		user.transferItemToLoc(mortar_shell, src)
		playsound(loc, 'sound/weapons/guns/fire/mortar_fire.ogg', 50, 1)
		firing = TRUE
		flick(icon_state + "_fire", src)
		mortar_shell.forceMove(src)

		var/turf/G = get_turf(src)
		G.ceiling_debris_check(2)

		for(var/mob/M in range(7))
			shake_camera(M, 3, 1)
		log_game("[key_name(user)] has fired the [src] at [AREACOORD(T)], impact in [travel_time+45] ticks")
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, T, 'sound/weapons/guns/misc/mortar_travel.ogg', 50, 1), travel_time)
		addtimer(CALLBACK(src, .proc/detonate_shell, T, mortar_shell), travel_time + 45)//This should always be 45 ticks!

	if(!istype(I, /obj/item/binoculars/tactical))
		return
	var/obj/item/binoculars/tactical/binocs = I
	playsound(src, 'sound/effects/binoctarget.ogg', 35)
	if(binocs.set_mortar(src))
		to_chat(user, "<span class='notice'>You link the mortar to the [binocs] allowing for remote targeting.</span>")
		return
	to_chat(user, "<span class='notice'>You disconnect the [binocs] from their linked mortar.")

///Proc called by tactical binoculars to send targeting information.
/obj/machinery/deployable/mortar/proc/recieve_target(turf/T, binocs, mob/user)
	coords["targ_x"] = T.x
	coords["targ_y"] = T.y
	say("Remote targeting set by [user]. COORDINATES: X:[coords["targ_x"]] Y:[coords["targ_y"]] OFFSET: X:[coords["dial_x"]] Y:[coords["dial_y"]]")
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

/obj/machinery/deployable/mortar/proc/detonate_shell(turf/target, obj/item/mortal_shell/mortar_shell)
	target.ceiling_debris_check(2)
	mortar_shell.detonate(target)
	qdel(mortar_shell)
	firing = FALSE

/obj/machinery/deployable/mortar/wrench_act(mob/living/user, obj/item/I)

	if(busy)
		to_chat(user, "<span class='warning'>Someone else is currently using [src].</span>")
		return

	if(firing)
		to_chat(user, "<span class='warning'>[src]'s barrel is still steaming hot. Wait a few seconds and stop firing it.</span>")
		return

	return ..()

//The portable mortar item
/obj/item/mortar_kit
	name = "\improper M402 mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Needs to be set down first to fire. Use 'Unique Action' to deploy."
	icon = 'icons/Marine/mortar.dmi'
	icon_state = "mortar"

	max_integrity = 200
	flags_item = IS_DEPLOYABLE|DEPLOYED_WRENCH_DISASSEMBLE

	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	w_class = WEIGHT_CLASS_BULKY //No dumping this in most backpacks. Carry it, fatso

/obj/item/mortar_kit/Initialize()
	. = ..()
	AddElement(/datum/element/deployable_item, /obj/machinery/deployable/mortar, 5 SECONDS)

/obj/item/mortar_kit/unique_action(mob/user)
	var/area/current_area = get_area(src)
	if(current_area.ceiling >= CEILING_METAL)
		to_chat(user, "<span class='warning'>You probably shouldn't deploy [src] indoors.</span>")
		return
	return ..()

/obj/item/mortal_shell
	name = "\improper 80mm mortar shell"
	desc = "An unlabeled 80mm mortar shell, probably a casing."
	icon = 'icons/Marine/mortar.dmi'
	icon_state = "mortar_ammo_cas"
	w_class = WEIGHT_CLASS_BULKY
	flags_atom = CONDUCT

/obj/item/mortal_shell/proc/detonate(turf/T)
	forceMove(T)

/obj/item/mortal_shell/he
	name = "\improper 80mm high explosive mortar shell"
	desc = "An 80mm mortar shell, loaded with a high explosive charge."
	icon_state = "mortar_ammo_he"

/obj/item/mortal_shell/he/detonate(turf/T)
	explosion(T, 1, 4, 7, 8)

/obj/item/mortal_shell/incendiary
	name = "\improper 80mm incendiary mortar shell"
	desc = "An 80mm mortar shell, loaded with a napalm charge."
	icon_state = "mortar_ammo_inc"

/obj/item/mortal_shell/incendiary/detonate(turf/T)
	explosion(T, 0, 2, 5, 7, throw_range = 0, small_animation = TRUE)
	flame_radius(3, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/obj/item/mortal_shell/smoke
	name = "\improper 80mm smoke mortar shell"
	desc = "An 80mm mortar shell, loaded with smoke dispersal agents. Can be fired at marines more-or-less safely."
	icon_state = "mortar_ammo_smk"
	var/datum/effect_system/smoke_spread/tactical/smoke

/obj/item/mortal_shell/smoke/Initialize()
	. = ..()
	smoke = new(src)

/obj/item/mortal_shell/smoke/detonate(turf/T)

	explosion(T, 0, 0, 1, 3, throw_range = 0, small_animation = TRUE)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	forceMove(T) //AAAAAAAA
	smoke.set_up(10, T, 11)
	smoke.start()
	smoke = null
	qdel(src)

/obj/item/mortal_shell/plasmaloss
	name = "\improper 80mm tangle mortar shell"
	desc = "An 80mm mortar shell, loaded with plasma-draining Tanglefoot gas. Can be fired at marines more-or-less safely."
	icon_state = "mortar_ammo_fsh"
	var/datum/effect_system/smoke_spread/plasmaloss/smoke

/obj/item/mortal_shell/plasmaloss/Initialize()
	. = ..()
	smoke = new(src)

/obj/item/mortal_shell/plasmaloss/detonate(turf/T)
	explosion(T, 0, 0, 1, 3, throw_range = 0)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	forceMove(T)
	smoke.set_up(10, T, 11)
	smoke.start()
	smoke = null
	qdel(src)

/obj/item/mortal_shell/flare
	name = "\improper 80mm flare mortar shell"
	desc = "An 80mm mortar shell, loaded with an illumination flare."
	icon_state = "mortar_ammo_flr"

/obj/item/mortal_shell/flare/detonate(turf/T)

	new /obj/item/flashlight/flare/on/illumination(T)
	playsound(T, 'sound/weapons/guns/fire/flare.ogg', 50, 1, 4)

//Special flare subtype for the illumination flare shell
//Acts like a flare, just even stronger, and set length
/obj/item/flashlight/flare/on/illumination
	name = "illumination flare"
	desc = "It's really bright, and unreachable."
	icon_state = "" //No sprite
	invisibility = INVISIBILITY_MAXIMUM //Can't be seen or found, it's "up in the sky"
	resistance_flags = RESIST_ALL
	mouse_opacity = 0
	light_range = 7 //Way brighter than most lights

/obj/item/flashlight/flare/on/illumination/Initialize()
	. = ..()
	fuel = rand(400, 500) // Half the duration of a flare, but justified since it's invincible

/obj/item/flashlight/flare/on/illumination/turn_off()

	..()
	qdel(src)

/obj/structure/closet/crate/mortar_ammo
	name = "\improper M402 mortar ammo crate"
	desc = "A crate containing live mortar shells with various payloads. DO NOT DROP. KEEP AWAY FROM FIRE SOURCES."
	icon = 'icons/Marine/mortar.dmi'
	icon_state = "closed_mortar_crate"
	icon_opened = "open_mortar_crate"
	icon_closed = "closed_mortar_crate"

/obj/structure/closet/crate/mortar_ammo/full/PopulateContents()
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/plasmaloss(src)
	new /obj/item/mortal_shell/plasmaloss(src)

/obj/structure/closet/crate/mortar_ammo/mortar_kit
	name = "\improper M402 mortar kit"
	desc = "A crate containing a basic set of a mortar and some shells, to get an engineer started."

/obj/structure/closet/crate/mortar_ammo/mortar_kit/PopulateContents()
	new /obj/item/mortar_kit(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/he(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/incendiary(src)
	new /obj/item/mortal_shell/plasmaloss(src)
	new /obj/item/mortal_shell/plasmaloss(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/binoculars/tactical/range(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
