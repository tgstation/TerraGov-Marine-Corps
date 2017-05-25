
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

Defined in setup.dm.
#define ATTACH_PASSIVE		1
#define ATTACH_REMOVABLE	2
#define ATTACH_CONTINUOUS	4
#define ATTACH_ACTIVATION	8
#define ATTACH_PROJECTILE	16
*/

/obj/item/attachable
	name = "attachable item"
	desc = "It's an attachment. You should never see this."
	icon = 'icons/Marine/marine-weapons.dmi'
	icon_state = null
	item_state = null
	var/pixel_shift_x = 16 //Determines the amount of pixels to move the icon state for the overlay.
	var/pixel_shift_y = 16 //Uses the bottom left corner of the item.

	flags_atom =  FPRINT|CONDUCT
	matter = list("metal" = 2000)
	w_class = 2.0
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
	var/damage_mod 		= 0 //Modifer to the damage mult, same as above.
	var/melee_mod 		= 0 //Changing to a flat number so this actually doesn't screw up the calculations.
	var/w_class_mod 	= 0 //Modifier to weapon's weight class.
	var/scatter_mod 	= 0 //Increases or decreases scatter chance.
	var/recoil_mod 		= 0 //If positive, adds recoil, if negative, lowers it. Recoil can't go below 0.
	var/silence_mod 	= 0 //Adds silenced to weapon
	var/light_mod 		= 0 //Adds an x-brightness flashlight to the weapon, which can be toggled on and off.
	var/delay_mod 		= 0 //Changes firing delay. Cannot go below 0.
	var/burst_mod 		= 0 //Changes burst rate. 1 == 0.
	var/size_mod 		= 0 //Increases the weight class.
	var/aim_speed_mod	= 0 //Changes the aiming speed slowdown of the wearer by this value.

	//This is a special case.
	var/twohanded_mod 	= 0 //If 1, removes two handed, if 2, adds two-handed.

	/*
	This is where activation begins. Attachments that activate can be passive (like a scope),
	or they can be active like a shotgun or grenade launcher. Attachments may be continuous,
	or they fire so long as you can activate them, or single fire. That is where they deactivate
	after one pass.
	*/
	var/activation_sound = 'sound/machines/click.ogg'
	var/fire_sound = null //Sound to play when firing it alternately

	//These are bipod specifics, but they function well enough in other scenarios if needed.
	var/obj/structure/firing_support = null //Used by the bipod/other support to see if the gun can fire better.
	var/turf/firing_turf = null //I don't really need to make these null, but it helps to differentiate.
	var/firing_direction //What direction the user must be facing to get the bonus.
	var/firing_flipped 	= 2 //Default is 2, 0 means the table isn't flipped. 1 means it is. 2 means it's not a table so we don't care.

	//Some attachments may be fired. So here are the variables related to that.
	var/datum/ammo/ammo = null //If it has a default bullet-like ammo.
	var/current_rounds 	= 0 //How much it has.
	var/max_rounds 		= 0 //How much ammo it can store
	var/max_range 		= 0 //Determines # of tiles distance the attachable can fire, if it's not a projectile.
	var/type_of_casings = null

	var/flags_attach_features = ATTACH_PASSIVE|ATTACH_REMOVABLE


	New() //Let's make sure if something needs an ammo type, it spawns with one.
		..()
		if(ammo) ammo = ammo_list[ammo]

	Dispose()
		. = ..()
		ammo = null
		firing_support = null
		firing_turf = null

/obj/item/attachable/proc/Attach(obj/item/weapon/gun/G)
	if(!istype(G)) return //Guns only

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
			if(G.rail) G.rail.Detach(G)
			G.rail = src
		if("muzzle")
			if(G.muzzle) G.muzzle.Detach(G)
			G.muzzle = src
		if("under")
			if(G.under) G.under.Detach(G)
			G.under = src
		if("stock")
			if(G.stock) G.stock.Detach(G)
			G.stock = src

	if(ishuman(loc))
		var/mob/living/carbon/human/M = src.loc
		M.drop_held_item(src)
	forceMove(G)

	G.accuracy 			+= accuracy_mod
	G.damage			+= damage_mod
	G.w_class 			+= w_class_mod
	G.scatter			+= scatter_mod
	G.fire_delay 		+= delay_mod
	G.burst_amount 		+= burst_mod
	G.recoil 			+= recoil_mod
	G.force 			+= melee_mod
	G.aim_slowdown		+= aim_speed_mod

	if(G.burst_amount <= 1) G.flags_gun_features &= ~GUN_BURST_ON //Remove burst if they can no longer use it.
	G.update_force_list() //This updates the gun to use proper force verbs.

	switch(twohanded_mod)
		if(1) G.flags_atom |= TWOHANDED //Add two handed flag.
		if(2) G.flags_atom &= ~TWOHANDED //Remove two handed flag.

	if(silence_mod)
		G.flags_gun_features |= GUN_SILENCED
		G.muzzle_flash = null
		G.fire_sound = "gun_silenced"

/obj/item/attachable/proc/Detach(obj/item/weapon/gun/G)
	if(!istype(G)) return //Guns only

	switch(slot) //I am removing checks for the attachment being src.
		if("rail") 		G.rail = null//If it's being called on by this proc, it has to be that attachment. ~N
		if("muzzle") 	G.muzzle = null
		if("under")
			var/obj/item/attachable/bipod/current_bipod = G.under
			if(istype(current_bipod))
				current_bipod.leave_position()
			G.under = null
		if("stock")		G.stock = null


	if(G.active_attachable == src) G.active_attachable = null

	G.accuracy 			-= accuracy_mod
	G.damage			-= damage_mod
	G.w_class 			-= w_class_mod
	G.scatter			-= scatter_mod
	G.fire_delay 		-= delay_mod
	G.burst_amount		-= burst_mod
	G.recoil 			-= recoil_mod
	G.force 			-= melee_mod
	G.aim_slowdown		-= aim_speed_mod

	G.update_force_list()

	//We need to know if the gun was originally two handed.
	var/temp_flags = initial(G.flags_atom)
	switch(twohanded_mod) //Not as quick as just initial()ing it, but pretty fast regardless.
		if(1) //We added the two handed mod.
			if( !(temp_flags & TWOHANDED) ) G.flags_atom &= ~TWOHANDED//Gun wasn't two handed initially.
		if(2) //We removed the two handed mod.
			if(temp_flags & TWOHANDED) G.flags_atom |= TWOHANDED //Gun was two handed before.

	if(silence_mod) //Built in silencers always come as an attach, so the gun can't be silenced right off the bat.
		G.flags_gun_features &= ~GUN_SILENCED
		G.muzzle_flash = initial(G.muzzle_flash)
		G.fire_sound = initial(G.fire_sound)
	if(light_mod)  //Remember to turn the lights off
		if(G.flags_gun_features & GUN_FLASHLIGHT_ON)
			var/atom/movable/light_source = ismob(G.loc) ? G.loc : G
			light_source.SetLuminosity(-light_mod)
		G.flags_gun_features &= ~GUN_FLASHLIGHT_ON

	loc = get_turf(G)

/obj/item/attachable/proc/activate_attachment(atom/target, mob/user) //This is for activating stuff like flamethrowers, or switching weapon modes.
	return

/obj/item/attachable/proc/fire_attachment(atom/target,obj/item/weapon/gun/gun, mob/user) //For actually shooting those guns.
	return

/obj/item/attachable/proc/get_into_position(mob/living/user, obj/structure/support_structure, turf/active_turf, flipped = 2)
	user << "<span class='notice'>You find a good location to place the bipod near [support_structure]! You can fire your gun steady so long as you remain here.</span>"
	firing_support = support_structure
	firing_turf = active_turf
	firing_direction = user.dir
	firing_flipped = flipped

/obj/item/attachable/proc/leave_position(mob/living/user)
	firing_support = null
	firing_turf = null
	firing_direction = null
	firing_flipped = 2
	if(user) user << "<span class='notice'>You get ready to find another firing position.</span>"

/obj/item/attachable/proc/establish_position(obj/item/weapon/gun, mob/living/user)
	var/turf/active_turf = get_turf(src)
	if(!active_turf) return

	//Define our basic structures to type check for later.
	var/obj/structure/support_structure //Something basic we're going to look for.
	var/obj/structure/table/support_table //In case it's a table, which complicates matters.
	var/obj/structure/barricade/support_barricade //In case it's a barricade.

	for(var/obj/Q in active_turf) //We're going to check the turf we're on first.
		support_structure = Q
		if(!istype(support_structure)) continue //Not a structure.
		if(support_structure.throwpass) //Can we throw over it? If so, this is what we want.
			support_table = Q
			if(istype(support_table)) //Is it a table?
				//If it's flipped and we are facing the right direction. Or it's not flipped.
				if( !support_table.flipped || (support_table.flipped && support_table.dir == user.dir) )
					get_into_position(user, support_table, active_turf, support_table.flipped)
					return 1
				else continue //It's a table flipped, but it's not facing our way.
			support_barricade = Q
			//We're on something, its direction doesn't matter unless it's a border structure.
			if( (!(support_barricade.flags_atom & ON_BORDER) || support_barricade.dir == user.dir))
				get_into_position(user, support_structure, active_turf)
				return 1

	//Second part of the proc.
	var/turf/inactive_turf //We didn't find anything out our turf, so now we look through the adjacent turf.
	switch(user.dir)
		if(1) inactive_turf = locate(active_turf.x,active_turf.y+1,active_turf.z)
		if(2) inactive_turf = locate(active_turf.x,active_turf.y-1,active_turf.z)
		if(4) inactive_turf = locate(active_turf.x+1,active_turf.y,active_turf.z)
		if(8) inactive_turf = locate(active_turf.x-1,active_turf.y,active_turf.z)

	if(!inactive_turf) return //We didn't find an adjacent turf somehow.
	for(var/obj/Q  in inactive_turf)
		support_structure = Q
		if(!istype(support_structure)) continue
		if(support_structure.throwpass) //We have the right kind of structure.
			support_barricade = Q
			if(istype(support_barricade)) continue //We don't care about metal barricades.
			support_table = Q
			if(istype(support_table)) //If it's a table, we need to determine a few things.
				if(support_table.flipped) continue //We don't care about flipped tables.
				else get_into_position(user, support_table, active_turf, support_table.flipped)
			else //Not a table but still fits the criteria? Okay.
				get_into_position(user, support_structure, active_turf)
			return 1

/obj/item/attachable/proc/check_position(obj/item/weapon/gun, mob/living/user)
	if(firing_turf == user.loc && firing_direction == user.dir) //We're in business.
		var/obj/structure/table/support_table
		var/obj/structure/barricade/support_barricade
		switch(firing_flipped)
			if(0) //It's a table, and it wasn't flipped when we got into position.
				support_table = firing_support
				if(support_table.flipped) //It was flipped.
					leave_position()
					return
			if(1) //has to be either a flipped table or metal barricade.
				support_table = firing_support
				support_barricade = firing_support
				if(istype(support_table)) //It is a table.
					if(!support_table.flipped || support_table.dir != user.dir) //Either it was flipped or directions don't match.
						leave_position()
						return
				else if(support_barricade.flags_atom & ON_BORDER) //It is a border structure.
					if(support_barricade.dir != user.dir) //Directions don't match.
						leave_position()
						return
		return 1 //If the no cases are out, we're good to go.
	leave_position(user) //Looks like we haven't returned yet, so it's time to leave the position.

/obj/item/attachable/suppressor
	name = "suppressor"
	desc = "A small tube with exhaust ports to expel noise and gas.\nDoes not completely silence a weapon, but does make it much quieter and a little more accurate and stable at the cost of slightly reduced damage."
	icon_state = "suppressor"
	slot = "muzzle"
	silence_mod = 1
	pixel_shift_y = 16

	New()
		..()
		accuracy_mod = config.min_hit_accuracy_mult
		damage_mod = -config.min_hit_damage_mult
		recoil_mod = -config.min_recoil_value
		scatter_mod = -config.min_scatter_value
		icon_state = pick("suppressor","suppressor2")

/obj/item/attachable/bayonet
	name = "bayonet"
	desc = "A sharp blade for mounting on a weapon. It can be used to stab manually on anything but harm intent."
	icon_state = "bayonet"
	force = 20
	throwforce = 10
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	melee_mod = 20 //35 for a rifle, comparable to 37 before. 40 with the stock, comparable to 42.
	slot = "muzzle"

	attackby(obj/item/I as obj, mob/user as mob)
		if(istype(I,/obj/item/weapon/screwdriver))
			user << "<span class='notice'>You modify the bayonet back into a combat knife.</span>"
			if(src.loc == user)
				user.drop_inv_item_on_ground(src)
			var/obj/item/weapon/combat_knife/F = new(src.loc)
			user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
			if(F.loc != user) //It ended up on the floor, put it whereever the old flashlight is.
				F.loc = src.loc
			cdel(src) //Delete da old bayonet
		else
			..()
	pixel_shift_x = 14 //Bellow the muzzle.
	pixel_shift_y = 18

	New()
		..()
		accuracy_mod = -config.min_hit_accuracy_mult

/obj/item/attachable/reddot
	name = "red-dot sight"
	desc = "A red-dot sight for short to medium range. Does not have a zoom feature, but does increase weapon accuracy by a good amount. \nNo drawbacks."
	icon_state = "reddot"
	slot = "rail"

	New()
		..()
		accuracy_mod = config.med_hit_accuracy_mult

/obj/item/attachable/foregrip
	name = "forward grip"
	desc = "A custom-built improved foregrip for better accuracy, less recoil, and less scatter. \nHowever, it also changes the weapon to two-handed and increases weapon size."
	icon_state = "sparemag"
	twohanded_mod = 1
	w_class_mod = 1
	slot = "under"
	pixel_shift_x = 20

	New()
		..()
		accuracy_mod = config.min_hit_accuracy_mult
		recoil_mod = -config.min_recoil_value
		scatter_mod = -config.min_scatter_value

/obj/item/attachable/gyro
	name = "gyroscopic stabilizer"
	desc = "A set of weights and balances to allow a two handed weapon to be fired with one hand. \nSomewhat reduces accuracy and increases scatter, however."
	icon_state = "gyro"
	twohanded_mod = 2
	slot = "under"

	New()
		..()
		accuracy_mod = -config.low_hit_accuracy_mult
		recoil_mod = config.min_recoil_value
		scatter_mod = config.min_scatter_value

/obj/item/attachable/flashlight
	name = "rail flashlight"
	desc = "A simple flashlight used for mounting on a firearm. \nHas no drawbacks, but isn't particuraly useful outside of providing a light source."
	icon_state = "flashlight"
	light_mod = 7
	slot = "rail"
	flags_attach_features = ATTACH_PASSIVE|ATTACH_REMOVABLE
	icon_action_button = 1
	action_button_name = "Toggle Rail Flashlight"

	activate_attachment(obj/item/weapon/gun/target,mob/living/user)
		if(target)
			var/flashlight_on = (target.flags_gun_features & GUN_FLASHLIGHT_ON) ? -1 : 1
			var/atom/movable/light_source =  user ? user : target
			light_source.SetLuminosity(light_mod * flashlight_on)
			target.flags_gun_features ^= GUN_FLASHLIGHT_ON
			target.update_attachable(slot)

	attackby(obj/item/I, mob/user)
		if(istype(I,/obj/item/weapon/screwdriver))
			user << "<span class='notice'>You modify the rail flashlight back into a normal flashlight.</span>"
			if(loc == user)
				user.temp_drop_inv_item(src)
			var/obj/item/device/flashlight/F = new(user)
			user.put_in_hands(F) //This proc tries right, left, then drops it all-in-one.
			cdel(src) //Delete da old flashlight
		else
			..()

/obj/item/attachable/bipod
	name = "bipod"
	desc = "A simple set of telescopic poles to keep a weapon stabilized during firing. \nGreatly increases accuracy and reduces recoil when properly placed, but also increases weapon size and slows firing speed."
	icon_state = "bipod"
	slot = "under"
	w_class_mod = 2
	melee_mod = -10

	flags_attach_features = ATTACH_PASSIVE|ATTACH_REMOVABLE|ATTACH_ACTIVATION

	New()
		..()
		delay_mod = config.min_fire_delay

	activate_attachment(obj/item/weapon/gun/target,mob/living/user)
		if(firing_support) //Let's see if we can find one.
			if(!check_position(target,user)) return 1//Our positions didn't match, so we're canceling and notifying the user.
		else
			if(establish_position(target,user)) return 1//We successfully established a position and are backing out.

/obj/item/attachable/extended_barrel
	name = "extended barrel"
	desc = "A lengthened barrel allows for greater accuracy, particularly at long range.\nHowever, natural resistance also slows the bullet, leading to slightly reduced damage."
	slot = "muzzle"
	icon_state = "ebarrel"

	New()
		..()
		accuracy_mod = config.hmed_hit_accuracy_mult
		damage_mod = -config.min_hit_damage_mult

/obj/item/attachable/heavy_barrel
	name = "barrel charger"
	desc = "A fitted barrel extender that goes on the muzzle, with a small shaped charge that propels a bullet much faster.\nGreatly increases projectile damage at the cost of accuracy and firing speed."
	slot = "muzzle"
	icon_state = "hbarrel"

	New()
		..()
		accuracy_mod = -config.hmed_hit_accuracy_mult
		damage_mod = config.hmed_hit_damage_mult
		delay_mod = config.low_fire_delay

/obj/item/attachable/quickfire
	name = "quickfire adapter"
	desc = "An enhanced and upgraded autoloading mechanism to fire rounds more quickly. \nHowever, it also reduces accuracy and the number of bullets fired on burst."
	slot = "rail"
	icon_state = "autoloader"

	New()
		..()
		accuracy_mod = -config.med_hit_accuracy_mult
		scatter_mod = config.med_scatter_value
		delay_mod = -config.mlow_fire_delay
		burst_mod = -config.min_burst_value

/obj/item/attachable/compensator
	name = "recoil compensator"
	desc = "A muzzle attachment that reduces recoil by diverting expelled gasses upwards. \nIncreases accuracy and reduces recoil, at the cost of a small amount of weapon damage."
	slot = "muzzle"
	icon_state = "comp"
	pixel_shift_x = 17

	New()
		..()
		accuracy_mod = config.med_hit_accuracy_mult
		damage_mod = -config.low_hit_damage_mult
		recoil_mod = -config.med_recoil_value

/obj/item/attachable/burstfire_assembly
	name = "burst fire assembly"
	desc = "A mechanism re-assembly kit that allows for automatic fire, or more shots per burst if the weapon already has the ability. \nJust don't mind the increased scatter."
	icon_state = "rapidfire"
	slot = "under"

	New()
		..()
		accuracy_mod = -config.low_hit_accuracy_mult
		burst_mod = config.low_burst_value
		scatter_mod = config.low_scatter_value

/obj/item/attachable/magnetic_harness
	name = "magnetic harness"
	desc = "A magnetically attached harness kit that attaches to the rail mount of a weapon. When dropped, the weapon will sling to a USCM armor."
	icon_state = "magnetic"
	slot = "rail"
	pixel_shift_x = 13

	New()
		..()
		accuracy_mod = -config.min_hit_accuracy_mult

/obj/item/attachable/stock //Generic stock parent and related things.
	name = "default stock"
	desc = "Default parent object, not meant for use."
	icon_state = "stock"
	slot = "stock"
	melee_mod = 5
	size_mod = 2
	pixel_shift_x = 30
	pixel_shift_y = 14

	New()
		..()
		accuracy_mod = config.min_hit_accuracy_mult
		recoil_mod = -config.min_recoil_value
		scatter_mod = -config.min_scatter_value
		delay_mod = config.high_fire_delay

/obj/item/attachable/stock/shotgun
	name = "\improper M37 wooden stock"
	desc = "A non-standard heavy wooden stock for the M37 Shotgun. Less quick and more cumbersome than the standard issue stakeout, but reduces recoil and improves accuracy. Allegedly makes a pretty good club in a fight too.."
	slot = "stock"
	icon_state = "stock"

/obj/item/attachable/stock/slavic
	name = "wooden stock"
	desc = "A non-standard heavy wooden stock for Slavic firearms."
	icon_state = "slavicstock"
	pixel_shift_x = 32
	pixel_shift_y = 13
	flags_attach_features = ATTACH_PASSIVE

/obj/item/attachable/stock/rifle
	name = "\improper M41A skeleton stock"
	desc = "A rare stock distributed in small numbers to USCM forces. Compatible with the M41A, this stock reduces recoil and improves accuracy, but at a reduction to handling and agility. Seemingly a bit more effective in a brawl"
	slot = "stock"
	melee_mod = 5
	size_mod = 1
	icon_state = "riflestock"
	pixel_shift_x = 41
	pixel_shift_y = 10

	New()
		..()
		accuracy_mod = config.low_hit_accuracy_mult

/obj/item/attachable/stock/rifle/marksman
	name = "\improper M41A marksman stock"
	icon_state = "m4markstock"
	flags_attach_features = ATTACH_PASSIVE

/obj/item/attachable/stock/revolver
	name = "\improper M44 magnum sharpshooter stock"
	desc = "A wooden stock modified for use on a 44-magnum. Increases accuracy and reduces recoil at the expense of handling and agility. Less effective in melee as well"
	slot = "stock"
	melee_mod = -5
	size_mod = 1
	w_class_mod = 2
	icon_state = "44stock"
	pixel_shift_x = 35
	pixel_shift_y = 19

	New()
		..()
		accuracy_mod = config.med_hit_accuracy_mult

//The requirement for an attachable being alt fire is AMMO CAPACITY > 0.
/obj/item/attachable/grenade
	name = "underslung grenade launcher"
	desc = "A weapon-mounted, two-shot grenade launcher. It cannot be reloaded."
	icon_state = "grenade"
	w_class = 4.0
	current_rounds = 2
	max_rounds = 2
	max_range = 7
	slot = "under"
	fire_sound = 'sound/weapons/gun_m92_attachable.ogg'
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION

	examine()
		..()
		if(current_rounds > 0) 	usr << "It's still got some punch left."
		else 					usr << "It looks spent."


	//"Readying" the gun for the grenade launch is not needed. Just point & click
	activate_attachment(atom/target,mob/living/user)
		user << "<span class='notice'>Your next shot will fire an explosive grenade.</span>"
		return 1

	fire_attachment(atom/target,obj/item/weapon/gun/gun,mob/living/user)
		if(get_dist(user,target) > max_range)
			user << "<span class='warning'>Too far to fire the attachment!</span>"
			return 1

		if(current_rounds > 0) prime_grenade(target,gun,user)
		else user << "<span class='warning'>\icon[gun] The [src.name] is empty!</span>"

		return 1

/obj/item/attachable/grenade/proc/prime_grenade(atom/target,obj/item/weapon/gun/gun,mob/living/user)
	set waitfor = 0
	var/obj/item/weapon/grenade/explosive/G = new(get_turf(gun))
	playsound(user.loc, fire_sound, 50, 1)
	message_admins("[key_name_admin(user)] fired an underslung grenade launcher (<A HREF='?_src_=holder;adminplayerobservejump=\ref[user]'>JMP</A>)")
	log_game("[key_name_admin(user)] used an underslung grenade launcher.")
	G.active = 1
	G.icon_state = "grenade_active"
	G.throw_range = max_range
	G.throw_at(target, max_range, 2, user)
	current_rounds--
	sleep(15)
	if(G && G.loc) G.prime()

//"ammo/flamethrower" is a bullet, but the actual process is handled through fire_attachment, linked through Fire().
/obj/item/attachable/flamer
	name = "mini flamethrower"
	icon_state = "flamethrower"
	desc = "A weapon-mounted flamethrower attachment.\nIt is designed for short bursts and must be discarded after it is empty."
	w_class = 4.0
	current_rounds = 20
	max_rounds = 20
	max_range = 5
	slot = "under"
	fire_sound = 'sound/weapons/gun_flamethrower3.ogg'
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION

	examine()
		..()
		if(current_rounds > 0) usr << "It's still got some flame left."
		else usr << "It looks spent."

	activate_attachment(atom/target,mob/living/carbon/user)
		user << "<span class='notice'>Your next shot will unleash a burst of flame from [src].</span>"
		return 1

	fire_attachment(atom/target, obj/item/weapon/gun/gun, mob/living/user)
		if(get_dist(user,target) > max_range+3)
			user << "<span class='warning'>Too far to fire the attachment!</span>"
			return 1

		if(current_rounds) unleash_flame(target, user)
		else user << "<span class='warning'>\icon[gun] [src] is empty!</span>"

		return 1

/obj/item/attachable/flamer/proc/unleash_flame(atom/target, mob/living/user)
	set waitfor = 0
	var/list/turf/turfs = getline2(user,target)
	var/distance = 0
	var/obj/structure/window/W
	var/turf/T
	playsound(user, 'sound/weapons/gun_flamethrower2.ogg', 50, 1)
	for(T in turfs)
		if(T == user.loc) 			continue
		if(!current_rounds) 		break
		if(distance >= max_range) 	break
		if(DirBlocked(T,user.dir))  break
		else if(DirBlocked(T,turn(user.dir,180))) break
		if(locate(/obj/effect/alien/resin/wall,T) || locate(/obj/structure/mineral_door/resin,T) || locate(/obj/effect/alien/resin/membrane,T)) break
		W = locate() in T
		if(W)
			if(W.is_full_window()) 	break
			if(W.dir == user.dir) 	break
		current_rounds--
		flame_turf(T,user)
		distance++
		sleep(1)

/obj/item/attachable/flamer/proc/flame_turf(turf/T, mob/living/user)
	if(!istype(T)) return

	if(!locate(/obj/flamer_fire) in T) // No stacking flames!
		var/obj/flamer_fire/F =  new/obj/flamer_fire(T)
		processing_objects.Add(F)
	else return

	for(var/mob/living/carbon/M in T) //Deal bonus damage if someone's caught directly in initial stream
		if(M.stat == DEAD)		continue

		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.fire_immune) 	continue
		else if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_suit, /obj/item/clothing/suit/fire) || istype(H.wear_suit,/obj/item/clothing/suit/space/rig/atmos)) continue

		M.adjustFireLoss(rand(20,50))  //fwoom!
		M << "[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]Augh! You are roasted by the flames!"

/obj/item/attachable/shotgun
	name = "masterkey shotgun"
	icon_state = "masterkey"
	desc = "A weapon-mounted, four-shot shotgun. Mostly used in emergencies. It cannot be reloaded."
	w_class = 4.0
	max_rounds = 5
	current_rounds = 5
	ammo = /datum/ammo/bullet/shotgun/slug
	slot = "under"
	fire_sound = 'sound/weapons/gun_shotgun.ogg'
	type_of_casings = "shell"
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_CONTINUOUS|ATTACH_PROJECTILE

	examine()
		..()
		if(current_rounds > 0) 	usr << "It's still got some shells left."
		else 					usr << "It looks spent."

	//Because it's got an ammo_type, everything is taken care of when the gun shoots. It more or less just uses the attachment instead.
	activate_attachment(atom/target,mob/living/carbon/user)
		user << "<span class='notice'>You will now shoot shotgun shells from the [src.name].</span>"
		return 1

/obj/item/attachable/scope
	name = "rail scope"
	icon_state = "sniperscope"
	desc = "A rail mounted zoom sight scope. Allows zoom by activating the attachment. Use F12 if your HUD doesn't come back."
	slot = "rail"
	aim_speed_mod = SLOWDOWN_ADS_SCOPE //Extra slowdown when aiming
	flags_attach_features = ATTACH_REMOVABLE|ATTACH_ACTIVATION|ATTACH_PASSIVE

	New()
		..()
		delay_mod = config.mhigh_fire_delay
		accuracy_mod = config.max_hit_accuracy_mult
		burst_mod = -config.min_burst_value

	activate_attachment(obj/item/weapon/gun/target,mob/living/carbon/user)
		target.zoom(user, 11, 12)
		return 1

/obj/item/attachable/scope/slavic
	icon_state = "slavicscope"


	New()
		..()
		accuracy_mod = config.high_hit_accuracy_mult

/obj/item/attachable/slavicbarrel
	name = "sniper barrel"
	icon_state = "slavicbarrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = "muzzle"

	pixel_shift_x = 20
	pixel_shift_y = 16
	flags_attach_features = ATTACH_PASSIVE

	New()
		..()
		accuracy_mod = config.min_hit_accuracy_mult
		scatter_mod = -config.low_scatter_value

/obj/item/attachable/sniperbarrel
	name = "sniper barrel"
	icon_state = "sniperbarrel"
	desc = "A heavy barrel. CANNOT BE REMOVED."
	slot = "muzzle"
	accuracy_mod = 10
	flags_attach_features = ATTACH_PASSIVE

	New()
		..()
		accuracy_mod = config.low_hit_accuracy_mult
		scatter_mod = -config.low_scatter_value

/obj/item/attachable/smartbarrel
	name = "smartgun barrel"
	icon_state = "smartbarrel"
	desc = "A heavy rotating barrel. CANNOT BE REMOVED."
	slot = "muzzle"
	flags_attach_features = ATTACH_PASSIVE
