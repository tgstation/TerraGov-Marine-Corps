/obj/item/reagent_containers/jerrycan
	name = "\improper jerry can"
	desc = "A can filled with fuel to light things on fire. It has Absolut Jerry stamped in the side."
	icon = 'icons/obj/items/tank.dmi'
	icon_state = "canister"
	volume = 200
	list_reagents = list(/datum/reagent/fuel = 200)
	///how much fuel we use up per spill
	var/fuel_usage = 10

/obj/item/reagent_containers/jerrycan/afterattack(atom/A, mob/user)
	if(!(get_dist(user,A) <= 1))
		return
	if(isturf(A))
		if(A.density)
			return
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>Theres no fuel left in [src]!</span>")
			return
		new /obj/effect/decal/cleanable/liquid_fuel(A, fuel_usage/2)
		reagents.remove_reagent(/datum/reagent/fuel, fuel_usage)
		user.visible_message("<span class='notice'>[user] splashes some fuel on \the [A]</span>", "<span class='notice'>You splash some fuel on [A]</span>")
	else if(isliving(A))
		var/mob/living/M = A
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>Theres no fuel left in [src]!</span>")
			return
		M.adjust_fire_stacks(10)
		reagents.remove_reagent(/datum/reagent/fuel, fuel_usage)
		to_chat(A, "<span class='warning'>[user] drenches you in fuel from [src]!<span>")
		log_attack("[user] has doused [M] in fuel")

	else if(istype(A, /obj/structure/reagent_dispensers/fueltank))
		var/obj/structure/reagent_dispensers/fueltank/FT = A
		if(FT.reagents.total_volume == 0)
			to_chat(user, "<span class='warning'>Out of fuel!</span>")
			return..()

		var/fuel_transfer_amount = min(FT.reagents.total_volume, (reagents.total_volume - volume)*-1)
		FT.reagents.trans_to(src, fuel_transfer_amount)
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		to_chat(user, "<span class='notice'>You refill [src] with [fuel_transfer_amount] units of fuel.</span>")

	else
		return ..()
