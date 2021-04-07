/datum/action/innate/order
	background_icon_state = "template2"
	///the word used to describe the action when notifying marines
	var/verb_name
	///the type of arrow used in the order
	var/arrow_type
	///the type of the visual added on the ground. If it has no visual type, the order can have any atom has a target
	var/visual_type

/datum/action/innate/order/attack_order
	name = "Send Attack Order"
	action_icon_state = "attack"
	verb_name = "attack the enemy at"
	arrow_type = /obj/screen/arrow/attack_order_arrow
	visual_type = /obj/effect/temp_visual/order/attack_order

/datum/action/innate/order/defend_order
	name = "Send Defend Order"
	action_icon_state = "defend"
	verb_name = "defend our position in"
	arrow_type = /obj/screen/arrow/defend_order_arrow
	visual_type = /obj/effect/temp_visual/order/defend_order

/datum/action/innate/order/retreat_order
	name = "Send Retreat Order"
	action_icon_state = "retreat"
	verb_name = "retreat from"
	visual_type = /obj/effect/temp_visual/order/retreat_order

/datum/action/innate/order/rally_order
	name = "Send Rally Order"
	action_icon_state = "rally"
	verb_name = "rally to"
	arrow_type = /obj/screen/arrow/rally_order_arrow
	///What skill is needed to have this action
	var/skill_name = "leadership"
	///What minimum level in that skill is needed to have that action
	var/skill_min = SKILL_LEAD_EXPERT

/datum/action/innate/order/rally_order/should_show()
	return can_use_action()
	
/datum/action/innate/order/rally_order/can_use_action()
	return owner.skills.getRating(skill_name) >= skill_min

/datum/action/innate/order/rally_order/action_activate()
	if(send_order(owner))
		var/message = pick(";TO ME MY MEN!", ";REGROUP TO ME!", ";FOLLOW MY LEAD!", ";RALLY ON ME!", ";FORWARD!")
		owner.say(message)
	
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
	if(TIMER_COOLDOWN_CHECK(owner, COOLDOWN_CIC_ORDERS))
		to_chat(owner, "<span class='warning'>Your last order was too recent.</span>")
		return FALSE
	TIMER_COOLDOWN_START(owner, COOLDOWN_CIC_ORDERS, ORDER_COOLDOWN)
	to_chat(owner ,"<span class='ordercic'>You ordered marines to [verb_name] [target.loc.name]!</span>")
	owner.playsound_local(owner, "sound/effects/CIC_order.ogg", 10, 1)
	if(visual_type)
		target = get_turf(target)
		new visual_type(target)
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[DATA_HUD_SQUAD]
	var/list/final_list = squad_hud.hudusers
	final_list -= owner //We don't want the eye to have an arrow, it's silly
	var/obj/screen/arrow/arrow_hud
	for(var/hud_user in final_list)
		if(!ishuman(hud_user))
			continue
		if(arrow_type)
			arrow_hud = new arrow_type
			arrow_hud.add_hud(hud_user, target)
		notify_marine(hud_user, target)
	return TRUE

///Send a message and a sound to the marine if he is on the same z level as the turf
/datum/action/innate/order/proc/notify_marine(mob/living/marine, atom/target) ///Send an order to that specific marine if it's on the right z level
	if(marine.z == target.z)
		marine.playsound_local(marine, "sound/effects/CIC_order.ogg", 20, 1)
		to_chat(marine,"<span class='ordercic'>Command is urging you to [verb_name] [target.loc.name]!</span>")
