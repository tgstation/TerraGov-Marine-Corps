/obj/item/disk/botany
	name = "flora data disk"
	desc = "A small disk used for carrying data on plant genetics."
	icon = 'icons/obj/items/disk.dmi'
	icon_state = "botanydisk"
	w_class = WEIGHT_CLASS_TINY

	var/list/genes = list()
	var/genesource = "unknown"

/obj/item/disk/botany/Initialize(mapload)
	. = ..()
	pixel_x = rand(-5,5)
	pixel_y = rand(-5,5)

/obj/item/disk/botany/attack_self(mob/user as mob)
	if(length(genes))
		var/choice = tgui_alert(user, "Are you sure you want to wipe the disk?", "Xenobotany Data", list("No", "Yes"))
		if(src && user && genes && choice == "Yes")
			to_chat(user, "You wipe the disk data.")
			name = initial(name)
			desc = initial(name)
			genes = list()
			genesource = "unknown"

/obj/item/storage/box/botanydisk
	name = "flora disk box"
	desc = "A box of flora data disks, apparently."
	spawn_type = /obj/item/disk/botany
	spawn_number = 7

/obj/machinery/botany
	icon = 'icons/obj/machines/hydroponics.dmi'
	icon_state = "hydrotray3"
	density = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	interaction_flags = INTERACT_MACHINE_TGUI

	var/obj/item/seeds/seed // Currently loaded seed packet.
	var/obj/item/disk/botany/loaded_disk //Currently loaded data disk.

	var/open = 0
	var/active = 0
	var/action_time = 50
	var/last_action = 0
	var/eject_disk = 0
	var/failed_task = 0
	var/disk_needs_genes = 0

/obj/machinery/botany/process()

	..()
	if(!active) return

	if(world.time > last_action + action_time)
		finished_task()


/obj/machinery/botany/proc/finished_task()
	active = 0
	if(failed_task)
		failed_task = 0
		visible_message("[icon2html(src, viewers(src))] [src] pings unhappily, flashing a red warning light.")
	else
		visible_message("[icon2html(src, viewers(src))] [src] pings happily.")

	if(eject_disk)
		eject_disk = 0
		if(loaded_disk)
			loaded_disk.loc = get_turf(src)
			visible_message("[icon2html(src, viewers(src))] [src] beeps and spits out [loaded_disk].")
			loaded_disk = null
	stop_processing()

/obj/machinery/botany/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(.)
		return

	if(istype(I, /obj/item/seeds))
		if(seed)
			to_chat(user, "There is already a seed loaded.")
			return
		var/obj/item/seeds/S = I
		if(S.seed?.immutable > 0)
			to_chat(user, "That seed is not compatible with our genetics technology.")
			return

		user.drop_held_item()
		I.forceMove(src)
		seed = I
		to_chat(user, "You load [I] into [src].")

	else if(isscrewdriver(I))
		open = !open
		to_chat(user, span_notice("You [open ? "open" : "close"] the maintenance panel."))

	else if(iscrowbar(I) && open)
		deconstruct()

	else if(istype(I, /obj/item/disk/botany))
		var/obj/item/disk/botany/B = I

		if(loaded_disk)
			to_chat(user, "There is already a data disk loaded.")
			return

		if(length(B.genes) && !disk_needs_genes)
			to_chat(user, "That disk already has gene data loaded.")
			return
		else if(disk_needs_genes)
			to_chat(user, "That disk does not have any gene data loaded.")
			return

		user.drop_held_item()
		I.forceMove(src)
		loaded_disk = I
		to_chat(user, "You load [I] into [src].")

// Allows for a trait to be extracted from a seed packet, destroying that seed.
/obj/machinery/botany/extractor
	name = "lysis-isolation centrifuge"
	icon_state = "traitcopier"

	var/datum/seed/genetics // Currently scanned seed genetic structure.
	var/degradation = 0     // Increments with each scan, stops allowing gene mods after a certain point.

/obj/machinery/botany/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["eject_packet"])
		if(!seed) return
		seed.loc = get_turf(src)

		if(seed.seed.name == "new line" || isnull(GLOB.seed_types[seed.seed.name]))
			seed.seed.uid = length(GLOB.seed_types) + 1
			seed.seed.name = "[seed.seed.uid]"
			GLOB.seed_types[seed.seed.name] = seed.seed

		seed.update_seed()
		visible_message("[icon2html(src, viewers(src))] [src] beeps and spits out [seed].")

		seed = null

	if(href_list["eject_disk"])
		if(!loaded_disk) return
		loaded_disk.loc = get_turf(src)
		visible_message("[icon2html(src, viewers(src))] [src] beeps and spits out [loaded_disk].")
		loaded_disk = null


/obj/machinery/botany/extractor/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["scan_genome"])

		if(!seed) return

		last_action = world.time
		active = 1
		start_processing()

		if(seed?.seed)
			genetics = seed.seed
			degradation = 0

		qdel(seed)
		seed = null

	if(href_list["get_gene"])

		if(!genetics || !loaded_disk) return

		last_action = world.time
		active = 1
		start_processing()

		var/datum/plantgene/P = genetics.get_gene(href_list["get_gene"])
		if(!P) return
		loaded_disk.genes += P

		loaded_disk.genesource = "[genetics.display_name]"
		if(!genetics.roundstart)
			loaded_disk.genesource += " (variety #[genetics.uid])"

		loaded_disk.name += " ([GLOB.gene_tag_masks[href_list["get_gene"]]], #[genetics.uid])"
		loaded_disk.desc += " The label reads \'gene [GLOB.gene_tag_masks[href_list["get_gene"]]], sampled from [genetics.display_name]\'."
		eject_disk = 1

		degradation += rand(20,60)
		if(degradation >= 100)
			failed_task = 1
			genetics = null
			degradation = 0

	if(href_list["clear_buffer"])
		if(!genetics) return
		genetics = null
		degradation = 0

	updateUsrDialog()


// Fires an extracted trait into another packet of seeds with a chance
// of destroying it based on the size/complexity of the plasmid.
/obj/machinery/botany/editor
	name = "bioballistic delivery system"
	icon_state = "traitgun"
	disk_needs_genes = 1

/obj/machinery/botany/editor/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["apply_gene"])
		if(!loaded_disk || !seed) return

		last_action = world.time
		active = 1
		start_processing()

		if(!isnull(GLOB.seed_types[seed.seed.name]))
			seed.seed = seed.seed.diverge(1)
			seed.seed_type = seed.seed.name
			seed.update_seed()

		if(prob(seed.modified))
			failed_task = 1
			seed.modified = 101

		for(var/datum/plantgene/gene in loaded_disk.genes)
			seed.seed.apply_gene(gene)
			seed.modified += rand(5,10)
