/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to separate chemicals and distribute them in a variety of forms."
	icon = 'icons/obj/machines/chemical_machines.dmi'
	icon_state = "mixer0"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER //So bottles/pills reliably appear above it
	use_power = IDLE_POWER_USE
	idle_power_usage = 20

	var/obj/item/reagent_containers/beaker = null
	var/obj/item/storage/pill_bottle/loaded_pill_bottle = null
	var/mode = 0
	var/condi = FALSE
	var/useramount = 30 // Last used amount
	var/pillamount = 16
	var/pillbottlesprite = "1"
	var/bottlesprite = "1" //yes, strings
	var/pillsprite = "1"
	var/autoinjectorsprite = "11"
	var/client/has_sprites = list()
	var/max_pill_count = 20


/obj/machinery/chem_master/Initialize()
	. = ..()
	var/datum/reagents/R = new/datum/reagents(240)
	reagents = R
	R.my_atom = src


/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(loaded_pill_bottle)
	return ..()


/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if (prob(50))
				qdel(src)


/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I,/obj/item/reagent_containers) && I.is_open_container())
		for(var/datum/reagent/X in I.reagents.reagent_list)
			if(X.medbayblacklist)
				to_chat(user, span_warning("The chem master's automatic safety features beep softly, they must have detected a harmful substance in the beaker."))
				return
		if(beaker)
			to_chat(user, span_warning("A beaker is already loaded into the machine."))
			return
		user.transferItemToLoc(I, src)
		beaker = I
		to_chat(user, span_notice("You add the beaker to the machine!"))
		updateUsrDialog()
		icon_state = "mixer1"

	else if(istype(I,/obj/item/reagent_containers/glass))
		to_chat(user, span_warning("Take off the lid first."))

	else if(istype(I, /obj/item/storage/pill_bottle))
		if(loaded_pill_bottle)
			to_chat(user, span_warning("A pill bottle is already loaded into the machine."))
			return

		loaded_pill_bottle = I
		user.transferItemToLoc(I, src)
		to_chat(user, span_notice("You add the pill bottle into the dispenser slot!"))
		updateUsrDialog()

/obj/machinery/chem_master/proc/transfer_chemicals(obj/dest, obj/source, amount, reagent_id)
	if(istype(source))
		if(amount > 0 && source.reagents && amount <= source.reagents.maximum_volume)
			if(!istype(dest))
				source.reagents.remove_reagent(reagent_id, amount)
			else if(dest.reagents)
				source.reagents.trans_id_to(dest, reagent_id, amount)

/obj/machinery/chem_master/proc/replace_beaker(mob/user)
	if(beaker)
		beaker.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(beaker)

	beaker = null
	reagents.clear_reagents()
	icon_state = "mixer0"
	return TRUE


/obj/machinery/chem_master/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(!ishuman(usr) || isAI(usr))
		return

	var/mob/living/user = usr

	if(!user.skills.getRating("medical"))
		to_chat(user, span_notice("You start fiddling with \the [src]..."))
		if(!do_after(user, SKILL_TASK_EASY, TRUE, src, BUSY_ICON_UNSKILLED))
			return

	if (href_list["ejectp"])
		if(loaded_pill_bottle)
			loaded_pill_bottle.loc = loc
			loaded_pill_bottle = null

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
			useramount = tgui_input_number(usr, "Select the amount to transfer.", 30, useramount)
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
			useramount = tgui_input_number(usr, "Select the amount to transfer.", 30, useramount)
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

		else if (href_list["createpillbottle"])
			if(!condi)
				if(loaded_pill_bottle)
					to_chat(user, span_warning("A pill bottle is already loaded into the machine."))
					return
				var/bottle_label = reject_bad_text(tgui_input_text(user, "Label:", "Enter desired bottle label", encode = FALSE))
				var/obj/item/storage/pill_bottle/I = new/obj/item/storage/pill_bottle
				if(pillbottlesprite == "2")//if the "2" sprite is selected, use the round pill bottle sprite
					I.set_greyscale_config(/datum/greyscale_config/pillbottleround)
				if(bottle_label)
					I.name = "[bottle_label] pill bottle"
				loaded_pill_bottle = I
				to_chat(user, span_notice("The Chemmaster 3000 sets a pill bottle into the dispenser slot."))
				updateUsrDialog()

		else if (href_list["createpill"] || href_list["createpill_multiple"])
			var/count = 1

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			if (href_list["createpill_multiple"])
				count = tgui_input_number(usr, "Select the number of pills to make.", 16, pillamount, max_pill_count, 0)
				if(!count)
					return

			if(reagents.total_volume/count < 1) //Sanity checking.
				return

			var/amount_per_pill = reagents.total_volume/count
			if (amount_per_pill > 15) amount_per_pill = 15

			var/name = reject_bad_text(tgui_input_text(user,"Name:","Name your pill!","[reagents.get_master_reagent_name()] ([amount_per_pill] units)", encode = FALSE))
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
				if(loaded_pill_bottle)
					if(loaded_pill_bottle.contents.len < loaded_pill_bottle.max_storage_space)
						loaded_pill_bottle.handle_item_insertion(P, TRUE)
						updateUsrDialog()

		else if (href_list["createbottle"])
			if(!condi)
				var/name = reject_bad_text(tgui_input_text(user,"Name:","Name your bottle!",reagents.get_master_reagent_name(), encode = FALSE))
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
				var/name = reject_bad_text(tgui_input_text(user,"Name:","Name your autoinjector!",reagents.get_master_reagent_name(), encode = FALSE))
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
			#define MAX_PILL_BOTTLE_SPRITE 2 //max icon state of the pill sprites
			var/dat = "<table>"
			dat += "<tr><td><a href=\"?src=\ref[src]&pill_bottle_sprite=[1]\">Select</a><img src=\"pill_canister1.png\" /><br></td></tr>"
			dat += "<tr><td><a href=\"?src=\ref[src]&pill_bottle_sprite=[2]\">Select</a><img src=\"round_pill_bottle.png\" /><br></td></tr>"
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
			#define MAX_AUTOINJECTOR_SPRITE 12 //max icon state of the autoinjector sprites
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
			user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "pill_canister1"), "pill_canister1.png")
			user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "round_pill_bottle"), "round_pill_bottle.png")
			for(var/i = 1 to MAX_PILL_SPRITE)
				user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "pill" + num2text(i)), "pill[i].png")
			for(var/i = 1 to MAX_BOTTLE_SPRITE)
				user << browse_rsc(icon('icons/obj/items/chemistry.dmi', "bottle-" + num2text(i)), "bottle-[i].png")
			for(var/i = 1 to MAX_AUTOINJECTOR_SPRITE)
				user << browse_rsc(icon('icons/obj/items/syringe.dmi', "autoinjector-" + num2text(i)), "autoinjector-[i].png")
	var/dat = ""
	if(!beaker)
		dat = "Please insert beaker.<BR>"
		if(loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.max_storage_space]\]</A><BR><BR>"
		else
			dat += "No pill bottle inserted.<BR><BR>"
	else
		dat += "<A href='?src=\ref[src];eject=1'>Eject beaker and Clear Buffer</A><BR>"
		if(loaded_pill_bottle)
			dat += "<A href='?src=\ref[src];ejectp=1'>Eject Pill Bottle \[[loaded_pill_bottle.contents.len]/[loaded_pill_bottle.max_storage_space]\]</A><BR><BR>"
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


/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	condi = TRUE

/obj/machinery/chem_master/nopower
	use_power = NO_POWER_USE

/obj/machinery/chem_master/condimaster/nopower
	use_power = NO_POWER_USE
