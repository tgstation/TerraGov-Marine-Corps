//The Marine mortar, the T-50S Mortar
//Works like a contemporary crew weapon mortar

#define TALLY_MORTAR  1
#define TALLY_HOWITZER 2

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
	var/offset_per_turfs = 10
	/// Spread on target
	var/spread
	var/busy = 0
	/// Used for deconstruction and aiming sanity
	var/firing = 0
	/// The fire sound of the mortar or artillery piece.
	var/fire_sound = 'sound/weapons/guns/fire/mortar_fire.ogg'
	var/reload_sound = 'sound/weapons/guns/interact/mortar_reload.ogg' // Our reload sound.
	var/fall_sound = 'sound/weapons/guns/misc/mortar_long_whistle.ogg' //The sound the shell makes when falling.
	///Minimum range to fire
	var/minimum_range = 10
	///Time it takes for the mortar to cool off to fire
	var/cool_off_time = 1 SECONDS
	var/fire_delay = 0
	var/fire_amount = 1

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

/obj/machinery/deployable/mortar/examine(mob/user)
	. = ..()
	if(ai_targeter)
		. += span_notice("They have an AI linked targeting device on.")

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
		user.balloon_alert(user, "The barrel is steaming hot. Wait a few seconds")
		return

	if(istype(I, /obj/item/mortal_shell))
		var/obj/item/mortal_shell/mortar_shell = I

		if(issynth(user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
			to_chat(user, span_warning("Your programming restricts operating heavy weaponry."))
			return

		if(!(I.type in allowed_shells))
			to_chat(user, span_warning("This shell doesn't fit in here!"))
			return

		if(busy)
			to_chat(user, span_warning("Someone else is currently using [src]."))
			return

		if(!is_ground_level(z))
			to_chat(user, span_warning("You cannot fire [src] here."))
			return

		if(coords["targ_x"] == 0 && coords["targ_y"] == 0) //Mortar wasn't set
			to_chat(user, span_warning("[src] needs to be aimed first."))
			return

		var/turf/selfown = locate((coords["targ_x"] + coords["dial_x"]), (coords["targ_y"] + coords["dial_y"]), z)
		if(get_dist(loc, selfown) < minimum_range)
			to_chat(user, span_warning("You cannot target this coordinate, it is too close to your mortar."))
			return

		var/turf/T = locate(coords["targ_x"] + coords["dial_x"], coords["targ_y"]  + coords["dial_x"], z)
		dir = get_dir(src, T)
		if(!isturf(T))
			to_chat(user, span_warning("You cannot fire [src] to this target."))
			return

		var/area/A = get_area(T)
		if(istype(A) && A.ceiling >= CEILING_UNDERGROUND)
			to_chat(user, span_warning("You cannot hit the target. It is probably underground."))
			return

		user.visible_message(span_notice("[user] starts loading \a [mortar_shell.name] into [src]."),
		span_notice("You start loading \a [mortar_shell.name] into [src]."))
		playsound(loc, reload_sound, 50, 1)
		busy = TRUE
		if(!do_after(user, 15, TRUE, src, BUSY_ICON_HOSTILE))
			busy = FALSE
			return

		busy = FALSE

		user.visible_message(span_notice("[user] loads \a [mortar_shell.name] into [src]."),
		span_notice("You load \a [mortar_shell.name] into [src]."))
		visible_message("[icon2html(src, viewers(src))] [span_danger("The [name] fires!")]")
		qdel(mortar_shell)
		var/turf/G = get_turf(src)
		G.ceiling_debris_check(2)
		log_game("[key_name(user)] has fired the [src] at [AREACOORD(T)]")

		var/offset_x_max = round(abs((coords["targ_x"] + coords["dial_x"]) - x)/offset_per_turfs) //Offset of mortar shot, grows by 1 every 10 tiles travelled
		var/offset_y_max = round(abs((coords["targ_y"] + coords["dial_y"]) - y)/offset_per_turfs)
		spread = offset_x_max + offset_y_max

		var/list/turf_list = list()
		for(var/turf/spread_turf in range(spread, T))
			turf_list += spread_turf
		user.balloon_alert(user, spread)
		for(var/i = 1 to fire_amount)
			var/turf/impact_turf = pick_n_take(turf_list)
			begin_fire(impact_turf, mortar_shell)
			if(fire_delay)
				sleep(fire_delay)
		addtimer(CALLBACK(src, .proc/cool_off), cool_off_time)

	if(istype(I, /obj/item/ai_target_beacon))
		if(!GLOB.ai_list.len)
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
		to_chat(user, span_notice("You link the mortar to the [binocs] allowing for remote targeting."))
		return
	to_chat(user, "<span class='notice'>You disconnect the [binocs] from their linked mortar.")

/obj/machinery/deployable/mortar/proc/begin_fire(target, obj/item/mortal_shell/arty_shell)
	firing = TRUE
	for(var/mob/M in range(7))
		shake_camera(M, 2, 1)
	if(tally_type == TALLY_MORTAR)
		GLOB.round_statistics.howitzer_shells_fired++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "howitzer_shells_fired")
	else if(tally_type == TALLY_HOWITZER)
		GLOB.round_statistics.mortar_shells_fired++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "mortar_shells_fired")
	playsound(loc, fire_sound, 50, 1)
	flick(icon_state + "_fire", src)
	var/obj/projectile/shell = new /obj/projectile(loc)
	var/datum/ammo/ammo = GLOB.ammo_list[arty_shell.ammo_type]
	shell.generate_bullet(ammo)
	shell.fire_at(target, src, src, get_dist(src, target), ammo.shell_speed, suppress_light = TRUE)
	var/distance = get_dist(src, target)
	addtimer(CALLBACK(src, .proc/falling, target, shell), distance/ammo.shell_speed - 10)

///Proc called by tactical binoculars to send targeting information.
/obj/machinery/deployable/mortar/proc/recieve_target(turf/T, mob/user)
	coords["targ_x"] = T.x
	coords["targ_y"] = T.y
	say("Remote targeting set by [user]. COORDINATES: X:[coords["targ_x"]] Y:[coords["targ_y"]] OFFSET: X:[coords["dial_x"]] Y:[coords["dial_y"]]")
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)

/obj/machinery/deployable/mortar/proc/cool_off()
	firing = FALSE

/obj/machinery/deployable/mortar/proc/falling(turf/T, obj/projectile/shell)
	flick(shell.icon_state + "_falling", shell)
	playsound(T, fall_sound, 100, 1)

///Prompt for the AI to unlink itself.
/obj/machinery/deployable/mortar/attack_ai(mob/living/silicon/ai/user)
	if (user.linked_artillery == src && tgui_alert(usr, "This artillery piece is linked to you. Do you want to unlink yourself from it?", "Artillery Targeting", list("Yes", "No")) == "Yes")
		user.clean_artillery_refs()

///Unlinking the AI from this mortar
/obj/machinery/deployable/mortar/proc/unset_targeter()
	say("Linked AI spotter has relinquished targeting privileges. Ejecting targeting device.")
	ai_targeter.forceMove(src.loc)
	ai_targeter = null

/obj/machinery/deployable/mortar/attack_hand_alternate(mob/living/user)
	if(!Adjacent(user) || user.lying_angle || user.incapacitated() || !ishuman(user))
		return

	if(busy)
		to_chat(user, span_warning("Someone else is currently using [src]."))
		return

	return ..()

//The portable mortar item
/obj/item/mortar_kit
	name = "\improper TA-50S mortar"
	desc = "A manual, crew-operated mortar system intended to rain down 80mm goodness on anything it's aimed at. Needs to be set down first to fire. Ctrl+Click on a tile to deploy, drag the mortar's sprites to mob's sprite to undeploy."
	icon = 'icons/Marine/mortar.dmi'
	icon_state = "mortar"
	max_integrity = 200
	flags_item = IS_DEPLOYABLE
	/// What item is this going to deploy when we put down the mortar?
	var/deployable_item = /obj/machinery/deployable/mortar
	resistance_flags = RESIST_ALL
	w_class = WEIGHT_CLASS_BULKY //No dumping this in most backpacks. Carry it, fatso

/obj/item/mortar_kit/Initialize()
	. = ..()
	AddElement(/datum/element/deployable_item, deployable_item, type, 1 SECONDS)

/obj/item/mortar_kit/attack_self(mob/user)
	do_unique_action(user)

/obj/item/mortar_kit/unique_action(mob/user)
	var/area/current_area = get_area(src)
	if(current_area.ceiling >= CEILING_METAL)
		to_chat(user, span_warning("You probably shouldn't deploy [src] indoors."))
		return
	return ..()

// The big boy, the Howtizer.

/obj/item/mortar_kit/howitzer
	name = "\improper TA-100Y howitzer"
	desc = "A manual, crew-operated and towable howitzer, will rain down 150mm laserguided and accurate shells on any of your foes. Right click to anchor to the ground."
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer"
	max_integrity = 400
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	w_class = WEIGHT_CLASS_HUGE
	deployable_item = /obj/machinery/deployable/mortar/howitzer

/obj/machinery/deployable/mortar/howitzer
	anchored = FALSE // You can move this.
	offset_per_turfs = 25
	fire_sound = 'sound/weapons/guns/fire/howitzer_fire.ogg'
	reload_sound = 'sound/weapons/guns/interact/tat36_reload.ogg'
	fall_sound = 'sound/weapons/guns/misc/howitzer_whistle.ogg'
	minimum_range = 15
	allowed_shells = list(
		/obj/item/mortal_shell/howitzer,
		/obj/item/mortal_shell/howitzer/white_phos,
		/obj/item/mortal_shell/howitzer/he,
		/obj/item/mortal_shell/howitzer/incendiary,
		/obj/item/mortal_shell/howitzer/plasmaloss,
		/obj/item/mortal_shell/flare,
	)
	tally_type = TALLY_HOWITZER
	cool_off_time = 2 SECONDS

/obj/machinery/deployable/mortar/howitzer/attack_hand_alternate(mob/living/user)
	if(!Adjacent(user) || user.lying_angle || user.incapacitated() || !ishuman(user))
		return

	anchored = !anchored
	to_chat(usr, span_warning("You have [anchored ? "<b>anchored</b>" : "<b>unanchored</b>"] the gun."))

/obj/item/mortar_kit/rocket_arty
	name = "\improper TA-100Y howitzer"
	desc = "A manual, crew-operated and towable howitzer, will rain down 150mm laserguided and accurate shells on any of your foes. Right click to anchor to the ground."
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer"
	max_integrity = 400
	flags_item = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	w_class = WEIGHT_CLASS_HUGE
	deployable_item = /obj/machinery/deployable/mortar/rocket_arty

/obj/machinery/deployable/mortar/rocket_arty
	anchored = FALSE // You can move this.
	fire_sound = 'sound/weapons/guns/fire/launcher.ogg'
	reload_sound = 'sound/weapons/guns/interact/tat36_reload.ogg'
	fall_sound = 'sound/weapons/guns/misc/mortar_long_whistle.ogg'
	minimum_range = 22
	allowed_shells = list(
		/obj/item/mortal_shell/howitzer,
		/obj/item/mortal_shell/howitzer/white_phos,
		/obj/item/mortal_shell/howitzer/he,
		/obj/item/mortal_shell/howitzer/incendiary,
		/obj/item/mortal_shell/howitzer/plasmaloss,
		/obj/item/mortal_shell/flare,
	)
	tally_type = TALLY_HOWITZER
	cool_off_time = 2 SECONDS
	fire_delay = 0.2 SECONDS
	fire_amount = 12
	spread = 7

/obj/machinery/deployable/mortar/rocket_arty/attack_hand_alternate(mob/living/user)
	if(!Adjacent(user) || user.lying_angle || user.incapacitated() || !ishuman(user))
		return

	anchored = !anchored
	to_chat(usr, span_warning("You have [anchored ? "<b>anchored</b>" : "<b>unanchored</b>"] the gun."))

// Shells themselves //

/obj/item/mortal_shell
	name = "\improper 80mm mortar shell"
	desc = "An unlabeled 80mm mortar shell, probably a casing."
	icon = 'icons/Marine/mortar.dmi'
	icon_state = "mortar_ammo_cas"
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = CONDUCT
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
	ammo_type = /datum/ammo/mortar/plasmaloss

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
	ammo_type = /datum/ammo/mortar/howi/plasmaloss

/obj/item/mortal_shell/howitzer/incendiary
	name = "\improper 150mm incendiary artillery shell"
	desc = "An 150mm artillery shell, loaded with explosives to punch through light structures then burn out whatever is on the other side. Will ruin their day and skin."
	icon_state = "howitzer_ammo_incend"
	ammo_type = /datum/ammo/mortar/howi/incend

/obj/item/mortal_shell/howitzer/white_phos
	name = "\improper 150mm white phosporous 'spotting' artillery shell"
	desc = "An 150mm artillery shell, loaded with a 'spotting' gas that sets anything it hits aflame, whatever is hit by this will have their day, skin and future ruined, with a demand for a warcrime tribunal."
	icon_state = "howitzer_ammo_wp"
	ammo_type = /datum/ammo/mortar/howi/wp

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

#undef TALLY_MORTAR
#undef TALLY_HOWITZER
