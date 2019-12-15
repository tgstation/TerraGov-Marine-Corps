#define SUIT_AUTODOC_DAM_MIN 50
#define SUIT_AUTODOC_DAM_MAX 150

/datum/component/suit_autodoc
	var/obj/item/healthanalyzer/integrated/analyzer

	var/burn_nextuse
	var/oxy_nextuse
	var/brute_nextuse
	var/tox_nextuse
	var/pain_nextuse

	var/chem_cooldown = 2.5 MINUTES

	var/enabled = FALSE

	var/damage_threshold = 50
	var/pain_threshold = 70

	var/list/burn_chems
	var/list/oxy_chems
	var/list/brute_chems
	var/list/tox_chems
	var/list/pain_chems

	var/static/list/default_burn_chems = list(
		/datum/reagent/medicine/kelotane,
		/datum/reagent/medicine/tricordrazine)
	var/static/list/default_oxy_chems = list(
		/datum/reagent/medicine/dexalinplus,
		/datum/reagent/medicine/inaprovaline,
		/datum/reagent/medicine/tricordrazine)
	var/static/list/default_brute_chems = list(
		/datum/reagent/medicine/bicaridine,
		/datum/reagent/medicine/quickclot,
		/datum/reagent/medicine/tricordrazine)
	var/static/list/default_tox_chems = list(
		/datum/reagent/medicine/dylovene,
		/datum/reagent/medicine/spaceacillin,
		/datum/reagent/medicine/tricordrazine)
	var/static/list/default_pain_chems = list(
		/datum/reagent/medicine/oxycodone,
		/datum/reagent/medicine/tramadol)

	var/datum/action/suit_autodoc_toggle/toggle_action
	var/datum/action/suit_autodoc_scan/scan_action
	var/datum/action/suit_autodoc_configure/configure_action

	var/mob/living/carbon/wearer

	var/overdose_threshold_mod = 0.5

/datum/component/suit_autodoc/Initialize(chem_cooldown, list/burn_chems, list/oxy_chems, list/brute_chems, list/tox_chems, list/pain_chems, overdose_threshold_mod)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	analyzer = new
	if(!isnull(chem_cooldown))
		src.chem_cooldown = chem_cooldown

	src.burn_chems = burn_chems || default_burn_chems
	src.oxy_chems = oxy_chems || default_oxy_chems
	src.brute_chems = brute_chems || default_brute_chems
	src.tox_chems = tox_chems || default_tox_chems
	src.pain_chems = pain_chems || default_pain_chems
	
	if(!isnull(overdose_threshold_mod))
		src.overdose_threshold_mod = overdose_threshold_mod

/datum/component/suit_autodoc/Destroy(force, silent)
	QDEL_NULL(analyzer)
	QDEL_NULL(toggle_action)
	QDEL_NULL(scan_action)
	QDEL_NULL(configure_action)
	wearer = null
	return ..()

/datum/component/suit_autodoc/RegisterWithParent()
	. = ..()
	toggle_action = new(parent)
	scan_action = new(parent)
	configure_action = new(parent)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, list(COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT, COMSIG_ITEM_DROPPED), .proc/dropped)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED_TO_SLOT, .proc/equipped)
	RegisterSignal(toggle_action, COMSIG_ACTION_TRIGGER, .proc/action_toggle)
	RegisterSignal(scan_action, COMSIG_ACTION_TRIGGER, .proc/scan_user)
	RegisterSignal(configure_action, COMSIG_ACTION_TRIGGER, .proc/configure)

/datum/component/suit_autodoc/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ITEM_EQUIPPED_NOT_IN_SLOT,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED_TO_SLOT))
	QDEL_NULL(toggle_action)
	QDEL_NULL(scan_action)
	QDEL_NULL(configure_action)

/datum/component/suit_autodoc/proc/RegisterSignals(mob/user)
	RegisterSignal(user, COMSIG_HUMAN_DAMAGE_TAKEN, .proc/damage_taken)

/datum/component/suit_autodoc/proc/UnregisterSignals(mob/user)
	UnregisterSignal(user, COMSIG_HUMAN_DAMAGE_TAKEN)

/datum/component/suit_autodoc/proc/examine(datum/source, mob/user)
	var/details
	if(burn_nextuse > world.time)
		details += "Its burn treatment injector is currently refilling. It will resupply in [(burn_nextuse - world.time) * 0.1] seconds.</br>"

	if(brute_nextuse > world.time)
		details += "Its trauma treatment injector is currently refilling. It will resupply in [(brute_nextuse - world.time) * 0.1] seconds.</br>"

	if(oxy_nextuse > world.time)
		details += "Its oxygenating injector is currently refilling. It will resupply in [(oxy_nextuse - world.time) * 0.1] seconds.</br>"

	if(tox_nextuse > world.time)
		details += "Its anti-toxin injector is currently refilling. It will resupply in [(tox_nextuse - world.time) * 0.1] seconds.</br>"

	if(pain_nextuse > world.time)
		details += "Its painkiller injector is currently refilling. It will resupply in [(pain_nextuse - world.time) * 0.1] seconds.</br>"

	if(details)
		to_chat(user, "<span class='danger'>[details]</span>")

/datum/component/suit_autodoc/proc/dropped(datum/source, mob/user)
	if(!iscarbon(user))
		return
	remove_actions()
	disable()
	wearer = null

/datum/component/suit_autodoc/proc/equipped(datum/source, mob/equipper, slot)
	if(!iscarbon(equipper)) // living can equip stuff but only carbon has traumatic shock
		return
	wearer = equipper
	enable()
	give_actions()

/datum/component/suit_autodoc/proc/disable(silent = FALSE)
	if(!enabled)
		return
	enabled = FALSE
	toggle_action.remove_selected_frame()
	UnregisterSignals(wearer)
	STOP_PROCESSING(SSobj, src)
	if(!silent)
		to_chat(wearer, "<span class='warning'>[parent] lets out a beep as its automedical suite deactivates.</span>")
		playsound(parent,'sound/machines/click.ogg', 15, 0, 1)

/datum/component/suit_autodoc/proc/enable(silent = FALSE)
	if(enabled)
		return
	enabled = TRUE
	toggle_action.add_selected_frame()
	RegisterSignals(wearer)
	START_PROCESSING(SSobj, src)
	if(!silent)
		to_chat(wearer, "<span class='notice'>[parent] lets out a hum as its automedical suite activates.</span>")
		playsound(parent,'sound/voice/b18_activate.ogg', 15, 0, 1)

/datum/component/suit_autodoc/proc/damage_taken(datum/source, mob/living/carbon/human/wearer, damage)
	treat_injuries()

/datum/component/suit_autodoc/process()
	treat_injuries()

/datum/component/suit_autodoc/proc/inject_chems(list/chems, mob/living/carbon/human/H, nextuse, damage, threshold, message_prefix)
	if(!length(chems) || nextuse > world.time || damage < threshold)
		return

	var/drugs

	for(var/chem in chems)
		var/datum/reagent/R = chem
		var/amount_to_administer = CLAMP(\
									initial(R.overdose_threshold) - H.reagents.get_reagent_amount(R),\
									0,\
									initial(R.overdose_threshold) * overdose_threshold_mod)
		if(amount_to_administer)
			H.reagents.add_reagent(R, amount_to_administer)
			drugs += " [initial(R.name)]: [amount_to_administer]U"

	if(LAZYLEN(drugs))
		. = "[message_prefix] administered. <span class='bold'>Dosage:[drugs]</span><br/>"

/datum/component/suit_autodoc/proc/treat_injuries()
	if(!wearer)
		CRASH("attempting to treat_injuries with no wearer")

	var/burns = inject_chems(burn_chems, wearer, burn_nextuse, wearer.getFireLoss(), damage_threshold, "Significant tissue burns detected. Restorative injection")
	if(burns)
		burn_nextuse = world.time + chem_cooldown
		addtimer(CALLBACK(src, .proc/nextuse_ready, "Burn treatment"), chem_cooldown)
	var/brute = inject_chems(brute_chems, wearer, brute_nextuse, wearer.getBruteLoss(), damage_threshold, "Significant tissue burns detected. Restorative injection")
	if(brute)
		brute_nextuse = world.time + chem_cooldown
		addtimer(CALLBACK(src, .proc/nextuse_ready, "Trauma treatment"), chem_cooldown)
	var/oxy = inject_chems(oxy_chems, wearer, oxy_nextuse, wearer.getOxyLoss(), damage_threshold, "Low blood oxygen detected. Reoxygenating preparation")
	if(oxy)
		oxy_nextuse = world.time + chem_cooldown
		addtimer(CALLBACK(src, .proc/nextuse_ready, "Oxygenation treatment"), chem_cooldown)
	var/tox = inject_chems(tox_chems, wearer, tox_nextuse, wearer.getToxLoss(), damage_threshold, "Significant blood toxicity detected. Chelating agents and curatives")
	if(tox)
		tox_nextuse = world.time + chem_cooldown
		addtimer(CALLBACK(src, .proc/nextuse_ready, "Toxicity treatment"), chem_cooldown)
	var/pain = inject_chems(pain_chems, wearer, pain_nextuse, wearer.traumatic_shock, pain_threshold, "User pain at performance impeding levels. Painkillers")
	if(pain)
		pain_nextuse = world.time + chem_cooldown
		addtimer(CALLBACK(src, .proc/nextuse_ready, "Painkiller"), chem_cooldown)

	if(burns || brute || oxy || tox || pain)
		playsound(parent,'sound/items/hypospray.ogg', 25, 0, 1)
		to_chat(wearer, "<span class='notice'>[icon2html(parent, wearer)] beeps:</br>[burns][brute][oxy][tox][pain]Estimated [chem_cooldown/600] minute replenishment time for each dosage.</span>")

/datum/component/suit_autodoc/proc/nextuse_ready(message)

	var/obj/item/I = parent // guarenteed by Initialize()

	playsound(I,'sound/effects/refill.ogg', 25, 0, 1)

	var/mob/living/carbon/human/H = I.loc // uncertain
	if(!istype(H))
		return

	to_chat(H, "<span class='notice'>[I] beeps: [message] reservoir replenished.</span>")

/datum/component/suit_autodoc/proc/give_actions()
	toggle_action.give_action(wearer)
	scan_action.give_action(wearer)
	configure_action.give_action(wearer)

/datum/component/suit_autodoc/proc/remove_actions()
	if(!wearer)
		return
	toggle_action.remove_action(wearer)
	scan_action.remove_action(wearer)
	configure_action.remove_action(wearer)

/datum/component/suit_autodoc/proc/action_toggle(datum/source)
	if(enabled)
		disable()
	else
		enable()

/datum/component/suit_autodoc/proc/scan_user(datum/source)
	analyzer.attack(wearer, wearer, TRUE)

/datum/component/suit_autodoc/proc/configure(datum/source)
	interact(wearer)

/datum/component/suit_autodoc/interact(mob/user)
	var/dat = {"
	<A href='?src=[REF(src)];automed_on=1'>Turn Automed System: [enabled ? "Off" : "On"]</A><BR>
	<BR>
	<B>Integrated Health Analyzer:</B><BR>
	<A href='byond://?src=[REF(src)];analyzer=1'>Scan Wearer</A><BR>
	<A href='byond://?src=[REF(src)];toggle_mode=1'>Turn Scanner HUD Mode: [analyzer.hud_mode ? "Off" : "On"]</A><BR>
	<BR>
	<B>Damage Trigger Threshold (Max [SUIT_AUTODOC_DAM_MAX], Min [SUIT_AUTODOC_DAM_MIN]):</B><BR>
	<A href='byond://?src=[REF(src)];automed_damage=-50'>-50</A>
	<A href='byond://?src=[REF(src)];automed_damage=-10'>-10</A>
	<A href='byond://?src=[REF(src)];automed_damage=-5'>-5</A>
	<A href='byond://?src=[REF(src)];automed_damage=-1'>-1</A> [damage_threshold]
	<A href='byond://?src=[REF(src)];automed_damage=1'>+1</A>
	<A href='byond://?src=[REF(src)];automed_damage=5'>+5</A>
	<A href='byond://?src=[REF(src)];automed_damage=10'>+10</A>
	<A href='byond://?src=[REF(src)];automed_damage=50'>+50</A><BR>
	<BR>
	<B>Pain Trigger Threshold (Max [SUIT_AUTODOC_DAM_MAX], Min [SUIT_AUTODOC_DAM_MIN]):</B><BR>
	<A href='byond://?src=[REF(src)];automed_pain=-50'>-50</A>
	<A href='byond://?src=[REF(src)];automed_pain=-10'>-10</A>
	<A href='byond://?src=[REF(src)];automed_pain=-5'>-5</A>
	<A href='byond://?src=[REF(src)];automed_pain=-1'>-1</A> [pain_threshold]
	<A href='byond://?src=[REF(src)];automed_pain=1'>+1</A>
	<A href='byond://?src=[REF(src)];automed_pain=5'>+5</A>
	<A href='byond://?src=[REF(src)];automed_pain=10'>+10</A>
	<A href='byond://?src=[REF(src)];automed_pain=50'>+50</A><BR>"}

	var/datum/browser/popup = new(user, "Suit Automedic")
	popup.set_content(dat)
	popup.open()

/datum/component/suit_autodoc/can_interact(mob/user)
	return TRUE

/datum/component/suit_autodoc/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(wearer != usr)
		return

	if(href_list["automed_on"])
		if(enabled)
			disable()
		else
			enable()

	else if(href_list["analyzer"]) //Integrated scanner
		analyzer.attack(wearer, wearer, TRUE)

	else if(href_list["toggle_mode"]) //Integrated scanner
		analyzer.hud_mode = !analyzer.hud_mode
		if(analyzer.hud_mode)
			to_chat(wearer, "<span class='notice'>The scanner now shows results on the hud.</span>")
		else
			to_chat(wearer, "<span class='notice'>The scanner no longer shows results on the hud.</span>")

	else if(href_list["automed_damage"])
		damage_threshold += text2num(href_list["automed_damage"])
		damage_threshold = round(damage_threshold)
		damage_threshold = CLAMP(damage_threshold,SUIT_AUTODOC_DAM_MIN,SUIT_AUTODOC_DAM_MAX)
	else if(href_list["automed_pain"])
		pain_threshold += text2num(href_list["automed_pain"])
		pain_threshold = round(pain_threshold)
		pain_threshold = CLAMP(pain_threshold,SUIT_AUTODOC_DAM_MIN,SUIT_AUTODOC_DAM_MAX)

	interact(wearer)

//// Action buttons

/datum/action/suit_autodoc_toggle
	name = "Toggle Suit Automedic"
	action_icon = 'icons/mob/screen_alert.dmi'
	action_icon_state = "suit_toggle"

/datum/action/suit_autodoc_scan
	name = "Suit Automedic User Scan"
	action_icon = 'icons/mob/screen_alert.dmi'
	action_icon_state = "suit_scan"

/datum/action/suit_autodoc_configure
	name = "Configure Suit Automedic"
	action_icon = 'icons/mob/screen_alert.dmi'
	action_icon_state = "suit_configure"

#undef SUIT_AUTODOC_DAM_MAX
#undef SUIT_AUTODOC_DAM_MIN
