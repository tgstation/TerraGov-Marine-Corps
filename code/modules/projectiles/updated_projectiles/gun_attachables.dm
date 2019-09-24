
//Gun attachable items code. Lets you add various effects to firearms.
//Some attachables are hardcoded in the projectile firing system, like grenade launchers, flamethrowers.
/*
When you are adding new guns into the attachment list, or even old guns, make sure that said guns
properly accept overlays. You can find the proper offsets in the individual gun dms, so make sure
you set them right. It's a pain to go back to find which guns are set incorrectly.
To summarize: rail attachments should go on top of the rail. For rifles, this usually means the middle of the gun.
For handguns, this is usually toward the back of the gun. SMGs usually follow rifles.
Muzzle attachments should connect to the barrel, not sit under or above it. The only exception is the bayonet.
Underrail attachments should just fit snugly, that's about it. Stocks are pretty obvious.

All attachment offsets are now in a list, including stocks. Guns that don't take attachments can keep the list null.
~N

Defined in conflicts.dm of the #defines folder.
#define ATTACH_REMOVABLE	1
#define ATTACH_ACTIVATION	2
#define ATTACH_PROJECTILE	4
#define ATTACH_RELOADABLE	8
#define ATTACH_WEAPON		16
#define ATTACH_UTILITY		32
*/

/obj/item/attachable
	name = "attachable item"
	desc = "It's an attachment. You should never see this."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = null
	item_state = null
	var/attach_icon //the sprite to show when the attachment is attached when we want it different from the icon_state.
	var/pixel_shift_x = 16 //Determines the amount of pixels to move the icon state for the overlay.
	var/pixel_shift_y = 16 //Uses the bottom left corner of the item.

	flags_atom = CONDUCT
	materials = list(/datum/material/metal = 1000)
	w_class = WEIGHT_CLASS_SMALL
	force = 1.0
	var/slot = null //"muzzle", "rail", "under", "stock"

	/*
	Anything that isn't used as the gun fires should be a flat number, never a percentange. It screws with the calculations,
	and can mean that the order you attach something/detach something will matter in the final number. It's also completely
	inaccurate. Don't worry if force is ever negative, it won't runtime.
	*/
	//These bonuses are applied only as the gun fires a projectile.

	//These are flat bonuses applied and are passive, though they may be applied at different points.
	var/accuracy_mod 	= 0 //Modifier to firing accuracy, works off a multiplier.
	var/accuracy_unwielded_mod = 0 //same as above but for onehanded.
	var/damage_mod 		= 0 //Modifer to the damage mult, works off a multiplier.
	var/damage_falloff_mod = 0 //Modifier to damage falloff, works off a multiplier.
	var/melee_mod 		= 0 //Changing to a flat number so this actually doesn't screw up the calculations.
	var/scatter_mod 	= 0 //Increases or decreases scatter chance.
	var/scatter_unwielded_mod = 0 //same as above but for onehanded firing.
	var/recoil_mod 		= 0 //If positive, adds recoil, if negative, lowers it. Recoil can't go below 0.
	var/recoil_unwielded_mod = 0 //same as above but for onehanded firing.
	var/burst_scatter_mod = 0 //Modifier to scatter from wielded burst fire, works off a multiplier.
	var/silence_mod 	= 0 //Adds silenced to weapon
	var/light_mod 		= 0 //Adds an x-brightness flashlight to the weapon, which can be toggled on and off.
	var/delay_mod 		= 0 //Changes firing delay. Cannot go below 0.
	var/burst_delay_mod = 0 //Changes burst firing delay. Cannot go below 0.
	var/burst_mod 		= 0 //Changes burst rate. 1 == 0.
	var/size_mod 		= 0 //Increases the weight class.
	var/aim_speed_mod	= 0 //Changes the aiming speed slowdown of the wearer by this value.
	var/wield_delay_mod	= 0 //How long ADS takes (time before firing)
	var/attach_shell_speed_mod = 0 //Changes the speed of projectiles fired
	var/movement_acc_penalty_mod = 0 //Modifies accuracy/scatter penalty when firing onehanded while moving.
	var/attach_delay = 30 //How long in deciseconds it takes to attach a weapon with level 1 firearms training. Default is 30 seconds.
	var/detach_delay = 30 //How long in deciseconds it takes to detach a weapon with level 1 firearms training. Default is 30 seconds.

	var/attachment_firing_delay = 0 //the delay between shots, for attachments that fires stuff

	var/activation_sound = 'sound/machines/click.ogg'

	var/flags_attach_features = ATTACH_REMOVABLE

	var/bipod_deployed = FALSE //only used by bipod
	var/current_rounds 	= 0 //How much it has.
	var/max_rounds 		= 0 //How much ammo it can store
	var/max_range		= 0

	var/attachment_action_type
	var/scope_zoom_mod = FALSE //codex

	var/obj/item/weapon/gun/master_gun


/obj/item/attachable/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(flags_attach_features & ATTACH_RELOADABLE)
		if(user.get_inactive_held_item() != src)
			to_chat(user, "<span class='warning'>You have to hold [src] to do that!</span>")
		else
			reload_attachment(I, user)
		return TRUE


/obj/item/attachable/attack_hand(mob/living/user)
	if(master_gun)
		return
	return ..()


/obj/item/attachable/proc/Attach(obj/item/weapon/gun/gun_to_attach, mob/user)
	if(!istype(gun_to_attach))
		return //Guns only
	master_gun = gun_to_attach
	/*
	This does not check if the attachment can be removed.
	Instead of checking individual attachments, I simply removed
	the specific guns for the specific attachments so you can't
	attempt the process in the first place if a slot can't be
	removed on a gun. can_be_removed is instead used when they
	try to strip the gun.
	*/
	switch(slot)
		if("rail")
			master_gun.rail?.Detach(user)
			master_gun.rail = src
		if("muzzle")
			master_gun.muzzle?.Detach(user)
			master_gun.muzzle = src
		if("under")
			master_gun.under?.Detach(user)
			master_gun.under = src
		if("stock")
			master_gun.stock?.Detach(user)
			master_gun.stock = src

	if(ishuman(user))
		var/mob/living/carbon/human/wielder = user
		wielder.drop_held_item(src)

	forceMove(master_gun)

	master_gun.accuracy_mult				+= accuracy_mod
	master_gun.accuracy_mult_unwielded		+= accuracy_unwielded_mod
	master_gun.damage_mult					+= damage_mod
	master_gun.damage_falloff_mult			+= damage_falloff_mod
	master_gun.w_class						+= size_mod
	master_gun.scatter						+= scatter_mod
	master_gun.scatter_unwielded			+= scatter_unwielded_mod
	if(delay_mod)
		master_gun.modify_fire_delay(delay_mod)
	if(burst_delay_mod)
		master_gun.modify_burst_delay(burst_delay_mod)
	if(burst_mod)
		master_gun.modify_burst_amount(burst_mod, user)
	master_gun.recoil						+= recoil_mod
	master_gun.recoil_unwielded				+= recoil_unwielded_mod
	master_gun.force						+= melee_mod
	master_gun.aim_slowdown					+= aim_speed_mod
	master_gun.wield_delay					+= wield_delay_mod
	master_gun.burst_scatter_mult			+= burst_scatter_mod
	master_gun.movement_acc_penalty_mult	+= movement_acc_penalty_mod
	master_gun.shell_speed_mod				+= attach_shell_speed_mod
	master_gun.scope_zoom					+= scope_zoom_mod

	master_gun.update_force_list() //This updates the gun to use proper force verbs.

	if(silence_mod)
		master_gun.flags_gun_features |= GUN_SILENCED
		master_gun.muzzle_flash = null
		master_gun.fire_sound = "gun_silenced"

	master_gun.update_attachable(slot)

	if(attachment_action_type)
		var/datum/action/action_to_update = new attachment_action_type(src, master_gun)
		if(isliving(master_gun.loc))
			var/mob/living/living_user = master_gun.loc
			if(master_gun == living_user.l_hand || master_gun == living_user.r_hand)
				action_to_update.give_action(living_user)


/obj/item/attachable/proc/Detach(mob/user)
	if(flags_attach_features & ATTACH_ACTIVATION)
		activate_attachment(null, TRUE)

	switch(slot)
		if("rail")
			master_gun.rail = null
		if("muzzle")
			master_gun.muzzle = null
		if("under")
			master_gun.under = null
		if("stock")
			master_gun.stock = null

	master_gun.accuracy_mult				-= accuracy_mod
	master_gun.accuracy_mult_unwielded		-= accuracy_unwielded_mod
	master_gun.damage_mult					-= damage_mod
	master_gun.damage_falloff_mult			-= damage_falloff_mod
	master_gun.w_class						-= size_mod
	master_gun.scatter						-= scatter_mod
	master_gun.scatter_unwielded			-= scatter_unwielded_mod
	if(delay_mod)
		master_gun.modify_fire_delay(-delay_mod)
	if(burst_delay_mod)
		master_gun.modify_burst_delay(-burst_delay_mod)
	if(burst_mod)
		master_gun.modify_burst_amount(-burst_mod, user)
	master_gun.recoil						-= recoil_mod
	master_gun.recoil_unwielded				-= recoil_unwielded_mod
	master_gun.force						-= melee_mod
	master_gun.aim_slowdown					-= aim_speed_mod
	master_gun.wield_delay					-= wield_delay_mod
	master_gun.burst_scatter_mult			-= burst_scatter_mod
	master_gun.movement_acc_penalty_mult	-= movement_acc_penalty_mod
	master_gun.shell_speed_mod				-=attach_shell_speed_mod
	master_gun.scope_zoom					-= scope_zoom_mod

	master_gun.update_force_list()

	if(silence_mod) //Built in silencers always come as an attach, so the gun can't be silenced right off the bat.
		master_gun.flags_gun_features &= ~GUN_SILENCED
		master_gun.muzzle_flash = initial(master_gun.muzzle_flash)
		master_gun.fire_sound = initial(master_gun.fire_sound)

	for(var/i in master_gun.actions)
		var/datum/action/action_to_update = i
		if(action_to_update.target != src)
			continue
		qdel(action_to_update)
		break

	forceMove(get_turf(master_gun))

	master_gun = null


/obj/item/attachable/ui_action_click(mob/living/user, datum/action/item_action/action, obj/item/weapon/gun/G)
	if(G == user.get_active_held_item() || G == user.get_inactive_held_item())
		if(activate_attachment(user)) //success
			playsound(user, activation_sound, 15, 1)
	else
		to_chat(user, "<span class='warning'>[G] must be in our hands to do this.</span>")




/obj/item/attachable/proc/activate_attachment(mob/user, turn_off) //This is for activating stuff like flamethrowers, or switching weapon modes.
	return

/obj/item/attachable/proc/reload_attachment(obj/item/I, mob/user)
	return

/obj/item/attachable/proc/fire_attachment(atom/target,obj/item/weapon/gun/gun, mob/user) //For actually shooting those guns.
	return


/////////// Muzzle Attachments /////////////////////////////////

/obj/item/attachable/suppressor
	name = "suppressor"
	desc = "A small tube with exhaust ports to expel noise and gas.\nDoes not completely silence a weapon, but does make it much quieter and a little more accurate and stable at the cost of slightly reduced damage and bullet speed."
	icon_state = "suppressor"
	slot = "muzzle"
	silence_mod = 1
	pixel_shift_y = 16
	attach_icon = "suppressor_a"
	attach_shell_speed_mod = -1
	accuracy_mod = 0.15
	damage_mod = -0.05
	recoil_mod = -2
	scatter_mod = -5
	accuracy_unwielded_mod = -0.05
	recoil_unwielded_mod = -2
	scatter_unwielded_mod = -5
	damage_falloff_mod = 0.1


/obj/item/attachable/suppressor/Initialize()
	. = ..()
	attach_icon = pick("suppressor_a","suppressor2_a")


/obj/item/attachable/suppressor/unremovable
	flags_attach_features = NONE


/obj/item/attachable/suppressor/unremovable/invisible
	attach_icon = ""
	icon_state = ""


/obj/item/attachable/suppressor/unremovable/invisible/Initialize(mapload, ...)
	. = ..()
	attach_icon = ""


/obj/item/attachable/bayonet
	name = "bayonet"
	desc = "A sharp blade for mounting on a weapon. It can be used to stab manually on anything but harm intent."
	icon_state = "bayonet"
	attach_icon = "bayonet_a"
	force = 20
	throwforce = 10
	attach_delay = 10 //Bayonets attach/detach quickly.
	detach_delay = 10
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	melee_mod = 20 //35 for a rifle, comparable to 37 before. 40 with the stock, comparable to 42.
	slot = "muzzle"
	pixel_shift_x = 14 //Below the muzzle.
	pixel_shift_y = 18
	accuracy_mod = -0.05
	accuracy_unwielded_mod = -0.05
	size_mod = 1

/obj/item/attachable/bayonet/attackby(obj/item/I, mob/user)
	. = ..()

	if(istype(I,/obj/item/tool/screwdriver))
		to_chat(user, "<span class='notice'>You modify the bayonet back into a combat knife.</span>")
		if(loc == user)
			user.dropItemToGround(src)
		var/obj/item/weapon/combat_knife/F = new(loc)
		user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
		if(F.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
			F.forceMove(loc)
		qdel(src) //Delete da old bayonet

/obj/item/attachable/extended_barrel
	name = "extended barrel"
	desc = "A lengthened barrel allows for lessened scatter, greater accuracy and muzzle velocity due to increased stabilization and shockwave exposure.\nHowever, this increase in velocity reduces tumbling, leading to slightly reduced damage."
	slot = "muzzle"
	icon_state = "ebarrel"
	attach_icon = "ebarrel_a"
	attach_shell_speed_mod = -1
	accuracy_mod = 0.20
	accuracy_unwielded_mod = 0.15
	damage_mod = -0.05
	scatter_mod = -5
	size_mod = 1


/obj/item/attachable/heavy_barrel
	name = "barrel charger"
	desc = "A fitted barrel extender that goes on the muzzle, with a small shaped charge that propels a bullet much faster.\nGreatly increases projectile damage and increases projectile speed at the cost of accuracy and firing speed."
	slot = "muzzle"
	icon_state = "hbarrel"
	attach_icon = "hbarrel_a"
	attach_shell_speed_mod = 1
	accuracy_mod = -0.30
	damage_mod = 0.30
	delay_mod = 3
	scatter_mod = 5
	accuracy_unwielded_mod = -0.40


/obj/item/attachable/compensator
	name = "recoil compensator"
	desc = "A muzzle attachment that reduces recoil and scatter by diverting expelled gasses upwards. \nSignificantly reduces recoil and scatter, at the cost of a small amount of weapon damage."
	slot = "muzzle"
	icon_state = "comp"
	attach_icon = "comp_a"
	pixel_shift_x = 17
	scatter_mod = -20
	damage_mod = -0.05
	recoil_mod = -3
	scatter_unwielded_mod = -20
	recoil_unwielded_mod = -3


/obj/item/attachable/slavicbarrel
	name = "sniper barrel"
	icon_state = "slavicbarrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = "muzzle"

	pixel_shift_x = 20
	pixel_shift_y = 16
	flags_attach_features = NONE
	accuracy_mod = 0.05
	scatter_mod = -15

/obj/item/attachable/mosinbarrel
	name = "mosin barrel"
	icon_state = "mosinbarrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = "under" //only way for it to work with a bayonet is to make this take the underbarrel slot. no more bipods.

	pixel_shift_x = 20
	pixel_shift_y = 16
	flags_attach_features = NONE
	accuracy_mod = 0.05
	scatter_mod = -15

/obj/item/attachable/sniperbarrel
	name = "sniper barrel"
	icon_state = "sniperbarrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = "muzzle"
	flags_attach_features = NONE
	accuracy_mod = 0.15
	scatter_mod = -15

/obj/item/attachable/smartbarrel
	name = "smartgun barrel"
	icon_state = "smartbarrel"
	desc = "A heavy rotating barrel. CANNOT BE REMOVED."
	slot = "muzzle"
	flags_attach_features = NONE






///////////// Rail attachments ////////////////////////

/obj/item/attachable/reddot
	name = "red-dot sight"
	desc = "A red-dot sight for short to medium range. Does not have a zoom feature, but does increase weapon accuracy by a good amount. \nNo drawbacks."
	icon_state = "reddot"
	attach_icon = "reddot_a"
	slot = "rail"
	accuracy_mod = 0.20
	accuracy_unwielded_mod = 0.15
	movement_acc_penalty_mod = -0.1


/obj/item/attachable/m16sight
	name = "M16 iron sights"
	desc = "The iconic carry-handle iron sights for the m16. Usually removed once the user finds something worthwhile to attach to the rail."
	icon_state = "m16sight"
	attach_icon = "m16sight_a"
	slot = "rail"
	accuracy_mod = 0.1
	accuracy_unwielded_mod = 0.05
	movement_acc_penalty_mod = -0.1


/obj/item/attachable/flashlight
	name = "rail flashlight"
	desc = "A simple flashlight used for mounting on a firearm. \nHas no drawbacks, but isn't particuraly useful outside of providing a light source."
	icon_state = "flashlight"
	attach_icon = "flashlight_a"
	light_mod = 7
	slot = "rail"
	materials = list(/datum/material/metal = 100, /datum/material/glass = 20)
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	activation_sound = 'sound/items/flashlight.ogg'

/obj/item/attachable/flashlight/activate_attachment(mob/living/user, turn_off)
	if(turn_off && !(master_gun.flags_gun_features & GUN_FLASHLIGHT_ON))
		return

	if(ismob(master_gun.loc) && !user)
		user = master_gun.loc

	if(master_gun.flags_gun_features & GUN_FLASHLIGHT_ON)
		icon_state = "flashlight"
		attach_icon = "flashlight_a"
		master_gun.set_light(0)
	else
		icon_state = "flashlight-on"
		attach_icon = "flashlight_a-on"
		master_gun.set_light(light_mod)

	master_gun.flags_gun_features ^= GUN_FLASHLIGHT_ON

	master_gun.update_attachable(slot)

	for(var/X in master_gun.actions)
		var/datum/action/A = X
		A.update_button_icon()
	return TRUE




/obj/item/attachable/flashlight/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I,/obj/item/tool/screwdriver))
		to_chat(user, "<span class='notice'>You modify the rail flashlight back into a normal flashlight.</span>")
		if(loc == user)
			user.temporarilyRemoveItemFromInventory(src)
		var/obj/item/flashlight/F = new(user)
		user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
		qdel(src) //Delete da old flashlight



/obj/item/attachable/quickfire
	name = "quickfire adapter"
	desc = "An enhanced and upgraded autoloading mechanism to fire rounds more quickly. \nHowever, it also reduces accuracy and the number of bullets fired on burst."
	slot = "rail"
	icon_state = "autoloader"
	attach_icon = "autoloader_a"
	accuracy_mod = -0.20
	scatter_mod = 5
	delay_mod = -1
	burst_mod = -1
	accuracy_unwielded_mod = -0.30
	scatter_unwielded_mod = 20


/obj/item/attachable/magnetic_harness
	name = "magnetic harness"
	desc = "A magnetically attached harness kit that attaches to the rail mount of a weapon. When dropped, the weapon will sling to a TGMC armor."
	icon_state = "magnetic"
	attach_icon = "magnetic_a"
	slot = "rail"
	pixel_shift_x = 13


/obj/item/attachable/scope
	name = "rail scope"
	icon_state = "sniperscope"
	attach_icon = "sniperscope_a"
	desc = "A rail mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	slot = "rail"
	aim_speed_mod = 1 //Extra slowdown when aiming
	wield_delay_mod = 0.6 SECONDS
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	scope_zoom_mod = TRUE
	movement_acc_penalty_mod = 0.25
	accuracy_unwielded_mod = -0.05
	var/zoom_offset = 11
	var/zoom_viewsize = 12
	var/zoom_accuracy = SCOPE_RAIL


/obj/item/attachable/scope/unremovable
	flags_attach_features = ATTACH_ACTIVATION


/obj/item/attachable/scope/activate_attachment(mob/living/carbon/user, turn_off)
	if(turn_off)
		if(master_gun.zoom)
			master_gun.zoom(user, zoom_offset, zoom_viewsize)
		return TRUE

	if(!master_gun.zoom && !(master_gun.flags_item & WIELDED))
		if(user)
			to_chat(user, "<span class='warning'>You must hold [master_gun] with two hands to use [src].</span>")
		return FALSE
	else
		master_gun.zoom(user, zoom_offset, zoom_viewsize)
	return TRUE


/obj/item/attachable/scope/mini
	name = "mini rail scope"
	icon_state = "miniscope"
	attach_icon = "miniscope_a"
	desc = "A small rail mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	slot = "rail"
	wield_delay_mod = 0.4 SECONDS
	zoom_offset = 5
	zoom_viewsize = 7
	zoom_accuracy = SCOPE_RAIL_MINI
	scope_zoom_mod = TRUE
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/scope/m4ra
	name = "M4RA rail scope"
	attach_icon = "none"
	desc = "A rail mounted zoom sight scope specialized for the M4RA Battle Rifle . Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	zoom_offset = 5
	zoom_viewsize = 7
	zoom_accuracy = SCOPE_RAIL_MINI
	flags_attach_features = ATTACH_ACTIVATION


/obj/item/attachable/scope/m42a
	name = "m42a rail scope"
	attach_icon = "none"
	desc = "A rail mounted zoom sight scope specialized for the M42A Sniper Rifle . Allows zoom by activating the attachment. Can activate its targeting laser while zoomed to take aim for increased damage and penetration. Use F12 if your HUD doesn't come back."
	zoom_accuracy = SCOPE_RAIL_SNIPER
	flags_attach_features = ATTACH_ACTIVATION

/obj/item/attachable/scope/slavic
	icon_state = "slavicscope"
	attach_icon = "slavicscope"

/obj/item/attachable/scope/pmc
	icon_state = "pmcscope"
	attach_icon = "pmcscope"
	flags_attach_features = ATTACH_ACTIVATION

//////////// Stock attachments ////////////////////////////


/obj/item/attachable/stock //Generic stock parent and related things.
	name = "default stock"
	desc = "Default parent object, not meant for use."
	icon_state = "stock"
	slot = "stock"
	wield_delay_mod = 0.2 SECONDS
	melee_mod = 5
	size_mod = 2
	pixel_shift_x = 30
	pixel_shift_y = 14

/obj/item/attachable/stock/shotgun
	name = "\improper M37 wooden stock"
	desc = "A non-standard heavy wooden stock for the M37 Shotgun. Less quick and more cumbersome than the standard issue stakeout, but reduces recoil and improves accuracy. Allegedly makes a pretty good club in a fight too."
	slot = "stock"
	wield_delay_mod = 0.4 SECONDS
	icon_state = "stock"
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/stock/tactical
	name = "\improper MK221 tactical stock"
	desc = "A sturdy polymer stock for the MK221 shotgun. Supplied in limited numbers and moderately encumbering, it provides an ergonomic surface to ease perceived recoil and usability."
	icon_state = "tactical_stock"
	accuracy_mod = 0.05
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/stock/scout
	name = "\improper ZX-76 tactical stock"
	desc = "A standard polymer stock for the ZX-76 assault shotgun. Designed for maximum ease of use in close quarters."
	icon_state = "zx_stock"
	wield_delay_mod = 0
	flags_attach_features = NONE
	accuracy_mod = 0.05
	recoil_mod = -2
	scatter_mod = -5

/obj/item/attachable/stock/slavic
	name = "wooden stock"
	desc = "A standard heavy wooden stock for Slavic firearms."
	icon_state = "slavicstock"
	wield_delay_mod = 0.6 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0.05
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/stock/mosin
	name = "mosin wooden stock"
	desc = "A non-standard long wooden stock for Slavic firearms."
	icon_state = "mosinstock"
	wield_delay_mod = 0.6 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1


/obj/item/attachable/stock/m16
	name = "M16 Composite Stock"
	desc = "A composite stock securely fit to the M16 platform. Disassembly required to remove, not recommended."
	icon_state = "m16stock"
	wield_delay_mod = 0.5 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE


/obj/item/attachable/stock/ak47
	name = "AK-47 Wooden Stock"
	desc = "A metallic stock with a wooden paint coating, made to fit the AK-47 replica."
	icon_state = "ak47stock"
	wield_delay_mod = 0.4 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE


/obj/item/attachable/stock/rifle
	name = "\improper M41A1 skeleton stock"
	desc = "A rare stock distributed in small numbers to TGMC forces. Compatible with the M41A1, this stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	slot = "stock"
	wield_delay_mod = 0.6 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "riflestock"
	attach_icon = "riflestock_a"
	pixel_shift_x = 41
	pixel_shift_y = 10
	accuracy_mod = 0.05
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/stock/rifle/marksman
	name = "\improper M4RA marksman stock"
	icon_state = "m4markstock"
	attach_icon = "m4markstock"
	flags_attach_features = NONE


/obj/item/attachable/stock/smg
	name = "M39 submachinegun stock"
	desc = "A rare stock distributed in small numbers to TGMC forces. Compatible with the M39, this stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	slot = "stock"
	wield_delay_mod = 0.4 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "smgstock"
	attach_icon = "smgstock_a"
	pixel_shift_x = 39
	pixel_shift_y = 11
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/stock/vp70
	name = "88 Mod 4 stock and holster"
	desc = "A rare holster-stock distributed in small numbers to TGMC forces. Compatible with the 88 Mod 4, this stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	slot = "stock"
	flags_equip_slot = ITEM_SLOT_POCKET
	w_class = WEIGHT_CLASS_NORMAL
	wield_delay_mod = 0.4 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "vp70stock" // Thank you to Manezinho
	attach_icon = "vp70stock_a" // Thank you to Manezinho
	pixel_shift_x = 39
	pixel_shift_y = 11
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1
	var/obj/item/storage/internal/pockets = /obj/item/storage/internal/pockets/vp70holster

/obj/item/storage/internal/pockets/vp70holster
	storage_slots = 1
	max_w_class = 1
	bypass_w_limit = list(/obj/item/weapon/gun/pistol/vp70)
	max_storage_space = 3

/obj/item/attachable/stock/vp70/Initialize()
	. = ..()
	pockets = new pockets(src)

/obj/item/attachable/stock/vp70/attack_hand(mob/living/user)
	if(loc == user && length(pockets.contents))
		var/obj/item/I = pockets.contents[length(pockets.contents)]
		return I.attack_hand(user)
	else if(pockets.handle_attack_hand(user))
		return ..()

/obj/item/attachable/stock/vp70/MouseDrop(obj/over_object)
	if(pockets.handle_mousedrop(usr, over_object))
		return ..(over_object)

/obj/item/attachable/stock/vp70/attackby(obj/item/I, mob/user, params)
	. = ..()
	return pockets.attackby(I, user, params)

/obj/item/attachable/stock/vp70/emp_act(severity)
	pockets.emp_act(severity)
	return ..()

/obj/item/attachable/stock/revolver
	name = "\improper M44 magnum sharpshooter stock"
	desc = "A wooden stock modified for use on a 44-magnum. Increases accuracy and reduces recoil at the expense of handling and agility."
	slot = "stock"
	wield_delay_mod = 0.2 SECONDS
	size_mod = 2
	icon_state = "44stock"
	pixel_shift_x = 35
	pixel_shift_y = 19
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1
	accuracy_unwielded_mod = 0.05
	recoil_unwielded_mod = -2
	scatter_unwielded_mod = -5


/obj/item/attachable/stock/lasgun
	name = "\improper M43 Sunfury lasgun stock"
	desc = "The standard stock for the M43 Sunfury lasgun."
	slot = "stock"
	wield_delay_mod = null
	icon_state = "laserstock"
	attach_icon = "laserstock"
	pixel_shift_x = 41
	pixel_shift_y = 10
	flags_attach_features = NONE

////////////// Underbarrel Attachments ////////////////////////////////////


/obj/item/attachable/attached_gun
	attachment_action_type = /datum/action/item_action/toggle
	//Some attachments may be fired. So here are the variables related to that.
	var/datum/ammo/ammo = null //If it has a default bullet-like ammo.
	max_range 		= 0 //Determines # of tiles distance the attachable can fire, if it's not a projectile.
	var/type_of_casings = null
	var/fire_sound = null //Sound to play when firing it alternately


/obj/item/attachable/attached_gun/Initialize() //Let's make sure if something needs an ammo type, it spawns with one.
	. = ..()
	if(ammo)
		ammo = GLOB.ammo_list[ammo]


/obj/item/attachable/attached_gun/Destroy()
	ammo = null
	return ..()



/obj/item/attachable/attached_gun/activate_attachment(mob/living/user, turn_off)
	if(master_gun.active_attachable == src)
		if(user)
			to_chat(user, "<span class='notice'>You are no longer using [src].</span>")
		master_gun.on_gun_attachment_detach(src)
		icon_state = initial(icon_state)
	else if(!turn_off)
		if(user)
			to_chat(user, "<span class='notice'>You are now using [src].</span>")
		master_gun.on_gun_attachment_attach(src)
		icon_state += "-on"

	for(var/X in master_gun.actions)
		var/datum/action/A = X
		A.update_button_icon()
	return TRUE



//The requirement for an attachable being alt fire is AMMO CAPACITY > 0.
/obj/item/attachable/attached_gun/grenade
	name = "underslung grenade launcher"
	desc = "A weapon-mounted, reloadable, one-shot grenade launcher."
	icon_state = "grenade"
	attach_icon = "grenade_a"
	w_class = WEIGHT_CLASS_BULKY
	current_rounds = 0
	max_rounds = 2
	max_range = 7
	slot = "under"
	fire_sound = 'sound/weapons/guns/fire/m92_attachable.ogg'
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_RELOADABLE|ATTACH_WEAPON
	var/list/loaded_grenades = list() //list of grenade types loaded in the UGL
	attachment_firing_delay = 21

/obj/item/attachable/attached_gun/grenade/unremovable
	flags_attach_features = ATTACH_ACTIVATION|ATTACH_RELOADABLE|ATTACH_WEAPON

/obj/item/attachable/attached_gun/grenade/unremovable/invisible
	icon_state = ""
	attach_icon = ""


/obj/item/attachable/attached_gun/grenade/examine(mob/user)
	..()
	if(current_rounds)
		to_chat(user, "It has [current_rounds] grenade\s left.")
	else
		to_chat(user, "It's empty.")





/obj/item/attachable/attached_gun/grenade/reload_attachment(obj/item/explosive/grenade/G, mob/user)
	if(!istype(G))
		to_chat(user, "<span class='warning'>[src] doesn't accept that type of grenade.</span>")
		return
	if(!G.active) //can't load live grenades
		if(!G.underslug_launchable)
			to_chat(user, "<span class='warning'>[src] doesn't accept that type of grenade.</span>")
			return
		if(current_rounds >= max_rounds)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		else
			playsound(user, 'sound/weapons/guns/interact/shotgun_shell_insert.ogg', 25, 1)
			current_rounds++
			loaded_grenades += G.type
			to_chat(user, "<span class='notice'>You load [G] in [src].</span>")
			user.temporarilyRemoveItemFromInventory(G)
			qdel(G)

/obj/item/attachable/attached_gun/grenade/fire_attachment(atom/target,obj/item/weapon/gun/gun,mob/living/user)
	if(get_dist(user,target) > max_range)
		to_chat(user, "<span class='warning'>Too far to fire the attachment!</span>")
		return
	if(current_rounds > 0)
		prime_grenade(target,gun,user)


/obj/item/attachable/attached_gun/grenade/proc/prime_grenade(atom/target, obj/item/weapon/gun/gun, mob/living/user)
	set waitfor = FALSE
	var/nade_type = loaded_grenades[1]
	var/obj/item/explosive/grenade/frag/G = new nade_type (get_turf(gun))
	playsound(user.loc, fire_sound, 50, 1)
	log_explosion("[key_name(user)] fired a grenade [G] from [src] at [AREACOORD(user.loc)].")
	log_combat(user, src, "fired a grenade [G] from")
	G.det_time = min(15, G.det_time)
	G.throw_range = max_range
	G.launched = TRUE
	G.activate()
	G.throwforce += G.launchforce //Throws with signifcantly more force than a standard marine can.
	G.throw_at(target, max_range, 3, user)
	current_rounds--
	loaded_grenades.Cut(1,2)


//"ammo/flamethrower" is a bullet, but the actual process is handled through fire_attachment, linked through Fire().
/obj/item/attachable/attached_gun/flamer
	name = "mini flamethrower"
	icon_state = "flamethrower"
	attach_icon = "flamethrower_a"
	desc = "A weapon-mounted refillable flamethrower attachment.\nIt is designed for short bursts."
	w_class = WEIGHT_CLASS_BULKY
	current_rounds = 20
	max_rounds = 20
	max_range = 4
	slot = "under"
	fire_sound = 'sound/weapons/guns/fire/flamethrower3.ogg'
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_RELOADABLE|ATTACH_WEAPON
	attachment_firing_delay = 35


/obj/item/attachable/attached_gun/flamer/unremovable
	flags_attach_features = ATTACH_ACTIVATION|ATTACH_RELOADABLE|ATTACH_WEAPON


/obj/item/attachable/attached_gun/flamer/examine(mob/user)
	..()
	if(current_rounds > 0)
		to_chat(user, "It has [current_rounds] unit\s of fuel left.")
	else
		to_chat(user, "It's empty.")

/obj/item/attachable/attached_gun/flamer/reload_attachment(object, mob/user)
	if(istype(object, /obj/item/ammo_magazine/flamer_tank))
		var/obj/item/ammo_magazine/flamer_tank/I = object
		if(current_rounds >= max_rounds)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		else if(I.current_rounds <= 0)
			to_chat(user, "<span class='warning'>[I] is empty!</span>")
		else
			var/transfered_rounds = min(max_rounds - current_rounds, I.current_rounds)
			current_rounds += transfered_rounds
			I.current_rounds -= transfered_rounds
			playsound(user, 'sound/effects/refill.ogg', 25, 1, 3)
			to_chat(user, "<span class='notice'>You refill [src] with [I].</span>")
	else if(istype(object, /obj/item/tool/weldpack))
		var/obj/item/tool/weldpack/FT = object
		if(current_rounds >= max_rounds)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		else if(!FT.reagents.get_reagent_amount(/datum/reagent/fuel))
			to_chat(user, "<span class='warning'>The [FT] doesn't have any welding fuel!</span>")
		else
			var/transfered_rounds = min(max_rounds - current_rounds, FT.reagents.get_reagent_amount(/datum/reagent/fuel))
			current_rounds += transfered_rounds
			FT.reagents.remove_reagent(/datum/reagent/fuel, transfered_rounds)
			to_chat(user, "<span class='notice'>You refill [src] with [FT].</span>")
			playsound(user, 'sound/effects/refill.ogg', 25, 1, 3)
	else if(istype(object, /obj/item/storage/backpack/marine/engineerpack))
		var/obj/item/storage/backpack/marine/engineerpack/FT = object
		if(current_rounds >= max_rounds)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		else if(!FT.reagents.get_reagent_amount(/datum/reagent/fuel))
			to_chat(user, "<span class='warning'>The [FT] doesn't have any welding fuel!</span>")
		else
			var/transfered_rounds = min(max_rounds - current_rounds, FT.reagents.get_reagent_amount(/datum/reagent/fuel))
			current_rounds += transfered_rounds
			FT.reagents.remove_reagent(/datum/reagent/fuel, transfered_rounds)
			to_chat(user, "<span class='notice'>You refill [src] with [FT].</span>")
			playsound(user, 'sound/effects/refill.ogg', 25, 1, 3)
	else if(istype(object, /obj/item/reagent_container))
		var/obj/item/reagent_container/FT = object
		if(current_rounds >= max_rounds)
			to_chat(user, "<span class='warning'>[src] is full.</span>")
		else if(!FT.reagents.get_reagent_amount(/datum/reagent/fuel))
			to_chat(user, "<span class='warning'>The [FT] doesn't have any welding fuel!</span>")
		else
			var/transfered_rounds = min(max_rounds - current_rounds, FT.reagents.get_reagent_amount(/datum/reagent/fuel))
			current_rounds += transfered_rounds
			FT.reagents.remove_reagent(/datum/reagent/fuel, transfered_rounds)
			to_chat(user, "<span class='notice'>You refill [src] with [FT].</span>")
			playsound(user, 'sound/effects/refill.ogg', 25, 1, 3)
	else
		to_chat(user, "<span class='warning'>[src] can be refilled only with welding fuel.</span>")

/obj/item/attachable/attached_gun/flamer/fire_attachment(atom/target, obj/item/weapon/gun/gun, mob/living/user)
	if(get_dist(user,target) > max_range+3)
		to_chat(user, "<span class='warning'>Too far to fire the attachment!</span>")
		return
	if(current_rounds)
		unleash_flame(target, user)


/obj/item/attachable/attached_gun/flamer/proc/unleash_flame(atom/target, mob/living/user)
	set waitfor = 0
	var/list/turf/turfs = getline(user,target)
	var/distance = 0
	var/turf/prev_T
	playsound(user, 'sound/weapons/guns/fire/flamethrower2.ogg', 50, 1)
	for(var/turf/T in turfs)
		if(T == user.loc)
			prev_T = T
			continue
		if(!current_rounds)
			break
		if(distance >= max_range)
			break
		if(prev_T && LinkBlocked(prev_T, T))
			break
		current_rounds--
		flame_turf(T,user)
		distance++
		prev_T = T
		sleep(1)


/obj/item/attachable/attached_gun/flamer/proc/flame_turf(turf/T, mob/living/user)
	if(!istype(T))
		return

	T.ignite()

	var/fire_mod
	for(var/mob/living/carbon/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)
			continue

		fire_mod = 1

		if(isxeno(M))
			var/mob/living/carbon/xenomorph/X = M
			if(X.xeno_caste.caste_flags & CASTE_FIRE_IMMUNE)
				continue
			fire_mod = CLAMP(X.xeno_caste.fire_resist + X.fire_resist_modifier, 0, 1)
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(user)
				if(!user.mind?.bypass_ff && !H.mind?.bypass_ff && user.faction == H.faction)
					log_combat(user, H, "shot", src)
					log_ffattack("[key_name(usr)] shot [key_name(H)] with [name] in [AREACOORD(T)].")
					msg_admin_ff("[ADMIN_TPMONTY(usr)] shot [ADMIN_TPMONTY(H)] with [name] in [ADMIN_VERBOSEJMP(T)].")
				else
					log_combat(user, H, "shot", src)
					msg_admin_attack("[ADMIN_TPMONTY(usr)] shot [ADMIN_TPMONTY(H)] with [name] in [ADMIN_VERBOSEJMP(T)].")

			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || istype(H.wear_suit,/obj/item/clothing/suit/space/rig/atmos))
				continue

		M.adjust_fire_stacks(rand(3,5))
		M.adjustFireLoss(rand(20,40) * fire_mod) //fwoom!
		to_chat(M, "[isxeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!")

/obj/item/attachable/attached_gun/shotgun
	name = "masterkey shotgun"
	icon_state = "masterkey"
	attach_icon = "masterkey_a"
	desc = "A weapon-mounted, three-shot shotgun. Reloadable with buckshot. The short barrel reduces the ammo's effectiveness."
	w_class = WEIGHT_CLASS_BULKY
	max_rounds = 3
	current_rounds = 3
	ammo = /datum/ammo/bullet/shotgun/buckshot/masterkey
	slot = "under"
	fire_sound = 'sound/weapons/guns/fire/shotgun.ogg'
	type_of_casings = "shell"
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_PROJECTILE|ATTACH_RELOADABLE|ATTACH_WEAPON
	attachment_firing_delay = 18

/obj/item/attachable/attached_gun/shotgun/examine(mob/user)
	..()
	if(current_rounds > 0)
		to_chat(user, "It has [current_rounds] shell\s left.")
	else
		to_chat(user, "It's empty.")

/obj/item/attachable/attached_gun/shotgun/reload_attachment(obj/item/ammo_magazine/handful/mag, mob/user)
	if(istype(mag) && mag.flags_magazine & AMMUNITION_HANDFUL)
		if(mag.default_ammo == /datum/ammo/bullet/shotgun/buckshot)
			if(current_rounds >= max_rounds)
				to_chat(user, "<span class='warning'>[src] is full.</span>")
			else
				current_rounds++
				mag.current_rounds--
				mag.update_icon()
				to_chat(user, "<span class='notice'>You load one shotgun shell in [src].</span>")
				playsound(user, 'sound/weapons/guns/interact/shotgun_shell_insert.ogg', 25, 1)
				if(mag.current_rounds <= 0)
					user.temporarilyRemoveItemFromInventory(mag)
					qdel(mag)
			return
	to_chat(user, "<span class='warning'>[src] only accepts shotgun buckshot.</span>")



/obj/item/attachable/verticalgrip
	name = "vertical grip"
	desc = "A custom-built improved foregrip for better accuracy, less recoil, and less scatter when wielded especially during burst fire. \nHowever, it also increases weapon size, slightly increases wield delay and makes unwielded fire more cumbersome."
	icon_state = "verticalgrip"
	attach_icon = "verticalgrip_a"
	wield_delay_mod = 0.4 SECONDS
	size_mod = 1
	slot = "under"
	pixel_shift_x = 20
	accuracy_mod = 0.05
	recoil_mod = -2
	scatter_mod = -5
	burst_scatter_mod = -1
	movement_acc_penalty_mod = 0.1
	accuracy_unwielded_mod = -0.05
	scatter_unwielded_mod = 5


/obj/item/attachable/angledgrip
	name = "angled grip"
	desc = "A custom-built improved foregrip for less recoil, and faster wielding time. \nHowever, it also increases weapon size, and slightly hinders unwielded firing."
	icon_state = "angledgrip"
	attach_icon = "angledgrip_a"
	wield_delay_mod = -0.4 SECONDS
	size_mod = 1
	slot = "under"
	pixel_shift_x = 20
	recoil_mod = -2
	accuracy_mod = 0.05
	scatter_mod = -5
	accuracy_unwielded_mod = -0.05
	scatter_unwielded_mod = 5



/obj/item/attachable/gyro
	name = "gyroscopic stabilizer"
	desc = "A set of weights and balances to stabilize the weapon when burst firing or moving, especially while shooting one-handed. Greatly reduces movement penalties to accuracy. Significantly reduces burst scatter, recoil and general scatter."
	icon_state = "gyro"
	attach_icon = "gyro_a"
	slot = "under"
	burst_scatter_mod = -1
	scatter_mod = -10
	recoil_mod = -2
	movement_acc_penalty_mod = -0.5
	scatter_unwielded_mod = -20
	accuracy_unwielded_mod = 0.05
	recoil_unwielded_mod = -2

/obj/item/attachable/lasersight
	name = "laser sight"
	desc = "A laser sight placed under the barrel. Significantly increases one-handed accuracy and significantly reduces movement penalties to accuracy."
	icon_state = "lasersight"
	attach_icon = "lasersight_a"
	slot = "under"
	pixel_shift_x = 17
	pixel_shift_y = 17
	accuracy_mod = 0.15
	movement_acc_penalty_mod = -0.1
	accuracy_unwielded_mod = 0.20


/obj/item/attachable/bipod
	name = "bipod"
	desc = "A simple set of telescopic poles to keep a weapon stabilized during firing. \nGreatly increases accuracy and reduces recoil when properly placed, but also increases weapon size and slows firing speed."
	icon_state = "bipod"
	attach_icon = "bipod_a"
	slot = "under"
	wield_delay_mod = 0.6 SECONDS
	size_mod = 2
	melee_mod = -10
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	var/mob/living/master_user
	var/deployment_accuracy_mod = 0.30
	var/deployment_recoil_mod = -2
	var/deployment_scatter_mod = -20
	var/deployment_burst_scatter_mod = -3


/obj/item/attachable/bipod/activate_attachment(mob/living/user, turn_off)
	if(bipod_deployed)
		bipod_deployed = FALSE
		to_chat(user, "<span class='notice'>You retract [src].</span>")
		master_gun.aim_slowdown -= 1
		master_gun.wield_delay -= 0.4 SECONDS
		master_gun.accuracy_mult -= deployment_accuracy_mod
		master_gun.recoil -= deployment_recoil_mod
		master_gun.scatter -= deployment_scatter_mod
		master_gun.burst_scatter_mult -= deployment_burst_scatter_mod
		icon_state = "bipod"
		attach_icon = "bipod_a"
		UnregisterSignal(master_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED))
		UnregisterSignal(master_user, COMSIG_MOVABLE_MOVED)
		master_user = null
	else if(turn_off)
		return //Was already offB
	else
		if(user.action_busy)
			return
		if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_BAR))
			return
		if(bipod_deployed)
			return
		bipod_deployed = TRUE
		to_chat(user, "<span class='notice'>You deploy [src].</span>")
		master_user = user
		RegisterSignal(master_user, COMSIG_MOVABLE_MOVED, .proc/retract_bipod)
		RegisterSignal(master_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), .proc/retract_bipod)
		master_gun.aim_slowdown += 1
		master_gun.wield_delay += 0.4 SECONDS
		master_gun.accuracy_mult += deployment_accuracy_mod
		master_gun.recoil += deployment_recoil_mod
		master_gun.scatter += deployment_scatter_mod
		master_gun.burst_scatter_mult += deployment_burst_scatter_mod
		icon_state = "bipod-on"
		attach_icon = "bipod_a-on"

	master_gun.update_slowdown()
	master_gun.update_attachable(slot)

	for(var/i in master_gun.actions)
		var/datum/action/action_to_update = i
		action_to_update.update_button_icon()
	return TRUE


/obj/item/attachable/bipod/proc/retract_bipod(datum/source)
	if(!ismob(source))
		return
	activate_attachment(source, TRUE)
	to_chat(source, "<span class='warning'>Losing support, the bipod retracts!</span>")
	playsound(source, 'sound/machines/click.ogg', 15, 1, 4)


//when user fires the gun, we check if they have something to support the gun's bipod.
/obj/item/attachable/proc/check_bipod_support(obj/item/weapon/gun/G, mob/living/user)
	return FALSE

/obj/item/attachable/bipod/check_bipod_support(obj/item/weapon/gun/G, mob/living/user)
	var/turf/T = get_turf(user)
	for(var/obj/O in T)
		if(O.throwpass && O.density && O.dir == user.dir && O.flags_atom & ON_BORDER)
			return O

	T = get_step(T, user.dir)
	for(var/obj/O in T)
		if((istype(O, /obj/structure/window_frame)))
			return O

	return FALSE




/obj/item/attachable/burstfire_assembly
	name = "burst fire assembly"
	desc = "A mechanism re-assembly kit that allows for automatic fire, or more shots per burst if the weapon already has the ability. \nIncreases scatter and decreases accuracy."
	icon_state = "rapidfire"
	attach_icon = "rapidfire_a"
	slot = "under"
	accuracy_mod = -0.10
	burst_mod = 2
	scatter_mod = 15
	accuracy_unwielded_mod = -0.20
	scatter_unwielded_mod = 20


/obj/item/attachable/hydro_cannon
	name = "M240T Hydro Cannon"
	desc = "An integrated component of the M240T incinerator unit, the hydro cannon fires high pressure sprays of water; mainly to extinguish any wayward allies or unintended collateral damage."
	icon_state = "hydrocannon"
	attach_icon = ""
	slot = "under"
	flags_attach_features = ATTACH_ACTIVATION|ATTACH_UTILITY
	attachment_action_type = /datum/action/item_action/toggle
	var/max_water = 200
	var/last_use

/obj/item/attachable/hydro_cannon/activate_attachment(mob/living/user, turn_off)
	if(master_gun.active_attachable == src)
		if(user)
			to_chat(user, "<span class='notice'>You are no longer using [src].</span>")
		master_gun.active_attachable = null
		icon_state = initial(icon_state)
	else if(!turn_off)
		if(user)
			to_chat(user, "<span class='notice'>You are now using [src].</span>")
		master_gun.active_attachable = src
		icon_state += "-on"

	for(var/X in master_gun.actions)
		var/datum/action/A = X
		A.update_button_icon()
	return TRUE


/obj/item/weapon/gun/zoom(mob/living/user, tileoffset = 11, viewsize = 12) //this is so the accuracy modifiers for the scopes apply correctly
	. = ..()
	if(istype(rail,/obj/item/attachable/scope))
		var/obj/item/attachable/scope/S = rail
		if(zoom)
			S.accuracy_mod = S.zoom_accuracy
		else
			S.accuracy_mod = 0
