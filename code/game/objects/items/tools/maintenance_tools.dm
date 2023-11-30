/obj/item/tool/wrench
	name = "wrench"
	desc = "A wrench with many common uses. Can be usually found in your hand."
	icon_state = "wrench"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	usesound = 'sound/items/ratchet.ogg'
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")
	tool_behaviour = TOOL_WRENCH


/obj/item/tool/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwwy with this."
	icon_state = "screwdriver_map"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	attack_verb = list("stabbed")
	tool_behaviour = TOOL_SCREWDRIVER
	/// If the item should be assigned a random color
	var/random_color = TRUE
	/// List of possible random colors
	var/static/list/screwdriver_colors = list(
		"blue" = "#1861d5",
		"red" = "#ff0000",
		"pink" = "#d5188d",
		"brown" = "#a05212",
		"green" = "#0e7f1b",
		"cyan" = "#18a2d5",
		"yellow" = "#ffa500"
	)


/obj/item/tool/screwdriver/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is stabbing the [name] into [user.p_their()] [pick("temple","heart")]! It looks like [user.p_theyre()] trying to commit suicide."))
	return(BRUTELOSS)


/obj/item/tool/screwdriver/Initialize(mapload)
	if(random_color)
		set_greyscale_config(/datum/greyscale_config/screwdriver)
		var/our_color = pick(screwdriver_colors)
		set_greyscale_colors(list(screwdriver_colors[our_color]))
		item_icons = list(
			slot_l_hand_str = SSgreyscale.GetColoredIconByType(/datum/greyscale_config/screwdriver_inhand_left, greyscale_colors),
			slot_r_hand_str = SSgreyscale.GetColoredIconByType(/datum/greyscale_config/screwdriver_inhand_right, greyscale_colors),
		)
		item_state_slots = list(
			slot_l_hand_str = null,
			slot_r_hand_str = null,
		)
	. = ..()
	if(prob(75))
		pixel_y = rand(0, 16)

/obj/item/tool/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon_state = "cutters"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 6
	throw_speed = 2
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("pinched", "nipped")
	sharp = IS_SHARP_ITEM_SIMPLE
	edge = 1
	tool_behaviour = TOOL_WIRECUTTER


/obj/item/tool/wirecutters/Initialize(mapload)
	. = ..()
	if(prob(50))
		icon_state = "cutters-y"
		item_state = "cutters_yellow"


/obj/item/tool/wirecutters/attack(mob/living/carbon/C, mob/user)
	if((C.handcuffed) && (istype(C.handcuffed, /obj/item/restraints/handcuffs/cable)))
		user.visible_message("\The [usr] cuts \the [C]'s restraints with \the [src]!",\
		"You cut \the [C]'s restraints with \the [src]!",\
		"You hear cable being cut.")
		C.update_handcuffed(null)
		return
	else
		..()


/obj/item/tool/weldingtool
	name = "blowtorch"
	desc = "Used for welding and repairing various things."
	icon_state = "welder"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT

	//Amount of OUCH when it's thrown
	force = 3
	throwforce = 5
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_WELDER

	//blowtorch specific stuff
	var/welding = 0 	//Whether or not the blowtorch is off(0), on(1) or currently welding(2)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold
	var/weld_tick = 0	//Used to slowly deplete the fuel when the tool is left on.
	var/status = TRUE //When welder is secured on unsecured


/obj/item/tool/weldingtool/Initialize(mapload)
	. = ..()
	create_reagents(max_fuel, null, list(/datum/reagent/fuel = max_fuel))


/obj/item/tool/weldingtool/Destroy()
	if(welding)
		STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/tool/weldingtool/examine(mob/user)
	. += ..()
	. +=  "It contains [get_fuel()]/[max_fuel] units of fuel!"


/obj/item/tool/weldingtool/use(used = 0)
	if(!isOn() || !check_fuel())
		return FALSE

	if(get_fuel() < used)
		return FALSE

	reagents.remove_reagent(/datum/reagent/fuel, used)
	check_fuel()
	return TRUE


// When welding is about to start, run a normal tool_use_check, then flash a mob if it succeeds.
/obj/item/tool/weldingtool/tool_start_check(mob/living/user, amount = 0)
	. = tool_use_check(user, amount)
	if(. && user)
		eyecheck(user)


// If welding tool ran out of fuel during a construction task, construction fails.
/obj/item/tool/weldingtool/tool_use_check(mob/living/user, amount)
	if(!isOn() || !check_fuel())
		balloon_alert(user, "[src] not on")
		return FALSE

	if(get_fuel() < amount)
		balloon_alert(user, "low fuel")
		return FALSE

	return TRUE


/obj/item/tool/weldingtool/process()
	if(gc_destroyed)
		STOP_PROCESSING(SSobj, src)
		return
	if(welding)
		if(++weld_tick >= 20)
			weld_tick = 0
			remove_fuel(1)
	else //should never be happening, but just in case
		toggle(TRUE)

/obj/item/tool/weldingtool/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/screwdriver))
		flamethrower_screwdriver(src, user)

/obj/item/tool/weldingtool/afterattack(obj/O, mob/user, proximity)
	if(!proximity)
		return
	if(!status && O.is_refillable())
		reagents.trans_to(O, reagents.total_volume)
	if (welding)
		remove_fuel(1)

		if(isliving(O))
			var/mob/living/L = O
			L.IgniteMob()

/obj/proc/handle_weldingtool_overlay(removing = FALSE)
	if(!removing)
		add_overlay(GLOB.welding_sparks)
	else
		cut_overlay(GLOB.welding_sparks)

/obj/item/tool/weldingtool/use_tool(atom/target, mob/living/user, delay, amount, volume, datum/callback/extra_checks)
	if(isobj(target))
		var/obj/O = target
		O.handle_weldingtool_overlay()
		. = ..()
		O.handle_weldingtool_overlay(TRUE)
	else
		. = ..()

/obj/item/tool/weldingtool/attack_self(mob/user as mob)
	if(!status)
		balloon_alert(user, "Can't, unsecured!")
		return
	toggle()


//Returns the amount of fuel in the welder
/obj/item/tool/weldingtool/proc/get_fuel()
	return reagents.get_reagent_amount(/datum/reagent/fuel)


//Removes fuel from the blowtorch. If a mob is passed, it will perform an eyecheck on the mob. This should probably be renamed to use()
/obj/item/tool/weldingtool/proc/remove_fuel(amount = 1, mob/M = null)
	if(!welding || !check_fuel())
		return 0
	if(get_fuel() >= amount)
		reagents.remove_reagent(/datum/reagent/fuel, amount)
		check_fuel()
		if(M)
			eyecheck(M)
		return 1
	else
		if(M)
			balloon_alert(M, "Out of welding fuel")
		return 0

//Returns whether or not the blowtorch is currently on.
/obj/item/tool/weldingtool/proc/isOn()
	return src.welding

//Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/tool/weldingtool/proc/check_fuel()
	if((get_fuel() <= 0) && welding)
		toggle(TRUE)
		return 0
	return 1


//Toggles the welder off and on
/obj/item/tool/weldingtool/proc/toggle(message = 0)
	var/mob/M
	if(ismob(loc))
		M = loc
	if(!welding)
		if(get_fuel() > 0)
			playsound(loc, 'sound/items/weldingtool_on.ogg', 25)
			welding = 1
			if(M)
				balloon_alert(M, "Turns on")
			set_light(1, LIGHTER_LUMINOSITY)
			weld_tick += 8 //turning the tool on does not consume fuel directly, but it advances the process that regularly consumes fuel.
			force = 15
			damtype = BURN
			icon_state = "welder1"
			w_class = WEIGHT_CLASS_BULKY
			heat = 3800
			START_PROCESSING(SSobj, src)
		else
			if(M)
				balloon_alert(M, "Out of fuel")
			return
	else
		playsound(loc, 'sound/items/weldingtool_off.ogg', 25)
		force = 3
		damtype = BRUTE
		icon_state = "welder"
		welding = 0
		w_class = initial(w_class)
		heat = 0
		if(M)
			if(!message)
				balloon_alert(M, "Switches off")
			else
				balloon_alert(M, "Out of fuel")
			if(M.r_hand == src)
				M.update_inv_r_hand()
			if(M.l_hand == src)
				M.update_inv_l_hand()
		set_light(0)
		STOP_PROCESSING(SSobj, src)

/obj/item/tool/weldingtool/proc/flamethrower_screwdriver(obj/item/I, mob/user)
	if(welding)
		balloon_alert(user, "Turn it off first")
		return
	status = !status
	if(status)
		balloon_alert(user, "Resecures and closes")
		DISABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER)
	else
		balloon_alert(user, "Ready to be refueled")
		ENABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER)

/obj/item/tool/weldingtool/largetank
	name = "industrial blowtorch"
	max_fuel = 40

/obj/item/tool/weldingtool/hugetank
	name = "high-capacity industrial blowtorch"
	max_fuel = 80
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/tool/weldingtool/experimental
	name = "experimental blowtorch"
	max_fuel = 40 //?
	w_class = WEIGHT_CLASS_NORMAL
	var/last_gen = 0

/obj/item/tool/weldingtool/experimental/proc/fuel_gen()//Proc to make the experimental welder generate fuel, optimized as fuck -Sieve
	var/gen_amount = ((world.time-last_gen)/25)
	reagents += (gen_amount)
	if(reagents > max_fuel)
		reagents = max_fuel

/obj/item/tool/crowbar
	name = "crowbar"
	desc = "Used to remove floors and to pry open doors."
	icon_state = "crowbar"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 5
	throwforce = 7
	item_state = "crowbar"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	pry_capable = IS_PRY_CAPABLE_CROWBAR
	tool_behaviour = TOOL_CROWBAR
	usesound = 'sound/items/crowbar.ogg'


/obj/item/tool/crowbar/red
	icon_state = "red_crowbar"
	item_state = "crowbar_red"



/obj/item/tool/weldpack
	name = "Welding kit"
	desc = "A heavy-duty, portable fuel carrier. Welder and flamer compatible."
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/obj/items/tank.dmi'
	icon_state = "welderpack"
	w_class = WEIGHT_CLASS_BULKY
	var/max_fuel = 500 //Because the marine backpack can carry 260, and still allows you to take items, there should be a reason to still use this one.

/obj/item/tool/weldpack/Initialize(mapload)
	. = ..()
	var/datum/reagents/R = new/datum/reagents(max_fuel) //Lotsa refills
	reagents = R
	R.my_atom = WEAKREF(src)
	R.add_reagent(/datum/reagent/fuel, max_fuel)

/obj/item/tool/weldpack/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(reagents.total_volume == 0)
		balloon_alert(user, "Out of fuel")
		return

	else if(iswelder(I))
		var/obj/item/tool/weldingtool/T = I
		if(T.welding)
			balloon_alert(user, "That was stupid")
			log_bomber(user, "triggered a weldpack explosion", src)
			explosion(src, light_impact_range = 3)
			qdel(src)
		if(T.get_fuel() == T.max_fuel || !reagents.total_volume)
			return ..()

		reagents.trans_to(I, T.max_fuel)
		balloon_alert(user, "Welder refilled")
		playsound(loc, 'sound/effects/refill.ogg', 25, TRUE, 3)

	else if(istype(I, /obj/item/ammo_magazine/flamer_tank))
		var/obj/item/ammo_magazine/flamer_tank/FT = I
		if(FT.current_rounds == FT.max_rounds || !reagents.total_volume)
			return ..()
		if(FT.default_ammo != /datum/ammo/flamethrower)
			balloon_alert(user, "Wrong fuel")
			return ..()

		//Reworked and much simpler equation; fuel capacity minus the current amount, with a check for insufficient fuel
		var/fuel_transfer_amount = min(reagents.total_volume, (FT.max_rounds - FT.current_rounds))
		reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		FT.current_rounds += fuel_transfer_amount
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		FT.caliber = CALIBER_FUEL
		balloon_alert(user, "Refills with [lowertext(FT.caliber)]")
		FT.update_icon()

	else if(istype(I, /obj/item/storage/holster/backholster/flamer))
		var/obj/item/storage/holster/backholster/flamer/flamer_bag = I
		var/obj/item/ammo_magazine/flamer_tank/internal/internal_tank = flamer_bag.tank
		if(internal_tank.current_rounds == internal_tank.max_rounds)
			return ..()
		var/fuel_to_transfer = min(reagents.total_volume, (internal_tank.max_rounds - internal_tank.current_rounds))
		reagents.remove_reagent(/datum/reagent/fuel, fuel_to_transfer)
		internal_tank.current_rounds += fuel_to_transfer
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		balloon_alert(user, "Refills")

	else if(istype(I, /obj/item/weapon/twohanded/rocketsledge))
		var/obj/item/weapon/twohanded/rocketsledge/RS = I
		if(RS.reagents.get_reagent_amount(/datum/reagent/fuel) == RS.max_fuel || !reagents.total_volume)
			return ..()

		var/fuel_transfer_amount = min(reagents.total_volume, (RS.max_fuel - RS.reagents.get_reagent_amount(/datum/reagent/fuel)))
		reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		RS.reagents.add_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		balloon_alert(user, "Refills")
		RS.update_icon()

	else
		balloon_alert(user, "Only works with welders and flamethrowers")


/obj/item/tool/weldpack/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) // this replaces and improves the get_dist(src,O) <= 1 checks used previously
		return
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume < max_fuel)
		O.reagents.trans_to(src, max_fuel)
		balloon_alert(user, "Refills pack from the tank")
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return
	else if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume == max_fuel)
		balloon_alert(user, "Already full")
		return

/obj/item/tool/weldpack/examine(mob/user)
	. = ..()
	. += "[reagents.total_volume] units of welding fuel left!"

/obj/item/tool/weldpack/marinestandard
	name = "M-22 welding kit"
	desc = "A heavy-duty, portable fuel carrier. Mainly used in flamethrowers. Welder and flamer compatible."
	flags_equip_slot = ITEM_SLOT_BACK
	icon_state = "marine_flamerpack"
	w_class = WEIGHT_CLASS_BULKY
	max_fuel = 500 //Because the marine backpack can carry 260, and still allows you to take items, there should be a reason to still use this one.

/obj/item/tool/handheld_charger
	name = "handheld charger"
	desc = "A hand-held, lightweight cell charger. It isn't going to give you tons of power, but it can help in a pinch."
	icon = 'icons/obj/items/tools.dmi'
	icon_state = "handheldcharger_black_empty"
	item_state = "handheldcharger_black_empty"
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = CONDUCT
	force = 6
	throw_speed = 2
	throw_range = 9
	flags_equip_slot = ITEM_SLOT_BELT
	/// This is the cell we ar charging
	var/obj/item/cell/cell
	///Are we currently recharging something.
	var/recharging = FALSE

/obj/item/tool/handheld_charger/Initialize(mapload)
	. = ..()
	cell = null

/obj/item/tool/handheld_charger/attack_self(mob/user)
	if(!cell)
		balloon_alert(user, "Needs a cell")
		return

	if(cell.charge >= cell.maxcharge)
		balloon_alert(user, "Fully charged")
		return

	if(user.do_actions)
		balloon_alert(user, "Too busy")
		return

	while(do_after(user, 1 SECONDS, NONE, src, BUSY_ICON_GENERIC))
		cell.charge = min(cell.charge + 200, cell.maxcharge)
		balloon_alert(user, "Charges the cell")
		playsound(user, 'sound/weapons/guns/interact/rifle_reload.ogg', 15, 1, 5)
		flick("handheldcharger_black_pumping", src)
		if(cell.charge >= cell.maxcharge)
			balloon_alert(user, "Fully charged")
			return
	balloon_alert(user, "Stops charging")


/obj/item/tool/handheld_charger/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!istype(I, /obj/item/cell))
		return
	if(I.w_class > WEIGHT_CLASS_NORMAL)
		balloon_alert(user, "Too large")
		return
	if(!user.drop_held_item())
		return

	if(cell) //hotswapping
		cell.update_icon()
		user.put_in_hands(cell)
		cell = null

	I.forceMove(src)
	cell = I
	cell.update_icon()
	balloon_alert(user, "Charge Remaining: [cell.charge]/[cell.maxcharge]")
	playsound(user, 'sound/weapons/guns/interact/rifle_reload.ogg', 20, 1, 5)
	icon_state = "handheldcharger_black"

/obj/item/tool/handheld_charger/attack_hand_alternate(mob/living/user)
	if(!cell)
		return ..()
	cell.update_icon()
	user.put_in_active_hand(cell)
	cell = null
	playsound(user, 'sound/machines/click.ogg', 20, 1, 5)
	balloon_alert(user, "Removes the cell")
	icon_state = "handheldcharger_black_empty"

/obj/item/tool/handheld_charger/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() != src)
		return ..()
	if(!cell)
		return ..()
	cell.update_icon()
	user.put_in_active_hand(cell)
	cell = null
	playsound(user, 'sound/machines/click.ogg', 20, 1, 5)
	balloon_alert(user, "Removes the cell")
	icon_state = "handheldcharger_black_empty"

/obj/item/tool/handheld_charger/Destroy()
	QDEL_NULL(cell)
	return ..()
