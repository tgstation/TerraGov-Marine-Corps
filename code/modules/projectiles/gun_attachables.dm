
/** Gun attachable items code. Lets you add various effects to firearms.

Some attachables are hardcoded in the projectile firing system, like grenade launchers, flamethrowers.

When you are adding new guns into the attachment list, or even old guns, make sure that said guns
properly accept overlays. You can find the proper offsets in the individual gun dms, so make sure
you set them right. It's a pain to go back to find which guns are set incorrectly.
To summarize: rail attachments should go on top of the rail. For rifles, this usually means the middle of the gun.
For handguns, this is usually toward the back of the gun. SMGs usually follow rifles.
Muzzle attachments should connect to the barrel, not sit under or above it. The only exception is the bayonet.
Underrail attachments should just fit snugly, that's about it. Stocks are pretty obvious.

All attachment offsets are now in a list, including stocks. Guns that don't take attachments can keep the list null.
~N

Anything that isn't used as the gun fires should be a flat number, never a percentange. It screws with the calculations,
and can mean that the order you attach something/detach something will matter in the final number. It's also completely
inaccurate. Don't worry if force is ever negative, it won't runtime.
 */

/obj/item/attachable
	name = "attachable item"
	desc = "It's an attachment. You should never see this."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = null
	item_state = null
	///Determines the amount of pixels to move the icon state for the overlay. in the x direction
	var/pixel_shift_x = 16
	///Determines the amount of pixels to move the icon state for the overlay. in the y direction
	var/pixel_shift_y = 16

	flags_atom = CONDUCT
	materials = list(/datum/material/metal = 100)
	w_class = WEIGHT_CLASS_SMALL
	force = 1.0
	///ATTACHMENT_SLOT_MUZZLE, ATTACHMENT_SLOT_RAIL, ATTACHMENT_SLOT_UNDER, ATTACHMENT_SLOT_STOCK the particular 'slot' the attachment can attach to. must always be a singular slot.
	var/slot = null

	///Modifier to firing accuracy, works off a multiplier.
	var/accuracy_mod 	= 0
	///Modifier to firing accuracy but for when scoped in, works off a multiplier.
	var/scoped_accuracy_mod = 0
	///Modifier to firing accuracy but for when onehanded.
	var/accuracy_unwielded_mod = 0
	///Modifer to the damage mult, works off a multiplier.
	var/damage_mod 		= 0
	///Modifier to damage falloff, works off a multiplier.
	var/damage_falloff_mod = 0
	///Flat number that adjusts the amount of mêlée force the weapon this is attached to has.
	var/melee_mod 		= 0
	///Increases or decreases scatter chance.
	var/scatter_mod 	= 0
	///Increases or decreases scatter chance but for onehanded firing.
	var/scatter_unwielded_mod = 0
	///If positive, adds recoil, if negative, lowers it. Recoil can't go below 0.
	var/recoil_mod 		= 0
	///If positive, adds recoil, if negative, lowers it. but for onehanded firing. Recoil can't go below 0.
	var/recoil_unwielded_mod = 0
	///Modifier to scatter from wielded burst fire, works off a multiplier.
	var/burst_scatter_mod = 0
	///Adds silenced to weapon. changing its fire sound, muzzle flash, and volume. TRUE or FALSE
	var/silence_mod 	= FALSE
	///Adds an x-brightness flashlight to the weapon, which can be toggled on and off.
	var/light_mod 		= 0
	///Changes firing delay. Cannot go below 0.
	var/delay_mod 		= 0
	///Changes burst firing delay. Cannot go below 0.
	var/burst_delay_mod = 0
	///Changes amount of shots in a burst
	var/burst_mod 		= 0
	///Increases the weight class.
	var/size_mod 		= 0
	///Changes the slowdown amount when wielding a weapon by this value.
	var/aim_speed_mod	= 0
	///How long ADS takes (time before firing)
	var/wield_delay_mod	= 0
	///Changes the speed of projectiles fired
	var/attach_shell_speed_mod = 0
	///Modifies accuracy/scatter penalty when firing onehanded while moving.
	var/movement_acc_penalty_mod = 0
	///How long in deciseconds it takes to attach a weapon with level 1 firearms training. Default is 30 seconds.
	var/attach_delay = 30
	///How long in deciseconds it takes to detach a weapon with level 1 firearms training. Default is 30 seconds.
	var/detach_delay = 30
	///Changes aim mode movement delay multiplicatively
	var/aim_mode_movement_mult = 0
	///Modifies projectile damage by a % when a marine gets passed, but not hit
	var/shot_marine_damage_falloff = 0
	///How much of the aim mode fire rate debuff is removed %-wise
	var/aim_mode_fire_rate_debuff_reduction = 0
	/*
	 * Contains the removed amount from the aim mode fire rate debuff
	 * so that the same amount that was removed is returned
	 * in the case of multiple things modifying the gun's var by a %
	 */
	var/cached_aim_mode_debuff_fire_rate = 0

	///the delay between shots, for attachments that fire stuff
	var/attachment_firing_delay = 0

	///The specific sound played when activating this attachment.
	var/activation_sound = 'sound/machines/click.ogg'

	///various yes no flags associated with attachments. See defines for these: [ATTACH_REMOVABLE]
	var/flags_attach_features = ATTACH_REMOVABLE

	///only used by bipod, denotes whether the bipod is currently deployed
	var/bipod_deployed = FALSE
	///only used by lace, denotes whether the lace is currently deployed
	var/lace_deployed = FALSE


	///what ability to give the user when attached to a weapon they are holding.
	var/attachment_action_type
	///used for the codex to denote if a weapon has the ability to zoom in or not.
	var/scope_zoom_mod = FALSE

	///what ammo the gun could also fire, different lasers usually.
	var/ammo_mod = null
	///how much charge difference it now costs to shoot. negative means more shots per mag.
	var/charge_mod = 0
	///what firemodes this attachment allows/adds.
	var/gun_firemode_list_mod = null

	///lazylist of attachment slot offsets for a gun.
	var/list/gun_attachment_offset_mod

	///what gun this attachment is currently attached to, if any.
	var/obj/item/weapon/gun/master_gun

	///Skill used to attach src to something.
	var/attach_skill = "firearms"
	///Skill threshold where the time to attach is halved.
	var/attach_skill_upper_threshold = SKILL_FIREARMS_TRAINED
	///Sound played on attach
	var/attach_sound = 'sound/machines/click.ogg'

/obj/item/attachable/Initialize()
	. = ..()
	AddElement(/datum/element/attachment, slot, icon, .proc/on_attach, .proc/on_detach, .proc/activate, .proc/can_attach, pixel_shift_x, pixel_shift_y, flags_attach_features, attach_delay, detach_delay, attach_skill, attach_skill_upper_threshold, attach_sound)

///Called when the attachment is attached to something. If it is a gun it will update the guns stats.
/obj/item/attachable/proc/on_attach(attaching_item, mob/user)

	if(!istype(attaching_item, /obj/item/weapon/gun))
		return //Guns only

	master_gun = attaching_item

	master_gun.accuracy_mult				+= accuracy_mod
	master_gun.accuracy_mult_unwielded		+= accuracy_unwielded_mod
	master_gun.damage_mult					+= damage_mod
	master_gun.damage_falloff_mult			+= damage_falloff_mod
	master_gun.w_class						+= size_mod
	master_gun.scatter						+= scatter_mod
	master_gun.scatter_unwielded			+= scatter_unwielded_mod
	master_gun.aim_speed_modifier			+= initial(master_gun.aim_speed_modifier)*aim_mode_movement_mult
	master_gun.iff_marine_damage_falloff	+= shot_marine_damage_falloff
	cached_aim_mode_debuff_fire_rate = master_gun.aim_fire_delay * aim_mode_fire_rate_debuff_reduction
	master_gun.aim_fire_delay 				-= cached_aim_mode_debuff_fire_rate
	if(delay_mod)
		master_gun.modify_fire_delay(delay_mod)
	if(burst_delay_mod)
		master_gun.modify_burst_delay(burst_delay_mod)
	if(burst_mod)
		master_gun.modify_burst_amount(burst_mod, user)
	master_gun.recoil						+= recoil_mod
	master_gun.recoil_unwielded				+= recoil_unwielded_mod
	master_gun.force						+= melee_mod
	master_gun.sharp						+= sharp
	master_gun.aim_slowdown					+= aim_speed_mod
	master_gun.wield_delay					+= wield_delay_mod
	master_gun.burst_scatter_mult			+= burst_scatter_mod
	master_gun.movement_acc_penalty_mult	+= movement_acc_penalty_mod
	master_gun.shell_speed_mod				+= attach_shell_speed_mod
	master_gun.scope_zoom					+= scope_zoom_mod
	if(ammo_mod)
		master_gun.add_ammo_mod(ammo_mod)
	if(charge_mod)
		master_gun.charge_cost				+= charge_mod
	for(var/i in gun_firemode_list_mod)
		master_gun.add_firemode(i, user)

	master_gun.update_force_list() //This updates the gun to use proper force verbs.

	if(silence_mod)
		ADD_TRAIT(master_gun, TRAIT_GUN_SILENCED, GUN_TRAIT)
		master_gun.muzzle_flash = null
		master_gun.fire_sound = "gun_silenced"

	if(attachment_action_type)
		var/datum/action/action_to_update = new attachment_action_type(src, master_gun)
		if(isliving(master_gun.loc))
			var/mob/living/living_user = master_gun.loc
			if(master_gun == living_user.l_hand || master_gun == living_user.r_hand)
				action_to_update.give_action(living_user)

	update_icon()

///Called when the attachment is detached from something. If the thing is a gun, it returns its stats to what they were before being attached.
/obj/item/attachable/proc/on_detach(attaching_item, mob/user)
	if(!isgun(attaching_item))
		return

	master_gun.accuracy_mult				-= accuracy_mod
	master_gun.accuracy_mult_unwielded		-= accuracy_unwielded_mod
	master_gun.damage_mult					-= damage_mod
	master_gun.damage_falloff_mult			-= damage_falloff_mod
	master_gun.w_class						-= size_mod
	master_gun.scatter						-= scatter_mod
	master_gun.scatter_unwielded			-= scatter_unwielded_mod
	master_gun.aim_speed_modifier			-= initial(master_gun.aim_speed_modifier)*aim_mode_movement_mult
	master_gun.iff_marine_damage_falloff	-= shot_marine_damage_falloff
	master_gun.aim_fire_delay 				+= cached_aim_mode_debuff_fire_rate
	if(HAS_TRAIT(master_gun, TRAIT_GUN_IS_AIMING))
		master_gun.modify_fire_delay(cached_aim_mode_debuff_fire_rate)
	cached_aim_mode_debuff_fire_rate = 0
	if(delay_mod)
		master_gun.modify_fire_delay(-delay_mod)
	if(burst_delay_mod)
		master_gun.modify_burst_delay(-burst_delay_mod)
	if(burst_mod)
		master_gun.modify_burst_amount(-burst_mod, user)
	master_gun.recoil						-= recoil_mod
	master_gun.recoil_unwielded				-= recoil_unwielded_mod
	master_gun.force						-= melee_mod
	master_gun.sharp						-= sharp
	master_gun.aim_slowdown					-= aim_speed_mod
	master_gun.wield_delay					-= wield_delay_mod
	master_gun.burst_scatter_mult			-= burst_scatter_mod
	master_gun.movement_acc_penalty_mult	-= movement_acc_penalty_mod
	master_gun.shell_speed_mod				-= attach_shell_speed_mod
	master_gun.scope_zoom					-= scope_zoom_mod
	if(ammo_mod)
		master_gun.remove_ammo_mod(ammo_mod)
	if(master_gun.charge_cost)
		master_gun.charge_cost -= charge_mod
	for(var/i in gun_firemode_list_mod)
		master_gun.remove_firemode(i, user)

	master_gun.update_force_list()

	if(silence_mod) //Built in silencers always come as an attach, so the gun can't be silenced right off the bat.
		REMOVE_TRAIT(master_gun, TRAIT_GUN_SILENCED, GUN_TRAIT)
		master_gun.muzzle_flash = initial(master_gun.muzzle_flash)
		master_gun.fire_sound = initial(master_gun.fire_sound)

	for(var/datum/action/action_to_update AS in master_gun.actions)
		if(action_to_update.target != src)
			continue
		qdel(action_to_update)
		break

	master_gun = null
	update_icon()


/obj/item/attachable/ui_action_click(mob/living/user, datum/action/item_action/action, obj/item/weapon/gun/G)
	if(G == user.get_active_held_item() || G == user.get_inactive_held_item() || CHECK_BITFIELD(G.flags_item, IS_DEPLOYED))
		if(activate(user)) //success
			playsound(user, activation_sound, 15, 1)
	else
		to_chat(user, span_warning("[G] must be in our hands to do this."))

/obj/item/attachable/hydro_cannon/ui_action_click(mob/living/user, datum/action/item_action/action, obj/item/weapon/gun/G)
	if(G == user.get_active_held_item() || G == user.get_inactive_held_item() || CHECK_BITFIELD(G.flags_item, IS_DEPLOYED))
		G.unique_action(user)
		return
	if(activate(user)) //success
		playsound(user, activation_sound, 15, 1)

///Called when the attachment is activated.
/obj/item/attachable/proc/activate(mob/user) //This is for activating stuff like flamethrowers, or switching weapon modes, or flashlights.
	return TRUE

///Called when the attachment is trying to be attached. If the attachment is allowed to go through, return TRUE.
/obj/item/attachable/proc/can_attach(obj/item/attaching_to, mob/attacher)
	return TRUE


/////////// Muzzle Attachments /////////////////////////////////

/obj/item/attachable/suppressor
	name = "suppressor"
	desc = "A small tube with exhaust ports to expel noise and gas.\nDoes not completely silence a weapon, but does make it much quieter and a little more accurate and stable at the cost of bullet speed."
	icon_state = "suppressor"
	slot = ATTACHMENT_SLOT_MUZZLE
	silence_mod = TRUE
	pixel_shift_y = 16
	attach_shell_speed_mod = -1
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -5
	recoil_unwielded_mod = -3
	scatter_unwielded_mod = -5
	damage_falloff_mod = 0.1

/obj/item/attachable/suppressor/unremovable
	flags_attach_features = NONE


/obj/item/attachable/suppressor/unremovable/invisible
	icon_state = ""


/obj/item/attachable/suppressor/unremovable/invisible/Initialize(mapload, ...)
	. = ..()


/obj/item/attachable/bayonet
	name = "bayonet"
	desc = "A sharp blade for mounting on a weapon. It can be used to stab manually on anything but harm intent. Slightly reduces the accuracy of the gun when mounted."
	icon_state = "bayonet"
	force = 20
	throwforce = 10
	attach_delay = 10 //Bayonets attach/detach quickly.
	detach_delay = 10
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	melee_mod = 25
	slot = ATTACHMENT_SLOT_MUZZLE
	pixel_shift_x = 14 //Below the muzzle.
	pixel_shift_y = 18
	accuracy_mod = -0.05
	accuracy_unwielded_mod = -0.1
	size_mod = 1
	sharp = IS_SHARP_ITEM_ACCURATE

/obj/item/attachable/bayonet/screwdriver_act(mob/living/user, obj/item/I)
	to_chat(user, span_notice("You modify the bayonet back into a combat knife."))
	if(loc == user)
		user.dropItemToGround(src)
	var/obj/item/weapon/combat_knife/knife = new(loc)
	user.put_in_hands(knife) //This proc tries right, left, then drops it all-in-one.
	if(knife.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
		knife.forceMove(loc)
	qdel(src) //Delete da old bayonet

/obj/item/attachable/bayonetknife
	name = "M-22 bayonet"
	desc = "A sharp knife that is the standard issue combat knife of the TerraGov Marine Corps can be attached to a variety of weapons at will or used as a standard knife."
	icon_state = "bayonetknife"
	item_state = "combat_knife"
	force = 25
	throwforce = 20
	throw_speed = 3
	throw_range = 6
	attack_speed = 7
	attach_delay = 10 //Bayonets attach/detach quickly.
	detach_delay = 10
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	melee_mod = 25
	slot = ATTACHMENT_SLOT_MUZZLE
	pixel_shift_x = 14 //Below the muzzle.
	pixel_shift_y = 18
	accuracy_mod = -0.05
	accuracy_unwielded_mod = -0.1
	size_mod = 1
	sharp = IS_SHARP_ITEM_ACCURATE

/obj/item/attachable/bayonetknife/Initialize()
	. = ..()
	AddElement(/datum/element/scalping)

/obj/item/attachable/extended_barrel
	name = "extended barrel"
	desc = "A lengthened barrel allows for lessened scatter, greater accuracy and muzzle velocity due to increased stabilization and shockwave exposure."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "ebarrel"
	attach_shell_speed_mod = 1
	accuracy_mod = 0.15
	accuracy_unwielded_mod = 0.1
	scatter_mod = -5
	size_mod = 1


/obj/item/attachable/heavy_barrel
	name = "barrel charger"
	desc = "A fitted barrel extender that goes on the muzzle, with a small shaped charge that propels a bullet much faster.\nGreatly increases projectile speed."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "hbarrel"
	attach_shell_speed_mod = 2
	accuracy_mod = -0.1


/obj/item/attachable/compensator
	name = "recoil compensator"
	desc = "A muzzle attachment that reduces recoil and scatter by diverting expelled gasses upwards. \nSignificantly reduces recoil and scatter, regardless of if the weapon is wielded."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "comp"
	pixel_shift_x = 17
	scatter_mod = -15
	recoil_mod = -2
	scatter_unwielded_mod = -15
	recoil_unwielded_mod = -2

/obj/item/attachable/sniperbarrel
	name = "sniper barrel"
	icon_state = "sniperbarrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	flags_attach_features = NONE
	accuracy_mod = 0.15
	scatter_mod = -15

/obj/item/attachable/autosniperbarrel
	name = "auto sniper barrel"
	icon_state = "t81barrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_UNDER
	flags_attach_features = NONE
	pixel_shift_x = 7
	pixel_shift_y = 14
	accuracy_mod = 0
	scatter_mod = -5

/obj/item/attachable/smartbarrel
	name = "smartgun barrel"
	icon_state = "smartbarrel"
	desc = "A heavy rotating barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	flags_attach_features = NONE

/obj/item/attachable/focuslens
	name = "M43 focused lens"
	desc = "Directs the beam into one specialized lens, allowing the lasgun to use the deadly focused bolts on overcharge, making it more like a high damage sniper."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "focus"
	pixel_shift_x = 17
	pixel_shift_y = 13
	ammo_mod = /datum/ammo/energy/lasgun/M43/overcharge
	damage_mod = -0.15

/obj/item/attachable/widelens
	name = "M43 wide lens"
	desc = "Splits the lens into three, allowing the lasgun to use a deadly close-range blast on overcharge akin to a traditional pellet based shotgun shot."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "wide"
	pixel_shift_x = 18
	pixel_shift_y = 15
	ammo_mod = /datum/ammo/energy/lasgun/M43/blast
	damage_mod = -0.15

/obj/item/attachable/heatlens
	name = "M43 heat lens"
	desc = "Changes the intensity and frequency of the laser. This makes your target be set on fire at a cost of upfront damage and penetration."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "heat"
	pixel_shift_x = 18
	pixel_shift_y = 16
	ammo_mod = /datum/ammo/energy/lasgun/M43/heat
	damage_mod = -0.15

/obj/item/attachable/efflens
	name = "M43 efficient lens"
	desc = "Makes the lens smaller and lighter to use, allowing the lasgun to use its energy much more efficiently. \nDecreases energy output of the lasgun."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "efficient"
	pixel_shift_x = 18
	pixel_shift_y = 14
	charge_mod = -5

/obj/item/attachable/sx16barrel
	name = "SX-16 barrel"
	desc = "The standard barrel on the SX-16. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "sx16barrel"
	flags_attach_features = NONE

/obj/item/attachable/pulselens
	name = "M43 pulse lens"
	desc = "Agitates the lens, allowing the lasgun to discharge at a rapid rate. \nAllows the weapon to be fired automatically."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "pulse"
	pixel_shift_x = 18
	pixel_shift_y = 15
	damage_mod = -0.15
	gun_firemode_list_mod = list(GUN_FIREMODE_AUTOMATIC)

/obj/item/attachable/t42barrel
	name = "T-42 barrel"
	desc = "The standard barrel on the T-42. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "t42barrel"
	flags_attach_features = NONE

/obj/item/attachable/t18barrel
	name = "T-18 barrel"
	desc = "The standard barrel on the T-18. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "t18barrel"
	flags_attach_features = NONE

/obj/item/attachable/t12barrel
	name = "T-12 barrel"
	desc = "The standard barrel on the T-12. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "t12barrel"
	flags_attach_features = NONE

/obj/item/attachable/t29barrel
	name = "T-29 barrel"
	icon_state = "t29barrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	flags_attach_features = NONE

///////////// Rail attachments ////////////////////////

/obj/item/attachable/reddot
	name = "red-dot sight"
	desc = "A red-dot sight for short to medium range. Does not have a zoom feature, but does increase weapon accuracy and fire rate while aiming by a good amount. \nNo drawbacks."
	icon_state = "reddot"
	slot = ATTACHMENT_SLOT_RAIL
	accuracy_mod = 0.15
	accuracy_unwielded_mod = 0.1
	aim_mode_fire_rate_debuff_reduction = 0.5

/obj/item/attachable/m16sight
	name = "M16 iron sights"
	desc = "The iconic carry-handle iron sights for the m16. Usually removed once the user finds something worthwhile to attach to the rail."
	icon_state = "m16sight"
	slot = ATTACHMENT_SLOT_RAIL
	accuracy_mod = 0.1
	accuracy_unwielded_mod = 0.05
	movement_acc_penalty_mod = -0.1


/obj/item/attachable/flashlight
	name = "rail flashlight"
	desc = "A simple flashlight used for mounting on a firearm. \nHas no drawbacks, but isn't particuraly useful outside of providing a light source."
	icon_state = "flashlight"
	light_mod = 6
	light_system = MOVABLE_LIGHT
	slot = ATTACHMENT_SLOT_RAIL
	materials = list(/datum/material/metal = 100, /datum/material/glass = 20)
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	activation_sound = 'sound/items/flashlight.ogg'

/obj/item/attachable/flashlight/activate(mob/living/user)
	turn_light(user, !light_on)

/obj/item/attachable/flashlight/turn_light(mob/user, toggle_on)
	. = ..()

	if(. != CHECKS_PASSED)
		return

	if(ismob(master_gun.loc) && !user)
		user = master_gun.loc
	if(!toggle_on && light_on)
		icon_state = "flashlight"
		master_gun.set_light_range(0)
		master_gun.set_light_power(0)
		master_gun.set_light_on(FALSE)
		light_on = FALSE
		REMOVE_TRAIT(master_gun, TRAIT_GUN_FLASHLIGHT_ON, GUN_TRAIT)
	else if(toggle_on & !light_on)
		icon_state = "flashlight-on"
		master_gun.set_light_range(light_mod)
		master_gun.set_light_power(3)
		master_gun.set_light_on(TRUE)
		light_on = TRUE
		ADD_TRAIT(master_gun, TRAIT_GUN_FLASHLIGHT_ON, GUN_TRAIT)
	else
		return

	for(var/X in master_gun.actions)
		var/datum/action/A = X
		A.update_button_icon()

	update_icon()

/obj/item/attachable/flashlight/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I,/obj/item/tool/screwdriver))
		to_chat(user, span_notice("You modify the rail flashlight back into a normal flashlight."))
		if(loc == user)
			user.temporarilyRemoveItemFromInventory(src)
		var/obj/item/flashlight/F = new(user)
		user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
		qdel(src) //Delete da old flashlight



/obj/item/attachable/quickfire
	name = "quickfire adapter"
	desc = "An enhanced and upgraded autoloading mechanism to fire rounds more quickly. \nHowever, it also reduces accuracy and the number of bullets fired on burst."
	slot = ATTACHMENT_SLOT_RAIL
	icon_state = "autoloader"
	accuracy_mod = -0.15
	scatter_mod = 5
	delay_mod = -0.125 SECONDS
	burst_mod = -1
	accuracy_unwielded_mod = -0.22
	scatter_unwielded_mod = 15


/obj/item/attachable/magnetic_harness
	name = "magnetic harness"
	desc = "A magnetically attached harness kit that attaches to the rail mount of a weapon. When dropped, the weapon will sling to a TGMC armor."
	icon_state = "magnetic"
	slot = ATTACHMENT_SLOT_RAIL
	pixel_shift_x = 13


/obj/item/attachable/scope
	name = "rail scope"
	icon_state = "sniperscope"
	desc = "A rail mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	slot = ATTACHMENT_SLOT_RAIL
	aim_speed_mod = 0.5 //Extra slowdown when aiming
	wield_delay_mod = 0.4 SECONDS
	accuracy_mod = 0.1
	scoped_accuracy_mod = SCOPE_RAIL
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	scope_zoom_mod = TRUE // codex
	accuracy_unwielded_mod = -0.05
	zoom_tile_offset = 11
	zoom_viewsize = 10
	zoom_allow_movement = TRUE
	///how much slowdown the scope gives when zoomed. You want this to be slowdown you want minus aim_speed_mod
	var/zoom_slowdown = 1
	///boolean as to whether a scope can apply nightvision
	var/has_nightvision = FALSE
	///boolean as to whether the attachment is currently giving nightvision
	var/active_nightvision = FALSE


/obj/item/attachable/scope/marine
	name = "T-47 rail scope"
	desc = "A marine standard mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	icon_state = "marinescope"

/obj/item/attachable/scope/nightvision
	name = "T-46 Night vision scope"
	icon_state = "nvscope"
	desc = "A rail-mounted night vision scope developed by Roh-Easy industries for the TGMC. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	has_nightvision = TRUE

/obj/item/attachable/scope/mosin
	name = "Mosin nagant rail scope"
	icon_state = "mosinscope"
	desc = "A Mosin specific mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."

/obj/item/attachable/scope/unremovable
	flags_attach_features = ATTACH_ACTIVATION


/obj/item/attachable/scope/unremovable/flaregun
	name = "long range ironsights"
	desc = "An unremovable set of long range ironsights for a flaregun."
	aim_speed_mod = 0
	wield_delay_mod = 0
	zoom_tile_offset = 5
	zoom_viewsize = 0
	scoped_accuracy_mod = SCOPE_RAIL_MINI
	zoom_slowdown = 0.50

/obj/item/attachable/scope/unremovable/tl127
	name = "T-45 rail scope"
	icon_state = "sniperscope_invisible"
	aim_speed_mod = 0
	wield_delay_mod = 0
	desc = "A rail mounted zoom sight scope specialized for the T-127 sniper rifle. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	flags_attach_features = ATTACH_ACTIVATION

/obj/item/attachable/scope/unremovable/heavymachinegun
	name = "MG-08/495 long range ironsights"
	desc = "An unremovable set of long range ironsights for an MG-08/495 machinegun."
	icon_state = "sniperscope_invisible"
	flags_attach_features = ATTACH_ACTIVATION
	zoom_viewsize = 0
	zoom_tile_offset = 3


/obj/item/attachable/scope/unremovable/tl102
	name = "TL-102 smart sight"
	desc = "An unremovable smart sight built for use with the tl102, it does nearly all the aiming work for the gun's integrated IFF systems."
	icon_state = "sniperscope_invisible"
	zoom_viewsize = 0
	zoom_tile_offset = 3

/obj/item/attachable/scope/unremovable/tl102/nest
	zoom_tile_offset = 6

/obj/item/attachable/scope/activate(mob/living/carbon/user, turn_off)
	if(turn_off)
		zoom(user)
		return TRUE

	if(!(master_gun.flags_item & WIELDED) && !CHECK_BITFIELD(master_gun.flags_item, IS_DEPLOYED))
		if(user)
			to_chat(user, span_warning("You must hold [master_gun] with two hands to use [src]."))
		return FALSE
	if(CHECK_BITFIELD(master_gun.flags_item, IS_DEPLOYED) && user.dir != master_gun.loc.dir)
		user.setDir(master_gun.loc.dir)
	zoom(user)
	update_icon()
	return TRUE

/obj/item/attachable/scope/zoom_item_turnoff(datum/source, mob/living/carbon/user)
	if(ismob(source))
		activate(source, TRUE)
	else
		activate(user, TRUE)

/obj/item/attachable/scope/onzoom(mob/living/user)
	if(zoom_allow_movement)
		user.add_movespeed_modifier(MOVESPEED_ID_SCOPE_SLOWDOWN, TRUE, 0, NONE, TRUE, zoom_slowdown)
		RegisterSignal(user, COMSIG_CARBON_SWAPPED_HANDS, .proc/zoom_item_turnoff)
	else
		RegisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_SWAPPED_HANDS), .proc/zoom_item_turnoff)
	if(!(master_gun.flags_gun_features & IS_DEPLOYED))
		RegisterSignal(user, COMSIG_MOB_FACE_DIR, .proc/change_zoom_offset)
	RegisterSignal(master_gun, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD, COMSIG_ITEM_DROPPED), .proc/zoom_item_turnoff)
	master_gun.accuracy_mult += scoped_accuracy_mod
	if(has_nightvision)
		update_remote_sight(user)
		user.reset_perspective(src)
		active_nightvision = TRUE

/obj/item/attachable/scope/onunzoom(mob/living/user)
	if(zoom_allow_movement)
		user.remove_movespeed_modifier(MOVESPEED_ID_SCOPE_SLOWDOWN)
		UnregisterSignal(user, list(COMSIG_CARBON_SWAPPED_HANDS, COMSIG_MOB_FACE_DIR))
	else
		UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_SWAPPED_HANDS, COMSIG_MOB_FACE_DIR))
	UnregisterSignal(master_gun, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD, COMSIG_ITEM_DROPPED))
	master_gun.accuracy_mult -= scoped_accuracy_mod
	if(has_nightvision)
		user.update_sight()
		user.reset_perspective(user)
		active_nightvision = FALSE

/obj/item/attachable/scope/update_remote_sight(mob/living/user)
	. = ..()
	user.see_in_dark = 32
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/obj/item/attachable/scope/unremovable/laser_sniper_scope
	name = "Terra Experimental laser sniper rifle rail scope"
	desc = "A marine standard mounted zoom sight scope made for the Terra Experimental laser sniper rifle otherwise known as TE-S abbreviated, allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	icon_state = "tes"

/obj/item/attachable/scope/mini
	name = "mini rail scope"
	icon_state = "miniscope"
	desc = "A small rail mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	slot = ATTACHMENT_SLOT_RAIL
	wield_delay_mod = 0.2 SECONDS
	accuracy_mod = 0.05
	accuracy_unwielded_mod = -0.05
	aim_speed_mod = 0.2
	scoped_accuracy_mod = SCOPE_RAIL_MINI
	scope_zoom_mod = TRUE
	has_nightvision = FALSE
	zoom_allow_movement = TRUE
	zoom_slowdown = 0.3
	zoom_tile_offset = 5
	zoom_viewsize = 0

/obj/item/attachable/scope/mini/tx11
	name = "TX-11 mini rail scope"
	icon_state = "tx11scope"

/obj/item/attachable/scope/antimaterial
	name = "antimaterial rail scope"
	desc = "A rail mounted zoom sight scope specialized for the antimaterial Sniper Rifle . Allows zoom by activating the attachment. Can activate its targeting laser while zoomed to take aim for increased damage and penetration. Use F12 if your HUD doesn't come back."
	icon_state = "antimat"
	scoped_accuracy_mod = SCOPE_RAIL_SNIPER
	has_nightvision = TRUE
	flags_attach_features = ATTACH_ACTIVATION|ATTACH_REMOVABLE
	pixel_shift_x = 0
	pixel_shift_y = 17


/obj/item/attachable/scope/slavic
	icon_state = "slavicscope"

/obj/item/attachable/scope/pmc
	icon_state = "pmcscope"
	flags_attach_features = ATTACH_ACTIVATION

/obj/item/attachable/scope/mini/dmr
	name = "T-37 mini rail scope"
	icon_state = "t37"


//////////// Stock attachments ////////////////////////////


/obj/item/attachable/stock //Generic stock parent and related things.
	name = "default stock"
	desc = "Default parent object, not meant for use."
	icon_state = "stock"
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.2 SECONDS
	melee_mod = 5
	size_mod = 2
	pixel_shift_x = 30
	pixel_shift_y = 14

/obj/item/attachable/stock/irremoveable
	wield_delay_mod = 0 SECONDS
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/shotgun
	name = "\improper shotgun stock"
	desc = "A non-standard heavy wooden stock for the old V10 shotgun. Less quick and more cumbersome than the standard issue stakeout, but reduces recoil and improves accuracy. Allegedly makes a pretty good club in a fight too."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.3 SECONDS
	icon_state = "stock"
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -15

/obj/item/attachable/stock/tactical
	name = "\improper MK221 tactical stock"
	desc = "A sturdy polymer stock for the MK221 shotgun. Supplied in limited numbers and moderately encumbering, it provides an ergonomic surface to ease perceived recoil and usability."
	icon_state = "tactical_stock"
	wield_delay_mod = 0.2 SECONDS
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -15

/obj/item/attachable/stock/scout
	name = "\improper ZX-76 tactical stock"
	desc = "A standard polymer stock for the ZX-76 assault shotgun. Designed for maximum ease of use in close quarters."
	icon_state = "zx_stock"
	wield_delay_mod = 0
	flags_attach_features = NONE
	accuracy_mod = 0.05
	recoil_mod = -2
	scatter_mod = -5

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

/obj/item/attachable/stock/irremoveable/ppsh
	name = "PPSh-17b submachinegun wooden stock"
	desc = "A long wooden stock for a PPSh-17b submachinegun"
	icon_state = "ppshstock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/irremoveable/t27
	name = "T-27 Body"
	desc = "A stock for a T-27 MMG."
	icon = 'icons/Marine/marine-mmg.dmi'
	icon_state = "t27body"
	pixel_shift_x = 15
	pixel_shift_y = 0

/obj/item/attachable/stock/irremoveable/pal12
	name = "Paladin-12 pump shotgun stock"
	desc = "A standard light stock for the Paladin-12 shotgun."
	icon_state = "pal12stock"

/obj/item/attachable/stock/m16
	name = "M16 composite stock"
	desc = "A composite stock securely fit to the M16 platform. Disassembly required to remove, not recommended."
	icon_state = "m16stock"
	wield_delay_mod = 0.5 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE

/obj/item/attachable/stock/ak47
	name = "AK-47 wooden stock"
	desc = "A metallic stock with a wooden paint coating, made to fit the AK-47 replica."
	icon_state = "ak47stock"
	wield_delay_mod = 0.4 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE


/obj/item/attachable/stock/rifle
	name = "\improper M412 solid stock"
	desc = "A common stock used by the M412 pulse rifle series, used for long rifles. This stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.2 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "riflestock"
	pixel_shift_x = 41
	pixel_shift_y = 10
	accuracy_mod = 0.05
	recoil_mod = -3
	scatter_mod = -10
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/stock/irremoveable/rifle
	name = "\improper M412 solid stock"
	icon_state = "riflestock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/sx16
	name = "\improper SX-16 stock"
	desc = "The standard stock for the SX-16. Can be removed to make the gun smaller and easier to wield."
	icon_state = "sx16stock"
	wield_delay_mod = 0.4 SECONDS
	size_mod = 1
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -20
	movement_acc_penalty_mod = 0.1

/obj/item/attachable/stock/tx15
	name = "\improper TX-15 stock"
	desc = "The standard stock for the TX-15. Cannot be removed."
	icon_state = "tx15stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t29stock
	name = "T-29 stock"
	desc = "A standard machinegun stock."
	icon_state = "t29stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/revolver
	name = "\improper M44 magnum sharpshooter stock"
	desc = "A wooden stock modified for use on a 44-magnum. Increases accuracy and reduces recoil at the expense of handling and agility."
	slot = ATTACHMENT_SLOT_STOCK
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
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = null
	icon_state = "laserstock"
	pixel_shift_x = 41
	pixel_shift_y = 10
	flags_attach_features = NONE

/obj/item/attachable/stock/lasgun/practice
	name = "\improper M43-P Sunfury lasgun stock"
	desc = "The standard stock for the M43-P Sunfury lasgun, seems the stock is made out of plastic."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = null
	melee_mod = 0
	icon_state = "laserstock"
	pixel_shift_x = 41
	pixel_shift_y = 10
	flags_attach_features = NONE

/obj/item/attachable/stock/br
	name = "\improper T-64 stock"
	desc = "A specialized stock for the T-64."
	icon_state = "brstock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t18stock
	name = "\improper T-18 stock"
	desc = "A specialized stock for the T-18."
	icon_state = "t18stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/tl127stock
	name = "\improper TL-127 stock"
	desc = "A irremovable TL-127 sniper rifle stock."
	icon_state = "tl127stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t12stock
	name = "\improper T-12 stock"
	desc = "A specialized stock for the T-12."
	icon_state = "t12stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t42stock
	name = "\improper T-42 stock"
	desc = "A specialized stock for the T-42."
	icon_state = "t42stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t19stock
	name = "\improper T-19 machinepistol stock"
	desc = "A submachinegun stock distributed in small numbers to TGMC forces. Compatible with the T-19, this stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.1 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "t19stock"
	pixel_shift_x = 39
	pixel_shift_y = 11
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -10
	scatter_unwielded_mod = -10

/obj/item/attachable/stock/t35stock
	name = "\improper T-35 stock"
	desc = "A non-standard heavy stock for the T-35 shotgun. Less quick and more cumbersome than the standard issue stakeout, but reduces recoil and improves accuracy. Allegedly makes a pretty good club in a fight too."
	slot = ATTACHMENT_SLOT_STOCK
	wield_delay_mod = 0.4 SECONDS
	icon_state = "t35stock"
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -20

/obj/item/attachable/stock/t39stock
	name = "\improper T-39 stock"
	desc = "A specialized stock for the T-35."
	icon_state = "t39stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t60stock
	name = "T-60 stock"
	desc = "A irremovable T-60 general purpose machinegun stock."
	icon_state = "t60stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t70stock
	name = "\improper T-70 stock"
	desc = "A irremovable T-70 grenade launcher stock."
	icon_state = "t70stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/t84stock
	name = "\improper TL-84 stock"
	desc = "A irremovable TL-84 flamer stock."
	icon_state = "tl84stock"
	wield_delay_mod = 0 SECONDS
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = NONE
	accuracy_mod = 0
	recoil_mod = 0
	melee_mod = 0
	scatter_mod = 0
	movement_acc_penalty_mod = 0

/obj/item/attachable/stock/irremoveable/m41a
	name = "HK-11 stock"
	icon_state = "m41a"

/obj/item/attachable/stock/irremoveable/tx11
	name = "TX-11 stock"
	icon_state = "tx11stock"



//Underbarrel

/obj/item/attachable/verticalgrip
	name = "vertical grip"
	desc = "A custom-built improved foregrip for better accuracy, moderately faster aimed movement speed, less recoil, and less scatter when wielded especially during burst fire. \nHowever, it also increases weapon size, slightly increases wield delay and makes unwielded fire more cumbersome."
	icon_state = "verticalgrip"
	wield_delay_mod = 0.2 SECONDS
	size_mod = 1
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 20
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -10
	burst_scatter_mod = -1
	accuracy_unwielded_mod = -0.05
	scatter_unwielded_mod = 5
	aim_mode_movement_mult = -0.2


/obj/item/attachable/angledgrip
	name = "angled grip"
	desc = "A custom-built improved foregrip for less recoil, and faster wielding time. \nHowever, it also increases weapon size, and slightly hinders unwielded firing."
	icon_state = "angledgrip"
	wield_delay_mod = -0.3 SECONDS
	size_mod = 1
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 20
	recoil_mod = -1
	scatter_mod = 5
	accuracy_unwielded_mod = -0.1
	scatter_unwielded_mod = 5



/obj/item/attachable/gyro
	name = "gyroscopic stabilizer"
	desc = "A set of weights and balances to stabilize the weapon when burst firing or moving, especially while shooting one-handed. Greatly reduces movement penalties to accuracy. Significantly reduces burst scatter, recoil and general scatter. By increasing accuracy while moving, it let you move faster when taking aim."
	icon_state = "gyro"
	slot = ATTACHMENT_SLOT_UNDER
	scatter_mod = -5
	recoil_mod = -2
	movement_acc_penalty_mod = -0.5
	scatter_unwielded_mod = -10
	recoil_unwielded_mod = -1
	aim_mode_movement_mult = -0.5
	shot_marine_damage_falloff = -0.1

/obj/item/attachable/lasersight
	name = "laser sight"
	desc = "A laser sight placed under the barrel. Significantly increases one-handed accuracy and significantly reduces unwielded penalties to accuracy."
	icon_state = "lasersight"
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 17
	pixel_shift_y = 17
	accuracy_mod = 0.1
	accuracy_unwielded_mod = 0.15


/obj/item/attachable/bipod
	name = "bipod"
	desc = "A simple set of telescopic poles to keep a weapon stabilized during firing. \nGreatly increases accuracy and reduces recoil and scatter when properly placed, but also increases weapon size."
	icon_state = "bipod"
	slot = ATTACHMENT_SLOT_UNDER
	size_mod = 2
	melee_mod = -10
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	///person holding the gun that this is attached to
	var/mob/living/master_user
	///bonus to accuracy when the bipod is deployed
	var/deployment_accuracy_mod = 0.30
	///bonus to recoil when the bipod is deployed
	var/deployment_recoil_mod = -2
	///bonus to scatter applied when the bipod is deployed
	var/deployment_scatter_mod = -20
	///bonus to burst scatter applied when the bipod is deployed
	var/deployment_burst_scatter_mod = -3


/obj/item/attachable/bipod/activate(mob/living/user, turn_off)
	if(bipod_deployed)
		bipod_deployed = FALSE
		to_chat(user, span_notice("You retract [src]."))
		master_gun.aim_slowdown -= 1
		master_gun.wield_delay -= 0.4 SECONDS
		master_gun.accuracy_mult -= deployment_accuracy_mod
		master_gun.recoil -= deployment_recoil_mod
		master_gun.scatter -= deployment_scatter_mod
		master_gun.burst_scatter_mult -= deployment_burst_scatter_mod
		icon_state = "bipod"
		UnregisterSignal(master_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED))
		UnregisterSignal(master_user, COMSIG_MOVABLE_MOVED)
		master_user = null
	else if(turn_off)
		return //Was already offB
	else
		if(user.do_actions)
			return
		if(!do_after(user, 1 SECONDS, TRUE, src, BUSY_ICON_BAR))
			return
		if(bipod_deployed)
			return
		bipod_deployed = TRUE
		to_chat(user, span_notice("You deploy [src]."))
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

	for(var/i in master_gun.actions)
		var/datum/action/action_to_update = i
		action_to_update.update_button_icon()

	update_icon()
	return TRUE


/obj/item/attachable/bipod/proc/retract_bipod(datum/source)
	SIGNAL_HANDLER
	if(!ismob(source))
		return
	INVOKE_ASYNC(src, .proc/activate, source, TRUE)
	to_chat(source, span_warning("Losing support, the bipod retracts!"))
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

/obj/item/attachable/lace
	name = "pistol lace"
	desc = "A simple lace to wrap around your wrist."
	icon_state = "lace"
	slot = ATTACHMENT_SLOT_MUZZLE //so you cannot have this and RC at once aka balance
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle

/obj/item/attachable/lace/activate(mob/living/user, turn_off)
	if(lace_deployed)
		DISABLE_BITFIELD(master_gun.flags_item, NODROP)
		to_chat(user, span_notice("You feel the [src] loosen around your wrist!"))
		playsound(user, 'sound/weapons/fistunclamp.ogg', 25, 1, 7)
		icon_state = "lace"
	else
		if(user.do_actions)
			return
		if(!do_after(user, 0.5 SECONDS, TRUE, src, BUSY_ICON_BAR))
			return
		to_chat(user, span_notice("You deploy the [src]."))
		ENABLE_BITFIELD(master_gun.flags_item, NODROP)
		to_chat(user, span_warning("You feel the [src] shut around your wrist!"))
		playsound(user, 'sound/weapons/fistclamp.ogg', 25, 1, 7)
		icon_state = "lace-on"

	lace_deployed = !lace_deployed

	for(var/i in master_gun.actions)
		var/datum/action/action_to_update = i
		action_to_update.update_button_icon()

	update_icon()
	return TRUE



/obj/item/attachable/burstfire_assembly
	name = "burst fire assembly"
	desc = "A mechanism re-assembly kit that allows for automatic fire, or more shots per burst if the weapon already has the ability. \nIncreases scatter and decreases accuracy."
	icon_state = "rapidfire"
	slot = ATTACHMENT_SLOT_UNDER
	accuracy_mod = -0.10
	burst_mod = 2
	scatter_mod = 15
	accuracy_unwielded_mod = -0.20
	scatter_unwielded_mod = 20

/obj/item/attachable/hydro_cannon
	name = "TL-84 Hydro Cannon"
	desc = "An integrated component of the TL-84 flamethrower, the hydro cannon fires high pressure sprays of water; mainly to extinguish any wayward allies or unintended collateral damage."
	icon_state = ""
	slot = ATTACHMENT_SLOT_UNDER
	flags_attach_features = GUN_ALLOW_SYNTHETIC
	attachment_action_type = /datum/action/item_action/toggle_hydro
	var/is_active = FALSE

/obj/item/attachable/hydro_cannon/activate(attached_item, mob/living/user, turn_off)
	if(is_active)
		if(user)
			to_chat(user, span_notice("You are no longer using [src]."))
		is_active = FALSE
		overlays -= image('icons/Marine/marine-weapons.dmi', src, "active")
		. = FALSE
	else
		if(user)
			to_chat(user, span_notice("You are now using [src]."))
		is_active = TRUE
		overlays += image('icons/Marine/marine-weapons.dmi', src, "active")
		. = TRUE
	for(var/X in master_gun.actions)
		var/datum/action/A = X
		A.update_button_icon()

	update_icon()

/obj/item/attachable/mateba_longbarrel
	name = "Mateba long barrel"
	desc = "A longer barrel for the Mateba, makes the gun more accurate and deal more damage on impact."
	icon_state = "mateba_barrel"
	slot = ATTACHMENT_BARREL_MOD
	damage_mod = 0.20
	scatter_mod = -3.5
	damage_falloff_mod = -0.5
	pixel_shift_x = 0
	pixel_shift_y = 0
	size_mod = 1
	detach_delay = 0
	gun_attachment_offset_mod = list("muzzle_x" = 8)


/obj/item/attachable/slavicbarrel
	name = "sniper barrel"
	icon_state = "svdbarrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_BARREL_MOD
	pixel_shift_x = -40
	pixel_shift_y = 0
	flags_attach_features = NONE

/obj/item/attachable/buildasentry
	name = "\improper Build-A-Sentry Attachment System"
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "build_a_sentry_attachment"
	desc = "The Build-A-Sentry is the latest design in cheap, automated, defense. Simple attach it the rail of a gun and deploy. Its that easy!"
	slot = ATTACHMENT_SLOT_RAIL
	pixel_shift_x = 10
	pixel_shift_y = 18
	///Battery of the deployed sentry. This is stored here only when the this is not attached to a gun.
	var/obj/item/cell/lasgun/lasrifle/marine/battery
	///Deploy time for the build-a-sentry
	var/deploy_time = 2 SECONDS
	///Undeploy tim for the build-a-sentry
	var/undeploy_time = 2 SECONDS

/obj/item/attachable/buildasentry/Initialize()
	. = ..()
	battery = new(src)

/obj/item/attachable/buildasentry/update_icon_state()
	. = ..()
	var/has_battery
	if(master_gun)
		has_battery = master_gun.sentry_battery
	else
		has_battery = battery
	icon_state = has_battery ? "build_a_sentry_attachment" : "build_a_sentry_attachment_e"

/obj/item/attachable/buildasentry/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I, /obj/item/cell/lasgun/lasrifle/marine))
		return
	if(battery)
		to_chat(user, span_warning("[src] already has a [battery] installed!"))
		return
	to_chat(user, span_notice("You install [I] into [src]."))
	battery = I
	battery.forceMove(src)
	user.temporarilyRemoveItemFromInventory(I)
	playsound(src, 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg', 20)
	update_icon()

/obj/item/attachable/buildasentry/attack_hand(mob/living/user)
	if(user.get_inactive_held_item() != src)
		return ..()
	if(!battery)
		to_chat(user, span_warning("There is no battery to remove from [src]."))
		return
	user.put_in_hands(battery)
	battery = null
	playsound(src, 'sound/weapons/guns/interact/standard_laser_rifle_reload.ogg', 20)
	update_icon()

/obj/item/attachable/buildasentry/can_attach(obj/item/attaching_to, mob/attacher)
	if(!isgun(attaching_to))
		return FALSE
	var/obj/item/weapon/gun/attaching_gun = attaching_to
	if(CHECK_BITFIELD(attaching_gun.flags_gun_features, GUN_IS_SENTRY))
		to_chat(attacher, span_warning("[attaching_gun] is already a sentry!"))
		return FALSE
	return ..()

/obj/item/attachable/buildasentry/on_attach(attaching_item, mob/user)
	. = ..()
	ENABLE_BITFIELD(master_gun.flags_gun_features, GUN_IS_SENTRY)
	ENABLE_BITFIELD(master_gun.flags_item, IS_DEPLOYABLE)
	master_gun.sentry_battery_type = /obj/item/cell/lasgun/lasrifle/marine
	master_gun.sentry_battery = battery
	battery?.forceMove(master_gun)
	master_gun.ignored_terrains = list(
		/obj/machinery/deployable/mounted,
		/obj/machinery/miner,
	)
	if(master_gun.ammo && CHECK_BITFIELD(master_gun.ammo.flags_ammo_behavior, AMMO_ENERGY) || istype(master_gun, /obj/item/weapon/gun/energy)) //If the guns ammo is energy, the sentry will shoot at things past windows.
		master_gun.ignored_terrains += list(
			/obj/structure/window,
			/obj/structure/window/reinforced,
			/obj/machinery/door/window,
			/obj/structure/window/framed,
			/obj/structure/window/framed/colony,
			/obj/structure/window/framed/mainship,
			/obj/structure/window/framed/prison,
		)
	master_gun.turret_flags = TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS
	master_gun.AddElement(/datum/element/deployable_item, /obj/machinery/deployable/mounted/sentry/buildasentry, deploy_time, undeploy_time)
	update_icon()

/obj/item/attachable/buildasentry/on_detach(attaching_item, mob/user)
	. = ..()
	var/obj/item/weapon/gun/detaching_item = attaching_item
	DISABLE_BITFIELD(detaching_item.flags_gun_features, GUN_IS_SENTRY)
	DISABLE_BITFIELD(detaching_item.flags_item, IS_DEPLOYABLE)
	detaching_item.ignored_terrains = null
	detaching_item.turret_flags = NONE
	battery = detaching_item.sentry_battery
	battery?.forceMove(src)
	detaching_item.sentry_battery = null
	detaching_item.RemoveElement(/datum/element/deployable_item, /obj/machinery/deployable/mounted/sentry/buildasentry, deploy_time, undeploy_time)


/obj/item/attachable/flamer_nozzle
	name = "standard flamer nozzle"
	desc = "The standard flamer nozzle. This one fires a stream of fire for direct and accurate flames. Though not as area filling as its counterpart, this one excels at directed frontline combat."
	icon_state = "flame_directional"
	slot = ATTACHMENT_SLOT_FLAMER_NOZZLE
	attach_delay = 2 SECONDS
	detach_delay = 2 SECONDS

	///This is pulled when the parent flamer fires, it determins how the parent flamers fire stream acts.
	var/stream_type = FLAMER_STREAM_STRAIGHT

	///Modifier for burn level of attached flamer. Percentage based.
	var/burn_level_mod = 1
	///Modifier for burn time of attached flamer. Percentage based.
	var/burn_time_mod = 1
	///Range modifier of attached flamer. Numerically based.
	var/range_modifier = 0
	///Damage multiplier for mobs caught in the initial stream of fire of the attached flamer.
	var/mob_flame_damage_mod = 1

/obj/item/attachable/flamer_nozzle/on_attach(attaching_item, mob/user)
	. = ..()
	if(!istype(attaching_item, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/flamer = attaching_item
	flamer.burn_level_mod *= burn_level_mod
	flamer.burn_time_mod *= burn_time_mod
	flamer.flame_max_range += range_modifier
	flamer.mob_flame_damage_mod *= mob_flame_damage_mod

/obj/item/attachable/flamer_nozzle/on_detach(attaching_item, mob/user)
	. = ..()
	if(!istype(attaching_item, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/flamer = attaching_item
	flamer.burn_level_mod /= burn_level_mod
	flamer.burn_time_mod /= burn_time_mod
	flamer.flame_max_range -= range_modifier
	flamer.mob_flame_damage_mod /= mob_flame_damage_mod

/obj/item/attachable/flamer_nozzle/unremovable
	flags_attach_features = NONE

/obj/item/attachable/flamer_nozzle/unremovable/invisible
	icon_state = null

/obj/item/attachable/flamer_nozzle/wide
	name = "spray flamer nozzle"
	desc = "This specialized nozzle sprays the flames of an attached flamer in a much more broad way than the standard nozzle. It serves for wide area denial as opposed to offensive directional flaming."
	icon_state = "flame_wide"
	range_modifier = -3
	pixel_shift_y = 17
	stream_type = FLAMER_STREAM_CONE

///Funny red wide nozzle that can fill entire screens with flames. Admeme only. 
/obj/item/attachable/flamer_nozzle/wide/red
	name = "red spray flamer nozzle"
	desc = "It is red, therefore its obviously more effective."
	icon_state = "flame_wide_red"
	range_modifier = 0

///This is called when an attachment gun (src) attaches to a gun.
/obj/item/weapon/gun/proc/on_attach(obj/item/attached_to, mob/user)
	if(!istype(attached_to, /obj/item/weapon/gun))
		return
	master_gun = attached_to
	if(gun_user)
		UnregisterSignal(gun_user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_ITEM_ZOOM, COMSIG_ITEM_UNZOOM, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_FIREMODE, COMSIG_KB_GUN_SAFETY, COMSIG_KB_UNIQUEACTION, COMSIG_PARENT_QDELETING,  COMSIG_MOB_CLICK_RIGHT))
	var/datum/action/new_action = new /datum/action/item_action/toggle(src, master_gun)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(master_gun == living_user.get_inactive_held_item() || master_gun == living_user.get_active_held_item())
		new_action.give_action(living_user)
	update_icon(user)

///This is called when an attachment gun (src) detaches from a gun.
/obj/item/weapon/gun/proc/on_detach(obj/item/attached_to, mob/user)
	if(!istype(attached_to, /obj/item/weapon/gun))
		return
	for(var/datum/action/action_to_delete AS in master_gun.actions)
		if(action_to_delete.target != src)
			continue
		QDEL_NULL(action_to_delete)
		break
	icon_state = initial(icon_state)
	overlays -= image('icons/Marine/marine-weapons.dmi', src, "active")
	if(master_gun.active_attachable == src)
		master_gun.active_attachable = null
	master_gun = null
	update_icon(user)

///This activates the weapon for use.
/obj/item/weapon/gun/proc/activate(mob/user)
	if(master_gun.active_attachable)
		if(master_gun.active_attachable != src)
			master_gun.active_attachable.activate(user)
			return TRUE
		master_gun.active_attachable = null
		set_gun_user(null)
		overlays -= image('icons/Marine/marine-weapons.dmi', src, "active")
		to_chat(user, span_notice("You stop using [src]."))
	else
		master_gun.active_attachable = src
		set_gun_user(master_gun.gun_user)
		overlays += image('icons/Marine/marine-weapons.dmi', src, "active")
		to_chat(user, span_notice("You start using [src]."))
	for(var/action_to_update in master_gun.actions)
		var/datum/action/action = action_to_update
		action.update_button_icon()
	return TRUE

///Called when the attachment is trying to be attached. If the attachment is allowed to go through, return TRUE.
/obj/item/weapon/gun/proc/can_attach(obj/item/attaching_to, mob/attacher)
	return TRUE

///Called when an attachment is attached to this gun (src).
/obj/item/weapon/gun/proc/on_attachment_attach(/obj/item/attaching_here, mob/attacher)
	return
///Called when an attachment is detached from this gun (src).
/obj/item/weapon/gun/proc/on_attachment_detach(/obj/item/detaching_here, mob/attacher)
	return
