/datum/rmb_intent
	var/name = "intent"
	var/desc = ""
	var/icon_state = ""

/datum/rmb_intent/proc/special_attack(/mob/user, /atom/target)
	return

/datum/rmb_intent/aimed
	name = "aimed"
	desc = "Your attacks are more precise but have a longer recovery time. Higher critrate with precise attacks."
	icon_state = "rmbaimed"

/datum/rmb_intent/strong
	name = "strong"
	desc = "Your attacks have +1 strength but use more stamina. Higher critrate with brutal attacks."
	icon_state = "rmbstrong"

/datum/rmb_intent/swift
	name = "swift"
	desc = "Your attacks have less recovery time but are less accurate."
	icon_state = "rmbswift"

/datum/rmb_intent/special
	name = "special"
	desc = "(RMB WHILE DEFENSE IS ACTIVE) A special attack that depends on the type of weapon you are using."
	icon_state = "rmbspecial"

/datum/rmb_intent/feint
	name = "feint"
	desc = "(RMB WHILE DEFENSE IS ACTIVE) A deceptive half-attack with no follow-through, meant to force your opponent to open their guard. Useless against someone who is dodging."
	icon_state = "rmbfeint"

/datum/rmb_intent/feint/special_attack(var/mob/living/user, var/atom/target)
	if(!isliving(target))
		return
	if(!user)
		return
	if(user.incapacitated())
		return
	var/mob/living/L = target
	user.changeNext_move(CLICK_CD_RAPID)
	playsound(user, 'sound/combat/feint.ogg', 100, TRUE)
	user.visible_message("<span class='danger'>[user] feints an attack at [target]!</span>")
	var/perc = 50
	if(user.mind)
		var/obj/item/I = user.get_active_held_item()
		var/ourskill = 0
		var/theirskill = 0
		if(I)
			if(I.associated_skill)
				ourskill = user.mind.get_skill_level(I.associated_skill)
			if(L.mind)
				I = L.get_active_held_item()
				if(I?.associated_skill)
					theirskill = L.mind.get_skill_level(I.associated_skill)
		if(ourskill > theirskill)
			perc += 100
	if(user.STAINT < L.STAINT)
		perc -= 15
	if(istype(L.rmb_intent, /datum/rmb_intent/riposte))
		perc += 15
	if(L.d_intent == INTENT_DODGE)
		perc = 0
	if(!L.cmode)
		perc = 0
	if(L.has_status_effect(/datum/status_effect/debuff/feinted))
		perc = 0
	if(user.has_status_effect(/datum/status_effect/debuff/feintcd))
		perc -= rand(10,30)
	user.apply_status_effect(/datum/status_effect/debuff/feintcd)
	perc = CLAMP(perc, 0, 99)
	if(prob(perc))
		L.apply_status_effect(/datum/status_effect/debuff/feinted)
		L.changeNext_move(4)
		L.Immobilize(5)
		to_chat(user, "<span class='notice'>[L] fell for my feint attack!</span>")
		to_chat(L, "<span class='danger'>I fall for [user]'s feint attack!</span>")
	else
		if(user.client?.prefs.showrolls)
			to_chat(user, "<span class='warning'>[L] did not fall for my feint... [perc]%</span>")

/datum/status_effect/debuff/feinted
	id = "nofeint"
	duration = 50

/datum/status_effect/debuff/feintcd
	id = "feintcd"
	duration = 100

/datum/status_effect/debuff/riposted
	id = "riposted"
	duration = 30

/datum/rmb_intent/riposte
	name = "defend"
	desc = "Successfully parrying your enemy's attack will open their defense briefly. No delay between dodge and parry rolls. 15% easier to be feinted while active."
	icon_state = "rmbdef"

/datum/rmb_intent/guard
	name = "guarde"
	desc = "(RMB WHILE DEFENSE IS ACTIVE) Raise your weapon, ready to attack any creature who moves onto the space you are guarding."
	icon_state = "rmbguard"

/datum/rmb_intent/weak
	name = "weak"
	desc = "Your attacks have -1 strength and will never critically-hit. Useful for longer punishments, play-fighting, and bloodletting."
	icon_state = "rmbweak"