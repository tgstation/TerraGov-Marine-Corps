#define TAB_MAIN 1
#define TAB_BANK 2
#define TAB_STOCK 3
#define TAB_IMPORT 4
#define TAB_BOUNTIES 5
#define TAB_LOG 6

/obj/structure/roguemachine/steward
	name = "nerve master"
	desc = ""
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "steward_machine"
	density = TRUE
	blade_dulling = DULLING_BASH
	max_integrity = 0
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	var/locked = FALSE
	var/keycontrol = "steward"
	var/current_tab = TAB_MAIN


/obj/structure/roguemachine/steward/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/roguekey))
		var/obj/item/roguekey/K = P
		if(K.lockid == keycontrol)
			locked = !locked
			playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
			update_icon()
			return
		else
			to_chat(user, "<span class='warning'>Wrong key.</span>")
			return
	if(istype(P, /obj/item/keyring))
		var/obj/item/keyring/K = P
		for(var/obj/item/roguekey/KE in K.keys)
			if(KE.lockid == keycontrol)
				locked = !locked
				playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
				update_icon()
				return
		to_chat(user, "<span class='warning'>Wrong key.</span>")
		return
	return ..()


/obj/structure/roguemachine/steward/Topic(href, href_list)
	. = ..()
	if(!usr.canUseTopic(src, BE_CLOSE) || locked)
		return
	if(href_list["switchtab"])
		current_tab = text2num(href_list["switchtab"])
	if(href_list["import"])
		var/datum/roguestock/D = locate(href_list["import"]) in SStreasury.stockpile_datums
		if(!D)
			return
		if(SStreasury.treasury_value < D.get_import_price())
			say("Insufficient mammon.")
			return
		var/amt = D.get_import_price()
		SStreasury.treasury_value -= amt
		SStreasury.log_to_steward("-[amt] imported [D.name]")
		scom_announce("Rockhill imports [D.name] for [amt] mammon.", )
		D.raise_demand()
		addtimer(CALLBACK(src, .proc/do_import, D.type), 10 SECONDS)
	if(href_list["export"])
		var/datum/roguestock/D = locate(href_list["export"]) in SStreasury.stockpile_datums
		if(!D)
			return
		if(D.held_items < D.importexport_amt)
			say("Insufficient stock.")
			return
		var/amt = D.get_export_price()
		D.held_items -= D.importexport_amt
		SStreasury.treasury_value += amt
		SStreasury.log_to_steward("+[amt] exported [D.name]")
		scom_announce("Rockhill exports [D.name] for [amt] mammon.")
		D.lower_demand()
	if(href_list["togglewithdraw"])
		var/datum/roguestock/D = locate(href_list["togglewithdraw"]) in SStreasury.stockpile_datums
		if(!D)
			return
		D.withdraw_disabled = !D.withdraw_disabled
	if(href_list["setbounty"])
		var/datum/roguestock/D = locate(href_list["setbounty"]) in SStreasury.stockpile_datums
		if(!D)
			return
		if(!D.percent_bounty)
			var/newtax = input(usr, "Set a new price for [D.name]", src, D.payout_price) as null|num
			if(newtax)
				if(!usr.canUseTopic(src, BE_CLOSE) || locked)
					return
				if(findtext(num2text(newtax), "."))
					return
				newtax = CLAMP(newtax, 0, 999)
				if(newtax > D.payout_price)
					scom_announce("The bounty for [D.name] was increased.")
				D.payout_price = newtax
		else
			var/newtax = input(usr, "Set a new percent for [D.name]", src, D.payout_price) as null|num
			if(newtax)
				if(!usr.canUseTopic(src, BE_CLOSE) || locked)
					return
				if(findtext(num2text(newtax), "."))
					return
				newtax = CLAMP(newtax, 1, 99)
				if(newtax > D.payout_price)
					scom_announce("The bounty for [D.name] was increased.")
				D.payout_price = newtax
	if(href_list["setprice"])
		var/datum/roguestock/D = locate(href_list["setprice"]) in SStreasury.stockpile_datums
		if(!D)
			return
		if(!D.percent_bounty)
			var/newtax = input(usr, "Set a new price to withdraw [D.name]", src, D.withdraw_price) as null|num
			if(newtax)
				if(!usr.canUseTopic(src, BE_CLOSE) || locked)
					return
				if(findtext(num2text(newtax), "."))
					return
				newtax = CLAMP(newtax, 0, 999)
				D.withdraw_price = newtax
	if(href_list["givemoney"])
		var/X = href_list["givemoney"]
		for(var/A in SStreasury.bank_accounts)
			if(A == X)
				var/newtax = input(usr, "How much to give [X]", src) as null|num
				if(!usr.canUseTopic(src, BE_CLOSE) || locked)
					return
				if(findtext(num2text(newtax), "."))
					return
				if(!newtax)
					return
				if(newtax < 1)
					return
				SStreasury.give_money_account(newtax, A)
				break
	if(href_list["fineaccount"])
		var/X = href_list["fineaccount"]
		for(var/A in SStreasury.bank_accounts)
			if(A == X)
				var/newtax = input(usr, "How much to fine [X]", src) as null|num
				if(!usr.canUseTopic(src, BE_CLOSE) || locked)
					return
				if(findtext(num2text(newtax), "."))
					return
				if(!newtax)
					return
				if(newtax < 1)
					return
				SStreasury.give_money_account(-newtax, A)
				break
	if(href_list["payroll"])
		var/list/L = list(GLOB.noble_positions) + list(GLOB.garrison_positions) + list(GLOB.church_positions) + list(GLOB.serf_positions) + list(GLOB.peasant_positions) + list(GLOB.youngfolk_positions)
		var/list/things = list()
		for(var/list/category in L)
			for(var/A in category)
				things += A
		var/job_to_pay = input(usr, "Select a job", src) as null|anything in things
		if(!job_to_pay)
			return
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		var/amount_to_pay = input(usr, "How much to pay every [job_to_pay]", src) as null|num
		if(!amount_to_pay)
			return
		if(amount_to_pay<1)
			return
		if(!usr.canUseTopic(src, BE_CLOSE) || locked)
			return
		if(findtext(num2text(amount_to_pay), "."))
			return
		for(var/mob/living/carbon/human/H in GLOB.human_list)
			if(H.job == job_to_pay)
				SStreasury.give_money_account(amount_to_pay, H.real_name)
	return attack_hand(usr)

/obj/structure/roguemachine/steward/proc/do_import(datum/roguestock/D,var/number)
	if(!D)
		return
	D = new D
	if(number > D.importexport_amt)
		return
	testing("number1 is [number]")
	if(!number)
		number = 1
	var/area/A = GLOB.areas_by_type[/area/rogue/indoors/town/warehouse]
	if(!A)
		return
	var/obj/item/I = new D.item_type()
	var/list/turfs = list()
	for(var/turf/T in A)
		turfs += T
	var/turf/T = pick(turfs)
	I.forceMove(T)
	playsound(T, 'sound/misc/hiss.ogg', 100, FALSE, -1)
	number += 1
	testing("number2 is [number]")
	addtimer(CALLBACK(src, .proc/do_import, D.type, number), 3 SECONDS)

/obj/structure/roguemachine/steward/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(locked)
		to_chat(user, "<span class='warning'>It's locked. Of course.</span>")
		return
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, 'sound/misc/keyboard_enter.ogg', 100, FALSE, -1)
	var/canread = user.can_read(src, TRUE)
	var/contents
	switch(current_tab)
		if(TAB_MAIN)
			contents += "<center>NERVE MASTER<BR>"
			contents += "--------------<BR>"
			contents += "<a href='?src=[REF(src)];switchtab=[TAB_BANK]'>\[Bank\]</a><BR>"
			contents += "<a href='?src=[REF(src)];switchtab=[TAB_STOCK]'>\[Stockpile\]</a><BR>"
			contents += "<a href='?src=[REF(src)];switchtab=[TAB_IMPORT]'>\[Import\]</a><BR>"
			contents += "<a href='?src=[REF(src)];switchtab=[TAB_BOUNTIES]'>\[Bounties\]</a><BR>"
			contents += "<a href='?src=[REF(src)];switchtab=[TAB_LOG]'>\[Log\]</a><BR>"
			contents += "</center>"
		if(TAB_BANK)
			contents += "<a href='?src=[REF(src)];switchtab=[TAB_MAIN]'>\[Return\]</a><BR>"
			contents += "<center>Bank<BR>"
			contents += "--------------<BR>"
			contents += "Treasury: [SStreasury.treasury_value]m</center><BR>"
			contents += "<a href='?src=[REF(src)];payroll=1'>\[Pay by Class\]</a><BR><BR>"
			for(var/A in SStreasury.bank_accounts)
				contents += "[A] - [SStreasury.bank_accounts[A]]m<BR>"
				contents += "<a href='?src=[REF(src)];givemoney=[A]'>\[Give Money\]</a> <a href='?src=[REF(src)];fineaccount=[A]'>\[Fine Account\]</a><BR><BR>"
		if(TAB_STOCK)
			contents += "<a href='?src=[REF(src)];switchtab=[TAB_MAIN]'>\[Return\]</a><BR>"
			contents += "<center>Stockpile<BR>"
			contents += "--------------<BR>"
			contents += "Treasury: [SStreasury.treasury_value]m<BR>"
			contents += "Lord's Tax: [SStreasury.tax_value*100]%<BR>"
			contents += "Guild's Tax: [SStreasury.queens_tax*100]%</center><BR>"
			for(var/datum/roguestock/stockpile/A in SStreasury.stockpile_datums)
				contents += "[A.name]<BR>"
				contents += "[A.desc]<BR>"
				contents += "Stockpiled Amount: [A.held_items]<BR>"
				contents += "Bounty Price: <a href='?src=[REF(src)];setbounty=[REF(A)]'>[A.payout_price]</a><BR>"
				contents += "Demand: [A.demand2word()]<BR>"
				if(A.importexport_amt)
					contents += "<a href='?src=[REF(src)];import=[REF(A)]'>\[Import [A.importexport_amt] ([A.get_import_price()])\]</a> <a href='?src=[REF(src)];export=[REF(A)]'>\[Export [A.importexport_amt] ([A.get_export_price()])\]</a> <BR>"
				contents += "<a href='?src=[REF(src)];togglewithdraw=[REF(A)]'>\[[A.withdraw_disabled ? "Enable" : "Disable"] Withdrawing\]</a><BR><BR>"
		if(TAB_IMPORT)
			contents += "<a href='?src=[REF(src)];switchtab=[TAB_MAIN]'>\[Return\]</a><BR>"
			contents += "<center>Imports<BR>"
			contents += "--------------<BR>"
			contents += "Treasury: [SStreasury.treasury_value]m<BR>"
			contents += "Lord's Tax: [SStreasury.tax_value*100]%<BR>"
			contents += "Guild's Tax: [SStreasury.queens_tax*100]%</center><BR>"
			for(var/datum/roguestock/import/A in SStreasury.stockpile_datums)
				contents += "[A.name]<BR>"
				contents += "[A.desc]<BR>"
				if(!A.stable_price)
					contents += "Demand: [A.demand2word()]<BR>"
				contents += "<a href='?src=[REF(src)];import=[REF(A)]'>\[Import [A.importexport_amt] ([A.get_import_price()])\]</a><BR><BR>"
		if(TAB_BOUNTIES)
			contents += "<a href='?src=[REF(src)];switchtab=[TAB_MAIN]'>\[Return\]</a><BR>"
			contents += "<center>Bounties<BR>"
			contents += "--------------<BR>"
			contents += "Treasury: [SStreasury.treasury_value]m<BR>"
			contents += "Lord's Tax: [SStreasury.tax_value*100]%</center><BR>"
			for(var/datum/roguestock/bounty/A in SStreasury.stockpile_datums)
				contents += "[A.name]<BR>"
				contents += "[A.desc]<BR>"
				contents += "Total Collected: [A.held_items]<BR>"
				if(A.percent_bounty)
					contents += "Bounty Price: <a href='?src=[REF(src)];setbounty=[REF(A)]'>[A.payout_price]%</a><BR><BR>"
				else
					contents += "Bounty Price: <a href='?src=[REF(src)];setbounty=[REF(A)]'>[A.payout_price]</a><BR><BR>"
		if(TAB_LOG)
			contents += "<a href='?src=[REF(src)];switchtab=[TAB_MAIN]'>\[Return\]</a><BR>"
			contents += "<center>Log<BR>"
			contents += "--------------</center><BR><BR>"
			for(var/i = SStreasury.log_entries.len to 1 step -1)
				contents += "<span class='info'>[SStreasury.log_entries[i]]</span><BR>"

	if(!canread)
		contents = stars(contents)
	var/datum/browser/popup = new(user, "VENDORTHING", "", 370, 220)
	popup.set_content(contents)
	popup.open()

#undef TAB_MAIN
#undef TAB_BANK
#undef TAB_STOCK
#undef TAB_IMPORT
#undef TAB_BOUNTIES
#undef TAB_LOG
