//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/* Tools!
 * Note: Multitools are /obj/item/device
 *
 * Contains:
 * 		Wrench
 * 		Screwdriver
 * 		Wirecutters
 * 		Blowtorch
 * 		Crowbar
 */

/*
 * Wrench
 */
/obj/item/tool/wrench
	name = "wrench"
	desc = "A wrench with many common uses. Can be usually found in your hand."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "wrench"
	flags_atom = CONDUCT
	flags_equip_slot = SLOT_WAIST
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	matter = list("metal" = 150)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("bashed", "battered", "bludgeoned", "whacked")


/*
 * Screwdriver
 */
/obj/item/tool/screwdriver
	name = "screwdriver"
	desc = "You can be totally screwwy with this."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "screwdriver"
	flags_atom = CONDUCT
	flags_equip_slot = SLOT_WAIST
	force = 5.0
	w_class = 1.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	matter = list("metal" = 75)
	attack_verb = list("stabbed")

	suicide_act(mob/user)
		user.visible_message(pick("<span class='danger'>[user] is stabbing the [src.name] into \his temple! It looks like \he's trying to commit suicide.</span>", \
							"<span class='danger'>[user] is stabbing the [src.name] into \his heart! It looks like \he's trying to commit suicide.</span>"))
		return(BRUTELOSS)

/obj/item/tool/screwdriver/New()
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

	if (prob(75))
		src.pixel_y = rand(0, 16)
	return

/*/obj/item/tool/screwdriver/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M))	return ..()
	if(user.zone_selected != "eyes") // && user.zone_selected != "head")
		return ..()
	if((CLUMSY in user.mutations) && prob(50))
		M = user
	return eyestab(M,user)*/

/*
 * Wirecutters
 */
/obj/item/tool/wirecutters
	name = "wirecutters"
	desc = "This cuts wires."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "cutters"
	flags_atom = CONDUCT
	flags_equip_slot = SLOT_WAIST
	force = 6.0
	throw_speed = 2
	throw_range = 9
	w_class = 2.0
	matter = list("metal" = 80)
	origin_tech = "materials=1;engineering=1"
	attack_verb = list("pinched", "nipped")
	sharp = IS_SHARP_ITEM_SIMPLE
	edge = 1

/obj/item/tool/wirecutters/New()
	if(prob(50))
		icon_state = "cutters-y"
		item_state = "cutters_yellow"

/obj/item/tool/wirecutters/attack(mob/living/carbon/C, mob/user)
	if((C.handcuffed) && (istype(C.handcuffed, /obj/item/handcuffs/cable)))
		user.visible_message("\The [usr] cuts \the [C]'s restraints with \the [src]!",\
		"You cut \the [C]'s restraints with \the [src]!",\
		"You hear cable being cut.")
		C.handcuffed = null
		C.handcuff_update()
		return
	else
		..()

/*
 * Blowtorch
 */
/obj/item/tool/weldingtool
	name = "blowtorch"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "welder"
	flags_atom = CONDUCT
	flags_equip_slot = SLOT_WAIST

	//Amount of OUCH when it's thrown
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0

	//Cost to make in the autolathe
	matter = list("metal" = 70, "glass" = 30)

	//R&D tech level
	origin_tech = "engineering=1"

	//blowtorch specific stuff
	var/welding = 0 	//Whether or not the blowtorch is off(0), on(1) or currently welding(2)
	var/max_fuel = 20 	//The max amount of fuel the welder can hold
	var/weld_tick = 0	//Used to slowly deplete the fuel when the tool is left on.
	var/status = TRUE //When welder is secured on unsecured

/obj/item/tool/weldingtool/New()
//	var/random_fuel = min(rand(10,20),max_fuel)
	create_reagents(max_fuel)
	reagents.add_reagent("fuel", max_fuel)
	return


/obj/item/tool/weldingtool/Destroy()
	if(welding)
		if(ismob(loc))
			loc.SetLuminosity(-2)
		else
			SetLuminosity(0)
		STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/tool/weldingtool/examine(mob/user)
	..()
	to_chat(user, "It contains [get_fuel()]/[max_fuel] units of fuel!")



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
	if(istype(I,/obj/item/tool/screwdriver))
		flamethrower_screwdriver(src, user)
	else
		. = ..()

/obj/item/tool/weldingtool/attack(mob/M, mob/user)

	if(hasorgans(M))
		var/mob/living/carbon/human/H = M
		var/datum/limb/S = H.get_limb(user.zone_selected)

		if (!S) return
		if(!(S.status & LIMB_ROBOT) || user.a_intent != "help")
			return ..()

		if(isSynth(H))
			if(M == user)
				to_chat(user, "<span class='warning'>You can't repair damage to your own body - it's against OH&S.</span>")
				return

		if(S.brute_dam && welding)
			S.heal_damage(15,0,0,1)
			H.UpdateDamageIcon()
			user.visible_message("<span class='warning'>\The [user] patches some dents on \the [H]'s [S.display_name] with \the [src].</span>", \
								"<span class='warning'>You patch some dents on \the [H]'s [S.display_name] with \the [src].</span>")
			remove_fuel(1,user)
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
	return reagents.get_reagent_amount("fuel")


//Removes fuel from the blowtorch. If a mob is passed, it will perform an eyecheck on the mob. This should probably be renamed to use()
/obj/item/tool/weldingtool/proc/remove_fuel(var/amount = 1, var/mob/M = null)
	if(!welding || !check_fuel())
		return 0
	if(get_fuel() >= amount)
		reagents.remove_reagent("fuel", amount)
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
/obj/item/tool/weldingtool/proc/toggle(var/message = 0)
	var/mob/M
	if(ismob(loc))
		M = loc
	if(!welding)
		if(get_fuel() > 0)
			playsound(loc, 'sound/items/weldingtool_on.ogg', 25)
			welding = 1
			if(M)
				to_chat(M, "<span class='notice'>You switch [src] on.</span>")
				M.SetLuminosity(2)
			else
				SetLuminosity(2)
			weld_tick += 8 //turning the tool on does not consume fuel directly, but it advances the process that regularly consumes fuel.
			force = 15
			damtype = "fire"
			icon_state = "welder1"
			w_class = 4
			heat_source = 3800
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
		heat_source = 0
		if(M)
			if(!message)
				to_chat(M, "<span class='notice'>You switch [src] off.</span>")
			else
				to_chat(M, "<span class='warning'>[src] shuts off!</span>")
			M.SetLuminosity(-2)
			if(M.r_hand == src)
				M.update_inv_r_hand()
			if(M.l_hand == src)
				M.update_inv_l_hand()
		else
			SetLuminosity(0)
		STOP_PROCESSING(SSobj, src)

/obj/item/tool/weldingtool/proc/flamethrower_screwdriver(obj/item/I, mob/user)
	if(welding)
		to_chat(user, "<span class='warning'>Turn it off first!</span>")
		return
	status = !status
	if(status)
		to_chat(user, "<span class='notice'>You resecure [src] and close the fuel tank.</span>")
		container_type = 0
	else
		to_chat(user, "<span class='notice'>[src] can now be refuelled and emptied.</span>")
		container_type = OPENCONTAINER

/obj/item/tool/weldingtool/pickup(mob/user)
	if(welding && loc != user)
		SetLuminosity(0)
		user.SetLuminosity(2)


/obj/item/tool/weldingtool/dropped(mob/user)
	if(welding && loc != user)
		user.SetLuminosity(-2)
		SetLuminosity(2)
	return ..()


/obj/item/tool/weldingtool/largetank
	name = "industrial blowtorch"
	max_fuel = 40
	matter = list("metal" = 70, "glass" = 60)
	origin_tech = "engineering=2"

/obj/item/tool/weldingtool/hugetank
	name = "high-capacity industrial blowtorch"
	max_fuel = 80
	w_class = 3.0
	matter = list("metal" = 70, "glass" = 120)
	origin_tech = "engineering=3"

/obj/item/tool/weldingtool/experimental
	name = "experimental blowtorch"
	max_fuel = 40 //?
	w_class = 3.0
	matter = list("metal" = 70, "glass" = 120)
	origin_tech = "engineering=4;phorontech=3"
	var/last_gen = 0



/obj/item/tool/weldingtool/experimental/proc/fuel_gen()//Proc to make the experimental welder generate fuel, optimized as fuck -Sieve
	var/gen_amount = ((world.time-last_gen)/25)
	reagents += (gen_amount)
	if(reagents > max_fuel)
		reagents = max_fuel

/*
 * Crowbar
 */

/obj/item/tool/crowbar
	name = "crowbar"
	desc = "Used to remove floors and to pry open doors."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "crowbar"
	flags_atom = CONDUCT
	flags_equip_slot = SLOT_WAIST
	force = 5.0
	throwforce = 7.0
	item_state = "crowbar"
	w_class = 2.0
	matter = list("metal" = 50)
	origin_tech = "engineering=1"
	attack_verb = list("attacked", "bashed", "battered", "bludgeoned", "whacked")
	pry_capable = IS_PRY_CAPABLE_CROWBAR

/obj/item/tool/crowbar/red
	icon = 'icons/obj/items/items.dmi'
	icon_state = "red_crowbar"
	item_state = "crowbar_red"





/*
 Welding backpack
*/

/obj/item/tool/weldpack
	name = "Welding kit"
	desc = "A heavy-duty, portable welding fluid carrier."
	flags_equip_slot = SLOT_BACK
	icon = 'icons/obj/items/items.dmi'
	icon_state = "welderpack"
	w_class = 4.0
	var/max_fuel = 600 //Because the marine backpack can carry 260, and still allows you to take items, there should be a reason to still use this one.

/obj/item/tool/weldpack/New()
	var/datum/reagents/R = new/datum/reagents(max_fuel) //Lotsa refills
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)

/obj/item/tool/weldpack/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/tool/weldingtool))
		var/obj/item/tool/weldingtool/T = W
		if(T.welding & prob(50))
			message_admins("[key_name_admin(user)] triggered a fueltank explosion.")
			log_game("[key_name(user)] triggered a fueltank explosion.")
			to_chat(user, "<span class='warning'>That was stupid of you.</span>")
			explosion(get_turf(src),-1,0,2)
			if(src)
				qdel(src)
			return
		else
			if(T.welding)
				to_chat(user, "<span class='warning'>That was close!</span>")
			src.reagents.trans_to(W, T.max_fuel)
			to_chat(user, "<span class='notice'>Welder refilled!</span>")
			playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
			return
	to_chat(user, "<span class='notice'>The tank scoffs at your insolence.  It only provides services to welders.</span>")
	return

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
