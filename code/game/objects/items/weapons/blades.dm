/* Weapons
* Contains:
*		Claymore
*		Harvester
*		mercsword
*		Energy Shield
*		Energy Shield
*		Energy Shield
*		Ceremonial Sword
*		M2132 machete
*		Officers sword
*		Commissars sword
*		Katana
*		M5 survival knife
*		Upp Type 30 survival knife
*		M11 throwing knife
*		Chainsword
*/


/obj/item/weapon/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 40
	throwforce = 10
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/claymore/Initialize()
	. = ..()
	AddElement(/datum/element/scalping)

/obj/item/weapon/claymore/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is falling on the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."))
	return(BRUTELOSS)

/obj/item/weapon/claymore/harvester
	name = "\improper HP-S Harvester blade"
	desc = "TerraGov Marine Corps' experimental High Point-Singularity 'Harvester' blade. An advanced weapon that trades sheer force for the ability to apply a variety of debilitating effects when loaded with certain reagents. Activate after loading to prime a single use of an effect. It also harvests substances from alien lifeforms it strikes when connected to the Vali system."
	icon_state = "energy_sword"
	item_state = "energy_katana"
	force = 60
	attack_speed = 12
	w_class = WEIGHT_CLASS_BULKY
	flags_item = DRAINS_XENO

	var/force_wielded = 40

	var/codex_info = {"<b>Reagent info:</b><BR>
	Bicaridine - heal your target for 10 brute. Usable on both dead and living targets.<BR>
	Kelotane - produce a cone of flames<BR>
	Tramadol - slow your target for 2 seconds<BR>
	<BR>
	<b>Tips:</b><BR>
	> Needs to be connected to the Vali system to collect green blood. You can connect it though the Vali system's configurations menu.<BR>
	> Filled by liquid reagent containers. Emptied by using an empty liquid reagent container.<BR>
	> Toggle unique action (SPACE by default) to load a single-use of the reagent effect after the blade has been filled up."}

/obj/item/weapon/claymore/harvester/Initialize()
	. = ..()
	AddComponent(/datum/component/harvester)

/obj/item/weapon/claymore/harvester/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/claymore/harvester/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/claymore/harvester/get_mechanics_info()
	. = ..()
	. += jointext(codex_info, "<br>")

/obj/item/weapon/claymore/mercsword
	name = "combat sword"
	desc = "A dusty sword commonly seen in historical museums. Where you got this is a mystery, for sure. Only a mercenary would be nuts enough to carry one of these. Sharpened to deal massive damage."
	icon_state = "mercsword"
	item_state = "machete"
	force = 39

/obj/item/weapon/claymore/mercsword/captain
	name = "Ceremonial Sword"
	desc = "A fancy ceremonial sword passed down from generation to generation. Despite this, it has been very well cared for, and is in top condition."
	icon_state = "mercsword"
	item_state = "machete"
	force = 55

/obj/item/weapon/claymore/mercsword/machete
	name = "\improper M2132 machete"
	desc = "Latest issue of the TGMC Machete. Great for clearing out jungle or brush on outlying colonies. Found commonly in the hands of scouts and trackers, but difficult to carry with the usual kit."
	icon_state = "machete"
	force = 75
	attack_speed = 12
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/claymore/mercsword/machete/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/claymore/mercsword/machete/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

//FC's sword.

/obj/item/weapon/claymore/mercsword/officersword
	name = "\improper Officers sword"
	desc = "This appears to be a rather old blade that has been well taken care of, it is probably a family heirloom. Oddly despite its probable non-combat purpose it is sharpened and not blunt."
	icon_state = "officer_sword"
	item_state = "officer_sword"
	force = 75
	attack_speed = 12
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/claymore/mercsword/machete/equipped(mob/user, slot)
	. = ..()
	toggle_item_bump_attack(user, TRUE)

/obj/item/weapon/claymore/mercsword/machete/dropped(mob/user)
	. = ..()
	toggle_item_bump_attack(user, FALSE)

/obj/item/weapon/claymore/mercsword/commissar_sword
	name = "\improper commissars sword"
	desc = "The pride of an imperial commissar, held high as they charge into battle."
	icon_state = "comsword"
	item_state = "comsword"
	force = 80
	attack_speed = 10
	w_class = WEIGHT_CLASS_BULKY

/obj/item/weapon/claymore/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
	return ..()

/obj/item/weapon/katana
	name = "katana"
	desc = "A finely made Japanese sword, with a well sharpened blade. The blade has been filed to a molecular edge, and is extremely deadly. Commonly found in the hands of mercenaries and yakuza."
	icon_state = "katana"
	flags_atom = CONDUCT
	force = 50
	throwforce = 10
	sharp = IS_SHARP_ITEM_BIG
	edge = 1
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

/obj/item/weapon/katana/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku."))
	return(BRUTELOSS)

//To do: replace the toys.
/obj/item/weapon/katana/replica
	name = "replica katana"
	desc = "A cheap knock-off commonly found in regular knife stores. Can still do some damage."
	force = 27
	throwforce = 7

/obj/item/weapon/katana/samurai
	name = "\improper tachi"
	desc = "A genuine replica of an ancient blade. This one is in remarkably good condition. It could do some damage to everyone, including yourself."
	icon_state = "samurai_open"
	force = 60
	attack_speed = 12
	w_class = WEIGHT_CLASS_BULKY


/obj/item/weapon/katana/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
	return ..()

/obj/item/weapon/combat_knife
	name = "\improper M5 survival knife"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "combat_knife"
	item_state = "combat_knife"
	desc = "A standard survival knife of high quality. You can slide this knife into your boots, and can be field-modified to attach to the end of a rifle with cable coil."
	flags_atom = CONDUCT
	sharp = IS_SHARP_ITEM_ACCURATE
	materials = list(/datum/material/metal = 200)
	force = 30
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 20
	throw_speed = 3
	throw_range = 6
	attack_speed = 8
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")


/obj/item/weapon/combat_knife/attackby(obj/item/I, mob/user)
	if(!istype(I,/obj/item/stack/cable_coil))
		return ..()
	var/obj/item/stack/cable_coil/CC = I
	if(!CC.use(5))
		to_chat(user, span_notice("You don't have enough cable for that."))
		return
	to_chat(user, "You wrap some cable around the bayonet. It can now be attached to a gun.")
	if(loc == user)
		user.temporarilyRemoveItemFromInventory(src)
	var/obj/item/attachable/bayonet/F = new(src.loc)
	user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
	if(F.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
		F.loc = get_turf(src)
	qdel(src) //Delete da old knife

/obj/item/weapon/combat_knife/Initialize()
	. = ..()
	AddElement(/datum/element/scalping)

/obj/item/weapon/combat_knife/suicide_act(mob/user)
	user.visible_message(pick(span_danger("[user] is slitting [user.p_their()] wrists with the [name]! It looks like [user.p_theyre()] trying to commit suicide."), \
							span_danger("[user] is slitting [user.p_their()] throat with the [name]! It looks like [user.p_theyre()] trying to commit suicide."), \
							span_danger("[user] is slitting [user.p_their()] stomach open with the [name]! It looks like [user.p_theyre()] trying to commit seppuku.")))
	return (BRUTELOSS)

/obj/item/weapon/combat_knife/upp
	name = "\improper Type 30 survival knife"
	icon_state = "upp_knife"
	item_state = "knife"
	desc = "The standard issue survival knife of the UPP forces, the Type 30 is effective, but humble. It is small enough to be non-cumbersome, but lethal none-the-less."
	force = 20
	throwforce = 10
	throw_speed = 2
	throw_range = 8

/obj/item/weapon/karambit
	name = "karambit"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "karambit"
	item_state = "karambit"
	desc = "A small high quality knife with a curved blade, good for slashing and hooking. This one has a mottled red finish."
	flags_atom = CONDUCT
	sharp = IS_SHARP_ITEM_ACCURATE
	materials = list(/datum/material/metal = 200)
	force = 30
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 20
	throw_speed = 3
	throw_range = 6
	attack_speed = 8
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut", "hooked")

//Try to do a fancy trick with your cool knife
/obj/item/weapon/karambit/attack_self(mob/user)
	. = ..()
	if(!user.dextrous)
		to_chat(user, span_warning("You don't have the dexterity to do this."))
		return
	if(user.incapacitated() || !isturf(user.loc))
		to_chat(user, span_warning("You can't do this right now."))
		return
	if(user.do_actions)
		return
	do_trick(user)

/obj/item/weapon/karambit/fade
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "karambit_fade"
	item_state = "karambit_fade"
	desc = "A small high quality knife with a curved blade, good for slashing and hooking. This one has been painted by airbrushing transparent paints that fade together over a chrome base coat."

/obj/item/weapon/karambit/case_hardened
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "karambit_case_hardened"
	item_state = "karambit_case_hardened"
	desc = "A small high quality knife with a curved blade, good for slashing and hooking. This one has been color case-hardened through the application of wood charcoal at high temperatures."

/obj/item/stack/throwing_knife
	name ="\improper M11 throwing knife"
	icon='icons/obj/items/weapons.dmi'
	icon_state = "throwing_knife"
	desc="A military knife designed to be thrown at the enemy. Much quieter than a firearm, but requires a steady hand to be used effectively."
	stack_name = "pile"
	singular_name = "knife"
	flags_atom = CONDUCT|DIRLOCK
	sharp = IS_SHARP_ITEM_ACCURATE
	force = 20
	w_class = WEIGHT_CLASS_TINY
	throwforce = 45
	throw_speed = 5
	throw_range = 7
	hitsound = 'sound/weapons/slash.ogg'
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	flags_equip_slot = ITEM_SLOT_POCKET

	max_amount = 5
	amount = 5
	///Delay between throwing.
	var/throw_delay = 0.2 SECONDS
	COOLDOWN_DECLARE(last_thrown)

/obj/item/stack/throwing_knife/Initialize(mapload, new_amount)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, .proc/post_throw)

/obj/item/stack/throwing_knife/update_icon()
	. = ..()
	var/amount_to_show = amount > max_amount ? max_amount : amount
	setDir(amount_to_show + round(amount_to_show / 3))

/obj/item/stack/throwing_knife/equipped(mob/user, slot)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(living_user.get_active_held_item() != src && living_user.get_inactive_held_item() != src)
		return
	RegisterSignal(user, COMSIG_MOB_ITEM_AFTERATTACK, .proc/throw_knife)

/obj/item/stack/throwing_knife/unequipped(mob/unequipper, slot)
	. = ..()
	UnregisterSignal(unequipper, COMSIG_MOB_ITEM_AFTERATTACK)

///Throws a knife from the stack, or, if the stack is one, throws the stack.
/obj/item/stack/throwing_knife/proc/throw_knife(datum/source, atom/target, params)
	SIGNAL_HANDLER
	var/mob/living/user = source
	if(user.Adjacent(target) || user.get_active_held_item() != src || !COOLDOWN_CHECK(src, last_thrown))
		return
	var/thrown_thing = src
	if(amount == 1)
		user.temporarilyRemoveItemFromInventory(src)
		forceMove(get_turf(src))
		throw_at(target, throw_range, throw_speed, user, TRUE)
	else
		var/obj/item/stack/throwing_knife/knife_to_throw = new(get_turf(src))
		knife_to_throw.amount = 1
		knife_to_throw.update_icon()
		knife_to_throw.throw_at(target, throw_range, throw_speed, user, TRUE)
		amount--
		thrown_thing = knife_to_throw
	playsound(src, 'sound/effects/throw.ogg', 30, 1)
	visible_message(span_warning("[user] expertly throws [thrown_thing]."), null, null, 5)
	update_icon()
	COOLDOWN_START(src, last_thrown, throw_delay)

///Fills any stacks currently in the tile that this object is thrown to.
/obj/item/stack/throwing_knife/proc/post_throw()
	SIGNAL_HANDLER
	if(amount >= max_amount)
		return
	for(var/item_in_loc in loc.contents)
		if(!istype(item_in_loc, /obj/item/stack/throwing_knife) || item_in_loc == src)
			continue
		var/obj/item/stack/throwing_knife/knife = item_in_loc
		if(!merge(knife))
			continue
		break


/obj/item/weapon/chainsword
	name = "chainsword"
	desc = "chainsword thing"
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "chainswordoff"
	attack_verb = list("gored", "slashed", "cut")
	force = 10
	throwforce = 5
	var/on = FALSE
	var/datum/looping_sound/chainsaw/chainsaw_loop


/obj/item/weapon/chainsword/Initialize()
	. = ..()
	chainsaw_loop = new(null, FALSE)

/obj/item/weapon/chainsword/attack_self(mob/user)
	. = ..()
	if(!on)
		on = !on
		icon_state = "chainswordon"
		force = 40
		attack_speed = 5
		throwforce = 30
		chainsaw_loop.start(src)
	else
		on = !on
		icon_state = initial(icon_state)
		force = initial(force)
		throwforce = initial(icon_state)
		chainsaw_loop.stop()

/obj/item/weapon/chainsword/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/chainsawhit.ogg', 100, 1)
	return ..()

/obj/item/weapon/chainsword/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is falling on the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."))
	return(BRUTELOSS)
