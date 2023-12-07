//Machine to hold a deployed gun. It aquired nearly all of its variables from the gun itself.
/obj/machinery/deployable/mounted

	anchored = TRUE
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	layer = TANK_BARREL_LAYER
	use_power = FALSE
	hud_possible = list(MACHINE_HEALTH_HUD, MACHINE_AMMO_HUD)
	allow_pass_flags = PASSABLE
	///Store user old pixel x
	var/user_old_x = 0
	///Store user old pixel y
	var/user_old_y = 0
	///Stores user old move resist and apply on unset interaction
	var/user_old_move_resist
	///If the gun has different sprites for being anchored.
	var/has_anchored_sprite = FALSE

///generates the icon based on how much ammo it has.
/obj/machinery/deployable/mounted/update_icon_state(mob/user)
	. = ..()
	var/obj/item/weapon/gun/gun = get_internal_item()
	if(gun && (!length(gun.chamber_items) || !gun.chamber_items[gun.current_chamber_position]))
		icon_state = default_icon_state + "_e"
	else
		icon_state = default_icon_state

	if(has_anchored_sprite)
		if(anchored)
			icon_state = default_icon_state + "_anchored"
		else
			icon_state = default_icon_state

	hud_set_gun_ammo()

/obj/machinery/deployable/mounted/Initialize(mapload, _internal_item, deployer)
	. = ..()
	if(!istype(get_internal_item(), /obj/item/weapon/gun))
		CRASH("[internal_item] was attempted to be deployed within the type [type] without being a gun]")

	var/obj/item/weapon/gun/new_gun = get_internal_item()

	new_gun?.set_gun_user(null)

/obj/machinery/deployable/mounted/Destroy()
	operator?.unset_interaction()
	return ..()

/obj/machinery/deployable/mounted/AltClick(mob/user)
	. = ..()
	if(!Adjacent(user) || user.lying_angle || user.incapacitated() || !ishuman(user)) //Damn you zack, yoinking mags from pipes as a runner.
		return
	var/obj/item/weapon/gun/internal_gun = get_internal_item()
	internal_gun?.unload(user)
	update_icon()

/obj/machinery/deployable/mounted/attack_hand_alternate(mob/living/user)
	. = ..()
	if(!ishuman(user))
		return
	var/obj/item/weapon/gun/internal_gun = get_internal_item()
	internal_gun?.do_unique_action(user)

/obj/machinery/deployable/mounted/attackby_alternate(obj/item/I, mob/user, params)
	. = ..()
	if(!ishuman(user))
		return
	var/obj/item/weapon/gun/internal_gun = get_internal_item()
	internal_gun?.attackby_alternate(I, user, params)

/obj/machinery/deployable/mounted/attackby(obj/item/I, mob/user, params) //This handles reloading the gun, if its in acid cant touch it.
	. = ..()

	if(!ishuman(user))
		return

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	reload(user, I)

///Reloads the internal_item
/obj/machinery/deployable/mounted/proc/reload(mob/user, ammo_magazine)
	if(HAS_TRAIT(src, TRAIT_GUN_RELOADING))
		to_chat(user, span_warning("The weapon is already being reloaded!"))
		return

	if(user.do_actions)
		to_chat(user, span_warning("You are busy doing something else!"))
		return

	ADD_TRAIT(src, TRAIT_GUN_RELOADING, GUN_TRAIT)

	var/obj/item/weapon/gun/gun = get_internal_item()
	if(length(gun?.chamber_items))
		gun.unload(user)
		update_icon_state()

	gun?.reload(ammo_magazine, user)
	update_icon_state()

	REMOVE_TRAIT(src, TRAIT_GUN_RELOADING, GUN_TRAIT)

	if(!CHECK_BITFIELD(gun?.reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION))
		return
	gun?.do_unique_action(gun, user)



///This is called when a user tries to operate the gun
/obj/machinery/deployable/mounted/interact(mob/user)
	if(!ishuman(user))
		return TRUE
	var/mob/living/carbon/human/human_user = user
	if(get_step(src, REVERSE_DIR(dir)) != human_user.loc) //cant man the gun from the barrels side
		to_chat(human_user, span_warning("You should be behind [src] to man it!"))
		return TRUE
	if(operator) //If there is already a operator then they're manning it.
		if(!operator.interactee)
			stack_trace("/obj/machinery/deployable/mounted/interact(mob/user) called by user [human_user] with an operator with a null interactee: [operator].")
			operator = null //this shouldn't happen, but just in case
		to_chat(human_user, span_warning("Someone's already controlling it."))
		return TRUE
	if(human_user.interactee) //Make sure we're not manning two guns at once, tentacle arms.
		human_user.unset_interaction()
	if(issynth(human_user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
		to_chat(human_user, span_warning("Your programming restricts operating heavy weaponry."))
		return TRUE

	density = FALSE
	if(!user.Move(loc)) //Move instead of forcemove to ensure we can actually get to the object's turf
		density = initial(density)
		return
	density = initial(density)

	playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 7)
	do_attack_animation(src, ATTACK_EFFECT_GRAB)
	visible_message("[icon2html(src, viewers(src))] [span_notice("[human_user] mans the [src]!")]",
		span_notice("You man the gun!"))

	return ..()

///Sets the user as manning the internal gun
/obj/machinery/deployable/mounted/on_set_interaction(mob/user)
	operator = user

	. = ..()

	var/obj/item/weapon/gun/gun = get_internal_item()

	if(!gun)
		CRASH("[src] has been deployed and attempted interaction with [operator] without having a gun. This shouldn't happen.")

	RegisterSignal(operator, COMSIG_MOB_MOUSEDOWN, PROC_REF(start_fire))
	RegisterSignal(operator, COMSIG_MOB_MOUSEDRAG, PROC_REF(change_target))

	for(var/datum/action/action AS in gun.actions)
		action.give_action(operator)

	gun.set_gun_user(operator)
	operator.setDir(dir)
	user_old_x = operator.pixel_x
	user_old_y = operator.pixel_y
	update_pixels(operator, TRUE)
	user_old_move_resist = operator.move_resist
	operator.move_resist = MOVE_FORCE_STRONG

///Updates the pixel offset of user so it looks like their manning the gun from behind
/obj/machinery/deployable/mounted/proc/update_pixels(mob/user, mounting)
	if(!mounting)
		animate(user, pixel_x=user_old_x, pixel_y=user_old_y, 4, 1)
		return
	var/diff_x = 0
	var/diff_y = 0
	switch(dir)
		if(NORTH)
			diff_y = -16 + user_old_y
			diff_x = 0
		if(SOUTH)
			diff_y = 16 + user_old_y
			diff_x = 0
		if(EAST)
			diff_x = -16 + user_old_x
			diff_y = 0
		if(WEST)
			diff_x = 16 + user_old_x
			diff_y = 0
	animate(user, pixel_x=diff_x, pixel_y=diff_y, 0.4 SECONDS)

///Begins the Firing Process, does custom checks before calling the guns start_fire()
/obj/machinery/deployable/mounted/proc/start_fire(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER

	var/obj/item/weapon/gun/gun = get_internal_item()

	var/target = get_turf_on_clickcatcher(object, operator, params)

	if(!can_fire(target))
		return

	gun?.start_fire(source, target, location, control, params, TRUE)

///Happens when you drag the mouse.
/obj/machinery/deployable/mounted/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	over_object = get_turf_on_clickcatcher(over_object, operator)

	if(!can_fire(over_object))
		return

	var/obj/item/weapon/gun/gun = get_internal_item()

	gun?.change_target(source, src_object, over_object, src_location, over_location, src_control, over_control, params)

///Checks if you can fire
/obj/machinery/deployable/mounted/proc/can_fire(atom/object)
	if(!object)
		return FALSE
	if(operator.lying_angle || !Adjacent(operator) || operator.incapacitated() || loc != operator.loc)
		operator.unset_interaction()
		return FALSE
	if(operator.get_active_held_item())
		to_chat(operator, span_warning("You need a free hand to shoot the [src]."))
		return FALSE
	var/atom/target = object

	if(!istype(target))
		return FALSE

	if(isnull(operator.loc) || isnull(loc) || !z || !target?.z == z)
		return FALSE


	var/angle = get_dir(src, target)
	var/obj/item/weapon/gun/gun = get_internal_item()
	//we can only fire in a 90 degree cone
	if((dir & angle) && target.loc != loc && target.loc != operator.loc)
		if(CHECK_BITFIELD(gun.flags_item, DEPLOYED_ANCHORED_FIRING_ONLY) && !anchored)
			to_chat(operator, "[src] cannot be fired without it being anchored.")
			return FALSE
		operator.setDir(dir)
		gun?.set_target(target)
		update_icon_state()
		return TRUE
	if(CHECK_BITFIELD(gun?.flags_item, DEPLOYED_NO_ROTATE))
		to_chat(operator, "This one is anchored in place and cannot be rotated.")
		return FALSE

	if(CHECK_BITFIELD(gun?.flags_item, DEPLOYED_NO_ROTATE_ANCHORED) && anchored)
		to_chat(operator, "[src] cannot be rotated while anchored.")
		return FALSE

	var/list/leftright = LeftAndRightOfDir(dir)
	var/left = leftright[1] - 1
	var/right = leftright[2] + 1
	if(!(left == (angle-1)) && !(right == (angle+1)))
		to_chat(operator, span_warning(" [src] cannot be rotated so violently."))
		return FALSE
	var/mob/living/carbon/human/user = operator

	var/obj/item/attachable/scope/current_scope
	for(var/key in gun.attachments_by_slot)
		var/obj/item/attachable = gun.attachments_by_slot[key]
		if(!attachable || !istype(attachable, /obj/item/attachable/scope))
			continue
		var/obj/item/attachable/scope/scope = attachable
		if(!scope.zoom)
			continue
		scope.zoom_item_turnoff(operator, operator)
		current_scope = scope

	setDir(angle)
	user.set_interaction(src)
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	operator.visible_message("[operator] rotates the [src].","You rotate the [src].")
	update_pixels(user, TRUE)

	if(current_scope?.deployed_scope_rezoom)
		INVOKE_ASYNC(current_scope, TYPE_PROC_REF(/obj/item/attachable/scope, activate), operator)

	return FALSE


///Unsets the user from manning the internal gun
/obj/machinery/deployable/mounted/on_unset_interaction(mob/user)
	if(!operator)
		return

	UnregisterSignal(operator, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEDRAG))
	var/obj/item/weapon/gun/gun = get_internal_item()
	if(HAS_TRAIT(gun, TRAIT_GUN_IS_AIMING))
		gun.toggle_aim_mode(operator)
	gun?.UnregisterSignal(operator, COMSIG_MOB_MOUSEUP)

	for(var/datum/action/action AS in gun.actions)
		action.remove_action(operator)

	for(var/key in gun?.attachments_by_slot)
		var/obj/item/attachable = gun.attachments_by_slot[key]
		if(!attachable || !istype(attachable, /obj/item/attachable/scope))
			continue
		var/obj/item/attachable/scope/scope = attachable
		if(!scope.zoom)
			continue
		scope.zoom_item_turnoff(operator, operator)

	operator.client?.view_size.reset_to_default()

	operator = null
	gun?.set_gun_user(null)
	update_pixels(user, FALSE)
	user_old_x = 0
	user_old_y = 0
	density = initial(density)
	user.move_resist = user_old_move_resist

///makes sure you can see and or use the gun
/obj/machinery/deployable/mounted/check_eye(mob/user)
	if(user.lying_angle || !Adjacent(user) || user.incapacitated() || !user.client)
		user.unset_interaction()

//Deployable guns that can be moved.
/obj/machinery/deployable/mounted/moveable
	anchored = FALSE
	/// Sets how long a deployable takes to be anchored
	var/anchor_time = 0 SECONDS

/// Can be anchored and unanchored from the ground by Alt Right Click.
/obj/machinery/deployable/mounted/moveable/AltRightClick(mob/living/user)
	. = ..()
	if(!Adjacent(user) || !ishuman(user) || user.lying_angle || user.incapacitated())
		return

	if(anchor_time)
		balloon_alert(user, "You begin [anchored ? "unanchoring" : "anchoring"] [src]")
		if(!do_after(user, anchor_time, NONE, src))
			balloon_alert(user, "Interrupted!")
			return

	anchored = !anchored
	update_icon()

	balloon_alert(user, "You [anchored ? "anchor" : "unanchor"] [src]")
