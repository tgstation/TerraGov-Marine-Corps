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

	///Gun that does almost all the work when deployed. This type should not exist with a null 'gun'
	var/obj/item/weapon/gun/gun

	///Icon state for when the gun has no ammo.
	var/icon_empty
	//this is amount of tiles we shift our vision towards guns direction when operated, currently its max is 7
	var/view_tile_offset = 3

/obj/machinery/deployable/mounted/Initialize()
	. = ..()
	prepare_huds()
	for(var/datum/atom_hud/squad/sentry_status_hud in GLOB.huds) //Add to the squad HUD
		sentry_status_hud.add_to_hud(src)

///generates the icon based on how much ammo it has.
/obj/machinery/deployable/mounted/update_icon_state() 

	if(!gun.current_mag)
		icon_state = icon_empty
	else
		icon_state = default_icon
	hud_set_machine_health()
	hud_set_gun_ammo()

///Handles variable transfer from the gun, to the machine.
/obj/machinery/deployable/mounted/deploy(obj/item/weapon/gun/deploying, direction)
	if(istype(deploying.current_mag, /obj/item/ammo_magazine/internal) || istype(deploying, /obj/item/weapon/gun/launcher))
		CRASH("[deploying] has been deployed, however it is incompatible because of either an internal magazine, or it is a launcher.")

	. = ..()

	gun = internal_item

	view_tile_offset = gun.deploy_view_offset

	icon_empty = gun.deploy_icon_empty ? gun.deploy_icon_empty : icon_state

	gun.bypass_checks = TRUE

	update_icon_state()

///Handles dissasembly
/obj/machinery/deployable/mounted/disassemble(mob/user)
	if(deploy_flags & DEPLOYED_NO_PICKUP)
		to_chat(user, "<span class='notice'>The [src] is anchored in place and cannot be disassembled.</span>")
		return
	gun.GetComponent(/datum/component/deployable/).un_deploy(user, src)
	gun = null

	qdel(src)

///Update health hud when damage is taken
/obj/machinery/deployable/mounted/take_damage(damage_amount, damage_type, damage_flag, effects, attack_dir, armour_penetration)
	. = ..()
	hud_set_machine_health()

///This is called when a user tries to operate the gun
/obj/machinery/deployable/mounted/interact(mob/user)
	if(!ishuman(user))
		return TRUE
	var/mob/living/carbon/human/human_user = user
	if(human_user.interactee == src) //If your already using the gun, and click on it again to exit
		human_user.unset_interaction()
		visible_message("[icon2html(src, viewers(src))] <span class='notice'>[human_user] decided to let someone else have a go. </span>",
			"<span class='notice'>You decided to let someone else have a go on the [src] </span>")
		return TRUE
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
		to_chat(human_user, "<span class='warning'>You're already busy!</span>")
		return TRUE
	if(issynth(human_user) && !CONFIG_GET(flag/allow_synthetic_gun_use))
		to_chat(human_user, "<span class='warning'>Your programming restricts operating heavy weaponry.</span>")
		return TRUE

	visible_message("[icon2html(src, viewers(src))] <span class='notice'>[human_user] mans the [src]!</span>",
		"<span class='notice'>You man the gun!</span>")

	update_view(user)

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

///Repairs gun
/obj/machinery/deployable/mounted/welder_act(mob/living/user, obj/item/I)
	if(user.do_actions)
		return FALSE

	var/obj/item/tool/weldingtool/WT = I

	if(!WT.isOn())
		return FALSE

	for(var/obj/effect/xenomorph/acid/A in loc)
		if(A.acid_t == src)
			to_chat(user, "You can't get near that, it's melting!")
			return TRUE

	if(obj_integrity == max_integrity)
		to_chat(user, "<span class='warning'>[src] doesn't need repairs.</span>")
		return TRUE

	if(user.skills.getRating("engineer") < SKILL_ENGINEER_METAL)
		user.visible_message("<span class='notice'>[user] fumbles around figuring out how to repair [src].</span>",
		"<span class='notice'>You fumble around figuring out how to repair [src].</span>")
		var/fumbling_time = 5 SECONDS * ( SKILL_ENGINEER_METAL - user.skills.getRating("engineer") )
		if(!do_after(user, fumbling_time, TRUE, src, BUSY_ICON_BUILD))
			return TRUE

	user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
	"<span class='notice'>You begin repairing the damage to [src].</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)

	if(!do_after(user, 5 SECONDS, TRUE, src, BUSY_ICON_FRIENDLY))
		return TRUE

	if(!WT.remove_fuel(2, user))
		to_chat(user, "<span class='warning'>Not enough fuel to finish the task.</span>")
		return TRUE

	user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
	"<span class='notice'>You repair [src].</span>")
	playsound(loc, 'sound/items/welder2.ogg', 25, TRUE)
	repair_damage(120)
	update_icon_state()
	return TRUE

///Reloads gun
/obj/machinery/deployable/mounted/proc/reload(mob/user, ammo_magazine)
	if(!istype(ammo_magazine, /obj/item/ammo_magazine))
		return

	var/obj/item/ammo_magazine/ammo = ammo_magazine
	
	if(istype(gun, ammo.gun_type))

		if(ammo.current_rounds <= 0)
			to_chat(user, "<span class='warning'>[ammo] is empty!</span>")
			return

		if(gun.current_mag)
			gun.unload(user,0,1)
			update_icon_state()

		var/tac_reload_time = max(0.5 SECONDS, 1.5 SECONDS - user.skills.getRating("firearms") * 5)
		if(!do_after(user, tac_reload_time, TRUE, ammo_magazine))
			return
	
		gun.reload(user, ammo_magazine)
		update_icon_state()

///Sets the user as manning the internal gun
/obj/machinery/deployable/mounted/on_set_interaction(mob/user)
	operator = user

	. = ..()

	if(!gun)
		CRASH("[src] has been deployed and attempted interaction with [user] without having a gun. This shouldn't happen.")
	
	

	RegisterSignal(operator, COMSIG_MOB_MOUSEDOWN, .proc/start_fire)
	gun.RegisterSignal(operator, COMSIG_MOB_MOUSEUP, /obj/item/weapon/gun/proc/stop_fire)
	RegisterSignal(operator, COMSIG_MOB_MOUSEDRAG, .proc/change_target)

	for(var/X in gun.actions)
		var/datum/action/A = X
		A.give_action(operator)
	var/obj/screen/ammo/hud = operator.hud_used.ammo
	gun.hud_enabled ? hud.add_hud(operator) : hud.remove_hud(operator)
	hud.update_hud(operator)

	gun.gun_user = operator

	update_view(operator)

/obj/machinery/deployable/mounted/proc/start_fire(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER

	if(gun.gun_on_cooldown(operator))
		return

	if(QDELETED(object))
		return

	var/target = object

	var/list/modifiers = params2list(params)
	if(istype(target, /obj/screen))
		if(!istype(target, /obj/screen/click_catcher))
			return
		//Happens when you click a black tile
		target = params2turf(modifiers["screen-loc"], get_turf(operator), operator.client)

	if(!can_fire(target))
		return

	gun.set_target(target)

	if(modifiers["right"] || modifiers["middle"] || modifiers["shift"])
		if(gun.active_attachable?.flags_attach_features & ATTACH_WEAPON)
			gun.do_fire_attachment()
		return
	if(gun.gun_firemode == GUN_FIREMODE_SEMIAUTO)
		if(!gun.Fire(TRUE) || gun.windup_checked == WEAPON_WINDUP_CHECKING)
			return
		gun.reset_fire()
		return
	gun.gun_user.client.mouse_pointer_icon = 'icons/effects/supplypod_target.dmi'
	SEND_SIGNAL(gun, COMSIG_GUN_FIRE)

obj/machinery/deployable/mounted/proc/change_target(datum/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(istype(over_object, /obj/screen))
		if(!istype(over_object, /obj/screen/click_catcher))
			return
		var/list/modifiers = params2list(params)
		over_object = params2turf(modifiers["screen-loc"], get_turf(operator), operator.client)

	if(!can_fire(over_object))
		return

	gun.set_target(over_object)
	operator.face_atom(over_object)

/obj/machinery/deployable/mounted/proc/can_fire(atom/object)

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
	var/direction = dir
	//we can only fire in a 90 degree cone
	if((direction & angle) && target.loc != loc && target.loc != operator.loc)
		operator.setDir(direction)
		gun.set_target(target)
		return TRUE
	else if (!(direction & angle) && target.loc != loc && target.loc != operator.loc) // Let us rotate this stuff.
		if(deploy_flags & DEPLOYED_NO_ROTATE)
			to_chat(operator, "This one is anchored in place and cannot be rotated.")
			return FALSE

		var/list/leftright = LeftAndRightOfDir(direction)
		var/left = leftright[1] - 1
		var/right = leftright[2] + 1
		if(left == (angle-1) || right == (angle+1))
			var/turf/w = get_step(src, REVERSE_DIR(angle))
			var/mob/living/carbon/human/user = operator
			if(operator.Move(w))
				setDir(angle)
				user.set_interaction(src)
				playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
				operator.visible_message("[operator] rotates the [src].","You rotate the [src].")
				update_view(operator)
			else
				to_chat(operator, "You cannot rotate [src] that way.")
				return FALSE
		else
			to_chat(operator, "<span class='warning'> [src] cannot be rotated so violently.</span>")
	return FALSE


///Unsets the user from manning the internal gun
/obj/machinery/deployable/mounted/on_unset_interaction(mob/user)
	if(!operator)
		return

	UnregisterSignal(operator, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEDRAG))
	gun.UnregisterSignal(operator, COMSIG_MOB_MOUSEUP)

	for(var/X in gun.actions)
		var/datum/action/A = X
		A.remove_action(operator)
	var/obj/screen/ammo/hud = operator.hud_used.ammo
	hud.remove_hud(operator)

	if(operator.client)	
		operator.client.change_view(WORLD_VIEW)
		operator.client.pixel_x = 0
		operator.client.pixel_y = 0
		operator.client.mouse_pointer_icon = initial(operator.client.mouse_pointer_icon)

	operator = null
	gun?.gun_user = null

///makes sure you can see and or use the gun
/obj/machinery/deployable/mounted/check_eye(mob/user)
	if(user.lying_angle || !Adjacent(user) || user.incapacitated() || !user.client)
		user.unset_interaction()

///Updates view, sets max zoom distance to 7
/obj/machinery/deployable/mounted/proc/update_view(mob/user)
	if(view_tile_offset > 7)
		stack_trace("[src] has its view_tile offset set higher than 7, please don't.")

	user.client.change_view(WORLD_VIEW)
	var/view_offset = view_tile_offset * 32
	switch(dir)
		if(NORTH)
			user.client.pixel_x = 0
			user.client.pixel_y = view_offset
		if(SOUTH)
			user.client.pixel_x = 0
			user.client.pixel_y = -1 * view_offset
		if(EAST)
			user.client.pixel_x = view_offset
			user.client.pixel_y = 0
		if(WEST)
			user.client.pixel_x = -1 * view_offset
			user.client.pixel_y = 0

//Mapbound version, it is initialized directly so it requires a gun to be set with it.
/obj/machinery/deployable/mounted/hsg_nest
	gun = /obj/item/weapon/gun/mounted/hsg_nest

/obj/machinery/deployable/mounted/hsg_nest/Initialize()
	. = ..()
	deploy(new gun(), SOUTH)
