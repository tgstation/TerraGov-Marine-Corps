
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

	greyscale_config = null
	greyscale_colors = GUN_PALETTE_BLACK
	colorable_colors = GUN_PALETTE_LIST

	///Determines the amount of pixels to move the icon state for the overlay. in the x direction
	var/pixel_shift_x = 16
	///Determines the amount of pixels to move the icon state for the overlay. in the y direction
	var/pixel_shift_y = 16

	flags_atom = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	force = 1
	///ATTACHMENT_SLOT_MUZZLE, ATTACHMENT_SLOT_RAIL, ATTACHMENT_SLOT_UNDER, ATTACHMENT_SLOT_STOCK the particular 'slot' the attachment can attach to. must always be a singular slot.
	var/slot = null

	///Modifier to firing accuracy, works off a multiplier.
	var/accuracy_mod = 0
	///Modifier to firing accuracy but for when scoped in, works off a multiplier.
	var/scoped_accuracy_mod = 0
	///Modifier to firing accuracy but for when onehanded.
	var/accuracy_unwielded_mod = 0
	///Modifer to the damage mult, works off a multiplier.
	var/damage_mod = 0
	///Modifier to damage falloff, works off a multiplier.
	var/damage_falloff_mod = 0
	///Flat number that adjusts the amount of mêlée force the weapon this is attached to has.
	var/melee_mod = 0
	///Increases or decreases scatter chance.
	var/scatter_mod = 0
	///Increases or decreases scatter chance but for onehanded firing.
	var/scatter_unwielded_mod = 0
	///Maximum scatter
	var/max_scatter_mod = 0
	///Maximum scatter when unwielded
	var/max_scatter_unwielded_mod = 0
	///How much scatter decays every X seconds
	var/scatter_decay_mod = 0
	///How much scatter decays every X seconds when wielded
	var/scatter_decay_unwielded_mod = 0
	///How much scatter increases per shot
	var/scatter_increase_mod = 0
	///How much scatter increases per shot when wielded
	var/scatter_increase_unwielded_mod = 0
	///Minimum scatter
	var/min_scatter_mod = 0
	///Minimum scatter when unwielded
	var/min_scatter_unwielded_mod = 0
	///If positive, adds recoil, if negative, lowers it. Recoil can't go below 0.
	var/recoil_mod = 0
	///If positive, adds recoil, if negative, lowers it. but for onehanded firing. Recoil can't go below 0.
	var/recoil_unwielded_mod = 0
	///Additive to burst scatter modifier from burst fire, works off a multiplier.
	var/burst_scatter_mod = 0
	///additive modifier to burst fire accuracy.
	var/burst_accuracy_mod = 0
	///Adds silenced to weapon. changing its fire sound, muzzle flash, and volume. TRUE or FALSE
	var/silence_mod = FALSE
	///Adds an x-brightness flashlight to the weapon, which can be toggled on and off.
	var/light_mod = 0
	///Changes firing delay. Cannot go below 0.
	var/delay_mod = 0
	///Changes burst firing delay. Cannot go below 0.
	var/burst_delay_mod = 0
	///Changes amount of shots in a burst
	var/burst_mod = 0
	///Increases the weight class.
	var/size_mod = 0
	///Changes the slowdown amount when wielding a weapon by this value.
	var/aim_speed_mod = 0
	///How long ADS takes (time before firing)
	var/wield_delay_mod = 0
	///Changes the speed of projectiles fired
	var/attach_shell_speed_mod = 0
	///Modifies accuracy/scatter penalty when firing onehanded while moving.
	var/movement_acc_penalty_mod = 0
	///How long in deciseconds it takes to attach a weapon with level 1 firearms training. Default is 1.5 seconds.
	var/attach_delay = 1.5 SECONDS
	///How long in deciseconds it takes to detach a weapon with level 1 firearms training. Default is 1.5 seconds.
	var/detach_delay = 1.5 SECONDS
	///Changes aim mode movement delay multiplicatively
	var/aim_mode_movement_mult = 0
	///Modifies projectile damage by a % when a marine gets passed, but not hit
	var/shot_marine_damage_falloff = 0
	///Modifies aim mode fire rate debuff by a %
	var/aim_mode_delay_mod = 0
	///adds aim mode to the gun
	var/add_aim_mode = FALSE
	///the delay between shots, for attachments that fire stuff
	var/attachment_firing_delay = 0

	///The specific sound played when activating this attachment.
	var/activation_sound = 'sound/machines/click.ogg'

	///various yes no flags associated with attachments. See defines for these: [ATTACH_REMOVABLE]
	var/flags_attach_features = ATTACH_REMOVABLE

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
	var/attach_skill = SKILL_FIREARMS
	///Skill threshold where the time to attach is halved.
	var/attach_skill_upper_threshold = SKILL_FIREARMS_TRAINED
	///Sound played on attach
	var/attach_sound = 'sound/machines/click.ogg'

	///Replacement for initial icon that allows for the code to work with multiple variants
	var/base_icon
	///Assoc list that uses the parents type as a key. type = "new_icon_state". This will change the icon state depending on what type the parent is. If the list is empty, or the parent type is not within, it will have no effect.
	var/list/variants_by_parent_type = list()

/obj/item/attachable/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/attachment, slot, icon, PROC_REF(on_attach), PROC_REF(on_detach), PROC_REF(activate), PROC_REF(can_attach), pixel_shift_x, pixel_shift_y, flags_attach_features, attach_delay, detach_delay, attach_skill, attach_skill_upper_threshold, attach_sound)

///Called when the attachment is attached to something. If it is a gun it will update the guns stats.
/obj/item/attachable/proc/on_attach(attaching_item, mob/user)

	if(!istype(attaching_item, /obj/item/weapon/gun))
		return //Guns only

	master_gun = attaching_item

	apply_modifiers(attaching_item, user, TRUE)

	if(attachment_action_type)
		var/datum/action/action_to_update = new attachment_action_type(src, master_gun)
		if(isliving(master_gun.loc))
			var/mob/living/living_user = master_gun.loc
			if(master_gun == living_user.l_hand || master_gun == living_user.r_hand)
				action_to_update.give_action(living_user)

	//custom attachment icons for specific guns
	if(length(variants_by_parent_type))
		for(var/selection in variants_by_parent_type)
			if(istype(master_gun, selection))
				icon_state = variants_by_parent_type[selection]

	update_icon()
	if(!greyscale_colors || !greyscale_config)
		return
	RegisterSignal(master_gun, COMSIG_ITEM_SECONDARY_COLOR, PROC_REF(handle_color))

///Sends a list of available colored attachments to be colored when the parent is right clicked with paint.
/obj/item/attachable/proc/handle_color(datum/source, mob/user, list/obj/item/secondaries)
	SIGNAL_HANDLER
	secondaries += src

///Called when the attachment is detached from something. If the thing is a gun, it returns its stats to what they were before being attached.
/obj/item/attachable/proc/on_detach(detaching_item, mob/user)
	if(!isgun(detaching_item))
		return

	activate(user, TRUE)

	apply_modifiers(detaching_item, user, FALSE)

	for(var/datum/action/action_to_update AS in master_gun.actions)
		if(action_to_update.target != src)
			continue
		qdel(action_to_update)
		break

	master_gun = null
	icon_state = initial(icon_state)
	update_icon()
	if(!greyscale_config || !greyscale_colors)
		return
	UnregisterSignal(master_gun, COMSIG_ITEM_SECONDARY_COLOR)

///Handles the modifiers to the parent gun
/obj/item/attachable/proc/apply_modifiers(attaching_item, mob/user, attaching)
	if(attaching)
		master_gun.accuracy_mult				+= accuracy_mod
		master_gun.accuracy_mult_unwielded		+= accuracy_unwielded_mod
		master_gun.damage_mult					+= damage_mod
		master_gun.damage_falloff_mult			+= damage_falloff_mod
		master_gun.w_class						+= size_mod
		master_gun.scatter						+= scatter_mod
		master_gun.scatter_unwielded			+= scatter_unwielded_mod
		master_gun.max_scatter                  += max_scatter_mod
		master_gun.max_scatter_unwielded        += max_scatter_unwielded_mod
		master_gun.scatter_decay                += scatter_decay_mod
		master_gun.scatter_decay_unwielded      += scatter_decay_unwielded_mod
		master_gun.scatter_increase             += scatter_increase_mod
		master_gun.scatter_increase_unwielded   += scatter_increase_unwielded_mod
		master_gun.min_scatter                  += min_scatter_mod
		master_gun.min_scatter_unwielded        += min_scatter_unwielded_mod
		master_gun.aim_speed_modifier			+= initial(master_gun.aim_speed_modifier)*aim_mode_movement_mult
		master_gun.iff_marine_damage_falloff	+= shot_marine_damage_falloff
		master_gun.add_aim_mode_fire_delay(name, initial(master_gun.aim_fire_delay) * aim_mode_delay_mod)
		if(add_aim_mode)
			var/datum/action/item_action/aim_mode/A = new (master_gun)
			///actually gives the user aim_mode if they're holding the gun
			if(user)
				A.give_action(user)
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
		master_gun.burst_accuracy_bonus			+= burst_accuracy_mod
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
	else
		master_gun.accuracy_mult				-= accuracy_mod
		master_gun.accuracy_mult_unwielded		-= accuracy_unwielded_mod
		master_gun.damage_mult					-= damage_mod
		master_gun.damage_falloff_mult			-= damage_falloff_mod
		master_gun.w_class						-= size_mod
		master_gun.scatter						-= scatter_mod
		master_gun.scatter_unwielded			-= scatter_unwielded_mod
		master_gun.max_scatter                  -= max_scatter_mod
		master_gun.max_scatter_unwielded        -= max_scatter_unwielded_mod
		master_gun.scatter_decay                -= scatter_decay_mod
		master_gun.scatter_decay_unwielded      -= scatter_decay_unwielded_mod
		master_gun.scatter_increase             -= scatter_increase_mod
		master_gun.scatter_increase_unwielded   -= scatter_increase_unwielded_mod
		master_gun.min_scatter                  -= min_scatter_mod
		master_gun.min_scatter_unwielded        -= min_scatter_unwielded_mod
		master_gun.aim_speed_modifier			-= initial(master_gun.aim_speed_modifier)*aim_mode_movement_mult
		master_gun.iff_marine_damage_falloff	-= shot_marine_damage_falloff
		master_gun.remove_aim_mode_fire_delay(name)
		if(add_aim_mode)
			var/datum/action/item_action/aim_mode/action_to_delete = locate() in master_gun.actions
			QDEL_NULL(action_to_delete)
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
		master_gun.burst_accuracy_bonus			-= burst_accuracy_mod
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

/obj/item/attachable/ui_action_click(mob/living/user, datum/action/item_action/action, obj/item/weapon/gun/G)
	if(G == user.get_active_held_item() || G == user.get_inactive_held_item() || CHECK_BITFIELD(G.flags_item, IS_DEPLOYED))
		if(activate(user)) //success
			playsound(user, activation_sound, 15, 1)
	else
		to_chat(user, span_warning("[G] must be in our hands to do this."))

///Called when the attachment is activated.
/obj/item/attachable/proc/activate(mob/user, turn_off) //This is for activating stuff like flamethrowers, or switching weapon modes, or flashlights.
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
	scatter_mod = -2
	recoil_unwielded_mod = -3
	scatter_unwielded_mod = -2
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
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/melee_right.dmi',
	)
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
	variants_by_parent_type = list(/obj/item/weapon/gun/shotgun/pump/t35 = "bayonet_t35")

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
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/melee_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/melee_right.dmi',
	)
	force = 25
	throwforce = 20
	throw_speed = 3
	throw_range = 6
	attack_speed = 8
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
	variants_by_parent_type = list(/obj/item/weapon/gun/shotgun/pump/t35 = "bayonetknife_t35")

/obj/item/attachable/bayonetknife/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/scalping)

/obj/item/attachable/bayonetknife/som
	name = "\improper S20 SOM bayonet"
	desc = "A large knife that is the standard issue combat knife of the SOM. Can be attached to a variety of weapons at will or used as a standard knife."
	icon_state = "bayonetknife_som"
	item_state = "bayonetknife"
	force = 30

/obj/item/attachable/extended_barrel
	name = "extended barrel"
	desc = "A lengthened barrel allows for lessened scatter, greater accuracy and muzzle velocity due to increased stabilization and shockwave exposure."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "ebarrel"
	attach_shell_speed_mod = 1
	accuracy_mod = 0.15
	accuracy_unwielded_mod = 0.1
	scatter_mod = -1
	size_mod = 1
	variants_by_parent_type = list(/obj/item/weapon/gun/rifle/som = "ebarrel_big", /obj/item/weapon/gun/smg/som = "ebarrel_big", /obj/item/weapon/gun/shotgun/pump/t35 = "ebarrel_big")


/obj/item/attachable/heavy_barrel
	name = "barrel charger"
	desc = "A fitted barrel extender that goes on the muzzle, with a small shaped charge that propels a bullet much faster.\nGreatly increases projectile speed and reduces damage falloff."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "hbarrel"
	attach_shell_speed_mod = 2
	accuracy_mod = -0.05
	damage_falloff_mod = -0.2


/obj/item/attachable/compensator
	name = "recoil compensator"
	desc = "A muzzle attachment that reduces recoil and scatter by diverting expelled gasses upwards. \nSignificantly reduces recoil and scatter, regardless of if the weapon is wielded."
	slot = ATTACHMENT_SLOT_MUZZLE
	icon_state = "comp"
	pixel_shift_x = 17
	scatter_mod = -3
	recoil_mod = -2
	scatter_unwielded_mod = -3
	recoil_unwielded_mod = -2
	variants_by_parent_type = list(
		/obj/item/weapon/gun/rifle/som = "comp_big",
		/obj/item/weapon/gun/smg/som = "comp_big",
		/obj/item/weapon/gun/shotgun/som = "comp_big",
		/obj/item/weapon/gun/shotgun/pump/t35 = "comp_big",
		/obj/item/weapon/gun/revolver/standard_magnum = "t76comp"
	)


/obj/item/attachable/sniperbarrel
	name = "sniper barrel"
	icon_state = "sniperbarrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_MUZZLE
	flags_attach_features = NONE
	accuracy_mod = 0.15
	scatter_mod = -3

/obj/item/attachable/autosniperbarrel
	name = "auto sniper barrel"
	icon_state = "t81barrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = ATTACHMENT_SLOT_UNDER
	flags_attach_features = NONE
	pixel_shift_x = 7
	pixel_shift_y = 14
	accuracy_mod = 0
	scatter_mod = -1

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

/obj/item/attachable/sgbarrel
	name = "SG-29 barrel"
	icon_state = "sg29barrel"
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
	aim_mode_delay_mod = -0.5
	variants_by_parent_type = list(/obj/item/weapon/gun/rifle/som = "", /obj/item/weapon/gun/shotgun/som = "")

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
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	activation_sound = 'sound/items/flashlight.ogg'

/obj/item/attachable/flashlight/activate(mob/living/user, turn_off)
	turn_light(user, turn_off ? !turn_off : !light_on)

/obj/item/attachable/flashlight/turn_light(mob/user, toggle_on, cooldown, sparks, forced, light_again)
	. = ..()

	if(. != CHECKS_PASSED)
		return

	if(ismob(master_gun.loc) && !user)
		user = master_gun.loc

	if(!toggle_on && light_on)
		icon_state = initial(icon_state)
		light_on = FALSE
		master_gun.set_light_range(master_gun.light_range - light_mod)
		master_gun.set_light_power(master_gun.light_power - (light_mod * 0.5))
		if(master_gun.light_range <= 0) //does the gun have another light source
			master_gun.set_light_on(FALSE)
			REMOVE_TRAIT(master_gun, TRAIT_GUN_FLASHLIGHT_ON, GUN_TRAIT)
	else if(toggle_on & !light_on)
		icon_state = initial(icon_state) +"_on"
		light_on = TRUE
		master_gun.set_light_range(master_gun.light_range + light_mod)
		master_gun.set_light_power(master_gun.light_power + (light_mod * 0.5))
		if(!HAS_TRAIT(master_gun, TRAIT_GUN_FLASHLIGHT_ON))
			master_gun.set_light_on(TRUE)
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

/obj/item/attachable/flashlight/under
	name = "underbarreled flashlight"
	desc = "A simple flashlight used for mounting on a firearm. \nHas no drawbacks, but isn't particuraly useful outside of providing a light source."
	icon_state = "uflashlight"
	slot = ATTACHMENT_SLOT_UNDER
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION



/obj/item/attachable/quickfire
	name = "quickfire adapter"
	desc = "An enhanced and upgraded autoloading mechanism to fire rounds more quickly. \nHowever, it also reduces accuracy and the number of bullets fired on burst."
	slot = ATTACHMENT_SLOT_RAIL
	icon_state = "autoloader"
	accuracy_mod = -0.10
	delay_mod = -0.125 SECONDS
	burst_mod = -1
	accuracy_unwielded_mod = -0.15

/obj/item/attachable/magnetic_harness
	name = "magnetic harness"
	desc = "A magnetically attached harness kit that attaches to the rail mount of a weapon. When dropped, the weapon will sling to a TGMC armor."
	icon_state = "magnetic"
	slot = ATTACHMENT_SLOT_RAIL
	pixel_shift_x = 13
	///Handles the harness functionality, created when attached to a gun and removed on detach
	var/datum/component/reequip_component

/obj/item/attachable/magnetic_harness/on_attach(attaching_item, mob/user)
	. = ..()
	if(!master_gun)
		return
	reequip_component = master_gun.AddComponent(/datum/component/reequip, list(SLOT_S_STORE, SLOT_BACK))

/obj/item/attachable/magnetic_harness/on_detach(attaching_item, mob/user)
	. = ..()
	if(master_gun)
		return
	QDEL_NULL(reequip_component)

/obj/item/attachable/scope
	name = "rail scope"
	icon_state = "sniperscope"
	desc = "A rail mounted zoom sight scope. Allows zoom by activating the attachment."
	slot = ATTACHMENT_SLOT_RAIL
	aim_speed_mod = 0.5 //Extra slowdown when aiming
	wield_delay_mod = 0.4 SECONDS
	scoped_accuracy_mod = SCOPE_RAIL //accuracy mod of 0.4 when scoped
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	scope_zoom_mod = TRUE // codex
	accuracy_unwielded_mod = -0.05
	zoom_tile_offset = 11
	zoom_viewsize = 10
	zoom_allow_movement = TRUE
	///how much slowdown the scope gives when zoomed. You want this to be slowdown you want minus aim_speed_mod
	var/zoom_slowdown = 1
	/// scope zoom delay, delay before you can aim.
	var/scope_delay = 0
	///boolean as to whether a scope can apply nightvision
	var/has_nightvision = FALSE
	///boolean as to whether the attachment is currently giving nightvision
	var/active_nightvision = FALSE
	///True if the scope is supposed to reactiveate when a deployed gun is turned.
	var/deployed_scope_rezoom = FALSE


/obj/item/attachable/scope/marine
	name = "T-47 rail scope"
	desc = "A marine standard mounted zoom sight scope. Allows zoom by activating the attachment."
	icon_state = "marinescope"

/obj/item/attachable/scope/nightvision
	name = "T-46 Night vision scope"
	icon_state = "nvscope"
	desc = "A rail-mounted night vision scope developed by Roh-Easy industries for the TGMC. Allows zoom by activating the attachment."
	has_nightvision = TRUE

/obj/item/attachable/scope/optical
	name = "T-49 Optical imaging scope"
	icon_state = "imagerscope"
	desc = "A rail-mounted scope designed for the AR-55 and GL-54. Features low light optical imaging capabilities and assists with precision aiming. Allows zoom by activating the attachment."
	has_nightvision = TRUE
	aim_speed_mod = 0.3
	wield_delay_mod = 0.2 SECONDS
	zoom_tile_offset = 7
	zoom_viewsize = 2
	add_aim_mode = TRUE

/obj/item/attachable/scope/mosin
	name = "Mosin nagant rail scope"
	icon_state = "mosinscope"
	desc = "A Mosin specific mounted zoom sight scope. Allows zoom by activating the attachment."

/obj/item/attachable/scope/standard_magnum
	name = "R-76 rail scope"
	desc = "A custom rail mounted zoom sight scope designed specifically for the R-76 Magnum. Allows zoom by activating the attachment."
	icon = 'icons/Marine/attachments_64.dmi'
	icon_state = "t76scope"

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
	icon_state = "tl127_scope"
	aim_speed_mod = 0
	wield_delay_mod = 0
	desc = "A rail mounted zoom sight scope specialized for the SR-127 sniper rifle. Allows zoom by activating the attachment."

/obj/item/attachable/scope/unremovable/heavymachinegun
	name = "HMG-08 long range ironsights"
	desc = "An unremovable set of long range ironsights for an HMG-08 machinegun."
	icon_state = "sniperscope_invisible"
	zoom_viewsize = 0
	zoom_tile_offset = 5

/obj/item/attachable/scope/unremovable/mmg
	name = "MG-27 rail scope"
	icon_state = "miniscope"
	desc = "A small rail mounted zoom sight scope. Allows zoom by activating the attachment."
	wield_delay_mod = 0.2 SECONDS
	aim_speed_mod = 0.2
	scoped_accuracy_mod = SCOPE_RAIL_MINI
	zoom_slowdown = 0.3
	zoom_tile_offset = 5
	zoom_viewsize = 0

/obj/item/attachable/scope/unremovable/standard_atgun
	name = "AT-36 long range scope"
	desc = "An unremovable set of long range scopes, very complex to properly range. Requires time to aim.."
	icon_state = "sniperscope_invisible"
	scope_delay = 2 SECONDS
	zoom_tile_offset = 7

/obj/item/attachable/scope/unremovable/tl102
	name = "HSG-102 smart sight"
	desc = "An unremovable smart sight built for use with the tl102, it does nearly all the aiming work for the gun's integrated IFF systems."
	icon_state = "sniperscope_invisible"
	zoom_viewsize = 0
	zoom_tile_offset = 5
	deployed_scope_rezoom = TRUE

//all mounted guns with a nest use this
/obj/item/attachable/scope/unremovable/tl102/nest
	scope_delay = 2 SECONDS
	zoom_tile_offset = 7
	zoom_viewsize = 2
	deployed_scope_rezoom = FALSE

/obj/item/attachable/scope/activate(mob/living/carbon/user, turn_off)
	if(turn_off)
		if(SEND_SIGNAL(user, COMSIG_ITEM_ZOOM) &  COMSIG_ITEM_ALREADY_ZOOMED)
			zoom(user)
		return TRUE

	if(!(master_gun.flags_item & WIELDED) && !CHECK_BITFIELD(master_gun.flags_item, IS_DEPLOYED))
		if(user)
			to_chat(user, span_warning("You must hold [master_gun] with two hands to use [src]."))
		return FALSE
	if(CHECK_BITFIELD(master_gun.flags_item, IS_DEPLOYED) && user.dir != master_gun.loc.dir)
		user.setDir(master_gun.loc.dir)
	if(!do_after(user, scope_delay, NONE, src, BUSY_ICON_BAR))
		return FALSE
	zoom(user)
	update_icon()
	return TRUE

/obj/item/attachable/scope/zoom_item_turnoff(datum/source, mob/living/carbon/user)
	if(ismob(source))
		INVOKE_ASYNC(src, PROC_REF(activate), source, TRUE)
	else
		INVOKE_ASYNC(src, PROC_REF(activate), user, TRUE)

/obj/item/attachable/scope/onzoom(mob/living/user)
	if(zoom_allow_movement)
		user.add_movespeed_modifier(MOVESPEED_ID_SCOPE_SLOWDOWN, TRUE, 0, NONE, TRUE, zoom_slowdown)
		RegisterSignal(user, COMSIG_CARBON_SWAPPED_HANDS, PROC_REF(zoom_item_turnoff))
	else
		RegisterSignals(user, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_SWAPPED_HANDS), PROC_REF(zoom_item_turnoff))
	if(!CHECK_BITFIELD(master_gun.flags_item, IS_DEPLOYED))
		RegisterSignal(user, COMSIG_MOB_FACE_DIR, PROC_REF(change_zoom_offset))
	RegisterSignals(master_gun, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD, COMSIG_ITEM_DROPPED), PROC_REF(zoom_item_turnoff))
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

/obj/item/attachable/scope/zoom(mob/living/user, tileoffset, viewsize)
	. = ..()
	//Makes the gun zoom align with the attachment, used for projectile procs
	if(zoom)
		master_gun.zoom = TRUE
	else
		master_gun.zoom = FALSE

/obj/item/attachable/scope/optical/update_remote_sight(mob/living/user)
	. = ..()
	user.see_in_dark = 2
	return TRUE

/obj/item/attachable/scope/unremovable/laser_sniper_scope
	name = "Terra Experimental laser sniper rifle rail scope"
	desc = "A marine standard mounted zoom sight scope made for the Terra Experimental laser sniper rifle otherwise known as TE-S abbreviated, allows zoom by activating the attachment."
	icon_state = "tes"

/obj/item/attachable/scope/unremovable/plasma_sniper_scope
	name = "PL-02 sniper rifle rail scope"
	desc = "A marine standard mounted zoom sight scope made for the PL-02 plasma sniper rifle, allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	icon_state = "plasma_scope"

/obj/item/attachable/scope/mini
	name = "mini rail scope"
	icon_state = "miniscope"
	desc = "A small rail mounted zoom sight scope. Allows zoom by activating the attachment."
	slot = ATTACHMENT_SLOT_RAIL
	wield_delay_mod = 0.2 SECONDS
	accuracy_unwielded_mod = -0.05
	aim_speed_mod = 0.2
	scoped_accuracy_mod = SCOPE_RAIL_MINI
	scope_zoom_mod = TRUE
	has_nightvision = FALSE
	zoom_allow_movement = TRUE
	zoom_slowdown = 0.3
	zoom_tile_offset = 5
	zoom_viewsize = 0
	variants_by_parent_type = list(/obj/item/weapon/gun/rifle/som = "")

/obj/item/attachable/scope/mini/tx11
	name = "AR-11 mini rail scope"
	icon_state = "tx11scope"

/obj/item/attachable/scope/antimaterial
	name = "antimaterial rail scope"
	desc = "A rail mounted zoom sight scope specialized for the antimaterial Sniper Rifle . Allows zoom by activating the attachment. Can activate its targeting laser while zoomed to take aim for increased damage and penetration."
	icon_state = "antimat"
	scoped_accuracy_mod = SCOPE_RAIL_SNIPER
	has_nightvision = TRUE
	zoom_allow_movement = FALSE
	flags_attach_features = ATTACH_ACTIVATION|ATTACH_REMOVABLE
	pixel_shift_x = 0
	pixel_shift_y = 17


/obj/item/attachable/scope/slavic
	icon_state = "slavicscope"

/obj/item/attachable/scope/pmc
	icon_state = "pmcscope"
	flags_attach_features = ATTACH_ACTIVATION

/obj/item/attachable/scope/mini/dmr
	name = "DMR-37 mini rail scope"
	icon_state = "t37"


//////////// Stock attachments ////////////////////////////


/obj/item/attachable/stock //Generic stock parent and related things.
	name = "default stock"
	desc = "Default parent object, not meant for use."
	slot = ATTACHMENT_SLOT_STOCK
	flags_attach_features = NONE //most stocks are not removable
	size_mod = 2
	pixel_shift_x = 30
	pixel_shift_y = 14

/obj/item/attachable/stock/mosin
	name = "mosin wooden stock"
	desc = "A non-standard long wooden stock for Slavic firearms."
	icon_state = "mosinstock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/ppsh
	name = "PPSh-17b submachinegun wooden stock"
	desc = "A long wooden stock for a PPSh-17b submachinegun"
	icon_state = "ppshstock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t27
	name = "MG-27 Body"
	desc = "A stock for a MG-27 MMG."
	icon = 'icons/Marine/marine-mmg.dmi'
	icon_state = "t27body"
	pixel_shift_x = 15
	pixel_shift_y = 0

/obj/item/attachable/stock/pal12
	name = "Paladin-12 pump shotgun stock"
	desc = "A standard light stock for the Paladin-12 shotgun."
	icon_state = "pal12stock"

/obj/item/attachable/stock/mpi_km
	name = "MPi-KM wooden stock"
	desc = "A metallic stock with a wooden paint coating, made to fit the MPi-KM."
	icon_state = "ak47stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/mpi_km/black
	name = "MPi-KM polymer stock"
	desc = "A black polymer stock, made to fit the MPi-KM."
	icon_state = "ak47stock_black"

/obj/item/attachable/stock/lmg_d
	name = "lMG-D wooden stock"
	desc = "A metallic stock with a wooden paint coating, made to fit lMG-D."
	icon_state = "ak47stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/tx15
	name = "\improper SH-15 stock"
	desc = "The standard stock for the SH-15. Cannot be removed."
	icon_state = "tx15stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/sgstock
	name = "SG-29 stock"
	desc = "A standard machinegun stock."
	icon_state = "sg29stock"
	greyscale_config = /datum/greyscale_config/gun_attachment
	colorable_allowed = PRESET_COLORS_ALLOWED
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/strstock
	name = "SG-62 stock"
	desc = "A standard rifle stock."
	icon_state = "sg62stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/lasgun
	name = "\improper M43 Sunfury lasgun stock"
	desc = "The standard stock for the M43 Sunfury lasgun."
	icon_state = "laserstock"
	pixel_shift_x = 41
	pixel_shift_y = 10

/obj/item/attachable/stock/lasgun/practice
	name = "\improper M43-P Sunfury lasgun stock"
	desc = "The standard stock for the M43-P Sunfury lasgun, seems the stock is made out of plastic."
	icon_state = "laserstock"
	pixel_shift_x = 41
	pixel_shift_y = 10

/obj/item/attachable/stock/tl127stock
	name = "\improper SR-127 stock"
	desc = "A irremovable SR-127 sniper rifle stock."
	icon_state = "tl127stock"
	greyscale_config = /datum/greyscale_config/gun_attachment
	colorable_allowed = PRESET_COLORS_ALLOWED
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/garand
	name = "\improper C1 stock"
	desc = "A irremovable C1 stock."
	icon_state = "garandstock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/trenchgun
	name = "\improper L-4043 stock"
	desc = "A irremovable L-4043 stock."
	icon_state = "trenchstock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/icc_pdw
	name = "\improper L-40 stock"
	desc = "A irremovable L-40 stock."
	icon_state = "l40stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/icc_sharpshooter
	name = "\improper L-1 stock"
	desc = "A irremovable L-11 stock."
	icon_state = "l11stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/clf_heavyrifle
	name = "PTR-41/1785 body"
	desc = "A stock for a PTR-41/1785 A-MR."
	icon = 'icons/Marine/clf_heavyrifle.dmi'
	icon_state = "ptrs_stock"
	pixel_shift_x = 15
	pixel_shift_y = 0

/obj/item/attachable/stock/dpm
	name = "\improper DP-27 stock"
	desc = "A irremovable DP stock."
	icon_state = "dpstock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t39stock
	name = "\improper SH-39 stock"
	desc = "A specialized stock for the SH-39."
	icon_state = "t39stock"
	pixel_shift_x = 32
	pixel_shift_y = 13
	size_mod = 1
	flags_attach_features = ATTACH_REMOVABLE
	wield_delay_mod = 0.2 SECONDS
	accuracy_mod = 0.15
	recoil_mod = -2
	scatter_mod = -2

/obj/item/attachable/stock/t60stock
	name = "MG-60 stock"
	desc = "A irremovable MG-60 general purpose machinegun stock."
	icon_state = "t60stock"
	greyscale_config = /datum/greyscale_config/gun_attachment
	colorable_allowed = PRESET_COLORS_ALLOWED
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t70stock
	name = "\improper GL-70 stock"
	desc = "A irremovable GL-70 grenade launcher stock."
	icon_state = "t70stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t84stock
	name = "\improper FL-84 stock"
	desc = "A irremovable FL-84 flamer stock."
	icon_state = "tl84stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/m41a
	name = "PR-11 stock"
	icon_state = "m41a"

/obj/item/attachable/stock/tx11
	name = "AR-11 stock"
	icon_state = "tx11stock"

/obj/item/attachable/stock/som_mg_stock
	name = "\improper V-41 stock"
	desc = "A irremovable V-41 machine gun stock."
	icon_state = "v41stock"
	pixel_shift_x = 0
	pixel_shift_y = 0

/obj/item/attachable/stock/t18stock
	name = "\improper AR-18 stock"
	desc = "A specialized stock for the AR-18."
	icon_state = "t18stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t12stock
	name = "\improper AR-12 stock"
	desc = "A specialized stock for the AR-12."
	icon_state = "t12stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t42stock
	name = "\improper MG-42 stock"
	desc = "A specialized stock for the MG-42."
	icon_state = "t42stock"
	pixel_shift_x = 32
	pixel_shift_y = 13

/obj/item/attachable/stock/t64stock
	name = "\improper BR-64 stock"
	desc = "A specialized stock for the BR-64."
	icon_state = "t64stock"

//You can remove the stock on the Magnum. So it has stats and is removeable.

/obj/item/attachable/stock/t76
	name = "T-76 magnum stock"
	desc = "A R-76 magnum stock. Makes about all your handling better outside of making it harder to wield. Recommended to be kept on the R-76 at all times if you value your shoulder."
	icon_state = "t76stock"
	flags_attach_features = ATTACH_REMOVABLE
	melee_mod = 5
	scatter_mod = -1
	size_mod = 2
	aim_speed_mod = 0.05
	recoil_mod = -2
	pixel_shift_x = 30
	pixel_shift_y = 14

//Underbarrel

/obj/item/attachable/verticalgrip
	name = "vertical grip"
	desc = "A custom-built improved foregrip for better accuracy, moderately faster aimed movement speed, less recoil, and less scatter when wielded especially during burst fire. \nHowever, it also increases weapon size, slightly increases wield delay and makes unwielded fire more cumbersome."
	icon_state = "verticalgrip"
	greyscale_config = /datum/greyscale_config/gun_attachment
	colorable_allowed = PRESET_COLORS_ALLOWED
	wield_delay_mod = 0.2 SECONDS
	size_mod = 1
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 20
	accuracy_mod = 0.1
	recoil_mod = -2
	scatter_mod = -3
	burst_scatter_mod = -1
	accuracy_unwielded_mod = -0.05
	scatter_unwielded_mod = 3
	aim_speed_mod = -0.1
	aim_mode_movement_mult = -0.2


/obj/item/attachable/angledgrip
	name = "angled grip"
	desc = "A custom-built improved foregrip for less recoil, and faster wielding time. \nHowever, it also increases weapon size, and slightly hinders unwielded firing."
	icon_state = "angledgrip"
	greyscale_config = /datum/greyscale_config/gun_attachment
	colorable_allowed = PRESET_COLORS_ALLOWED
	wield_delay_mod = -0.3 SECONDS
	size_mod = 1
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 20
	recoil_mod = -1
	scatter_mod = 2
	accuracy_unwielded_mod = -0.1
	scatter_unwielded_mod = 1



/obj/item/attachable/gyro
	name = "gyroscopic stabilizer"
	desc = "A set of weights and balances to stabilize the weapon when burst firing or moving, especially while shooting one-handed. Greatly reduces movement penalties to accuracy. Significantly reduces burst scatter, recoil and general scatter. By increasing accuracy while moving, it let you move faster when taking aim."
	icon_state = "gyro"
	slot = ATTACHMENT_SLOT_UNDER
	scatter_mod = -1
	recoil_mod = -2
	movement_acc_penalty_mod = -2
	accuracy_unwielded_mod = 0.1
	scatter_unwielded_mod = -2
	recoil_unwielded_mod = -1
	aim_mode_movement_mult = -0.5

/obj/item/attachable/lasersight
	name = "laser sight"
	desc = "A laser sight placed under the barrel. Significantly increases one-handed accuracy and significantly reduces unwielded penalties to accuracy."
	icon_state = "lasersight"
	slot = ATTACHMENT_SLOT_UNDER
	pixel_shift_x = 17
	pixel_shift_y = 17
	accuracy_mod = 0.1
	accuracy_unwielded_mod = 0.15

/obj/item/attachable/lace
	name = "pistol lace"
	desc = "A simple lace to wrap around your wrist."
	icon_state = "lace"
	slot = ATTACHMENT_SLOT_MUZZLE //so you cannot have this and RC at once aka balance
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle

/obj/item/attachable/lace/activate(mob/living/user, turn_off)
	if(lace_deployed)
		REMOVE_TRAIT(master_gun, TRAIT_NODROP, PISTOL_LACE_TRAIT)
		to_chat(user, span_notice("You feel the [src] loosen around your wrist!"))
		playsound(user, 'sound/weapons/fistunclamp.ogg', 25, 1, 7)
		icon_state = "lace"
	else if(turn_off)
		return
	else
		if(user.do_actions)
			return
		if(!do_after(user, 0.5 SECONDS, NONE, src, BUSY_ICON_BAR))
			return
		to_chat(user, span_notice("You deploy the [src]."))
		ADD_TRAIT(master_gun, TRAIT_NODROP, PISTOL_LACE_TRAIT)
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
	burst_mod = 2
	burst_scatter_mod = 1
	burst_accuracy_mod = -0.1


//Foldable/deployable attachments
/obj/item/attachable/foldable
	name = "foldable stock"
	desc = "A foldable stock. You shouldn't see this."
	icon_state = ""
	slot = ATTACHMENT_SLOT_STOCK
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION
	attachment_action_type = /datum/action/item_action/toggle
	///How long it takes to fold or unfold
	var/deploy_time
	///whether the attachment is currently folded or not
	var/folded = TRUE

/obj/item/attachable/foldable/on_attach(attaching_item, mob/user)
	if(!istype(attaching_item, /obj/item/weapon/gun))
		return //Guns only

	master_gun = attaching_item

	if(attachment_action_type)
		var/datum/action/action_to_update = new attachment_action_type(src, master_gun)
		if(isliving(master_gun.loc))
			var/mob/living/living_user = master_gun.loc
			if(master_gun == living_user.l_hand || master_gun == living_user.r_hand)
				action_to_update.give_action(living_user)

	//custom attachment icons for specific guns
	if(length(variants_by_parent_type))
		for(var/selection in variants_by_parent_type)
			if(istype(master_gun, selection))
				icon_state = variants_by_parent_type[selection]

	update_icon()
	if(!greyscale_config || !greyscale_colors)
		return
	RegisterSignal(master_gun, COMSIG_ITEM_SECONDARY_COLOR, PROC_REF(handle_color))

/obj/item/attachable/foldable/on_detach(detaching_item, mob/user)
	if(!isgun(detaching_item))
		return

	if(!folded)
		activate()

	for(var/datum/action/action_to_update AS in master_gun.actions)
		if(action_to_update.target != src)
			continue
		qdel(action_to_update)
		break

	master_gun = null
	icon_state = initial(icon_state)
	update_icon()
	if(!greyscale_config || !greyscale_colors)
		return
	UnregisterSignal(master_gun, COMSIG_ITEM_SECONDARY_COLOR)

/obj/item/attachable/foldable/activate(mob/living/user, turn_off)
	if(user && deploy_time && !do_after(user, deploy_time, NONE, src, BUSY_ICON_BAR))
		return FALSE

	folded = !folded
	playsound(src, 'sound/machines/click.ogg', 20, FALSE, 4)
	update_icon()

	if(master_gun)
		apply_modifiers(master_gun, user, !folded)
		for(var/X in master_gun.actions)
			var/datum/action/A = X
			A.update_button_icon()

	return TRUE

/obj/item/attachable/foldable/update_icon_state()
	. = ..()
	if(folded)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_open"

/obj/item/attachable/foldable/skorpion_stock
	name = "\improper Skorpion submachinegun wooden stock"
	desc = "A foldable wire stock for a Skorpion submachinegun"
	icon = 'icons/Marine/attachments_64.dmi'
	icon_state = "skorpion"
	flags_attach_features = ATTACH_ACTIVATION
	pixel_shift_x = 0
	pixel_shift_y = 0
	size_mod = 2
	wield_delay_mod = 0.1 SECONDS
	accuracy_mod = 0.25
	recoil_mod = -2
	scatter_mod = -6
	scatter_unwielded_mod = 4
	accuracy_unwielded_mod = -0.1

/obj/item/attachable/foldable/t19stock
	name = "\improper MP-19 machinepistol stock"
	desc = "A submachinegun stock distributed in small numbers to TGMC forces. Compatible with the MP-19, this stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	flags_attach_features = ATTACH_ACTIVATION
	wield_delay_mod = 0.1 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "t19stock"
	accuracy_mod = 0.3
	recoil_mod = -2
	scatter_mod = -8
	accuracy_unwielded_mod = -0.1
	scatter_unwielded_mod = 4

/obj/item/attachable/foldable/som_carbine
	name = "\improper V-34 carbine stock"
	desc = "A side folding stock built into the V-34 carbine. The gun is designed to be fired with the stock deployed, but can be done without, with some difficulty."
	flags_attach_features = ATTACH_ACTIVATION
	wield_delay_mod = 0.1 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "v34stock"
	accuracy_mod = 0.2
	recoil_mod = -2
	scatter_mod = -8
	aim_speed_mod = 0.05

/obj/item/attachable/foldable/icc_machinepistol
	name = "\improper PL-38 machinepistol stock"
	desc = "A submachinegun stock found on ICC subguns, this stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl."
	flags_attach_features = ATTACH_ACTIVATION
	icon = 'icons/Marine/attachments_64.dmi'
	wield_delay_mod = 0.1 SECONDS
	melee_mod = 5
	size_mod = 1
	icon_state = "pl38stock"
	accuracy_mod = 0.3
	recoil_mod = -2
	scatter_mod = -8
	accuracy_unwielded_mod = -0.1
	scatter_unwielded_mod = 4

/obj/item/attachable/foldable/t35stock
	name = "\improper SH-35 stock"
	desc = "A non-standard heavy stock for the SH-35 shotgun. Less quick and more cumbersome than the standard issue stakeout, but reduces recoil and improves accuracy. Allegedly makes a pretty good club in a fight too."
	icon = 'icons/Marine/attachments_64.dmi'
	icon_state = "t35stock"
	greyscale_config = /datum/greyscale_config/gun_attachment_64
	colorable_allowed = PRESET_COLORS_ALLOWED
	flags_attach_features = ATTACH_ACTIVATION
	wield_delay_mod = 0.2 SECONDS
	accuracy_mod = 0.15
	recoil_mod = -3
	scatter_mod = -2

/obj/item/attachable/foldable/bipod
	name = "bipod"
	desc = "A simple set of telescopic poles to keep a weapon stabilized during firing. \nGreatly increases accuracy and reduces recoil and scatter when properly placed, but also increases weapon size."
	icon_state = "bipod"
	slot = ATTACHMENT_SLOT_UNDER
	size_mod = 2
	deploy_time = 1 SECONDS
	accuracy_mod = 0.3
	recoil_mod = -2
	scatter_mod = -10
	burst_scatter_mod = -3
	aim_mode_delay_mod = -0.5

/obj/item/attachable/foldable/bipod/activate(mob/living/user, turn_off)
	if(folded && !(master_gun.flags_item & WIELDED)) //no one handed bipod use
		if(user)
			balloon_alert(user, "Unwielded")
		return

	. = ..()

	if(folded)
		UnregisterSignal(master_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD))
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		to_chat(user, span_notice("You retract [src]."))
		return

	if(user)
		RegisterSignals(master_gun, list(COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_UNWIELD), PROC_REF(retract_bipod))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(retract_bipod))
		to_chat(user, span_notice("You deploy [src]."))

///Signal handler for forced undeployment
/obj/item/attachable/foldable/bipod/proc/retract_bipod(datum/source, mob/living/user)
	SIGNAL_HANDLER
	deploy_time = 0
	INVOKE_ASYNC(src, PROC_REF(activate), (istype(user) ? user : source), TRUE)
	deploy_time = initial(deploy_time)
	to_chat(user, span_warning("Losing support, the bipod retracts!"))

/obj/item/attachable/buildasentry
	name = "\improper Build-A-Sentry Attachment System"
	icon = 'icons/Marine/sentry.dmi'
	icon_state = "build_a_sentry_attachment"
	desc = "The Build-A-Sentry is the latest design in cheap, automated, defense. Simple attach it to the rail of a gun and deploy. Its that easy!"
	slot = ATTACHMENT_SLOT_RAIL
	size_mod = 1
	pixel_shift_x = 10
	pixel_shift_y = 18
	///Deploy time for the build-a-sentry
	var/deploy_time = 2 SECONDS
	///Undeploy tim for the build-a-sentry
	var/undeploy_time = 2 SECONDS

/obj/item/attachable/buildasentry/can_attach(obj/item/attaching_to, mob/attacher)
	if(!isgun(attaching_to))
		return FALSE
	var/obj/item/weapon/gun/attaching_gun = attaching_to
	if(ispath(attaching_gun.deployable_item, /obj/machinery/deployable/mounted/sentry))
		to_chat(attacher, span_warning("[attaching_gun] is already a sentry!"))
		return FALSE
	return ..()

/obj/item/attachable/buildasentry/on_attach(attaching_item, mob/user)
	. = ..()
	ENABLE_BITFIELD(master_gun.flags_item, IS_DEPLOYABLE)
	master_gun.deployable_item = /obj/machinery/deployable/mounted/sentry/buildasentry
	master_gun.ignored_terrains = list(
		/obj/machinery/deployable/mounted,
		/obj/machinery/miner,
	)
	if(master_gun.ammo_datum_type && CHECK_BITFIELD(initial(master_gun.ammo_datum_type.flags_ammo_behavior), AMMO_ENERGY) || istype(master_gun, /obj/item/weapon/gun/energy)) //If the guns ammo is energy, the sentry will shoot at things past windows.
		master_gun.ignored_terrains += list(
			/obj/structure/window,
			/obj/structure/window/reinforced,
			/obj/machinery/door/window,
			/obj/structure/window/framed,
			/obj/structure/window/framed/colony,
			/obj/structure/window/framed/mainship,
			/obj/structure/window/framed/prison,
		)
	master_gun.turret_flags |= TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS
	master_gun.AddComponent(/datum/component/deployable_item, master_gun.deployable_item, deploy_time, undeploy_time)
	update_icon()

/obj/item/attachable/buildasentry/on_detach(detaching_item, mob/user)
	. = ..()
	var/obj/item/weapon/gun/detaching_gun = detaching_item
	DISABLE_BITFIELD(detaching_gun.flags_item, IS_DEPLOYABLE)
	qdel(detaching_gun.GetComponent(/datum/component/deployable_item))
	detaching_gun.ignored_terrains = null
	detaching_gun.deployable_item = null
	detaching_gun.turret_flags &= ~(TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS)


/obj/item/attachable/shoulder_mount
	name = "experimental shoulder attachment point"
	desc = "A brand new advance in combat technology. This device, once attached to a firearm, will allow the firearm to be mounted onto any piece of modular armor. Once attached to the armor and activated, the gun will fire when the user chooses.\nOnce attached to the armor, <b>right clicking</b> the armor with an empty hand will select what click will fire the armor (middle, right, left). <b>Right clicking</b> with ammunition will reload the gun. Using the <b>Unique Action</b> keybind will perform the weapon's unique action only when the gun is active."
	icon = 'icons/mob/modular/shoulder_gun.dmi'
	icon_state = "shoulder_gun"
	slot = ATTACHMENT_SLOT_RAIL
	pixel_shift_x = 13
	///What click the gun will fire on.
	var/fire_mode = "right"
	///Blacklist of item types not allowed to be in the users hand to fire the gun.
	var/list/in_hand_items_blacklist = list(
		/obj/item/weapon/gun,
		/obj/item/weapon/shield,
	)

/obj/item/attachable/shoulder_mount/on_attach(attaching_item, mob/user)
	. = ..()
	var/obj/item/weapon/gun/attaching_gun = attaching_item
	ENABLE_BITFIELD(flags_attach_features, ATTACH_BYPASS_ALLOWED_LIST|ATTACH_APPLY_ON_MOB)
	attaching_gun.AddElement(/datum/element/attachment, ATTACHMENT_SLOT_MODULE, icon, null, null, null, null, 0, 0, flags_attach_features, attach_delay, detach_delay, attach_skill, attach_skill_upper_threshold, attach_sound, attachment_layer = COLLAR_LAYER)
	RegisterSignal(attaching_gun, COMSIG_ATTACHMENT_ATTACHED, PROC_REF(handle_armor_attach))
	RegisterSignal(attaching_gun, COMSIG_ATTACHMENT_DETACHED, PROC_REF(handle_armor_detach))

/obj/item/attachable/shoulder_mount/on_detach(detaching_item, mob/user)
	var/obj/item/weapon/gun/detaching_gun = detaching_item
	detaching_gun.RemoveElement(/datum/element/attachment, ATTACHMENT_SLOT_MODULE, icon, null, null, null, null, 0, 0, flags_attach_features, attach_delay, detach_delay, attach_skill, attach_skill_upper_threshold, attach_sound, attachment_layer = COLLAR_LAYER)
	DISABLE_BITFIELD(flags_attach_features, ATTACH_BYPASS_ALLOWED_LIST|ATTACH_APPLY_ON_MOB)
	UnregisterSignal(detaching_gun, list(COMSIG_ATTACHMENT_ATTACHED, COMSIG_ATTACHMENT_DETACHED))
	return ..()

/obj/item/attachable/shoulder_mount/ui_action_click(mob/living/user, datum/action/item_action/action, obj/item/weapon/gun/G)
	if(!istype(master_gun.loc, /obj/item/clothing/suit/modular) || master_gun.loc.loc != user)
		return
	activate(user)

/obj/item/attachable/shoulder_mount/activate(mob/user, turn_off)
	. = ..()
	if(CHECK_BITFIELD(master_gun.flags_item, IS_DEPLOYED))
		DISABLE_BITFIELD(master_gun.flags_item, IS_DEPLOYED)
		UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)
		master_gun.set_gun_user(null)
		. = FALSE
	else if(!turn_off)
		ENABLE_BITFIELD(master_gun.flags_item, IS_DEPLOYED)
		update_icon()
		master_gun.set_gun_user(user)
		RegisterSignal(user, COMSIG_MOB_MOUSEDOWN, PROC_REF(handle_firing))
		master_gun.RegisterSignal(user, COMSIG_MOB_MOUSEDRAG, TYPE_PROC_REF(/obj/item/weapon/gun, change_target))
		. = TRUE
	for(var/datum/action/item_action/toggle/action_to_update AS in actions)
		action_to_update.set_toggle(.)
		action_to_update.update_button_icon()

///Handles the gun attaching to the armor.
/obj/item/attachable/shoulder_mount/proc/handle_armor_attach(datum/source, attaching_item, mob/user)
	SIGNAL_HANDLER
	if(!istype(attaching_item, /obj/item/clothing/suit/modular))
		return
	master_gun.set_gun_user(null)
	RegisterSignal(attaching_item, COMSIG_ITEM_EQUIPPED, PROC_REF(handle_activations))
	RegisterSignal(attaching_item, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, PROC_REF(switch_mode))
	RegisterSignal(attaching_item, COMSIG_ATOM_ATTACKBY_ALTERNATE, PROC_REF(reload_gun))
	RegisterSignal(master_gun, COMSIG_MOB_GUN_FIRED, PROC_REF(after_fire))
	master_gun.base_gun_icon = master_gun.placed_overlay_iconstate
	master_gun.update_icon()

///Handles the gun detaching from the armor.
/obj/item/attachable/shoulder_mount/proc/handle_armor_detach(datum/source, detaching_item, mob/user)
	SIGNAL_HANDLER
	if(!istype(detaching_item, /obj/item/clothing/suit/modular))
		return
	for(var/datum/action/action_to_delete AS in actions)
		if(action_to_delete.target != src)
			continue
		QDEL_NULL(action_to_delete)
		break
	update_icon(user)
	master_gun.base_gun_icon = initial(master_gun.icon_state)
	master_gun.update_icon()
	UnregisterSignal(detaching_item, list(COMSIG_ITEM_EQUIPPED, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, COMSIG_ATOM_ATTACKBY_ALTERNATE))
	UnregisterSignal(master_gun, COMSIG_MOB_GUN_FIRED)
	UnregisterSignal(user, COMSIG_MOB_MOUSEDOWN)

///Sets up the action.
/obj/item/attachable/shoulder_mount/proc/handle_activations(datum/source, mob/equipper, slot)
	if(!isliving(equipper))
		return
	if(slot != SLOT_WEAR_SUIT)
		LAZYREMOVE(actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/old_action = locate(/datum/action/item_action/toggle) in actions
		if(!old_action)
			return
		old_action.remove_action(equipper)
		actions = null
	else
		LAZYADD(actions_types, /datum/action/item_action/toggle)
		var/datum/action/item_action/toggle/new_action = new(src)
		new_action.give_action(equipper)

///Performs the firing.
/obj/item/attachable/shoulder_mount/proc/handle_firing(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	if(!modifiers[fire_mode])
		return
	if(!istype(master_gun.loc, /obj/item/clothing/suit/modular) || master_gun.loc.loc != source)
		return
	if(source.Adjacent(object))
		return
	var/mob/living/user = master_gun.gun_user
	if(user.incapacitated()  || user.lying_angle || LAZYACCESS(user.do_actions, src) || !user.dextrous || (!CHECK_BITFIELD(master_gun.flags_gun_features, GUN_ALLOW_SYNTHETIC) && !CONFIG_GET(flag/allow_synthetic_gun_use) && issynth(user)))
		return
	var/active_hand = user.get_active_held_item()
	var/inactive_hand = user.get_inactive_held_item()
	for(var/item_blacklisted in in_hand_items_blacklist)
		if(!istype(active_hand, item_blacklisted) && !istype(inactive_hand, item_blacklisted))
			continue
		to_chat(user, span_warning("[src] beeps. Guns or shields in your hands are interfering with its targetting. Aborting."))
		return
	master_gun.start_fire(source, object, location, control, null, TRUE)

///Switches click fire modes.
/obj/item/attachable/shoulder_mount/proc/switch_mode(datum/source, mob/living/user)
	SIGNAL_HANDLER
	switch(fire_mode)
		if("right")
			fire_mode = "middle"
			to_chat(user, span_notice("[master_gun] will now fire on a 'middle click'."))
		if("middle")
			fire_mode = "left"
			to_chat(user, span_notice("[master_gun] will now fire on a 'left click'."))
		if("left")
			fire_mode = "right"
			to_chat(user, span_notice("[master_gun] will now fire on a 'right click'."))

///Reloads the gun
/obj/item/attachable/shoulder_mount/proc/reload_gun(datum/source, obj/item/attacking_item, mob/living/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(master_gun, TYPE_PROC_REF(/obj/item/weapon/gun, reload), attacking_item, user)

///Performs the unique action after firing and checks to see if the user is still able to fire.
/obj/item/attachable/shoulder_mount/proc/after_fire(datum/source, atom/target, obj/item/weapon/gun/fired_gun)
	SIGNAL_HANDLER
	if(CHECK_BITFIELD(master_gun.reciever_flags, AMMO_RECIEVER_REQUIRES_UNIQUE_ACTION))
		INVOKE_ASYNC(master_gun, TYPE_PROC_REF(/obj/item/weapon/gun, do_unique_action), master_gun.gun_user)
	var/mob/living/user = master_gun.gun_user
	var/active_hand = user.get_active_held_item()
	var/inactive_hand = user.get_inactive_held_item()
	for(var/item_blacklisted in in_hand_items_blacklist)
		if(!istype(active_hand, item_blacklisted) && !istype(inactive_hand, item_blacklisted))
			continue
		to_chat(user, span_warning("[src] beeps. Guns or shields in your hands are interfering with its targetting. Stopping fire."))
		master_gun.stop_fire()
		return
	if(!user.incapacitated() && !user.lying_angle && !LAZYACCESS(user.do_actions, src) && user.dextrous && (CHECK_BITFIELD(master_gun.flags_gun_features, GUN_ALLOW_SYNTHETIC) || CONFIG_GET(flag/allow_synthetic_gun_use) || !issynth(user)))
		return
	master_gun.stop_fire()

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
	pixel_shift_y = 17
	stream_type = FLAMER_STREAM_CONE
	burn_time_mod = 0.3

///Funny red wide nozzle that can fill entire screens with flames. Admeme only.
/obj/item/attachable/flamer_nozzle/wide/red
	name = "red spray flamer nozzle"
	desc = "It is red, therefore its obviously more effective."
	icon_state = "flame_wide_red"
	range_modifier = 3

///Flamer ammo is a normal ammo datum, which means we can shoot it if we want
/obj/item/attachable/flamer_nozzle/long
	name = "extended flamer nozzle"
	icon_state = "flame_long"
	desc = "Rather than spreading the supplied fuel over an area, this nozzle launches a single fireball to ignite a target at range. Reduced volume per shot also means the next is ready quicker."
	stream_type = FLAMER_STREAM_RANGED
	delay_mod = -10

/obj/item/attachable/flamer_nozzle/long/on_attach(attaching_item, mob/user)
	. = ..()
	if(!istype(attaching_item, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/flamer = attaching_item
	//Since we're firing more like a normal gun, we do need to use up rounds after firing
	flamer.reciever_flags &= ~AMMO_RECIEVER_DO_NOT_EMPTY_ROUNDS_AFTER_FIRE

/obj/item/attachable/flamer_nozzle/long/on_detach(attaching_item, mob/user)
	. = ..()
	if(!istype(attaching_item, /obj/item/weapon/gun/flamer))
		return
	var/obj/item/weapon/gun/flamer/flamer = attaching_item
	if(initial(flamer.reciever_flags) & AMMO_RECIEVER_DO_NOT_EMPTY_ROUNDS_AFTER_FIRE)
		flamer.reciever_flags |= AMMO_RECIEVER_DO_NOT_EMPTY_ROUNDS_AFTER_FIRE

///This is called when an attachment gun (src) attaches to a gun.
/obj/item/weapon/gun/proc/on_attach(obj/item/attached_to, mob/user)
	if(!istype(attached_to, /obj/item/weapon/gun))
		return
	master_gun = attached_to
	master_gun.wield_delay					+= wield_delay_mod
	if(gun_user)
		UnregisterSignal(gun_user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_ITEM_ZOOM, COMSIG_ITEM_UNZOOM, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_FIREMODE, COMSIG_KB_GUN_SAFETY, COMSIG_KB_AUTOEJECT, COMSIG_KB_UNIQUEACTION, COMSIG_QDELETING,  COMSIG_MOB_CLICK_RIGHT))
	var/datum/action/item_action/toggle/new_action = new /datum/action/item_action/toggle(src, master_gun)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(master_gun == living_user.get_inactive_held_item() || master_gun == living_user.get_active_held_item())
		new_action.give_action(living_user)
	attached_to:gunattachment = src
	activate(user)
	new_action.set_toggle(TRUE)
	new_action.update_button_icon()
	update_icon(user)
	RegisterSignal(master_gun, COMSIG_ITEM_REMOVED_INVENTORY, TYPE_PROC_REF(/obj/item/weapon/gun, drop_connected_mag))

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
	if(master_gun.active_attachable == src)
		master_gun.active_attachable = null
	master_gun.wield_delay					-= wield_delay_mod
	UnregisterSignal(master_gun, COMSIG_ITEM_REMOVED_INVENTORY)
	master_gun = null
	attached_to:gunattachment = null
	update_icon(user)

///This activates the weapon for use.
/obj/item/weapon/gun/proc/activate(mob/user)
	if(master_gun.active_attachable)
		if(master_gun.active_attachable != src)
			master_gun.active_attachable.activate(user)
			return TRUE
		master_gun.active_attachable = null
		set_gun_user(null)
		to_chat(user, span_notice("You stop using [src]."))
	else
		master_gun.active_attachable = src
		set_gun_user(null)
		set_gun_user(master_gun.gun_user)
		to_chat(user, span_notice("You start using [src]."))
	for(var/datum/action/item_action/toggle/action AS in master_gun.actions)
		if(action.target != src )
			continue
		action.set_toggle(master_gun.active_attachable == src)
		action.update_button_icon()
	return TRUE

///Called when the attachment is trying to be attached. If the attachment is allowed to go through, return TRUE.
/obj/item/weapon/gun/proc/can_attach(obj/item/attaching_to, mob/attacher)
	return TRUE

///Called when an attachment is attached to this gun (src).
/obj/item/weapon/gun/proc/on_attachment_attach(obj/item/attaching_here, mob/attacher)
	return
///Called when an attachment is detached from this gun (src).
/obj/item/weapon/gun/proc/on_attachment_detach(obj/item/detaching_here, mob/attacher)
	return
