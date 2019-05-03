/*
 * Backpack
 */

/obj/item/storage/backpack
	name = "backpack"
	desc = "You wear this on your back and put items into it."
	icon_state = "backpack"
	w_class = 4
	flags_equip_slot = ITEM_SLOT_BACK	//ERROOOOO
	max_w_class = 3
	storage_slots = null
	max_storage_space = 30
	var/worn_accessible = FALSE //whether you can access its content while worn on the back

/obj/item/storage/backpack/attack_hand(mob/user)
	if(!worn_accessible && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.back == src)
/*			if(user.dropItemToGround(src))
				pickup(user)
				add_fingerprint(user)
				if(!user.put_in_active_hand(src))
					dropped(user)
*/
			to_chat(H, "<span class='notice'>You can't look in [src] while it's on your back.</span>")
			return
	..()

/obj/item/storage/backpack/attackby(obj/item/W, mob/user)
/*	if(!worn_accessible && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.back == src)
			to_chat(H, "<span class='notice'>You can't access [src] while it's on your back.</span>")
			return TRUE
*/
	if (use_sound)
		playsound(src.loc, src.use_sound, 15, 1, 6)
	..()

/obj/item/storage/backpack/mob_can_equip(M as mob, slot)
	if (!..())
		return 0

	if (!uniform_restricted)
		return 1

	if (!ishuman(M))
		return 0

	var/mob/living/carbon/human/H = M
	var/list/equipment = list(H.wear_suit, H.w_uniform, H.shoes, H.belt, H.gloves, H.glasses, H.head, H.wear_ear, H.wear_id, H.r_store, H.l_store, H.s_store)

	for (var/type in uniform_restricted)
		if (!(locate(type) in equipment))
			to_chat(H, "<span class='warning'>You must be wearing [initial(type:name)] to equip [name]!")
			return 0
	return 1

/obj/item/storage/backpack/equipped(mob/user, slot)
	if(slot == SLOT_BACK)
		mouse_opacity = 2 //so it's easier to click when properly equipped.
		if(use_sound)
			playsound(loc, use_sound, 15, 1, 6)
		if(!worn_accessible && user.s_active == src) //currently looking into the backpack
			close(user)
	..()

/obj/item/storage/backpack/dropped(mob/user)
	mouse_opacity = initial(mouse_opacity)
	..()


/obj/item/storage/backpack/open(mob/user)
	if(!worn_accessible && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.back == src)
			to_chat(H, "<span class='notice'>You can't access [src] while it's on your back.</span>")
			return
	..()

/*
 * Backpack Types
 */

/obj/item/storage/backpack/holding
	name = "bag of holding"
	desc = "A backpack that opens into a localized pocket of Blue Space."
	origin_tech = "bluespace=4"
	icon_state = "holdingpack"
	max_w_class = 4
	max_storage_space = 28

	attackby(obj/item/W as obj, mob/user as mob)
		if(crit_fail)
			to_chat(user, "<span class='warning'>The Bluespace generator isn't working.</span>")
			return
		if(istype(W, /obj/item/storage/backpack/holding) && !W.crit_fail)
			to_chat(user, "<span class='warning'>The Bluespace interfaces of the two devices conflict and malfunction.</span>")
			qdel(W)
			return
		..()

	proc/failcheck(mob/user as mob)
		if (prob(src.reliability)) return 1 //No failure
		if (prob(src.reliability))
			to_chat(user, "<span class='warning'>The Bluespace portal resists your attempt to add another item.</span>")
		else
			to_chat(user, "<span class='warning'>The Bluespace generator malfunctions!</span>")
			for (var/obj/O in src.contents) //it broke, delete what was in it
				qdel(O)
			crit_fail = 1
			icon_state = "brokenpack"


/obj/item/storage/backpack/santabag
	name = "Santa's Gift Bag"
	desc = "Space Santa uses this to deliver toys to all the nice children in space in Christmas! Wow, it's pretty big!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = 4.0
	storage_slots = null
	max_w_class = 3
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
	worn_accessible = TRUE
	storage_slots = null
	max_storage_space = 15

/obj/item/storage/backpack/satchel/withwallet/Initialize(mapload, ...)
	. = ..()
	new /obj/item/storage/wallet/random( src )

/obj/item/storage/backpack/satchel/norm
	name = "satchel"
	desc = "A trendy looking satchel."
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


//==========================// MARINE BACKPACKS\\================================\\
//=======================================================================\\

/obj/item/storage/backpack/marine
	name = "\improper lightweight IMP backpack"
	desc = "The standard-issue pack of the TGMC forces. Designed to slug gear into the battlefield."
	icon_state = "marinepack"

/obj/item/storage/backpack/marine/standard
	name = "\improper lightweight IMP backpack"
	desc = "The standard-issue pack of the TGMC forces. Designed to slug gear into the battlefield."

/obj/item/storage/backpack/marine/corpsman
	name = "\improper TGMC corpsman backpack"
	desc = "The standard-issue backpack worn by TGMC corpsmen."
	icon_state = "marinepackm"
	var/obj/item/cell/high/cell //Starts with a high capacity energy cell.
	var/icon_skin

/obj/item/storage/backpack/marine/corpsman/Initialize(mapload, ...)
	. = ..()
	cell = new (src)
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
		to_chat(user, "<span class='notice'>[warning]<b>Charge Remaining: [cell.charge]/[cell.maxcharge]</b></span>")
	update_icon()
	return ..()

/obj/item/storage/backpack/marine/corpsman/examine(mob/user)
	. = ..()
	if(cell)
		to_chat(user, "<span class='notice'>Its defibrillator recharge unit has a loaded power cell and its readout counter is active. <b>Charge Remaining: [cell.charge]/[cell.maxcharge]</b></span>")
	else
		to_chat(user, "<span class='warning'>Its defibrillator recharge unit does not have a power cell installed!</span>")

/obj/item/storage/backpack/marine/corpsman/update_icon()
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
				to_chat(user, "<span class='warning'>This defibrillator is already at maximum charge!</span>")
		else
			to_chat(user, "<span class='warning'>[src]'s defibrillator recharge unit does not have a power cell installed!</span>")
	else if(istype(W, /obj/item/cell))
		if(user.drop_held_item())
			W.loc = src
			var/replace_install = "You replace the cell in [src]'s defibrillator recharge unit."
			if(!cell)
				replace_install = "You install a cell in [src]'s defibrillator recharge unit."
			else
				cell.updateicon()
				user.put_in_hands(cell)
			cell = W
			to_chat(user, "<span class='notice'>[replace_install] <b>Charge Remaining: [cell.charge]/[cell.maxcharge]</b></span>")
			playsound(user, 'sound/weapons/gun_rifle_reload.ogg', 25, 1, 5)
			update_icon()
	return ..()


/obj/item/storage/backpack/marine/tech
	name = "\improper TGMC technician backpack"
	desc = "The standard-issue backpack worn by TGMC technicians. Specially equipped to hold sentry gun and M56D emplacement parts."
	icon_state = "marinepackt"
	bypass_w_limit = list(
		/obj/item/m56d_gun,
		/obj/item/ammo_magazine/m56d,
		/obj/item/m56d_post,
		/obj/item/turret_top,
		/obj/item/ammo_magazine/sentry,
		/obj/item/ammo_magazine/minisentry,
		/obj/item/marine_turret/mini,
		/obj/item/stack/razorwire,
		/obj/item/stack/sandbags)

/obj/item/storage/backpack/marine/satchel
	name = "\improper TGMC satchel"
	desc = "A heavy-duty satchel carried by some TGMC soldiers and support personnel."
	icon_state = "marinesat"
	worn_accessible = TRUE
	storage_slots = null
	max_storage_space = 15


/obj/item/storage/backpack/marine/satchel/corpsman
	name = "\improper TGMC corpsman satchel"
	desc = "A heavy-duty satchel carried by some TGMC corpsmen."
	icon_state = "marinesatm"

/obj/item/storage/backpack/marine/satchel/tech
	name = "\improper TGMC technician satchel"
	desc = "A heavy-duty satchel carried by some TGMC technicians."
	icon_state = "marinesatt"

/obj/item/storage/backpack/marine/smock
	name = "\improper M3 sniper's smock"
	desc = "A specially designed smock with pockets for all your sniper needs."
	icon_state = "smock"
	worn_accessible = TRUE


// Scout Cloak
/obj/item/storage/backpack/marine/satchel/scout_cloak
	name = "\improper M68 Thermal Cloak"
	desc = "The lightweight thermal dampeners and optical camouflage provided by this cloak are weaker than those found in standard TGMC ghillie suits. In exchange, the cloak can be worn over combat armor and offers the wearer high manueverability and adaptability to many environments."
	icon_state = "scout_cloak"
	uniform_restricted = list(/obj/item/clothing/suit/storage/marine/M3S) //Need to wear Scout armor to equip this.
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
	var/process_count = 0

/obj/item/storage/backpack/marine/satchel/scout_cloak/scout

/obj/item/storage/backpack/marine/satchel/scout_cloak/Destroy()
	camo_off()
	return ..()

/obj/item/storage/backpack/marine/satchel/scout_cloak/dropped(mob/user)
	camo_off(user)
	wearer = null
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/item/storage/backpack/marine/satchel/scout_cloak/verb/use_camouflage()
	set name = "Toggle M68 Thermal Camouflage"
	set desc = "Activate your cloak's camouflage."
	set category = "Scout"

	camouflage()

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/camouflage()
	if (!usr || usr.incapacitated(TRUE))
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

	if (camo_cooldown_timer)
		to_chat(M, "<span class='warning'>Your thermal cloak is still recalibrating! It will be ready in [(camo_cooldown_timer - world.time) * 0.1] seconds.")
		return

	camo_active = TRUE
	camo_last_stealth = world.time
	to_chat(M, "<span class='notice'>You activate your cloak's camouflage.</span>")
	wearer = M

	for (var/mob/O in oviewers(M))
		O.show_message("[M] fades into thin air!", 1)
	playsound(M.loc,'sound/effects/cloak_scout_on.ogg', 15, 1)

	stealth_delay = world.time - SCOUT_CLOAK_STEALTH_DELAY
	if(camo_last_shimmer > stealth_delay) //Shimmer after taking aggressive actions
		wearer.alpha = shimmer_alpha //50% invisible
	else
		wearer.alpha = SCOUT_CLOAK_STILL_ALPHA

	if (M.smokecloaked)
		M.smokecloaked = FALSE
	else
		var/datum/mob_hud/security/advanced/SA = huds[MOB_HUD_SECURITY_ADVANCED]
		SA.remove_from_hud(M)
		var/datum/mob_hud/xeno_infection/XI = huds[MOB_HUD_XENO_INFECTION]
		XI.remove_from_hud(M)

	spawn(1)
		anim(M.loc,M,'icons/mob/mob.dmi',,"cloak",,M.dir)

	START_PROCESSING(SSfastprocess, src)
	wearer.cloaking = TRUE

	return TRUE

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/camo_off(var/mob/user)
	if (!user)
		camo_active = FALSE
		wearer = null
		STOP_PROCESSING(SSfastprocess, src)
		return 0

	if(!camo_active)
		return FALSE

	camo_active = FALSE

	user.visible_message("[user.name] shimmers into existence!", "<span class='warning'>Your cloak's camouflage has deactivated!</span>")
	playsound(user.loc,'sound/effects/cloak_scout_off.ogg', 15, 1)
	user.alpha = initial(user.alpha)

	var/datum/mob_hud/security/advanced/SA = huds[MOB_HUD_SECURITY_ADVANCED]
	SA.add_to_hud(user)
	var/datum/mob_hud/xeno_infection/XI = huds[MOB_HUD_XENO_INFECTION]
	XI.add_to_hud(user)

	spawn(1)
		anim(user.loc,user,'icons/mob/mob.dmi',,"uncloak",,user.dir)

	var/cooldown = round( (initial(camo_energy) - camo_energy) / SCOUT_CLOAK_INACTIVE_RECOVERY * 10) //Should be 20 seconds after a full depletion with inactive recovery at 5
	if(cooldown)
		camo_cooldown_timer = world.time + cooldown //recalibration and recharge time scales inversely with charge remaining
		to_chat(user, "<span class='warning'>Your thermal cloak is recalibrating! It will be ready in [(camo_cooldown_timer - world.time) * 0.1] seconds.")
		process_camo_cooldown(user, cooldown)
	STOP_PROCESSING(SSfastprocess, src)
	wearer.cloaking = FALSE

/obj/item/storage/backpack/marine/satchel/scout_cloak/proc/process_camo_cooldown(mob/living/user, cooldown)
	if(!camo_cooldown_timer)
		return
	spawn(cooldown)
		camo_cooldown_timer = null
		camo_energy = initial(camo_energy)
		playsound(loc,'sound/effects/EMPulse.ogg', 25, 0, 1)
		if(wearer)
			to_chat(wearer, "<span class='danger'>Your thermal cloak has recalibrated and is ready to cloak again.</span>")

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

	to_chat(user, "<span class='warning'>[details.Join(" ")]</span>")

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
	camo_energy = CLAMP(camo_energy - drain,0,initial(camo_energy))

	if(!camo_energy) //Turn off the camo if we run out of energy.
		to_chat(user, "<span class='danger'>Your thermal cloak lacks sufficient energy to remain active.</span>")
		camo_off(user)

/obj/item/storage/backpack/marine/satchel/scout_cloak/process()
	if(!wearer)
		camo_off()
		return
	else if(wearer.stat == DEAD)
		camo_off(wearer)
		return

	if(process_count++ < 4)
		return

	process_count = 0

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
	uniform_restricted = list(/obj/item/clothing/suit/storage/marine/sniper) //Need to wear Scout armor and helmet to equip this.
	desc = "The M68-B thermal cloak is a variant custom-purposed for snipers, allowing for faster, superior, stationary concealment at the expense of mobile concealment. It is designed to be paired with the lightweight M3 recon battle armor."
	shimmer_alpha = SCOUT_CLOAK_RUN_ALPHA * 0.5 //Half the normal shimmer transparency.

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
	var/max_fuel = 260
	storage_slots = null
	max_storage_space = 15

/obj/item/storage/backpack/marine/engineerpack/Initialize(mapload, ...)
	. = ..()
	var/datum/reagents/R = new/datum/reagents(max_fuel) //Lotsa refills
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", max_fuel)


/obj/item/storage/backpack/marine/engineerpack/attackby(obj/item/W, mob/living/user)
	if(iswelder(W))
		var/obj/item/tool/weldingtool/T = W
		if(T.welding)
			to_chat(user, "<span class='warning'>That was close! However you realized you had the welder on and prevented disaster.</span>")
			return
		if(!(T.get_fuel()==T.max_fuel) && reagents.total_volume)
			reagents.trans_to(W, T.max_fuel)
			to_chat(user, "<span class='notice'>Welder refilled!</span>")
			playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
			return
	else if(istype(W, /obj/item/ammo_magazine/flamer_tank))
		var/obj/item/ammo_magazine/flamer_tank/FT = W
		if(!FT.current_rounds && reagents.total_volume)
			var/fuel_available = reagents.total_volume < FT.max_rounds ? reagents.total_volume : FT.max_rounds
			reagents.remove_reagent("fuel", fuel_available)
			FT.current_rounds = fuel_available
			playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
			FT.caliber = "Fuel"
			to_chat(user, "<span class='notice'>You refill [FT] with [lowertext(FT.caliber)].</span>")
			FT.update_icon()
			return
	. = ..()

/obj/item/storage/backpack/marine/engineerpack/afterattack(obj/O as obj, mob/user as mob, proximity)
	if(!proximity) // this replaces and improves the get_dist(src,O) <= 1 checks used previously
		return
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume < max_fuel)
		O.reagents.trans_to(src, max_fuel)
		to_chat(user, "<span class='notice'>You crack the cap off the top of the pack and fill it back up again from the tank.</span>")
		playsound(src.loc, 'sound/effects/refill.ogg', 25, 1, 3)
		return
	else if (istype(O, /obj/structure/reagent_dispensers/fueltank) && src.reagents.total_volume == max_fuel)
		to_chat(user, "<span class='notice'>The pack is already full!</span>")
		return
	..()

/obj/item/storage/backpack/marine/engineerpack/examine(mob/user)
	..()
	to_chat(user, "[reagents.total_volume] units of fuel left!")

// Pyrotechnician Spec backpack fuel tank
/obj/item/storage/backpack/marine/engineerpack/flamethrower
	name = "\improper TGMC Pyrotechnician fueltank"
	desc = "A specialized fueltank worn by TGMC Pyrotechnicians for use with the M240-T incinerator unit. A small general storage compartment is installed."
	icon_state = "flamethrower_tank"
	max_fuel = 500


/obj/item/storage/backpack/marine/engineerpack/flamethrower/attackby(obj/item/W, mob/living/user)
	if(!istype(W, /obj/item/ammo_magazine/flamer_tank))
		return ..()
	var/obj/item/ammo_magazine/flamer_tank/FTL = W
	if(FTL.default_ammo != /datum/ammo/flamethrower)
		return ..()
	if(FTL.max_rounds == FTL.current_rounds)
		return ..()
	if(reagents.total_volume <= 0)
		to_chat(user, "<span class='warning'>You try to refill \the [FTL] but \the [src] fuel reserve is empty.</span>")
		return ..()
	var/fuel_refill = FTL.max_rounds - FTL.current_rounds
	if(reagents.total_volume < fuel_refill)
		fuel_refill = reagents.total_volume
	reagents.remove_reagent("fuel", fuel_refill)
	FTL.current_rounds = FTL.current_rounds + fuel_refill
	playsound(loc, 'sound/effects/refill.ogg', 25, 1, 3)
	to_chat(user, "<span class='notice'>You refill [FTL] with UT-Napthal Fuel as you place it inside of \the [src].</span>")
	FTL.update_icon()


/obj/item/storage/backpack/lightpack
	name = "\improper lightweight combat pack"
	desc = "A small lightweight pack for expeditions and short-range operations."
	icon_state = "ERT_satchel"
	worn_accessible = TRUE

/obj/item/storage/backpack/commando
	name = "commando bag"
	desc = "A heavy-duty bag carried by Nanotrasen commandos."
	icon_state = "commandopack"
	storage_slots = null
	max_storage_space = 30

/obj/item/storage/backpack/captain
	name = "marine captain backpack"
	desc = "The contents of this backpack are top secret."
	icon_state = "marinepack"
	storage_slots = null
	max_storage_space = 30
