/mob/living/carbon/verb/give()
	set category = "IC"
	set name = "Give"
	var/mob/living/carbon/human/is_giving = usr
	is_giving.do_give()

///Signal handler for give keybind
/mob/living/carbon/proc/give_signal_handler()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/do_give)

///Look for a nearby human to give the held item, and ask him if he wants it
/mob/living/carbon/proc/do_give()
	if(stat != CONSCIOUS)
		return
	if(!hand && r_hand == null)
		to_chat(usr, "<span class='warning'>You don't have anything in your right hand to give.</span>")
		return
	if(hand && l_hand == null)
		to_chat(usr, "<span class='warning'>You don't have anything in your left hand to give.</span>")
		return
	var/mob/living/carbon/to_give_to
	for(var/mob/living/carbon/human AS in cheap_get_humans_near(src, 1))
		if(human.stat == CONSCIOUS && human.client && src != human)
			to_give_to = human
			break
	if(!to_give_to)
		return
	var/obj/item/item
	if(hand)
		item = l_hand
	else if(!hand)
		item = r_hand
	if(!istype(item) || (item.flags_item & (DELONDROP|NODROP)))
		return
	if(to_give_to.r_hand && to_give_to.l_hand)
		to_chat(src, "<span class='warning'>[to_give_to]'s hands are full.</span>")
		return
	if(tgui_alert(to_give_to, "[src] wants to give you \a [item]?", null, list("Yes","No")) != "Yes")
		return
	if(!Adjacent(to_give_to))
		to_chat(src, "<span class='warning'>You need to stay in reaching distance while giving an object.</span>")
		to_chat(to_give_to, "<span class='warning'>[src] moved too far away.</span>")
		return
	if((hand && l_hand != item) || (!hand && r_hand != item))
		to_chat(src, "<span class='warning'>You need to keep the item in your active hand.</span>")
		to_chat(to_give_to, "<span class='warning'>[src] seem to have given up on giving [item] to you.</span>")
		return
	if(to_give_to.r_hand != null && to_give_to.l_hand != null)
		to_chat(src, "<span class='warning'>[to_give_to]'s hands are full.</span>")
		to_chat(to_give_to, "<span class='warning'>Your hands are full.</span>")
		return
	if(!drop_held_item())
		return
	if(!to_give_to.put_in_hands(item))
		return
	visible_message("<span class='notice'>[src] hands [item] to [to_give_to].</span>",
	"<span class='notice'>You hand [item] to [to_give_to].</span>", null, 4)
