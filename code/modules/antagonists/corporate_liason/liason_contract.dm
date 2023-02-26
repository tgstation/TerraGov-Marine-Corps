/obj/item/paper/liason_contract
	name = "paperwork"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "paper_words"
	item_state = "paper_words"
	desc = "A paper filled with dense legalese, it has a blank spot at the bottom for a signature."
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	flags_equip_slot = ITEM_SLOT_HEAD
	flags_armor_protection = HEAD
	attack_verb = list("bapped")
	info =  "Who reads these things anyway"
	//who produced this paperwork
	var/mob/living/carbon/human/owner
	//who signed this paperwork
	var/mob/living/signer

/obj/item/paper/liason_contract/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tool/pen) && ishuman(user))
		if(user == owner) //no fair signing your own paperwork
			balloon_alert(user, "Can't fill your own contract")
			return
		user.visible_message(span_notice("[user] begins to fill out the paperwork"), \
		span_notice("You begin to fill out the paperwork..."), null, 5)
		if(!do_after(user, 4.5 SECONDS, TRUE, src, BUSY_ICON_GENERIC))
			return
		signer = user
		balloon_alert(user, "You fill out the paperwork and sign your name...")
		name = "filled out paperwork"
		desc = "A paper filled with dense legalese, the name of [signer] is at the bottom."

/obj/item/paper/liason_contract/examine(mob/user)
	. = ..()
	return

/datum/action/objectives/contracts/pen
	name = "Produce Pen"
	action_icon_state = "pen_blue"

/datum/action/objectives/contracts/pen/action_activate()
	var/obj/item/tool/pen/pentochoose = pick(
		/obj/item/tool/pen,
		/obj/item/tool/pen/blue,
		/obj/item/tool/pen/red,
	)
	var/obj/item/spawnedpen = new pentochoose
	usr.balloon_alert_to_viewers("Pulls out [spawnedpen]")
	usr.put_in_hands(spawnedpen)

/datum/action/objectives/contracts
	name = "Produce Contracts"
	action_icon_state = "paper_words"

/datum/action/objectives/contracts/action_activate()
	var/obj/item/paper/liason_contract/contract = new /obj/item/paper/liason_contract
	contract.owner = usr
	usr.balloon_alert_to_viewers("Pulls out [contract]")
	usr.put_in_hands(contract)
