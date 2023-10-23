/obj/item/weapon/energy
	flags_atom = NOBLOODY

/obj/item/weapon/energy/suicide_act(mob/user)
	user.visible_message(pick(span_danger("[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku."), \
						span_danger("[user] is falling on the [name]! It looks like [user.p_theyre()] trying to commit suicide.")))
	return (BRUTELOSS|FIRELOSS)



/obj/item/weapon/energy/axe
	name = "energy axe"
	desc = "An energised battle axe."
	icon_state = "axe0"
	force = 40
	throwforce = 25
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	flags_atom = CONDUCT|NOBLOODY
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1

/obj/item/weapon/energy/axe/suicide_act(mob/user)
	user.visible_message(span_danger("[user] swings the [name] towards [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide."))
	return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/energy/axe/attack_self(mob/user)
	active = !active
	if(active)
		to_chat(user, span_notice("The axe is now energised."))
		force = 150
		icon_state = "axe1"
		w_class = WEIGHT_CLASS_HUGE
		heat = 3500
	else
		to_chat(user, span_notice("The axe can now be concealed."))
		force = 40
		icon_state = "axe0"
		w_class = WEIGHT_CLASS_HUGE
		heat = 0



/obj/item/weapon/energy/sword
	name = "energy sword"
	desc = "May the force be within you."
	icon_state = "sword"
	force = 10
	throwforce = 12
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = NOBLOODY
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	flags_equip_slot = ITEM_SLOT_BELT
	///Sword color, if applicable
	var/sword_color
	///Force of the weapon when activated
	var/active_force = 40

/obj/item/weapon/energy/sword/Initialize(mapload)
	. = ..()
	if(!sword_color)
		sword_color = pick("red","blue","green","purple")
	AddComponent(/datum/component/shield, SHIELD_TOGGLE|SHIELD_PURE_BLOCKING, shield_cover = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0))
	AddComponent(/datum/component/stun_mitigation, shield_cover = list(MELEE = 40, BULLET = 40, LASER = 40, ENERGY = 40, BOMB = 40, BIO = 40, FIRE = 40, ACID = 40))
	AddElement(/datum/element/strappable)

/obj/item/weapon/energy/sword/attack_self(mob/living/user)
	switch_state(src, user)

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	H.update_inv_l_hand()
	H.update_inv_r_hand()

///Handles all the state switch stuff
/obj/item/weapon/energy/sword/proc/switch_state(datum/source, mob/living/user)
	SIGNAL_HANDLER
	toggle_active()
	if(active)
		toggle_item_bump_attack(user, TRUE)
		hitsound = 'sound/weapons/blade1.ogg'
		force = active_force
		throwforce = active_force
		penetration = 30
		heat = 3500
		icon_state = "[initial(icon_state)]_[sword_color]"
		w_class = WEIGHT_CLASS_BULKY
		playsound(src, 'sound/weapons/saberon.ogg', 25, 1)
		RegisterSignals(src, list(COMSIG_ITEM_EQUIPPED_TO_SLOT, COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_UNEQUIPPED), PROC_REF(switch_state))
	else
		toggle_item_bump_attack(user, FALSE)
		hitsound = initial(hitsound)
		force = initial(force)
		throwforce = initial(throwforce)
		penetration = 0
		heat = 0
		icon_state = "[initial(icon_state)]"
		w_class = WEIGHT_CLASS_SMALL
		playsound(src, 'sound/weapons/saberoff.ogg', 25, 1)
		UnregisterSignal(src, list(COMSIG_ITEM_EQUIPPED_TO_SLOT, COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_UNEQUIPPED))

/obj/item/weapon/energy/sword/pirate
	name = "energy cutlass"
	desc = "Arrrr matey."
	icon_state = "cutlass"
	sword_color = "on"

/obj/item/weapon/energy/sword/green
	sword_color = "green"

/obj/item/weapon/energy/sword/red
	sword_color = "red"

/obj/item/weapon/energy/sword/blue
	sword_color = "blue"

/obj/item/weapon/energy/sword/deathsquad
	sword_color = "blue"
	active_force = 55

/obj/item/weapon/energy/sword/som
	icon_state = "som_sword"
	desc = "A SOM energy sword. Designed to cut through armored plate."
	active_force = 50
	sword_color = "on"

/obj/item/weapon/energy/sword/som/Initialize(mapload)
	. = ..()
	set_light_range_power_color(2, 1, COLOR_ORANGE)

/obj/item/weapon/energy/sword/som/switch_state(datum/source, mob/living/user)
	. = ..()
	if(active)
		flick("som_sword_open", src)
		set_light_on(TRUE)
	else
		flick("som_sword_close", src)
		set_light_on(FALSE)

/obj/item/weapon/energy/sword/som/apply_custom(mutable_appearance/standing, inhands, icon_used, state_used)
	. = ..()
	var/mutable_appearance/emissive_overlay = emissive_appearance(icon_used, "[state_used]_emissive")
	standing.overlays.Add(emissive_overlay)
