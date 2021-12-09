
//Underbarrel

/obj/item/attachable/verticalgrip
	name = "vertical grip"
	desc = "A custom-built improved foregrip for better accuracy, moderately faster aimed movement speed, less recoil, and less scatter when wielded especially during burst fire. \nHowever, it also increases weapon size, slightly increases wield delay and makes unwielded fire more cumbersome."
	icon_state = "verticalgrip"
	wield_delay_mod = 0.2 SECONDS
	size_mod = 1
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 20
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -10
	burst_scatter_mod = -1
	accuracy_unwielded_mod = -0.05
	scatter_unwielded_mod = 5
	aim_mode_movement_mult = -0.2


/obj/item/attachable/angledgrip
	name = "angled grip"
	desc = "A custom-built improved foregrip for less recoil, and faster wielding time. \nHowever, it also increases weapon size, and slightly hinders unwielded firing."
	icon_state = "angledgrip"
	wield_delay_mod = -0.3 SECONDS
	size_mod = 1
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 20
	recoil_mod = -1
	scatter_mod = 5
	accuracy_unwielded_mod = -0.1
	scatter_unwielded_mod = 5



/obj/item/attachable/gyro
	name = "gyroscopic stabilizer"
	desc = "A set of weights and balances to stabilize the weapon when burst firing or moving, especially while shooting one-handed. Greatly reduces movement penalties to accuracy. Significantly reduces burst scatter, recoil and general scatter. By increasing accuracy while moving, it let you move faster when taking aim."
	icon_state = "gyro"
	slot = ATTACHMENT_SLOT_UNDER
	scatter_mod = -5
	recoil_mod = -2
	movement_acc_penalty_mod = -0.5
	scatter_unwielded_mod = -10
	recoil_unwielded_mod = -1
	aim_mode_movement_mult = -0.5
	shot_marine_damage_falloff = -0.1

/obj/item/attachable/lasersight
	name = "laser sight"
	desc = "A laser sight placed under the barrel. Significantly increases one-handed accuracy and significantly reduces unwielded penalties to accuracy."
	icon_state = "lasersight"
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 17
	pixel_shift_y = 17
	accuracy_mod = 0.1
	accuracy_unwielded_mod = 0.15


/obj/item/attachable/bipod
	name = "bipod"
	desc = "A simple set of telescopic poles to keep a weapon stabilized during firing. \nGreatly increases accuracy and reduces recoil and scatter when properly placed, but also increases weapon size."
	icon_state = "bipod"
	slot = ATTACHMENT_SLOT_UNDER
	size_mod = 2
	melee_mod = -10
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	///person holding the gun that this is attached to
	var/mob/living/master_user
	///bonus to accuracy when the bipod is deployed
	var/deployment_accuracy_mod = 0.30
	///bonus to recoil when the bipod is deployed
	var/deployment_recoil_mod = -2
	///bonus to scatter applied when the bipod is deployed
	var/deployment_scatter_mod = -20
	///bonus to burst scatter applied when the bipod is deployed
	var/deployment_burst_scatter_mod = -3
	///bonus to aim mode delay by % when the bipod is deployed
	var/deployment_aim_mode_delay_mod = -0.5

/obj/item/attachable/bipod/activate(mob/living/user, turn_off)
	if(bipod_deployed)
		bipod_deployed = FALSE
		to_chat(user, span_notice("You retract [src]."))
		master_gun.aim_slowdown -= 1
		master_gun.wield_delay -= 0.4 SECONDS
		master_gun.accuracy_mult -= deployment_accuracy_mod
		master_gun.recoil -= deployment_recoil_mod
		master_gun.scatter -= deployment_scatter_mod
		master_gun.burst_scatter_mult -= deployment_burst_scatter_mod
		master_gun.remove_aim_mode_fire_delay(name)
		icon_state = "bipod"
		UnregisterSignal(master_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED))
		UnregisterSignal(master_user, COMSIG_MOVABLE_MOVED)
		master_user = null
	else if(turn_off)
		return //Was already offB
	else
		if(user.do_actions)
			return
		if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_BAR))
			return
		if(bipod_deployed)
			return
		bipod_deployed = TRUE
		to_chat(user, span_notice("You deploy [src]."))
		master_user = user
		RegisterSignal(master_user, COMSIG_MOVABLE_MOVED, .proc/retract_bipod)
		RegisterSignal(master_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), .proc/retract_bipod)
		master_gun.aim_slowdown += 1
		master_gun.wield_delay += 0.4 SECONDS
		master_gun.accuracy_mult += deployment_accuracy_mod
		master_gun.recoil += deployment_recoil_mod
		master_gun.scatter += deployment_scatter_mod
		master_gun.burst_scatter_mult += deployment_burst_scatter_mod
		master_gun.add_aim_mode_fire_delay(name, initial(master_gun.aim_fire_delay) * deployment_aim_mode_delay_mod)
		icon_state = "bipod-on"

	for(var/i in master_gun.actions)
		var/datum/action/action_to_update = i
		action_to_update.update_button_icon()

	update_icon()
	return TRUE


/obj/item/attachable/bipod/proc/retract_bipod(datum/source)
	SIGNAL_HANDLER
	if(!ismob(source))
		return
	INVOKE_ASYNC(src, .proc/activate, source, TRUE)
	to_chat(source, span_warning("Losing support, the bipod retracts!"))
	playsound(source, 'sound/machines/click.ogg', 15, 1, 4)


//when user fires the gun, we check if they have something to support the gun's bipod.
/obj/item/attachable/proc/check_bipod_support(obj/item/weapon/gun/G, mob/living/user)
	return FALSE

/obj/item/attachable/bipod/check_bipod_support(obj/item/weapon/gun/G, mob/living/user)
	var/turf/T = get_turf(user)
	for(var/obj/O in T)
		if(O.throwpass && O.density && O.dir == user.dir && O.flags_atom & ON_BORDER)
			return O

	T = get_step(T, user.dir)
	for(var/obj/O in T)
		if((istype(O, /obj/structure/window_frame)))
			return O

	return FALSE

/obj/item/attachable/lace
	name = "pistol lace"
	desc = "A simple lace to wrap around your wrist."
	icon_state = "lace"
	slot = ATTACHMENT_SLOT_MUZZLE //so you cannot have this and RC at once aka balance
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle

/obj/item/attachable/lace/activate(mob/living/user, turn_off)
	if(lace_deployed)
		DISABLE_BITFIELD(master_gun.flags_item, NODROP)
		to_chat(user, span_notice("You feel the [src] loosen around your wrist!"))
		playsound(user, 'sound/weapons/fistunclamp.ogg', 25, 1, 7)
		icon_state = "lace"
	else
		if(user.do_actions)
			return
		if(!do_after(user, 0.5 SECONDS, TRUE, src, BUSY_ICON_BAR))
			return
		to_chat(user, span_notice("You deploy the [src]."))
		ENABLE_BITFIELD(master_gun.flags_item, NODROP)
		to_chat(user, span_warning("You feel the [src] shut around your wrist!"))
		playsound(user, 'sound/weapons/fistclamp.ogg', 25, 1, 7)
		icon_state = "lace-on"

	lace_deployed = !lace_deployed

	for(var/i in master_gun.actions)
		var/datum/action/action_to_update = i
		action_to_update.update_button_icon()

	update_icon()
	return TRUE



/obj/item/attachable/burstfire_assembly
	name = "burst fire assembly"
	desc = "A mechanism re-assembly kit that allows for automatic fire, or more shots per burst if the weapon already has the ability. \nIncreases scatter and decreases accuracy."
	icon_state = "rapidfire"
	slot = ATTACHMENT_SLOT_UNDER
	accuracy_mod = -0.10
	burst_mod = 2
	scatter_mod = 15
	accuracy_unwielded_mod = -0.20
	scatter_unwielded_mod = 20

/obj/item/attachable/hydro_cannon
	name = "TL-84 Hydro Cannon"
	desc = "An integrated component of the TL-84 flamethrower, the hydro cannon fires high pressure sprays of water; mainly to extinguish any wayward allies or unintended collateral damage."
	icon_state = ""
	slot = ATTACHMENT_SLOT_UNDER
	flags_attach_features = GUN_ALLOW_SYNTHETIC
	attachment_action_type = /datum/action/item_action/toggle_hydro
	var/is_active = FALSE

/obj/item/attachable/hydro_cannon/activate(attached_item, mob/living/user, turn_off)
	if(is_active)
		if(user)
			to_chat(user, span_notice("You are no longer using [src]."))
		is_active = FALSE
		overlays -= image('icons/Marine/marine-weapons.dmi', src, "active")
		. = FALSE
	else
		if(user)
			to_chat(user, span_notice("You are now using [src]."))
		is_active = TRUE
		overlays += image('icons/Marine/marine-weapons.dmi', src, "active")
		. = TRUE
	for(var/X in master_gun.actions)
		var/datum/action/A = X
		A.update_button_icon()
	update_icon()

/obj/item/attachable/lever_action
	name = "lever-action conversion kit"
	desc = "Some deranged madman of an armorer decided it was a good idea to be able to make any weapons system a lever-action. This is the product, simply attach it to any weapon and watch as it now needs twice the work to operate."
	icon_state = "lever"
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 15
	pixel_shift_y = 18
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_BYPASS_ALLOWED_LIST //Fuckit. I want to see this on anything.

/obj/item/attachable/lever_action/can_attach(obj/item/attaching_to, mob/attacher)
	. = ..()
	if(!. || !isgun(attaching_to))
		return
	var/obj/item/weapon/gun/gun = attaching_to
	if(CHECK_BITFIELD(gun.reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION))
		to_chat(attacher, span_warning("You cannot attach [src] to a gun that is already manual."))
		return FALSE
	return TRUE

/obj/item/attachable/lever_action/on_attach(attaching_item, mob/user)
	. = ..()
	ENABLE_BITFIELD(master_gun.reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION|AMMO_RECIEVER_UNIQUE_ACTION_LOCKS)
	ENABLE_BITFIELD(master_gun.flags_gun_features, GUN_NO_SPECIAL_SPRITES)
	master_gun.modify_fire_delay(-(master_gun.fire_delay / 2))
	master_gun.cocked_sound = 'sound/weapons/guns/interact/ak47_cocked.ogg'
	master_gun.cocked_message = "You work the lever."
	master_gun.cock_locked_message = "The lever is locked! Fire it first!"
	master_gun.cock_delay = 0 SECONDS

/obj/item/attachable/lever_action/on_detach(detaching_item, mob/user)
	DISABLE_BITFIELD(master_gun.reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION|AMMO_RECIEVER_UNIQUE_ACTION_LOCKS)
	DISABLE_BITFIELD(master_gun.flags_gun_features, GUN_NO_SPECIAL_SPRITES)
	master_gun.modify_fire_delay(master_gun.fire_delay / 2)
	master_gun.cocked_sound = initial(master_gun.cocked_sound)
	master_gun.cocked_message = initial(master_gun.cocked_message)
	master_gun.cock_locked_message = initial(master_gun.cock_locked_message)
	master_gun.cock_delay = initial(master_gun.cock_delay)
	return ..()
