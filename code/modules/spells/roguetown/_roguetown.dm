//pseudo ranged or melee ability, invocation on mmb


/obj/effect/proc_holder/spell/invoked
	name = "invoked spell"
	range = -1
	selection_type = "range"
	no_early_release = TRUE
	charge_max = 30
	charge_type = "recharge"
	var/active_sound
	invocation_type = "shout"

/obj/effect/proc_holder/spell/update_icon()
	if(!action)
		return
	action.button_icon_state = "[base_icon_state][active]"
	if(overlay_state)
		action.overlay_state = overlay_state
	action.name = name
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/invoked/Click()
	var/mob/living/user = usr
	if(!istype(user))
		return
	if(!can_cast(user))
		start_recharge()
		deactivate(user)
		return
	if(active)
		deactivate(user)
	else
		if(active_sound)
			user.playsound_local(user,active_sound,100,vary = FALSE)
		active = TRUE
		add_ranged_ability(user, null, TRUE)
		on_activation(user)
	update_icon()
	start_recharge()

/obj/effect/proc_holder/spell/invoked/deactivate(mob/living/user)
	..()
	active = FALSE
	remove_ranged_ability(null)
	on_deactivation(user)

/obj/effect/proc_holder/spell/invoked/proc/on_activation(mob/user)
	return

/obj/effect/proc_holder/spell/invoked/proc/on_deactivation(mob/user)
	return

/obj/effect/proc_holder/spell/invoked/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return FALSE
	if(!cast_check(0, ranged_ability_user))
		return FALSE
	var/list/targets = list(target)
	if(perform(targets, TRUE, user = ranged_ability_user))
		return TRUE

/obj/effect/proc_holder/spell/invoked/projectile
	var/projectile_type = /obj/projectile/magic/teleport
	var/list/projectile_var_overrides = list()
	var/projectile_amount = 1	//Projectiles per cast.
	var/current_amount = 0	//How many projectiles left.
	var/projectiles_per_fire = 1		//Projectiles per fire. Probably not a good thing to use unless you override ready_projectile().

/obj/effect/proc_holder/spell/invoked/projectile/proc/ready_projectile(obj/projectile/P, atom/target, mob/user, iteration)
	return

/obj/effect/proc_holder/spell/invoked/projectile/cast(list/targets, mob/living/user)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return FALSE
	fire_projectile(user, target)
	user.newtonian_move(get_dir(U, T))
	update_icon()
	start_recharge()
	return TRUE

/obj/effect/proc_holder/spell/invoked/projectile/proc/fire_projectile(mob/living/user, atom/target)
	current_amount--
	for(var/i in 1 to projectiles_per_fire)
		var/obj/projectile/P = new projectile_type(user.loc)
		if(istype(P, /obj/projectile/magic/bloodsteal))
			var/obj/projectile/magic/bloodsteal/B = P
			B.sender = user
		P.firer = user
		P.preparePixelProjectile(target, user)
		for(var/V in projectile_var_overrides)
			if(P.vars[V])
				P.vv_edit_var(V, projectile_var_overrides[V])
		ready_projectile(P, target, user, i)
		P.fire()
	return TRUE
