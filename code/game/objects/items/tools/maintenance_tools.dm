/obj/item/tool/wrench
	name = "wrench"
	desc = "A wrench with many common uses. Can be usually found in your hand."
	icon = 'icons/obj/items/items.dmi'
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
	icon = 'icons/obj/items/items.dmi'
	icon_state = "screwdriver"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 5.0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	attack_verb = list("stabbed")
	tool_behaviour = TOOL_SCREWDRIVER


/obj/item/tool/screwdriver/suicide_act(mob/user)
	user.visible_message("<span class='danger'>[user] is stabbing the [name] into [user.p_their()] [pick("temple","heart")]! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return(BRUTELOSS)


/obj/item/tool/screwdriver/Initialize()
	. = ..()
	switch(pick("red","blue","purple","brown","green","cyan","yellow"))
		if ("red")
			icon_state = "screwdriver2"
			item_state = "screwdriver"
		if ("blue")
			icon_state = "screwdriver"
			item_state = "screwdriver_blue"
		if ("purple")
			icon_state = "screwdriver3"
			item_state = "screwdriver_purple"
		if ("brown")
			icon_state = "screwdriver4"
			item_state = "screwdriver_brown"
		if ("green")
			icon_state = "screwdriver5"
			item_state = "screwdriver_green"
		if ("cyan")
			icon_state = "screwdriver6"
			item_state = "screwdriver_cyan"
		if ("yellow")
			icon_state = "screwdriver7"
			item_state = "screwdriver_yellow"

	if(prob(75))
		pixel_y = rand(0, 16)


/obj/item/tool/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "cutters"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 6.0
	throw_speed = 2
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("pinched", "nipped")
	sharp = IS_SHARP_ITEM_SIMPLE
	edge = 1
	tool_behaviour = TOOL_WIRECUTTER


/obj/item/tool/wirecutters/Initialize()
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
	icon = 'icons/obj/items/items.dmi'
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
	materials = list(/datum/material/metal = 70, /datum/material/glass = 30)

	//blowtorch specific stuff
	var/welding = 0 	//Whether or not the blowtorch is off(0), on(1) or currently welding(2)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold
	var/weld_tick = 0	//Used to slowly deplete the fuel when the tool is left on.
	var/status = TRUE //When welder is secured on unsecured


/obj/item/tool/weldingtool/Initialize()
	. = ..()
	create_reagents(max_fuel, null, list(/datum/reagent/fuel = max_fuel))


/obj/item/tool/weldingtool/Destroy()
	if(welding)
		STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/tool/weldingtool/examine(mob/user)
	..()
	to_chat(user, "It contains [get_fuel()]/[max_fuel] units of fuel!")


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
		to_chat(user, "<span class='warning'>[src] has to be on to complete this task!</span>")
		return FALSE

	if(get_fuel() < amount)
		to_chat(user, "<span class='warning'>You need more welding fuel to complete this task!</span>")
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

/obj/item/tool/weldingtool/attack(mob/M, mob/user)

	if(hasorgans(M))
		var/mob/living/carbon/human/H = M
		var/datum/limb/S = H.get_limb(user.zone_selected)

		if (!S) return
		if(!(S.limb_status & LIMB_ROBOT) || user.a_intent != INTENT_HELP)
			return ..()

		if(S.brute_dam && welding)
			if(issynth(H) && M == user)
				if(user.action_busy || !do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_BUILD))
					return
			S.heal_limb_damage(15, robo_repair = TRUE, updating_health = TRUE)
			H.UpdateDamageIcon()
			user.visible_message("<span class='warning'>\The [user] patches some dents on \the [H]'s [S.display_name] with \the [src].</span>", \
								"<span class='warning'>You patch some dents on \the [H]'s [S.display_name] with \the [src].</span>")
			remove_fuel(1,user)
			playsound(user.loc, 'sound/items/welder2.ogg', 25, 1)
			return
		else
			to_chat(user, "<span class='warning'>Nothing to fix!</span>")

	else
		return ..()

/obj/item/tool/weldingtool/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity)
		return
	if(!status && O.is_refillable())
		reagents.trans_to(O, reagents.total_volume)
	if (welding)
		remove_fuel(1)

		if(isliving(O))
			var/mob/living/L = O
			L.IgniteMob()
	return


/obj/item/tool/weldingtool/attack_self(mob/user as mob)
	if(!status)
		to_chat(user, "<span class='warning'>[src] can't be turned on while unsecured!</span>")
		return
	toggle()
	return

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
			to_chat(M, "<span class='notice'>You need more welding fuel to complete this task.</span>")
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
				to_chat(M, "<span class='notice'>You switch [src] on.</span>")
			set_light(LIGHTER_LUMINOSITY)
			weld_tick += 8 //turning the tool on does not consume fuel directly, but it advances the process that regularly consumes fuel.
			force = 15
			damtype = "fire"
			icon_state = "welder1"
			w_class = WEIGHT_CLASS_BULKY
			heat = 3800
			START_PROCESSING(SSobj, src)
		else
			if(M)
				to_chat(M, "<span class='warning'>[src] needs more fuel!</span>")
			return
	else
		playsound(loc, 'sound/items/weldingtool_off.ogg', 25)
		force = 3
		damtype = "brute"
		icon_state = "welder"
		welding = 0
		w_class = initial(w_class)
		heat = 0
		if(M)
			if(!message)
				to_chat(M, "<span class='notice'>You switch [src] off.</span>")
			else
				to_chat(M, "<span class='warning'>[src] shuts off!</span>")
			if(M.r_hand == src)
				M.update_inv_r_hand()
			if(M.l_hand == src)
				M.update_inv_l_hand()
		set_light(0)
		STOP_PROCESSING(SSobj, src)

/obj/item/tool/weldingtool/proc/flamethrower_screwdriver(obj/item/I, mob/user)
	if(welding)
		to_chat(user, "<span class='warning'>Turn it off first!</span>")
		return
	status = !status
	if(status)
		to_chat(user, "<span class='notice'>You resecure [src] and close the fuel tank.</span>")
		DISABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER)
	else
		to_chat(user, "<span class='notice'>[src] can now be refuelled and emptied.</span>")
		ENABLE_BITFIELD(reagents.reagent_flags, OPENCONTAINER)

/obj/item/tool/weldingtool/largetank
	name = "industrial blowtorch"
	max_fuel = 40
	materials = list(/datum/material/metal = 70, /datum/material/glass = 60)


/obj/item/tool/weldingtool/hugetank
	name = "high-capacity industrial blowtorch"
	max_fuel = 80
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/metal = 70, /datum/material/glass = 120)


/obj/item/tool/weldingtool/experimental
	name = "experimental blowtorch"
	max_fuel = 40 //?
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/metal = 70, /datum/material/glass = 120)
	var/last_gen = 0



/obj/item/tool/weldingtool/experimental/proc/fuel_gen()//Proc to make the experimental welder generate fuel, optimized as fuck -Sieve
	var/gen_amount = ((world.time-last_gen)/25)
	reagents += (gen_amount)
	if(reagents > max_fuel)
		reagents = max_fuel


/obj/item/tool/crowbar
	name = "crowbar"
	desc = "Used to remove floors and to pry open doors."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "crowbar"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 5.0
	throwforce = 7.0
	item_state = "crowbar"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	pry_capable = IS_PRY_CAPABLE_CROWBAR
	tool_behaviour = TOOL_CROWBAR


/obj/item/tool/crowbar/red
	icon = 'icons/obj/items/items.dmi'
	icon_state = "red_crowbar"
	item_state = "crowbar_red"



/obj/item/tool/weldpack
	name = "Welding kit"
	desc = "A heavy-duty, portable welding fluid carrier."
	flags_equip_slot = ITEM_SLOT_BACK
	icon = 'icons/obj/items/items.dmi'
	icon_state = "welderpack"
	w_class = WEIGHT_CLASS_BULKY
	var/max_fuel = 600 //Because the marine backpack can carry 260, and still allows you to take items, there should be a reason to still use this one.

/obj/item/tool/weldpack/Initialize()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(max_fuel) //Lotsa refills
	reagents = R
	R.my_atom = src
	R.add_reagent(/datum/reagent/fuel, max_fuel)

/obj/item/tool/weldpack/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(iswelder(I))
		var/obj/item/tool/weldingtool/T = I
		if(T.welding & prob(50))
			to_chat(user, "<span class='warning'>That was stupid of you.</span>")
			log_explosion("[key_name(user)] triggered a weldpack explosion at [AREACOORD(user.loc)].")
			explosion(src, light_impact_range = 3)
			qdel(src)
		else
			if(T.welding)
				to_chat(user, "<span class='warning'>That was close!</span>")
			reagents.trans_to(T, T.max_fuel)
			to_chat(user, "<span class='notice'>Welder refilled!</span>")
			playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)

	else
		to_chat(user, "<span class='notice'>The tank scoffs at your insolence.  It only provides services to welders.</span>")


/obj/item/tool/weldpack/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) // this replaces and improves the get_dist(src,O) <= 1 checks used previously
		return
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume < max_fuel)
		O.reagents.trans_to(src, max_fuel)
		to_chat(user, "<span class='notice'>You crack the cap off the top of the pack and fill it back up again from the tank.</span>")
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return
	else if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume == max_fuel)
		to_chat(user, "<span class='notice'>The pack is already full!</span>")
		return

/obj/item/tool/weldpack/examine(mob/user)
	..()
	to_chat(user, "[reagents.total_volume] units of welding fuel left!")
