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
	icon_state = null
	worn_icon_state = null
	atom_flags = CONDUCT
	w_class = WEIGHT_CLASS_SMALL
	force = 1
	///ATTACHMENT_SLOT_MUZZLE, ATTACHMENT_SLOT_RAIL, ATTACHMENT_SLOT_UNDER, ATTACHMENT_SLOT_STOCK the particular 'slot' the attachment can attach to. must always be a singular slot.
	var/slot = null
	///Determines the amount of pixels to move the icon state for the overlay. in the x direction
	var/pixel_shift_x = 16
	///Determines the amount of pixels to move the icon state for the overlay. in the y direction
	var/pixel_shift_y = 16
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
	///How long in deciseconds it takes to attach a weapon with level 1 combat training. Default is 1.5 seconds.
	var/attach_delay = 1.5 SECONDS
	///How long in deciseconds it takes to detach a weapon with level 1 combat training. Default is 1.5 seconds.
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
	var/attach_features_flags = ATTACH_REMOVABLE
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
	var/attach_skill = SKILL_COMBAT
	///Skill threshold where the time to attach is halved.
	var/attach_skill_upper_threshold = SKILL_COMBAT_TRAINED
	///Sound played on attach
	var/attach_sound = 'sound/machines/click.ogg'
	///Replacement for initial icon that allows for the code to work with multiple variants
	var/base_icon
	///Assoc list that uses the parents type as a key. type = "new_icon_state". This will change the icon state depending on what type the parent is. If the list is empty, or the parent type is not within, it will have no effect.
	var/list/variants_by_parent_type = list()

/obj/item/attachable/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/attachment, slot, icon, PROC_REF(on_attach), PROC_REF(on_detach), PROC_REF(activate), PROC_REF(can_attach), pixel_shift_x, pixel_shift_y, attach_features_flags, attach_delay, detach_delay, attach_skill, attach_skill_upper_threshold, attach_sound)

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
			master_gun.fire_sound = SFX_GUN_SILENCED
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
	if(G == user.get_active_held_item() || G == user.get_inactive_held_item() || CHECK_BITFIELD(G.item_flags, IS_DEPLOYED))
		playsound(user, activation_sound, 15, 1)
		if(activate(user))
			return TRUE
	else
		to_chat(user, span_warning("[G] must be in our hands to do this."))

///Called when the attachment is activated.
/obj/item/attachable/proc/activate(mob/user, turn_off) //This is for activating stuff like flamethrowers, or switching weapon modes, or flashlights.
	return TRUE

///Called when the attachment is trying to be attached. If the attachment is allowed to go through, return TRUE.
/obj/item/attachable/proc/can_attach(obj/item/attaching_to, mob/attacher)
	return TRUE

///This is called when an attachment gun (src) attaches to a gun.
/obj/item/weapon/gun/proc/on_attach(obj/item/attached_to, mob/user)
	if(!isgun(attached_to))
		return
	var/obj/item/weapon/gun/gun_attached_to = attached_to
	gun_attached_to.gunattachment = src
	master_gun = attached_to
	master_gun.wield_delay += wield_delay_mod
	if(gun_user)
		UnregisterSignal(gun_user, list(COMSIG_MOB_MOUSEDOWN, COMSIG_MOB_MOUSEUP, COMSIG_ITEM_ZOOM, COMSIG_ITEM_UNZOOM, COMSIG_MOB_MOUSEDRAG, COMSIG_KB_RAILATTACHMENT, COMSIG_KB_MUZZLEATTACHMENT, COMSIG_KB_UNDERRAILATTACHMENT, COMSIG_KB_UNLOADGUN, COMSIG_KB_GUN_SAFETY, COMSIG_KB_AUTOEJECT, COMSIG_KB_UNIQUEACTION, COMSIG_QDELETING,  COMSIG_MOB_CLICK_RIGHT))
	var/datum/action/item_action/toggle/new_action = new /datum/action/item_action/toggle(src, master_gun)
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(master_gun == living_user.get_inactive_held_item() || master_gun == living_user.get_active_held_item())
		new_action.give_action(living_user)
	activate(user)
	new_action.set_toggle(TRUE)
	update_icon()
	RegisterSignal(master_gun, COMSIG_ITEM_REMOVED_INVENTORY, TYPE_PROC_REF(/obj/item/weapon/gun, drop_connected_mag))

///This is called when an attachment gun (src) detaches from a gun.
/obj/item/weapon/gun/proc/on_detach(obj/item/attached_to, mob/user)
	if(!isgun(attached_to))
		return
	for(var/datum/action/action_to_delete AS in master_gun.actions)
		if(action_to_delete.target != src)
			continue
		QDEL_NULL(action_to_delete)
		break
	icon_state = initial(icon_state)
	if(master_gun.active_attachable == src)
		master_gun.active_attachable = null
	master_gun.wield_delay -= wield_delay_mod
	UnregisterSignal(master_gun, COMSIG_ITEM_REMOVED_INVENTORY)
	master_gun = null
	var/obj/item/weapon/gun/gun_attached_to = attached_to
	gun_attached_to.gunattachment = null
	update_icon()

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
