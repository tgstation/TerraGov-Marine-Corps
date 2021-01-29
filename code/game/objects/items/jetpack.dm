#define FUEL_USE 5

/obj/item/jetpack_marine
	name = "marine jetpack"
	desc = "A high powered jetpack with enough fuel to send a person flying for a short while. It allows for fast and agile movement on the battlefield. <b>Alt click to fly to a destination when the jetpack is equipped.</b>"
	icon = 'icons/obj/items/jetpack.dmi'
	icon_state = "jetpack_marine"
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	///maximum amount of fuel in the jetpack
	var/fuel_max = 60
	///current amount of fuel in the jetpack
	var/fuel_left = 60 
	///threshold to change the jetpack fuel indicator
	var/fuel_indicator = 40 
	///how much fuel we use every flight
	var/range = 6 
	///How quick you will fly (warning, it rounds up to the nearest integer)
	var/speed = 1 
	///How long the jetpack allows you to fly over things
	var/hovering_time = 1 SECONDS 
	///True when jetpack has flame overlay
	var/lit
	COOLDOWN_DECLARE(cooldown_jetpack)

/obj/item/jetpack_marine/Initialize()
	. = ..()
	update_icon()
	
/obj/item/jetpack_marine/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_BACK)
		RegisterSignal(user, COMSIG_MOB_CLICK_ALT, .proc/try_to_use_jetpack)

/obj/item/jetpack_marine/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_CLICK_ALT)

///remove the flame overlay
/obj/item/jetpack_marine/proc/reset_flame()
	lit = FALSE
	update_icon()

///Signal handler for alt click, when the user want to fly at an atom
/obj/item/jetpack_marine/proc/try_to_use_jetpack(datum/source, atom/A) 
	SIGNAL_HANDLER
	var/mob/living/carbon/human/human_user = usr
	if (use_jetpack(human_user))
		COOLDOWN_START(src, cooldown_jetpack, 10 SECONDS)
		lit = TRUE
		playsound(human_user,'sound/items/weldingtool_on.ogg',25)
		fuel_left -= FUEL_USE
		change_fuel_indicator()
		update_icon()
		human_user.fly_at(A,range,speed,hovering_time)
		addtimer(CALLBACK(src,.proc/reset_flame), hovering_time)

///Check if we can use the jetpack and give feedback to the users
/obj/item/jetpack_marine/proc/use_jetpack(mob/living/carbon/human/human_user)
	if(!COOLDOWN_CHECK(src,cooldown_jetpack))
		to_chat(human_user,"<span class='warning'>You cannot use the jetpack yet!</span>")
		return FALSE
	if(fuel_left<FUEL_USE)
		to_chat(human_user,"<span class='warning'>The jetpack ran out of fuel!</span>")
		return FALSE
	return TRUE
	
/obj/item/jetpack_marine/update_overlays()
	. = ..()
	if (lit)
		.+= image('icons/obj/items/jetpack.dmi', src, "+jetpacklit")
	var/image/I
	switch(fuel_indicator)
		if(40)
			I = image('icons/obj/items/jetpack.dmi', src, "+jetpackfull")
		if(20)
			I = image('icons/obj/items/jetpack.dmi', src, "+jetpackhalffull")
		if(FUEL_USE)
			I = image('icons/obj/items/jetpack.dmi', src, "+jetpackalmostempty")
		else
			I = image('icons/obj/items/jetpack.dmi', src, "+jetpackempty")
	. += I

///Manage the fuel indicator overlay
/obj/item/jetpack_marine/proc/change_fuel_indicator() 
	if(fuel_left-fuel_indicator<0)
		if (fuel_left >= 20)
			fuel_indicator = 20
			return
		if (fuel_left >= FUEL_USE)
			fuel_indicator = FUEL_USE
			return
		fuel_indicator = 0
		return
	return

/obj/item/jetpack_marine/afterattack(obj/target, mob/user , flag) //refuel at fueltanks when we run out of fuel
	if(istype(target, /obj/structure/reagent_dispensers/fueltank))
		var/obj/structure/reagent_dispensers/fueltank/FT = target
		if(FT.reagents.total_volume == 0)
			to_chat(user, "<span class='warning'>Out of fuel!</span>")
			return..()

		var/fuel_transfer_amount = min(FT.reagents.total_volume, (fuel_max - fuel_left))
		FT.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		fuel_left += fuel_transfer_amount
		fuel_indicator = 40
		update_icon()
		playsound(loc, 'sound/effects/refill.ogg', 30, 1, 3)
		to_chat(user, "<span class='notice'>You refill [src] with [target].</span>")

	else
		..()
