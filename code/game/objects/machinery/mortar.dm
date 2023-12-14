//The Marine mortar, the T-50S Mortar
//Works like a contemporary crew weapon mortar

//TODO SPLIT THIS FILE INTO A FOLDER BECAUSE ITS ARTY NOT MORTAR NOW

#define TALLY_MORTAR  1
#define TALLY_HOWITZER 2
#define TALLY_ROCKET_ARTY 3

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

	if(firing)
		user.balloon_alert(user, "The barrel is steaming hot. Wait till it cools off")
		return

	if(istype(I, /obj/item/mortal_shell))
		var/obj/item/mortal_shell/mortar_shell = I

		if(length(chamber_items) >= max_rounds)
			user.balloon_alert(user, "You cannot fit more")
			return

		if(!(I.type in allowed_shells))
			user.balloon_alert(user, "This shell doesn't fit")
			return

		if(busy)
			user.balloon_alert(user, "Someone else is using this")
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
		user.balloon_alert(user, "Right click to fire")
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
	playsound(loc, fire_sound, 50, 1)
	flick(icon_state + "_fire", src)
	var/obj/projectile/shell = new /obj/projectile(loc)
	var/datum/ammo/ammo = GLOB.ammo_list[arty_shell.ammo_type]
	shell.generate_bullet(ammo)
	var/shell_range = min(get_dist_euclide(src, target), ammo.max_range)
	shell.fire_at(target, src, src, shell_range, ammo.shell_speed)

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
/obj/machinery/deployable/mortar/proc/falling(turf/T, obj/projectile/shell)
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
		user.balloon_alert(user, "Your programming restricts operating this")
		return

	if(firing)
		user.balloon_alert(user, "The gun is still firing.")
		return

	if(length(chamber_items) <= 0)
		user.balloon_alert(user, "There is nothing loaded.")
		return

	if(!is_ground_level(z))
		user.balloon_alert(user, "You can't fire the gun here.")
		return

	if(coords["targ_x"] == 0 && coords["targ_y"] == 0) //Mortar wasn't set
		user.balloon_alert(user, "The gun needs to be aimed first.")
		return

	var/turf/target = locate(coords["targ_x"] + coords["dial_x"], coords["targ_y"]  + coords["dial_y"], z)
	if(get_dist(loc, target) < minimum_range)
		user.balloon_alert(user, "The target is too close to the gun.")
		return
	if(!isturf(target))
		user.balloon_alert(user, "You cannot fire the gun to this target.")
		return
	setDir(get_cardinal_dir(src, target))

	var/area/A = get_area(target)
	if(istype(A) && A.ceiling >= CEILING_UNDERGROUND)
		user.balloon_alert(user, "The target is underground.")
		return

	visible_message("[icon2html(src, viewers(src))] [span_danger("The [name] fires!")]")
	var/turf/location = get_turf(src)
	location.ceiling_debris_check(2)
	log_game("[key_name(user)] has fired the [src] at [AREACOORD(target)]")

	var/max_offset = round(abs((get_dist_euclide(src,target)))/offset_per_turfs)
	var/firing_spread = max_offset + spread
	if(firing_spread > max_spread)
		firing_spread = max_spread
	var/list/turf_list = list()
	var/obj/in_chamber
	var/next_chamber_position = length(chamber_items)
	var/amount_to_fire = fire_amount
	if(!amount_to_fire)
		amount_to_fire = length(chamber_items)
	if(amount_to_fire > length(chamber_items))
		amount_to_fire = length(chamber_items)
	for(var/turf/spread_turf in RANGE_TURFS(firing_spread, target))
		turf_list += spread_turf
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
	icon = 'icons/Marine/mortar.dmi'
	icon_state = "mortar"
	max_integrity = 200
	soft_armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 15, BIO = 100, FIRE = 0, ACID = 0)
	flags_item = IS_DEPLOYABLE
	/// What item is this going to deploy when we put down the mortar?
	var/deployable_item = /obj/machinery/deployable/mortar
	resistance_flags = RESIST_ALL
	w_class = WEIGHT_CLASS_BULKY //No dumping this in most backpacks. Carry it, fatso
	/// list of binoculars linked to the structure of the mortar, used for continuity
	var/list/linked_item_binoculars

/obj/item/mortar_kit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, 1 SECONDS)

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
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Needs to be set down first to fire. This one is a double barreled mortar that can hold 4 rounds usually fitted in TAV's."
	icon_state = "mortar_db"
	max_integrity = 400
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	w_class = WEIGHT_CLASS_HUGE
	deployable_item = /obj/machinery/deployable/mortar/double

/obj/machinery/deployable/mortar/double
	tally_type = TALLY_MORTAR
	reload_time = 2 SECONDS
	fire_amount = 2
	max_rounds = 2
	fire_delay = 0.5 SECONDS
	cool_off_time = 6 SECONDS
	spread = 2

// The big boy, the Howtizer.

/obj/item/mortar_kit/howitzer
	name = "\improper TA-100Y howitzer"
	desc = "A manual, crew-operated and towable howitzer, will rain down 150mm laserguided and accurate shells on any of your foes."
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer"
	max_integrity = 400
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	w_class = WEIGHT_CLASS_HUGE
	deployable_item = /obj/machinery/deployable/mortar/howitzer

/obj/machinery/deployable/mortar/howitzer
	pixel_x = -16
	anchored = FALSE // You can move this.
	offset_per_turfs = 25
	fire_sound = 'sound/weapons/guns/fire/howitzer_fire.ogg'
	reload_sound = 'sound/weapons/guns/interact/tat36_reload.ogg'
	fall_sound = 'sound/weapons/guns/misc/howitzer_whistle.ogg'
	minimum_range = 20
	allowed_shells = list(
		/obj/item/mortal_shell/howitzer,
		/obj/item/mortal_shell/howitzer/white_phos,
		/obj/item/mortal_shell/howitzer/he,
		/obj/item/mortal_shell/howitzer/incendiary,
		/obj/item/mortal_shell/howitzer/plasmaloss,
		/obj/item/mortal_shell/flare,
	)
	tally_type = TALLY_HOWITZER
	cool_off_time = 10 SECONDS
	reload_time = 1 SECONDS
	max_spread = 8

/obj/machinery/deployable/mortar/howitzer/AltRightClick(mob/living/user)
	if(!Adjacent(user) || user.lying_angle || user.incapacitated() || !ishuman(user))
		return

	if(!anchored)
		anchored = TRUE
		to_chat(user, span_warning("You have anchored the gun to the ground. It may not be moved."))
	else
		anchored = FALSE
		to_chat(user, span_warning("You unanchored the gun from the ground. It may be moved."))


/obj/machinery/deployable/mortar/howitzer/perform_firing_visuals()
	var/particle_type = /particles/howitzer_dust
	switch(dir)
		if(NORTH)
			particle_type = /particles/howitzer_dust/north
		if(SOUTH)
			particle_type = /particles/howitzer_dust/south
		if(EAST)
			particle_type = /particles/howitzer_dust/east
	var/obj/effect/abstract/particle_holder/dust = new(src, particle_type)
	addtimer(VARSET_CALLBACK(dust.particles, count, 0), 5)
	QDEL_IN(dust, 3 SECONDS)

/particles/howitzer_dust
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
	width = 150
	height = 200
	count = 40
	spawning = 30
	lifespan = 1 SECONDS
	fade = 1 SECONDS
	fadein = 4
	position = generator(GEN_VECTOR, list(-7, -16), list(-7, -10), NORMAL_RAND)
	velocity = list(25, -1)
	color = "#fbebd3" //coloring in a sorta dark dusty look
	drift = generator(GEN_SPHERE, 0, 1.5, NORMAL_RAND)
	friction = 0.3
	gravity = list(0, 0.55)
	grow = 0.05

/particles/howitzer_dust/east
	velocity = list(-25, -1)
	position = generator(GEN_VECTOR, list(7, -16), list(7, -10), NORMAL_RAND)

/particles/howitzer_dust/north
	velocity =  generator(GEN_VECTOR, list(10, -20), list(-10, -20), SQUARE_RAND)
	position = list(16, -16)

/particles/howitzer_dust/south
	velocity =  generator(GEN_VECTOR, list(10, 20), list(-10, 20), SQUARE_RAND)
	position = list(16, 16)

/obj/item/mortar_kit/mlrs
	name = "\improper TA-40L multiple rocket launcher system"
	desc = "A manual, crew-operated and towable multiple rocket launcher system piece used by the TerraGov Marine Corps, it is meant to saturate an area with munitions to total up to large amounts of firepower, it thus has high scatter when firing to accomplish such a task. Fires in only bursts of up to 16 rockets, it can hold 32 rockets in total. Uses 60mm Rockets."
	icon_state = "mlrs"
	max_integrity = 400
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	w_class = WEIGHT_CLASS_HUGE
	deployable_item = /obj/machinery/deployable/mortar/howitzer/mlrs

/obj/machinery/deployable/mortar/howitzer/mlrs/perform_firing_visuals()
	return

/obj/machinery/deployable/mortar/howitzer/mlrs //TODO why in the seven hells is this a howitzer child??????
	pixel_x = 0
	anchored = FALSE // You can move this.
	fire_sound = 'sound/weapons/guns/fire/rocket_arty.ogg'
	reload_sound = 'sound/weapons/guns/interact/tat36_reload.ogg'
	fall_sound = 'sound/weapons/guns/misc/rocket_whistle.ogg'
	minimum_range = 25
	allowed_shells = list(
		/obj/item/mortal_shell/rocket/mlrs,
		/obj/item/mortal_shell/rocket/mlrs/gas,
	)
	tally_type = TALLY_ROCKET_ARTY
	cool_off_time = 80 SECONDS
	fire_delay = 0.15 SECONDS
	fire_amount = 16
	reload_time = 0.25 SECONDS
	max_rounds = 32
	offset_per_turfs = 25
	spread = 5
	max_spread = 5

//this checks for box of rockets, otherwise will go to normal attackby for mortars
/obj/machinery/deployable/mortar/howitzer/mlrs/attackby(obj/item/I, mob/user, params)
	if(firing)
		user.balloon_alert(user, "The barrel is steaming hot. Wait till it cools off")
		return

	if(!istype(I, /obj/item/storage/box/mlrs_rockets) && !istype(I, /obj/item/storage/box/mlrs_rockets_gas))
		return ..()

	var/obj/item/storage/box/rocket_box = I

	//prompt user and ask how many rockets to load
	var/numrockets = tgui_input_number(user, "How many rockets do you wish to load?)", "Quantity to Load", 0, 16, 0)
	if(numrockets < 1 || !can_interact(user))
		return

	//loop that continues loading until a invalid condition is met
	var/rocketsloaded = 0
	while(rocketsloaded < numrockets)
		//verify it has rockets
		if(!istype(rocket_box.contents[1], /obj/item/mortal_shell/rocket/mlrs))
			user.balloon_alert(user, "Out of rockets")
			return
		var/obj/item/mortal_shell/mortar_shell = rocket_box.contents[1]

		if(length(chamber_items) >= max_rounds)
			user.balloon_alert(user, "You cannot fit more")
			return

		if(!(mortar_shell.type in allowed_shells))
			user.balloon_alert(user, "This shell doesn't fit")
			return

		if(busy)
			user.balloon_alert(user, "Someone else is using this")
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

		rocket_box.remove_from_storage(mortar_shell,null,user)
		rocketsloaded++
	user.balloon_alert(user, "Right click to fire")


// Shells themselves //

/obj/item/mortal_shell
	name = "\improper 80mm mortar shell"
	desc = "An unlabeled 80mm mortar shell, probably a casing."
	icon = 'icons/Marine/mortar.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/ammo_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/ammo_right.dmi',
	)
	icon_state = "mortar_ammo_cas"
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = CONDUCT
	///Ammo datum typepath that the shell uses
	var/ammo_type

/obj/item/mortal_shell/he
	name = "\improper 80mm high explosive mortar shell"
	desc = "An 80mm mortar shell, loaded with a high explosive charge."
	icon_state = "mortar_ammo_he"
	ammo_type = /datum/ammo/mortar

/obj/item/mortal_shell/incendiary
	name = "\improper 80mm incendiary mortar shell"
	desc = "An 80mm mortar shell, loaded with a napalm charge."
	icon_state = "mortar_ammo_inc"
	ammo_type = /datum/ammo/mortar/incend

/obj/item/mortal_shell/smoke
	name = "\improper 80mm smoke mortar shell"
	desc = "An 80mm mortar shell, loaded with smoke dispersal agents. Can be fired at marines more-or-less safely. Way slimmer than your typical 80mm."
	icon_state = "mortar_ammo_smk"
	ammo_type = /datum/ammo/mortar/smoke

/obj/item/mortal_shell/plasmaloss
	name = "\improper 80mm tangle mortar shell"
	desc = "An 80mm mortar shell, loaded with plasma-draining Tanglefoot gas. Can be fired at marines more-or-less safely."
	icon_state = "mortar_ammo_fsh"
	ammo_type = /datum/ammo/mortar/smoke/plasmaloss

/obj/item/mortal_shell/flare
	name = "\improper 80mm flare mortar shell"
	desc = "An 80mm mortar shell, loaded with an illumination flare, far slimmer than your typical 80mm shell. Can be fired out of larger cannons."
	icon_state = "mortar_ammo_flr"
	ammo_type = /datum/ammo/mortar/flare

/obj/item/mortal_shell/howitzer
	name = "\improper 150mm artillery shell"
	desc = "An unlabeled 150mm shell, probably a casing."
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_ammo"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/mortal_shell/howitzer/he
	name = "\improper 150mm high explosive artillery shell"
	desc = "An 150mm artillery shell, loaded with a high explosive charge, whatever is hit by this will have, A really, REALLY bad day."
	ammo_type = /datum/ammo/mortar/howi

/obj/item/mortal_shell/howitzer/plasmaloss
	name = "\improper 150mm 'Tanglefoot' artillery shell"
	desc = "An 150mm artillery shell, loaded with a toxic intoxicating gas, whatever is hit by this will have their abilities sapped slowly. Acommpanied by a small moderate explosion."
	icon_state = "howitzer_ammo_purp"
	ammo_type = /datum/ammo/mortar/smoke/howi/plasmaloss

/obj/item/mortal_shell/howitzer/incendiary
	name = "\improper 150mm incendiary artillery shell"
	desc = "An 150mm artillery shell, loaded with explosives to punch through light structures then burn out whatever is on the other side. Will ruin their day and skin."
	icon_state = "howitzer_ammo_incend"
	ammo_type = /datum/ammo/mortar/howi/incend

/obj/item/mortal_shell/howitzer/white_phos
	name = "\improper 150mm white phosporous 'spotting' artillery shell"
	desc = "An 150mm artillery shell, loaded with a 'spotting' gas that sets anything it hits aflame, whatever is hit by this will have their day, skin and future ruined, with a demand for a warcrime tribunal."
	icon_state = "howitzer_ammo_wp"
	ammo_type = /datum/ammo/mortar/smoke/howi/wp

/obj/item/mortal_shell/rocket
	ammo_type = /datum/ammo/mortar/rocket

/obj/item/mortal_shell/rocket/incend
	ammo_type = /datum/ammo/mortar/rocket/incend

/obj/item/mortal_shell/rocket/minelaying
	ammo_type = /datum/ammo/mortar/rocket/minelayer

/obj/item/mortal_shell/rocket/mlrs
	name = "\improper 60mm rocket"
	desc = "A 60mm rocket loaded with explosives, meant to be used in saturation fire with high scatter."
	icon_state = "mlrs_rocket"
	ammo_type = /datum/ammo/mortar/rocket/mlrs

/obj/item/mortal_shell/rocket/mlrs/gas
	name = "\improper 60mm 'X-50' rocket"
	desc = "A 60mm rocket loaded with deadly X-50 gas that drains the energy and life out of anything unfortunate enough to find itself inside of it."
	icon_state = "mlrs_rocket_gas"
	ammo_type = /datum/ammo/mortar/rocket/smoke/mlrs

/obj/structure/closet/crate/mortar_ammo
	name = "\improper T-50S mortar ammo crate"
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
	name = "\improper TA-50S mortar kit"
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
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/smoke(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/binoculars/tactical/range(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/hud_tablet/artillery(src)


/obj/structure/closet/crate/mortar_ammo/howitzer_kit
	name = "\improper TA-100Y howitzer kit"
	desc = "A crate containing a basic, somehow compressed kit consisting of an entire howitzer and some shells, to get a artilleryman started."

/obj/structure/closet/crate/mortar_ammo/howitzer_kit/PopulateContents()
	new /obj/item/mortar_kit/howitzer(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/incendiary(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/he(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new /obj/item/mortal_shell/howitzer/white_phos(src)
	new	/obj/item/mortal_shell/howitzer/plasmaloss(src)
	new	/obj/item/mortal_shell/howitzer/plasmaloss(src)
	new	/obj/item/mortal_shell/howitzer/plasmaloss(src)
	new	/obj/item/mortal_shell/howitzer/plasmaloss(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/mortal_shell/flare(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/binoculars/tactical/range(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/hud_tablet/artillery(src)


/obj/structure/closet/crate/mortar_ammo/mlrs_kit
	name = "\improper TA-40L MLRS kit"
	desc = "A crate containing a basic, somehow compressed kit consisting of an entire multiple launch rocket system and some rockets, to get a artilleryman started."

/obj/structure/closet/crate/mortar_ammo/mlrs_kit/PopulateContents()
	new /obj/item/mortar_kit/mlrs(src)
	new /obj/item/storage/box/mlrs_rockets(src)
	new /obj/item/storage/box/mlrs_rockets(src)
	new /obj/item/storage/box/mlrs_rockets(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/encryptionkey/engi(src)
	new /obj/item/binoculars/tactical/range(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/encryptionkey/cas(src)
	new /obj/item/hud_tablet/artillery(src)


/obj/item/storage/box/mlrs_rockets
	name = "\improper TA-40L rocket crate"
	desc = "A large case containing rockets in a compressed setting for the TA-40L MLRS. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 16

/obj/item/storage/box/mlrs_rockets/Initialize(mapload)
	. = ..()
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)
	new /obj/item/mortal_shell/rocket/mlrs(src)

/obj/item/storage/box/mlrs_rockets_gas
	name = "\improper TA-40L X-50 rocket crate"
	desc = "A large case containing rockets in a compressed setting for the TA-40L MLRS. Drag this sprite into you to open it up!\nNOTE: You cannot put items back inside this case."
	storage_slots = 16

/obj/item/storage/box/mlrs_rockets_gas/Initialize(mapload)
	. = ..()
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)
	new /obj/item/mortal_shell/rocket/mlrs/gas(src)

#undef TALLY_MORTAR
#undef TALLY_HOWITZER
