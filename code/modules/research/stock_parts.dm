/*Power cells are in code\modules\power\cell.dm

If you create T5+ please take a pass at gene_modder.dm [L40]. Max_values MUST fit with the clamp to not confuse the user or cause possible exploits.*/
/obj/item/storage/part_replacer
	name = "rapid part exchange device"
	desc = ""
	icon_state = "RPED"
	item_state = "RPED"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	component_type = /datum/component/storage/concrete/rped
	var/works_from_distance = FALSE
	var/pshoom_or_beepboopblorpzingshadashwoosh = 'sound/blank.ogg'
	var/alt_sound = null

/obj/item/storage/part_replacer/pre_attack(obj/machinery/T, mob/living/user, params)
	if(!istype(T) || !T.component_parts)
		return ..()
	if(user.Adjacent(T)) // no TK upgrading.
		if(works_from_distance)
			user.Beam(T, icon_state = "rped_upgrade", time = 5)
		T.exchange_parts(user, src)
		return TRUE
	return ..()

/obj/item/storage/part_replacer/afterattack(obj/machinery/T, mob/living/user, adjacent, params)
	if(adjacent || !istype(T) || !T.component_parts)
		return ..()
	if(works_from_distance)
		user.Beam(T, icon_state = "rped_upgrade", time = 5)
		T.exchange_parts(user, src)
		return
	return ..()

/obj/item/storage/part_replacer/proc/play_rped_sound()
	//Plays the sound for RPED exhanging or installing parts.
	if(alt_sound && prob(1))
		playsound(src, alt_sound, 40, TRUE)
	else
		playsound(src, pshoom_or_beepboopblorpzingshadashwoosh, 40, TRUE)

/obj/item/storage/part_replacer/bluespace
	name = "bluespace rapid part exchange device"
	desc = ""
	icon_state = "BS_RPED"
	w_class = WEIGHT_CLASS_NORMAL
	works_from_distance = TRUE
	pshoom_or_beepboopblorpzingshadashwoosh = 'sound/blank.ogg'
	alt_sound = 'sound/blank.ogg'
	component_type = /datum/component/storage/concrete/bluespace/rped

/obj/item/storage/part_replacer/bluespace/tier1

/obj/item/storage/part_replacer/bluespace/tier1/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/scanning_module(src)
		new /obj/item/stock_parts/manipulator(src)
		new /obj/item/stock_parts/micro_laser(src)
		new /obj/item/stock_parts/matter_bin(src)

/obj/item/storage/part_replacer/bluespace/tier2

/obj/item/storage/part_replacer/bluespace/tier2/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/adv(src)
		new /obj/item/stock_parts/scanning_module/adv(src)
		new /obj/item/stock_parts/manipulator/nano(src)
		new /obj/item/stock_parts/micro_laser/high(src)
		new /obj/item/stock_parts/matter_bin/adv(src)

/obj/item/storage/part_replacer/bluespace/tier3

/obj/item/storage/part_replacer/bluespace/tier3/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/super(src)
		new /obj/item/stock_parts/scanning_module/phasic(src)
		new /obj/item/stock_parts/manipulator/pico(src)
		new /obj/item/stock_parts/micro_laser/ultra(src)
		new /obj/item/stock_parts/matter_bin/super(src)

/obj/item/storage/part_replacer/bluespace/tier4

/obj/item/storage/part_replacer/bluespace/tier4/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor/quadratic(src)
		new /obj/item/stock_parts/scanning_module/triphasic(src)
		new /obj/item/stock_parts/manipulator/femto(src)
		new /obj/item/stock_parts/micro_laser/quadultra(src)
		new /obj/item/stock_parts/matter_bin/bluespace(src)

/obj/item/storage/part_replacer/cargo //used in a cargo crate

/obj/item/storage/part_replacer/cargo/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/stock_parts/capacitor(src)
		new /obj/item/stock_parts/scanning_module(src)
		new /obj/item/stock_parts/manipulator(src)
		new /obj/item/stock_parts/micro_laser(src)
		new /obj/item/stock_parts/matter_bin(src)

/obj/item/storage/part_replacer/cyborg
	name = "rapid part exchange device"
	desc = ""
	icon_state = "borgrped"
	item_state = "RPED"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

/proc/cmp_rped_sort(obj/item/A, obj/item/B)
	return B.get_part_rating() - A.get_part_rating()

/obj/item/stock_parts
	name = "stock part"
	desc = ""
	icon = 'icons/obj/stock_parts.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/rating = 1

/obj/item/stock_parts/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/stock_parts/get_part_rating()
	return rating

//Rating 1

/obj/item/stock_parts/capacitor
	name = "capacitor"
	desc = ""
	icon_state = "capacitor"
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/scanning_module
	name = "scanning module"
	desc = ""
	icon_state = "scan_module"
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/manipulator
	name = "micro-manipulator"
	desc = ""
	icon_state = "micro_mani"
	custom_materials = list(/datum/material/iron=30)

/obj/item/stock_parts/micro_laser
	name = "micro-laser"
	desc = ""
	icon_state = "micro_laser"
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/matter_bin
	name = "matter bin"
	desc = ""
	icon_state = "matter_bin"
	custom_materials = list(/datum/material/iron=80)

//Rating 2

/obj/item/stock_parts/capacitor/adv
	name = "advanced capacitor"
	desc = ""
	icon_state = "adv_capacitor"
	rating = 2
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/scanning_module/adv
	name = "advanced scanning module"
	desc = ""
	icon_state = "adv_scan_module"
	rating = 2
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/manipulator/nano
	name = "nano-manipulator"
	desc = ""
	icon_state = "nano_mani"
	rating = 2
	custom_materials = list(/datum/material/iron=30)

/obj/item/stock_parts/micro_laser/high
	name = "high-power micro-laser"
	desc = ""
	icon_state = "high_micro_laser"
	rating = 2
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/matter_bin/adv
	name = "advanced matter bin"
	desc = ""
	icon_state = "advanced_matter_bin"
	rating = 2
	custom_materials = list(/datum/material/iron=80)

//Rating 3

/obj/item/stock_parts/capacitor/super
	name = "super capacitor"
	desc = ""
	icon_state = "super_capacitor"
	rating = 3
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/scanning_module/phasic
	name = "phasic scanning module"
	desc = ""
	icon_state = "super_scan_module"
	rating = 3
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/manipulator/pico
	name = "pico-manipulator"
	desc = ""
	icon_state = "pico_mani"
	rating = 3
	custom_materials = list(/datum/material/iron=30)

/obj/item/stock_parts/micro_laser/ultra
	name = "ultra-high-power micro-laser"
	icon_state = "ultra_high_micro_laser"
	desc = ""
	rating = 3
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/matter_bin/super
	name = "super matter bin"
	desc = ""
	icon_state = "super_matter_bin"
	rating = 3
	custom_materials = list(/datum/material/iron=80)

//Rating 4

/obj/item/stock_parts/capacitor/quadratic
	name = "quadratic capacitor"
	desc = ""
	icon_state = "quadratic_capacitor"
	rating = 4
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=50)

/obj/item/stock_parts/scanning_module/triphasic
	name = "triphasic scanning module"
	desc = ""
	icon_state = "triphasic_scan_module"
	rating = 4
	custom_materials = list(/datum/material/iron=50, /datum/material/glass=20)

/obj/item/stock_parts/manipulator/femto
	name = "femto-manipulator"
	desc = ""
	icon_state = "femto_mani"
	rating = 4
	custom_materials = list(/datum/material/iron=30)

/obj/item/stock_parts/micro_laser/quadultra
	name = "quad-ultra micro-laser"
	icon_state = "quadultra_micro_laser"
	desc = ""
	rating = 4
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=20)

/obj/item/stock_parts/matter_bin/bluespace
	name = "bluespace matter bin"
	desc = ""
	icon_state = "bluespace_matter_bin"
	rating = 4
	custom_materials = list(/datum/material/iron=80)

// Subspace stock parts

/obj/item/stock_parts/subspace/ansible
	name = "subspace ansible"
	icon_state = "subspace_ansible"
	desc = ""
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/filter
	name = "hyperwave filter"
	icon_state = "hyperwave_filter"
	desc = ""
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/amplifier
	name = "subspace amplifier"
	icon_state = "subspace_amplifier"
	desc = ""
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/treatment
	name = "subspace treatment disk"
	icon_state = "treatment_disk"
	desc = ""
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/analyzer
	name = "subspace wavelength analyzer"
	icon_state = "wavelength_analyzer"
	desc = ""
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)

/obj/item/stock_parts/subspace/crystal
	name = "ansible crystal"
	icon_state = "ansible_crystal"
	desc = ""
	custom_materials = list(/datum/material/glass=50)

/obj/item/stock_parts/subspace/transmitter
	name = "subspace transmitter"
	icon_state = "subspace_transmitter"
	desc = ""
	custom_materials = list(/datum/material/iron=50)

/obj/item/research//Makes testing much less of a pain -Sieve
	name = "research"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"
	desc = ""
