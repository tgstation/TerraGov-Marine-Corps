//defines special click interactions between mobs and interactees with CLICK_RELAY.
/atom/movable/proc/handle_click(mob/living/carbon/human/user, atom/A, params)
	return FALSE

/obj/item/device/binoculars/tactical/handle_click(mob/living/user, atom/A, list/mods)
	if (mods["ctrl"])
		acquire_target(A, user)
		return TRUE
	return FALSE

/obj/item/weapon/gun/rifle/sniper/M42A/handle_click(mob/living/user, atom/A, list/mods)
	if(mods["ctrl"])
		integrated_laze.acquire_target(A, user)
		return TRUE
	return ..()

/obj/machinery/m56d_hmg/handle_click(mob/living/carbon/human/user, atom/A, list/mods)
	if(mods["middle"] || mods["shift"] || mods["alt"] || !operator || operator != user)
		return FALSE
	if(is_bursting)
		return TRUE
	if(user.lying || !Adjacent(user) || user.is_mob_incapacitated())
		user.unset_interaction()
		return FALSE
	if(user.get_active_held_item())
		to_chat(usr, "<span class='warning'>You need a free hand to shoot the [src].</span>")
		return TRUE
	target = A
	if(!istype(target))
		return FALSE
	if(isnull(operator.loc) || isnull(loc) || !z || !target?.z == z)
		return FALSE
	if(get_dist(target, loc) > 15)
		return TRUE

	if(mods["ctrl"])
		burst_fire = !burst_fire
		burst_fire_toggled = TRUE

	var/angle = get_dir(src,target)
	//we can only fire in a 90 degree cone
	if((dir & angle) && target.loc != loc && target.loc != operator.loc)

		if(!rounds)
			to_chat(user, "<span class='warning'><b>*click*</b></span>")
			playsound(src, 'sound/weapons/gun_empty.ogg', 25, 1, 5)
		else
			process_shot()
		return TRUE

	if(burst_fire_toggled)
		burst_fire = !burst_fire
	return FALSE

/obj/machinery/marine_turret/handle_click(mob/living/carbon/human/user, atom/A, list/mods)
	if(mods["middle"] || mods["shift"] || mods["alt"] || mods["ctrl"])
		return FALSE
	if(!manual_override || !operator || !istype(user) || operator != user || operator.interactee != src || istype(A, /obj/screen))
		return FALSE
	if(is_bursting)
		return TRUE
	if(get_dist(user, src) > 1 || user.is_mob_incapacitated())
		user.visible_message("<span class='notice'>[user] lets go of [src]</span>",
		"<span class='notice'>You let go of [src]</span>")
		state("<span class='notice'>The [name] buzzes: AI targeting re-initialized.</span>")
		user.unset_interaction()
		return FALSE
	if(user.get_active_held_item())
		to_chat(usr, "<span class='warning'>You need a free hand to shoot [src].</span>")
		return TRUE

	target = A
	if(!istype(target))
		return FALSE

	if(target.z != z || !target.z|| !z || isnull(operator.loc) || isnull(loc))
		return FALSE

	if(get_dist(target, loc) > 10)
		return TRUE

	var/dx = target.x - x
	var/dy = target.y - y //Calculate which way we are relative to them. Should be 90 degree cone..
	var/direct

	if(abs(dx) < abs(dy))
		if(dy > 0)
			direct = NORTH
		else
			direct = SOUTH
	else
		if(dx > 0)
			direct = EAST
		else
			direct = WEST

	if(direct == dir && target.loc != loc && target.loc != operator.loc)
		process_shot()
		return TRUE

	return FALSE

//No one but the gunner can gun
//And other checks to make sure you aren't breaking the law
/obj/vehicle/multitile/root/cm_armored/tank/handle_click(mob/living/user, atom/A, list/mods)

	if(istype(A,/obj/screen) || A == src || mods["middle"] || mods["shift"] || mods["alt"])
		return FALSE

	if(!can_use_hp(user))
		return TRUE

	if(!hardpoints.Find(active_hp))
		to_chat(user, "<span class='warning'>Please select an active hardpoint first.</span>")
		return TRUE

	var/obj/item/hardpoint/HP = hardpoints[active_hp]

	if(!HP?.is_ready())
		return TRUE

	if(!HP.firing_arc(A))
		to_chat(user, "<span class='warning'>The target is not within your firing arc.</span>")
		return TRUE

	HP.active_effect(A)
	return TRUE