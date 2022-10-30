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


/obj/item/weapon/broken_bottle
	name = "Broken Bottle"
	desc = "A bottle with a sharp broken bottom."
	icon = 'icons/obj/items/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9.0
	throwforce = 5.0
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
	desc = "A metal gauntlet with a energy-powered fist to throw back enemies. Altclick to clamp it around your hand, use it to change power settings and screwdriver to pop out the cell."
	icon_state = "powerfist"
	item_state = "powerfist"
	flags_equip_slot = ITEM_SLOT_BELT
	force = 10
	attack_verb = list("smashed", "rammed", "power-fisted")
	var/obj/item/cell/cell
	///the higher the power level the harder it hits
	var/setting = 1

/obj/item/weapon/powerfist/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

/obj/item/weapon/powerfist/examine(user)
	. = ..()
	. += "It's power setting is set to [setting]."
	if(cell)
		. += "It has [cell.charge] power remaining."
	else
		. += "There is no cell installed!"

/obj/item/weapon/powerfist/attack_self(mob/user)
	. = ..()
	if(setting == 3)
		setting = 1
	else
		setting += 1
	balloon_alert(user, "Power level [setting].")

/obj/item/weapon/powerfist/AltClick(mob/user)
	if(!can_interact(user))
		return ..()
	if(!ishuman(user))
		return ..()
	if(!(user.l_hand == src || user.r_hand == src))
		return ..()
	TOGGLE_BITFIELD(flags_item, NODROP)
	if(CHECK_BITFIELD(flags_item, NODROP))
		to_chat(user, span_warning("You feel the [src] clamp shut around your hand!"))
		playsound(user, 'sound/weapons/fistclamp.ogg', 25, 1, 7)
	else
		to_chat(user, span_notice("You feel the [src] loosen around your hand!"))
		playsound(user, 'sound/weapons/fistunclamp.ogg', 25, 1, 7)



/obj/item/weapon/powerfist/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!cell)
		to_chat(user, span_warning("\The [src] can't operate without a source of power!"))
		return

	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL) //Incorporeal beings cannot attack or be attacked
		return

	var/powerused = setting * 30
	if(powerused >= cell.charge)
		to_chat(user, span_warning("\The [src]'s cell doesn't have enough power!"))
		M.apply_damage((force/5), BRUTE)
		playsound(loc, 'sound/weapons/punch1.ogg', 50, TRUE)
		M.visible_message(span_danger("[user]'s powerfist lets out a dull thunk as they punch [M.name]!"), \
			span_userdanger("[user] punches you!"))
		return ..()
	M.apply_damage(force * setting, BRUTE)
	M.visible_message(span_danger("[user]'s powerfist shudders as they punch [M.name], flinging them away!"), \
		span_userdanger("You [user]'s punch flings you backwards!"))
	playsound(loc, 'sound/weapons/energy_blast.ogg', 50, TRUE)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, TRUE)
	var/atom/throw_target = get_edge_target_turf(M, get_dir(src, get_step_away(M, src)))
	var/throw_distance = setting * LERP(5 , 2, M.mob_size / MOB_SIZE_BIG)
	M.throw_at(throw_target, throw_distance, 0.5 + (setting / 2))
	cell.charge -= powerused
	return ..()

/obj/item/weapon/powerfist/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/cell))
		return ..()
	if(!istype(I, /obj/item/cell/lasgun))
		to_chat(user, span_warning("The powerfist only accepts lasgun cells!"))
		return
	if(cell)
		unload(user)
	user.transferItemToLoc(I,src)
	cell = I
	to_chat(user, span_notice("You insert the [I] into the [src]."))

/obj/item/weapon/powerfist/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(!cell)
		to_chat(user, span_notice("There is no cell installed!"))
		return TRUE
	unload(user)
	to_chat(user, span_notice("You pop open the cover and remove the cell."))
	return TRUE

/// Remove the cell from the powerfist
/obj/item/weapon/powerfist/proc/unload(mob/user)
	user.dropItemToGround(cell)
	cell = null
	playsound(user, 'sound/weapons/guns/interact/rifle_reload.ogg', 25, TRUE)

/obj/item/weapon/maul
	name = "taser goad"
	desc = "A metal gauntlet with a energy-powered fist to throw back enemies. Altclick to clamp it around your hand, use it to change power settings and screwdriver to pop out the cell."
	icon_state = "goad"
	item_state = "goad"
	flags_equip_slot = ITEM_SLOT_BELT
	force = 30
	attack_verb = list("electrocutes", "goads", "fries")
	var/obj/item/cell/cell
	var/on = FALSE

/obj/item/weapon/maul/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

/obj/item/weapon/maul/examine(user)
	. = ..()
	if(cell)
		. += "It has [cell.charge] power remaining."
	else
		. += "There is no cell installed!"

/obj/item/weapon/maul/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!cell)
		to_chat(user, span_warning("\The [src] can't operate without a source of power!"))
		return

	if(M.status_flags & INCORPOREAL || user.status_flags & INCORPOREAL) //Incorporeal beings cannot attack or be attacked
		return

	var/powerused = 30
	if(powerused >= cell.charge)
		to_chat(user, span_warning("\The [src]'s cell doesn't have enough power!"))
		unload(user)
		return ..()
	M.apply_effects(1,2)
	cell.charge -= powerused
	return ..()

/obj/item/weapon/maul/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/cell))
		return
	if(cell)
		to_chat(user, span_notice("There is already a cell installed!"))
	user.transferItemToLoc(I,src)
	cell = I
	icon_state = "goad_on"
	to_chat(user, span_notice("You insert the [I] into the [src]."))

/obj/item/weapon/maul/attack_hand(mob/living/user)
	if(!cell)
		to_chat(user, span_notice("There is no cell installed!"))
		return
	if(user.get_inactive_held_item() != src)
		return ..()
	unload(user)

/// Remove the cell from the powerfist
/obj/item/weapon/maul/proc/unload(mob/user)
	user.dropItemToGround(cell)
	cell = null
	playsound(user, 'sound/weapons/guns/interact/rifle_reload.ogg', 25, TRUE)
	on = FALSE
	icon_state = "goad_off"
