
//-------------------------------------------------------
//ENERGY GUNS/ETC

/obj/item/weapon/gun/energy
	attachable_allowed = list()
	var/obj/item/cell/cell //1000 power.
	var/charge_cost = 10 //100 shots.
	var/cell_type = /obj/item/cell
	flags_gun_features = GUN_AMMO_COUNTER

/obj/item/weapon/gun/energy/examine_ammo_count(mob/user)
	var/list/dat = list()
	if(!(flags_gun_features & (GUN_INTERNAL_MAG|GUN_UNUSUAL_DESIGN))) //Internal mags and unusual guns have their own stuff set.
		var/current_shots = get_ammo_count()
		if(cell && current_shots > 0)
			if(flags_gun_features & GUN_AMMO_COUNTER)

				dat += "Ammo counter shows [current_shots] round\s remaining.<br>"
			else
				dat += "It's loaded[in_chamber?" and has a round chambered":""].<br>"
		else
			dat += "It's unloaded[in_chamber?" but has a round chambered":""].<br>"
	if(dat)
		to_chat(user, "[dat.Join(" ")]")

/obj/item/weapon/gun/energy/Initialize()
	. = ..()
	if(cell_type)
		cell = new cell_type(src)

/obj/item/weapon/gun/energy/able_to_fire(mob/living/user)
	. = ..()
	if(!cell || cell.charge - charge_cost < 0)
		return

/obj/item/weapon/gun/energy/load_into_chamber()
	if(!cell || cell.charge - charge_cost < 0)
		return

	cell.charge -= charge_cost
	in_chamber = create_bullet(ammo)
	return in_chamber

/obj/item/weapon/gun/energy/update_icon()
	return

/obj/item/weapon/gun/energy/reload_into_chamber()
	update_icon()
	return TRUE

/obj/item/weapon/gun/energy/delete_bullet(var/obj/item/projectile/projectile_to_fire, refund = 0)
	qdel(projectile_to_fire)
	if(refund)
		cell.charge = min(cell.charge + charge_cost, cell.maxcharge) //Safeguard against 'overcharging' the cell.
	return TRUE

/obj/item/weapon/gun/energy/emp_act(severity)
	cell.use(round(cell.maxcharge / severity))
	update_icon()
	return ..()

/obj/item/weapon/gun/energy/get_ammo_type()
	if(!ammo)
		return list("unknown", "unknown")
	else
		return list(ammo.hud_state, ammo.hud_state_empty)

/obj/item/weapon/gun/energy/get_ammo_count()
	if(!cell)
		return 0
	else
		return FLOOR(cell.charge / max(charge_cost, 1),1)


/obj/item/weapon/gun/energy/taser
	name = "taser gun"
	desc = "An advanced stun device capable of firing balls of ionized electricity. Used for nonlethal takedowns."
	icon_state = "taser"
	item_state = "taser"
	muzzle_flash = null //TO DO.
	fire_sound = 'sound/weapons/Taser.ogg'
	origin_tech = "combat=1;materials=1"
	matter = list("metal" = 2000)
	ammo = /datum/ammo/energy/taser
	charge_cost = 500
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AMMO_COUNTER
	gun_skill_category = GUN_SKILL_PISTOLS
	movement_acc_penalty_mult = 0
	cell_type = /obj/item/cell/high

/obj/item/weapon/gun/energy/taser/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay) * 2
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/low_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/mlow_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/low_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

/obj/item/weapon/gun/energy/taser/update_icon()
	if(!cell || cell.charge - charge_cost < 0)
		icon_state = base_gun_icon + "_e"
	else
		icon_state = base_gun_icon

/obj/item/weapon/gun/energy/taser/able_to_fire(mob/living/user)
	. = ..()
	if (.) //Let's check all that other stuff first.
		if(user?.mind?.cm_skills?.police && user.mind.cm_skills.police < SKILL_POLICE_MP)
			to_chat(user, "<span class='warning'>You don't seem to know how to use [src]...</span>")
			return FALSE


/obj/item/weapon/gun/energy/plasmarifle
	name = "plasma rifle"
	desc = "A long-barreled heavy plasma weapon capable of taking down large game. It has a mounted scope for distant shots and an integrated battery."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "plasmarifle"
	item_state = "plasmarifle"
	origin_tech = "combat=8;materials=7;bluespace=6"
	unacidable = 1
	fire_sound = 'sound/weapons/pred_plasma_shot.ogg'
	ammo = /datum/ammo/energy/yautja/rifle/bolt
	muzzle_flash = null // TO DO, add a decent one.
	zoomdevicename = "scope"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = 5
	charge_cost = 100
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AMMO_COUNTER
	cell_type = /obj/item/cell/high

/obj/item/weapon/gun/energy/plasmarifle/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay) * 2
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/max_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/max_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

/obj/item/weapon/gun/energy/plasmarifle/examine(mob/user)
	. = ..()
	if(isyautja(user))
		to_chat(user, "It currently has [cell.charge / charge_cost] shots remaining.")
	else
		to_chat(user, "This thing looks like an alien rifle of some kind. Strange.")

/obj/item/weapon/gun/energy/plasmarifle/unique_action(mob/user)
	if(!isyautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return
	zoom(user)
	return ..()

/obj/item/weapon/gun/energy/plasmarifle/able_to_fire(mob/user)
	if(!isyautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return
	return ..()


/obj/item/weapon/gun/energy/plasmapistol
	name = "plasma pistol"
	desc = "A plasma pistol capable of rapid fire. It has an integrated battery."
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "plasmapistol"
	item_state = "plasmapistol"
	origin_tech = "combat=8;materials=7;bluespace=6"
	unacidable = 1
	fire_sound = 'sound/weapons/pulse3.ogg'
	flags_equip_slot = ITEM_SLOT_BELT
	ammo = /datum/ammo/energy/yautja/pistol
	muzzle_flash = null // TO DO, add a decent one.
	w_class = 3
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AMMO_COUNTER

/obj/item/weapon/gun/energy/plasmapistol/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/med_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/med_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	scatter = CONFIG_GET(number/combat_define/low_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

/obj/item/weapon/gun/energy/plasmapistol/examine(mob/user)
	. = ..()
	if(isyautja(user))
		to_chat(user, "It currently has [cell.charge / charge_cost] shots remaining.")
	else
		to_chat(user, "This thing looks like an alien rifle of some kind. Strange.")

/obj/item/weapon/gun/energy/plasmapistol/able_to_fire(mob/user)
	if(!isyautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return
	return ..()


/obj/item/weapon/gun/energy/plasma_caster
	icon = 'icons/obj/items/predator.dmi'
	icon_state = "plasma"
	item_state = "plasma_wear"
	name = "plasma caster"
	desc = "A powerful, shoulder-mounted energy weapon."
	fire_sound = 'sound/weapons/pred_plasmacaster_fire.ogg'
	ammo = /datum/ammo/energy/yautja/caster/bolt
	muzzle_flash = null // TO DO, add a decent one.
	w_class = 5
	force = 0
	fire_delay = 3
	charge_cost = 100
	var/mode = 0
	actions_types = list(/datum/action/item_action/toggle)
	flags_atom = CONDUCT
	flags_item = NOBLUDGEON|DELONDROP //Can't bludgeon with this.
	flags_gun_features = GUN_UNUSUAL_DESIGN|GUN_AMMO_COUNTER

/obj/item/weapon/gun/energy/plasma_caster/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/high_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/high_fire_delay)
	scatter = CONFIG_GET(number/combat_define/med_scatter_value)
	scatter_unwielded = CONFIG_GET(number/combat_define/med_scatter_value)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)

/obj/item/weapon/gun/energy/plasma_caster/attack_self(mob/living/user)
	switch(mode)
		if(0)
			mode = 1
			charge_cost = 100
			fire_delay = CONFIG_GET(number/combat_define/med_fire_delay) * 4
			fire_sound = 'sound/weapons/emitter2.ogg'
			to_chat(user, "<span class='notice'>[src] is now set to fire medium plasma blasts.</span>")
			ammo = GLOB.ammo_list[/datum/ammo/energy/yautja/caster/blast]
		if(1)
			mode = 2
			charge_cost = 300
			fire_delay = CONFIG_GET(number/combat_define/high_fire_delay) * 20
			fire_sound = 'sound/weapons/pulse.ogg'
			to_chat(user, "<span class='notice'>[src] is now set to fire heavy plasma spheres.</span>")
			ammo = GLOB.ammo_list[/datum/ammo/energy/yautja/caster/sphere]
		if(2)
			mode = 0
			charge_cost = 30
			fire_delay = CONFIG_GET(number/combat_define/high_fire_delay)
			fire_sound = 'sound/weapons/pred_lasercannon.ogg'
			to_chat(user, "<span class='notice'>[src] is now set to fire light plasma bolts.</span>")
			ammo = GLOB.ammo_list[/datum/ammo/energy/yautja/caster/bolt]

/obj/item/weapon/gun/energy/plasma_caster/dropped(mob/living/carbon/human/M)
	playsound(M,'sound/weapons/pred_plasmacaster_off.ogg', 15, 1)
	..()

/obj/item/weapon/gun/energy/plasma_caster/able_to_fire(mob/user)
	if(!isyautja(user))
		to_chat(user, "<span class='warning'>You have no idea how this thing works!</span>")
		return
	return ..()

//-------------------------------------------------------
//Lasguns

/obj/item/weapon/gun/energy/lasgun
	name = "\improper Lasgun"
	desc = "A laser based firearm. Uses power cells."
	origin_tech = "combat=5;materials=4"
	reload_sound = 'sound/weapons/gun_rifle_reload.ogg'
	fire_sound = 'sound/weapons/Laser.ogg'
	matter = list("metal" = 2000)
	load_method = CELL //codex

	ammo = /datum/ammo/energy/lasgun
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = 4
	force = 15
	overcharge = FALSE
	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_ENERGY|GUN_AMMO_COUNTER
	aim_slowdown = SLOWDOWN_ADS_RIFLE
	wield_delay = WIELD_DELAY_SLOW
	gun_skill_category = GUN_SKILL_RIFLES


/obj/item/weapon/gun/energy/lasgun/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/low_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/max_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/high_hit_accuracy_mult)
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value) * 2 //Heavy and unwieldy
	damage_falloff_mult = CONFIG_GET(number/combat_define/med_damage_falloff_mult)


//-------------------------------------------------------
//M43 Sunfury Lasgun MK1

/obj/item/weapon/gun/energy/lasgun/M43
	name = "\improper M43 Sunfury Lasgun MK1"
	desc = "An accurate, recoilless laser based battle rifle with an integrated charge selector. Ideal for longer range engagements. Uses power cells."
	force = 20 //Large and hefty! Includes stock bonus.
	icon_state = "m43"
	item_state = "m43"
	max_shots = 50 //codex stuff
	load_method = CELL //codex stuff
	ammo = /datum/ammo/energy/lasgun/M43
	cell_type = null
	charge_cost = M37_STANDARD_AMMO_COST
	attachable_allowed = list(
						/obj/item/attachable/bayonet,
						/obj/item/attachable/reddot,
						/obj/item/attachable/verticalgrip,
						/obj/item/attachable/angledgrip,
						/obj/item/attachable/lasersight,
						/obj/item/attachable/gyro,
						/obj/item/attachable/flashlight,
						/obj/item/attachable/bipod,
						/obj/item/attachable/magnetic_harness,
						/obj/item/attachable/attached_gun/grenade,
						/obj/item/attachable/attached_gun/flamer,
						/obj/item/attachable/attached_gun/shotgun,
						/obj/item/attachable/scope/mini)

	flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK|GUN_AMMO_COUNTER|GUN_ENERGY|GUN_AMMO_COUNTER
	starting_attachment_types = list(/obj/item/attachable/attached_gun/grenade, /obj/item/attachable/stock/lasgun)
	attachable_offset = list("muzzle_x" = 32, "muzzle_y" = 18,"rail_x" = 12, "rail_y" = 23, "under_x" = 23, "under_y" = 15, "stock_x" = 22, "stock_y" = 12)

/obj/item/weapon/gun/energy/lasgun/M43/set_gun_config_values()
	fire_delay = CONFIG_GET(number/combat_define/low_fire_delay)
	accuracy_mult = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) + CONFIG_GET(number/combat_define/max_hit_accuracy_mult)
	accuracy_mult_unwielded = CONFIG_GET(number/combat_define/base_hit_accuracy_mult) - CONFIG_GET(number/combat_define/max_hit_accuracy_mult) //Heavy and unwieldy; you don't one hand this.
	damage_mult = CONFIG_GET(number/combat_define/base_hit_damage_mult)
	scatter_unwielded = CONFIG_GET(number/combat_define/max_scatter_value) * 2.5 //Heavy and unwieldy; you don't one hand this.
	damage_falloff_mult = CONFIG_GET(number/combat_define/low_damage_falloff_mult)

//variant without ugl attachment
/obj/item/weapon/gun/energy/lasgun/M43/stripped
	starting_attachment_types = list()

/obj/item/weapon/gun/energy/lasgun/M43/unique_action(mob/user)
	toggle_chargemode(user)


//Toggles Overcharge mode. Overcharge mode significantly increases damage and AP in exchange for doubled ammo usage and increased fire delay.
/obj/item/weapon/gun/energy/lasgun/proc/toggle_chargemode(mob/user)
	//if(in_chamber)
	//	delete_bullet(in_chamber, TRUE)
	if(overcharge == FALSE)
		if(!cell)
			playsound(user, 'sound/machines/buzz-two.ogg', 15, 0, 2)
			to_chat(user, "<span class='warning'>You attempt to toggle on [src]'s overcharge mode but you have no battery loaded.</span>")
			return
		if(cell.charge < M37_OVERCHARGE_AMMO_COST)
			playsound(user, 'sound/machines/buzz-two.ogg', 15, 0, 2)
			to_chat(user, "<span class='warning'>You attempt to toggle on [src]'s overcharge mode but your battery pack lacks adequate charge to do so.</span>")
			return
		//While overcharge is active, double ammo consumption, and
		playsound(user, 'sound/weapons/emitter.ogg', 5, 0, 2)
		charge_cost = M37_OVERCHARGE_AMMO_COST
		ammo = GLOB.ammo_list[/datum/ammo/energy/lasgun/M43/overcharge]
		fire_delay = M37_OVERCHARGE_FIRE_DELAY // 1 shot per second fire rate
		fire_sound = 'sound/weapons/Laser3.ogg'
		to_chat(user, "[icon2html(src, user)] You [overcharge? "<B>disable</b>" : "<B>enable</b>" ] [src]'s overcharge mode.")
		overcharge = TRUE
	else
		playsound(user, 'sound/weapons/emitter2.ogg', 5, 0, 2)
		charge_cost = M37_STANDARD_AMMO_COST
		ammo = GLOB.ammo_list[/datum/ammo/energy/lasgun/M43]
		fire_delay = CONFIG_GET(number/combat_define/low_fire_delay)
		fire_sound = 'sound/weapons/Laser.ogg'
		to_chat(user, "[icon2html(src, user)] You [overcharge? "<B>disable</b>" : "<B>enable</b>" ] [src]'s overcharge mode.")
		overcharge = FALSE

	//load_into_chamber()

	if(user)
		var/obj/screen/ammo/A = user.hud_used.ammo //The ammo HUD
		A.update_hud(user)

/obj/item/weapon/gun/energy/lasgun/load_into_chamber(mob/user)
		//Let's check on the active attachable. It loads ammo on the go, so it never chambers anything
	if(active_attachable)
		if(active_attachable.current_rounds > 0) //If it's still got ammo and stuff.
			active_attachable.current_rounds--
			return create_bullet(active_attachable.ammo)
		else
			to_chat(user, "<span class='warning'>[active_attachable] is empty!</span>")
			to_chat(user, "<span class='notice'>You disable [active_attachable].</span>")
			playsound(user, active_attachable.activation_sound, 15, 1)
			active_attachable.activate_attachment(src, null, TRUE)

	if(!cell?.use(charge_cost))
		return
	in_chamber = create_bullet(ammo)
	update_icon(user)
	return in_chamber

/obj/item/weapon/gun/energy/lasgun/reload_into_chamber(mob/user)
	/*
	ATTACHMENT POST PROCESSING
	This should only apply to the masterkey, since it's the only attachment that shoots through Fire()
	instead of its own thing through fire_attachment(). If any other bullet attachments are added, they would fire here.
	*/
	if(active_attachable)
		make_casing(active_attachable.type_of_casings) // Attachables can drop their own casings.

	if(!active_attachable && cell) //We don't need to check for the mag if an attachment was used to shoot.
		if(cell) //If there is no mag, we can't reload.
			if(overcharge && cell.charge < M37_OVERCHARGE_AMMO_COST && cell.charge >= M37_STANDARD_AMMO_COST) //Revert to standard shot if we don't have enough juice for overcharge, but enough for the standard mode
				toggle_chargemode(user)
				return
			if(cell.charge <= 0 && flags_gun_features & GUN_AUTO_EJECTOR) // This is where the magazine is auto-ejected.
				unload(user,1,1) // We want to quickly autoeject the magazine. This proc does the rest based on magazine type. User can be passed as null.
				playsound(src, empty_sound, 25, 1)

	return TRUE


//Ammo/Charge functions
/obj/item/weapon/gun/energy/lasgun/update_icon(mob/user)
	if(!cell || cell.charge <= 0)
		icon_state = base_gun_icon + "_0"
		if(flags_item & WIELDED)
			item_state = "m43_0_w"
		else
			item_state = "m43_0"
	else
		var/remaining = CEILING((cell.charge / max(cell.maxcharge, 1)) * 100, 25)
		icon_state = "[base_gun_icon]_[remaining]"
		item_state = "m43_[remaining][flags_item & WIELDED ? "_w" : ""]"

	if(cell)
		update_mag_overlay()

	if(ishuman(user))
		var/mob/living/carbon/human/M = user
		if(src == M.l_hand)
			M.update_inv_l_hand()
		else if (src == M.r_hand)
			M.update_inv_r_hand()

/obj/item/weapon/gun/energy/lasgun/attackby(obj/item/I, mob/user)
	if(flags_gun_features & GUN_BURST_FIRING)
		return

	if(istype(I,/obj/item/attachable))
		if(check_inactive_hand(user))
			attach_to_gun(user,I)

 	//the active attachment is reloadable
	else if(active_attachable && active_attachable.flags_attach_features & ATTACH_RELOADABLE)
		if(!check_inactive_hand(user))
			return
		if(istype(I,/obj/item/ammo_magazine))
			var/obj/item/ammo_magazine/MG = I
			if(istype(src, MG.gun_type))
				to_chat(user, "<span class='notice'>You disable [active_attachable].</span>")
				playsound(user, active_attachable.activation_sound, 15, 1)
				active_attachable.activate_attachment(src, null, TRUE)
				reload(user,MG)
				return
		active_attachable.reload_attachment(I, user)

	else if(istype(I,/obj/item/cell/lasgun))
		if(check_inactive_hand(user))
			reload(user,I)


/obj/item/weapon/gun/energy/lasgun/reload(mob/user, obj/item/cell/lasgun/new_cell)
	if(flags_gun_features & (GUN_BURST_FIRING|GUN_UNUSUAL_DESIGN|GUN_INTERNAL_MAG))
		return

	if(!new_cell || !istype(new_cell))
		to_chat(user, "<span class='warning'>That's not a power cell!</span>")
		return

	if(new_cell.charge <= 0)
		to_chat(user, "<span class='warning'>[cell] is depleted!</span>")
		return

	if(!istype(src, new_cell.gun_type))
		to_chat(user, "<span class='warning'>That power cell doesn't fit in there!</span>")
		return

	if(cell)
		to_chat(user, "<span class='warning'>It's still got something loaded.</span>")
		return

	if(user)
		if(new_cell.reload_delay > 1)
			to_chat(user, "<span class='notice'>You begin reloading [src]. Hold still...</span>")
			if(do_after(user,new_cell.reload_delay, TRUE, 5, BUSY_ICON_FRIENDLY))
				replace_magazine(user, new_cell)
			else
				to_chat(user, "<span class='warning'>Your reload was interrupted!</span>")
				return
		else
			replace_magazine(user, new_cell)
	else
		replace_magazine(null, new_cell)
	return TRUE

/obj/item/weapon/gun/energy/lasgun/replace_magazine(mob/user, obj/item/cell/lasgun/new_cell)
	cell = new_cell
	if(user)
		user.transferItemToLoc(new_cell, src) //Click!
		user.visible_message("<span class='notice'>[user] loads [new_cell] into [src]!</span>",
		"<span class='notice'>You load [new_cell] into [src]!</span>", null, 3)
		if(reload_sound)
			playsound(user, reload_sound, 25, 1, 5)
		update_icon(user)
	else
		cell.loc = src
		update_icon()

//Drop out the magazine. Keep the ammo type for next time so we don't need to replace it every time.
//This can be passed with a null user, so we need to check for that as well.
/obj/item/weapon/gun/energy/lasgun/unload(mob/user, reload_override = 0, drop_override = 0) //Override for reloading mags after shooting, so it doesn't interrupt burst. Drop is for dropping the magazine on the ground.
	if(!reload_override && (flags_gun_features & (GUN_BURST_FIRING|GUN_UNUSUAL_DESIGN|GUN_INTERNAL_MAG)))
		return

	if(!cell || cell.loc != src)
		return

	if(drop_override || !user) //If we want to drop it on the ground or there's no user.
		cell.loc = get_turf(src) //Drop it on the ground.
	else
		user.put_in_hands(cell)

	playsound(user, unload_sound, 25, 1, 5)
	user.visible_message("<span class='notice'>[user] unloads [cell] from [src].</span>",
	"<span class='notice'>You unload [cell] from [src].</span>", null, 4)
	cell.update_icon()
	cell = null

	update_icon(user)
