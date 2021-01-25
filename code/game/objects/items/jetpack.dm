#define FULL "full"
#define HALF_FULL "half full"
#define EMPTY "empty"

/obj/item/jetpack_marine
	name = "marine jetpack"
	desc = "Allows for fast and agile movement on the battlefield"
	icon = 'icons/obj/items/jetpack.dmi'
	icon_state = "jetpack_marine"
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK
	var/fuel_max = 60
	var/fuel_left = 60
	var/fuel_indicator = 40
	var/fuel_use = 5 ///how much fuel we use every flight
	var/range = 6 ///how far the jetpack can fly in one burst
	COOLDOWN_DECLARE(cooldown_jetpack)
	var/image/fuel_indicator_overlay

/obj/item/jetpack_marine/Initialize()
	. = ..()
	fuel_indicator_overlay = image('icons/obj/items/jetpack.dmi', src, "+jetpackfull")
	overlays += fuel_indicator_overlay
	
/obj/item/jetpack_marine/equipped(mob/user, slot)
	if(slot == SLOT_BACK)
		user.client.click_intercept |= src

/obj/item/jetpack_marine/dropped(mob/user)
	. = ..()
	user.client.click_intercept -= src

/obj/item/jetpack_marine/InterceptClickOn(mob/user, params, atom/object)
	var/list/pa = params2list(params)
	if (pa["alt"])
		var/mob/living/carbon/human/human_user = user
		if (use_jetpack(human_user))
			change_icon_lit(TRUE)
			COOLDOWN_START(src, cooldown_jetpack, 10 SECONDS)
			human_user.fly_at(object,6,1)

/obj/item/jetpack_marine/proc/use_jetpack(mob/living/carbon/human/human_user)
	if(!COOLDOWN_CHECK(src,cooldown_jetpack))
		to_chat(human_user,"<span class='warning'>You can't use the jetpack yet</span>")
		return FALSE
	else if(fuel_left>=fuel_use)
		playsound(human_user,'sound/items/weldingtool_on.ogg',25)
		fuel_left -= fuel_use
		change_icon_indicator()
		addtimer(CALLBACK(src,.proc/change_icon_lit,FALSE),1.5 SECONDS)
		return TRUE
	to_chat(human_user,"<span class='warning'>The jetpack ran out of fuel</span>")
	return FALSE
	

/obj/item/jetpack_marine/proc/change_icon_lit(lit)
	var/image/I = image('icons/obj/items/jetpack.dmi', src, "+jetpacklit")
	if (lit)
		overlays += I
	else
		overlays -= I
		qdel(I)

/obj/item/jetpack_marine/proc/change_icon_indicator()
	if (fuel_left == fuel_max)
		overlays -= fuel_indicator_overlay
		fuel_indicator_overlay = image('icons/obj/items/jetpack.dmi', src, "+jetpackfull")
		overlays += fuel_indicator_overlay
		fuel_indicator = 40
		return
	else if (fuel_left-fuel_indicator<=0)
		if (fuel_left >= 20)
			overlays -= fuel_indicator_overlay
			fuel_indicator_overlay = image('icons/obj/items/jetpack.dmi', src, "+jetpackhalffull")
			overlays += fuel_indicator_overlay
			fuel_indicator = 20
			return
		else if (fuel_left >= fuel_use)
			overlays -= fuel_indicator_overlay
			fuel_indicator_overlay = image('icons/obj/items/jetpack.dmi', src, "+jetpackalmostempty")
			overlays += fuel_indicator_overlay
			fuel_indicator = fuel_use
			return
		else
			overlays -= fuel_indicator_overlay
			fuel_indicator_overlay = image('icons/obj/items/jetpack.dmi', src, "+jetpackempty")
			overlays += fuel_indicator_overlay
			return

/obj/item/jetpack_marine/afterattack(obj/target, mob/user , flag) //refuel at fueltanks when we run out of ammo.

	if(istype(target, /obj/structure/reagent_dispensers/fueltank) && get_dist(user,target) <= 1)
		var/obj/structure/reagent_dispensers/fueltank/FT = target
		if(FT.reagents.total_volume == 0)
			to_chat(user, "<span class='warning'>Out of fuel!</span>")
			return..()

		var/fuel_transfer_amount = min(FT.reagents.total_volume, (fuel_max - fuel_left))
		FT.reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		fuel_left += fuel_transfer_amount
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		to_chat(user, "<span class='notice'>You refill [src] with [target].</span>")

	else
		..()
