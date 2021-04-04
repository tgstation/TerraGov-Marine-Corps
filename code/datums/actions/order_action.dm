/datum/action/innate/order
	///the word used to describe the action when notifying marines
	var/verb_name
	///the type of arrow used in the order
	var/arrow_type
	///the type of the visual added on the ground
	var/visual_type

/datum/action/innate/order/attack_order
	name = "Send Attack Order"
	background_icon_state = "template2"
	action_icon_state = "attack"
	verb_name = "attack the enemy at"
	arrow_type = /obj/screen/arrow/attack_order_arrow
	visual_type = /obj/effect/temp_visual/order/attack_order

/datum/action/innate/order/defend_order
	name = "Send Defend Order"
	background_icon_state = "template2"
	action_icon_state = "defend"
	verb_name = "defend our position in"
	arrow_type = /obj/screen/arrow/defend_order_arrow
	visual_type = /obj/effect/temp_visual/order/defend_order

/datum/action/innate/order/retreat_order
	name = "Send Retreat Order"
	background_icon_state = "template2"
	action_icon_state = "retreat"
	verb_name = "retreat from"
	visual_type = /obj/effect/temp_visual/order/retreat_order

/datum/action/innate/order/Activate()
	active = TRUE
	add_selected_frame()
	SEND_SIGNAL(owner, COMSIG_ORDER_SELECTED, src)
	RegisterSignal(owner, COMSIG_ORDER_SELECTED, .proc/Deactivate_signal_handler)

/// Signal handler for deactivating the order	
/datum/action/innate/order/proc/Deactivate_signal_handler()
	SIGNAL_HANDLER
	Deactivate()
		
/datum/action/innate/order/Deactivate()
	active = FALSE
	remove_selected_frame()
	UnregisterSignal(owner, COMSIG_ORDER_SELECTED)

///Print order visual to all marines squad hud and give them an arrow to follow the waypoint
/datum/action/innate/order/proc/send_order(atom/target)
	var/turf/target_turf = get_turf(target)
	if(TIMER_COOLDOWN_CHECK(owner, COOLDOWN_CIC_ORDERS))
		to_chat(owner, "<span class='warning'>Your last order was too recent.</span>")
		return
	TIMER_COOLDOWN_START(owner, COOLDOWN_CIC_ORDERS, ORDER_COOLDOWN)
	new visual_type(target_turf)
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[DATA_HUD_SQUAD]
	var/list/final_list = squad_hud.hudusers
	final_list -= owner //We don't want the eye to have an arrow, it's silly
	var/obj/screen/arrow/arrow_hud
	for(var/hud_user in final_list)
		if(!ishuman(hud_user))
			continue
		if(arrow_type)
			arrow_hud = new arrow_type
			arrow_hud.add_hud(hud_user, target_turf)
		notify_marine(hud_user, target_turf)

///Send a message and a sound to the marine if he is on the same z level as the turf
/datum/action/innate/order/proc/notify_marine(mob/living/marine, turf/target_turf) ///Send an order to that specific marine if it's on the right z level
	if(marine.z == target_turf.z)
		marine.playsound_local(marine, "sound/effects/CIC_order.ogg", 10, 1)
		to_chat(marine,"<span class='ordercic'>Command is urging you to [verb_name] [target_turf.loc.name]!</span>")

