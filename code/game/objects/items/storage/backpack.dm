/*
* Backpack
*/

/obj/item/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/backpacks_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/backpacks_right.dmi',
	)
	item_state = "backpack"
	sprite_sheets = list(
		"Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Sterling Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Chilvaris Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Hammerhead Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		"Ratcher Combat Robot" = 'icons/mob/species/robot/backpack.dmi',
		)
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BACK	//ERROOOOO
	max_w_class = WEIGHT_CLASS_NORMAL
	storage_slots = null
	max_storage_space = 24
	access_delay = 1.5 SECONDS

/obj/item/storage/backpack/should_access_delay(obj/item/item, mob/user, taking_out)
	if(!taking_out) // Always allow items to be tossed in instantly
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if(human_user.back == src)
			return TRUE
	return FALSE

/obj/item/storage/backpack/attackby(obj/item/I, mob/user, params)
	. = ..()

	if (use_sound)
		playsound(loc, use_sound, 15, 1, 6)

/obj/item/storage/backpack/equipped(mob/user, slot)
	if(slot == SLOT_BACK)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
		if(use_sound)
			playsound(loc, use_sound, 15, 1, 6)
	..()

/obj/item/storage/backpack/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()

/obj/item/storage/backpack/vendor_equip(mob/user)
	..()
	return user.equip_to_appropriate_slot(src)

/*
* Backpack Types
*/

/obj/item/storage/backpack/holding
	name = "bag of holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	icon_state = "holdingpack"
	max_w_class = WEIGHT_CLASS_BULKY
	max_storage_space = 28

/obj/item/storage/backpack/holding/proc/failcheck(mob/user)
	if (prob(reliability))
		return TRUE //No failure
	if (prob(reliability))
		to_chat(user, span_warning("The Bluespace portal resists your attempt to add another item."))
	else
		to_chat(user, span_warning("The Bluespace generator malfunctions!"))
		for (var/obj/O in src.contents) //it broke, delete what was in it
			qdel(O)
		crit_fail = 1
		icon_state = "brokenpack"

/obj/item/storage/backpack/holding/attackby(obj/item/I, mob/user, params)
	if(crit_fail)
		to_chat(user, span_warning("The Bluespace generator isn't working."))

	else if(istype(I, /obj/item/storage/backpack/holding) && !I.crit_fail)
		to_chat(user, span_warning("The Bluespace interfaces of the two devices conflict and malfunction."))
		qdel(I)

	else
		return ..()

/obj/item/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = WEIGHT_CLASS_BULKY
	storage_slots = null
	max_w_class = WEIGHT_CLASS_NORMAL
	max_storage_space = 400 // can store a ton of shit!

/obj/item/storage/backpack/cultpack
	name = "trophy rack"
	desc = "It's useful for both carrying extra gear and proudly declaring your insanity."
	icon_state = "cultpack"

/obj/item/storage/backpack/clown
	name = "Giggles von Honkerton"
	desc = "It's a backpack made by Honk! Co."
	icon_state = "clownpack"

/obj/item/storage/backpack/corpsman
	name = "medical backpack"
	desc = "It's a backpack especially designed for use in a sterile environment."
	icon_state = "medicalpack"

/obj/item/storage/backpack/security
	name = "security backpack"
	desc = "It's a very robust backpack."
	icon_state = "securitypack"

/obj/item/storage/backpack/captain
	name = "captain's backpack"
	desc = "It's a special backpack made exclusively for officers."
	icon_state = "captainpack"

/obj/item/storage/backpack/industrial
	name = "industrial backpack"
	desc = "It's a tough backpack for the daily grind of station life."
	icon_state = "engiepack"
	item_state = "engiepack"

/obj/item/storage/backpack/toxins
	name = "laboratory backpack"
	desc = "It's a light backpack modeled for use in laboratories and other scientific institutions."
	icon_state = "toxpack"

/obj/item/storage/backpack/hydroponics
	name = "herbalist's backpack"
	desc = "It's a green backpack with many pockets to store plants and tools in."
	icon_state = "hydpack"

/obj/item/storage/backpack/genetics
	name = "geneticist backpack"
	desc = "It's a backpack fitted with slots for diskettes and other workplace tools."
	icon_state = "genpack"

/obj/item/storage/backpack/virology
	name = "sterile backpack"
	desc = "It's a sterile backpack able to withstand different pathogens from entering its fabric."
	icon_state = "viropack"

/obj/item/storage/backpack/chemistry
	name = "chemistry backpack"
	desc = "It's an orange backpack which was designed to hold beakers, pill bottles and bottles."
	icon_state = "chempack"

/*
* Satchel Types
*/

/obj/item/storage/backpack/satchel
	name = "leather satchel"
	desc = "It's a very fancy satchel made with fine leather."
	icon_state = "satchel"
	storage_slots = null
	max_storage_space = 15
	access_delay = 0

/obj/item/storage/backpack/satchel/withwallet/Initialize(mapload, ...)
	. = ..()
	new /obj/item/storage/wallet/random( src )


/obj/item/storage/backpack/satchel/som
	name = "mining satchel"
	desc = "A satchel with origins dating back to the mining colonies."
	icon_state = "som_satchel"
	item_state = "som_satchel"

/obj/item/storage/backpack/satchel/norm
	name = "satchel"
	desc = "A trendy looking satchel."
	icon_state = "satchel-norm"

/obj/item/storage/backpack/satchel/rugged
	name = "satchel"
	desc = "A rugged satchel for workers of all types."
	icon_state = "satchel-norm"

/obj/item/storage/backpack/satchel/eng
	name = "industrial satchel"
	desc = "A tough satchel with extra pockets."
	icon_state = "satchel-eng"

/obj/item/storage/backpack/satchel/med
	name = "medical satchel"
	desc = "A sterile satchel used in medical departments."
	icon_state = "satchel-med"

/obj/item/storage/backpack/satchel/vir
	name = "virologist satchel"
	desc = "A sterile satchel with virologist colours."
	icon_state = "satchel-vir"

/obj/item/storage/backpack/satchel/chem
	name = "chemist satchel"
	desc = "A sterile satchel with chemist colours."
	icon_state = "satchel-chem"

/obj/item/storage/backpack/satchel/gen
	name = "geneticist satchel"
	desc = "A sterile satchel with geneticist colours."
	icon_state = "satchel-gen"

/obj/item/storage/backpack/satchel/tox
	name = "scientist satchel"
	desc = "Useful for holding research materials."
	icon_state = "satchel-tox"

/obj/item/storage/backpack/satchel/sec
	name = "security satchel"
	desc = "A robust satchel for security related needs."
	icon_state = "satchel-sec"

/obj/item/storage/backpack/satchel/hyd
	name = "hydroponics satchel"
	desc = "A green satchel for plant related work."
	icon_state = "satchel_hyd"

/obj/item/storage/backpack/satchel/cap
	name = "captain's satchel"
	desc = "An exclusive satchel for officers."
	icon_state = "satchel-cap"

//ERT backpacks.
/obj/item/storage/backpack/ert
	name = "emergency response team backpack"
	desc = "A spacious backpack with lots of pockets, used by members of the Emergency Response Team."
	icon_state = "ert_commander"

//Commander
/obj/item/storage/backpack/ert/commander
	name = "emergency response team commander backpack"
	desc = "A spacious backpack with lots of pockets, worn by the commander of a Emergency Response Team."

//Security
/obj/item/storage/backpack/ert/security
	name = "emergency response team security backpack"
	desc = "A spacious backpack with lots of pockets, worn by security members of a Emergency Response Team."
	icon_state = "ert_security"

//Engineering
/obj/item/storage/backpack/ert/engineer
	name = "emergency response team engineer backpack"
	desc = "A spacious backpack with lots of pockets, worn by engineering members of a Emergency Response Team."
	icon_state = "ert_engineering"

//Medical
/obj/item/storage/backpack/ert/medical
	name = "emergency response team medical backpack"
	desc = "A spacious backpack with lots of pockets, worn by medical members of a Emergency Response Team."
	icon_state = "ert_medical"


/*========================== MARINE BACKPACKS ================================
==========================================================================*/

/obj/item/storage/backpack/marine
	name = "\improper lightweight IMP backpack"
	desc = "The standard-issue pack of the TGMC forces. Designed to slug gear into the battlefield."
	icon_state = "marinepack"
	item_state = "marinepack"

/obj/item/storage/backpack/marine/standard
	name = "\improper lightweight IMP backpack"
	desc = "The standard-issue pack of the TGMC forces. Designed to slug gear into the battlefield."

/obj/item/storage/backpack/marine/corpsman
	name = "\improper TGMC corpsman backpack"
	desc = "The standard-issue backpack worn by TGMC corpsmen. You can recharge defibrillators by plugging them in."
	icon_state = "marinepackm"
	item_state = "marinepackm"
	var/obj/item/cell/high/cell //Starts with a high capacity energy cell.
	var/icon_skin

/obj/item/storage/backpack/marine/corpsman/Initialize(mapload, ...)
	. = ..()
	cell = new
	icon_skin = icon_state
	update_icon()

/obj/item/storage/backpack/marine/corpsman/proc/use_charge(mob/user, amount = 0, mention_charge = TRUE)
	var/warning = ""
	if(amount > cell.charge)
		playsound(src, 'sound/machines/buzz-two.ogg', 25, 1)
		if(cell.charge)
			warning = "<span class='warning'>[src]'s defibrillator recharge unit buzzes a warning, its battery only having enough power to partially recharge the defibrillator for [cell.charge] amount. "
		else
			warning = "<span class='warning'>[src]'s defibrillator recharge unit buzzes a warning, as its battery is completely depleted of charge. "
	else
		playsound(src, 'sound/machines/ping.ogg', 25, 1)
		warning = "<span class='notice'>[src]'s defibrillator recharge unit cheerfully pings as it successfully recharges the defibrillator. "
	cell.charge -= min(cell.charge, amount)
	if(mention_charge)
		to_chat(user, span_notice("[warning]<b>Charge Remaining: [cell.charge]/[cell.maxcharge]</b>"))
	update_icon()

/obj/item/storage/backpack/marine/corpsman/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("Its defibrillator recharge unit has a loaded power cell and its readout counter is active. <b>Charge Remaining: [cell.charge]/[cell.maxcharge]</b>")
	else
		. += span_warning("Its defibrillator recharge unit does not have a power cell installed!")

/obj/item/storage/backpack/marine/corpsman/update_icon_state()
	icon_state = icon_skin
	if(cell?.charge >= 0)
		switch(PERCENT(cell.charge/cell.maxcharge))
			if(75 to INFINITY)
				icon_state += "_100"
			if(50 to 74.9)
				icon_state += "_75"
			if(25 to 49.9)
				icon_state += "_50"
			if(0.1 to 24.9)
				icon_state += "_25"
	else
		icon_state += "_0"

/obj/item/storage/backpack/marine/corpsman/MouseDrop_T(obj/item/W, mob/living/user) //Dragging the defib/power cell onto the backpack will trigger its special functionality.
	if(istype(W, /obj/item/defibrillator))
		if(cell)
			var/obj/item/defibrillator/D = W
			var/charge_difference = D.dcell.maxcharge - D.dcell.charge
			if(charge_difference) //If the defib has less than max charge, recharge it.
				use_charge(user, charge_difference) //consume an appropriate amount of charge
				D.dcell.charge += min(charge_difference, cell.charge) //Recharge the defibrillator battery with the lower of the difference between its present and max cap, or the remaining charge
			else
				to_chat(user, span_warning("This defibrillator is already at maximum charge!"))
		else
			to_chat(user, span_warning("[src]'s defibrillator recharge unit does not have a power cell installed!"))
	else if(istype(W, /obj/item/cell))
		if(user.drop_held_item())
			W.loc = src
			var/replace_install = "You replace the cell in [src]'s defibrillator recharge unit."
			if(!cell)
				replace_install = "You install a cell in [src]'s defibrillator recharge unit."
			else
				cell.update_icon()
				user.put_in_hands(cell)
			cell = W
			to_chat(user, span_notice("[replace_install] <b>Charge Remaining: [cell.charge]/[cell.maxcharge]</b>"))
			playsound(user, 'sound/weapons/guns/interact/rifle_reload.ogg', 25, 1, 5)
			update_icon()
	return ..()


/obj/item/storage/backpack/marine/tech
	name = "\improper TGMC technician backpack"
	desc = "The standard-issue backpack worn by TGMC technicians. Specially equipped to hold sentry gun and M56D emplacement parts."
	icon_state = "marinepackt"
	item_state = "marinepackt"
	bypass_w_limit = list(
		/obj/item/weapon/gun/sentry/big_sentry,
		/obj/item/weapon/gun/sentry/mini,
		/obj/item/weapon/gun/tl102,
		/obj/item/ammo_magazine/tl102,
		/obj/item/ammo_magazine/sentry,
		/obj/item/ammo_magazine/minisentry,
		/obj/item/mortal_shell,
		/obj/item/mortar_kit,
		/obj/item/stack/razorwire,
		/obj/item/stack/sandbags,
	)

/obj/item/storage/backpack/marine/satchel
	name = "\improper TGMC satchel"
	desc = "A heavy-duty satchel carried by some TGMC soldiers and support personnel."
	icon_state = "marinesat"
	item_state = "marinesat"
	storage_slots = null
	max_storage_space = 15
	access_delay = 0

/obj/item/storage/backpack/marine/satchel/green
	name = "\improper TGMC satchel"
	icon_state = "marinesat_green"


/obj/item/storage/backpack/marine/corpsman/satchel
	name = "\improper TGMC corpsman satchel"
	desc = "A heavy-duty satchel carried by some TGMC corpsmen. You can recharge defibrillators by plugging them in."
	icon_state = "marinesatm"
	item_state = "marinesatm"
	storage_slots = null
	max_storage_space = 15
	access_delay = 0
	cell = /obj/item/cell/apc

/obj/item/storage/backpack/marine/satchel/tech
	name = "\improper TGMC technician satchel"
	desc = "A heavy-duty satchel carried by some TGMC technicians. Can hold the ST-580 point defense sentry and ammo."
	icon_state = "marinesatt"
	item_state = "marinesatt"
	bypass_w_limit = list(
		/obj/item/weapon/gun/sentry/mini,
		/obj/item/ammo_magazine/tl102,
		/obj/item/ammo_magazine/sentry,
		/obj/item/ammo_magazine/minisentry,
		/obj/item/mortal_shell,
		/obj/item/stack/razorwire,
		/obj/item/stack/sandbags,
	)

/obj/item/storage/backpack/marine/smock
	name = "\improper M3 sniper's smock"
	desc = "A specially designed smock with pockets for all your sniper needs."
	icon_state = "smock"
	access_delay = 0

//CLOAKS

/obj/item/storage/backpack/marine/satchel/officer_cloak
	name = "Officer Cloak"
	desc = "A dashing cloak as befitting an officer."
	icon_state = "officer_cloak" //with thanks to Baystation12
	item_state = "officer_cloak" //with thanks to Baystation12

/obj/item/storage/backpack/marine/satchel/captain_cloak
	name = "Captain's Cloak"
	desc = "An opulent cloak detailed with your many accomplishments."
	icon_state = "commander_cloak" //with thanks to Baystation12
	item_state = "commander_cloak" //with thanks to Baystation12

/obj/item/storage/backpack/marine/satchel/officer_cloak_red
	name = "Officer Cloak - Red"
	desc = "A dashing cloak as befitting an officer, with fancy red trim."
	icon_state = "officer_cloak_red" //with thanks to Baystation12
	item_state = "officer_cloak_red" //with thanks to Baystation12

/obj/item/storage/backpack/marine/satchel/captain_cloak_red
	name = "Captain's Cloak - Red"
	desc = "An opulent cloak detailed with your many accomplishments, with fancy red trim."
	icon_state = "commander_cloak_red" //with thanks to Baystation12
	item_state = "commander_cloak_red" //with thanks to Baystation12


// Scout Cloak
/obj/item/storage/backpack/marine/satchel/scout_cloak
	name = "\improper M68 Thermal Cloak"
	desc = "The lightweight thermal dampeners and optical camouflage provided by this cloak are weaker than those found in standard TGMC ghillie suits. In exchange, the cloak can be worn over combat armor and offers the wearer high manueverability and adaptability to many environments. Serves as a satchel."
	icon_state = "scout_cloak"
	var/camo_active = 0
	var/camo_active_timer = 0
	var/camo_cooldown_timer = null
	var/camo_last_stealth = null
	var/camo_last_shimmer = null
	var/camo_energy = 100
	var/mob/living/carbon/human/wearer = null
	var/shimmer_alpha = SCOUT_CLOAK_RUN_ALPHA
	var/stealth_delay = null
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/storage/backpack/marine/satchel/scout_cloak/scout

/obj/item/storage/backpack/marine/satchel/scout_cloak/Destroy()
	camo_off()
	return ..()

/obj/item/storage/backpack/marine/satchel/scout_cloak/dropped(mob/user)
	camo_off(user)
	wearer = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/item/storage/backpack/marine/satchel/scout_cloak/verb/use_camouflage()
	set name = "Toggle M68 Thermal Camouflage"
	set desc = "Activate your cloak's camouflage."
	set category = "Scout"

	camouflage()

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/camouflage()
	if (usr.incapacitated(TRUE))
		return

	var/mob/living/carbon/human/M = usr
	if (!istype(M))
		return

	if (M.back != src)
		to_chat(M, "<span class='warning'>You must be wearing the cloak to activate it!")
		return

	if (camo_active)
		camo_off(usr)
		return

	if(SEND_SIGNAL(M, COMSIG_MOB_ENABLE_STEALTH) & STEALTH_ALREADY_ACTIVE)
		to_chat(M, span_warning("You are already cloaked!"))
		return FALSE

	if (camo_cooldown_timer)
		to_chat(M, "<span class='warning'>Your thermal cloak is still recalibrating! It will be ready in [(camo_cooldown_timer - world.time) * 0.1] seconds.")
		return

	camo_active = TRUE
	camo_last_stealth = world.time
	wearer = M

	RegisterSignal(wearer, COMSIG_MOB_ENABLE_STEALTH, PROC_REF(on_other_activate))
	M.visible_message("[M] fades into thin air!", span_notice("You activate your cloak's camouflage."))
	playsound(M.loc,'sound/effects/cloak_scout_on.ogg', 15, 1)

	stealth_delay = world.time - SCOUT_CLOAK_STEALTH_DELAY
	if(camo_last_shimmer > stealth_delay) //Shimmer after taking aggressive actions
		wearer.alpha = shimmer_alpha //50% invisible
	else
		wearer.alpha = SCOUT_CLOAK_STILL_ALPHA

	if (M.smokecloaked)
		M.smokecloaked = FALSE
	else
		GLOB.huds[DATA_HUD_SECURITY_ADVANCED].remove_from_hud(M)
		GLOB.huds[DATA_HUD_BASIC].remove_from_hud(M)
		GLOB.huds[DATA_HUD_XENO_INFECTION].remove_from_hud(M)
		GLOB.huds[DATA_HUD_XENO_HEART].remove_from_hud(M)

	addtimer(CALLBACK(src, PROC_REF(on_cloak)), 1)
	RegisterSignal(M, COMSIG_HUMAN_DAMAGE_TAKEN, PROC_REF(damage_taken))
	RegisterSignals(M, list(
		COMSIG_MOB_GUN_FIRED,
		COMSIG_MOB_GUN_AUTOFIRED,
		COMSIG_MOB_ATTACHMENT_FIRED,
		COMSIG_MOB_THROW,
		COMSIG_MOB_ITEM_ATTACK), PROC_REF(action_taken))

	START_PROCESSING(SSprocessing, src)
	wearer.cloaking = TRUE

	return TRUE


/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/on_other_activate()
	SIGNAL_HANDLER
	return STEALTH_ALREADY_ACTIVE


/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/on_cloak()
	if(wearer)
		anim(wearer.loc,wearer,'icons/mob/mob.dmi',,"cloak",,wearer.dir)

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/on_decloak()
	if(wearer)
		anim(wearer.loc,wearer,'icons/mob/mob.dmi',,"uncloak",,wearer.dir)

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/camo_off(mob/user)
	if(wearer)
		UnregisterSignal(wearer, COMSIG_MOB_ENABLE_STEALTH)
	if(!user)
		camo_active = FALSE
		wearer = null
		STOP_PROCESSING(SSprocessing, src)
		return FALSE

	if(!camo_active)
		return FALSE

	camo_active = FALSE

	user.visible_message(span_warning("[user.name] shimmers into existence!"), span_danger("Your cloak's camouflage has deactivated!"))
	playsound(user.loc,'sound/effects/cloak_scout_off.ogg', 15, 1)
	user.alpha = initial(user.alpha)

	GLOB.huds[DATA_HUD_SECURITY_ADVANCED].add_to_hud(user)
	GLOB.huds[DATA_HUD_BASIC].add_to_hud(user)
	GLOB.huds[DATA_HUD_XENO_INFECTION].add_to_hud(user)
	GLOB.huds[DATA_HUD_XENO_HEART].add_to_hud(user)

	addtimer(CALLBACK(src, PROC_REF(on_decloak)), 1)

	var/cooldown = round( (initial(camo_energy) - camo_energy) / SCOUT_CLOAK_INACTIVE_RECOVERY * 10) //Should be 20 seconds after a full depletion with inactive recovery at 5
	if(cooldown)
		camo_cooldown_timer = world.time + cooldown //recalibration and recharge time scales inversely with charge remaining
		to_chat(user, "<span class='warning'>Your thermal cloak is recalibrating! It will be ready in [(camo_cooldown_timer - world.time) * 0.1] seconds.")
		process_camo_cooldown(user, cooldown)

	UnregisterSignal(user, list(
		COMSIG_HUMAN_DAMAGE_TAKEN,
		COMSIG_MOB_GUN_FIRED,
		COMSIG_MOB_GUN_AUTOFIRED,
		COMSIG_MOB_ATTACHMENT_FIRED,
		COMSIG_MOB_THROW,
		COMSIG_MOB_ITEM_ATTACK))
	STOP_PROCESSING(SSprocessing, src)
	wearer.cloaking = FALSE

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/process_camo_cooldown(mob/living/user, cooldown)
	if(!camo_cooldown_timer)
		return
	addtimer(CALLBACK(src, PROC_REF(cooldown_finished)), cooldown)

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/cooldown_finished()
	camo_cooldown_timer = null
	camo_energy = initial(camo_energy)
	playsound(loc,'sound/effects/EMPulse.ogg', 25, 0, 1)
	if(wearer)
		to_chat(wearer, span_danger("Your thermal cloak has recalibrated and is ready to cloak again."))

/obj/item/storage/backpack/marine/satchel/scout_cloak/examine(mob/user)
	. = ..()
	if(user != wearer) //Only the wearer can see these details.
		return
	var/list/details = list()
	details +=("It has [camo_energy]/[initial(camo_energy)] charge. </br>")

	if(camo_cooldown_timer)
		details +=("It will be ready in [(camo_cooldown_timer - world.time) * 0.1] seconds. </br>")

	if(camo_active)
		details +=("It's currently active.</br>")

	. += span_warning("[details.Join(" ")]")

/obj/item/storage/backpack/marine/satchel/scout_cloak/item_action_slot_check(mob/user, slot)
	if(!ishuman(user))
		return FALSE
	if(slot != SLOT_BACK)
		return FALSE
	return TRUE


/obj/item/storage/backpack/marine/satchel/scout_cloak/attack_self(mob/user)
	. = ..()
	camouflage()

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/camo_adjust_energy(mob/user, drain = SCOUT_CLOAK_WALK_DRAIN)
	camo_energy = clamp(camo_energy - drain,0,initial(camo_energy))

	if(!camo_energy) //Turn off the camo if we run out of energy.
		to_chat(user, span_danger("Your thermal cloak lacks sufficient energy to remain active."))
		camo_off(user)

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/damage_taken(datum/source, damage)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/wearer = source
	if(damage >= 15)
		to_chat(wearer, span_danger("Your cloak shimmers from the damage!"))
		apply_shimmer()

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/action_taken() //This is used by multiple signals passing different parameters.
	SIGNAL_HANDLER
	to_chat(wearer, span_danger("Your cloak shimmers from your actions!"))
	apply_shimmer()

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/apply_shimmer()
	camo_last_shimmer = world.time //Reduces transparency to 50%
	wearer.alpha = max(wearer.alpha,shimmer_alpha)

/obj/item/storage/backpack/marine/satchel/scout_cloak/process()
	if(!wearer)
		camo_off()
		return
	else if(wearer.stat != CONSCIOUS)
		camo_off(wearer)
		return

	stealth_delay = world.time - SCOUT_CLOAK_STEALTH_DELAY
	if(camo_last_shimmer > stealth_delay) //Shimmer after taking aggressive actions; no energy regeneration
		wearer.alpha = shimmer_alpha //50% invisible
	else if(camo_last_stealth > stealth_delay ) //We have an initial reprieve at max invisibility allowing us to reposition; no energy recovery during this time
		wearer.alpha = SCOUT_CLOAK_STILL_ALPHA
		return
	//Stationary stealth
	else if( wearer.last_move_intent < stealth_delay ) //If we're standing still and haven't shimmed in the past 3 seconds we become almost completely invisible
		wearer.alpha = SCOUT_CLOAK_STILL_ALPHA //95% invisible
		camo_adjust_energy(wearer, SCOUT_CLOAK_ACTIVE_RECOVERY)

/obj/item/storage/backpack/marine/satchel/scout_cloak/sniper
	name = "\improper M68-B Thermal Cloak"
	icon_state = "smock"
	desc = "The M68-B thermal cloak is a variant custom-purposed for snipers, allowing for faster, superior, stationary concealment at the expense of mobile concealment. It is designed to be paired with the lightweight M3 recon battle armor. Serves as a satchel."
	shimmer_alpha = SCOUT_CLOAK_RUN_ALPHA * 0.5 //Half the normal shimmer transparency.

/obj/item/storage/backpack/marine/satchel/scout_cloak/sniper/equippedsniper/Initialize(mapload)
	. = ..()
	new /obj/item/detpack(src)

/obj/item/storage/backpack/marine/satchel/scout_cloak/sniper/process()
	if(!wearer)
		camo_off()
		return
	else if(wearer.stat == DEAD)
		camo_off(wearer)
		return

	stealth_delay = world.time - SCOUT_CLOAK_STEALTH_DELAY * 0.5
	if(camo_last_shimmer > stealth_delay) //Shimmer after taking aggressive actions; no energy regeneration
		wearer.alpha = max(wearer.alpha, shimmer_alpha) //50% invisible
	//Stationary stealth
	else if( wearer.last_move_intent < stealth_delay ) //If we're standing still and haven't shimmed in the past 2 seconds we become almost completely invisible
		wearer.alpha = SCOUT_CLOAK_STILL_ALPHA //95% invisible
		camo_adjust_energy(wearer, SCOUT_CLOAK_ACTIVE_RECOVERY)

// Welder Backpacks //

/obj/item/storage/backpack/marine/engineerpack
	name = "\improper TGMC technician welderpack"
	desc = "A specialized backpack worn by TGMC technicians. It carries a fueltank for quick welder refueling and use,"
	icon_state = "engineerpack"
	item_state = "engineerpack"
	var/max_fuel = 260
	storage_slots = null
	max_storage_space = 15
	access_delay = 0

/obj/item/storage/backpack/marine/engineerpack/Initialize(mapload, ...)
	. = ..()
	var/datum/reagents/R = new/datum/reagents(max_fuel) //Lotsa refills
	reagents = R
	R.my_atom = WEAKREF(src)
	R.add_reagent(/datum/reagent/fuel, max_fuel)


/obj/item/storage/backpack/marine/engineerpack/attackby(obj/item/I, mob/user, params)
	if(iswelder(I))
		var/obj/item/tool/weldingtool/T = I
		if(T.welding)
			to_chat(user, span_warning("That was close! However you realized you had the welder on and prevented disaster."))
			return
		if(T.get_fuel() == T.max_fuel || !reagents.total_volume)
			return ..()

		reagents.trans_to(I, T.max_fuel)
		to_chat(user, span_notice("Welder refilled!"))
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)

	else if(istype(I, /obj/item/ammo_magazine/flamer_tank))
		var/obj/item/ammo_magazine/flamer_tank/FT = I
		if(FT.default_ammo != /datum/ammo/flamethrower)
			to_chat(user, span_warning("Not the right kind of fuel!"))
			return ..()
		if(FT.current_rounds == FT.max_rounds || !reagents.total_volume)
			return ..()

		//Reworked and much simpler equation; fuel capacity minus the current amount, with a check for insufficient fuel
		var/fuel_transfer_amount = min(reagents.total_volume, (FT.max_rounds - FT.current_rounds))
		reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		FT.current_rounds += fuel_transfer_amount
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		FT.caliber = CALIBER_FUEL
		to_chat(user, span_notice("You refill [FT] with [lowertext(FT.caliber)]."))
		FT.update_icon()

	else if(istype(I, /obj/item/weapon/twohanded/rocketsledge))
		var/obj/item/weapon/twohanded/rocketsledge/RS = I
		if(RS.reagents.get_reagent_amount(/datum/reagent/fuel) == RS.max_fuel || !reagents.total_volume)
			return ..()

		var/fuel_transfer_amount = min(reagents.total_volume, (RS.max_fuel - RS.reagents.get_reagent_amount(/datum/reagent/fuel)))
		reagents.remove_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		RS.reagents.add_reagent(/datum/reagent/fuel, fuel_transfer_amount)
		playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
		to_chat(user, span_notice("You refill [RS] with fuel."))
		RS.update_icon()

	else
		return ..()

/obj/item/storage/backpack/marine/engineerpack/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) // this replaces and improves the get_dist(src,O) <= 1 checks used previously
		return
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume < max_fuel)
		O.reagents.trans_to(src, max_fuel)
		to_chat(user, span_notice("You crack the cap off the top of the pack and fill it back up again from the tank."))
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return
	else if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume == max_fuel)
		to_chat(user, span_notice("The pack is already full!"))
		return
	..()

/obj/item/storage/backpack/marine/engineerpack/examine(mob/user)
	. = ..()
	. += "[reagents.total_volume] units of fuel left!"


/obj/item/storage/backpack/lightpack
	name = "\improper lightweight combat pack"
	desc = "A small lightweight pack for expeditions and short-range operations."
	icon_state = "ERT_satchel"
	access_delay = 0

/obj/item/storage/backpack/commando
	name = "commando bag"
	desc = "A heavy-duty bag carried by Nanotrasen commandos."
	icon_state = "commandopack"
	storage_slots = null
	max_storage_space = 40
	access_delay = 0

/obj/item/storage/backpack/captain
	name = "marine captain backpack"
	desc = "The contents of this backpack are top secret."
	icon_state = "marinepack"
	storage_slots = null
	max_storage_space = 30


/obj/item/storage/backpack/lightpack/som
	name = "mining rucksack"
	desc = "A rucksack with origins dating back to the mining colonies."
	icon_state = "som_lightpack"
	item_state = "som_lightpack"

/obj/item/storage/backpack/lightpack/icc
	name = "\improper Modello/190"
	desc = "A small lightweight buttpack made for use in a wide variety of operations, made with a synthetic tan fibre."
	icon_state = "icc_bag"

/obj/item/storage/backpack/lightpack/icc/guard
	name = "\improper Modello/190"
	desc = "A small lightweight buttpack made for use in a wide variety of operations, made with a synthetic black fibre."
	icon_state = "icc_bag_guard"
