
#define RECALL_DO_COOLDOWN 40 SECONDS
#define RECALL_LINK_COOLDOWN 90 SECONDS
#define RECALL_DO_DELAY 9 SECONDS

//Bluespace recall system
//For returning a weapon to your hand at will like some RPG protagonist.

//DO NOT USE link OR recall AS AN IDENTIFIER

/datum/component/bs_recall
	var/mob/living/carbon/human/wearer
	///Actions that the component provides
	var/list/datum/action/component_actions = list(
		/datum/action/bs_recall/do_recall = .proc/do_recall,
		/datum/action/bs_recall/link_item = .proc/link_item,
	)
	///Currently linked item or lack thereof, to be summoned or lacked
	var/obj/item/linked_item
	///Types that can be linked
	var/static/list/recall_valid_types = list(
		/obj/item/weapon/gun,
		/obj/item/weapon/claymore,
		/obj/item/weapon/combat_knife,
		/obj/item/weapon/twohanded,
		/obj/item/tool/pickaxe/plasmacutter,
		/obj/item/reagent_containers/hypospray,
		/obj/item/reagent_containers/food/snacks, //for the memes.
		/obj/item/tool/extinguisher
	)

	COOLDOWN_DECLARE(recall_do_cooldown)
	COOLDOWN_DECLARE(recall_link_cooldown)

/datum/component/bs_recall/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	var/list/new_actions = list()
	for(var/action_type in component_actions)
		var/new_action = new action_type(src, FALSE)
		new_actions += new_action
		RegisterSignal(new_action, COMSIG_ACTION_TRIGGER, component_actions[action_type])
	component_actions = new_actions

/datum/component/bs_recall/Destroy(force, silent)
	for(var/action in component_actions)
		QDEL_NULL(action)
	wearer = null
	linked_item = null
	return ..()

/datum/component/bs_recall/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), .proc/dropped)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, .proc/equipped)

/datum/component/bs_recall/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED_TO_SLOT))

///Adds additional text for the component when examining the item it is attached to
/datum/component/bs_recall/proc/examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += span_notice("It is linked to [linked_item].")

///Cleans up actions when the suit is unequipped
/datum/component/bs_recall/proc/dropped(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!wearer)
		return
	for(var/datum/action/current_action AS in component_actions)
		current_action.remove_action(wearer)
	wearer = null

///Sets up actions when the suit is equipped
/datum/component/bs_recall/proc/equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(!isliving(equipper))
		return
	wearer = equipper

	for(var/datum/action/current_action AS in component_actions)
		current_action.give_action(wearer)

/datum/component/bs_recall/proc/do_recall_handler(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/do_recall, wearer)
///does it
/datum/component/bs_recall/proc/do_recall()
	if(!COOLDOWN_CHECK(src, recall_do_cooldown))
		wearer.balloon_alert(wearer, "Wait [round(COOLDOWN_TIMELEFT(src, recall_do_cooldown) / 10)] seconds")
		return

	if(isnull(linked_item))
		wearer.balloon_alert(wearer, "Item missing or destroyed")
		return

	if(wearer.z != linked_item.z)
		wearer.balloon_alert(wearer, "Item on different Z-level")
		return

<<<<<<< HEAD
	if(!do_after(wearer, RECALL_DO_DELAY, TRUE, FALSE, BUSY_ICON_FRIENDLY, null, PROGRESS_GENERIC))
		wearer.balloon_alert(wearer, "Interrupted")
		return

=======
	if(!do_after(wearer, 3 SECONDS, TRUE, FALSE, BUSY_ICON_FRIENDLY, null, PROGRESS_GENERIC))
		return

	do_sparks(5, TRUE, linked_item)
>>>>>>> aea35e0e0 (bluespace recall armor module)
	playsound(linked_item, 'sound/effects/phasein.ogg', 50, FALSE)
	linked_item.visible_message("\The [src] suddenly disappears in a flash of light!")
	// |
	linked_item.forceMove(get_turf(wearer))
	// |
	if(wearer.put_in_hands(linked_item))
		wearer.visible_message("\A [linked_item] suddenly appears in [wearer]'s hand!", "\The [linked_item] appears in your hand.")
	else
		wearer.visible_message("\A [linked_item] suddenly appears at [wearer]'s feet!", "\The [linked_item] appears at your feet.")
		playsound(wearer,'sound/effects/phasein.ogg', 50, FALSE)

	COOLDOWN_START(src, recall_do_cooldown, RECALL_DO_COOLDOWN)

/datum/component/bs_recall/proc/link_handler(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/link_item, wearer)
///Links and/or overwrites an active link
/datum/component/bs_recall/proc/link_item()
	SIGNAL_HANDLER
	if(!COOLDOWN_CHECK(src, recall_link_cooldown))
		wearer.balloon_alert(wearer, "Wait [round(COOLDOWN_TIMELEFT(src, recall_link_cooldown) / 10)] seconds")
		return

	var/was_linked = linked_item

	if(wearer.do_actions)
		wearer.balloon_alert(wearer, "Cannot, busy")
		return

	var/obj/item/held_item = wearer.get_held_item()
	if(!held_item)
		wearer.balloon_alert(wearer, "No item selected")
		return

	if(CHECK_BITFIELD(held_item.flags_item, ITEM_ABSTRACT | IS_DEPLOYABLE | NO_RECALL))
		wearer.balloon_alert(wearer, "Incompatible")
		return

	if(!is_type_in_list(held_item, recall_valid_types))
		wearer.balloon_alert(wearer, "Incompatible")
		return

	wearer.balloon_alert(wearer, "Linked[was_linked ? ", old item unlinked" : ""]")
	playsound(wearer,'sound/machines/ping.ogg', 25, FALSE)
	manage_linked(held_item)

///Sets up the link
/datum/component/bs_recall/proc/manage_linked(obj/item/to_link)
	SIGNAL_HANDLER
	if(linked_item)
		DISABLE_BITFIELD(linked_item.flags_item, NO_RECALL)
		UnregisterSignal(linked_item, list(COMSIG_PARENT_QDELETING))
		linked_item = null

	if(!to_link)
		return FALSE

	linked_item = to_link
	ENABLE_BITFIELD(linked_item.flags_item, NO_RECALL)
	RegisterSignal(linked_item, list(COMSIG_PARENT_QDELETING), .proc/manage_linked) //:harm:
	COOLDOWN_START(src, recall_link_cooldown, RECALL_LINK_COOLDOWN)
	return TRUE


/datum/action/bs_recall/do_recall
<<<<<<< HEAD
	name = "Recall"
	action_icon = 'icons/mob/modular/modular_armor_modules.dmi'
	action_icon_state = "mod_recall"
=======
	name = "bs_recall"
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "bs_recall"
>>>>>>> aea35e0e0 (bluespace recall armor module)
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_VALI_HEAL, //Okay maybe I copypasted a bit
	)

/datum/action/bs_recall/link_item
	name = "Link/Unlink"
	action_icon = 'icons/mob/actions.dmi'
	action_icon_state = "vali_weapon_connect"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_VALI_CONNECT, //These keybinds fit though
	)
<<<<<<< HEAD

#undef RECALL_DO_COOLDOWN
#undef RECALL_LINK_COOLDOWN
#undef RECALL_DO_DELAY
=======
>>>>>>> aea35e0e0 (bluespace recall armor module)
