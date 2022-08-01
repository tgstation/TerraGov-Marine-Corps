/obj/item/reagent_containers/jerrycan
	name = "\improper jerry can"
	desc = "A can filled with fuel to light things on fire. It has Absolut Jerry stamped in the side."
	icon = 'icons/obj/items/tank.dmi'
	icon_state = "canister"
	w_class = WEIGHT_CLASS_BULKY
	volume = 200
	list_reagents = list(/datum/reagent/fuel = 200)
	///how much fuel we use up per spill
	var/fuel_usage = 10

/obj/item/reagent_containers/jerrycan/afterattack(atom/A, mob/user)
	if(!(get_dist(user,A) <= 1))
		return

/obj/item/reagent_containers/jerrycan/attack_turf(turf/A, mob/user)
	. = ..()
	if(A.density)
		return
	if(!reagents.total_volume)
		to_chat(user, span_warning("Theres no fuel left in [src]!"))
		return
	new /atom/movable/effect/decal/cleanable/liquid_fuel(A, fuel_usage/2)
	reagents.remove_reagent(/datum/reagent/fuel, fuel_usage)
	user.visible_message(span_notice("[user] splashes some fuel on \the [A]"), span_notice("You splash some fuel on [A]"))
	log_attack("[key_name(user)] has splashed fuel on  [A] in [AREACOORD(user)]")
	A.add_fingerprint(user, "attack_turf", "doused with fuel from [src]")

/obj/item/reagent_containers/jerrycan/attack(mob/living/M, mob/living/user)
	. = ..()
	if(!reagents.total_volume)
		to_chat(user, span_warning("Theres no fuel left in [src]!"))
		return
	M.adjust_fire_stacks(10)
	reagents.remove_reagent(/datum/reagent/fuel, fuel_usage)
	user.visible_message(span_notice("[user] splashes some fuel on [M]"), span_notice("You splash some fuel on [M]"), ignored_mob = M)
	to_chat(M, "<span class='warning'>[user] drenches you in fuel from [src]!<span>")
	log_attack("[key_name(user)] has doused [M] in fuel in [AREACOORD(user)]")

/obj/item/reagent_containers/jerrycan/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity)
		return
	if(!istype(O, /obj/structure/reagent_dispensers/fueltank))
		return ..()
	var/obj/structure/reagent_dispensers/fueltank/FT = O
	if(FT.reagents.total_volume == 0)
		to_chat(user, span_warning("Out of fuel!"))
		return

	var/fuel_transfer_amount = min(FT.reagents.total_volume, (reagents.total_volume - volume)*-1)
	FT.reagents.trans_to(src, fuel_transfer_amount)
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(user, span_notice("You refill [src] with [fuel_transfer_amount] units of fuel."))
	return ..()

/obj/item/reagent_containers/jerrycan/attack_obj(obj/O, mob/living/user)
	if(istype(O, /obj/alien/weeds))
		return attack_turf(get_turf(O), user)
	return ..()
