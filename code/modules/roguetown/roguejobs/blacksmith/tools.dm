
/obj/item/rogueweapon/hammer
	force = 21
	possible_item_intents = list(/datum/intent/mace/strike, /datum/intent/mace/smash)
	name = "hammer"
	desc = ""
	icon_state = "hammer"
	icon = 'icons/roguetown/weapons/tools.dmi'
	sharpness = IS_BLUNT
	//dropshrink = 0.8
	wlength = 10
	slot_flags = ITEM_SLOT_HIP
	w_class = WEIGHT_CLASS_NORMAL
	associated_skill = /datum/skill/combat/axesmaces
	smeltresult = /obj/item/ingot/iron

/obj/item/rogueweapon/hammer/attack_obj(obj/attacked_object, mob/living/user)
	if(!isliving(user) || !user.mind)
		return
	var/datum/mind/blacksmith_mind = user.mind
	var/repair_percent = 0.05 // 5% Repairing per hammer smack

	if(isitem(attacked_object))
		var/obj/item/attacked_item = attacked_object
		if(!attacked_item.anvilrepair || !attacked_item.max_integrity || !isturf(attacked_item.loc))
			return
		if(!attacked_item.obj_integrity)
			user.visible_message("<span class='warning'>[attacked_item] is broken!</span>")
			return

		if(blacksmith_mind.get_skill_level(attacked_item.anvilrepair) > 0)
			// People with maximum repairing skill will insta-fix anything in a single swing (3.4 * 6 * 0.05 = 1.02)
			repair_percent *= 3.4 * blacksmith_mind.get_skill_level(attacked_item.anvilrepair)

		playsound(src,'sound/items/bsmithfail.ogg', 100, FALSE)
		repair_percent *= attacked_item.max_integrity
		attacked_item.obj_integrity = min(obj_integrity+repair_percent, attacked_item.max_integrity)
		user.visible_message("<span class='info'>[user] repairs [attacked_item]!</span>")
		blacksmith_mind.adjust_experience(attacked_item.anvilrepair, repair_percent) //We gain as much exp as we fix
		return

	if(isstructure(attacked_object))
		var/obj/structure/attacked_structure = attacked_object
		if(!attacked_structure.hammer_repair || !attacked_structure.max_integrity)
			return
		if(blacksmith_mind.get_skill_level(attacked_structure.hammer_repair) <= 0)
			to_chat(user, "<span class='warning'>I don't know how to repair this..</span>")
			return
		repair_percent *= blacksmith_mind.get_skill_level(attacked_structure.hammer_repair) * attacked_structure.max_integrity
		attacked_structure.obj_integrity = min(attacked_structure.obj_integrity + repair_percent, attacked_structure.max_integrity)
		blacksmith_mind.adjust_experience(attacked_structure.hammer_repair, repair_percent) //We gain as much exp as we fix
		playsound(src,'sound/items/bsmithfail.ogg', 100, FALSE)
		user.visible_message("<span class='info'>[user] repairs [attacked_structure]!</span>")
		return

	..()

/obj/item/rogueweapon/hammer/claw
	icon_state = "clawh"

/*
/obj/item/rogueweapon/hammer/claw/attack_turf(turf/T, mob/living/user)
	if(!user.cmode)
		if(T.hammer_repair && T.max_integrity && !T.obj_broken)
			var/repair_percent = 0.05
			if(user.mind)
				if(user.mind.get_skill_level(I.hammer_repair) <= 0)
					to_chat(user, "<span class='warning'>I don't know how to repair this..</span>")
					return
				repair_percent = max(user.mind.get_skill_level(I.hammer_repair) * 0.05, 0.05)
			repair_percent = repair_percent * I.max_integrity
			I.obj_integrity = min(obj_integrity+repair_percent, I.max_integrity)
			playsound(src,'sound/items/bsmithfail.ogg', 100, FALSE)
			user.visible_message("<span class='info'>[user] repairs [I]!</span>")
			return
	..()
*/

/obj/item/rogueweapon/hammer/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,
"sx" = -15,
"sy" = -12,
"nx" = 9,
"ny" = -11,
"wx" = -11,
"wy" = -11,
"ex" = 1,
"ey" = -12,
"northabove" = 0,
"southabove" = 1,
"eastabove" = 1,
"westabove" = 0,
"nturn" = 90,
"sturn" = -90,
"wturn" = -90,
"eturn" = 90,
"nflip" = 0,
"sflip" = 8,
"wflip" = 8,
"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)



/obj/item/rogueweapon/tongs
	force = 10
	possible_item_intents = list(/datum/intent/mace/strike)
	name = "tongs"
	desc = ""
	icon_state = "tongs"
	icon = 'icons/roguetown/weapons/tools.dmi'
	sharpness = IS_BLUNT
	//dropshrink = 0.8
	wlength = 10
	slot_flags = ITEM_SLOT_HIP
	associated_skill = null
	var/obj/item/ingot/hingot = null
	var/hott = FALSE
	smeltresult = /obj/item/ingot/iron

/obj/item/rogueweapon/tongs/update_icon()
	if(!hingot)
		icon_state = "tongs"
	else
		if(hott)
			icon_state = "tongsi1"
		else
			icon_state = "tongsi0"

/obj/item/rogueweapon/tongs/proc/make_unhot(input)
	if(hott == input)
		hott = FALSE

/obj/item/rogueweapon/tongs/attack_self(mob/user)
	if(hingot)
		if(isturf(user.loc))
			hingot.forceMove(get_turf(user))
			hingot = null
			hott = FALSE
			update_icon()

/obj/item/rogueweapon/tongs/dropped()
	..()
	if(hingot)
		hingot.forceMove(get_turf(src))
		hingot = null
	hott = FALSE
	update_icon()

/obj/item/rogueweapon/tongs/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,
"sx" = -15,
"sy" = -12,
"nx" = 9,
"ny" = -11,
"wx" = -11,
"wy" = -11,
"ex" = 1,
"ey" = -12,
"northabove" = 0,
"southabove" = 1,
"eastabove" = 1,
"westabove" = 0,
"nturn" = 90,
"sturn" = -90,
"wturn" = -90,
"eturn" = 90,
"nflip" = 0,
"sflip" = 8,
"wflip" = 8,
"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
