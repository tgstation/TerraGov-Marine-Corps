/obj/item/weapon/sword
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	icon = 'icons/obj/items/weapons/swords.dmi'
	worn_icon_state = "claymore"
	atom_flags = CONDUCT
	equip_slot_flags = ITEM_SLOT_BELT
	force = 40
	throwforce = 10
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacks", "slashes", "stabs", "slices", "tears", "rips", "dices", "cuts")
	hitsound = 'sound/weapons/bladeslice.ogg'
	///Special attack action granted to users with the right trait
	var/datum/action/ability/activable/weapon_skill/sword_lunge/special_attack

/obj/item/weapon/sword/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/scalping)
	special_attack = new(src, force, penetration)

/obj/item/weapon/sword/Destroy()
	QDEL_NULL(special_attack)
	return ..()

/obj/item/weapon/sword/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)
	if(HAS_TRAIT(user, TRAIT_SWORD_EXPERT))
		special_attack.give_action(user)

/obj/item/weapon/sword/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)
	special_attack?.remove_action(user)

/obj/item/weapon/sword/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is falling on [user.p_their()] [name]! It looks like [user.p_theyre()] trying to commit suicide."))
	return(BRUTELOSS)

//Special attack
/datum/action/ability/activable/weapon_skill/sword_lunge
	name = "Lunging strike"
	action_icon_state = "sword_lunge"
	desc = "A powerful leaping strike. Cannot stun."
	ability_cost = 8
	cooldown_duration = 6 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_WEAPONABILITY_SWORDLUNGE,
	)
	///Range of this ability
	var/lunge_range = 2

/datum/action/ability/activable/weapon_skill/sword_lunge/ai_should_use(atom/target)
	if(get_dist(owner, target) > lunge_range)
		return FALSE
	return ..()

/datum/action/ability/activable/weapon_skill/sword_lunge/use_ability(atom/A)
	var/mob/living/carbon/carbon_owner = owner

	RegisterSignal(carbon_owner, COMSIG_MOVABLE_MOVED, PROC_REF(movement_fx))
	RegisterSignal(carbon_owner, COMSIG_MOVABLE_BUMP, PROC_REF(lunge_impact))
	RegisterSignal(carbon_owner, COMSIG_MOVABLE_POST_THROW, PROC_REF(charge_complete))

	carbon_owner.visible_message(span_danger("[carbon_owner] charges towards \the [A]!"))
	playsound(owner, 'sound/effects/alien/tail_swipe2.ogg', 50, 0, 4)
	carbon_owner.throw_at(A, lunge_range, 1, carbon_owner)
	succeed_activate()
	add_cooldown()

///Create an after image
/datum/action/ability/activable/weapon_skill/sword_lunge/proc/movement_fx()
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/after_image(get_turf(owner), owner)

///Unregisters signals after lunge complete
/datum/action/ability/activable/weapon_skill/sword_lunge/proc/charge_complete()
	SIGNAL_HANDLER
	UnregisterSignal(owner, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_POST_THROW, COMSIG_MOVABLE_MOVED))

///Sig handler for atom impacts during lunge
/datum/action/ability/activable/weapon_skill/sword_lunge/proc/lunge_impact(datum/source, atom/movable/target, speed)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(do_lunge_impact), source, target)
	charge_complete()

///Actual effects of lunge impact
/datum/action/ability/activable/weapon_skill/sword_lunge/proc/do_lunge_impact(datum/source, atom/movable/target)
	var/mob/living/carbon/carbon_owner = source
	if(isobj(target))
		var/obj/obj_victim = target
		obj_victim.take_damage(damage, BRUTE, MELEE, TRUE, TRUE, get_dir(obj_victim, carbon_owner), penetration, carbon_owner)
		obj_victim.knockback(carbon_owner, 1, 2, knockback_force = MOVE_FORCE_VERY_STRONG)
		return
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/human_victim = target
	human_victim.apply_damage(damage, BRUTE, BODY_ZONE_CHEST, MELEE, TRUE, TRUE, TRUE, penetration, owner)
	human_victim.adjust_stagger(1 SECONDS)
	playsound(human_victim, "sound/weapons/wristblades_hit.ogg", 25, 0, 5)
	shake_camera(human_victim, 2, 1)

/obj/item/weapon/sword/mercsword
	name = "combat sword"
	desc = "A dusty sword commonly seen in historical museums. Where you got this is a mystery, for sure. Only a mercenary would be nuts enough to carry one of these. Sharpened to deal massive damage."
	icon_state = "mercsword"
	worn_icon_state = "machete"
	force = 39

/obj/item/weapon/sword/captain
	name = "Ceremonial Sword"
	desc = "A fancy ceremonial sword passed down from generation to generation. Despite this, it has been very well cared for, and is in top condition."
	icon_state = "mercsword"
	worn_icon_state = "machete"
	force = 55

/obj/item/weapon/sword/machete
	name = "\improper M2132 machete"
	desc = "Latest issue of the TGMC Machete. Great for clearing out jungle or brush on outlying colonies. Found commonly in the hands of scouts and trackers, but difficult to carry with the usual kit."
	icon_state = "machete"
	worn_icon_state = "machete"
	force = 75
	attack_speed = 12
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/sword/machete/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/strappable)

/obj/item/weapon/sword/machete/alt
	name = "machete"
	desc = "A nice looking machete. Great for clearing out jungle or brush on outlying colonies. Found commonly in the hands of scouts and trackers, but difficult to carry with the usual kit."
	icon_state = "machete_alt"

//FC's sword.
/obj/item/weapon/sword/officersword
	name = "officers sword"
	desc = "This appears to be a rather old blade that has been well taken care of, it is probably a family heirloom. Oddly despite its probable non-combat purpose it is sharpened and not blunt."
	icon_state = "officer_sword"
	worn_icon_state = "officer_sword"
	force = 75
	attack_speed = 11
	penetration = 15
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/sword/officersword/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/strappable)

/obj/item/weapon/sword/commissar_sword
	name = "commissars sword"
	desc = "The pride of an imperial commissar, held high as they charge into battle."
	icon_state = "comsword"
	worn_icon_state = "comsword"
	force = 80
	attack_speed = 10
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/sword/katana
	name = "katana"
	desc = "A finely made Japanese sword, with a well sharpened blade. The blade has been filed to a molecular edge, and is extremely deadly. Commonly found in the hands of mercenaries and yakuza."
	icon_state = "katana"
	worn_icon_state = "machete"
	force = 50
	throwforce = 10

/obj/item/weapon/sword/katana/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku."))
	return(BRUTELOSS)

//To do: replace the toys.
/obj/item/weapon/sword/katana/replica
	name = "replica katana"
	desc = "A cheap knock-off commonly found in regular knife stores. Can still do some damage."
	force = 27
	throwforce = 7

/obj/item/weapon/sword/katana/samurai
	name = "\improper tachi"
	desc = "A genuine replica of an ancient blade. This one is in remarkably good condition. It could do some damage to everyone, including yourself."
	icon_state = "samurai_open"
	force = 60
	attack_speed = 12
	w_class = WEIGHT_CLASS_BULKY
