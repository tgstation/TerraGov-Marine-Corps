/obj/item/attachable/foldable
	name = "foldable stock"
	desc = "A foldable stock. You shouldn't see this."
	icon = 'icons/obj/items/guns/attachments/stock.dmi'
	slot = ATTACHMENT_SLOT_STOCK
	attach_features_flags = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	///How long it takes to fold or unfold
	var/deploy_time
	///whether the attachment is currently folded or not
	var/folded = TRUE

/obj/item/attachable/foldable/on_attach(attaching_item, mob/user)
	if(!istype(attaching_item, /obj/item/weapon/gun))
		return //Guns only

	master_gun = attaching_item

	if(attachment_action_type)
		var/datum/action/action_to_update = new attachment_action_type(src, master_gun)
		if(isliving(master_gun.loc))
			var/mob/living/living_user = master_gun.loc
			if(master_gun == living_user.l_hand || master_gun == living_user.r_hand)
				action_to_update.give_action(living_user)

	//custom attachment icons for specific guns
	if(length(variants_by_parent_type))
		for(var/selection in variants_by_parent_type)
			if(istype(master_gun, selection))
				icon_state = variants_by_parent_type[selection]

	update_icon()

/obj/item/attachable/foldable/on_detach(detaching_item, mob/user)
	if(!isgun(detaching_item))
		return

	if(!folded)
		activate()

	for(var/datum/action/action_to_update AS in master_gun.actions)
		if(action_to_update.target != src)
			continue
		qdel(action_to_update)
		break

	master_gun = null
	icon_state = initial(icon_state)
	update_icon()

/obj/item/attachable/foldable/activate(mob/living/user, turn_off)
	if(user && deploy_time && !do_after(user, deploy_time, NONE, src, BUSY_ICON_BAR))
		return FALSE

	folded = !folded
	playsound(src, 'sound/machines/click.ogg', 20, FALSE, 4)
	update_icon()

	if(master_gun)
		apply_modifiers(master_gun, user, !folded)

	return TRUE

/obj/item/attachable/foldable/update_icon_state()
	. = ..()
	if(folded)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_open"

/obj/item/attachable/foldable/skorpion_stock
	name = "\improper Skorpion submachinegun wooden stock"
	desc = "A foldable wire stock for a Skorpion submachinegun"
	icon = 'icons/obj/items/guns/attachments/stock_64.dmi'
	icon_state = "skorpion"
	attach_features_flags = ATTACH_ACTIVATION
	pixel_shift_x = 0
	pixel_shift_y = 0
	size_mod = 2
	wield_delay_mod = 0.1 SECONDS
	accuracy_mod = 0.25
	recoil_mod = -2
	scatter_mod = -6
	scatter_unwielded_mod = 4
	accuracy_unwielded_mod = -0.1

/obj/item/attachable/foldable/t19stock
	name = "\improper MP-19 machinepistol stock"
	desc = "A submachinegun stock distributed in small numbers to TGMC forces. Compatible with the MP-19, this stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	attach_features_flags = ATTACH_ACTIVATION
	wield_delay_mod = 0.1 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "t19"
	accuracy_mod = 0.3
	recoil_mod = -2
	scatter_mod = -8
	accuracy_unwielded_mod = -0.1
	scatter_unwielded_mod = 4

/obj/item/attachable/foldable/som_carbine
	name = "\improper V-34 carbine stock"
	desc = "A side folding stock built into the V-34 carbine. The gun is designed to be fired with the stock deployed, but can be done without, with some difficulty."
	attach_features_flags = ATTACH_ACTIVATION
	wield_delay_mod = 0.1 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "v34"
	accuracy_mod = 0.2
	recoil_mod = -2
	scatter_mod = -8
	aim_speed_mod = 0.05

/obj/item/attachable/foldable/icc_machinepistol
	name = "\improper PL-38 machinepistol stock"
	desc = "A submachinegun stock found on ICC subguns, this stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	attach_features_flags = ATTACH_ACTIVATION
	wield_delay_mod = 0.1 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "pl38"
	icon = 'icons/obj/items/guns/attachments/stock_64.dmi'
	accuracy_mod = 0.3
	recoil_mod = -2
	scatter_mod = -8
	accuracy_unwielded_mod = -0.1
	scatter_unwielded_mod = 4

/obj/item/attachable/foldable/t35stock
	name = "\improper SH-35 stock"
	desc = "A non-standard heavy stock for the SH-35 shotgun. Less quick and more cumbersome than the standard issue stakeout, but reduces recoil and improves accuracy. Allegedly makes a pretty good club in a fight too."
	icon = 'icons/obj/items/guns/attachments/stock_64.dmi'
	icon_state = "t35"
	attach_features_flags = ATTACH_ACTIVATION
	wield_delay_mod = 0.2 SECONDS
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -2

/obj/item/attachable/foldable/bipod
	name = "bipod"
	desc = "A simple set of telescopic poles to keep a weapon stabilized during firing. \nGreatly increases accuracy and reduces recoil and scatter when properly placed, but also increases weapon size."
	icon = 'icons/obj/items/guns/attachments/underbarrel.dmi'
	icon_state = "bipod"
	slot = ATTACHMENT_SLOT_UNDER
	size_mod = 2
	deploy_time = 1 SECONDS
	accuracy_mod = 0.3
	recoil_mod = -2
	scatter_mod = -10
	burst_scatter_mod = -3
	aim_mode_delay_mod = -0.5

/obj/item/attachable/foldable/bipod/activate(mob/living/user, turn_off)
	if(folded && !(master_gun.item_flags & WIELDED)) //no one handed bipod use
		if(user)
			balloon_alert(user, "Unwielded")
		return

	. = ..()

	if(folded)
		UnregisterSignal(master_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD))
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		to_chat(user, span_notice("You retract [src]."))
		return

	if(user)
		RegisterSignals(master_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD), PROC_REF(retract_bipod))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(retract_bipod))
		to_chat(user, span_notice("You deploy [src]."))

///Signal handler for forced undeployment
/obj/item/attachable/foldable/bipod/proc/retract_bipod(datum/source, mob/living/user)
	SIGNAL_HANDLER
	deploy_time = 0
	INVOKE_ASYNC(src, PROC_REF(activate), (istype(user) ? user : source), TRUE)
	deploy_time = initial(deploy_time)
	to_chat(user, span_warning("Losing support, the bipod retracts!"))
