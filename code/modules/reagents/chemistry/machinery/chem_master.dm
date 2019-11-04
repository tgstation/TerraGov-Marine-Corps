/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to separate chemicals and distribute them in a variety of forms."
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = UNACIDABLE
	ui_x = 465
	ui_y = 550
	interaction_flags = INTERACT_MACHINE_TGUI

	var/obj/item/reagent_containers/beaker = null
	var/obj/item/storage/pill_bottle/bottle = null
	var/mode = 1
	var/condi = FALSE
	var/chosenPillStyle = 1
	var/screen = "home"
	var/list/analyzeVars = list()
	var/useramount = 30 // Last used amount
	var/list/pillStyles = null

/obj/machinery/chem_master/Initialize()
	create_reagents(100)

	//Calculate the span tags and ids fo all the available pill icons
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
	pillStyles = list()
	for (var/x in 1 to PILL_STYLE_COUNT)
		var/list/SL = list()
		SL["id"] = x
		SL["className"] = assets.icon_class_name("pill[x]")
		pillStyles += list(SL)

	. = ..()

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(bottle)
	return ..()

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return

/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers) && !(I.flags_item & ITEM_ABSTRACT) && I.is_open_container())
		. = TRUE // no afterattack
		if(machine_stat & PANEL_OPEN)
			to_chat(user, "<span class='warning'>You can't use the [src.name] while its panel is opened!</span>")
			return
		var/obj/item/reagent_containers/B = I
		. = TRUE // no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		updateUsrDialog()
		update_icon()
	else if(!condi && istype(I, /obj/item/storage/pill_bottle))
		if(bottle)
			to_chat(user, "<span class='warning'>A pill bottle is already loaded into [src]!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		bottle = I
		to_chat(user, "<span class='notice'>You add [I] into the dispenser slot.</span>")
		updateUsrDialog()
	else
		return ..()

/obj/machinery/chem_master/AltClick(mob/living/user)
	if(!istype(user) || !can_interact(user))
		return
	replace_beaker(user)
	return

/obj/machinery/chem_master/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(beaker)
		beaker.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(beaker)
	if(new_beaker)
		beaker = new_beaker
	else
		beaker = null
	update_icon()
	return TRUE

/obj/machinery/chem_master/on_deconstruction()
	replace_beaker()
	if(bottle)
		bottle.forceMove(drop_location())
		adjust_item_drop_location(bottle)
		bottle = null
	return ..()

/obj/machinery/chem_master/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
		assets.send(user)

		ui = new(user, src, ui_key, "chem_master", name, ui_x, ui_y, master_ui, state)
		ui.open()

//Insert our custom spritesheet css link into the html
/obj/machinery/chem_master/ui_base_html(html)
	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
	. = replacetext(html, "<!--customheadhtml-->", assets.css_tag())

/obj/machinery/chem_master/ui_data(mob/user)
	var/list/data = list()
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["mode"] = mode
	data["condi"] = condi
	data["screen"] = screen
	data["analyzeVars"] = analyzeVars
	data["chosenPillStyle"] = chosenPillStyle
	data["isPillBottleLoaded"] = bottle ? 1 : 0
	if(bottle)
		data["pillBottleCurrentAmount"] = length(bottle.contents)
		data["pillBottleMaxAmount"] = bottle.max_storage_space

	var/list/beakerContents = list()
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id" = ckey(R.name), "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	var/list/bufferContents = list()
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			bufferContents.Add(list(list("name" = N.name, "id" = ckey(N.name), "volume" = N.volume))) // ^
	data["bufferContents"] = bufferContents

	//Calculated at init time as it never changes
	data["pillStyles"] = pillStyles
	return data

/obj/machinery/chem_master/ui_act(action, params)
	if(..())
		return

	if(action == "eject")
		replace_beaker(usr)
		return TRUE

	if(action == "ejectPillBottle")
		if(!bottle)
			return FALSE
		bottle.forceMove(drop_location())
		adjust_item_drop_location(bottle)
		bottle = null
		return TRUE

	if(action == "transfer")
		if(!beaker)
			return FALSE
		var/reagent = GLOB.name2reagent[params["id"]]
		var/amount = text2num(params["amount"])
		var/to_container = params["to"]
		// Custom amount
		if (amount == -1)
			amount = text2num(input(
				"Enter the amount you want to transfer:",
				name, ""))
		if (amount == null || amount <= 0)
			return FALSE
		if (to_container == "buffer")
			beaker.reagents.trans_id_to(src, reagent, amount)
			return TRUE
		if (to_container == "beaker" && mode)
			reagents.trans_id_to(beaker, reagent, amount)
			return TRUE
		if (to_container == "beaker" && !mode)
			reagents.remove_reagent(reagent, amount)
			return TRUE
		return FALSE

	if(action == "toggleMode")
		mode = !mode
		return TRUE

	if(action == "pillStyle")
		var/id = text2num(params["id"])
		chosenPillStyle = id
		return TRUE

	if(action == "create")
		if(reagents.total_volume == 0)
			return FALSE
		var/item_type = params["type"]
		// Get amount of items
		var/amount = text2num(params["amount"])
		if(amount == null)
			amount = text2num(input(usr,
				"Max 10. Buffer content will be split evenly.",
				"How many to make?", 1))
		amount = CLAMP(round(amount), 0, 10)
		if (amount <= 0)
			return FALSE
		// Get units per item
		var/vol_each = text2num(params["volume"])
		var/vol_each_text = params["volume"]
		var/vol_each_max = reagents.total_volume / amount
		if (item_type == "pill")
			vol_each_max = min(50, vol_each_max)
		else if (item_type == "patch")
			vol_each_max = min(40, vol_each_max)
		else if (item_type == "bottle")
			vol_each_max = min(30, vol_each_max)
		else if (item_type == "condimentPack")
			vol_each_max = min(10, vol_each_max)
		else if (item_type == "condimentBottle")
			vol_each_max = min(50, vol_each_max)
		else
			return FALSE
		if(vol_each_text == "auto")
			vol_each = vol_each_max
		if(vol_each == null)
			vol_each = text2num(input(usr,
				"Maximum [vol_each_max] units per item.",
				"How many units to fill?",
				vol_each_max))
		vol_each = CLAMP(round(vol_each), 0, vol_each_max)
		if(vol_each <= 0)
			return FALSE
		// Get item name
		var/name = params["name"]
		var/name_has_units = item_type == "pill" || item_type == "patch"
		if(!name)
			var/name_default = reagents.get_master_reagent_name()
			if (name_has_units)
				name_default += " ([vol_each]u)"
			name = stripped_input(usr,
				"Name:",
				"Give it a name!",
				name_default,
				MAX_NAME_LEN)
		if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, !issilicon(usr)))
			return FALSE
		// Start filling
		if(item_type == "pill")
			var/obj/item/reagent_containers/pill/P
			var/target_loc = drop_location()
			var/drop_threshold = INFINITY
			if(bottle)
				drop_threshold = bottle.max_storage_space - length(bottle.contents)
			for(var/i = 0; i < amount; i++)
				if(i < drop_threshold)
					P = new/obj/item/reagent_containers/pill(target_loc)
				else
					P = new/obj/item/reagent_containers/pill(drop_location())
				P.name = trim("[name] pill")
				if(chosenPillStyle == RANDOM_PILL_STYLE)
					P.icon_state ="pill[rand(1,21)]"
				else
					P.icon_state = "pill[chosenPillStyle]"
				if(P.icon_state == "pill4")
					P.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty and the brutal truths of reality."
				adjust_item_drop_location(P)
				reagents.trans_to(P, vol_each)
			return TRUE
		if(item_type == "bottle")
			var/obj/item/reagent_containers/glass/bottle/P
			for(var/i = 0; i < amount; i++)
				P = new/obj/item/reagent_containers/glass/bottle(drop_location())
				P.name = trim("[name] bottle")
				adjust_item_drop_location(P)
				reagents.trans_to(P, vol_each)
			return TRUE
		if(item_type == "condimentBottle")
			var/obj/item/reagent_containers/food/condiment/P
			for(var/i = 0; i < amount; i++)
				P = new/obj/item/reagent_containers/food/condiment(drop_location())
				//P.originalname = name
				P.name = trim("[name] bottle")
				reagents.trans_to(P, vol_each)
			return TRUE
		return FALSE

	if(action == "analyze")
		var/datum/reagent/R = GLOB.name2reagent[params["id"]]
		if(R)
			var/state = "Unknown"
			if(initial(R.reagent_state) == 1)
				state = "Solid"
			else if(initial(R.reagent_state) == 2)
				state = "Liquid"
			else if(initial(R.reagent_state) == 3)
				state = "Gas"
			var/const/P = 3 //The number of seconds between life ticks
			var/T = initial(R.custom_metabolism) * (60 / P)
			analyzeVars = list("name" = initial(R.name), "state" = state, "color" = initial(R.color), "description" = initial(R.description), "metaRate" = T, "overD" = initial(R.overdose_threshold), "addicD" = initial(R.addiction_threshold))
			screen = "analyze"
			return TRUE

	if(action == "goScreen")
		screen = params["screen"]
		return TRUE

	return FALSE

/obj/machinery/chem_master/proc/isgoodnumber(num)
	if(isnum(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 0
		else
			num = round(num)
		return num
	else
		return 0
/*
/obj/machinery/chem_master/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(!ishuman(usr))
		return

	var/mob/living/carbon/human/user = usr

	if (href_list["ejectp"])
		if(!bottle)
			return FALSE
		bottle.forceMove(drop_location())
		adjust_item_drop_location(bottle)
		bottle = null
		return TRUE

	if(beaker)
		if (href_list["analyze"])
			var/dat = ""
			if(!condi)
				var/reag_path = text2path(href_list["reag_type"])
				if(ispath(reag_path, /datum/reagent/blood))
					var/datum/reagent/blood/G
					for(var/datum/reagent/F in beaker.reagents.reagent_list)
						if(F.name == href_list["name"])
							G = F
							break
					var/A = G.name
					var/B = G.data["blood_type"]
					var/C = G.data["blood_DNA"]
					dat += "Chemical infos:<BR><BR>Name:<BR>[A]<BR><BR>Description:<BR>Blood Type: [B]<br>DNA: [C]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
				else
					dat += "Chemical infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			else
				dat += "Condiment infos:<BR><BR>Name:<BR>[href_list["name"]]<BR><BR>Description:<BR>[href_list["desc"]]<BR><BR><BR><A href='?src=\ref[src];main=1'>(Back)</A>"
			var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Chemmaster 3000</div>", 575, 400)
			popup.set_content(dat)
			popup.open(FALSE)
			return

		else if (href_list["add"])

			if(href_list["amount"])
				var/id = text2path(href_list["add"])
				var/amount = text2num(href_list["amount"])
				if(amount < 0) //href protection
					log_admin_private("[key_name(usr)] attempted to add a negative amount of [id] ([amount]) to the buffer of [src] at [AREACOORD(usr.loc)].")
					message_admins("[ADMIN_TPMONTY(usr)] attempted to add a negative amount of [id] ([amount]) to the buffer of [src]. Possible HREF exploit.")
					return
				transfer_chemicals(src, beaker, amount, id)

		else if (href_list["addcustom"])

			var/id = text2path(href_list["addcustom"])
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			transfer_chemicals(src, beaker, useramount, id)

		else if (href_list["remove"])

			if(href_list["amount"])
				var/id = text2path(href_list["remove"])
				var/amount = text2num(href_list["amount"])
				if(amount < 0) //href protection
					log_admin_private("[key_name(usr)] attempted to transfer a negative amount of [id] ([amount]) to [mode ? beaker : "disposal"] in [src] at [AREACOORD(usr.loc)].")
					message_admins("[ADMIN_TPMONTY(usr)] attempted to transfer a negative amount of [id] ([amount]) to [mode ? beaker : "disposal"] in [src]. Possible HREF exploit.")
					return
				if(mode)
					transfer_chemicals(beaker, src, amount, id)
				else
					transfer_chemicals(null, src, amount, id)


		else if (href_list["removecustom"])

			var/id = text2path(href_list["removecustom"])
			useramount = input("Select the amount to transfer.", 30, useramount) as num
			if(mode)
				transfer_chemicals(beaker, src, useramount, id)
			else
				transfer_chemicals(null, src, useramount, id)

		else if (href_list["toggle"])
			mode = !mode

		else if (href_list["main"])
			attack_hand(user)
			return
		else if (href_list["eject"])
			replace_beaker(usr)
			return TRUE

		else if (href_list["createpillbottle"])
			if(!condi)
				if(bottle)
					to_chat(user, "<span class='warning'>A pill bottle is already loaded into the machine.</span>")
					return
				var/obj/item/storage/pill_bottle/I = new/obj/item/storage/pill_bottle
				I.icon_state = "pill_canister"+pillbottlesprite
				bottle = I
				to_chat(user, "<span class='notice'>The Chemmaster 3000 sets a pill bottle into the dispenser slot.</span>")
				updateUsrDialog()

		else if (href_list["createpill"] || href_list["createpill_multiple"])
			var/count = 1

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			if (href_list["createpill_multiple"])
				count = CLAMP(input("Select the number of pills to make. (max: [max_pill_count])", 16, pillamount) as num|null,0,max_pill_count)
				if(!count)
					return

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			var/amount_per_pill = reagents.total_volume/count
			if (amount_per_pill > 15) amount_per_pill = 15

			var/name = reject_bad_text(input(user,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill] units)") as text|null)
			if(!name)
				return

			if(reagents.total_volume/count < 1) //Sanity checking.
				return
			while (count--)
				var/obj/item/reagent_containers/pill/P = new/obj/item/reagent_containers/pill(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = name
				P.pill_desc = "A [name] pill."
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "pill"+pillsprite
				reagents.trans_to(P,amount_per_pill)
				if(bottle)
					if(length(bottle.contents) < bottle.max_storage_space)
						bottle.handle_item_insertion(P, TRUE)
						updateUsrDialog()

		else if (href_list["createbottle"])
			if(!condi)
				var/name = reject_bad_text(input(user,"Name:","Name your bottle!",reagents.get_master_reagent_name()) as text|null)
				if(!name)
					return
				var/obj/item/reagent_containers/glass/bottle/P = new/obj/item/reagent_containers/glass/bottle(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] bottle"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "bottle-"+bottlesprite
				reagents.trans_to(P,60)
				P.update_icon()
			else
				var/obj/item/reagent_containers/food/condiment/P = new/obj/item/reagent_containers/food/condiment(loc)
				reagents.trans_to(P,50)

		else if (href_list["createautoinjector"])
			if(!condi)
				var/name = reject_bad_text(input(user,"Name:","Name your autoinjector!",reagents.get_master_reagent_name()) as text|null)
				if(!name)
					return
				var/obj/item/reagent_containers/hypospray/autoinjector/fillable/P = new/obj/item/reagent_containers/hypospray/autoinjector/fillable(loc)
				if(!name) name = reagents.get_master_reagent_name()
				P.name = "[name] autoinjector"
				P.pixel_x = rand(-7, 7) //random position
				P.pixel_y = rand(-7, 7)
				P.icon_state = "autoinjector-"+autoinjectorsprite
				reagents.trans_to(P,30)
				P.update_icon()

		else if(href_list["change_pill_bottle"])
			#define MAX_PILL_BOTTLE_SPRITE 12 //max icon state of the pill sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_PILL_BOTTLE_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&pill_bottle_sprite=[i]\">Select</a><img src=\"pill_canister[i].png\" /><br></td></tr>"
			dat += "</table>"
			var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Change Pill Bottle</div>")
			popup.set_content(dat)
			popup.open(FALSE)
			return

		else if(href_list["change_pill"])
			#define MAX_PILL_SPRITE 21 //max icon state of the pill sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_PILL_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&pill_sprite=[i]\">Select</a><img src=\"pill[i].png\" /><br></td></tr>"
			dat += "</table>"
			var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Change Pill</div>")
			popup.set_content(dat)
			popup.open(FALSE)
			return

		else if(href_list["change_bottle"])
			#define MAX_BOTTLE_SPRITE 4 //max icon state of the bottle sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&bottle_sprite=[i]\">Select</a><img src=\"bottle-[i].png\" /><br></td></tr>"
			dat += "</table>"
			var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Change Bottle</div>")
			popup.set_content(dat)
			popup.open(FALSE)
			return

		else if(href_list["change_autoinjector"])
			#define MAX_AUTOINJECTOR_SPRITE 11 //max icon state of the autoinjector sprites
			var/dat = "<table>"
			for(var/i = 1 to MAX_AUTOINJECTOR_SPRITE)
				dat += "<tr><td><a href=\"?src=\ref[src]&autoinjector_sprite=[i]\">Select</a><img src=\"autoinjector-[i].png\" /><br></td></tr>"
			dat += "</table>"
			var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Change Autoinjector</div>")
			popup.set_content(dat)
			popup.open(FALSE)
			return

		else if(href_list["pill_bottle_sprite"])
			pillbottlesprite = href_list["pill_bottle_sprite"]
		else if(href_list["pill_sprite"])
			pillsprite = href_list["pill_sprite"]
		else if(href_list["bottle_sprite"])
			bottlesprite = href_list["bottle_sprite"]
		else if(href_list["autoinjector_sprite"])
			autoinjectorsprite = href_list["autoinjector_sprite"]

	updateUsrDialog()


/obj/machinery/chem_master/interact(mob/user)
	. = ..()
	if(.)
		return
	if(!(user.client in has_sprites))
		spawn()
			has_sprites += user.client
			for(var/i = 1 to MAX_PILL_BOTTLE_SPRITE)
				user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "pill_canister" + num2text(i)), "pill_canister[i].png")
			for(var/i = 1 to MAX_PILL_SPRITE)
				user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "pill" + num2text(i)), "pill[i].png")
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "bottle-" + num2text(i)), "bottle-[i].png")
			for(var/i = 1 to MAX_AUTOINJECTOR_SPRITE)
				user << browse_rsc(icon('icons/obj/items/syringe.dmi', "autoinjector-" + num2text(i)), "autoinjector-[i].png")
	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		if(bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[length(bottle.contents)]/[bottle.max_storage_space]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
	else
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[length(bottle.contents)]/[bottle.max_storage_space]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
		if(!beaker.reagents.total_volume)
			dat += "Beaker is empty."
		else
			dat += "Add to buffer:<BR>"
			for(var/datum/reagent/G in beaker.reagents.reagent_list)
				dat += "[G.name] , [G.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[G.description];name=[G.name];reag_type=[G.type]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];add=[G.type];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];add=[G.type];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];add=[G.type];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];add=[G.type];amount=[G.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];addcustom=[G.type]'>(Custom)</A><BR>"

		dat += "<HR>Transfer to <A href='?src=\ref[src];toggle=1'>[(!mode ? "disposal" : "beaker")]:</A><BR>"
		if(reagents.total_volume)
			for(var/datum/reagent/N in reagents.reagent_list)
				dat += "[N.name] , [N.volume] Units - "
				dat += "<A href='?src=\ref[src];analyze=1;desc=[N.description];name=[N.name];reag_type=[N.type]'>(Analyze)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.type];amount=1'>(1)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.type];amount=5'>(5)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.type];amount=10'>(10)</A> "
				dat += "<A href='?src=\ref[src];remove=[N.type];amount=[N.volume]'>(All)</A> "
				dat += "<A href='?src=\ref[src];removecustom=[N.type]'>(Custom)</A><BR>"
		else
			dat += "Empty<BR>"
		if(!condi)
			dat += "<HR><BR><A href='?src=\ref[src];createpillbottle=1'>Load pill bottle</A><a href=\"?src=\ref[src]&change_pill_bottle=1\">Change</a><img src=\"pill_canister[pillbottlesprite].png\" /><BR>"
			dat += "<A href='?src=\ref[src];createpill=1'>Create pill (15 units max)</A><a href=\"?src=\ref[src]&change_pill=1\">Change</a><img src=\"pill[pillsprite].png\" /><BR>"
			dat += "<A href='?src=\ref[src];createpill_multiple=1'>Create multiple pills</A><BR>"
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (60 units max)<a href=\"?src=\ref[src]&change_bottle=1\">Change</A><img src=\"bottle-[bottlesprite].png\" /><BR>"
			dat += "<A href='?src=\ref[src];createautoinjector=1'>Create autoinjector (30 units max)<a href=\"?src=\ref[src]&change_autoinjector=1\">Change</A><img src=\"autoinjector-[autoinjectorsprite].png\" />"
		else
			dat += "<A href='?src=\ref[src];createbottle=1'>Create bottle (50 units max)</A>"

	var/datum/browser/popup = new(user, "chem_master", "<div align='center'>Chemmaster menu</div>", 575, 450)
	popup.set_content(dat)
	popup.open()
*/

/obj/machinery/chem_master/adjust_item_drop_location(atom/movable/AM) // Special version for chemmasters and condimasters
	if (AM == beaker)
		AM.pixel_x = -8
		AM.pixel_y = 8
		return null
	else if (AM == bottle)
		if (length(bottle.contents))
			AM.pixel_x = -13
		else
			AM.pixel_x = -7
		AM.pixel_y = -8
		return null
	else
		var/md5 = md5(AM.name)
		for (var/i in 1 to 32)
			. += hex2num(md5[i])
		. = . % 9
		AM.pixel_x = ((.%3)*6)
		AM.pixel_y = -8 + (round( . / 3)*8)

/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	desc = "Used to create condiments and other cooking supplies."
	condi = TRUE
