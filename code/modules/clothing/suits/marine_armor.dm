// MARINE STORAGE ARMOR

/obj/item/clothing/suit/storage/marine
	name = "\improper M3 pattern marine armor"
	desc = "A standard TerraGov Marine Corps M3 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "3"
	item_state = "armor"
	sprite_sheet_id = 1
	flags_atom = CONDUCT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	armor = list("melee" = 50, "bullet" = 40, "laser" = 35, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 20)
	siemens_coefficient = 0.7
	permeability_coefficient = 0.8
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	allowed = list(/obj/item/weapon/gun/,
		/obj/item/tank/emergency_oxygen,
		/obj/item/storage/bible,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/weapon/claymore,
		/obj/item/storage/belt/gun)

	var/brightness_on = 5 //Average attachable pocket light
	var/flashlight_cooldown = 0 //Cooldown for toggling the light
	var/locate_cooldown = 0 //Cooldown for SL locator
	var/list/armor_overlays
	actions_types = list(/datum/action/item_action/toggle)
	var/flags_marine_armor = ARMOR_SQUAD_OVERLAY|ARMOR_LAMP_OVERLAY
	w_class = 5
	time_to_unequip = 2 SECONDS
	time_to_equip = 2 SECONDS
	pockets = /obj/item/storage/internal/suit/marine

/obj/item/storage/internal/suit/marine
	bypass_w_limit = list(
		/obj/item/ammo_magazine/rifle,
		/obj/item/ammo_magazine/smg,
		/obj/item/ammo_magazine/sniper,
		/obj/item/cell/lasgun
	 )
	max_storage_space = 6

/obj/item/clothing/suit/storage/marine/Initialize()
	. = ..()
	armor_overlays = list("lamp") //Just one for now, can add more later.
	update_icon()

/obj/item/clothing/suit/storage/marine/update_icon(mob/user)
	var/image/I
	I = armor_overlays["lamp"]
	overlays -= I
	qdel(I)
	if(flags_marine_armor & ARMOR_LAMP_OVERLAY)
		I = image('icons/obj/clothing/cm_suits.dmi', src, flags_marine_armor & ARMOR_LAMP_ON? "lamp-on" : "lamp-off")
		armor_overlays["lamp"] = I
		overlays += I
	else
		armor_overlays["lamp"] = null
	user?.update_inv_wear_suit()

/obj/item/clothing/suit/storage/marine/pickup(mob/user)
	if(flags_marine_armor & ARMOR_LAMP_ON && src.loc != user)
		user.SetLuminosity(brightness_on)
		SetLuminosity(0)
	return ..()

/obj/item/clothing/suit/storage/marine/dropped(mob/user)
	if(loc != user)
		turn_off_light(user)
	return ..()

/obj/item/clothing/suit/storage/marine/proc/turn_off_light(mob/wearer)
	if(flags_marine_armor & ARMOR_LAMP_ON)
		SetLuminosity(0)
		toggle_armor_light(wearer) //turn the light off
		return TRUE
	return FALSE

/obj/item/clothing/suit/storage/marine/Destroy()
	if(ismob(loc))
		var/mob/user = loc
		user.SetLuminosity(-brightness_on)
	SetLuminosity(0)
	if(pockets)
		qdel(pockets)
	return ..()

/obj/item/clothing/suit/storage/marine/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot turn the light on while in [user.loc].</span>")
		return
	if(flashlight_cooldown > world.time)
		return
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.wear_suit != src)
		return
	toggle_armor_light(user)
	return TRUE

/obj/item/clothing/suit/storage/marine/item_action_slot_check(mob/user, slot)
	if(!ishuman(user))
		return FALSE
	if(slot != SLOT_WEAR_SUIT)
		return FALSE
	return TRUE //only give action button when armor is worn.

/obj/item/clothing/suit/storage/marine/proc/toggle_armor_light(mob/user)
	//message_admins("TOGGLE ARMOR LIGHT DEBUG 1: flags_marine_armor: [flags_marine_armor] user: [user]")
	flashlight_cooldown = world.time + 2 SECONDS //2 seconds cooldown every time the light is toggled
	if(flags_marine_armor & ARMOR_LAMP_ON) //Turn it off.
		if(user)
			user.SetLuminosity(-brightness_on)
		else
			SetLuminosity(0)
	else //Turn it on.
		if(user)
			user.SetLuminosity(brightness_on)
		else
			SetLuminosity(brightness_on)
	flags_marine_armor ^= ARMOR_LAMP_ON
	playsound(src,'sound/items/flashlight.ogg', 15, 1)
	update_icon(user)
	update_action_button_icons()

/obj/item/clothing/suit/storage/marine/M3HB
	name = "\improper M3-H pattern marine armor"
	desc = "A standard Marine M3 Heavy Build Pattern Chestplate. Increased protection at the cost of slowdown."
	icon_state = "1"
	armor = list("melee" = 60, "bullet" = 70, "laser" = 45, "energy" = 30, "bomb" = 60, "bio" = 20, "rad" = 20, "fire" = 30, "acid" = 30)
	slowdown = SLOWDOWN_ARMOR_HEAVY

/obj/item/clothing/suit/storage/marine/M3LB
	name = "\improper M3-LB pattern marine armor"
	desc = "A standard Marine M3 Light Build Pattern Chestplate. Lesser encumbrance and protection."
	icon_state = "2"
	armor = list("melee" = 30, "bullet" = 20, "laser" = 25, "energy" = 10, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 10, "acid" = 10)
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/marine/M3IS
	name = "\improper M3-IS pattern marine armor"
	desc = "A standard Marine M3 Integrated Storage Pattern Chestplate. Increased encumbrance and carrying capacity."
	icon_state = "4"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	var/obj/item/weapon/gun/current_gun
	var/sheatheSound = 'sound/weapons/gun_pistol_sheathe.ogg'
	var/drawSound = 'sound/weapons/gun_pistol_draw.ogg'
	pockets = /obj/item/storage/internal/suit/marine/M3IS

/obj/item/storage/internal/suit/marine/M3IS
	bypass_w_limit = list()
	storage_slots = null
	max_storage_space = 14
	max_w_class = 3 //Can fit larger items

/obj/item/clothing/suit/storage/marine/M3E
	name = "\improper M3-E pattern marine armor"
	desc = "A standard Marine M3 Edge Pattern Chestplate. High protection against cuts and slashes, but very little padding against bullets or explosions."
	icon_state = "5"
	armor = list("melee" = 70, "bullet" = 20, "laser" = 35, "energy" = 20, "bomb" = 15, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 20)

/obj/item/clothing/suit/storage/marine/M3P
	name = "\improper M3-P pattern marine armor"
	desc = "A standard Marine M3 Padded Pattern Chestplate. Better protection against bullets and explosions, with limited thermal shielding against energy weapons, but worse against melee."
	icon_state = "6"
	armor = list("melee" = 30, "bullet" = 70, "laser" = 45, "energy" = 30, "bomb" = 60, "bio" = 10, "rad" = 10, "fire" = 30, "acid" = 30)

/obj/item/clothing/suit/storage/marine/M3P/tanker
	name = "\improper M3 pattern tanker armor"
	desc = "A modified and refashioned suit of M3 Pattern armor designed to be worn by vehicle crew. While the suit is a bit more encumbering to wear with the crewman uniform, it offers the loader a degree of protection that would otherwise not be enjoyed."
	icon_state = "tanker"

/obj/item/clothing/suit/storage/marine/leader
	name = "\improper B12 pattern leader armor"
	desc = "A lightweight suit of carbon fiber body armor built for quick movement. Use it to toggle the built-in flashlight."
	icon_state = "7"
	armor = list("melee" = 50, "bullet" = 60, "laser" = 45, "energy" = 40, "bomb" = 40, "bio" = 15, "rad" = 15, "fire" = 40, "acid" = 40)
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/marine/MP
	name = "\improper N2 pattern MA armor"
	desc = "A standard TerraGov Navy N2 Pattern Chestplate. Protects the chest from ballistic rounds, bladed objects and accidents. It has a small leather pouch strapped to it for limited storage."
	icon_state = "mp"
	armor = list("melee" = 40, "bullet" = 70, "laser" = 35, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 20)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/weapon/baton,
		/obj/item/handcuffs,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/storage/belt/sparepouch,
		/obj/item/hailer,
		/obj/item/storage/belt/gun)

/obj/item/clothing/suit/storage/marine/MP/WO
	icon_state = "warrant_officer"
	name = "\improper N3 pattern MA armor"
	desc = "A well-crafted suit of N3 Pattern Armor typically distributed to Command Masters at Arms. Useful for letting your men know who is in charge."
	armor = list("melee" = 50, "bullet" = 80, "laser" = 40, "energy" = 25, "bomb" = 30, "bio" = 10, "rad" = 10, "fire" = 25, "acid" = 25)

/obj/item/clothing/suit/storage/marine/MP/admiral
	icon_state = "admiral"
	name = "\improper M3 pattern admiral armor"
	desc = "A well-crafted suit of M3 Pattern Armor with a gold shine. It looks very expensive, but shockingly fairly easy to carry and wear."
	w_class = 3
	armor = list("melee" = 50, "bullet" = 80, "laser" = 40, "energy" = 25, "bomb" = 30, "bio" = 10, "rad" = 10, "fire" = 25, "acid" = 25)

/obj/item/clothing/suit/storage/marine/MP/RO
	icon_state = "officer"
	name = "\improper M3 pattern officer armor"
	desc = "A well-crafted suit of M3 Pattern Armor typically found in the hands of higher-ranking officers. Useful for letting your men know who is in charge when taking to the field"

/obj/item/clothing/suit/storage/marine/smartgunner
	name = "M56 combat harness"
	desc = "A heavy protective vest designed to be worn with the M56 Smartgun System. \nIt has specially designed straps and reinforcement to carry the Smartgun and accessories."
	icon_state = "8"
	item_state = "armor"
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS
	armor = list("melee" = 55, "bullet" = 75, "laser" = 35, "energy" = 35, "bomb" = 35, "bio" = 10, "rad" = 10, "fire" = 35, "acid" = 35)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/tank/emergency_oxygen,
					/obj/item/flashlight,
					/obj/item/ammo_magazine,
					/obj/item/explosive/mine,
					/obj/item/weapon/combat_knife,
					/obj/item/weapon/gun/smartgun,
					/obj/item/storage/belt/sparepouch)

/obj/item/clothing/suit/storage/marine/smartgunner/fancy
	desc = "A heavy protective vest designed to be worn with the M56 Smartgun System. \nIt has specially designed straps and reinforcement to carry the Smartgun and accessories. This luxury model appears to belong to the CO. You feel like you probably could get fired for touching this.."
	icon_state = "8fancy"

//===========================SPECIALIST================================


/obj/item/clothing/suit/storage/marine/specialist
	name = "\improper B18 defensive armor"
	desc = "A heavy, rugged set of armor plates for when you really, really need to not die horribly. Slows you down though.\nHas an automated diagnostics and medical system for keeping its wearer alive."
	icon_state = "xarmor"
	armor = list("melee" = 80, "bullet" = 110, "laser" = 80, "energy" = 80, "bomb" = 80, "bio" = 20, "rad" = 20, "fire" = 80, "acid" = 80)
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|FEET
	slowdown = SLOWDOWN_ARMOR_HEAVY
	var/mob/living/carbon/human/wearer = null
	var/B18_burn_cooldown = null
	var/B18_oxy_cooldown = null
	var/B18_brute_cooldown = null
	var/B18_tox_cooldown = null
	var/B18_pain_cooldown = null
	var/B18_automed_on = TRUE
	var/B18_automed_damage = 50
	var/B18_automed_pain = 70
	var/obj/item/healthanalyzer/integrated/B18_analyzer = null
	supporting_limbs = list(CHEST, GROIN, ARM_LEFT, ARM_RIGHT, HAND_LEFT, HAND_RIGHT, LEG_LEFT, LEG_RIGHT, FOOT_LEFT, FOOT_RIGHT) //B18 effectively stabilizes these.
	resistance_flags = UNACIDABLE

/obj/item/clothing/suit/storage/marine/specialist/Initialize(mapload, ...)
	. = ..()
	B18_analyzer = new /obj/item/healthanalyzer/integrated

/obj/item/clothing/suit/storage/marine/specialist/examine(mob/user)
	. = ..()
	if(user != wearer) //Only the wearer can see these details.
		return
	var/list/details = list()
	if(B18_burn_cooldown)
		details +=("Its burn treatment injector is currently refilling. It will resupply in [(B18_burn_cooldown - world.time) * 0.1] seconds.</br>")

	if(B18_brute_cooldown)
		details +=("Its trauma treatment injector is currently refilling. It will resupply in [(B18_brute_cooldown - world.time) * 0.1] seconds.</br>")

	if(B18_oxy_cooldown)
		details +=("Its oxygenating injector is currently refilling. It will resupply in [(B18_oxy_cooldown - world.time) * 0.1] seconds.</br>")

	if(B18_tox_cooldown)
		details +=("Its anti-toxin injector is currently refilling. It will resupply in [(B18_tox_cooldown - world.time) * 0.1] seconds.</br>")

	if(B18_pain_cooldown)
		details +=("Its painkiller injector is currently refilling. It will resupply in [(B18_pain_cooldown - world.time) * 0.1] seconds.</br>")

	to_chat(user, "<span class='danger'>[details.Join(" ")]</span>")

/obj/item/clothing/suit/storage/marine/specialist/Destroy()
	b18automed_turn_off(wearer, TRUE)
	wearer = null
	qdel(B18_analyzer)
	. = ..()

/obj/item/clothing/suit/storage/marine/specialist/dropped(mob/user)
	. = ..()
	b18automed_turn_off(wearer, TRUE)
	wearer = null

/obj/item/clothing/suit/storage/marine/specialist/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == SLOT_WEAR_SUIT)
		wearer = user
		b18automed_turn_on(user)

/obj/item/clothing/suit/storage/marine/specialist/proc/b18automed_turn_off(mob/living/carbon/human/user, silent = FALSE)
	B18_automed_on = FALSE
	STOP_PROCESSING(SSobj, src)
	if(!silent)
		to_chat(user, "<span class='warning'>[src] lets out a beep as its automedical suite deactivates.</span>")
		playsound(src,'sound/machines/click.ogg', 15, 0, 1)

/obj/item/clothing/suit/storage/marine/specialist/proc/b18automed_turn_on(mob/living/carbon/human/user, silent = FALSE)
	B18_automed_on = TRUE
	START_PROCESSING(SSobj, src)
	if(!silent)
		to_chat(user, "<span class='notice'>[src] lets out a hum as its automedical suite activates.</span>")
		playsound(src,'sound/voice/b18_activate.ogg', 15, 0, 1)

/obj/item/clothing/suit/storage/marine/specialist/process()
	if(!B18_automed_on)
		STOP_PROCESSING(SSobj, src)
		return
	if(!wearer)
		STOP_PROCESSING(SSobj, src)
		return

	var/list/details = list()
	var/dose_administered = null
	var/tricordrazine = CLAMP(REAGENTS_OVERDOSE - (wearer.reagents.get_reagent_amount("tricordrazine") + 0.5),0,REAGENTS_OVERDOSE * B18_CHEM_MOD)

	if(wearer.getFireLoss() > B18_automed_damage && !B18_burn_cooldown)
		var/kelotane = CLAMP(REAGENTS_OVERDOSE - (wearer.reagents.get_reagent_amount("kelotane") + 0.5),0,REAGENTS_OVERDOSE * B18_CHEM_MOD)
		if(kelotane)
			wearer.reagents.add_reagent("kelotane",kelotane)
		if(tricordrazine)
			wearer.reagents.add_reagent("tricordrazine",tricordrazine)
		if(kelotane || tricordrazine) //Only report if we actually administer something
			details +=("Significant tissue burns detected. Restorative injection administered. <b>Dosage:[kelotane ? " Kelotane: [kelotane]U |" : ""][tricordrazine ? " Tricordrazine: [tricordrazine]U" : ""]</b></br>")
			B18_burn_cooldown = world.time + B18_CHEM_COOLDOWN
			handle_chem_cooldown(B18_BURN_CODE)
			dose_administered = TRUE

	if(wearer.getBruteLoss() > B18_automed_damage && !B18_brute_cooldown)
		var/bicaridine = CLAMP(REAGENTS_OVERDOSE - (wearer.reagents.get_reagent_amount("bicaridine") + 0.5),0,REAGENTS_OVERDOSE * B18_CHEM_MOD)
		var/quickclot = CLAMP(REAGENTS_OVERDOSE * 0.5 - (wearer.reagents.get_reagent_amount("quickclot") + 0.5),0,REAGENTS_OVERDOSE * 0.5 * B18_CHEM_MOD)
		if(quickclot)
			wearer.reagents.add_reagent("quickclot",quickclot)
		if(bicaridine)
			wearer.reagents.add_reagent("bicaridine",bicaridine)
		if(tricordrazine)
			wearer.reagents.add_reagent("tricordrazine",tricordrazine)
		if(quickclot || bicaridine || tricordrazine) //Only report if we actually administer something
			details +=("Significant physical trauma detected. Regenerative formula administered. <b>Dosage:[bicaridine ? " Bicaridine: [bicaridine]U |" : ""][quickclot ? " Quickclot: [quickclot]U |" : ""][tricordrazine ? " Tricordrazine: [tricordrazine]U" : ""]</b></br>")
			B18_brute_cooldown = world.time + B18_CHEM_COOLDOWN
			handle_chem_cooldown(B18_BRUTE_CODE)
			playsound(src,'sound/voice/b18_brute.ogg', 15, 0, 1)
			dose_administered = TRUE

	if(wearer.getOxyLoss() > B18_automed_damage && !B18_oxy_cooldown)
		var/dexalinplus = CLAMP(REAGENTS_OVERDOSE * 0.5 - (wearer.reagents.get_reagent_amount("dexalinplus") + 0.5),0,REAGENTS_OVERDOSE * 0.5 * B18_CHEM_MOD)
		var/inaprovaline = CLAMP(REAGENTS_OVERDOSE * 2 - (wearer.reagents.get_reagent_amount("inaprovaline") + 0.5),0,REAGENTS_OVERDOSE * 2 * B18_CHEM_MOD)
		if(dexalinplus)
			wearer.reagents.add_reagent("dexalinplus",dexalinplus)
		if(inaprovaline)
			wearer.reagents.add_reagent("inaprovaline",inaprovaline)
		if(tricordrazine)
			wearer.reagents.add_reagent("tricordrazine",tricordrazine)
		if(dexalinplus || inaprovaline || tricordrazine) //Only report if we actually administer something
			details +=("Low blood oxygen detected. Reoxygenating preparation administered. <b>Dosage:[dexalinplus ? " Dexalin Plus: [dexalinplus]U |" : ""][inaprovaline ? " Inaprovaline: [inaprovaline]U |" : ""][tricordrazine ? " Tricordrazine: [tricordrazine]U" : ""]</b></br>")
			B18_oxy_cooldown = world.time + B18_CHEM_COOLDOWN
			handle_chem_cooldown(B18_OXY_CODE)
			dose_administered = TRUE

	if(wearer.getToxLoss() > B18_automed_damage && !B18_tox_cooldown)
		var/dylovene = CLAMP(REAGENTS_OVERDOSE - (wearer.reagents.get_reagent_amount("dylovene") + 0.5),0,REAGENTS_OVERDOSE * B18_CHEM_MOD)
		var/spaceacillin = CLAMP(REAGENTS_OVERDOSE - (wearer.reagents.get_reagent_amount("spaceacillin") + 0.5),0,REAGENTS_OVERDOSE * B18_CHEM_MOD)
		if(dylovene)
			wearer.reagents.add_reagent("dylovene",dylovene)
		if(spaceacillin)
			wearer.reagents.add_reagent("spaceacillin",spaceacillin)
		if(tricordrazine)
			wearer.reagents.add_reagent("tricordrazine",tricordrazine)
		if(dylovene || spaceacillin || tricordrazine) //Only report if we actually administer something
			details +=("Significant blood toxicity detected. Chelating agents and curatives administered. <b>Dosage:[dylovene ? " Dylovene: [dylovene]U |" : ""][spaceacillin ? " Spaceacillin: [spaceacillin]U |" : ""][tricordrazine ? " Tricordrazine: [tricordrazine]U" : ""]</b></br>")
			B18_tox_cooldown = world.time + B18_CHEM_COOLDOWN
			playsound(src,pick('sound/voice/b18_antitoxin.ogg','sound/voice/b18_antitoxin2.ogg'), 15, 0, 1)
			handle_chem_cooldown(B18_TOX_CODE)
			dose_administered = TRUE

	if(wearer.traumatic_shock > B18_automed_pain && !B18_pain_cooldown)
		var/oxycodone = CLAMP(REAGENTS_OVERDOSE * 0.66 - (wearer.reagents.get_reagent_amount("oxycodone") + 0.5),0,REAGENTS_OVERDOSE * 0.66 * B18_CHEM_MOD)
		var/tramadol = CLAMP(REAGENTS_OVERDOSE - (wearer.reagents.get_reagent_amount("tramadol") + 0.5),0,REAGENTS_OVERDOSE * B18_CHEM_MOD)
		if(oxycodone)
			wearer.reagents.add_reagent("oxycodone",oxycodone)
		if(tramadol)
			wearer.reagents.add_reagent("tramadol",tramadol)
		if(oxycodone || tramadol) //Only report if we actually administer something
			details +=("User pain at performance impeding levels. Painkillers administered. <b>Dosage:[oxycodone ? " Oxycodone: [oxycodone]U |" : ""][tramadol ? " Tramadol: [tramadol]U" : ""]</b></br>")
			B18_pain_cooldown = world.time + B18_CHEM_COOLDOWN
			handle_chem_cooldown(B18_PAIN_CODE)
			playsound(src,'sound/voice/b18_pain_suppress.ogg', 15, 0, 1)
			dose_administered = TRUE

	if(dose_administered)
		playsound(src,'sound/items/hypospray.ogg', 25, 0, 1)
		details +=("Estimated [B18_CHEM_COOLDOWN/600] minute replenishment time for each dosage.")
		to_chat(wearer, "<span class='notice'>[icon2html(src, wearer)] beeps:</br> [details.Join(" ")]</span>")

/obj/item/clothing/suit/storage/marine/specialist/proc/handle_chem_cooldown(code = B18_BRUTE_CODE, silent = FALSE)
	if(code)
		spawn(B18_CHEM_COOLDOWN)
			switch(code)
				if(B18_BRUTE_CODE)
					if(B18_brute_cooldown)
						B18_brute_cooldown = null
				if(B18_BURN_CODE)
					if(B18_burn_cooldown)
						B18_burn_cooldown = null
				if(B18_OXY_CODE)
					if(B18_oxy_cooldown)
						B18_oxy_cooldown = null
				if(B18_TOX_CODE)
					if(B18_tox_cooldown)
						B18_tox_cooldown = null
				if(B18_PAIN_CODE)
					if(B18_pain_cooldown)
						B18_pain_cooldown = null
			if(!silent)
				to_chat(wearer, "<span class='notice'>[src] beeps: [code == B18_BRUTE_CODE ? "Trauma treatment" : code == B18_BURN_CODE ? "Burn treatment" : code == B18_OXY_CODE ? "Oxygenation treatment" : code == B18_TOX_CODE ? "Toxicity treatment" : "Painkiller"] reservoir replenished.</span>")
			playsound(src,'sound/effects/refill.ogg', 25, 0, 1)

/obj/item/clothing/suit/storage/marine/specialist/verb/b18_automedic_toggle()
	set name = "Toggle B18 Automedic"
	set category = "B18 Armor"
	set src in usr

	if(usr.incapacitated() || usr != wearer )
		return 0

	if(B18_automed_on)
		b18automed_turn_off(usr)
	else
		b18automed_turn_on(usr)


/obj/item/clothing/suit/storage/marine/specialist/verb/b18_automedic_scan()
	set name = "B18 Automedic User Scan"
	set category = "B18 Armor"
	set src in usr

	if(usr.incapacitated() || usr != wearer )
		return 0

	B18_analyzer.attack(usr, usr, TRUE)

/obj/item/clothing/suit/storage/marine/specialist/verb/configure_automedic()
	set name = "Configure B18 Automedic"
	set category = "B18 Armor"
	set src in usr

	if(usr.incapacitated() || usr != wearer )
		return 0

	handle_interface(usr)

/obj/item/clothing/suit/storage/marine/specialist/proc/handle_interface(mob/living/carbon/human/user, flag1)
	user.set_interaction(src)
	var/dat = {"<TT>
	<A href='?src=\ref[src];B18_automed_on=1'>Turn Automed System: [B18_automed_on ? "Off" : "On"]</A><BR>
	<BR>
	<B>Integrated Health Analyzer:</B><BR>
	<A href='byond://?src=\ref[src];B18_analyzer=1'>Scan Wearer</A><BR>
	<A href='byond://?src=\ref[src];B18_toggle_mode=1'>Turn Scanner HUD Mode: [B18_analyzer.hud_mode ? "Off" : "On"]</A><BR>
	<BR>
	<B>Damage Trigger Threshold (Max 150, Min 50):</B><BR>
	<A href='byond://?src=\ref[src];B18_automed_damage=-50'>-50</A>
	<A href='byond://?src=\ref[src];B18_automed_damage=-10'>-10</A>
	<A href='byond://?src=\ref[src];B18_automed_damage=-5'>-5</A>
	<A href='byond://?src=\ref[src];B18_automed_damage=-1'>-1</A> [B18_automed_damage]
	<A href='byond://?src=\ref[src];B18_automed_damage=1'>+1</A>
	<A href='byond://?src=\ref[src];B18_automed_damage=5'>+5</A>
	<A href='byond://?src=\ref[src];B18_automed_damage=10'>+10</A>
	<A href='byond://?src=\ref[src];B18_automed_damage=50'>+50</A><BR>
	<BR>
	<B>Pain Trigger Threshold (Max 150, Min 50):</B><BR>
	<A href='byond://?src=\ref[src];B18_automed_pain=-50'>-50</A>
	<A href='byond://?src=\ref[src];B18_automed_pain=-10'>-10</A>
	<A href='byond://?src=\ref[src];B18_automed_pain=-5'>-5</A>
	<A href='byond://?src=\ref[src];B18_automed_pain=-1'>-1</A> [B18_automed_pain]
	<A href='byond://?src=\ref[src];B18_automed_pain=1'>+1</A>
	<A href='byond://?src=\ref[src];B18_automed_pain=5'>+5</A>
	<A href='byond://?src=\ref[src];B18_automed_pain=10'>+10</A>
	<A href='byond://?src=\ref[src];B18_automed_pain=50'>+50</A><BR>

	</TT>"}
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

//Interface for the B18
/obj/item/clothing/suit/storage/marine/specialist/Topic(href, href_list)
	//..()
	if(usr.incapacitated() || usr != wearer || !usr.IsAdvancedToolUser())
		return
	if(usr.contents.Find(src) )
		usr.set_interaction(src)
		if(href_list["B18_automed_on"])
			if(B18_automed_on)
				b18automed_turn_off(usr)
			else
				b18automed_turn_on(usr)

		else if(href_list["B18_analyzer"] && B18_analyzer && usr == wearer) //Integrated scanner
			B18_analyzer.attack(usr, usr, TRUE)

		else if(href_list["B18_toggle_mode"] && B18_analyzer && usr == wearer) //Integrated scanner
			B18_analyzer.hud_mode = !B18_analyzer.hud_mode
			switch (B18_analyzer.hud_mode)
				if(TRUE)
					to_chat(usr, "<span class='notice'>The scanner now shows results on the hud.</span>")
				if(FALSE)
					to_chat(usr, "<span class='notice'>The scanner no longer shows results on the hud.</span>")

		else if(href_list["B18_automed_damage"])
			B18_automed_damage += text2num(href_list["B18_automed_damage"])
			B18_automed_damage = round(B18_automed_damage)
			B18_automed_damage = CLAMP(B18_automed_damage,B18_DAMAGE_MIN,B18_DAMAGE_MAX)
		else if(href_list["B18_automed_pain"])
			B18_automed_pain += text2num(href_list["B18_automed_pain"])
			B18_automed_pain = round(B18_automed_pain)
			B18_automed_pain = CLAMP(B18_automed_pain,B18_PAIN_MIN,B18_PAIN_MAX)
		if(!( master ))
			if(ishuman(loc))
				handle_interface(loc)
			else
				for(var/mob/living/carbon/human/M in viewers(1, src))
					if(M.client)
						handle_interface(M)
		else
			if(ishuman(master.loc))
				handle_interface(master.loc)
			else
				for(var/mob/living/carbon/human/M in viewers(1, master))
					if(M.client)
						handle_interface(M)
	else
		usr << browse(null, "window=radio")

/obj/item/clothing/suit/storage/marine/M3T
	name = "\improper M3-T light armor"
	desc = "A custom set of M3 armor designed for users of long ranged explosive weaponry."
	icon_state = "demolitionist"
	armor = list("melee" = 65, "bullet" = 50, "laser" = 40, "energy" = 25, "bomb" = 50, "bio" = 10, "rad" = 10, "fire" = 25, "acid" = 25)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun/launcher/rocket)

/obj/item/clothing/suit/storage/marine/M3S
	name = "\improper M3-S light armor"
	desc = "A custom set of M3 armor designed for TGMC Scouts."
	icon_state = "scout_armor"
	armor = list("melee" = 65, "bullet" = 80, "laser" = 40, "energy" = 25, "bomb" = 35, "bio" = 10, "rad" = 10, "fire" = 25, "acid" = 25)
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/marine/M35
	name = "\improper M35 armor"
	desc = "A custom set of M35 armor designed for use by TGMC Pyrotechnicians. Contains thick kevlar shielding, partial environmental shielding and thermal dissipators."
	icon_state = "pyro_armor"
	armor = list("melee" = 70, "bullet" = 90, "laser" = 60, "energy" = 60, "bomb" = 30, "bio" = 30, "rad" = 50, "fire" = 60, "acid" = 60)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS|FEET
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS|FEET
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS|FEET

/obj/item/clothing/suit/storage/marine/sniper
	name = "\improper M3 pattern recon armor"
	desc = "A custom modified set of M3 armor designed for recon missions."
	icon_state = "marine_sniper"
	armor = list("melee" = 65, "bullet" = 70, "laser" = 40, "energy" = 25, "bomb" = 30, "bio" = 10, "rad" = 10, "fire" = 25, "acid" = 25)
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/marine/sniper/jungle
	name = "\improper M3 pattern marksman armor"
	icon_state = "marine_sniperm"

//=============================//PMCS\\==================================

/obj/item/clothing/suit/storage/marine/veteran
	flags_marine_armor = ARMOR_LAMP_OVERLAY

/obj/item/clothing/suit/storage/marine/veteran/PMC
	name = "\improper M4 pattern PMC armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind."
	icon_state = "pmc_armor"
	armor = list("melee" = 55, "bullet" = 62, "laser" = 42, "energy" = 38, "bomb" = 40, "bio" = 15, "rad" = 15, "fire" = 38, "acid" = 38)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife)

/obj/item/clothing/suit/storage/marine/veteran/PMC/leader
	name = "\improper M4 pattern PMC leader armor"
	desc = "A modification of the standard Armat Systems M3 armor. Designed for high-profile security operators and corporate mercenaries in mind. This particular suit looks like it belongs to a high-ranking officer."
	icon_state = "officer_armor"

/obj/item/clothing/suit/storage/marine/veteran/PMC/sniper
	name = "\improper M4 pattern PMC sniper armor"
	icon_state = "pmc_sniper"
	flags_armor_protection = CHEST|GROIN|LEGS
	flags_cold_protection = CHEST|GROIN|LEGS
	flags_heat_protection = CHEST|GROIN|LEGS
	armor = list("melee" = 60, "bullet" = 70, "laser" = 50, "energy" = 60, "bomb" = 65, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)
	flags_inventory = BLOCKSHARPOBJ
	flags_inv_hide = HIDELOWHAIR

/obj/item/clothing/suit/storage/marine/smartgunner/veteran/PMC
	name = "\improper PMC gunner armor"
	desc = "A modification of the standard Armat Systems M3 armor. Hooked up with harnesses and straps allowing the user to carry an M56 Smartgun."
	icon_state = "heavy_armor"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS
	armor = list("melee" = 85, "bullet" = 85, "laser" = 55, "energy" = 65, "bomb" = 70, "bio" = 20, "rad" = 20, "fire" = 65, "acid" = 65)

/obj/item/clothing/suit/storage/marine/veteran/PMC/commando
	name = "\improper PMC commando armor"
	desc = "A heavily armored suit built by who-knows-what for elite operations. It is a fully self-contained system and is heavily corrosion resistant."
	icon_state = "commando_armor"
	slowdown = SLOWDOWN_ARMOR_VERY_HEAVY
	armor = list("melee" = 90, "bullet" = 120, "laser" = 100, "energy" = 90, "bomb" = 90, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90)
	resistance_flags = UNACIDABLE

//===========================//DISTRESS\\================================

/obj/item/clothing/suit/storage/marine/veteran/bear
	name = "\improper H1 Iron Bears vest"
	desc = "A protective vest worn by Iron Bears mercenaries."
	icon_state = "bear_armor"
	flags_armor_protection = CHEST|GROIN
	armor = list("melee" = 70, "bullet" = 70, "laser" = 50, "energy" = 60, "bomb" = 50, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT

/obj/item/clothing/suit/storage/marine/veteran/dutch
	name = "\improper D2 armored vest"
	desc = "A protective vest worn by some seriously experienced mercs."
	icon_state = "dutch_armor"
	flags_armor_protection = CHEST|GROIN
	armor = list("melee" = 70, "bullet" = 85, "laser" = 55, "energy" = 65, "bomb" = 70, "bio" = 10, "rad" = 10, "fire" = 65, "acid" = 65)
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT


//===========================//I.o.M\\================================

/obj/item/clothing/suit/storage/marine/imperial
	name = "\improper Imperial Guard flak armour"
	desc = "A cheap, mass produced armour worn by the Imperial Guard, which are also cheap and mass produced. You can make out what appears to be <i>Cadia stands</i> carved into the armour."
	icon_state = "guardarmor"
	item_state = "guardarmor"
	armor = list("melee" = 75, "bullet" = 65, "laser" = 60, "energy" = 60, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60)

/obj/item/clothing/suit/storage/marine/imperial/sergeant
	// SL armour, better than flak, covers more
	name = "\improper Imperial Guard sergeant armour"
	desc = "A body armour that offers much better protection than the flak armour."
	icon_state = "guardSLarmor"
	item_state = "guardSLarmor"
	armor = list("melee" = 85, "bullet" = 85, "laser" = 85, "energy" = 85, "bomb" = 85, "bio" = 25, "rad" = 25, "fire" = 85, "acid" = 85)
	brightness_on = 6 // better light
	pockets = /obj/item/storage/internal/suit/imperial

/obj/item/storage/internal/suit/imperial
	storage_slots = 3
	max_storage_space = 6

/obj/item/clothing/suit/storage/marine/imperial/medicae
	name = "\improper Imperial Guard medicae armour"
	desc = "An armour worn by the medicae of the Imperial Guard."
	icon_state = "guardmedicarmor"
	item_state = "guardmedicarmor"

/obj/item/clothing/suit/storage/marine/imperial/sergeant/veteran
	name = "\improper Imperial Guard carapace armour"
	desc = "A heavy full body armour that protects the wearer a lot more than the flak armour, also slows down considerably."
	icon_state = "guardvetarmor"
	item_state = "guardvetarmor"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	armor = list("melee" = 90, "bullet" = 90, "laser" = 90, "energy" = 90, "bomb" = 90, "bio" = 30, "rad" = 30, "fire" = 90, "acid" = 90)

/obj/item/clothing/suit/storage/marine/imperial/power
	// Should this maybe require recharging?
	name = "\improper salvaged Space Marine power armour"
	desc = "A power armour that was once broken, is functional once again. However this version isn't as powerful as the real power armour."
	//icon_state
	armor = list("melee" = 75, "bullet" = 60, "laser" = 55, "energy" = 40, "bomb" = 45, "bio" = 15, "rad" = 15, "fire" = 40, "acid" = 40)
	brightness_on = 6
	pockets = /obj/item/storage/internal/suit/imperial

/obj/item/clothing/suit/storage/marine/imperial/power/astartes
	// This should either be admin only or only given to one person
	name = "\improper Space Marine power armour"
	desc = "You feel a chill running down your spine just looking at this. This is the power armour that the Space Marines wear themselves. The servos inside the power armour allow you to move at incredible speeds."
	//icon_state
	slowdown = SLOWDOWN_ARMOR_LIGHT // beefed up space marine inside an armor that boosts speed
	armor = list("melee" = 95, "bullet" = 95, "laser" = 95, "energy" = 95, "bomb" = 95, "bio" = 95, "rad" = 95, "fire" = 95, "acid" = 95)

//===========================//U.P.P\\================================

/obj/item/clothing/suit/storage/faction
	icon = 'icons/obj/clothing/cm_suits.dmi'
	sprite_sheet_id = 1
	flags_atom = CONDUCT
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	flags_cold_protection = CHEST|GROIN|ARMS|LEGS
	flags_heat_protection = CHEST|GROIN|ARMS|LEGS
	min_cold_protection_temperature = ARMOR_MIN_COLD_PROTECTION_TEMPERATURE
	max_heat_protection_temperature = ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE
	blood_overlay_type = "armor"
	armor = list("melee" = 50, "bullet" = 40, "laser" = 35, "energy" = 20, "bomb" = 25, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 20)
	siemens_coefficient = 0.7
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/large_holster/machete)
	var/brightness_on = 5 //Average attachable pocket light
	var/flashlight_cooldown = 0 //Cooldown for toggling the light
	var/locate_cooldown = 0 //Cooldown for SL locator
	var/armor_overlays["lamp"]
	actions_types = list(/datum/action/item_action/toggle)
	var/flags_faction_armor = ARMOR_LAMP_OVERLAY

/obj/item/clothing/suit/storage/faction/Initialize(mapload, ...)
	. = ..()
	armor_overlays = list("lamp")
	update_icon()

/obj/item/clothing/suit/storage/faction/update_icon(mob/user)
	var/image/I
	I = armor_overlays["lamp"]
	overlays -= I
	qdel(I)
	if(flags_faction_armor & ARMOR_LAMP_OVERLAY)
		I = image('icons/obj/clothing/cm_suits.dmi', src, flags_faction_armor & ARMOR_LAMP_ON? "lamp-on" : "lamp-off")
		armor_overlays["lamp"] = I
		overlays += I
	else armor_overlays["lamp"] = null
	if(user) user.update_inv_wear_suit()

/obj/item/clothing/suit/storage/faction/pickup(mob/user)
	if(flags_faction_armor & ARMOR_LAMP_ON && src.loc != user)
		user.SetLuminosity(brightness_on)
		SetLuminosity(0)
	..()

/obj/item/clothing/suit/storage/faction/dropped(mob/user)
	if(flags_faction_armor & ARMOR_LAMP_ON && src.loc != user)
		user.SetLuminosity(-brightness_on)
		SetLuminosity(brightness_on)
		toggle_armor_light() //turn the light off
	..()

/obj/item/clothing/suit/storage/faction/Destroy()
	if(ismob(src.loc))
		src.loc.SetLuminosity(-brightness_on)
	else
		SetLuminosity(0)
	. = ..()

/obj/item/clothing/suit/storage/faction/attack_self(mob/user)
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot turn the light on while in [user.loc].</span>")
		return

	if(flashlight_cooldown > world.time)
		return

	if(!ishuman(user)) return
	var/mob/living/carbon/human/H = user
	if(H.wear_suit != src) return

	toggle_armor_light(user)
	return 1

/obj/item/clothing/suit/storage/faction/item_action_slot_check(mob/user, slot)
	if(!ishuman(user)) return FALSE
	if(slot != SLOT_WEAR_SUIT) return FALSE
	return TRUE //only give action button when armor is worn.

/obj/item/clothing/suit/storage/faction/proc/toggle_armor_light(mob/user)
	flashlight_cooldown = world.time + 20 //2 seconds cooldown every time the light is toggled
	if(flags_faction_armor & ARMOR_LAMP_ON) //Turn it off.
		if(user) user.SetLuminosity(-brightness_on)
		else SetLuminosity(0)
	else //Turn it on.
		if(user) user.SetLuminosity(brightness_on)
		else SetLuminosity(brightness_on)

	flags_faction_armor ^= ARMOR_LAMP_ON

	playsound(src,'sound/machines/click.ogg', 15, 1)
	update_icon(user)

	update_action_button_icons()




/obj/item/clothing/suit/storage/faction/UPP
	name = "\improper UM5 personal armor"
	desc = "Standard body armor of the UPP military, the UM5 (Union Medium MK5) is a medium body armor, roughly on par with the venerable M3 pattern body armor in service with the TGMC."
	icon_state = "upp_armor"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	flags_armor_protection = CHEST|GROIN
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 60, "bomb" = 40, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)

/obj/item/clothing/suit/storage/faction/UPP/commando
	name = "\improper UM5CU personal armor"
	desc = "A modification of the UM5, designed for stealth operations."
	icon_state = "upp_armor_commando"
	slowdown = SLOWDOWN_ARMOR_LIGHT

/obj/item/clothing/suit/storage/faction/UPP/heavy
	name = "\improper UH7 heavy plated armor"
	desc = "An extremely heavy duty set of body armor in service with the UPP military, the UH7 (Union Heavy MK5) is known for being a rugged set of armor, capable of taking immesnse punishment."
	icon_state = "upp_armor_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_armor_protection = CHEST|GROIN|LEGS
	armor = list("melee" = 85, "bullet" = 85, "laser" = 50, "energy" = 60, "bomb" = 60, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)

/obj/item/clothing/suit/storage/marine/smartgunner/UPP
	name = "\improper UH7 heavy plated armor"
	desc = "An extremely heavy duty set of body armor in service with the UPP military, the UH7 (Union Heavy MK5) is known for being a rugged set of armor, capable of taking immesnse punishment."
	icon_state = "upp_armor_heavy"
	slowdown = SLOWDOWN_ARMOR_HEAVY
	flags_armor_protection = CHEST|GROIN
	armor = list("melee" = 85, "bullet" = 85, "laser" = 50, "energy" = 60, "bomb" = 60, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)

//===========================FREELANCER================================

/obj/item/clothing/suit/storage/faction/freelancer
	name = "\improper freelancer cuirass"
	desc = "A armored protective chestplate scrapped together from various plates. It keeps up remarkably well, as the craftsmanship is solid, and the design mirrors such armors in the UPP and the TGMC."
	icon_state = "freelancer_armor"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = CHEST|GROIN
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 60, "bomb" = 40, "bio" = 10, "rad" = 10, "fire" = 60, "acid" = 60)

//this one is for CLF
/obj/item/clothing/suit/storage/militia
	name = "\improper colonial militia hauberk"
	desc = "The hauberk of a colonist militia member, created from boiled leather and some modern armored plates. While primitive compared to most modern suits of armor, it gives the wearer almost perfect mobility, which suits the needs of the local colonists. "
	icon = 'icons/obj/clothing/cm_suits.dmi'
	icon_state = "rebel_armor"
	sprite_sheet_id = 1
	slowdown = SLOWDOWN_ARMOR_VERY_LIGHT
	flags_armor_protection = CHEST|GROIN|LEGS
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 30, "bomb" = 60, "bio" = 30, "rad" = 30, "fire" = 30, "acid" = 30)
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine,
		/obj/item/explosive/grenade,
		/obj/item/binoculars,
		/obj/item/weapon/combat_knife,
		/obj/item/storage/belt/sparepouch,
		/obj/item/storage/large_holster/machete,
		/obj/item/weapon/baseballbat)
	flags_cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/suit/storage/CMB
	name = "\improper CMB jacket"
	desc = "A green jacket worn by crew on the Colonial Marshals."
	icon_state = "CMB_jacket"
	blood_overlay_type = "coat"
	flags_armor_protection = CHEST|ARMS

/obj/item/clothing/suit/storage/RO
	name = "\improper RO jacket"
	desc = "A green jacket worn by TGMC personnel. The back has the flag of the TerraGov on it."
	icon_state = "RO_jacket"
	blood_overlay_type = "coat"
	flags_armor_protection = CHEST|ARMS

//===========================//HELGHAST - MERCENARY\\================================

/obj/item/clothing/suit/storage/marine/veteran/mercenary
	name = "\improper K12 ceramic plated armor"
	desc = "A set of grey, heavy ceramic armor with dark blue highlights. It is the standard uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_heavy_armor"
	armor = list("melee" = 75, "bullet" = 62, "laser" = 42, "energy" = 38, "bomb" = 40, "bio" = 15, "rad" = 15, "fire" = 38, "acid" = 38)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife)

/obj/item/clothing/suit/storage/marine/veteran/mercenary/miner
	name = "\improper Y8 armored miner vest"
	desc = "A set of beige, light armor built for protection while mining. It is a specialized uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_miner_armor"
	armor = list("melee" = 50, "bullet" = 42, "laser" = 42, "energy" = 38, "bomb" = 25, "bio" = 15, "rad" = 15, "fire" = 38, "acid" = 38)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife)

/obj/item/clothing/suit/storage/marine/veteran/mercenary/engineer
	name = "\improper Z7 armored engineer vest"
	desc = "A set of blue armor with yellow highlights built for protection while building in highly dangerous environments. It is a specialized uniform of a unknown mercenary group working in the sector"
	icon_state = "mercenary_engineer_armor"
	armor = list("melee" = 55, "bullet" = 52, "laser" = 42, "energy" = 38, "bomb" = 30, "bio" = 15, "rad" = 15, "fire" = 38, "acid" = 38)
	slowdown = SLOWDOWN_ARMOR_LIGHT
	allowed = list(/obj/item/weapon/gun,
		/obj/item/tank/emergency_oxygen,
		/obj/item/flashlight,
		/obj/item/ammo_magazine/,
		/obj/item/weapon/baton,
		/obj/item/handcuffs,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/tool/lighter,
		/obj/item/explosive/grenade,
		/obj/item/storage/bible,
		/obj/item/weapon/claymore/mercsword/machete,
		/obj/item/weapon/combat_knife)



/obj/item/clothing/suit/storage/marine/som
	name = "\improper S12 hauberk"
	desc = "A heavily modified piece of mining equipment remade for general purpose combat use. It's light but practically gives no armor."
	icon_state = "som_armor"
	item_state = "som_armor"
	slowdown = SLOWDOWN_ARMOR_LIGHT
	flags_armor_protection = CHEST|GROIN
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 30, "bio" = 5, "rad" = 5, "fire" = 30, "acid" = 30)


/obj/item/clothing/suit/storage/marine/som/veteran
	name = "\improper S12 combat Hauberk"
	desc = "A heavily modified piece of mining equipment remade for general purpose combat use. Seems to have been modifed much further than other pieces like it. Heavier but tougher because of it."
	icon_state = "som_armor_veteran"
	item_state = "som_armor_veteran"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	armor = list("melee" = 40, "bullet" = 40, "laser" = 30, "energy" = 40, "bomb" = 30, "bio" = 10, "rad" = 10, "fire" = 40, "acid" = 40)


/obj/item/clothing/suit/storage/marine/som/leader
	name = "\improper S13 leader hauberk"
	desc = "A heavily modified modified piece of mining equipment remade for general purpose combat use. Modified extensively than other pieces like it but heavier because of it."
	icon_state = "som_armor_leader"
	item_state = "som_armor_leader"
	slowdown = SLOWDOWN_ARMOR_MEDIUM
	flags_armor_protection = CHEST|GROIN|ARMS|LEGS
	armor = list("melee" = 50, "bullet" = 50, "laser" = 40, "energy" = 50, "bomb" = 40, "bio" = 15, "rad" = 15, "fire" = 50, "acid" = 50)