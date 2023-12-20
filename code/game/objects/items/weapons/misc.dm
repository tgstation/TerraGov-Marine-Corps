/obj/item/weapon/chainofcommand
	name = "chain of command"
	desc = "A tool used by great men to placate the frothing masses."
	icon_state = "chain"
	item_state = "chain"
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	force = 10
	throwforce = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("flogged", "whipped", "lashed", "disciplined")

/obj/item/weapon/chainofcommand/suicide_act(mob/user)
	user.visible_message(span_danger("[user] is strangling [p_them()]self with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."))
	return (OXYLOSS)

/obj/item/weapon/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "cane"
	item_state = "cane"
	flags_atom = CONDUCT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")

/obj/item/weapon/broken_bottle
	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/items/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	item_state = "broken_beer"
	attack_verb = list("stabbed", "slashed", "attacked")
	sharp = IS_SHARP_ITEM_SIMPLE
	edge = 0
	var/icon/broken_outline = icon('icons/obj/items/drinks.dmi', "broken")

/obj/item/weapon/broken_bottle/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 25, 1)
	return ..()

/obj/item/weapon/powerfist
	name = "powerfist"
	desc = "A metal gauntlet with a energy-powered fist to throw back enemies. Altclick to clamp it around your hand, use it to change power settings and click with an empty off-hand or right click to pop out the cell."
	icon_state = "powerfist"
	item_state = "powerfist"
	flags_equip_slot = ITEM_SLOT_BELT
	force = 10
	attack_verb = list("smashed", "rammed", "power-fisted")
	var/obj/item/cell/cell
	///the higher the power level the harder it hits
	var/setting = 1

/obj/item/weapon/powerfist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/strappable)
	update_icon()

/obj/item/weapon/powerfist/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

/obj/item/weapon/powerfist/update_icon_state()
	. = ..()
	icon_state = cell ? "powerfist" : "powerfist_e"

/obj/item/weapon/powerfist/examine(user)
	. = ..()
	var/powerused = setting * 20
	. += "It's power setting is set to [setting]."
	if(cell)
		. += "It has [round(cell.charge/powerused, 1)] level [setting] punches remaining."
	else
		. += "There is no cell installed!"

/obj/item/weapon/powerfist/attack_self(mob/user)
	. = ..()
	if(setting == 3)
		setting = 1
	else
		setting += 1
	balloon_alert(user, "Power level [setting].")

/obj/item/weapon/powerfist/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!cell)
		to_chat(user, span_warning("\The [src] can't operate without a source of power!"))
		return

	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL) //Incorporeal beings cannot attack or be attacked
		return

	var/powerused = setting * 20
	if(powerused > cell.charge)
		to_chat(user, span_warning("\The [src]'s cell doesn't have enough power!"))
		M.apply_damage((force * 0.2), BRUTE, user.zone_selected, MELEE)
		playsound(loc, 'sound/weapons/punch1.ogg', 50, TRUE)
		if(M == user)
			to_chat(user, span_userdanger("You punch yourself!"))
		else
			M.visible_message(span_danger("[user]'s powerfist lets out a dull thunk as they punch [M.name]!"), \
				span_userdanger("[user] punches you!"))
		return ..()
	if(M == user)
		user.apply_damage(force * setting, BRUTE, user.zone_selected, MELEE)
		to_chat(user, span_userdanger("You punch yourself!"))
		playsound(loc, 'sound/weapons/energy_blast.ogg', 50, TRUE)
		playsound(loc, 'sound/weapons/genhit2.ogg', 50, TRUE)
		cell.charge -= powerused
		return ..()
	M.apply_damage(force * setting, BRUTE, user.zone_selected, MELEE)
	M.visible_message(span_danger("[user]'s powerfist shudders as they punch [M.name], flinging them away!"), \
		span_userdanger("[user]'s punch flings you backwards!"))
	playsound(loc, 'sound/weapons/energy_blast.ogg', 50, TRUE)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, TRUE)
	var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
	var/throw_distance = setting * LERP(5, 3, M.mob_size / MOB_SIZE_BIG)
	M.throw_at(throw_target, throw_distance, 0.5 + (setting / 2))
	cell.charge -= powerused
	return ..()

/obj/item/weapon/powerfist/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/cell))
		return ..()
	if(!istype(I, /obj/item/cell/lasgun))
		to_chat(user, span_warning("The powerfist only accepts lasgun cells!"))
		return
	if(I.w_class >= WEIGHT_CLASS_BULKY)
		to_chat(user, span_warning("Too big to fit!"))
		return
	if(cell)
		unload(user)
	user.transferItemToLoc(I,src)
	cell = I
	update_icon()
	user.balloon_alert(user, "Cell inserted")

/obj/item/weapon/powerfist/attack_hand(mob/living/user)
	if(!(user.get_inactive_held_item() == src))
		return ..()
	if(!cell)
		user.balloon_alert(user, "No cell")
		return
	unload(user)
	user.balloon_alert(user, "Cell removed")
	return

/obj/item/weapon/powerfist/attack_hand_alternate(mob/living/user)
	if(!cell)
		user.balloon_alert(user, "No cell")
		return
	unload(user)
	user.balloon_alert(user, "Cell removed")
	return

/// Remove the cell from the powerfist
/obj/item/weapon/powerfist/proc/unload(mob/user)
	if(!user.put_in_active_hand(cell))
		user.dropItemToGround(cell)
	cell = null
	update_icon()
	playsound(user, 'sound/weapons/guns/interact/rifle_reload.ogg', 25, TRUE)

/obj/item/weapon/brick
	name = "brick"
	desc = "It's a brick. Commonly used to hit things, occasionally used to build stuff instead."
	icon_state = "brick"
	force = 30
	throwforce = 40
	attack_verb = list("smacked", "whacked", "bonked", "bricked", "thwacked", "socked", "donked")
	hitsound = 'sound/weapons/heavyhit.ogg'

/obj/item/stack/throwing_knife/stone
	name = "stone"
	desc = "Capable of doing minor amounts of damage, these stones will annoy the hell out of the recipient."
	icon_state = "stone"
	force = 15
	throwforce = 15
	max_amount = 12
	amount = 12
	throw_delay = 0.3 SECONDS
	attack_verb = list("smacked", "whacked", "bonked", "pelted", "thwacked", "cracked")
	hitsound = 'sound/weapons/heavyhit.ogg'
	singular_name = "stone"
	flags_atom = DIRLOCK
	sharp = IS_NOT_SHARP_ITEM
