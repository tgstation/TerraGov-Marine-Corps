//Machine to hold a deployed gun. It aquired nearly all of its variables from the gun itself.
/obj/machinery/deployable/mounted

	anchored = TRUE
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	use_power = FALSE
	max_integrity = 100
	soft_armor = list("melee" = 0, "bullet" = 50, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 0)
	hud_possible = list(MACHINE_HEALTH_HUD, SENTRY_AMMO_HUD)

///generates the icon based on how much ammo it has.
/obj/machinery/deployable/mounted/update_icon_state(mob/user)
	. = ..()
	var/obj/item/weapon/gun/gun = internal_item
	if(!gun.current_mag)
		icon_state = default_icon_state + "_e"
	else
		icon_state = default_icon_state
	hud_set_gun_ammo()

/obj/machinery/deployable/mounted/Initialize(mapload, _internal_item)
	. = ..()
	if(!istype(internal_item, /obj/item/weapon/gun))
		CRASH("[internal_item] was attempted to be deployed within the type /obj/machinery/deployable/mounted without being a gun]")
	
	var/obj/item/weapon/gun/new_gun = internal_item 

	if(istype(new_gun.current_mag, /obj/item/ammo_magazine/internal) || istype(new_gun, /obj/item/weapon/gun/launcher))
		CRASH("[new_gun] has been deployed, however it is incompatible because of either an internal magazine, or it is a launcher.")


///This is called when a user tries to operate the gun
/obj/machinery/deployable/mounted/interact(mob/user)
	if(!ishuman(user))
		return TRUE
	var/mob/living/carbon/human/human_user = user
	if(get_step(src, REVERSE_DIR(dir)) != human_user.loc) //cant man the gun from the barrels side
		to_chat(human_user, "<span class='warning'>You should be behind [src] to man it!</span>")
		return TRUE
	if(operator) //If there is already a operator then they're manning it.
		if(!operator.interactee)
			stack_trace("/obj/machinery/deployable/mounted/interact(mob/user) called by user [human_user] with an operator with a null interactee: [operator].")
			operator = null //this shouldn't happen, but just in case
		to_chat(human_user, "<span class='warning'>Someone's already controlling it.</span>")
		return TRUE
	if(human_user.interactee) //Make sure we're not manning two guns at once, tentacle arms.
		human_user.unset_interaction()
	if(issynth(human_user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
		to_chat(human_user, "<span class='warning'>Your programming restricts operating heavy weaponry.</span>")
		return TRUE
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 7)
	do_attack_animation(src, ATTACK_EFFECT_GRAB)
	visible_message("[icon2html(src, viewers(src))] <span class='notice'>[human_user] mans the [src]!</span>",
		"<span class='notice'>You man the gun!</span>")

	return ..()


/obj/machinery/deployable/mounted/attackby(obj/item/I, mob/user, params) //This handles reloading the gun, if its in acid cant touch it.
	. = ..()

	if(!ishuman(user))
		return

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return

	reload(user, I)


///Reloads gun
/obj/machinery/deployable/mounted/proc/reload(mob/user, ammo_magazine)
	if(!istype(ammo_magazine, /obj/item/ammo_magazine))
		return

	var/obj/item/ammo_magazine/ammo = ammo_magazine
	var/obj/item/weapon/gun/gun = internal_item
	if(!istype(gun, ammo.gun_type))
		return
	if(ammo.current_rounds <= 0)
		to_chat(user, "<span class='warning'>[ammo] is empty!</span>")
		return

	if(gun.current_mag)
		gun.unload(user,0,1)
		update_icon_state()

	var/tac_reload_time = max(0.5 SECONDS, 1.5 SECONDS - user.skills.getRating("firearms") * 5)
	if(!do_after(user, tac_reload_time, TRUE, src, BUSY_ICON_FRIENDLY))
		return
	
	gun.reload(user, ammo_magazine)
	update_icon_state()

///Sets the user as manning the internal gun
/obj/machinery/deployable/mounted/on_set_interaction(mob/user)
	operator = user

	. = ..()

	var/obj/item/weapon/gun/gun = internal_item

	if(!gun)
		CRASH("[src] has been deployed and attempted interaction with [operator] without having a gun. This shouldn't happen.")

	RegisterSignal(operator, COMSIG_MOB_MOUSEDOWN, .proc/start_fire)
	RegisterSignal(operator, COMSIG_MOB_MOUSEDRAG, .proc/change_target)

	for(var/datum/action/action AS in gun.actions)
		action.give_action(operator)
	var/obj/screen/ammo/hud = operator.hud_used.ammo
	hud.add_hud(operator, internal_item)
	hud.update_hud(operator, internal_item)

	gun.set_gun_user(operator)


///Begins the Firing Process, does custom checks before calling the guns start_fire()
/obj/machinery/deployable/mounted/proc/start_fire(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER

	var/obj/item/weapon/gun/gun = internal_item

	if(object == src) //Clicking the gun gets off of it.
		var/mob/living/carbon/human/user = source
		user.unset_interaction()
		return

	var/target = get_turf_on_clickcatcher(object, operator, params)

	if(!can_fire(target))
		return

	gun.start_fire(source, target, location, control, params, TRUE)

///Happens when you drag the mouse.
/obj/machinery/deployable/mounted/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	over_object = get_turf_on_clickcatcher(over_object, operator)

	if(!can_fire(over_object))
		return

	var/obj/item/weapon/gun/gun = internal_item

	gun.change_target(source, src_object, over_object, src_location, over_location, src_control, over_control, params)

///Checks if you can fire
/obj/machinery/deployable/mounted/proc/can_fire(atom/object)
	if(!object)
		return FALSE
	if(operator.lying_angle || !Adjacent(operator) || operator.incapacitated() || get_step(src, REVERSE_DIR(dir)) != operator.loc)
		operator.unset_interaction()
		return FALSE
	if(operator.get_active_held_item())
		to_chat(operator, "<span class='warning'>You need a free hand to shoot the [src].</span>")
		return FALSE

	var/atom/target = object

	if(!istype(target))
		return FALSE

	if(isnull(operator.loc) || isnull(loc) || !z || !target?.z == z)
		return FALSE


	var/angle = get_dir(src, target)
	var/obj/item/weapon/gun/gun = internal_item
	//we can only fire in a 90 degree cone
	if((dir & angle) && target.loc != loc && target.loc != operator.loc)
		operator.setDir(dir)
		gun.set_target(target)
		update_icon_state()
		return TRUE
	if(CHECK_BITFIELD(gun.flags_item, DEPLOYED_NO_ROTATE))
		to_chat(operator, "This one is anchored in place and cannot be rotated.")
		return FALSE

	var/list/leftright = LeftAndRightOfDir(dir)
	var/left = leftright[1] - 1
	var/right = leftright[2] + 1
	if(!(left == (angle-1)) && !(right == (angle+1)))
		to_chat(operator, "<span class='warning'> [src] cannot be rotated so violently.</span>")
		return FALSE
	var/turf/move_to = get_step(src, REVERSE_DIR(angle))
	var/mob/living/carbon/human/user = operator

	if(!operator.Move(move_to))
		to_chat(operator, "You cannot rotate [src] that way.")
		return FALSE

	setDir(angle)
	user.set_interaction(src)
	playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
	operator.visible_message("[operator] rotates the [src].","You rotate the [src].")
	return FALSE


///Unsets the user from manning the internal gun
/obj/machinery/deployable/mounted/on_unset_interaction(mob/user)
	if(!operator)
		return

	UnregisterSignal(operator, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEDRAG))
	var/obj/item/weapon/gun/gun = internal_item
	gun.UnregisterSignal(operator, COMSIG_MOB_MOUSEUP)

	for(var/datum/action/action AS in gun.actions)
		action.remove_action(operator)
	var/obj/screen/ammo/hud = operator.hud_used.ammo
	hud.remove_hud(operator)

	for(var/attachable in gun.attachments)
		if(!istype(attachable, /obj/item/attachable/scope))
			continue
		var/obj/item/attachable/scope/scope = attachable
		scope.zoom_item_turnoff(operator, operator)

	operator.client?.view_size.reset_to_default()

	operator = null
	gun?.set_gun_user(null)

///makes sure you can see and or use the gun
/obj/machinery/deployable/mounted/check_eye(mob/user)
	if(user.lying_angle || !Adjacent(user) || user.incapacitated() || !user.client)
		user.unset_interaction()
