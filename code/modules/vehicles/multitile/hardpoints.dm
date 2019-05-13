/*
All of the hardpoints, for the tank or other
Currently only has the tank hardpoints
*/

#define HDPT_PRIMARY "primary"
#define HDPT_SECDGUN "secondary"
#define HDPT_SUPPORT "support"
#define HDPT_ARMOR "armor"
#define HDPT_TREADS "treads"

/obj/item/hardpoint

	var/slot //What slot do we attach to?
	var/obj/vehicle/owner //Who do we work for?

	icon = 'icons/obj/hardpoint_modules.dmi'
	icon_state = "tires" //Placeholder

	max_integrity = 100
	w_class = 15

	var/obj/item/ammo_magazine/tank/ammo
	//If we use ammo, put it here
	var/obj/item/ammo_magazine/tank/starter_ammo

	//Strings, used to get the overlay for the armored vic
	var/disp_icon //This also differentiates tank vs apc vs other
	var/disp_icon_state

	var/next_use = 0
	var/is_activatable = FALSE
	var/max_angle = 180
	var/point_cost = 0

	var/list/backup_clips = list()
	var/max_clips = 1 //1 so they can reload their backups and actually reload once
	var/buyable = TRUE

/obj/item/hardpoint/Initialize()
	. = ..()
	if(starter_ammo)
		ammo = new starter_ammo

/obj/item/hardpoint/examine(mob/user)
	. = ..()
	var/status = obj_integrity <= 0.1 ? "broken" : "functional"
	var/span_class = obj_integrity <= 0.1 ? "<span class = 'danger'>" : "<span class = 'notice'>"
	if((user?.mind?.cm_skills && user.mind.cm_skills.engineer >= SKILL_ENGINEER_METAL) || isobserver(user))
		switch(PERCENT(obj_integrity / max_integrity))
			if(0.1 to 33)
				status = "heavily damaged"
				span_class = "<span class = 'warning'>"
			if(33.1 to 66)
				status = "damaged"
				span_class = "<span class = 'warning'>"
			if(66.1 to 90)
				status = "slighty damaged"
			if(90.1 to 100)
				status = "intact"
	to_chat(user, "[span_class]It's [status].</span>")

/obj/item/hardpoint/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/ammo_magazine/tank))
		try_add_clip(W, user)
		return
	if(!iswelder(W) && !iswrench(W))
		return ..()
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>[src] is already in perfect condition.</span>")
		return
	var/repair_delays = 6
	var/obj/item/tool/repair_tool = /obj/item/tool/weldingtool
	switch(slot)
		if(HDPT_PRIMARY)
			repair_delays = 5
		if(HDPT_SECDGUN)
			repair_tool = /obj/item/tool/wrench
			repair_delays = 3
		if(HDPT_SUPPORT)
			repair_tool = /obj/item/tool/wrench
			repair_delays = 2
		if(HDPT_ARMOR)
			repair_delays = 10
	var/obj/item/tool/weldingtool/WT = iswelder(W) ? W : null
	if(!istype(W, repair_tool))
		to_chat(user, "<span class='warning'>That's the wrong tool. Use a [WT ? "wrench" : "welder"].</span>")
		return
	if(WT && !WT.isOn())
		to_chat(user, "<span class='warning'>You need to light your [WT] first.</span>")
		return
	user.visible_message("<span class='notice'>[user] starts repairing [src].</span>",
		"<span class='notice'>You start repairing [src].</span>")
	if(!do_after(user, 3 SECONDS * repair_delays, TRUE, src, BUSY_ICON_BUILD))
		user.visible_message("<span class='notice'>[user] stops repairing [src].</span>",
							"<span class='notice'>You stop repairing [src].</span>")
		return
	if(WT)
		if(!WT.isOn())
			return
		WT.remove_fuel(repair_delays, user)
	user.visible_message("<span class='notice'>[user] finishes repairing [src].</span>",
		"<span class='notice'>You finish repairing [src].</span>")
	obj_integrity = max_integrity

//If our cooldown has elapsed
/obj/item/hardpoint/proc/is_ready()
	if(world.time < next_use)
		to_chat(usr, "<span class='warning'>This module is not ready to be used yet.</span>")
		return FALSE
	if(!obj_integrity)
		to_chat(usr, "<span class='warning'>This module is too broken to be used.</span>")
		return FALSE
	return TRUE

/obj/item/hardpoint/proc/try_add_clip(obj/item/ammo_magazine/tank/A, mob/user)

	if(!max_clips)
		to_chat(user, "<span class='warning'>This module does not have room for additional ammo.</span>")
		return FALSE
	else if(length(backup_clips) >= max_clips)
		to_chat(user, "<span class='warning'>The reloader is full.</span>")
		return FALSE
	else if(!istype(A, starter_ammo))
		to_chat(user, "<span class='warning'>That is the wrong ammo type.</span>")
		return FALSE

	to_chat(user, "<span class='notice'>You start loading [A] in [src].</span>")

	var/atom/target = owner ? owner : src

	if(!do_after(user, 10, TRUE, target) || QDELETED(src))
		to_chat(user, "<span class='warning'>Something interrupted you while loading [src].</span>")
		return FALSE

	user.temporarilyRemoveItemFromInventory(A, FALSE)
	user.visible_message("<span class='notice'>[user] loads [A] in [src]</span>",
				"<span class='notice'>You finish loading [A] in \the [src].</span>", null, 3)
	backup_clips += A
	playsound(user.loc, 'sound/weapons/gun_minigun_cocked.ogg', 25)
	return TRUE

//Returns the image object to overlay onto the root object
/obj/item/hardpoint/proc/get_icon_image(x_offset, y_offset, new_dir)

	var/icon_suffix = "NS"
	var/icon_state_suffix = "0"

	if(new_dir in list(NORTH, SOUTH))
		icon_suffix = "NS"
	else if(new_dir in list(EAST, WEST))
		icon_suffix = "EW"

	if(!obj_integrity)
		icon_state_suffix = "1"

	return image(icon = "[disp_icon]_[icon_suffix]", icon_state = "[disp_icon_state]_[icon_state_suffix]", pixel_x = x_offset, pixel_y = y_offset)

///////////////
// AMMO MAGS // START
///////////////

//Special ammo magazines for hardpoint modules. Some aren't here since you can use normal magazines on them
/obj/item/ammo_magazine/tank
	flags_magazine = 0 //No refilling
	var/point_cost = 0

/obj/item/ammo_magazine/tank/ltb_cannon
	name = "LTB Cannon Magazine"
	desc = "A primary armament cannon magazine"
	caliber = "86mm" //Making this unique on purpose
	icon_state = "ltbcannon_4"
	w_class = 15 //Heavy fucker
	default_ammo = /datum/ammo/rocket/ltb
	max_rounds = 4
	point_cost = 50
	gun_type = /obj/item/tank_weapon

/obj/item/ammo_magazine/tank/ltb_cannon/update_icon()
	icon_state = "ltbcannon_[current_rounds]"


/obj/item/ammo_magazine/tank/ltaaap_minigun
	name = "LTAA-AP Minigun Magazine"
	desc = "A primary armament minigun magazine"
	caliber = "7.62x51mm" //Correlates to miniguns
	icon_state = "painless"
	w_class = 10
	default_ammo = /datum/ammo/bullet/minigun
	max_rounds = 500
	point_cost = 25
	gun_type = /obj/item/tank_weapon/minigun


///////////////
// AMMO MAGS // END
///////////////
