/datum/mutation/human/shock
	name = "Shock Touch"
	desc = ""
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>I feel power flow through your hands.</span>"
	text_lose_indication = "<span class='notice'>The energy in your hands subsides.</span>"
	power = /obj/effect/proc_holder/spell/targeted/touch/shock
	instability = 30

/obj/effect/proc_holder/spell/targeted/touch/shock
	name = "Shock Touch"
	desc = ""
	drawmessage = "You channel electricity into your hand."
	dropmessage = "You let the electricity from your hand dissipate."
	hand_path = /obj/item/melee/touch_attack/shock
	charge_max = 100
	clothes_req = FALSE
	action_icon_state = "zap"

/obj/item/melee/touch_attack/shock
	name = "\improper shock touch"
	desc = ""
	catchphrase = null
	on_use_sound = 'sound/blank.ogg'
	icon_state = "zapper"
	item_state = "zapper"

/obj/item/melee/touch_attack/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!proximity)
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.electrocute_act(15, user, 1, SHOCK_NOSTUN))//doesnt stun. never let this stun
			C.dropItemToGround(C.get_active_held_item())
			C.dropItemToGround(C.get_inactive_held_item())
			C.confused += 15
			C.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='danger'>[user] electrocutes you!</span>")
			return ..()
		else
			user.visible_message("<span class='warning'>[user] fails to electrocute [target]!</span>")
			return ..()
	else if(isliving(target))
		var/mob/living/L = target
		L.electrocute_act(15, user, 1, SHOCK_NOSTUN)
		L.visible_message("<span class='danger'>[user] electrocutes [target]!</span>","<span class='danger'>[user] electrocutes you!</span>")
		return ..()
	else
		to_chat(user,"<span class='warning'>The electricity doesn't seem to affect [target]...</span>")
		return ..()
