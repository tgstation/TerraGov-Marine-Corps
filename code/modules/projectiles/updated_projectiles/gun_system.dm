/obj/item/weapon/gun
	name = "Guns"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/items/gun.dmi'
	icon_state = ""
	item_state = "gun"
	materials = list(/datum/material/metal = 5000)
	w_class 	= 3
	throwforce 	= 5
	throw_speed = 4
	throw_range = 5
	force 		= 5
	attack_verb = null
	sprite_sheet_id = 1
	flags_atom = CONDUCT
	flags_item = TWOHANDED

	var/atom/movable/vis_obj/effect/muzzle_flash/muzzle_flash
	var/muzzle_flash_lum = 3 //muzzle flash brightness

	var/fire_sound 		= 'sound/weapons/guns/fire/gunshot.ogg'
	var/dry_fire_sound	= 'sound/weapons/guns/fire/empty.ogg'
	var/unload_sound 	= 'sound/weapons/flipblade.ogg'
	var/empty_sound 	= 'sound/weapons/guns/misc/smg_empty_alarm.ogg'
	var/reload_sound 	= null					//We don't want these for guns that don't have them.
	var/cocked_sound 	= null
	var/cock_cooldown	= 0						//world.time value, to prevent COCK COCK COCK COCK
	var/cock_delay		= 3 SECONDS				//Delay before we can cock again
	var/last_fired = 0							//When it was last fired, related to world.time.

	//Ammo will be replaced on New() for things that do not use mags..
	var/datum/ammo/ammo = null					//How the bullet will behave once it leaves the gun, also used for basic bullet damage and effects, etc.
	var/obj/item/projectile/in_chamber = null 	//What is currently in the chamber. Most guns will want something in the chamber upon creation.
	/*Ammo mags may or may not be internal, though the difference is a few additional variables. If they are not internal, don't call
	on those unique vars. This is done for quicker pathing. Just keep in mind most mags aren't internal, though some are.
	This is also the default magazine path loaded into a projectile weapon for reverse lookups on New(). Leave this null to do your own thing.*/
	var/obj/item/ammo_magazine/internal/current_mag = null
	var/type_of_casings = null					//Can be "bullet", "shell", or "cartridge". Bullets are generic casings, shells are used by shotguns, cartridges are for rifles.

	//Basic stats.
	var/accuracy_mult 			= 1				//Multiplier. Increased and decreased through attachments. Multiplies the projectile's accuracy by this number.
	var/damage_mult 			= 1				//Same as above, for damage.
	var/damage_falloff_mult 	= 1				//Same as above, for damage bleed (falloff)
	var/recoil 					= 0				//Screen shake when the weapon is fired.
	var/recoil_unwielded 		= 0
	var/scatter					= 20				//How much the bullet scatters when fired.
	var/scatter_unwielded 		= 20
	var/burst_scatter_mult		= 3				//Multiplier. Increases or decreases how much bonus scatter is added when burst firing (wielded only).
	var/burst_accuracy_mult		= 1				//Multiplier. Defaults to 1 (no penalty). Multiplies accuracy modifier by this amount while burst firing; usually a fraction (penalty) when set.
	var/accuracy_mod			= 0.05				//accuracy modifier, used by most attachments.
	var/accuracy_mult_unwielded = 1		//same vars as above but for unwielded firing.
	var/movement_acc_penalty_mult = 5				//Multiplier. Increased and decreased through attachments. Multiplies the accuracy/scatter penalty of the projectile when firing onehanded while moving.
	var/fire_delay = 6							//For regular shots, how long to wait before firing again.
	var/shell_speed_mod	= 0						//Modifies the speed of projectiles fired.
	
	//Burst fire.
	var/burst_amount 	= 1						//How many shots can the weapon shoot in burst? Anything less than 2 and you cannot toggle burst.
	var/burst_delay 	= 0.1 SECONDS			//The delay in between shots. Lower = less delay = faster.
	var/extra_delay		= 0						//When burst-firing, this number is extra time before the weapon can fire again. Depends on number of rounds fired.


	//Slowdowns
	var/aim_slowdown	= 0						//Self explanatory. How much does aiming (wielding the gun) slow you
	var/wield_delay		= 0.4 SECONDS		//How long between wielding and firing in tenths of seconds
	var/wield_penalty	= 0.2 SECONDS	//Extra wield delay for untrained operators
	var/wield_time		= 0						//Storing value for above


	//Energy Weapons
	var/ammo_per_shot	= 1						//How much ammo consumed per shot; normally 1.
	var/overcharge		= 0						//In overcharge mode?

	//Attachments.
	var/list/attachable_overlays	= list("muzzle", "rail", "under", "stock", "mag") //List of overlays so we can switch them in an out, instead of using Cut() on overlays.
	var/list/attachable_offset 		= null		//Is a list, see examples of from the other files. Initiated on New() because lists don't initial() properly.
	var/list/attachable_allowed		= null		//Must be the exact path to the attachment present in the list. Empty list for a default.
	var/obj/item/attachable/muzzle 	= null		//Attachable slots. Only one item per slot.
	var/obj/item/attachable/rail 	= null
	var/obj/item/attachable/under 	= null
	var/obj/item/attachable/stock 	= null
	var/obj/item/attachable/attached_gun/active_attachable = null //This will link to one of the above four, or remain null.
	var/list/starting_attachment_types = null //What attachments this gun starts with THAT CAN BE REMOVED. Important to avoid nuking the attachments on restocking! Added on New()

	var/flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK

	var/gun_firemode = GUN_FIREMODE_SEMIAUTO
	var/list/gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO)

	var/gun_skill_category //used to know which job knowledge this gun is linked to

	var/base_gun_icon //the default gun icon_state. change to reskin the gun

	var/hud_enabled = TRUE //If the Ammo HUD is enabled for this gun or not.

	var/general_codex_key = "guns"


//----------------------------------------------------------
				//				    \\
				// NECESSARY PROCS  \\
				//					\\
				//					\\
//----------------------------------------------------------

/obj/item/weapon/gun/Initialize(mapload, spawn_empty) //You can pass on spawn_empty to make the sure the gun has no bullets or mag or anything when created.
	. = ..()					//This only affects guns you can get from vendors for now. Special guns spawn with their own things regardless.
	base_gun_icon = icon_state
	if(current_mag)
		if(spawn_empty && !(flags_gun_features & GUN_INTERNAL_MAG)) //Internal mags will still spawn, but they won't be filled.
			current_mag = null
			update_icon()
		else
			current_mag = new current_mag(src, spawn_empty ? TRUE : FALSE)
			ammo = current_mag.default_ammo ? GLOB.ammo_list[current_mag.default_ammo] : GLOB.ammo_list[/datum/ammo/bullet] //Latter should never happen, adding as a precaution.
		if(flags_gun_features & GUN_LOAD_INTO_CHAMBER && current_mag?.current_rounds > 0)
			load_into_chamber()
	else
		ammo = GLOB.ammo_list[ammo] //If they don't have a mag, they fire off their own thing.
	update_force_list() //This gives the gun some unique verbs for attacking.

	handle_starting_attachment()

	setup_firemodes()
	AddComponent(/datum/component/automatic_fire, fire_delay, burst_delay, burst_amount, gun_firemode, loc) //This should go after handle_starting_attachment() and setup_firemodes() to get the proper values set.

	muzzle_flash = new()


//Hotfix for attachment offsets being set AFTER the core New() proc. Causes a small graphical artifact when spawning, hopefully works even with lag
/obj/item/weapon/gun/proc/handle_starting_attachment()
	if(starting_attachment_types && starting_attachment_types.len)
		for(var/path in starting_attachment_types)
			var/obj/item/attachable/A = new path(src)
			A.Attach(src)


/obj/item/weapon/gun/Destroy()
	ammo = null
	active_attachable = null
	if(muzzle)
		QDEL_NULL(muzzle)
	if(rail)
		QDEL_NULL(rail)
	if(under)
		QDEL_NULL(under)
	if(stock)
		QDEL_NULL(stock)
	if(in_chamber)
		QDEL_NULL(in_chamber)
	if(current_mag)
		QDEL_NULL(current_mag)
	if(muzzle_flash)
		QDEL_NULL(muzzle_flash)
	return ..()

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/equipped(mob/user, slot)
	unwield(user)

	return ..()

/obj/item/weapon/gun/update_icon()
	if(!current_mag || current_mag.current_rounds <= 0)
		icon_state = base_gun_icon + "_e"
	else
		icon_state = base_gun_icon
	update_mag_overlay()

/obj/item/weapon/gun/examine(mob/user)
	. = ..()
	var/list/dat = list()
	if(flags_gun_features & GUN_TRIGGER_SAFETY)
		dat += "The safety's on!<br>"
	else
		dat += "The safety's off!<br>"

	if(rail)
		dat += "It has [icon2html(rail, user)] [rail.name] mounted on the top.<br>"
	if(muzzle)
		dat += "It has [icon2html(muzzle, user)] [muzzle.name] mounted on the front.<br>"
	if(stock)
		dat += "It has [icon2html(stock, user)] [stock.name] for a stock.<br>"
	if(under)
		dat += "It has [icon2html(under, user)] [under.name]"
		if(under.flags_attach_features & ATTACH_WEAPON)
			dat += " ([under.current_rounds]/[under.max_rounds])"
		dat += " mounted underneath.<br>"

	if(dat)
		to_chat(user, "[dat.Join(" ")]")

	examine_ammo_count(user)

/obj/item/weapon/gun/proc/examine_ammo_count(mob/user)
	var/list/dat = list()
	if(!(flags_gun_features & (GUN_INTERNAL_MAG|GUN_UNUSUAL_DESIGN))) //Internal mags and unusual guns have their own stuff set.
		if(current_mag?.current_rounds > 0)
			if(flags_gun_features & GUN_AMMO_COUNTER)
				dat += "Ammo counter shows [current_mag.current_rounds] round\s remaining.<br>"
			else
				dat += "It's loaded[in_chamber?" and has a round chambered":""].<br>"
		else
			dat += "It's unloaded[in_chamber?" but has a round chambered":""].<br>"
	if(dat)
		to_chat(user, "[dat.Join(" ")]")

/obj/item/weapon/gun/wield(mob/user)
	if(!(flags_item & TWOHANDED) || flags_item & WIELDED)
		return

	var/obj/item/offhand = user.get_inactive_held_item()
	if(offhand)
		if(offhand == user.r_hand)
			user.drop_r_hand()
		else if(offhand == user.l_hand)
			user.drop_l_hand()
		if(user.get_inactive_held_item()) //Failsafe; if there's somehow still something in the off-hand (undroppable), bail.
			to_chat(user, "<span class='warning'>You need your other hand to be empty!</span>")
			return

	if(ishuman(user))
		var/check_hand = user.r_hand == src ? "l_hand" : "r_hand"
		var/mob/living/carbon/human/wielder = user
		var/datum/limb/hand = wielder.get_limb(check_hand)
		if(!istype(hand) || !hand.is_usable())
			to_chat(user, "<span class='warning'>Your other hand can't hold \the [src]!</span>")
			return

	flags_item 	   ^= WIELDED
	name 	   += " (Wielded)"
	item_state += "_w"
	update_slowdown()
	place_offhand(user, initial(name))
	var/wdelay = wield_delay
	//slower or faster wield delay depending on skill.
	if(user.mind && user.mind.cm_skills)
		if(user.mind.cm_skills.firearms == 0) //no training in any firearms
			wdelay += 3
		else
			var/skill_value = 0
			switch(gun_skill_category)
				if(GUN_SKILL_PISTOLS)
					skill_value = user.mind.cm_skills.pistols
				if(GUN_SKILL_SMGS)
					skill_value = user.mind.cm_skills.smgs
				if(GUN_SKILL_RIFLES)
					skill_value = user.mind.cm_skills.rifles
				if(GUN_SKILL_SHOTGUNS)
					skill_value = user.mind.cm_skills.shotguns
				if(GUN_SKILL_HEAVY_WEAPONS)
					skill_value = user.mind.cm_skills.heavy_weapons
				if(GUN_SKILL_SMARTGUN)
					skill_value = user.mind.cm_skills.smartgun
				if(GUN_SKILL_SPEC)
					skill_value = user.mind.cm_skills.spec_weapons
			if(skill_value > 0)
				wdelay -= 2*skill_value
			else
				wdelay += wield_penalty
	wield_time = world.time + wdelay
	var/obj/screen/ammo/A = user.hud_used.ammo
	A.add_hud(user)
	A.update_hud(user)
	do_wield(user, wdelay)
	return TRUE


/obj/item/weapon/gun/unwield(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(zoom)
		zoom(user)

	update_slowdown()

	var/obj/screen/ammo/A = user.hud_used?.ammo
	if(A)
		A.remove_hud(user)

	return TRUE


/obj/item/weapon/gun/proc/update_slowdown()
	if(flags_item & WIELDED)
		slowdown = initial(slowdown) + aim_slowdown
	else
		slowdown = initial(slowdown)


//----------------------------------------------------------
			//							        \\
			// LOADING, RELOADING, AND CASINGS  \\
			//							        \\
			//						   	        \\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/replace_ammo(mob/user = null, obj/item/ammo_magazine/magazine)
	if(!magazine.default_ammo)
		stack_trace("null ammo while reloading. User: [user]")
		ammo = GLOB.ammo_list[/datum/ammo/bullet] //Looks like we're defaulting it.
	else
		ammo = GLOB.ammo_list[overcharge? magazine.overcharge_ammo : magazine.default_ammo]
		//to_chat(user, "DEBUG: REPLACE AMMO. Ammo: [ammo]")

//Hardcoded and horrible
/obj/item/weapon/gun/proc/cock_gun(mob/user)
	set waitfor = 0
	if(cocked_sound)
		sleep(3)
		if(user && loc)
			playsound(user, cocked_sound, 25, 1)

/*
Reload a gun using a magazine.
This sets all the initial datum's stuff. The bullet does the rest.
User can be passed as null, (a gun reloading itself for instance), so we need to watch for that constantly.
*/
/obj/item/weapon/gun/proc/reload(mob/user, obj/item/ammo_magazine/magazine)
	if(flags_gun_features & (GUN_BURST_FIRING|GUN_UNUSUAL_DESIGN|GUN_INTERNAL_MAG))
		return

	if(!magazine || !istype(magazine))
		to_chat(user, "<span class='warning'>That's not a magazine!</span>")
		return

	if(magazine.flags_magazine & AMMUNITION_HANDFUL)
		to_chat(user, "<span class='warning'>[src] needs an actual magazine.</span>")
		return

	if(magazine.current_rounds <= 0)
		to_chat(user, "<span class='warning'>[magazine] is empty!</span>")
		return

	if(!istype(src, magazine.gun_type))
		to_chat(user, "<span class='warning'>That magazine doesn't fit in there!</span>")
		return

	if(current_mag)
		to_chat(user, "<span class='warning'>It's still got something loaded.</span>")
		return



	if(user)
		if(magazine.reload_delay > 1)
			to_chat(user, "<span class='notice'>You begin reloading [src]. Hold still...</span>")
			if(do_after(user,magazine.reload_delay, TRUE, src, BUSY_ICON_GENERIC))
				replace_magazine(user, magazine)
			else
				to_chat(user, "<span class='warning'>Your reload was interrupted!</span>")
				return
		else
			replace_magazine(user, magazine)
	else
		current_mag = magazine
		magazine.loc = src
		replace_ammo(,magazine)
		if(!in_chamber)
			load_into_chamber()

	update_icon(user)
	return TRUE

/obj/item/weapon/gun/proc/replace_magazine(mob/user, obj/item/ammo_magazine/magazine)
	user.transferItemToLoc(magazine, src) //Click!
	current_mag = magazine
	replace_ammo(user,magazine)
	if(!in_chamber)
		ready_in_chamber(user)
		if(!flags_gun_features & GUN_ENERGY)
			cock_gun(user)
	user.visible_message("<span class='notice'>[user] loads [magazine] into [src]!</span>",
	"<span class='notice'>You load [magazine] into [src]!</span>", null, 3)
	if(reload_sound)
		playsound(user, reload_sound, 25, 1, 5)
	update_icon()


//Drop out the magazine. Keep the ammo type for next time so we don't need to replace it every time.
//This can be passed with a null user, so we need to check for that as well.
/obj/item/weapon/gun/proc/unload(mob/user, reload_override = 0, drop_override = 0) //Override for reloading mags after shooting, so it doesn't interrupt burst. Drop is for dropping the magazine on the ground.
	if(!reload_override && (flags_gun_features & (GUN_BURST_FIRING|GUN_UNUSUAL_DESIGN|GUN_INTERNAL_MAG)))
		return FALSE

	if(!current_mag || isnull(current_mag) || current_mag.loc != src || !flags_gun_features & GUN_ENERGY)
		return cock(user)

	if(drop_override || !user) //If we want to drop it on the ground or there's no user.
		current_mag.loc = get_turf(src) //Drop it on the ground.
	else
		user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1, 5)
	user.visible_message("<span class='notice'>[user] unloads [current_mag] from [src].</span>",
	"<span class='notice'>You unload [current_mag] from [src].</span>", null, 4)
	current_mag.update_icon()
	current_mag = null

	update_icon(user)

	return TRUE


//Manually cock the gun
//This only works on weapons NOT marked with UNUSUAL_DESIGN or INTERNAL_MAG or ENERGY
/obj/item/weapon/gun/proc/cock(mob/user)

	if(flags_gun_features & (GUN_BURST_FIRING|GUN_UNUSUAL_DESIGN|GUN_INTERNAL_MAG|GUN_ENERGY))
		return FALSE
	if(cock_cooldown > world.time)
		return FALSE

	cock_cooldown = world.time + cock_delay
	cock_gun(user)
	if(in_chamber)
		user.visible_message("<span class='notice'>[user] cocks [src], clearing a [in_chamber.name] from its chamber.</span>",
		"<span class='notice'>You cock [src], clearing a [in_chamber.name] from its chamber.</span>", null, 4)

		// Get gun information from the current mag if its equipped otherwise the default ammo & caliber
		var/bullet_ammo_type
		var/bullet_caliber
		if(current_mag)
			bullet_ammo_type = current_mag.default_ammo
			bullet_caliber = current_mag.caliber
		else
			bullet_ammo_type = ammo.type
			bullet_caliber = caliber

		// Try to find an existing handful in our hands or on the floor under us
		var/obj/item/ammo_magazine/handful/X
		if (istype(user.r_hand, /obj/item/ammo_magazine/handful))
			X = user.r_hand
		else if (istype(user.l_hand, /obj/item/ammo_magazine/handful))
			X = user.l_hand

		var/obj/item/ammo_magazine/handful/H
		if (X && X.default_ammo == bullet_ammo_type && X.caliber == bullet_caliber && X.current_rounds < X.max_rounds)
			H = X
		else
			for(var/obj/item/ammo_magazine/handful/HL in user.loc)
				if(HL.default_ammo == bullet_ammo_type && HL.caliber == bullet_caliber && HL.current_rounds < HL.max_rounds)
					H = HL
					break
		if(H)
			H.current_rounds++
		else
			H = new
			H.generate_handful(bullet_ammo_type, bullet_caliber, 8, 1, type)
			user.put_in_hands(H)

		H.update_icon()
		in_chamber = null
	else
		user.visible_message("<span class='notice'>[user] cocks [src].</span>",
		"<span class='notice'>You cock [src].</span>", null, 4)
	ready_in_chamber() //This will already check for everything else, loading the next bullet.

	return TRUE


//Since reloading and casings are closely related, placing this here ~N
/obj/item/weapon/gun/proc/make_casing(casing_type) //Handle casings is set to discard them.
	if(casing_type)
		var/num_of_casings = (current_mag && current_mag.used_casings) ? current_mag.used_casings : 1
		var/sound_to_play = casing_type == "shell" ? 'sound/bullets/bulletcasing_shotgun_fall1.ogg' : pick('sound/bullets/bulletcasing_fall2.ogg','sound/bullets/bulletcasing_fall1.ogg')
		var/turf/current_turf = get_turf(src)
		var/new_casing = text2path("/obj/item/ammo_casing/[casing_type]")
		var/obj/item/ammo_casing/casing = locate(new_casing) in current_turf
		if(!casing) //No casing on the ground?
			casing = new new_casing(current_turf)
			num_of_casings--
			playsound(current_turf, sound_to_play, 25, 1, 5) //Played again if necessary.
		if(num_of_casings) //Still have some.
			casing.current_casings += num_of_casings
			casing.update_icon()
			playsound(current_turf, sound_to_play, 25, 1, 5)

//----------------------------------------------------------
			//							    \\
			// AFTER ATTACK AND CHAMBERING  \\
			//							    \\
			//						   	    \\
//----------------------------------------------------------

/obj/item/weapon/gun/afterattack(atom/A, mob/living/user, flag, params)
	if(flag)
		return ..() //It's adjacent, is the user, or is on the user's person
	if(QDELETED(A))
		return
	if(flags_gun_features & GUN_BURST_FIRING)
		return

	if(!istype(A, /obj/screen))
		Fire(A, user, params) //Otherwise, fire normally.

/*
load_into_chamber(), reload_into_chamber(), and clear_jam() do all of the heavy lifting.
If you need to change up how a gun fires, just change these procs for that subtype
and you're good to go.
*/
/obj/item/weapon/gun/proc/load_into_chamber(mob/user)
	//The workhorse of the bullet procs.
	
	//Let's check on the active attachable. It loads ammo on the go, so it never chambers anything
	if(active_attachable && active_attachable.flags_attach_features & ATTACH_PROJECTILE)
		if(active_attachable.current_rounds > 0) //If it's still got ammo and stuff.
			active_attachable.current_rounds--
			return create_bullet(active_attachable.ammo)
		to_chat(user, "<span class='warning'>[active_attachable] is empty!</span>")
		to_chat(user, "<span class='notice'>You disable [active_attachable].</span>")
		playsound(user, active_attachable.activation_sound, 15, 1)
		active_attachable.activate_attachment(null, TRUE)
		return

	if(in_chamber) //If we have a round chambered and no active attachable, we're good to go.
		return in_chamber //Already set!

	return ready_in_chamber() //We're not using the active attachable, we must use the active mag if there is one.


/obj/item/weapon/gun/proc/ready_in_chamber()
	if(current_mag && current_mag.current_rounds > 0)
		in_chamber = create_bullet(ammo)
		current_mag.current_rounds-- //Subtract the round from the mag.
		return in_chamber

/obj/item/weapon/gun/proc/create_bullet(datum/ammo/chambered)
	if(!chambered)
		stack_trace("null ammo while create_bullet(). User: [usr]")
		chambered = GLOB.ammo_list[/datum/ammo/bullet] //Slap on a default bullet if somehow ammo wasn't passed.

	var/obj/item/projectile/P = new /obj/item/projectile(src)
	P.generate_bullet(chambered)
	return P

//This proc is needed for firearms that chamber rounds after firing.
/obj/item/weapon/gun/proc/reload_into_chamber(mob/user)
	/*
	ATTACHMENT POST PROCESSING
	This should only apply to the masterkey, since it's the only attachment that shoots through Fire()
	instead of its own thing through fire_attachment(). If any other bullet attachments are added, they would fire here.
	*/
	if(active_attachable && active_attachable.flags_attach_features & ATTACH_PROJECTILE)
		make_casing(active_attachable.type_of_casings) // Attachables can drop their own casings.
		return in_chamber
	
	make_casing(type_of_casings) // Drop a casing if needed.
	in_chamber = null //If we didn't fire from attachable, let's set this so the next pass doesn't think it still exists.

	if(current_mag) //If there is no mag, we can't reload.
		ready_in_chamber(user)
		if(current_mag.current_rounds <= 0 && flags_gun_features & GUN_AUTO_EJECTOR) // This is where the magazine is auto-ejected.
			unload(user, TRUE, TRUE) // We want to quickly autoeject the magazine. This proc does the rest based on magazine type. User can be passed as null.
			playsound(src, empty_sound, 25, 1)

	return in_chamber //Returns the projectile if it's actually successful.


/obj/item/weapon/gun/proc/delete_bullet(obj/item/projectile/projectile_to_fire, refund = FALSE)
	if(active_attachable && active_attachable.flags_attach_features & ATTACH_PROJECTILE) //Attachables don't chamber rounds, so we want to delete it right away.
		qdel(projectile_to_fire) //Getting rid of it. Attachables only use ammo after the cycle is over.
		if(refund)
			active_attachable.current_rounds += ammo_per_shot //Refund the bullet.
		return TRUE


/obj/item/weapon/gun/proc/clear_jam(obj/item/projectile/projectile_to_fire, mob/user) //Guns jamming, great.
	flags_gun_features &= ~GUN_BURST_FIRING // Also want to turn off bursting, in case that was on. It probably was.
	delete_bullet(projectile_to_fire, TRUE) //We're going to clear up anything inside if we need to.
	//If it's a regular bullet, we're just going to keep it chambered.
	extra_delay = 0.2 SECONDS + ((burst_delay + extra_delay) * 2) // Some extra delay before firing again.
	to_chat(user, "<span class='warning'>[src] jammed! You'll need a second to get it fixed!</span>")

//----------------------------------------------------------
		//									   \\
		// FIRE BULLET AND POINT BLANK/SUICIDE \\
		//									   \\
		//						   			   \\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/Fire(atom/target, mob/living/user, params, reflex = 0, dual_wield)
	set waitfor = 0

	if(!able_to_fire(user))
		return

	if(gun_on_cooldown(user))
		return

	if(SEND_SIGNAL(src, COMSIG_GUN_FIRE, target, user) & COMPONENT_GUN_FIRED)
		return

	var/turf/targloc = get_turf(target)

	/*
	This is where burst is established for the proceeding section. Which just means the proc loops around that many times.
	If burst = 1, you must null it if you ever RETURN during the for() cycle. If for whatever reason burst is left on while
	the gun is not firing, it will break a lot of stuff. BREAK is fine, as it will null it.
	*/

	//Number of bullets based on burst. If an active attachable is shooting, bursting is always zero.
	var/bullets_fired = 1
	if(gun_firemode == GUN_FIREMODE_BURSTFIRE && burst_amount > 1)
		bullets_fired = burst_amount
		flags_gun_features |= GUN_BURST_FIRING

	var/i
	for(i = 1 to bullets_fired)
		if(loc != user)
			break //If you drop it while bursting, for example.

		if(i > 1 && !(flags_gun_features & GUN_BURST_FIRING))//no longer burst firing somehow
			break

		//The gun should return the bullet that it already loaded from the end cycle of the last Fire().
		var/obj/item/projectile/projectile_to_fire = load_into_chamber(user) //Load a bullet in or check for existing one.
		if(!projectile_to_fire) //If there is nothing to fire, click.
			click_empty(user)
			break

		if(QDELETED(target)) //This can happen on burstfire, as it's a sleeping proc.
			if(QDELETED(targloc))
				break
			target = targloc //If the original targets gets destroyed, fire at its location.

		var/recoil_comp = 0 //used by bipod and akimbo firing

		//checking for a gun in other hand to fire akimbo
		if(i == 1 && !reflex && !dual_wield)
			if(user)
				var/obj/item/IH = user.get_inactive_held_item()
				if(istype(IH, /obj/item/weapon/gun))
					var/obj/item/weapon/gun/OG = IH
					if(!(OG.flags_gun_features & GUN_WIELDED_FIRING_ONLY) && OG.gun_skill_category == gun_skill_category)
						OG.Fire(target,user,params, 0, TRUE)
						dual_wield = TRUE
						recoil_comp++

		apply_gun_modifiers(projectile_to_fire, target)
		setup_bullet_accuracy(projectile_to_fire, user, i, dual_wield) //User can be passed as null.

		if(params)
			var/list/mouse_control = params2list(params)
			if(mouse_control["icon-x"])
				projectile_to_fire.p_x = text2num(mouse_control["icon-x"])
			if(mouse_control["icon-y"])
				projectile_to_fire.p_y = text2num(mouse_control["icon-y"])

		var/firing_angle = get_angle_with_scatter((user || get_turf(src)), target, get_scatter(projectile_to_fire.scatter, user), projectile_to_fire.p_x, projectile_to_fire.p_y)

		//Finally, make with the pew pew!
		if(!projectile_to_fire || !istype(projectile_to_fire,/obj))
			stack_trace("projectile malfunctioned while firing. User: [user]")
			flags_gun_features &= ~GUN_BURST_FIRING
			return

		if(!QDELETED(user))
			play_fire_sound(user)
			muzzle_flash(firing_angle, user)
			simulate_recoil(recoil_comp, user)


		//This is where the projectile leaves the barrel and deals with projectile code only.
		//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
		projectile_to_fire.fire_at(target, user, src, projectile_to_fire.ammo.max_range, projectile_to_fire.ammo.shell_speed, firing_angle)
		//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		last_fired = world.time

		//This is where we load the next bullet in the chamber. We check for attachments too, since we don't want to load anything if an attachment is active.
		if(!reload_into_chamber(user)) // It has to return a bullet, otherwise it's empty.
			click_empty(user)
			break //Nothing else to do here, time to cancel out.

		if(i < bullets_fired) // We still have some bullets to fire.
			extra_delay = min(extra_delay+(burst_delay*2), fire_delay*3) // The more bullets you shoot, the more delay there is, but no more than thrice the regular delay.
			sleep(burst_delay)

		SEND_SIGNAL(user, COMSIG_HUMAN_GUN_FIRED, target, src, user)

	flags_gun_features &= ~GUN_BURST_FIRING // We always want to turn off bursting when we're done.

	var/obj/screen/ammo/A = user.hud_used.ammo //The ammo HUD
	A.update_hud(user)


/obj/item/weapon/gun/attack(mob/living/M, mob/living/user, def_zone)
	if(!CHECK_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)) // If it can't point blank, you can't suicide and such.
		return ..()

	if(!able_to_fire(user))
		return ..()

	if(gun_on_cooldown(user))
		return ..()

	if(M != user && user.a_intent == INTENT_HARM)
		if(!active_attachable && gun_firemode == GUN_FIREMODE_BURSTFIRE && burst_amount > 1)
			..()
			Fire(M, user)
			return TRUE
		..()
		DISABLE_BITFIELD(flags_gun_features, GUN_BURST_FIRING)
		//Point blanking simulates firing the bullet proper but without actually firing it.
		if(active_attachable && !CHECK_BITFIELD(active_attachable.flags_attach_features, ATTACH_PROJECTILE))
			active_attachable.activate_attachment(null, TRUE)//No way.
		var/obj/item/projectile/projectile_to_fire = load_into_chamber(user)
		if(!projectile_to_fire) //We actually have a projectile, let's move on. We're going to simulate the fire cycle.
			return // no ..(), already invoked above

		user.visible_message("<span class='danger'>[user] fires [src] point blank at [M]!</span>")
		apply_gun_modifiers(projectile_to_fire, M)
		setup_bullet_accuracy(projectile_to_fire, user) //We add any damage effects that we need.
		projectile_to_fire.setDir(get_dir(user, M))
		projectile_to_fire.distance_travelled = get_dist(user, M)
		simulate_recoil(1, user) // 1 is a scalar value not boolean
		play_fire_sound(user)

		if(projectile_to_fire.ammo.bonus_projectiles_amount)
			var/obj/item/projectile/BP
			for(var/i = 1 to projectile_to_fire.ammo.bonus_projectiles_amount)
				BP = new /obj/item/projectile(M.loc)
				BP.generate_bullet(GLOB.ammo_list[projectile_to_fire.ammo.bonus_projectiles_type])
				BP.setDir(get_dir(user, M))
				BP.distance_travelled = get_dist(user, M)
				BP.ammo.on_hit_mob(M, BP)
				M.bullet_act(BP)
				qdel(BP)

		projectile_to_fire.ammo.on_hit_mob(M, projectile_to_fire)
		M.bullet_act(projectile_to_fire)
		last_fired = world.time

		if(!delete_bullet(projectile_to_fire))
			qdel(projectile_to_fire)
		reload_into_chamber(user) //Reload into the chamber if the gun supports it.
		if(user) //Update dat HUD
			var/obj/screen/ammo/A = user.hud_used.ammo //The ammo HUD
			A.update_hud(user)
		return TRUE


	if(M != user || user.zone_selected != "mouth")
		return ..()

	DISABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK) //If they try to click again, they're going to hit themselves.

	user.visible_message("<span class='warning'>[user] sticks their gun in their mouth, ready to pull the trigger.</span>")
	log_combat(user, null, "is trying to commit suicide")

	if(!do_after(user, 40, TRUE, src, BUSY_ICON_DANGER))
		M.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
		ENABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)
		return

	if(active_attachable && !CHECK_BITFIELD(active_attachable.flags_attach_features, ATTACH_PROJECTILE))
		active_attachable.activate_attachment(null, TRUE)//We're not firing off a nade into our mouth.
	var/obj/item/projectile/projectile_to_fire = load_into_chamber(user)

	if(!projectile_to_fire) //We actually have a projectile, let's move on.
		click_empty(user)//If there's no projectile, we can't do much.
		ENABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)
		return

	user.visible_message("<span class = 'warning'>[user] pulls the trigger!</span>")
	var/actual_sound = (active_attachable?.fire_sound) ? active_attachable.fire_sound : fire_sound
	var/sound_volume = (CHECK_BITFIELD(flags_gun_features, GUN_SILENCED) && !active_attachable) ? 25 : 60
	playsound(user, actual_sound, sound_volume, 1)
	simulate_recoil(2, user)
	var/obj/item/weapon/gun/revolver/current_revolver = src
	log_combat(user, null, "committed suicide with [src].")
	message_admins("[ADMIN_TPMONTY(user)] committed suicide with [src].")
	if(istype(current_revolver) && current_revolver.russian_roulette) //If it's a revolver set to Russian Roulette.
		user.apply_damage(projectile_to_fire.damage * 3, projectile_to_fire.ammo.damage_type, "head", 0, TRUE)
		user.apply_damage(200, OXY) //In case someone tried to defib them. Won't work.
		user.death()
		to_chat(user, "<span class='highdanger'>Your life flashes before you as your spirit is torn from your body!</span>")
		user.ghostize(0) //No return.
		ENABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)
		return

	if(projectile_to_fire.ammo.damage_type == HALLOSS)
		to_chat(user, "<span class = 'notice'>Ow...</span>")
		user.apply_effect(110, AGONY, 0)
	else
		user.apply_damage(projectile_to_fire.damage * 2.5, projectile_to_fire.ammo.damage_type, "head", 0, TRUE)
		user.apply_damage(100, OXY)
		if(ishuman(user) && user == M)
			var/mob/living/carbon/human/HM = user
			HM.set_undefibbable() //can't be defibbed back from self inflicted gunshot to head
		user.death()

	user.log_message("commited suicide with [src]", LOG_ATTACK, "red") //Apply the attack log.
	last_fired = world.time

	projectile_to_fire.play_damage_effect(user)
	if(!delete_bullet(projectile_to_fire))
		qdel(projectile_to_fire) //If this proc DIDN'T delete the bullet, we're going to do so here.

	reload_into_chamber(user) //Reload the sucker.
	ENABLE_BITFIELD(flags_gun_features, GUN_CAN_POINTBLANK)

//----------------------------------------------------------
				//							\\
				// FIRE CYCLE RELATED PROCS \\
				//							\\
				//						   	\\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/able_to_fire(mob/user)
	if(flags_gun_features & GUN_BURST_FIRING)
		return FALSE
	if(!ismob(user)) //Could be an object firing the gun.
		return TRUE
	if(!user.dextrous)
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(!(flags_gun_features & GUN_ALLOW_SYNTHETIC) && !CONFIG_GET(flag/allow_synthetic_gun_use) && issynth(user))
		to_chat(user, "<span class='warning'>Your program does not allow you to use this firearm.</span>")
		return FALSE
	if(flags_gun_features & GUN_TRIGGER_SAFETY)
		to_chat(user, "<span class='warning'>The safety is on!</span>")
		return FALSE
	if((flags_gun_features & GUN_WIELDED_FIRING_ONLY) && !(flags_item & WIELDED)) //If we're not holding the weapon with both hands when we should.
		to_chat(user, "<span class='warning'>You need a more secure grip to fire this weapon!")
		return FALSE
	if((flags_gun_features & GUN_POLICE) && !police_allowed_check(user))
		return FALSE
	return TRUE


/obj/item/weapon/gun/proc/gun_on_cooldown(mob/user)
	var/added_delay = fire_delay
	if(active_attachable?.attachment_firing_delay && active_attachable.flags_attach_features & ATTACH_PROJECTILE)
		added_delay = active_attachable.attachment_firing_delay
	else if(user?.mind?.cm_skills)
		if(!user.mind.cm_skills.firearms) //no training in any firearms
			added_delay += 3 //untrained humans fire more slowly.
		else
			switch(gun_skill_category)
				if(GUN_SKILL_HEAVY_WEAPONS)
					if(fire_delay > 10) //long delay to fire
						added_delay = max(fire_delay - 3*user.mind.cm_skills.heavy_weapons, 6)
				if(GUN_SKILL_SMARTGUN)
					if(user.mind.cm_skills.smartgun < 0)
						added_delay -= 2*user.mind.cm_skills.smartgun
				if(GUN_SKILL_SPEC)
					if(user.mind.cm_skills.spec_weapons < 0)
						added_delay -= 2*user.mind.cm_skills.spec_weapons

	if(world.time >= last_fired + added_delay + extra_delay) //check the last time it was fired.
		extra_delay = 0 //Since we are ready to fire again, zero it up.
		return FALSE
	
	if(world.time % 3)
		to_chat(user, "<span class='warning'>[src] is not ready to fire again!</span>")
	return TRUE


/obj/item/weapon/gun/proc/click_empty(mob/user)
	SEND_SIGNAL(src, COMSIG_GUN_CLICKEMPTY)
	if(user)
		var/obj/screen/ammo/A = user.hud_used.ammo //The ammo HUD
		A.update_hud(user)
		to_chat(user, "<span class='warning'><b>*click*</b></span>")
		playsound(user, dry_fire_sound, 25, 1, 5) //5 tile range
	else
		playsound(src, dry_fire_sound, 25, 1, 5)


/obj/item/weapon/gun/proc/play_fire_sound(mob/user)
	if(active_attachable && active_attachable.flags_attach_features & ATTACH_PROJECTILE)
		if(active_attachable.fire_sound) //If we're firing from an attachment, use that noise instead.
			playsound(user, active_attachable.fire_sound, 50)
		return
	if(flags_gun_features & GUN_SILENCED)
		playsound(user, fire_sound, 25)
		return
	playsound(user, fire_sound, 60)


/obj/item/weapon/gun/proc/apply_gun_modifiers(obj/item/projectile/projectile_to_fire, atom/target)
	projectile_to_fire.shot_from = src
	projectile_to_fire.damage *= damage_mult
	projectile_to_fire.damage_falloff *= damage_falloff_mult
	projectile_to_fire.projectile_speed += shell_speed_mod


/obj/item/weapon/gun/proc/setup_bullet_accuracy(obj/item/projectile/projectile_to_fire, mob/user, bullets_fired = 1, dual_wield = FALSE)
	var/gun_accuracy_mult = accuracy_mult_unwielded
	var/gun_scatter = scatter_unwielded

	if(flags_item & WIELDED && wielded_stable())
		gun_accuracy_mult = accuracy_mult
		gun_scatter = scatter

	else if(user && world.time - user.last_move_time < 5) //moved during the last half second
		//accuracy and scatter penalty if the user fires unwielded right after moving
		gun_accuracy_mult = max(0.1, gun_accuracy_mult - max(0,movement_acc_penalty_mult * 0.15))
		gun_scatter += max(0, movement_acc_penalty_mult * 5)

	if(gun_firemode == GUN_FIREMODE_BURSTFIRE && burst_amount > 1)
		gun_accuracy_mult = max(0.1, gun_accuracy_mult * burst_accuracy_mult)

	if(dual_wield) //akimbo firing gives terrible accuracy
		if(gun_skill_category == GUN_SKILL_PISTOLS)
			gun_accuracy_mult = max(0.1, gun_accuracy_mult - 0.1*rand(1,2))
			gun_scatter += 10*rand(1,3)
		else
			gun_accuracy_mult = max(0.1, gun_accuracy_mult - 0.1*rand(2,4))
			gun_scatter += 10*rand(3,5)

	if(user)
	// Apply any skill-based bonuses to accuracy
		if(user.mind?.cm_skills)
			var/skill_accuracy = 0
			if(user.mind.cm_skills.firearms == 0) //no training in any firearms
				skill_accuracy = -1
			else
				switch(gun_skill_category)
					if(GUN_SKILL_PISTOLS)
						skill_accuracy = user.mind.cm_skills.pistols
					if(GUN_SKILL_SMGS)
						skill_accuracy = user.mind.cm_skills.smgs
					if(GUN_SKILL_RIFLES)
						skill_accuracy = user.mind.cm_skills.rifles
					if(GUN_SKILL_SHOTGUNS)
						skill_accuracy = user.mind.cm_skills.shotguns
					if(GUN_SKILL_HEAVY_WEAPONS)
						skill_accuracy = user.mind.cm_skills.heavy_weapons
					if(GUN_SKILL_SMARTGUN)
						skill_accuracy = user.mind.cm_skills.smartgun
					if(GUN_SKILL_SPEC)
						skill_accuracy = user.mind.cm_skills.spec_weapons
			if(skill_accuracy)
				gun_accuracy_mult += skill_accuracy * 0.15 // Accuracy mult increase/decrease per level is equal to attaching/removing a red dot sight

		projectile_to_fire.firer = user
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			projectile_to_fire.def_zone = user.zone_selected
			if(C.stagger)
				gun_scatter += 30

	projectile_to_fire.accuracy = round(projectile_to_fire.accuracy * gun_accuracy_mult) // Apply gun accuracy multiplier to projectile accuracy
	projectile_to_fire.scatter += gun_scatter					//Add gun scatter value to projectile's scatter value





/obj/item/weapon/gun/proc/get_scatter(starting_scatter, mob/user)
	. = starting_scatter //projectile_to_fire.scatter

	if(. <= 0) //Not if the gun doesn't scatter at all, or negative scatter.
		return 0

	switch(gun_firemode)
		if(GUN_FIREMODE_BURSTFIRE, GUN_FIREMODE_AUTOBURST, GUN_FIREMODE_AUTOMATIC) //Much higher chance on a burst or similar.
			if(flags_item & WIELDED && wielded_stable())
				. += burst_amount * burst_scatter_mult
			else
				. += burst_amount * burst_scatter_mult * 5

	if(user?.mind?.cm_skills)
		if(user.mind.cm_skills.firearms <= 0) //no training in any firearms
			. += 15
		else
			var/scatter_tweak = 0
			switch(gun_skill_category)
				if(GUN_SKILL_PISTOLS)
					scatter_tweak = user.mind.cm_skills.pistols
				if(GUN_SKILL_SMGS)
					scatter_tweak = user.mind.cm_skills.smgs
				if(GUN_SKILL_RIFLES)
					scatter_tweak = user.mind.cm_skills.rifles
				if(GUN_SKILL_SHOTGUNS)
					scatter_tweak = user.mind.cm_skills.shotguns
				if(GUN_SKILL_HEAVY_WEAPONS)
					scatter_tweak = user.mind.cm_skills.heavy_weapons
				if(GUN_SKILL_SMARTGUN)
					scatter_tweak = user.mind.cm_skills.smartgun
				if(GUN_SKILL_SPEC)
					scatter_tweak = user.mind.cm_skills.spec_weapons
			if(scatter_tweak)
				. -= scatter_tweak * 15

	if(!prob(.)) //RNG at work.
		return 0


/obj/item/weapon/gun/proc/simulate_recoil(recoil_bonus = 0, mob/user)
	var/total_recoil = recoil_bonus
	if(flags_item & WIELDED && wielded_stable())
		total_recoil += recoil
	else
		total_recoil += recoil_unwielded
		if(flags_gun_features & GUN_BURST_FIRING)
			total_recoil += 1

	if(user?.mind?.cm_skills)

		if(user.mind.cm_skills.firearms == 0) //no training in any firearms
			total_recoil += 2
		else
			var/recoil_tweak
			switch(gun_skill_category)
				if(GUN_SKILL_PISTOLS)
					recoil_tweak = user.mind.cm_skills.pistols
				if(GUN_SKILL_SMGS)
					recoil_tweak = user.mind.cm_skills.smgs
				if(GUN_SKILL_RIFLES)
					recoil_tweak = user.mind.cm_skills.rifles
				if(GUN_SKILL_SHOTGUNS)
					recoil_tweak = user.mind.cm_skills.shotguns
				if(GUN_SKILL_HEAVY_WEAPONS)
					recoil_tweak = user.mind.cm_skills.heavy_weapons
				if(GUN_SKILL_SMARTGUN)
					recoil_tweak = user.mind.cm_skills.smartgun
				if(GUN_SKILL_SPEC)
					recoil_tweak = user.mind.cm_skills.spec_weapons
			if(recoil_tweak)
				total_recoil -= recoil_tweak * 2
	if(total_recoil > 0 && ishuman(user))
		shake_camera(user, total_recoil + 1, total_recoil)
		return TRUE


/obj/item/weapon/gun/proc/muzzle_flash(angle, atom/movable/flash_loc)
	if(!muzzle_flash || muzzle_flash.applied)
		return
	var/prev_light = light_range
	if(light_range < muzzle_flash_lum)
		set_light(muzzle_flash_lum)
		addtimer(CALLBACK(src, /atom.proc/set_light, prev_light), 1 SECONDS)

	//Offset the pixels.
	switch(angle)
		if(0, 360)
			muzzle_flash.pixel_x = 0
			muzzle_flash.pixel_y = 4
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(1 to 44)
			muzzle_flash.pixel_x = round(4 * ((angle) / 45))
			muzzle_flash.pixel_y = 4
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(45)
			muzzle_flash.pixel_x = 4
			muzzle_flash.pixel_y = 4
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(46 to 89)
			muzzle_flash.pixel_x = 4
			muzzle_flash.pixel_y = round(4 * ((90 - angle) / 45))
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(90)
			muzzle_flash.pixel_x = 4
			muzzle_flash.pixel_y = 0
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(91 to 134)
			muzzle_flash.pixel_x = 4
			muzzle_flash.pixel_y = round(-3 * ((angle - 90) / 45))
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(135)
			muzzle_flash.pixel_x = 4
			muzzle_flash.pixel_y = -3
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(136 to 179)
			muzzle_flash.pixel_x = round(4 * ((180 - angle) / 45))
			muzzle_flash.pixel_y = -3
			muzzle_flash.layer = ABOVE_MOB_LAYER
		if(180)
			muzzle_flash.pixel_x = 0
			muzzle_flash.pixel_y = -3
			muzzle_flash.layer = ABOVE_MOB_LAYER
		if(181 to 224)
			muzzle_flash.pixel_x = round(-3 * ((angle - 180) / 45))
			muzzle_flash.pixel_y = -3
			muzzle_flash.layer = ABOVE_MOB_LAYER
		if(225)
			muzzle_flash.pixel_x = -3
			muzzle_flash.pixel_y = -3
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(226 to 269)
			muzzle_flash.pixel_x = -3
			muzzle_flash.pixel_y = round(-3 * ((270 - angle) / 45))
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(270)
			muzzle_flash.pixel_x = -3
			muzzle_flash.pixel_y = 0
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(271 to 314)
			muzzle_flash.pixel_x = -3
			muzzle_flash.pixel_y = round(4 * ((angle - 270) / 45))
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(315)
			muzzle_flash.pixel_x = -3
			muzzle_flash.pixel_y = 4
			muzzle_flash.layer = initial(muzzle_flash.layer)
		if(316 to 359)
			muzzle_flash.pixel_x = round(-3 * ((360 - angle) / 45))
			muzzle_flash.pixel_y = 4
			muzzle_flash.layer = initial(muzzle_flash.layer)
	
	muzzle_flash.transform = null
	muzzle_flash.transform = turn(muzzle_flash.transform, angle)
	flash_loc.vis_contents += muzzle_flash
	muzzle_flash.applied = TRUE

	addtimer(CALLBACK(src, .proc/remove_muzzle_flash, flash_loc, muzzle_flash), 0.2 SECONDS)


/obj/item/weapon/gun/proc/remove_muzzle_flash(atom/movable/flash_loc, atom/movable/vis_obj/effect/muzzle_flash/muzzle_flash)
	if(!QDELETED(flash_loc))
		flash_loc.vis_contents -= muzzle_flash
	muzzle_flash.applied = FALSE


/obj/item/weapon/gun/on_enter_storage(obj/item/I)
	if(istype(I,/obj/item/storage/belt/gun))
		var/obj/item/storage/belt/gun/GB = I
		GB.holds_guns_now++ //Slide it in.
		if(!GB.current_gun)
			GB.current_gun = src //If there's no active gun, we want to make this our icon.
			GB.update_gun_icon()

/obj/item/weapon/gun/on_exit_storage(obj/item/I)
	if(istype(I,/obj/item/storage/belt/gun))
		var/obj/item/storage/belt/gun/GB = I
		GB.holds_guns_now--
		if(GB.current_gun == src)
			GB.current_gun = null
			GB.update_gun_icon()


/obj/item/weapon/gun/proc/on_gun_attachment_attach(obj/item/attachable/attached_gun/attaching)
	active_attachable = attaching
	if(!(attaching.flags_attach_features & ATTACH_WEAPON))
		return
	if(attaching.flags_attach_features & ATTACH_PROJECTILE)
		return //These are handled through regular Fire() for now.
	RegisterSignal(src, COMSIG_ITEM_CLICKCTRLON, .proc/do_fire_attachment) //For weapons with special projectiles not handled via Fire()


/obj/item/weapon/gun/proc/on_gun_attachment_detach(obj/item/attachable/attached_gun/detaching)
	active_attachable = null
	UnregisterSignal(src, COMSIG_ITEM_CLICKCTRLON)


/obj/item/weapon/gun/proc/do_fire_attachment(datum/source, atom/target, mob/user)
	if(!CHECK_BITFIELD(flags_item, WIELDED))
		return NONE //By default, let people CTRL+grab others if they are one-handing the weapon.
	. = COMPONENT_ITEM_CLICKCTRLON_INTERCEPTED
	if(!able_to_fire(user))
		return
	if(gun_on_cooldown(user))
		return
	if(active_attachable.current_rounds <= 0)
		click_empty(user) //If it's empty, let them know.
		to_chat(user, "<span class='warning'>[active_attachable] is empty!</span>")
		return
	if(!wielded_stable())
		to_chat(user, "<span class='warning'>[active_attachable] is not ready to fire!</span>")
		return
	active_attachable.fire_attachment(target, src, user) //Fire it.
	SEND_SIGNAL(user, COMSIG_HUMAN_ATTACHMENT_FIRED, target, active_attachable, user)
	last_fired = world.time
