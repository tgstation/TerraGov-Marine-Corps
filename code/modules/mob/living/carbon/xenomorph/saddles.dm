/obj/item/storage/backpack/marine/duffelbag/xenosaddle
	name = "\improper Runner Saddle"
	desc = "A rugged saddle, designed to be worn by runners. You can alt-click to change the style"
	icon = 'icons/Xeno/saddles/saddles.dmi'
	//Same as icon state; We need to cache it so that update icons works later in the code and fetches the right style
	var/style = "cowboybags"
	icon_state = "cowboybags"
	worn_icon_state = null
	storage_type = /datum/storage/backpack/duffelbag/saddle
	///list of selectable styles & the actual name in the DMI file so the user doesn't see the codenames
	var/list/style_list = list(
		"Cowboy (Default)" = "cowboybags",
		"Rugged" = "saddlebags",
	)
	///this is really janky but I need the inverted list to be able to display the player-facing name to the player using the codename as a key (its all shitcode, all the way down)
	var/list/style_list_inverted = list(
		"cowboybags" = "Cowboy (Default)",
		"saddlebags" = "Rugged",
	)

/datum/storage/backpack/duffelbag/saddle
	max_storage_space = 18

/obj/item/storage/backpack/marine/duffelbag/xenosaddle/examine(mob/user)
	. = ..()
	. += span_notice("Its current style is set to [style_list_inverted[style]]")

/obj/item/storage/backpack/marine/duffelbag/xenosaddle/AltClick(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/living_user = user
	if(!living_user.Adjacent(src) || (living_user.get_active_held_item() != src && living_user.get_inactive_held_item() != src))
		return
	var/new_style = tgui_input_list(living_user, "Pick a style", "Pick style", style_list)
	if(!new_style)
		return
	else
		style = style_list[new_style]
		icon_state = style

/obj/item/storage/backpack/marine/duffelbag/xenosaddle/mob_can_equip(mob/user, slot, warning, override_nodrop, bitslot)
	if(!slot || !user)
		return FALSE
	if(HAS_TRAIT(src, TRAIT_NODROP) && slot != SLOT_L_HAND && slot != SLOT_R_HAND && !override_nodrop) //No drops can only be equipped to a hand slot
		if(slot == SLOT_L_HAND || slot == SLOT_R_HAND)
			to_chat(user, span_notice("[src] is stuck to your hand!"))
			return FALSE
	if(isxenorunner(user))
		return TRUE
	return FALSE

/obj/item/storage/backpack/marine/duffelbag/xenosaddle/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!isxenorunner(target))
		return
	var/mob/living/carbon/xenomorph/runner/rouny = target
	if(rouny.back)
		balloon_alert(user,"This runner already has a saddle on!")
		return
	if(rouny.stat == DEAD)
		balloon_alert(user,"This runner is dead!")
		return
	if(!do_after(user, 3 SECONDS, NONE, target))
		return
	///Need to remove the now equipped saddle from the saddlers hand; Equip_to_slot would normally handle this but it doesn't account for it not being a selfequip
	if(src == user.l_hand)
		user.l_hand = null
		src.unequipped(src, SLOT_L_HAND)
		user.update_inv_l_hand()

	else if(src == user.r_hand)
		user.r_hand = null
		src.unequipped(src, SLOT_R_HAND)
		user.update_inv_l_hand()
	rouny.equip_to_slot_if_possible(src,SLOT_BACK,TRUE)

/obj/item/storage/backpack/marine/duffelbag/xenosaddle/equipped(mob/equipper, slot)
	. = ..()
	if(!isxeno(equipper))
		return
	var/mob/living/carbon/xenomorph/rouny = equipper
	var/atom/movable/vis_obj/xeno_wounds/backpack_overlay/backpack_overlay = rouny.backpack_overlay
	backpack_overlay.icon_state = src.style
	ENABLE_BITFIELD(rouny.buckle_flags, CAN_BUCKLE)
	rouny.AddElement(/datum/element/ridable, /datum/component/riding/creature/runner)
	rouny.RegisterSignal(rouny, COMSIG_GRAB_SELF_ATTACK, TYPE_PROC_REF(/mob/living/carbon/xenomorph, grabbed_self_attack))

/obj/item/storage/backpack/marine/duffelbag/xenosaddle/unequipped(mob/unequipper, slot)
	. = ..()
	if(!isxeno(unequipper))
		return
	var/mob/living/carbon/xenomorph/rouny = unequipper
	var/atom/movable/vis_obj/xeno_wounds/backpack_overlay/backpack_overlay = rouny.backpack_overlay
	backpack_overlay.icon_state = ""
	DISABLE_BITFIELD(rouny.buckle_flags, CAN_BUCKLE)
	rouny.RemoveElement(/datum/element/ridable, /datum/component/riding/creature/runner)
	rouny.UnregisterSignal(rouny, COMSIG_GRAB_SELF_ATTACK)

/mob/living/carbon/xenomorph/runner/mouse_buckle_handling(atom/movable/dropping, mob/living/user)
	return
