/obj/item/attachable/reddot
	name = "red-dot sight"
	desc = "A red-dot sight for short to medium range. Does not have a zoom feature, but does increase weapon accuracy and fire rate while aiming by a good amount. \nNo drawbacks."
	icon_state = "reddot"
	icon = 'icons/obj/items/guns/attachments/rail.dmi'
	slot = ATTACHMENT_SLOT_RAIL
	accuracy_mod = 0.15
	accuracy_unwielded_mod = 0.1
	aim_mode_movement_mult = -0.35
	variants_by_parent_type = list(/obj/item/weapon/gun/rifle/som = "", /obj/item/weapon/gun/shotgun/som = "")

/obj/item/attachable/m16sight
	name = "M16 iron sights"
	desc = "The iconic carry-handle iron sights for the m16. Usually removed once the user finds something worthwhile to attach to the rail."
	icon_state = "m16sight" // missing icon?
	icon = 'icons/obj/items/guns/attachments/rail.dmi'
	slot = ATTACHMENT_SLOT_RAIL
	accuracy_mod = 0.1
	accuracy_unwielded_mod = 0.05
	movement_acc_penalty_mod = -0.1

/obj/item/attachable/flashlight
	name = "rail flashlight"
	desc = "A simple flashlight used for mounting on a firearm. \nHas no drawbacks, but isn't particuraly useful outside of providing a light source."
	icon_state = "flashlight"
	icon = 'icons/obj/items/guns/attachments/rail.dmi'
	light_mod = 6
	light_system = MOVABLE_LIGHT
	slot = ATTACHMENT_SLOT_RAIL
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	activation_sound = 'sound/items/flashlight.ogg'

/obj/item/attachable/flashlight/activate(mob/living/user, turn_off)
	turn_light(user, turn_off ? !turn_off : !light_on)

/obj/item/attachable/flashlight/turn_light(mob/user, toggle_on, cooldown, sparks, forced, light_again)
	. = ..()

	if(. != CHECKS_PASSED)
		return

	if(ismob(master_gun.loc) && !user)
		user = master_gun.loc

	if(!toggle_on && light_on)
		icon_state = initial(icon_state)
		light_on = FALSE
		master_gun.set_light_range(master_gun.light_range - light_mod)
		master_gun.set_light_power(master_gun.light_power - (light_mod * 0.5))
		if(master_gun.light_range <= 0) //does the gun have another light source
			master_gun.set_light_on(FALSE)
			REMOVE_TRAIT(master_gun, TRAIT_GUN_FLASHLIGHT_ON, GUN_TRAIT)
	else if(toggle_on & !light_on)
		icon_state = initial(icon_state) +"_on"
		light_on = TRUE
		master_gun.set_light_range(master_gun.light_range + light_mod)
		master_gun.set_light_power(master_gun.light_power + (light_mod * 0.5))
		if(!HAS_TRAIT(master_gun, TRAIT_GUN_FLASHLIGHT_ON))
			master_gun.set_light_on(TRUE)
			ADD_TRAIT(master_gun, TRAIT_GUN_FLASHLIGHT_ON, GUN_TRAIT)
	else
		return

	update_icon()

/obj/item/attachable/flashlight/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I,/obj/item/tool/screwdriver))
		to_chat(user, span_notice("You modify the rail flashlight back into a normal flashlight."))
		if(loc == user)
			user.temporarilyRemoveItemFromInventory(src)
		var/obj/item/flashlight/F = new(user)
		user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
		qdel(src) //Delete da old flashlight

/obj/item/attachable/flashlight/under
	name = "underbarreled flashlight"
	desc = "A simple flashlight used for mounting on a firearm. \nHas no drawbacks, but isn't particuraly useful outside of providing a light source."
	icon_state = "uflashlight"
	icon = 'icons/obj/items/guns/attachments/underbarrel.dmi'
	slot = ATTACHMENT_SLOT_UNDER
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION

/obj/item/attachable/quickfire
	name = "quickfire adapter"
	desc = "An enhanced and upgraded autoloading mechanism to fire rounds more quickly. \nHowever, it also reduces accuracy and the number of bullets fired on burst."
	slot = ATTACHMENT_SLOT_RAIL
	icon_state = "autoloader"
	icon = 'icons/obj/items/guns/attachments/rail.dmi'
	accuracy_mod = -0.10
	delay_mod = -0.125 SECONDS
	burst_mod = -1
	accuracy_unwielded_mod = -0.15

/obj/item/attachable/magnetic_harness
	name = "magnetic harness"
	desc = "A magnetically attached harness kit that attaches to the rail mount of a weapon. When dropped, the weapon will sling to a TGMC armor."
	icon_state = "magnetic"
	icon = 'icons/obj/items/guns/attachments/rail.dmi'
	slot = ATTACHMENT_SLOT_RAIL
	pixel_shift_x = 13
	///Handles the harness functionality, created when attached to a gun and removed on detach
	var/datum/component/reequip/reequip_component

/obj/item/attachable/magnetic_harness/on_attach(attaching_item, mob/user)
	. = ..()
	if(!master_gun)
		return
	reequip_component = master_gun.AddComponent(/datum/component/reequip, list(SLOT_S_STORE, SLOT_BELT, SLOT_BACK))

/obj/item/attachable/magnetic_harness/on_detach(attaching_item, mob/user)
	. = ..()
	if(master_gun)
		return
	QDEL_NULL(reequip_component)

/obj/item/attachable/buildasentry
	name = "\improper Build-A-Sentry attachment system"
	icon = 'icons/obj/machines/deployable/sentry/build_a_sentry.dmi'
	icon_state = "build_a_sentry_attachment"
	desc = "The Build-A-Sentry is the latest design in cheap, automated, defense. Simply attach it to the rail of a gun and deploy. Its that easy!"
	slot = ATTACHMENT_SLOT_RAIL
	size_mod = 1
	pixel_shift_x = 10
	pixel_shift_y = 18
	///Deploy time for the build-a-sentry
	var/deploy_time = 2 SECONDS
	///Undeploy tim for the build-a-sentry
	var/undeploy_time = 2 SECONDS

/obj/item/attachable/buildasentry/can_attach(obj/item/attaching_to, mob/attacher)
	if(!isgun(attaching_to))
		return FALSE
	var/obj/item/weapon/gun/attaching_gun = attaching_to
	if(ispath(attaching_gun.deployable_item, /obj/machinery/deployable/mounted/sentry))
		to_chat(attacher, span_warning("[attaching_gun] is already a sentry!"))
		return FALSE
	return ..()

/obj/item/attachable/buildasentry/on_attach(attaching_item, mob/user)
	. = ..()
	ENABLE_BITFIELD(master_gun.item_flags, IS_DEPLOYABLE)
	master_gun.deployable_item = /obj/machinery/deployable/mounted/sentry/buildasentry
	master_gun.turret_flags |= TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS
	master_gun.AddComponent(/datum/component/deployable_item, master_gun.deployable_item, deploy_time, undeploy_time)
	update_icon()

/obj/item/attachable/buildasentry/on_detach(detaching_item, mob/user)
	. = ..()
	var/obj/item/weapon/gun/detaching_gun = detaching_item
	DISABLE_BITFIELD(detaching_gun.item_flags, IS_DEPLOYABLE)
	qdel(detaching_gun.GetComponent(/datum/component/deployable_item))
	detaching_gun.deployable_item = null
	detaching_gun.turret_flags &= ~(TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS)
