/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'icons/obj/gun.dmi'
	icon_state = ""
	item_state = "gun"
	var/muzzle_flash 	= "muzzle_flash"
	matter = list("metal" = 75000)
	origin_tech = "combat=1" //Guns generally have their own unique levels.
	w_class 	= 3
	throwforce 	= 5
	throw_speed = 4
	throw_range = 5
	force 		= 5
	attack_verb = null
	icon_action_button = null //Adds it to the quick-icon list

	var/fire_sound 		= 'sound/weapons/Gunshot.ogg'
	var/unload_sound 	= 'sound/weapons/flipblade.ogg'
	var/empty_sound 	= 'sound/weapons/smg_empty_alarm.ogg'
	var/reload_sound 	= null //We don't want these for guns that don't have them.
	var/cocked_sound 	= null
	var/cock_cooldown	= 0 //world.time value, to prevent COCK COCK COCK COCK
	var/cock_delay		= 30 //Delay before we can cock again, in tenths of seconds

	//Ammo will be replaced on New() for things that do not use mags..
	var/datum/ammo/ammo = null //How the bullet will behave once it leaves the gun, also used for basic bullet damage and effects, etc.
	var/obj/item/projectile/in_chamber = null //What is currently in the chamber. Most guns will want something in the chamber upon creation.
	/*Ammo mags may or may not be internal, though the difference is a few additional variables. If they are not internal, don't call
	on those unique vars. This is done for quicker pathing. Just keep in mind most mags aren't internal, though some are.
	This is also the default magazine path loaded into a projectile weapon for reverse lookups on New(). Leave this null to do your own thing.*/
	var/obj/item/ammo_magazine/internal/current_mag = null
	var/type_of_casings = null //Can be "bullet", "shell", or "cartridge". Bullets are generic casings, shells are used by shotguns, cartridges are for rifles.

	//Basic stats.
	var/accuracy 		= 0  //Miltiplier. Increased and decreased through attachments. Multiplies the damage by this number.
	var/damage 			= 0  //Same as above.
	var/recoil 			= 0  //Screen shake when the weapon is fired.
	var/scatter			= 0  //How much the bullet scatters when fired.
	var/jamming			= 0	 //How often the gun jams.
	var/fire_delay 		= 0  //For regular shots, how long to wait before firing again.
	var/last_fired 		= 0  //When it was last fired, related to world.time.
	var/aim_slowdown	= 0  //Self explanatory. How much does aiming (wielding the gun) slow you

	//Burst fire.
	var/burst_amount 	= 0 //How many shots can the weapon shoot in burst? Anything less than 2 and you cannot toggle burst.
	var/burst_delay 	= 0 //The delay in between shots. Lower = less delay = faster.
	var/extra_delay 	= 0 //When burst-firing, this number is extra time before the weapon can fire again. Depends on number of rounds fired.

	//Targeting.
	var/tmp/list/mob/living/target //List of who yer targeting.
	var/tmp/mob/living/last_moved_mob //Used to fire faster at more than one person.
	var/tmp/lock_time 		= -100
	var/automatic 			= 0 //Used to determine if you can target multiple people.
	var/tmp/told_cant_shoot = 0 //So that it doesn't spam them with the fact they cannot hit them.
	var/firerate 			= 0 	//0 for keep shooting until aim is lowered
						//1 for one bullet after target moves and aim is lowered
	//Attachments.
	var/attachable_overlays[] 		= null //List of overlays so we can switch them in an out, instead of using Cut() on overlays.
	var/attachable_offset[] 		= null //Is a list, see examples of from the other files. Initiated on New() because lists don't initial() properly.
	var/attachable_allowed[]		= list() //Must be the exact path to the attachment present in the list. Empty list for a default.
	var/obj/item/attachable/muzzle 	= null //Attachable slots. Only one item per slot.
	var/obj/item/attachable/rail 	= null
	var/obj/item/attachable/under 	= null
	var/obj/item/attachable/stock 	= null
	var/obj/item/attachable/active_attachable = null //This will link to one of the above four, or remain null.

	flags_atom 			 = FPRINT|CONDUCT
	var/flags_gun_features = GUN_AUTO_EJECTOR|GUN_CAN_POINTBLANK


//----------------------------------------------------------
				//				    \\
				// NECESSARY PROCS  \\
				//					\\
				//					\\
//----------------------------------------------------------

	New(loc, spawn_empty) //You can pass on spawn_empty to make the sure the gun has no bullets or mag or anything when created.
		..()					//This only affects guns you can get from vendors for now. Special guns spawn with their own things regardless.
		attachable_overlays = list("muzzle", "rail", "under", "stock", "mag", "special")
		if(current_mag)
			if(spawn_empty && !ispath(current_mag, /obj/item/ammo_magazine/internal)) //Internal mags will still spawn, but they won't be filled.
				current_mag = null
				update_icon()
			else
				current_mag = new current_mag(src, spawn_empty? 1:0)
				ammo = current_mag.default_ammo ? ammo_list[current_mag.default_ammo] : ammo_list[/datum/ammo/bullet] //Latter should never happen, adding as a precaution.
		else ammo = ammo_list[ammo] //If they don't have a mag, they fire off their own thing.
		accuracy = config.base_hit_accuracy_mult
		damage = config.base_hit_damage_mult
		scatter = config.med_scatter_value
		fire_delay = config.mhigh_fire_delay
		burst_amount = config.min_burst_value
		update_force_list() //This gives the gun some unique verbs for attacking.

/obj/item/weapon/gun/Dispose()
	. = ..()
	in_chamber 		= null
	ammo 			= null
	current_mag 	= null
	target 			= null
	last_moved_mob 	= null
	muzzle 			= null
	if( (flags_gun_features & GUN_FLASHLIGHT_ON) && ismob(loc) ) loc.SetLuminosity(-rail.light_mod) //Handle flashlight.
	rail 			= null
	under 			= null
	stock 			= null
	attachable_overlays = null

/obj/item/weapon/gun/emp_act(severity)
	for(var/obj/O in contents)
		O.emp_act(severity)

/obj/item/weapon/gun/equipped(mob/user, slot)
	if(slot != WEAR_L_HAND && slot != WEAR_R_HAND)
		stop_aim()
		if (user.client)
			user.update_gun_icons()

	unwield(user)

	return ..()

/obj/item/weapon/gun/update_icon()
	icon_state = (!current_mag || current_mag.current_rounds <= 0) ? icon_state + "_e" : copytext(icon_state, 1, -2)
	update_mag_overlay()

/obj/item/weapon/gun/examine()
	..()
	if( !(flags_gun_features & GUN_UNUSUAL_DESIGN) ) //If they don't follow standard gun rules, all of this doesn't apply.

		var/dat = ""
		if(flags_gun_features & GUN_TRIGGER_SAFETY) dat += "The safety's on!<br>"

		if(rail) 	dat += "It has \icon[rail] [rail.name] mounted on the top.<br>"
		if(muzzle) 	dat += "It has \icon[muzzle] [muzzle.name] mounted on the front.<br>"
		if(under) 	dat += "It has \icon[under] [under.name] mounted underneath.<br>"
		if(stock) 	dat += "It has \icon[stock] [stock.name] for a stock.<br>"

		if(!istype(current_mag)) //Internal mags and the like have their own stuff set.
			if(current_mag && current_mag.current_rounds > 0)
				if(flags_gun_features & GUN_AMMO_COUNTER) dat += "Ammo counter shows [current_mag.current_rounds] round\s remaining.<br>"
				else 								dat += "It's loaded[in_chamber?" and has a round chambered":""].<br>"
			else 									dat += "It's unloaded[in_chamber?" but has a round chambered":""].<br>"
		usr << dat

/obj/item/weapon/gun/wield(var/mob/user)

	if(!(flags_atom & TWOHANDED) || flags_atom & WIELDED)
		return

	if(user.get_inactive_hand())
		user << "<span class='warning'>You need your other hand to be empty!</span>"
		return

	if(ishuman(user))
		var/check_hand = user.r_hand == src ? "l_hand" : "r_hand"
		var/mob/living/carbon/human/wielder = user
		var/datum/organ/external/hand = wielder.organs_by_name[check_hand]
		if(!istype(hand) || !hand.is_usable())
			user << "<span class='warning'>Your other hand can't hold \the [src]!</span>"
			return

	flags_atom 	   ^= WIELDED
	name 	   += " (Wielded)"
	item_state += "_w"
	slowdown = initial(slowdown) + aim_slowdown
	place_offhand(user, initial(name))
	return 1

/obj/item/weapon/gun/unwield(var/mob/user)

	if((flags_atom|TWOHANDED|WIELDED) != flags_atom)
		return //Have to be actually a twohander and wielded.
	flags_atom ^= WIELDED
	name 	    = copytext(name, 1, -10)
	item_state  = copytext(item_state, 1, -2)
	slowdown = initial(slowdown)
	remove_offhand(user)
	return 1

//----------------------------------------------------------
			//							        \\
			// LOADING, RELOADING, AND CASINGS  \\
			//							        \\
			//						   	        \\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/replace_ammo(mob/user = null, var/obj/item/ammo_magazine/magazine)
	if(!magazine.default_ammo)
		user << "Something went horribly wrong. Ahelp the following: ERROR CODE A1: null ammo while reloading."
		log_debug("ERROR CODE A1: null ammo while reloading. User: <b>[user]</b>")
		ammo = ammo_list[/datum/ammo/bullet] //Looks like we're defaulting it.
	else ammo = ammo_list[magazine.default_ammo]

//Hardcoded and horrible
/obj/item/weapon/gun/proc/cock_gun(mob/user)
	set waitfor = 0
	if(cocked_sound)
		sleep(3)
		if(user && loc) playsound(user, cocked_sound, 25, 1)

/*
Reload a gun using a magazine.
This sets all the initial datum's stuff. The bullet does the rest.
User can be passed as null, (a gun reloading itself for instance), so we need to watch for that constantly.
*/
/obj/item/weapon/gun/proc/reload(mob/user, obj/item/ammo_magazine/magazine)
	if((flags_gun_features|GUN_BURST_ON|GUN_BURST_FIRING) == flags_gun_features  || flags_gun_features & (GUN_UNUSUAL_DESIGN|GUN_INTERNAL_MAG) ) return

	if(!magazine || !istype(magazine))
		user << "<span class='warning'>That's not a magazine!</span>"
		return

	if(magazine.flags_magazine & AMMUNITION_HANDFUL)
		user << "<span class='warning'>[src] needs an actual magazine.</span>"
		return

	if(magazine.current_rounds <= 0)
		user << "<span class='warning'>[magazine] is empty!</span>"
		return

	if(!istype(src, magazine.gun_type))
		user << "<span class='warning'>That magazine doesn't fit in there!</span>"
		return

	if(!isnull(current_mag) && current_mag.loc == src)
		user << "<span class='warning'>It's still got something loaded.</span>"
		return



	if(user)
		if(magazine.reload_delay > 1)
			user << "<span class='notice'>You begin reloading [src]. Hold still...</span>"
			if(do_after(user,magazine.reload_delay, TRUE, 5, BUSY_ICON_CLOCK)) replace_magazine(user, magazine)
			else
				user << "<span class='warning'>Your reload was interrupted!</span>"
				return
		else replace_magazine(user, magazine)
	else
		current_mag = magazine
		magazine.loc = src
		replace_ammo(,magazine)
		if(!in_chamber) load_into_chamber()

	update_icon()
	return 1

/obj/item/weapon/gun/proc/replace_magazine(mob/user, obj/item/ammo_magazine/magazine)
	user.drop_inv_item_to_loc(magazine, src) //Click!
	current_mag = magazine
	replace_ammo(user,magazine)
	if(!in_chamber)
		ready_in_chamber()
		cock_gun(user)
	user.visible_message("<span class='notice'>[user] loads [magazine] into [src]!</span>",
	"<span class='notice'>You load [magazine] into [src]!</span>")
	if(reload_sound) playsound(user, reload_sound, 25, 1)


//Drop out the magazine. Keep the ammo type for next time so we don't need to replace it every time.
//This can be passed with a null user, so we need to check for that as well.
/obj/item/weapon/gun/proc/unload(mob/user, reload_override = 0, drop_override = 0) //Override for reloading mags after shooting, so it doesn't interrupt burst. Drop is for dropping the magazine on the ground.
	if(!reload_override && ((flags_gun_features|GUN_BURST_ON|GUN_BURST_FIRING) == flags_gun_features || flags_gun_features & (GUN_UNUSUAL_DESIGN|GUN_INTERNAL_MAG))) return

	if(!current_mag || isnull(current_mag) || current_mag.loc != src)
		cock(user)
		return

	if(drop_override || !user) //If we want to drop it on the ground or there's no user.
		current_mag.loc = get_turf(src) //Drop it on the ground.
	else user.put_in_hands(current_mag)

	playsound(user, unload_sound, 25, 1)
	user.visible_message("<span class='notice'>[user] unloads [current_mag] from [src].</span>",
	"<span class='notice'>You unload [current_mag] from [src].</span>")
	current_mag.update_icon()
	current_mag = null

	update_icon()

//Manually cock the gun
//This only works on weapons NOT marked with UNUSUAL_DESIGN or INTERNAL_MAG
/obj/item/weapon/gun/proc/cock(mob/user)

	if((flags_gun_features|GUN_BURST_ON|GUN_BURST_FIRING) == flags_gun_features || flags_gun_features & (GUN_UNUSUAL_DESIGN|GUN_INTERNAL_MAG)) return
	if(cock_cooldown > world.time) return

	cock_cooldown = world.time + cock_delay
	cock_gun(user)
	if(in_chamber)
		user.visible_message("<span class='notice'>[user] cocks [src], clearing a [in_chamber.name] from its chamber.</span>",
		"<span class='notice'>You cock [src], clearing a [in_chamber.name] from its chamber.</span>")
		make_casing(type_of_casings)
		in_chamber = null
	else
		user.visible_message("<span class='notice'>[user] cocks [src].</span>",
		"<span class='notice'>You cock [src].</span>")
	ready_in_chamber() //This will already check for everything else, loading the next bullet.

//Since reloading and casings are closely related, placing this here ~N
/obj/item/weapon/gun/proc/make_casing(casing_type) //Handle casings is set to discard them.
	if(casing_type)
		var/num_of_casings = (current_mag && current_mag.used_casings) ? current_mag.used_casings : 1
		var/sound_to_play = casing_type == "shell" ? 'sound/weapons/bulletcasing_shotgun_fall.ogg' : pick('sound/weapons/bulletcasing_fall2.ogg','sound/weapons/bulletcasing_fall.ogg')
		var/turf/current_turf = get_turf(src)
		var/new_casing = text2path("/obj/item/ammo_casing/[casing_type]")
		var/obj/item/ammo_casing/casing = locate(new_casing) in current_turf
		if(!casing) //No casing on the ground?
			casing = new new_casing(current_turf)
			num_of_casings--
			playsound(current_turf, sound_to_play, 25, 1) //Played again if necessary.
		if(num_of_casings) //Still have some.
			casing.current_casings += num_of_casings
			casing.update_icon()
			playsound(current_turf, sound_to_play, 25, 1)

//----------------------------------------------------------
			//							    \\
			// AFTER ATTACK AND CHAMBERING  \\
			//							    \\
			//						   	    \\
//----------------------------------------------------------

/obj/item/weapon/gun/afterattack(atom/A, mob/living/user, flag, params)
	if(flag)	return ..() //It's adjacent, is the user, or is on the user's person
	if(!istype(A)) return
	if((flags_gun_features|GUN_BURST_ON|GUN_BURST_FIRING) == flags_gun_features) return

	if(user && user.client && user.gun_mode && !(A in target)) PreFire(A,user,params) //They're using the new gun system, locate what they're aiming at.
	else															  Fire(A,user,params) //Otherwise, fire normally.

/*
load_into_chamber(), reload_into_chamber(), and clear_jam() do all of the heavy lifting.
If you need to change up how a gun fires, just change these procs for that subtype
and you're good to go.
*/
/obj/item/weapon/gun/proc/load_into_chamber(mob/user)
	//The workhorse of the bullet procs.
	//If it's something like a flashlight, we turn it off. If it's an actual fire and forget one, we need to keep going.
	if(active_attachable && (active_attachable.flags_attach_features & ATTACH_PASSIVE) ) active_attachable = null
 	//If we have a round chambered and no attachable, we're good to go.
	if(in_chamber && !active_attachable) return in_chamber //Already set!

	//Let's check on the active attachable. It loads ammo on the go, so it never chambers anything
	if(active_attachable)
		if(active_attachable.current_rounds > 0) //If it's still got ammo and stuff.
			active_attachable.current_rounds--
			return create_bullet(active_attachable.ammo)
		else
			user << "<span class='warning'>[active_attachable.name] is empty!</span>"
			active_attachable = null
	else return ready_in_chamber()//We're not using the active attachable, we must use the active mag if there is one.


/obj/item/weapon/gun/proc/ready_in_chamber()
	if(current_mag && current_mag.current_rounds > 0)
		in_chamber = create_bullet(ammo)
		current_mag.current_rounds-- //Subtract the round from the mag.
		return in_chamber

/obj/item/weapon/gun/proc/create_bullet(datum/ammo/chambered)
	if(!chambered)
		usr << "Something has gone horribly wrong. Ahelp the following: ERROR CODE I2: null ammo while create_bullet()"
		log_debug("ERROR CODE I2: null ammo while create_bullet(). User: <b>[usr]</b>")
		chambered = ammo_list[/datum/ammo/bullet] //Slap on a default bullet if somehow ammo wasn't passed.

	var/obj/item/projectile/P = rnew(/obj/item/projectile, src)
	P.generate_bullet(chambered)
	return P

//This proc is needed for firearms that chamber rounds after firing.
/obj/item/weapon/gun/proc/reload_into_chamber(mob/user)
	/*
	ATTACHMENT POST PROCESSING
	This should only apply to the masterkey, since it's the only attachment that shoots through Fire()
	instead of its own thing through fire_attachment(). If any other bullet attachments are added, they would fire here.
	*/
	if(active_attachable) make_casing(active_attachable.type_of_casings) // Attachables can drop their own casings.
	else
		make_casing(type_of_casings) // Drop a casing if needed.
		in_chamber = null //If we didn't fire from attachable, let's set this so the next pass doesn't think it still exists.

	if(!active_attachable) //We don't need to check for the mag if an attachment was used to shoot.
		if(current_mag) //If there is no mag, we can't reload.
			ready_in_chamber()
			if(current_mag.current_rounds <= 0 && flags_gun_features & GUN_AUTO_EJECTOR) // This is where the magazine is auto-ejected.
				unload(user,1,1) // We want to quickly autoeject the magazine. This proc does the rest based on magazine type. User can be passed as null.
				playsound(src, empty_sound, 25, 1)

	// Shouldn't be called on, but in case something that uses Fire() is added that is toggled.
	else if( !(active_attachable.flags_attach_features & ATTACH_CONTINUOUS) ) active_attachable = null // Set it to null for next activation. Again, this isn't really going to happen.
	return in_chamber //Returns the projectile if it's actually successful.

/obj/item/weapon/gun/proc/delete_bullet(var/obj/item/projectile/projectile_to_fire, var/refund = 0)
	if(active_attachable) //Attachables don't chamber rounds, so we want to delete it right away.
		cdel(projectile_to_fire) //Getting rid of it. Attachables only use ammo after the cycle is over.
		if(refund) active_attachable.current_rounds++ //Refund the bullet.
		return 1

/obj/item/weapon/gun/proc/clear_jam(var/obj/item/projectile/projectile_to_fire, mob/user as mob) //Guns jamming, great.
	flags_gun_features &= ~GUN_BURST_FIRING // Also want to turn off bursting, in case that was on. It probably was.
	delete_bullet(projectile_to_fire, 1) //We're going to clear up anything inside if we need to.
	//If it's a regular bullet, we're just going to keep it chambered.
	extra_delay = 2 + (burst_delay + extra_delay)*2 // Some extra delay before firing again.
	user << "<span class='warning'>[src] jammed! You'll need a second to get it fixed!</span>"

//----------------------------------------------------------
		//									   \\
		// FIRE BULLET AND POINT BLANK/SUICIDE \\
		//									   \\
		//						   			   \\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/Fire(atom/target, mob/living/user, params, reflex = 0)
	set waitfor = 0

	if(!able_to_fire(user)) return

	var/turf/curloc = get_turf(user) //In case the target or we are expired.
	var/turf/targloc = get_turf(target)
	if (!targloc || !curloc) return //Something has gone wrong...
	var/atom/original_target = target //This is for burst mode, in case the target changes per scatter chance in between fired bullets.

	/*
	This is where the grenade launcher and flame thrower function as attachments.
	This is also a general check to see if the attachment can fire in the first place.
	*/
	var/check_for_attachment_fire = 0
	if(active_attachable && !(active_attachable.flags_attach_features & ATTACH_PASSIVE) ) //Attachment activated and isn't a flashlight or something.
		check_for_attachment_fire = 1
		if( !(active_attachable.flags_attach_features & ATTACH_PROJECTILE) ) //If it's unique projectile, this is where we fire it.
			active_attachable.fire_attachment(target,src,user) //Fire it.
			if(active_attachable.current_rounds <= 0) click_empty(user) //If it's empty, let them know.
			active_attachable = null //Set it to null anyway, it's done.
			return
			//If there's more to the attachment, it will be processed farther down, through in_chamber and regular bullet act.

	/*
	This is where burst is established for the proceeding section. Which just means the proc loops around that many times.
	If burst = 1, you must null it if you ever RETURN during the for() cycle. If for whatever reason burst is left on while
	the gun is not firing, it will break a lot of stuff. BREAK is fine, as it will null it.
	*/

	//Number of bullets based on burst. If an active attachable is shooting, bursting is always zero.
	var/bullets_fired = 1
	if(!check_for_attachment_fire && flags_gun_features & GUN_BURST_ON && burst_amount > 1)
		bullets_fired = burst_amount
		flags_gun_features |= GUN_BURST_FIRING

	var/i
	for(i = 1 to bullets_fired)
		if(loc != user) break //If you drop it while bursting, for example.

		//The gun should return the bullet that it already loaded from the end cycle of the last Fire().
		var/obj/item/projectile/projectile_to_fire = load_into_chamber(user) //Load a bullet in or check for existing one.
		if(!projectile_to_fire) //If there is nothing to fire, click.
			click_empty(user)
			break

		apply_bullet_effects(projectile_to_fire, user, i, reflex) //User can be passed as null.

		//BIPODS BEGINS HERE
		var/recoil_comp = 0 //If we're using a bipod properly, this will change.
		var/scatter_chance_mod = 0
		//They decrease scatter chance and increase accuracy a tad. Can also increase damage.
		if(user && under && under.firing_support) //Let's get to work on the bipod. I'm not really concerned if they are the same person as the previous user. It doesn't matter.
			if(under.check_position(src, user))
				//Passive accuracy and recoil buff, but only when firing in position.
				projectile_to_fire.accuracy *= config.base_hit_accuracy_mult + config.hmed_hit_accuracy_mult //More accuracy.
				recoil_comp-- //Less recoil.
				if(prob(65)) scatter_chance_mod -= config.med_scatter_value
				if(prob(30)) projectile_to_fire.damage *= config.base_hit_damage_mult + config.low_hit_damage_mult//Lower chance of a damage buff.
				if(i == 1) user << "<span class='notice'>Your bipod keeps [src] steady!</span>"
		//End of bipods.

		target = original_target ? original_target : targloc
		target = simulate_scatter(projectile_to_fire, target, targloc, scatter_chance_mod)

		if(params)
			var/list/mouse_control = params2list(params)
			if(mouse_control["icon-x"])
				projectile_to_fire.p_x = text2num(mouse_control["icon-x"])
			if(mouse_control["icon-y"])
				projectile_to_fire.p_y = text2num(mouse_control["icon-y"])

		//Finally, make with the pew pew!
		if(!projectile_to_fire || !istype(projectile_to_fire,/obj))
			user << "Your gun is malfunctioning. Ahelp the following: ERROR CODE I1: projectile malfunctioned while firing."
			log_debug("ERROR CODE I1: projectile malfunctioned while firing. User: <b>[user]</b>")
			flags_gun_features &= ~GUN_BURST_FIRING
			return

		if(get_turf(target) != get_turf(user))
			simulate_recoil(recoil+recoil_comp, user, target)

			//This is where the projectile leaves the barrel and deals with projectile code only.
			//vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
			projectile_to_fire.fire_at(target,user,src,projectile_to_fire.ammo.max_range,projectile_to_fire.ammo.shell_speed)
			//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

		else // This happens in very rare circumstances when you're moving a lot while burst firing, so I'm going to toss it up to guns jamming.
			clear_jam(projectile_to_fire,user)
			break

		//>>POST PROCESSING AND CLEANUP BEGIN HERE.<<
		if(target) //If we had a target, let's do a muzzle flash.
			var/angle = round(Get_Angle(user,target))
			muzzle_flash(angle,user)

		//This is where we load the next bullet in the chamber. We check for attachments too, since we don't want to load anything if an attachment is active.
		if(!reload_into_chamber(user)) // It has to return a bullet, otherwise it's empty.
			click_empty(user)
			break //Nothing else to do here, time to cancel out.

		if(i < bullets_fired) // We still have some bullets to fire.
			extra_delay = min(extra_delay+(burst_delay*2), fire_delay*3) // The more bullets you shoot, the more delay there is, but no more than thrice the regular delay.
			sleep(burst_delay)

	flags_gun_features &= ~GUN_BURST_FIRING // We always want to turn off bursting when we're done.

/obj/item/weapon/gun/attack(mob/living/M, mob/living/user, def_zone)
	if(flags_gun_features & GUN_CAN_POINTBLANK) // If it can't point blank, you can't suicide and such.
		if(M == user && user.zone_selected == "mouth")
			if(able_to_fire(user))
				flags_gun_features ^= GUN_CAN_POINTBLANK //If they try to click again, they're going to hit themselves.
				M.visible_message("<span class='warning'>[user] sticks their gun in their mouth, ready to pull the trigger.</span>")
				if(do_after(user, 40, TRUE, 5, BUSY_ICON_CLOCK))
					if(active_attachable && !(active_attachable.flags_attach_features & ATTACH_PROJECTILE))
						active_attachable = null //We're not firing off a nade into our mouth.
					var/obj/item/projectile/projectile_to_fire = load_into_chamber(user)
					if(projectile_to_fire) //We actually have a projectile, let's move on.
						user.visible_message("<span class = 'warning'>[user] pulls the trigger!</span>")
						var/actual_sound = (active_attachable && active_attachable.fire_sound) ? active_attachable.fire_sound : fire_sound
						var/sound_volume = (flags_gun_features & GUN_SILENCED && !active_attachable) ? 25 : 125
						playsound(user, actual_sound, sound_volume, 1)
						simulate_recoil(recoil + 2, user)
						var/obj/item/weapon/gun/revolver/current_revolver = src
						var/t = "\[[time_stamp()]\] <b>[user]/[user.ckey]</b> committed suicide with <b>[src]</b>" //Log it.
						if(istype(current_revolver) && current_revolver.russian_roulette) //If it's a revolver set to Russian Roulette.
							t += " after playing Russian Roulette"
							user.apply_damage(projectile_to_fire.damage * 3, projectile_to_fire.ammo.damage_type, "head", used_weapon = "An unlucky pull of the trigger during Russian Roulette!", sharp = 1)
							user.apply_damage(200, OXY) //In case someone tried to defib them. Won't work.
							user.death()
							user << "<span class='highdanger'>Your life flashes before you as your spirit is torn from your body!</span>"
							user.ghostize(0) //No return.
						else
							if(projectile_to_fire.ammo.damage_type == HALLOSS)
								user << "<span class = 'notice'>Ow...</span>"
								user.apply_effect(110, AGONY, 0)
							else
								user.apply_damage(projectile_to_fire.damage * 2.5, projectile_to_fire.ammo.damage_type, "head", used_weapon = "Point blank shot in the mouth with \a [projectile_to_fire]", sharp = 1)
								user.apply_damage(100, OXY)
								user.death()
						user.attack_log += t //Apply the attack log.

						projectile_to_fire.play_damage_effect(user)
						if(!delete_bullet(projectile_to_fire)) cdel(projectile_to_fire) //If this proc DIDN'T delete the bullet, we're going to do so here.

						reload_into_chamber(user) //Reload the sucker.

					else click_empty(user)//If there's no projectile, we can't do much.
				else M.visible_message("<span class='notice'>[user] decided life was worth living.</span>")
				flags_gun_features ^= GUN_CAN_POINTBLANK //Reset this.
			return

		else if(user.a_intent == "hurt") //Point blanking doesn't actually fire the projectile. No reason to.
			flags_gun_features &= ~GUN_BURST_FIRING
			//Point blanking simulates firing the bullet proper but without actually firing it.
			if(able_to_fire(user)) //If you can't fire the gun in the first place, we're just going to hit them with it.
				if(active_attachable && !(active_attachable.flags_attach_features & ATTACH_PROJECTILE)) active_attachable = null//No way.
				var/obj/item/projectile/projectile_to_fire = load_into_chamber(user)
				if(projectile_to_fire) //We actually have a projectile, let's move on. We're going to simulate the fire cycle.
					projectile_to_fire.damage *= (config.base_hit_damage_mult+config.low_hit_damage_mult) //Multiply the damage for point blank.
					user.visible_message("<span class='danger'>[user] fires [src] point blank at [M]!</span>")
					apply_bullet_effects(projectile_to_fire, user) //We add any damage effects that we need.
					simulate_recoil(recoil+1, user)

					projectile_to_fire.ammo.on_hit_mob(M,projectile_to_fire)
					M.bullet_act(projectile_to_fire)

					if(!delete_bullet(projectile_to_fire)) cdel(projectile_to_fire)
					reload_into_chamber(user) //Reload into the chamber if the gun supports it.
				else
					click_empty(user) //We want to return here, since they're trying to point blank them, not hit them with the gun.
				return
	return ..() //Pistolwhippin'

//----------------------------------------------------------
				//							\\
				// FIRE CYCLE RELATED PROCS \\
				//							\\
				//						   	\\
//----------------------------------------------------------

/obj/item/weapon/gun/proc/able_to_fire(mob/user)
	/*
	Removed ishuman() check. There is no reason for it, as it just eats up more processing, and adding fingerprints during the fire cycle is silly.
	Consequently, predators are able to fire while cloaked.
	*/
	if((flags_gun_features|GUN_BURST_ON|GUN_BURST_FIRING) == flags_gun_features) return
	if(ismob(user)) //Could be an object firing the gun.
		if(!user.IsAdvancedToolUser())
			user << "<span class='warning'>You don't have the dexterity to do this!</span>"
			return

		if(flags_gun_features & GUN_TRIGGER_SAFETY)
			user << "<span class='warning'>The safety is on!</span>"
			return

		if(flags_atom & TWOHANDED) //If we're not holding the weapon with both hands when we should.
			var/obj/item/weapon/twohanded/offhand/O = user.get_inactive_hand() //We have to check for this though, since the offhand can drop due to arm malfs, etc.
			if(!istype(O))
				unwield(user)
				user << "<span class='warning'>You need a more secure grip to fire this weapon!"
				return

		if( (flags_gun_features & GUN_WY_RESTRICTED) && !wy_allowed_check(user) ) return

		//Has to be on the bottom of the stack to prevent delay when failing to fire the weapon for the first time.
		//Can also set last_fired through New(), but honestly there's not much point to it.
		if(world.time >= last_fired + max(0, fire_delay) + extra_delay) //If not, check the last time it was fired.
			extra_delay = 0
			last_fired = world.time
		else
			if (world.time % 3) user << "<span class='warning'>[src] is not ready to fire again!</span>" //to prevent spam
			return
	return 1

/obj/item/weapon/gun/proc/click_empty(mob/user)
	if(user)
		user.visible_message("*click click*", "<span class='warning'><b>*click*</b></span>")
		playsound(user, 'sound/weapons/gun_empty.ogg', 25, 1)
	else
		visible_message("*click click*")
		playsound(src, 'sound/weapons/gun_empty.ogg', 25, 1)

//This proc applies some bonus effects to the shot/makes the message when a bullet is actually fired.
/obj/item/weapon/gun/proc/apply_bullet_effects(obj/item/projectile/projectile_to_fire, mob/user, i = 1, reflex = 0)
	var/actual_sound = fire_sound
	var/sound_volume = flags_gun_features & GUN_SILENCED ? 25 : 75
	projectile_to_fire.accuracy = round(projectile_to_fire.accuracy * accuracy) //We're going to throw in the gun's accuracy.
	projectile_to_fire.damage 	= round(projectile_to_fire.damage * damage) 	//And then multiply the damage.
	projectile_to_fire.shot_from = src

	if(active_attachable && !(active_attachable.flags_attach_features & ATTACH_PASSIVE))
		if(active_attachable.fire_sound) actual_sound = active_attachable.fire_sound //If we're firing from an attachment, use that noise instead.
		sound_volume = 50 //Since we're using an attachable, the silencer doesn't matter.

	if(user) //The gun only messages when fired by a user.
		projectile_to_fire.firer = user
		if(isliving(user)) projectile_to_fire.def_zone = user.zone_selected
		projectile_to_fire.dir = user.dir
		playsound(user, actual_sound, sound_volume)
		if(i == 1)
			if(!(flags_gun_features & GUN_SILENCED))
				user.visible_message(
				"<span class='danger'>[user] fires [src][reflex ? " by reflex":""]!</span>", \
				"<span class='warning'>You fire [src][reflex ? "by reflex":""]! [flags_gun_features & GUN_AMMO_COUNTER && current_mag ? "<B>[current_mag.current_rounds-1]</b>/[current_mag.max_rounds]" : ""]</span>", \
				"<span class='warning'>You hear a [istype(projectile_to_fire.ammo, /datum/ammo/bullet) ? "gunshot" : "blast"]!</span>"
				)
			else
				user << "<span class='warning'>You fire [src][reflex ? "by reflex":""]! [flags_gun_features & GUN_AMMO_COUNTER && current_mag ? "<B>[current_mag.current_rounds-1]</b>/[current_mag.max_rounds]" : ""]</span>"
	return 1

/obj/item/weapon/gun/proc/simulate_scatter(obj/item/projectile/projectile_to_fire, atom/target, turf/targloc, total_scatter_chance = 0)
	total_scatter_chance += (scatter + projectile_to_fire.ammo.scatter)
	//Not if the gun doesn't scatter at all, or negative scatter.
	if(total_scatter_chance > 0 && ( prob(5) || (flags_gun_features & GUN_BURST_ON && burst_amount > 1) ) ) //Only 5% chance to scatter, and then still unlikely on single fire.
		total_scatter_chance += (burst_amount * 3) //Much higher chance on a burst.

		if(prob(total_scatter_chance)) //Scattered!
			var/scatter_x = rand(-1,1)
			var/scatter_y = rand(-1,1)
			var/turf/new_target = locate(targloc.x + round(scatter_x),targloc.y + round(scatter_y),targloc.z) //Locate an adjacent turf.
			if(new_target) target = new_target//Looks like we found a turf.

	projectile_to_fire.original = target
	return target

/obj/item/weapon/gun/proc/simulate_recoil(total_recoil = 0, mob/user, atom/target)
	if(total_recoil > 0 && ishuman(user))
		shake_camera(user, total_recoil + 1, total_recoil)
		return 1

/obj/item/weapon/gun/proc/muzzle_flash(angle,mob/user)
	if(!muzzle_flash || flags_gun_features & GUN_SILENCED || isnull(angle)) return //We have to check for null angle here, as 0 can also be an angle.
	if(!istype(user) || !istype(user.loc,/turf)) return
	if(prob(65)) //Not all the time.
		var/image_layer = (user && user.dir == SOUTH) ? MOB_LAYER+0.1 : MOB_LAYER-0.1
		var/image/reusable/I = rnew(/image/reusable, list('icons/obj/projectiles.dmi',user,muzzle_flash,image_layer))
		var/matrix/rotate = matrix() //Change the flash angle.
		rotate.Translate(0,5)
		rotate.Turn(angle)
		I.transform = rotate

		I.flick_overlay(user, 3)
