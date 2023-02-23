/obj/item/paper/liason_contract
	name = "paperwork"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "paper"
	item_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	flags_equip_slot = ITEM_SLOT_HEAD
	flags_armor_protection = HEAD
	attack_verb = list("bapped")
	//who produced this paperwork
	var/mob/living/carbon/human/owner
	//who signed this paperwork
	var/mob/living/signer

/obj/item/paper/liason_contract/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/tool/pen) && ishuman(user))
		if(user = owner) //no fair signing your own paperwork
			balloon_alert(user, "Can't")
			return
		user.visible_message(span_notice("[user] begins to fill out the paperwork"), \
		span_notice("You begin to fill out the paperwork..."), null, 5)
		if(!do_after(user, 4.5 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
			return
		signer = user
		span_notice("You fill out the paperwork and sign your name...")

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
