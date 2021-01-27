/obj/item/jetpack_marine
	name = "marine jetpack"
	desc = "A high powered jetpack with enough fuel to send a person flying for a short while. It allows for fast and agile movement on the battlefield. <b>Alt click to fly to a destination when the jetpack is equipped.</b>"
	icon = 'icons/obj/items/jetpack.dmi'
	icon_state = "jetpack_marine"
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	var/fuel_max = 60 ///maximum amount of fuel in the jetpack
	var/fuel_left = 60 ///current amount of fuel in the jetpack
	var/fuel_indicator = 40 ///threshold to change the jetpack fuel indicator
	var/fuel_use = 5 ///how much fuel we use every flight
	var/range = 6 ///how far the jetpack can fly in one burst
	var/speed = 1 ///How quick you will fly (warning, it rounds up to the nearest integer)
	var/hovering_time = 1 SECONDS ///How long the jetpack allows you to fly over things
	var/image/fuel_indicator_overlay ///image overlay off the fuel indicator
	COOLDOWN_DECLARE(cooldown_jetpack)

/obj/item/jetpack_marine/Initialize()
	. = ..()
	fuel_indicator_overlay = image('icons/obj/items/jetpack.dmi', src, "+jetpackfull")
	add_overlay(fuel_indicator_overlay)
	
/obj/item/jetpack_marine/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_BACK)
		RegisterSignal(user, COMSIG_MOB_CLICK_ALT, .proc/try_to_use_jetpack)

/obj/item/jetpack_marine/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOB_CLICK_ALT)

/obj/item/jetpack_marine/proc/try_to_use_jetpack(datum/source, atom/A) ///Check if we can use the jetpack and throw the user at the atom if possible
	var/mob/living/carbon/human/human_user = usr
	if (use_jetpack(human_user))
		change_icon_lit(TRUE)
		COOLDOWN_START(src, cooldown_jetpack, 10 SECONDS)
		human_user.fly_at(A,range,speed,hovering_time)
		addtimer(CALLBACK(src,.proc/change_icon_lit,FALSE), hovering_time)

/obj/item/jetpack_marine/proc/use_jetpack(mob/living/carbon/human/human_user) ///Check if we can use the jetpack and give feedback to the users
	if(!COOLDOWN_CHECK(src,cooldown_jetpack))
		to_chat(human_user,"<span class='warning'>You cannot use the jetpack yet!</span>")
		return FALSE
	else if(fuel_left>=fuel_use)
		playsound(human_user,'sound/items/weldingtool_on.ogg',25)
		fuel_left -= fuel_use
		change_icon_indicator()
		return TRUE
	to_chat(human_user,"<span class='warning'>The jetpack ran out of fuel!</span>")
	return FALSE
	

/obj/item/jetpack_marine/proc/change_icon_lit(lit) ///Add a flame overlay when the jetpack is on
	var/image/I = image('icons/obj/items/jetpack.dmi', src, "+jetpacklit")
	if (lit)
		add_overlay(I)
	else
		cut_overlay(I)
		qdel(I)

/obj/item/jetpack_marine/proc/change_icon_indicator() ///Manage the fuel indicator overlay
	if (fuel_left == fuel_max)
		cut_overlay(fuel_indicator_overlay)
		qdel(fuel_indicator_overlay)
		fuel_indicator_overlay = image('icons/obj/items/jetpack.dmi', src, "+jetpackfull")
		add_overlay(fuel_indicator_overlay)
		return
	else if (fuel_left-fuel_indicator<=0)
		if (fuel_left >= 20)
			cut_overlay(fuel_indicator_overlay)
			qdel(fuel_indicator_overlay)
			fuel_indicator_overlay = image('icons/obj/items/jetpack.dmi', src, "+jetpackhalffull")
			add_overlay(fuel_indicator_overlay)
			fuel_indicator = 20
			return
		else if (fuel_left >= fuel_use)
			cut_overlay(fuel_indicator_overlay)
			qdel(fuel_indicator_overlay)
			fuel_indicator_overlay = image('icons/obj/items/jetpack.dmi', src, "+jetpackalmostempty")
			add_overlay(fuel_indicator_overlay)
			fuel_indicator = fuel_use
			return
		else
			cut_overlay(fuel_indicator_overlay)
			qdel(fuel_indicator_overlay)
			fuel_indicator_overlay = image('icons/obj/items/jetpack.dmi', src, "+jetpackempty")
			add_overlay(fuel_indicator_overlay)
			return

/obj/item/jetpack_marine/afterattack(obj/target, mob/user , flag) //refuel at fueltanks when we run out of fuel

	if(istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(user,target) <= 1)
		var/obj/structure/reagent_dispensers/fueltank/FT = target
		if(FT.reagents.total_volume == 0)
			to_chat(user, "<span class='warning'>Out of fuel!</span>")
			return..()

		var/fuel_transfer_amount = min(FT.reagents.total_volume, (fuel_max - fuel_left))
		FT.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		fuel_left += fuel_transfer_amount
		fuel_indicator = 40
		change_icon_indicator()
		playsound(loc, 'sound/effects/refill.ogg', 30, 1, 3)
		to_chat(user, "<span class='notice'>You refill [src] with [target].</span>")

	else
		..()
