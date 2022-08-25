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
	/// Automatic offset from target
	var/offset_x = 0
	var/offset_y = 0
	/// Number of turfs to offset from target by 1
	var/offset_per_turfs = 10
	/// Constant, assuming perfect parabolic trajectory. ONLY THE DELAY BEFORE INCOMING WARNING WHICH ADDS 45 TICKS
	var/travel_time = 45
	var/busy = 0
	/// Used for deconstruction and aiming sanity
	var/firing = 0
	/// The fire sound of the mortar or artillery piece.
	var/fire_sound = 'sound/weapons/guns/fire/mortar_fire.ogg'
	var/reload_sound = 'sound/weapons/guns/interact/mortar_reload.ogg' // Our reload sound.
	var/fall_sound = 'sound/weapons/guns/misc/mortar_travel.ogg' //The sound the shell makes when falling.

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
	if(firing)
		to_chat(user, span_warning("[src]'s barrel is still steaming hot. Wait a few seconds and stop firing it."))
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
		if(get_dist(loc, selfown) < 7)
			to_chat(user, span_warning("You cannot target this coordinate, it is too close to your mortar."))
			return

		var/turf/T = locate(coords["targ_x"] + coords["dial_x"] + offset_x, coords["targ_y"]  + coords["dial_x"] + offset_y, z)
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
		user.transferItemToLoc(mortar_shell, src)
		playsound(loc, fire_sound, 50, 1)
		firing = TRUE
		flick(icon_state + "_fire", src)
		mortar_shell.forceMove(src)

		if(tally_type == TALLY_MORTAR)
			GLOB.round_statistics.howitzer_shells_fired++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "howitzer_shells_fired")		
		else if(tally_type == TALLY_HOWITZER)
			GLOB.round_statistics.mortar_shells_fired++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "mortar_shells_fired")		

		var/turf/G = get_turf(src)
		G.ceiling_debris_check(2)

		for(var/mob/M in range(7))
			shake_camera(M, 3, 1)
		log_game("[key_name(user)] has fired the [src] at [AREACOORD(T)], impact in [travel_time+45] ticks")
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, T, fall_sound, 50, 1), travel_time)
		addtimer(CALLBACK(src, .proc/detonate_shell, T, mortar_shell), travel_time + 45)//This should always be 45 ticks!

	if(istype(I, /obj/item/ai_target_beacon))
		for(var/mob/living/silicon/ai/AI AS in GLOB.ai_list)
			if(!AI)
				to_chat(user, span_notice("There is no AI to associate with."))
				return
			to_chat(user, span_notice("You attach the [I], allowing for remote targeting."))
			to_chat(AI, span_notice("[src] has been linked to your systems, allowing for remote targeting."))
			user.transferItemToLoc(I, src)
			AI.associate_artillery(src)
			playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
			ai_targeter = I
			return
	if(!istype(I, /obj/item/binoculars/tactical))
		return
	var/obj/item/binoculars/tactical/binocs = I
	playsound(src, 'sound/effects/binoctarget.ogg', 35)
	if(binocs.set_mortar(src))
		to_chat(user, span_notice("You link the mortar to the [binocs] allowing for remote targeting."))
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

/obj/machinery/deployable/mortar/attack_ai(mob/living/silicon/ai/user)
	if(user.linked_artillery == src)
		switch(tgui_alert(usr, "This artillery piece is linked to you. Do you want to unlink yourself from it?", "Artillery Targeting", list("Yes", "No")))
			if("Yes")
				user.clean_artillery_refs()
			if("No")
				return

/obj/machinery/deployable/mortar/proc/unset_targeter()
	say("Linked AI spotter has relinquished targeting privileges. Ejecting targeting device.")
	ai_targeter.loc = src.loc
	ai_targeter = null
	

/obj/machinery/deployable/mortar/attack_hand_alternate(mob/living/user)
	if(!Adjacent(user) || user.lying_angle || user.incapacitated() || !ishuman(user))
		return

	if(busy)
		to_chat(user, span_warning("Someone else is currently using [src]."))
		return

	if(firing)
		to_chat(user, span_warning("[src]'s barrel is still steaming hot. Wait a few seconds and stop firing it."))
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
	AddElement(/datum/element/deployable_item, deployable_item, type, 5 SECONDS)

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
	offset_per_turfs = 25 // Howizters are significantly more accurate.
	travel_time = 60
	fire_sound = 'sound/weapons/guns/fire/howitzer_fire.ogg'
	reload_sound = 'sound/weapons/guns/interact/tat36_reload.ogg'
	fall_sound = 'sound/weapons/guns/misc/howitzer_whistle.ogg'
	allowed_shells = list(
		/obj/item/mortal_shell/howitzer,
		/obj/item/mortal_shell/howitzer/white_phos,
		/obj/item/mortal_shell/howitzer/he,
		/obj/item/mortal_shell/howitzer/incendiary,
		/obj/item/mortal_shell/howitzer/plasmaloss,
		/obj/item/mortal_shell/flare,
	)
	tally_type = TALLY_HOWITZER

/obj/machinery/deployable/mortar/howitzer/attack_hand_alternate(mob/living/user)
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

/obj/item/mortal_shell/proc/detonate(turf/T)
	forceMove(T)

/obj/item/mortal_shell/he
	name = "\improper 80mm high explosive mortar shell"
	desc = "An 80mm mortar shell, loaded with a high explosive charge."
	icon_state = "mortar_ammo_he"

/obj/item/mortal_shell/he/detonate(turf/T)
	explosion(T, 1, 2, 5, 3)

/obj/item/mortal_shell/incendiary
	name = "\improper 80mm incendiary mortar shell"
	desc = "An 80mm mortar shell, loaded with a napalm charge."
	icon_state = "mortar_ammo_inc"

/obj/item/mortal_shell/incendiary/detonate(turf/T)
	explosion(T, 0, 2, 3, 7, throw_range = 0, small_animation = TRUE)
	flame_radius(4, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/obj/item/mortal_shell/smoke
	name = "\improper 80mm smoke mortar shell"
	desc = "An 80mm mortar shell, loaded with smoke dispersal agents. Can be fired at marines more-or-less safely. Way slimmer than your typical 80mm."
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
	smoke.set_up(10, T, 7)
	smoke.start()
	smoke = null
	qdel(src)

/obj/item/mortal_shell/flare
	name = "\improper 80mm flare mortar shell"
	desc = "An 80mm mortar shell, loaded with an illumination flare, far slimmer than your typical 80mm shell. Can be fired out of larger cannons."
	icon_state = "mortar_ammo_flr"

/obj/item/mortal_shell/flare/detonate(turf/T)
	new /obj/effect/mortar_flare(T)
	playsound(T, 'sound/weapons/guns/fire/flare.ogg', 50, 1, 4)

///Name_swap of the CAS flare
/obj/effect/mortar_flare
	invisibility = INVISIBILITY_MAXIMUM
	resistance_flags = RESIST_ALL
	mouse_opacity = 0
	light_color = COLOR_VERY_SOFT_YELLOW
	light_system = HYBRID_LIGHT
	light_power = 8
	light_range = 12 //Way brighter than most lights

/obj/effect/mortar_flare/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	set_light(light_range, light_power)
	T.visible_message(span_warning("You see a tiny flash, and then a blindingly bright light from a flare as it lights off in the sky!"))
	playsound(T, 'sound/weapons/guns/fire/flare.ogg', 50, 1, 4) // stolen from the mortar i'm not even sorry
	QDEL_IN(src, rand(70 SECONDS, 90 SECONDS)) // About the same burn time as a flare, considering it requires it's own CAS run.

/obj/item/mortal_shell/howitzer
	name = "\improper 150mm artillery shell"
	desc = "An unlabeled 150mm shell, probably a casing."
	icon = 'icons/Marine/howitzer.dmi'
	icon_state = "howitzer_ammo"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/mortal_shell/howitzer/he
	name = "\improper 150mm high explosive artillery shell"
	desc = "An 150mm artillery shell, loaded with a high explosive charge, whatever is hit by this will have, A really, REALLY bad day."

/obj/item/mortal_shell/howitzer/he/detonate(turf/T)
	explosion(T, 1, 6, 7, 12)

/obj/item/mortal_shell/howitzer/plasmaloss
	name = "\improper 150mm 'Tanglefoot' artillery shell"
	desc = "An 150mm artillery shell, loaded with a toxic intoxicating gas, whatever is hit by this will have their abilities sapped slowly. Acommpanied by a small moderate explosion."
	icon_state = "howitzer_ammo_purp"
	var/datum/effect_system/smoke_spread/plasmaloss/smoke

/obj/item/mortal_shell/howitzer/plasmaloss/Initialize()
	. = ..()
	smoke = new(src)

/obj/item/mortal_shell/howitzer/plasmaloss/detonate(turf/T)
	explosion(T, 0, 0, 5, 0, throw_range = 0)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	forceMove(T)
	smoke.set_up(10, T, 11)
	smoke.start()
	smoke = null
	qdel(src)

/obj/item/mortal_shell/howitzer/incendiary
	name = "\improper 150mm incendiary artillery shell"
	desc = "An 150mm artillery shell, loaded with explosives to punch through light structures then burn out whatever is on the other side. Will ruin their day and skin."
	icon_state = "howitzer_ammo_incend"

/obj/item/mortal_shell/howitzer/incendiary/detonate(turf/T)
	explosion(T, 0, 3, 0, 3, throw_range = 0, small_animation = TRUE)
	flame_radius(5, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/obj/item/mortal_shell/howitzer/white_phos
	name = "\improper 150mm white phosporous 'spotting' artillery shell"
	desc = "An 150mm artillery shell, loaded with a 'spotting' gas that sets anything it hits aflame, whatever is hit by this will have their day, skin and future ruined, with a demand for a warcrime tribunal."
	icon_state = "howitzer_ammo_wp"
	var/datum/effect_system/smoke_spread/phosphorus/smoke

/obj/item/mortal_shell/howitzer/white_phos/Initialize()
	. = ..()
	smoke = new(src)

/obj/item/mortal_shell/howitzer/white_phos/detonate(turf/T)
	explosion(T, 0, 0, 1, 0, throw_range = 0)
	playsound(loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(6, T, 7)
	smoke.start()
	flame_radius(4, T)
	flame_radius(1, T, burn_intensity = 45, burn_duration = 75, burn_damage = 15, fire_stacks = 75)
	qdel(src)

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
