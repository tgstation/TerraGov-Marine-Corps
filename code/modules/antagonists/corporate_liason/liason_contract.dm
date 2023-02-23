/obj/item/paper/liason_contract
	name = "contract"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "paper"
	item_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	flags_equip_slot = ITEM_SLOT_HEAD
	flags_armor_protection = HEAD
	attack_verb = list("bapped")

/datum/objective/proc/give_contract_button(mob/living/carbon/human/M)
	var/datum/action/contracts/contractbutton = new
	contractbutton.give_action(usr)
	to_chat(usr,"<span class='infoplain'><a href='?src=[REF(contractbutton)];report=1'>Summon contract</a></span>")

/datum/objective/proc/give_pen_button(mob/living/carbon/human/M)
	var/datum/action/contracts/pen/penbutton = new
	penbutton.give_action(usr)
	to_chat(usr,"<span class='infoplain'><a href='?src=[REF(penbutton)];report=1'>Summon pen</a></span>")

/datum/action/contracts/pen
	name = "Produce Pen"
	action_icon_state = "signal_transmit"

/datum/action/contracts/pen/action_activate()
	var/obj/item/tool/pen/pentochoose = pick(
		/obj/item/tool/pen,
		/obj/item/tool/pen/blue,
		/obj/item/tool/pen/red,
	)
	var/obj/item/spawnedpen = new pentochoose
	usr.balloon_alert_to_viewers("Pulls out [spawnedpen]")
	usr.put_in_hands(spawnedpen)

/datum/action/contracts
	name = "Produce Contracts"
	action_icon_state = "signal_transmit"

/datum/action/contracts/action_activate()
	var/obj/item/contract = new /obj/item/paper/liason_contract
	usr.balloon_alert_to_viewers("Pulls out [contract]")
	usr.put_in_hands(contract)

/datum/objective/recruitment_drive/post_setup()
	give_contract_button(owner)
	give_pen_button(owner)
