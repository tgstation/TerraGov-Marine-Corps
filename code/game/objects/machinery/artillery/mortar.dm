//The Marine mortar, the T-50S Mortar
//Works like a contemporary crew weapon mortar

/obj/machinery/deployable/mortar
	anchored = TRUE
	density = TRUE
	coverage = 20
	layer = ABOVE_MOB_LAYER //So you can't hide it under corpses
	/// list of the target x and y, and the dialing we can do to them
	var/list/coords = list("name"= "", "targ_x" = 0, "targ_y" = 0, "dial_x" = 0, "dial_y" = 0)
	/// saved last three inputs that were actually used to fire a round
	var/list/last_three_inputs = list(
		"coords_one" = list("name"="Target 1", "targ_x" = 0, "targ_y" = 0, "dial_x" = 0, "dial_y" = 0),
		"coords_two" = list("name"="Target 2", "targ_x" = 0, "targ_y" = 0, "dial_x" = 0, "dial_y" = 0),
		"coords_three" = list("name"="Target 3", "targ_x" = 0, "targ_y" = 0, "dial_x" = 0, "dial_y" = 0)
		)
	/// Number of turfs to offset from target by 1
	var/offset_per_turfs = 15
	/// Constant spread on target
	var/spread = 1
	/// Max spread on target
	var/max_spread = 5
	var/busy = 0
	/// Used for deconstruction and aiming sanity
	var/firing = 0
	/// The fire sound of the mortar or artillery piece.
	var/fire_sound = 'sound/weapons/guns/fire/mortar_fire.ogg'
	var/reload_sound = 'sound/weapons/guns/interact/mortar_reload.ogg' // Our reload sound.
	var/fall_sound = 'sound/weapons/guns/misc/mortar_long_whistle.ogg' //The sound the shell makes when falling.
	///Minimum range to fire
	var/minimum_range = 15
	///Time it takes for the mortar to cool off to fire
	var/cool_off_time = 1 SECONDS
	///How long to wait before next shot
	var/fire_delay = 0.1 SECONDS
	///Amount of shells that can be loaded
	var/max_rounds = 1
	///List of stored ammunition items.
	var/list/obj/chamber_items = list()
	///Time to load a shell
	var/reload_time = 0.5 SECONDS
	///Amount of shells to fire if this is empty all shells in chamber items list will fire
	var/fire_amount
	///Camera to display impact shots
	var/obj/machinery/camera/artillery/impact_cam
	///Amount of shots that we need to monitor with imapct cameras
	var/current_shots = 0

	/// What type of shells can we use?
	var/list/allowed_shells = list(
		/obj/item/mortal_shell/he,
		/obj/item/mortal_shell/incendiary,
		/obj/item/mortal_shell/smoke,
		/obj/item/mortal_shell/flare,
		/obj/item/mortal_shell/plasmaloss,
	)

	use_power = NO_POWER_USE

	///Used for round stats
	var/tally_type = TALLY_MORTAR

	///Used for remote targeting by AI
	var/obj/item/ai_target_beacon/ai_targeter

	// used for keeping track of different mortars and their types for cams
	var/static/list/id_by_type = list()
	/// list of linked binoculars to the structure of the mortar, used for continuity to item
	var/list/linked_struct_binoculars

/obj/machinery/deployable/mortar/Initialize(mapload, _internal_item, deployer)
	. = ..()

	RegisterSignal(src, COMSIG_ITEM_UNDEPLOY, PROC_REF(handle_undeploy_references))
	LAZYINITLIST(linked_struct_binoculars)
	var/obj/item/mortar_kit/mortar = get_internal_item()
	for (var/obj/item/binoculars/tactical/binoc in mortar?.linked_item_binoculars)
		binoc.set_mortar(src)
	impact_cam = new
	impact_cam.forceMove(src)
	impact_cam.c_tag = "[strip_improper(name)] #[++id_by_type[type]]"

/obj/machinery/deployable/mortar/Destroy()
	QDEL_NULL(impact_cam)
	return ..()


/obj/machinery/deployable/mortar/examine(mob/user)
	. = ..()
	if(ai_targeter)
		. += span_notice("They have an AI linked targeting device on.")
	. += span_notice("Alt-Right-Click to anchor.")
	. += span_notice("Right-Click to fire the loaded shell.")

/obj/machinery/deployable/mortar/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(busy)
		to_chat(user, span_warning("Someone else is currently using [src]."))
		return

	ui_interact(user)

/obj/machinery/deployable/mortar/disassemble(mob/user)
	for(var/obj/loaded_item in chamber_items)
		chamber_items -= loaded_item
		loaded_item.forceMove(get_turf(src))
	return ..()

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
		usr.visible_message(span_notice("[usr] adjusts [src]'s firing angle and distance."),
		span_notice("You adjust [src]'s firing angle and distance to match the new coordinates."))
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

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

/obj/machinery/deployable/mortar/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(firing)
		user.balloon_alert(user, "barrel too hot—wait a while!")
		return

	if(istype(I, /obj/item/mortal_shell))
		var/obj/item/mortal_shell/mortar_shell = I

		if(length(chamber_items) >= max_rounds)
			user.balloon_alert(user, "you cannot fit more!")
			return

		if(!(I.type in allowed_shells))
			user.balloon_alert(user, "this shell doesn't fit!")
			return

		if(busy)
			user.balloon_alert(user, "someone else is using this!")
			return

		user.visible_message(span_notice("[user] starts loading \a [mortar_shell.name] into [src]."),
		span_notice("You start loading \a [mortar_shell.name] into [src]."))
		playsound(loc, reload_sound, 50, 1)
		busy = TRUE
		if(!do_after(user, reload_time, NONE, src, BUSY_ICON_HOSTILE))
			busy = FALSE
			return

		busy = FALSE

		user.visible_message(span_notice("[user] loads \a [mortar_shell.name] into [src]."),
		span_notice("You load \a [mortar_shell.name] into [src]."))
		chamber_items += mortar_shell
		user.balloon_alert(user, "right click to fire!")
		mortar_shell.forceMove(src)
		user.temporarilyRemoveItemFromInventory(mortar_shell)

	if(istype(I, /obj/item/ai_target_beacon))
		if(!length(GLOB.ai_list))
			to_chat(user, span_notice("There is no AI to associate with."))
			return

		var/mob/living/silicon/ai/AI = tgui_input_list(usr, "Which AI would you like to associate this gun with?", null, GLOB.ai_list)
		if(!AI)
			return
		to_chat(user, span_notice("You attach the [I], allowing for remote targeting."))
		to_chat(AI, span_notice("NOTICE - [src] has been linked to your systems, allowing for remote targeting. Use shift click to set a target."))
		user.transferItemToLoc(I, src)
		AI.associate_artillery(src)
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		ai_targeter = I

	if(istype(I, /obj/item/compass))
		var/obj/item/compass/compass = I
		coords["targ_x"] = compass.target_turf.x
		coords["targ_y"] = compass.target_turf.y
		say("Targeting set by [user]. COORDINATES: X:[coords["targ_x"]] Y:[coords["targ_y"]] OFFSET: X:[coords["dial_x"]] Y:[coords["dial_y"]]")
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		return TRUE

	if(!istype(I, /obj/item/binoculars/tactical))
		return
	var/obj/item/binoculars/tactical/binocs = I
	playsound(src, 'sound/effects/binoctarget.ogg', 35)
	if(binocs.set_mortar(src))
		balloon_alert(user, "linked")
		return
	balloon_alert(user, "unlinked")

///Start firing the gun on target and increase tally
/obj/machinery/deployable/mortar/proc/begin_fire(atom/target, obj/item/mortal_shell/arty_shell)
	firing = TRUE
	for(var/mob/M in GLOB.player_list)
		if(get_dist(M , src) <= 7)
			shake_camera(M, 1, 1)
	switch(tally_type)
		if(TALLY_MORTAR)
			GLOB.round_statistics.mortar_shells_fired++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "mortar_shells_fired")
		if(TALLY_HOWITZER)
			GLOB.round_statistics.howitzer_shells_fired++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "howitzer_shells_fired")
		if(TALLY_ROCKET_ARTY)
			GLOB.round_statistics.rocket_shells_fired++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "rocket_shells_fired")
	playsound(loc, fire_sound, GUN_FIRE_SOUND_VOLUME, 1)
	flick(icon_state + "_fire", src)
	var/atom/movable/projectile/shell = new /atom/movable/projectile(loc)
	var/datum/ammo/ammo = GLOB.ammo_list[arty_shell.ammo_type]
	shell.generate_bullet(ammo)
	var/shell_range = min(get_dist_euclidean(src, target), ammo.max_range)
	shell.fire_at(target, null, src, shell_range, ammo.shell_speed)

	perform_firing_visuals()

	var/fall_time = (shell_range/(ammo.shell_speed * 5)) - 0.5 SECONDS
	//prevent runtime
	if(fall_time < 0.5 SECONDS)
		fall_time = 0.5 SECONDS
	impact_cam.forceMove(get_turf(target))
	current_shots++
	addtimer(CALLBACK(src, PROC_REF(falling), target, shell), fall_time)
	addtimer(CALLBACK(src, PROC_REF(return_cam)), fall_time + 5 SECONDS)
	addtimer(VARSET_CALLBACK(src, firing, FALSE), cool_off_time)

///Proc called by tactical binoculars to send targeting information.
/obj/machinery/deployable/mortar/proc/recieve_target(turf/T, mob/user)
	coords["targ_x"] = T.x
	coords["targ_y"] = T.y
	say("Remote targeting set by [user]. COORDINATES: X:[coords["targ_x"]] Y:[coords["targ_y"]] OFFSET: X:[coords["dial_x"]] Y:[coords["dial_y"]]")
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

///perform any individual sprite-specific visuals here
/obj/machinery/deployable/mortar/proc/perform_firing_visuals()
	SHOULD_NOT_SLEEP(TRUE)
	return

///Returns the impact camera to the mortar
/obj/machinery/deployable/mortar/proc/return_cam()
	current_shots--
	if(current_shots <= 0)
		impact_cam.forceMove(src)

///Begins fall animation for projectile and plays fall sound
/obj/machinery/deployable/mortar/proc/falling(turf/T, atom/movable/projectile/shell)
	flick(shell.icon_state + "_falling", shell)
	playsound(T, fall_sound, 75, 1)

///Prompt for the AI to unlink itself.
/obj/machinery/deployable/mortar/attack_ai(mob/living/silicon/ai/user)
	if (user.linked_artillery == src && tgui_alert(usr, "This artillery piece is linked to you. Do you want to unlink yourself from it?", "Artillery Targeting", list("Yes", "No")) == "Yes")
		user.clean_artillery_refs()

///Unlinking the AI from this mortar
/obj/machinery/deployable/mortar/proc/unset_targeter()
	say("Linked AI spotter has relinquished targeting privileges. Ejecting targeting device.")
	ai_targeter.forceMove(src.loc)
	ai_targeter = null

/// Handles the continuity transfer of linked binoculars from the mortar struct to the mortar item
/obj/machinery/deployable/mortar/proc/handle_undeploy_references()
	SIGNAL_HANDLER
	var/obj/item/mortar_kit/mortar = get_internal_item()
	if(mortar)
		LAZYINITLIST(mortar.linked_item_binoculars)
		LAZYCLEARLIST(mortar.linked_item_binoculars)
		mortar.linked_item_binoculars = linked_struct_binoculars.Copy()
	UnregisterSignal(src, COMSIG_ITEM_UNDEPLOY)

/obj/machinery/deployable/mortar/attack_hand_alternate(mob/living/user)
	if(!Adjacent(user) || user.lying_angle || user.incapacitated() || !ishuman(user))
		return

	if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
		user.balloon_alert(user, "you can't operate this!")
		return

	if(firing)
		user.balloon_alert(user, "the gun is still firing!")
		return

	if(length(chamber_items) <= 0)
		user.balloon_alert(user, "there is nothing loaded!")
		return

	if(!is_ground_level(z))
		user.balloon_alert(user, "you can't fire the gun here!")
		return

	if(coords["targ_x"] == 0 && coords["targ_y"] == 0) //Mortar wasn't set
		user.balloon_alert(user, "the gun needs to be aimed first!")
		return

	var/turf/target = locate(coords["targ_x"] + coords["dial_x"], coords["targ_y"]  + coords["dial_y"], z)
	if(get_dist(loc, target) < minimum_range)
		user.balloon_alert(user, "the target is too close to the gun!")
		return
	if(!isturf(target))
		user.balloon_alert(user, "you can't fire the gun at this target!")
		return
	setDir(get_cardinal_dir(src, target))

	var/area/A = get_area(target)
	if(istype(A) && A.ceiling >= CEILING_UNDERGROUND)
		user.balloon_alert(user, "the target is underground!")
		return

	visible_message("[icon2html(src, viewers(src))] [span_danger("The [name] fires!")]")
	var/turf/location = get_turf(src)
	location.ceiling_debris_check(2)
	log_game("[key_name(user)] has fired the [src] at [AREACOORD(target)]")

	var/max_offset = round(abs((get_dist_euclidean(src,target)))/offset_per_turfs)
	var/firing_spread = max_offset + spread
	if(firing_spread > max_spread)
		firing_spread = max_spread
	var/list/turf_list = RANGE_TURFS(firing_spread, target)
	var/obj/in_chamber
	var/next_chamber_position = length(chamber_items)
	var/amount_to_fire = fire_amount
	if(!amount_to_fire)
		amount_to_fire = length(chamber_items)
	if(amount_to_fire > length(chamber_items))
		amount_to_fire = length(chamber_items)
	//Probably easier to declare and update a counter than it is to keep accessing a client and datum multiple times
	var/shells_fired = 0
	var/war_crimes_counter = 0
	for(var/i = 1 to amount_to_fire)
		var/turf/impact_turf = pick(turf_list)
		in_chamber = chamber_items[next_chamber_position]
		addtimer(CALLBACK(src, PROC_REF(begin_fire), impact_turf, in_chamber), fire_delay * i)
		next_chamber_position--
		chamber_items -= in_chamber
		if(istype(in_chamber, /obj/item/mortal_shell/howitzer/white_phos || /obj/item/mortal_shell/rocket/mlrs/gas))
			war_crimes_counter++
		shells_fired++
		QDEL_NULL(in_chamber)
	if(user.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
		personal_statistics.artillery_fired += shells_fired
		if(war_crimes_counter)
			personal_statistics.war_crimes += war_crimes_counter
	return ..()

// Artillery cameras. Together with the artillery impact hud tablet, shows a live feed of imapcts.

/obj/machinery/camera/artillery
	name = "artillery camera"
	network = list("terragovartillery")
	alpha = 0 //we shouldn't be able to see this!
	internal_light = FALSE
	c_tag = "impact camera"
	resistance_flags = RESIST_ALL

//The portable mortar item
/obj/item/mortar_kit
	name = "\improper TA-50S mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Needs to be set down first to fire. Ctrl+Click on a tile to deploy, drag the mortar's sprites to mob's sprite to undeploy."
	icon = 'icons/obj/machines/deployable/mortar.dmi'
	icon_state = "mortar"
	max_integrity = 200
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 15, BIO = 100, FIRE = 0, ACID = 0)
	item_flags = IS_DEPLOYABLE
	/// What item is this going to deploy when we put down the mortar?
	var/deployable_item = /obj/machinery/deployable/mortar
	resistance_flags = RESIST_ALL
	w_class = WEIGHT_CLASS_BULKY //No dumping this in most backpacks. Carry it, fatso
	/// list of binoculars linked to the structure of the mortar, used for continuity
	var/list/linked_item_binoculars

/obj/item/mortar_kit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, 1 SECONDS, 1 SECONDS)

/obj/item/mortar_kit/attack_self(mob/user)
	do_unique_action(user)

/obj/item/mortar_kit/unique_action(mob/user)
	var/area/current_area = get_area(src)
	if(current_area.ceiling >= CEILING_OBSTRUCTED)
		to_chat(user, span_warning("You probably shouldn't deploy [src] indoors."))
		return
	return ..()

//tadpole mounted double barrel mortar

/obj/item/mortar_kit/double
	name = "\improper TA-55DB mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Needs to be set down first to fire. This one is a double barreled mortar that can hold 2 rounds, and is usually fitted in TAVs."
	icon_state = "mortar_db"
	max_integrity = 400
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	w_class = WEIGHT_CLASS_HUGE
	deployable_item = /obj/machinery/deployable/mortar/double

/obj/machinery/deployable/mortar/double
	tally_type = TALLY_MORTAR
	reload_time = 2 SECONDS
	fire_amount = 2
	max_rounds = 2
	fire_delay = 0.5 SECONDS
	cool_off_time = 6 SECONDS
