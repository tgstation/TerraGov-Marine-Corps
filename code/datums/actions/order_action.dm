/datum/action/innate/order
	background_icon_state = "template2"
	///the word used to describe the action when notifying marines
	var/verb_name
	///the type of arrow used in the order
	var/arrow_type
	///the type of the visual added on the ground. If it has no visual type, the order can have any atom has a target
	var/visual_type
	///What skill is needed to have this action
	var/skill_name = SKILL_LEADERSHIP
	///What minimum level in that skill is needed to have that action
	var/skill_min = SKILL_LEAD_EXPERT

/datum/action/innate/order/give_action(mob/M)
	. = ..()
	RegisterSignal(M, COMSIG_ORDER_SENT, PROC_REF(update_button_icon))

/datum/action/innate/order/remove_action(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_ORDER_SENT)

/datum/action/innate/order/Activate()
	active = TRUE
	set_toggle(TRUE)
	SEND_SIGNAL(owner, COMSIG_ORDER_SELECTED, src)
	RegisterSignal(owner, COMSIG_ORDER_SELECTED, PROC_REF(Deactivate_signal_handler))

/// Signal handler for deactivating the order
/datum/action/innate/order/proc/Deactivate_signal_handler()
	SIGNAL_HANDLER
	Deactivate()

/datum/action/innate/order/Deactivate()
	active = FALSE
	set_toggle(FALSE)
	UnregisterSignal(owner, COMSIG_ORDER_SELECTED)

/datum/action/innate/order/can_use_action()
	. = ..()
	if(!.)
		return
	if(owner.stat != CONSCIOUS || TIMER_COOLDOWN_CHECK(owner, COOLDOWN_CIC_ORDERS))
		return FALSE

///Print order visual to all marines squad hud and give them an arrow to follow the waypoint
/datum/action/innate/order/proc/send_order(atom/target, datum/squad/squad, faction = FACTION_TERRAGOV)
	if(!can_use_action())
		return
	to_chat(owner ,span_ordercic("You ordered marines to [verb_name] [get_area(target.loc)]!"))
	owner.playsound_local(owner, "sound/effects/CIC_order.ogg", 10, 1)
	if(visual_type)
		target = get_turf(target)
		new visual_type(target, faction)
	TIMER_COOLDOWN_START(owner, COOLDOWN_CIC_ORDERS, ORDER_COOLDOWN)
	SEND_SIGNAL(owner, COMSIG_ORDER_SENT)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob, update_all_icons_orders)), ORDER_COOLDOWN)
	if(squad)
		for(var/mob/living/carbon/human/marine AS in squad.marines_list)
			marine.receive_order(target, arrow_type, verb_name, faction)
		return TRUE
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == faction)
			human.receive_order(target, arrow_type, verb_name, faction)
	return TRUE

///Update all icons of orders action of the mob
/mob/proc/update_all_icons_orders()
	for(var/datum/action/action AS in actions)
		if(istype(action, /datum/action/innate/order))
			action.update_button_icon()

/**
 * Proc to give a marine an order
 * target : what atom to track
 * arrow_type : what kind of visual arrow will be spawned on the marine
 * verb_name : a word / sentence to describe the order
 */
/mob/living/carbon/human/proc/receive_order(atom/target, arrow_type, verb_name = "rally", faction)
	if(!target || !arrow_type)
		return
	if(!(job.job_flags & JOB_FLAG_CAN_SEE_ORDERS))
		return
	if(z != target.z)
		return
	if(target == src)
		return
	var/hud_type
	if(faction == FACTION_TERRAGOV)
		hud_type = DATA_HUD_SQUAD_TERRAGOV
	else if(faction == FACTION_TERRAGOV_REBEL)
		hud_type = DATA_HUD_SQUAD_REBEL
	else if(faction == FACTION_SOM)
		hud_type = DATA_HUD_SQUAD_SOM
	else
		return
	var/datum/atom_hud/squad/squad_hud = GLOB.huds[hud_type]
	if(!squad_hud.hudusers[src])
		return
	var/atom/movable/screen/arrow/arrow_hud = new arrow_type
	arrow_hud.add_hud(src, target)
	playsound_local(src, "sound/effects/CIC_order.ogg", 20, 1)
	to_chat(src,span_ordercic("Command is urging you to [verb_name] [get_area(get_turf(target))]!"))

/datum/action/innate/order/attack_order
	name = "Send Attack Order"
	action_icon_state = "attack"
	verb_name = "attack the enemy at"
	arrow_type = /atom/movable/screen/arrow/attack_order_arrow
	visual_type = /obj/effect/temp_visual/order/attack_order

//These 'personal' subtypes are the ones not used by overwatch; like what SL or FC gets
/datum/action/innate/order/attack_order/personal
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_ATTACKORDER,
	)

/datum/action/innate/order/attack_order/personal/should_show()
	return owner.skills.getRating(skill_name) >= skill_min

/datum/action/innate/order/attack_order/personal/action_activate()
	var/mob/living/carbon/human/human = owner
	if(send_order(human, human.assigned_squad, human.faction))
		var/message = pick(";ДОБЕЙТЕ ВЫЖИВШИХ!", ";РАЗОТРИТЕ ИХ В ПЫЛЬ!", ";НАКОРМИТЕ ИХ СВИНЦОМ!", ";ВПЕРЁД! В РУКОПАШНУЮ!", ";АТАКОВАТЬ!", ";В АТАКУ!", ";ПЕРЕБЕЙТЕ ИХ!")
		owner.say(message)

/datum/action/innate/order/defend_order
	name = "Send Defend Order"
	action_icon_state = "defend"
	verb_name = "defend our position in"
	arrow_type = /atom/movable/screen/arrow/defend_order_arrow
	visual_type = /obj/effect/temp_visual/order/defend_order

/datum/action/innate/order/defend_order/personal
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_DEFENDORDER,
	)

/datum/action/innate/order/defend_order/personal/should_show()
	return owner.skills.getRating(skill_name) >= skill_min

/datum/action/innate/order/defend_order/personal/action_activate()
	var/mob/living/carbon/human/human = owner
	if(send_order(human, human.assigned_squad, human.faction))
		var/message = pick(";ПРИГНИТЕСЬ!", ";ДЕРЖИМ ЛИНИЮ!", ";ДЕРЖИМ ПОЗИЦИЮ!", ";НИ ШАГУ НАЗАД!", ";СТОЯТЬ И СРАЖАТЬСЯ!", ";В УКРЫТИЕ!", ";ЗАЩИЩАЙТЕ ПОЗИЦИЮ!", ";ПРИГОТОВИТЬСЯ К УДАРУ!", ";ДЕРЖИТЕСЬ!", ";ОНИ ИДУТ!", ";НЕ АТАКОВАТЬ! ЗАЩИЩАТЬСЯ!")
		owner.say(message)

/datum/action/innate/order/retreat_order
	name = "Send Retreat Order"
	action_icon_state = "retreat"
	verb_name = "retreat from"
	visual_type = /obj/effect/temp_visual/order/retreat_order

/datum/action/innate/order/retreat_order/personal
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_RETREATORDER,
	)

/datum/action/innate/order/retreat_order/personal/should_show()
	return owner.skills.getRating(skill_name) >= skill_min

/datum/action/innate/order/retreat_order/personal/action_activate()
	var/mob/living/carbon/human/human = owner
	if(send_order(human, human.assigned_squad, human.faction))
		var/message = pick(";НАЗАД! НАЗАД!", ";ТАКТИЧЕСКОЕ ОТСТУПЛЕНИЕ!", ";НЕ УМРИТЕ! УБЕГАЕМ!", ";БЕГИ ПОКА МОЖЕШЬ!", ";ОТСТУПАЕМ! ПОВТОРЯЮ, ОТСТУПАЕМ!", ";ОТСТУПАЕМ! УХОДИМ!")
		owner.say(message)

/datum/action/innate/order/rally_order
	name = "Send Rally Order"
	action_icon_state = "rally"
	verb_name = "rally to"
	arrow_type = /atom/movable/screen/arrow/rally_order_arrow
	visual_type = /obj/effect/temp_visual/order/rally_order

/datum/action/innate/order/rally_order/personal
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_RALLYORDER,
	)

/datum/action/innate/order/rally_order/personal/should_show()
	return owner.skills.getRating(skill_name) >= skill_min

/datum/action/innate/order/rally_order/personal/action_activate()
	var/mob/living/carbon/human/human = owner
	if(send_order(human, human.assigned_squad, human.faction))
		var/message = pick("ВСЕ КО МНЕ!", "ПЕРЕГРУППИРОВАТЬСЯ!", "ВСЕМ ЗА МНОЙ!", "СОБРАТЬСЯ ВОЗЛЕ МЕНЯ!")
		owner.say(message)
