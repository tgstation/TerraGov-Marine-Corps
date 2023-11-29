#define AUTODOC_NOTICE_SUCCESS 1
#define AUTODOC_NOTICE_DEATH 2
#define AUTODOC_NOTICE_NO_RECORD 3
#define AUTODOC_NOTICE_NO_POWER 4
#define AUTODOC_NOTICE_XENO_FUCKERY 5
#define AUTODOC_NOTICE_IDIOT_EJECT 6
#define AUTODOC_NOTICE_FORCE_EJECT 7

#define ADSURGERY_INTERNAL 1
#define ADSURGERY_GERMS 2
#define ADSURGERY_DAMAGE 3
#define ADSURGERY_FACIAL 4

#define ADSURGERY_BRUTE 5
#define ADSURGERY_BURN 6
#define ADSURGERY_TOXIN 7
#define ADSURGERY_DIALYSIS 8
#define ADSURGERY_BLOOD 9

#define ADSURGERY_BROKEN 10
#define ADSURGERY_MISSING 11
#define ADSURGERY_NECRO 12
#define ADSURGERY_SHRAPNEL 13
#define ADSURGERY_GERM 14
#define ADSURGERY_OPEN 15
#define ADSURGERY_EYES 16

//Autodoc
/obj/machinery/autodoc
	name = "\improper autodoc medical system"
	desc = "A fancy machine developed to be capable of operating on people with minimal human intervention. However, the interface is rather complex and most of it would only be useful to trained medical personnel."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "autodoc_open"
	density = TRUE
	anchored = TRUE
	coverage = 20
	req_one_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_MEDPREP)
	light_range = 1
	light_power = 0.5
	light_color = LIGHT_COLOR_BLUE
	dir = EAST
	var/locked = FALSE
	var/mob/living/carbon/human/occupant = null
	var/list/surgery_todo_list = list() //a list of surgeries to do.
//	var/surgery_t = 0 //Surgery timer in seconds.
	var/surgery = FALSE
	var/surgery_mod = 1 //What multiple to increase the surgery timer? This is used for any non-WO maps or events that are done.
	var/filtering = 0
	var/blood_transfer = 0
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_toxin = 0
	var/automaticmode = 0
	var/event = 0
	var/forceeject = FALSE

	var/obj/machinery/computer/autodoc_console/connected

	//It uses power
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 15
	active_power_usage = 120000 // It rebuilds you from nothing...

	var/stored_metal = 1000 // starts with 500 metal loaded
	var/stored_metal_max = 2000


/obj/machinery/autodoc/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_SHUTTLE_CRUSH, PROC_REF(shuttle_crush))
	update_icon()


/obj/machinery/autodoc/Destroy()
	forceeject = TRUE
	INVOKE_ASYNC(src, PROC_REF(do_eject))
	if(connected)
		connected.connected = null
		connected = null
	return ..()


/obj/machinery/autodoc/proc/shuttle_crush()
	SIGNAL_HANDLER
	if(occupant)
		var/mob/living/carbon/human/H = occupant
		go_out()
		H.gib()

/obj/machinery/autodoc/power_change()
	. = ..()
	if(is_operational() || !occupant)
		return
	visible_message("[src] engages the safety override, ejecting the occupant.")
	surgery = FALSE
	go_out(AUTODOC_NOTICE_NO_POWER)

/obj/machinery/autodoc/update_icon()
	. = ..()
	if(machine_stat & NOPOWER)
		set_light(0)
	else if(surgery || occupant)
		set_light(initial(light_range) + 1)
	else
		set_light(initial(light_range))

/obj/machinery/autodoc/update_icon_state()
	if(machine_stat & NOPOWER)
		icon_state = "autodoc_off"
	else if(surgery)
		icon_state = "autodoc_operate"
	else if (occupant)
		icon_state = "autodoc_closed"
	else
		icon_state = "autodoc_open"

/obj/machinery/autodoc/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		return
	. += emissive_appearance(icon, "[icon_state]_emissive", alpha = src.alpha)

/obj/machinery/autodoc/process()
	if(!occupant)
		return

	if(occupant.stat == DEAD)
		say("Patient has expired.")
		surgery = FALSE
		go_out(AUTODOC_NOTICE_DEATH)
		return

	if(!surgery)
		return

	// keep them alive
	var/updating_health = FALSE
	occupant.adjustToxLoss(-0.5) // pretend they get IV dylovene
	occupant.adjustOxyLoss(-occupant.getOxyLoss()) // keep them breathing, pretend they get IV dexalinplus
	if(filtering)
		var/filtered = 0
		for(var/datum/reagent/x in occupant.reagents.reagent_list)
			occupant.reagents.remove_reagent(x.type, 10) // same as sleeper, may need reducing
			filtered += 10
		if(!filtered)
			filtering = 0
			say("Blood filtering complete.")
		else if(prob(10))
			visible_message("[src] whirrs and gurgles as the dialysis module operates.")
			to_chat(occupant, span_info("You feel slightly better."))
	if(blood_transfer)
		if(connected && occupant.blood_volume < BLOOD_VOLUME_NORMAL)
			if(connected.blood_pack.reagents.get_reagent_amount(/datum/reagent/blood) < 4)
				connected.blood_pack.reagents.add_reagent(/datum/reagent/blood, 195, list("donor"=null,"blood_DNA"=null,"blood_type"="O-"))
				say("Blood reserves depleted, switching to fresh bag.")
			occupant.inject_blood(connected.blood_pack, 8) // double iv stand rate
			if(prob(10))
				visible_message("[src] whirrs and gurgles as it tranfuses blood.")
				to_chat(occupant, span_info("You feel slightly less faint."))
		else
			blood_transfer = 0
			say("Blood transfer complete.")
	if(heal_brute)
		if(occupant.getBruteLoss() > 0)
			occupant.heal_limb_damage(3, 0)
			updating_health = TRUE
			if(prob(10))
				visible_message("[src] whirrs and clicks as it stitches flesh together.")
				to_chat(occupant, span_info("You feel your wounds being stitched and sealed shut."))
		else
			heal_brute = 0
			say("Trauma repair surgery complete.")
	if(heal_burn)
		if(occupant.getFireLoss() > 0)
			occupant.heal_limb_damage(0, 3)
			updating_health = TRUE
			if(prob(10))
				visible_message("[src] whirrs and clicks as it grafts synthetic skin.")
				to_chat(occupant, span_info("You feel your burned flesh being sliced away and replaced."))
		else
			heal_burn = 0
			say("Skin grafts complete.")
	if(heal_toxin)
		if(occupant.getToxLoss() > 0)
			occupant.adjustToxLoss(-3)
			updating_health = TRUE
			if(prob(10))
				visible_message("[src] whirrs and gurgles as it kelates the occupant.")
				to_chat(occupant, span_info("You feel slighly less ill."))
		else
			heal_toxin = 0
			say("Chelation complete.")
	if(updating_health)
		occupant.updatehealth()

/obj/machinery/autodoc/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(!occupant)
		to_chat(X, span_xenowarning("There is nothing of interest in there."))
		return
	if(X.status_flags & INCORPOREAL || X.do_actions)
		return
	visible_message(span_warning("[X] begins to pry the [src]'s cover!"), 3)
	playsound(src,'sound/effects/metal_creaking.ogg', 25, 1)
	if(!do_after(X, 2 SECONDS))
		return
	playsound(loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	go_out()

#define LIMB_SURGERY 1
#define ORGAN_SURGERY 2
#define EXTERNAL_SURGERY 3

#define UNNEEDED_DELAY 100 // how long to waste if someone queues an unneeded surgery

/datum/autodoc_surgery
	var/datum/limb/limb_ref = null
	var/datum/internal_organ/organ_ref = null
	var/type_of_surgery = 0 // the above constants
	var/surgery_procedure = "" // text of surgery
	var/unneeded = 0

/proc/create_autodoc_surgery(limb_ref, type_of_surgery, surgery_procedure, unneeded=0, organ_ref=null)
	var/datum/autodoc_surgery/A = new()
	A.type_of_surgery = type_of_surgery
	A.surgery_procedure = surgery_procedure
	A.unneeded = unneeded
	A.limb_ref = limb_ref
	A.organ_ref = organ_ref
	return A


/proc/generate_autodoc_surgery_list(mob/living/carbon/human/M)
	if(!ishuman(M))
		return list()
	var/surgery_list = list()
	for(var/datum/limb/L in M.limbs)
		if(L)
			if(length(L.wounds))
				surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_INTERNAL)

			var/organdamagesurgery = 0
			for(var/datum/internal_organ/I in L.internal_organs)
				if(I.robotic == ORGAN_ASSISTED||I.robotic == ORGAN_ROBOT)
					// we can't deal with these
					continue
				if(I.damage > 0)
					if(I.organ_id == ORGAN_EYES) // treat eye surgery differently
						continue
					if(organdamagesurgery > 0)
						continue // avoid duplicates
					surgery_list += create_autodoc_surgery(L,ORGAN_SURGERY,ADSURGERY_DAMAGE,0,I)
					organdamagesurgery++

			if(istype(L,/datum/limb/head))
				var/datum/limb/head/H = L
				if(H.disfigured || H.face_surgery_stage > 0)
					surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_FACIAL)

			if(L.limb_status & LIMB_BROKEN)
				surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_BROKEN)
			if(L.limb_status & LIMB_DESTROYED)
				if(!(L.parent.limb_status & LIMB_DESTROYED) && L.body_part != HEAD)
					surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_MISSING)
			if(L.limb_status & LIMB_NECROTIZED)
				surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_NECRO)
			var/skip_embryo_check = FALSE
			if(length(L.implants))
				for(var/I in L.implants)
					if(!is_type_in_list(I,GLOB.known_implants))
						surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_SHRAPNEL)
						if(L.body_part == CHEST)
							skip_embryo_check = TRUE
			var/obj/item/alien_embryo/A = locate() in M
			if(A && L.body_part == CHEST && !skip_embryo_check) //If we're not already doing a shrapnel removal surgery on the chest, add an extraction surgery to remove it
				surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_SHRAPNEL)
			if(L.germ_level > INFECTION_LEVEL_ONE)
				surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_GERMS)
			if(L.surgery_open_stage)
				surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_OPEN)
	var/datum/internal_organ/I = M.internal_organs_by_name["eyes"]
	if(I && (M.disabilities & NEARSIGHTED || M.disabilities & BLIND || I.damage > 0))
		surgery_list += create_autodoc_surgery(null,ORGAN_SURGERY,ADSURGERY_EYES,0,I)
	if(M.getBruteLoss() > 0)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,ADSURGERY_BRUTE)
	if(M.getFireLoss() > 0)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,ADSURGERY_BURN)
	if(M.getToxLoss() > 0)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,ADSURGERY_TOXIN)
	var/overdose = FALSE
	for(var/datum/reagent/x in M.reagents.reagent_list)
		if(istype(x, /datum/reagent/toxin) || M.reagents.get_reagent_amount(x.type) > x.overdose_threshold)
			overdose = TRUE
			break
	if(overdose)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,ADSURGERY_DIALYSIS)
	if(M.blood_volume < BLOOD_VOLUME_NORMAL)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,ADSURGERY_BLOOD)
	return surgery_list

/obj/machinery/autodoc/proc/surgery_op()
	if(surgery) //This is called via href, let's avoid duplicate surgeries.
		return

	if(QDELETED(occupant) || occupant.stat == DEAD)
		if(!ishuman(occupant))
			stack_trace("Non-human occupant made its way into the autodoc: [occupant] | [occupant?.type].")
		visible_message("[src] buzzes.")
		go_out(AUTODOC_NOTICE_DEATH) //kick them out too.
		return

	var/datum/data/record/N = null
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (R.fields["name"] == occupant.real_name)
			N = R
	if(isnull(N))
		visible_message("[src] buzzes: No records found for occupant.")
		go_out(AUTODOC_NOTICE_NO_RECORD) //kick them out too.
		return

	var/list/surgery_todo_list
	if(automaticmode)
		surgery_todo_list = N.fields["autodoc_data"]
	else
		surgery_todo_list = N.fields["autodoc_manual"]

	if(!length(surgery_todo_list))
		visible_message("[src] buzzes, no surgical procedures were queued.")
		return

	visible_message("[src] begins to operate, the pod locking shut with a loud click.")
	surgery = TRUE
	update_icon()

	for(var/datum/autodoc_surgery/A in surgery_todo_list)
		if(A.type_of_surgery == EXTERNAL_SURGERY)
			switch(A.surgery_procedure)
				if(ADSURGERY_BRUTE)
					heal_brute = 1
				if(ADSURGERY_BURN)
					heal_burn = 1
				if(ADSURGERY_TOXIN)
					heal_toxin = 1
				if(ADSURGERY_DIALYSIS)
					filtering = 1
				if(ADSURGERY_BLOOD)
					blood_transfer = 1
			surgery_todo_list -= A

	var/currentsurgery = 1
	while(length(surgery_todo_list) > 0)
		if(!surgery)
			break
		sleep(-1)
		var/datum/autodoc_surgery/S = surgery_todo_list[currentsurgery]
		if(automaticmode)
			surgery_mod = 1.5 // automatic mode takes longer
		else
			surgery_mod = 1 // might need tweaking

		switch(S.type_of_surgery)
			if(ORGAN_SURGERY)
				switch(S.surgery_procedure)
					if(ADSURGERY_GERMS) // Just dose them with the maximum amount of antibiotics and hope for the best
						say("Beginning organ disinfection.")
						var/datum/reagent/R = GLOB.chemical_reagents_list[/datum/reagent/medicine/spaceacillin]
						var/amount = R.overdose_threshold - occupant.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin)
						var/inject_per_second = 3
						to_chat(occupant, span_info("You feel a soft prick from a needle."))
						while(amount > 0)
							if(!surgery)
								break
							if(amount < inject_per_second)
								occupant.reagents.add_reagent(/datum/reagent/medicine/spaceacillin,amount)
								break
							else
								occupant.reagents.add_reagent(/datum/reagent/medicine/spaceacillin,inject_per_second)
								amount -= inject_per_second
								sleep(10*surgery_mod)

					if(ADSURGERY_DAMAGE)
						say("Beginning organ restoration.")
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							say("Procedure has been deemed unnecessary.")
							surgery_todo_list -= S
							continue
						open_incision(occupant, S.limb_ref)

						if(S.limb_ref.body_part != GROIN)
							open_encased(occupant, S.limb_ref)

						if(!istype(S.organ_ref,/datum/internal_organ/brain))
							sleep(FIX_ORGAN_MAX_DURATION*surgery_mod)
						else
							if(S.organ_ref.damage > BONECHIPS_MAX_DAMAGE)
								sleep(HEMOTOMA_MAX_DURATION*surgery_mod)
							sleep(BONECHIPS_REMOVAL_MAX_DURATION*surgery_mod)
						if(!surgery)
							break
						if(istype(S.organ_ref,/datum/internal_organ))
							S.organ_ref.heal_organ_damage(S.organ_ref.damage)
						else
							say("Organ is missing.")

						// close them
						if(S.limb_ref.body_part != GROIN) // TODO: fix brute damage before closing
							close_encased(occupant, S.limb_ref)
						close_incision(occupant, S.limb_ref)

					if(ADSURGERY_EYES)
						say("Beginning corrective eye surgery.")
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							say("Procedure has been deemed unnecessary.")
							surgery_todo_list -= S
							continue
						if(istype(S.organ_ref,/datum/internal_organ/eyes))
							var/datum/internal_organ/eyes/E = S.organ_ref

							if(E.eye_surgery_stage == 0)
								sleep(EYE_CUT_MAX_DURATION)
								if(!surgery)
									break
								E.eye_surgery_stage = 1
								occupant.disabilities |= NEARSIGHTED // code\#define\mobs.dm

							if(E.eye_surgery_stage == 1)
								sleep(EYE_LIFT_MAX_DURATION)
								if(!surgery)
									break
								E.eye_surgery_stage = 2

							if(E.eye_surgery_stage == 2)
								sleep(EYE_MEND_MAX_DURATION)
								if(!surgery)
									break
								E.eye_surgery_stage = 3

							if(E.eye_surgery_stage == 3)
								sleep(EYE_CAUTERISE_MAX_DURATION)
								if(!surgery)
									break
								occupant.disabilities &= ~NEARSIGHTED
								occupant.disabilities &= ~BLIND
								E.heal_organ_damage(E.damage)
								E.eye_surgery_stage = 0


			if(LIMB_SURGERY)
				switch(S.surgery_procedure)
					if(ADSURGERY_INTERNAL)
						say("Beginning internal bleeding procedure.")
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							say("Procedure has been deemed unnecessary.")
							surgery_todo_list -= S
							continue
						open_incision(occupant, S.limb_ref)
						for(var/datum/wound/W in S.limb_ref.wounds)
							if(!surgery)
								break
							sleep(FIXVEIN_MAX_DURATION*surgery_mod)
							qdel(W)
						if(!surgery)
							break
						close_incision(occupant, S.limb_ref)

					if(ADSURGERY_BROKEN)
						say("Beginning broken bone procedure.")
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							say("Procedure has been deemed unnecessary.")
							surgery_todo_list -= S
							continue
						open_incision(occupant, S.limb_ref)
						sleep(BONEGEL_REPAIR_MAX_DURATION*surgery_mod)
						sleep(BONESETTER_MAX_DURATION*surgery_mod)
						if(S.limb_ref.brute_dam > 20)
							sleep(((S.limb_ref.brute_dam - 20)/2)*surgery_mod)
							if(!surgery)
								break
							S.limb_ref.heal_limb_damage(S.limb_ref.brute_dam - 20)
						if(!surgery)
							break
						S.limb_ref.remove_limb_flags(LIMB_BROKEN | LIMB_SPLINTED | LIMB_STABILIZED)
						S.limb_ref.add_limb_flags(LIMB_REPAIRED)
						close_incision(occupant, S.limb_ref)

					if(ADSURGERY_MISSING)
						say("Beginning limb replacement.")
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							say("Procedure has been deemed unnecessary.")
							surgery_todo_list -= S
							continue

						sleep(ROBOLIMB_CUT_MAX_DURATION*surgery_mod)
						sleep(ROBOLIMB_MEND_MAX_DURATION*surgery_mod)
						sleep(ROBOLIMB_PREPARE_MAX_DURATION*surgery_mod)

						if(stored_metal < LIMB_METAL_AMOUNT)
							say("Metal reserves depleted.")
							playsound(loc, 'sound/machines/buzz-two.ogg', 15, TRUE)
							surgery_todo_list -= S
							continue // next surgery

						stored_metal -= LIMB_METAL_AMOUNT

						if(S.limb_ref.parent.limb_status & LIMB_DESTROYED) // there's nothing to attach to
							say("Limb attachment failed.")
							playsound(loc, 'sound/machines/buzz-two.ogg', 15, TRUE)
							surgery_todo_list -= S
							continue

						if(!surgery)
							break
						S.limb_ref.add_limb_flags(LIMB_AMPUTATED)
						S.limb_ref.setAmputatedTree()
						S.limb_ref.limb_replacement_stage = 0

						var/spillover = LIMB_PRINTING_TIME - (ROBOLIMB_PREPARE_MAX_DURATION+ROBOLIMB_MEND_MAX_DURATION+ROBOLIMB_CUT_MAX_DURATION)
						if(spillover > 0)
							sleep(spillover*surgery_mod)

						sleep(ROBOLIMB_ATTACH_MAX_DURATION*surgery_mod)
						if(!surgery)
							break
						S.limb_ref.robotize()
						occupant.update_body()
						occupant.updatehealth()
						occupant.UpdateDamageIcon()

					if(ADSURGERY_NECRO)
						say("Beginning necrotic tissue removal.")
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							say("Procedure has been deemed unnecessary.")
							surgery_todo_list -= S
							continue

						open_incision(occupant, S.limb_ref)
						sleep(NECRO_REMOVE_MAX_DURATION*surgery_mod)
						sleep(NECRO_TREAT_MAX_DURATION*surgery_mod)
						S.limb_ref.remove_limb_flags(LIMB_NECROTIZED)
						occupant.update_body()

						close_incision(occupant, S.limb_ref)

					if(ADSURGERY_SHRAPNEL)
						say("Beginning foreign body removal.")
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							say("Procedure has been deemed unnecessary.")
							surgery_todo_list -= S
							continue

						open_incision(occupant, S.limb_ref)
						if(S.limb_ref.body_part == CHEST || S.limb_ref.body_part == HEAD)
							open_encased(occupant, S.limb_ref)
						if(S.limb_ref.body_part == CHEST) //if it's the chest check for gross parasites
							var/obj/item/alien_embryo/A = locate() in occupant
							if(A)
								for(A in occupant)
									sleep(HEMOSTAT_REMOVE_MAX_DURATION*surgery_mod)
									occupant.visible_message(span_warning(" [src] defty extracts a wriggling parasite from [occupant]'s ribcage!"))
									var/mob/living/carbon/xenomorph/larva/L = locate() in occupant //the larva was fully grown, ready to burst.
									if(L)
										L.forceMove(get_turf(src))
									else
										A.forceMove(occupant.loc)
										occupant.status_flags &= ~XENO_HOST
									qdel(A)
						if(length(S.limb_ref.implants))
							for(var/obj/item/I in S.limb_ref.implants)
								if(!surgery)
									break
								if(!is_type_in_list(I, GLOB.known_implants))
									sleep(HEMOSTAT_REMOVE_MAX_DURATION*surgery_mod)
									I.unembed_ourself(TRUE)
						if(S.limb_ref.body_part == CHEST || S.limb_ref.body_part == HEAD)
							close_encased(occupant, S.limb_ref)
						if(!surgery)
							break
						close_incision(occupant, S.limb_ref)

					if(ADSURGERY_GERM)
						say("Beginning limb disinfection.")

						var/datum/reagent/R = GLOB.chemical_reagents_list[/datum/reagent/medicine/spaceacillin]
						var/amount = (R.overdose_threshold * 0.5) - occupant.reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin)
						var/inject_per_second = 3
						to_chat(occupant, span_info("You feel a soft prick from a needle."))
						while(amount > 0)
							if(!surgery)
								break
							if(amount < inject_per_second)
								occupant.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, amount)
								break
							else
								occupant.reagents.add_reagent(/datum/reagent/medicine/spaceacillin, inject_per_second)
								amount -= inject_per_second
								sleep(1 SECONDS)

					if(ADSURGERY_FACIAL) // dumb but covers for incomplete facial surgery
						say("Beginning Facial Reconstruction Surgery.")
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							say("Procedure has been deemed unnecessary.")
							surgery_todo_list -= S
							continue
						if(istype(S.limb_ref,/datum/limb/head))
							var/datum/limb/head/F = S.limb_ref
							if(F.face_surgery_stage == 0)
								sleep(FACIAL_CUT_MAX_DURATION)
								if(!surgery)
									break
								F.face_surgery_stage = 1
							if(F.face_surgery_stage == 1)
								sleep(FACIAL_MEND_MAX_DURATION)
								if(!surgery)
									break
								F.face_surgery_stage = 2
							if(F.face_surgery_stage == 2)
								sleep(FACIAL_FIX_MAX_DURATION)
								if(!surgery)
									break
								F.face_surgery_stage = 3
							if(F.face_surgery_stage == 3)
								sleep(FACIAL_CAUTERISE_MAX_DURATION)
								if(!surgery)
									break
								F.remove_limb_flags(LIMB_BLEEDING)
								F.disfigured = 0
								F.owner.name = F.owner.get_visible_name()
								F.face_surgery_stage = 0

					if(ADSURGERY_OPEN)
						say("Closing surgical incision.")
						close_encased(occupant, S.limb_ref)
						close_incision(occupant, S.limb_ref)

		say("Procedure complete.")
		surgery_todo_list -= S
		continue

	while(heal_brute||heal_burn||heal_toxin||filtering||blood_transfer)
		if(!surgery)
			break
		sleep(2 SECONDS)
		if(prob(5))
			visible_message("[src] beeps as it continues working.")

	visible_message("\The [src] clicks and opens up having finished the requested operations.")
	surgery = 0
	go_out(AUTODOC_NOTICE_SUCCESS)


/obj/machinery/autodoc/proc/open_incision(mob/living/carbon/human/target, datum/limb/L)
	if(target && L && L.surgery_open_stage < 2)
		sleep(INCISION_MANAGER_MAX_DURATION*surgery_mod)
		if(!surgery)
			return
		L.createwound(CUT, 1)
		L.clamp_bleeder() //Hemostat function, clamp bleeders
		L.surgery_open_stage = 2 //Can immediately proceed to other surgery steps
		target.updatehealth()

/obj/machinery/autodoc/proc/close_incision(mob/living/carbon/human/target, datum/limb/L)
	if(target && L && 0 < L.surgery_open_stage <= 2)
		sleep(CAUTERY_MAX_DURATION*surgery_mod)
		if(!surgery)
			return
		L.surgery_open_stage = 0
		L.germ_level = 0
		L.remove_limb_flags(LIMB_BLEEDING)
		target.updatehealth()

/obj/machinery/autodoc/proc/open_encased(mob/living/carbon/human/target, datum/limb/L)
	if(target && L && L.surgery_open_stage >= 2)
		if(L.surgery_open_stage == 2) // this will cover for half completed surgeries
			sleep(SAW_OPEN_ENCASED_MAX_DURATION*surgery_mod)
			if(!surgery)
				return
			L.surgery_open_stage = 2.5
		if(L.surgery_open_stage == 2.5)
			sleep(RETRACT_OPEN_ENCASED_MAX_DURATION*surgery_mod)
			if(!surgery)
				return
			L.surgery_open_stage = 3

/obj/machinery/autodoc/proc/close_encased(mob/living/carbon/human/target, datum/limb/L)
	if(target && L && L.surgery_open_stage > 2)
		if(L.surgery_open_stage == 3) // this will cover for half completed surgeries
			sleep(RETRACT_CLOSE_ENCASED_MAX_DURATION*surgery_mod)
			if(!surgery)
				return
			L.surgery_open_stage = 2.5
		if(L.surgery_open_stage == 2.5)
			sleep(BONEGEL_CLOSE_ENCASED_MAX_DURATION*surgery_mod)
			if(!surgery)
				return
			L.surgery_open_stage = 2

/obj/machinery/autodoc/verb/eject()
	set name = "Eject Med-Pod"
	set category = "Object"
	set src in oview(1)
	if(usr.incapacitated())
		return // nooooooooooo
	if(locked && !allowed(usr)) //Check access if locked.
		to_chat(usr, span_warning("Access denied."))
		playsound(loc,'sound/machines/buzz-two.ogg', 25, 1)
		return
	do_eject()

/obj/machinery/autodoc/proc/do_eject()
	if(!occupant)
		return
	if(forceeject)
		if(!surgery)
			visible_message("\The [src] is destroyed, ejecting [occupant] and showering them in debris.")
			occupant.take_limb_damage(rand(10,20),rand(10,20))
		else
			visible_message("\The [src] malfunctions as it is destroyed mid-surgery, ejecting [occupant] with surgical wounds and showering them in debris.")
			occupant.take_limb_damage(rand(30,50),rand(30,50))
		go_out(AUTODOC_NOTICE_FORCE_EJECT)
		return
	if(isxeno(usr) && !surgery) // let xenos eject people hiding inside; a xeno ejecting someone during surgery does so like someone untrained
		go_out(AUTODOC_NOTICE_XENO_FUCKERY)
		return
	if(!ishuman(usr))
		return
	if(usr == occupant)
		if(surgery)
			to_chat(usr, span_warning("There's no way you're getting out while this thing is operating on you!"))
			return
		else
			visible_message("[usr] engages the internal release mechanism, and climbs out of \the [src].")
	if(usr.skills.getRating(SKILL_SURGERY) < SKILL_SURGERY_TRAINED && !event)
		usr.visible_message(span_notice("[usr] fumbles around figuring out how to use [src]."),
		span_notice("You fumble around figuring out how to use [src]."))
		var/fumbling_time = max(0 , SKILL_TASK_TOUGH - ( SKILL_TASK_EASY * usr.skills.getRating(SKILL_SURGERY) ))// 8 secs non-trained, 5 amateur
		if(!do_after(usr, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED) || !occupant)
			return
	if(surgery)
		surgery = 0
		if(usr.skills.getRating(SKILL_SURGERY) < SKILL_SURGERY_TRAINED) //Untrained people will fail to terminate the surgery properly.
			visible_message("\The [src] malfunctions as [usr] aborts the surgery in progress.")
			occupant.take_limb_damage(rand(30,50),rand(30,50))
			log_game("[key_name(usr)] ejected [key_name(occupant)] from the autodoc during surgery causing damage.")
			message_admins("[ADMIN_TPMONTY(usr)] ejected [ADMIN_TPMONTY(occupant)] from the autodoc during surgery causing damage.")
			go_out(AUTODOC_NOTICE_IDIOT_EJECT)
			return
	go_out()

/obj/machinery/autodoc/proc/move_inside_wrapper(mob/living/target, mob/user)
	if(!ishuman(target) || !ishuman(user) || user.incapacitated(TRUE))
		return

	if(occupant)
		to_chat(user, span_notice("[src] is already occupied!"))
		return

	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_notice("[src] is non-functional!"))
		return

	if(user.skills.getRating(SKILL_SURGERY) < SKILL_SURGERY_TRAINED && !event)
		target.visible_message(span_notice("[target] fumbles around figuring out how to get into \the [src]."),
		span_notice("You fumble around figuring out how to get into \the [src]."))
		var/fumbling_time = max(0 , SKILL_TASK_TOUGH - ( SKILL_TASK_EASY * user.skills.getRating(SKILL_SURGERY) ))// 8 secs non-trained, 5 amateur
		if(!do_after(target, fumbling_time, NONE, src, BUSY_ICON_UNSKILLED))
			return

	target.visible_message(span_notice("[target] starts climbing into \the [src]."),
	span_notice("You start climbing into \the [src]."))
	if(do_after(target, 1 SECONDS, IGNORE_HELD_ITEM, src, BUSY_ICON_GENERIC))
		if(occupant)
			to_chat(user, span_notice("[src] is already occupied!"))
			return
		target.stop_pulling()
		target.forceMove(src)
		occupant = target
		update_icon()
		var/implants = list(/obj/item/implant/neurostim)
		var/mob/living/carbon/human/H = occupant
		var/doc_dat
		med_scan(H, doc_dat, implants, TRUE)
		start_processing()
		for(var/obj/O in src)
			qdel(O)
		if(automaticmode)
			say("Automatic mode engaged, initialising procedures.")
			addtimer(CALLBACK(src, PROC_REF(auto_start)), 5 SECONDS)

///Callback to start auto mode on someone entering
/obj/machinery/autodoc/proc/auto_start()
	if(surgery)
		return
	if(!occupant)
		say("Occupant missing, procedures canceled.")
	if(!automaticmode)
		say("Automatic mode disengaged, awaiting manual inputs.")
		return
	surgery_op()


/obj/machinery/autodoc/MouseDrop_T(mob/M, mob/user)
	. = ..()
	move_inside_wrapper(M, user)

/obj/machinery/autodoc/verb/move_inside()
	set name = "Enter Med-Pod"
	set category = "Object"
	set src in oview(1)

	move_inside_wrapper(usr, usr)

/obj/machinery/autodoc/proc/go_out(notice_code = FALSE)
	for(var/i in contents)
		var/atom/movable/AM = i
		AM.forceMove(loc)
	if(connected?.release_notice && occupant) //If auto-release notices are on as they should be, let the doctors know what's up
		var/reason = "Reason for discharge: Procedural completion."
		switch(notice_code)
			if(AUTODOC_NOTICE_SUCCESS)
				playsound(src.loc, 'sound/machines/ping.ogg', 50, FALSE) //All steps finished properly; this is the 'normal' notification.
			if(AUTODOC_NOTICE_DEATH)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Patient death."
			if(AUTODOC_NOTICE_NO_RECORD)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Medical records not detected. Alerting security advised."
			if(AUTODOC_NOTICE_NO_POWER)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Power failure."
			if(AUTODOC_NOTICE_XENO_FUCKERY)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Unauthorized manual release. Alerting security advised."
			if(AUTODOC_NOTICE_IDIOT_EJECT)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Unauthorized manual release during surgery. Alerting security advised."
			if(AUTODOC_NOTICE_FORCE_EJECT)
				playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 50, FALSE)
				reason = "Reason for discharge: Destruction of linked Autodoc Medical System. Alerting security advised."
		connected.radio.talk_into(src, "<b>Patient: [occupant] has been released from [src] at: [get_area(src)]. [reason]</b>", RADIO_CHANNEL_MEDICAL)
	occupant = null
	surgery_todo_list = list()
	update_icon()
	stop_processing()

/obj/machinery/autodoc/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(!ishuman(user))
		return // no

	if(istype(I, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = I
		if(stored_metal >= stored_metal_max)
			to_chat(user, span_warning("[src]'s metal reservoir is full; it can't hold any more material!"))
			return
		stored_metal = min(stored_metal_max,stored_metal + M.amount * 100)
		to_chat(user, span_notice("[src] processes \the [I]. Its metal reservoir now contains [stored_metal] of [stored_metal_max] units."))
		user.drop_held_item()
		qdel(I)

	else if(istype(I, /obj/item/healthanalyzer) && occupant) //Allows us to use the analyzer on the occupant without taking him out.
		var/obj/item/healthanalyzer/J = I
		J.attack(occupant, user)
		return

	else if(!istype(I, /obj/item/grab))
		return

	if(machine_stat & (NOPOWER|BROKEN))
		to_chat(user, span_notice("[src] is non-functional!"))
		return

	else if(occupant)
		to_chat(user, span_notice("[src] is already occupied!"))
		return

	if(!istype(I, /obj/item/grab))
		return

	var/obj/item/grab/G = I

	var/mob/M
	if(ismob(G.grabbed_thing))
		M = G.grabbed_thing
	else if(istype(G.grabbed_thing, /obj/structure/closet/bodybag/cryobag))
		var/obj/structure/closet/bodybag/cryobag/C = G.grabbed_thing
		if(!C.bodybag_occupant)
			to_chat(user, span_warning("The stasis bag is empty!"))
			return
		M = C.bodybag_occupant
		C.open()
		user.start_pulling(M)


	if(!M)
		return

	else if(!ishuman(M)) // stop fucking monkeys and xenos being put in. // MONKEEY IS FREE
		to_chat(user, span_notice("[src] is compatible with humanoid anatomies only!"))
		return

	else if(M.abiotic())
		to_chat(user, span_warning("Subject cannot have abiotic items on."))
		return

	if(user.skills.getRating(SKILL_SURGERY) < SKILL_SURGERY_TRAINED && !event)
		user.visible_message(span_notice("[user] fumbles around figuring out how to put [M] into [src]."),
		span_notice("You fumble around figuring out how to put [M] into [src]."))
		var/fumbling_time = max(0 , SKILL_TASK_TOUGH - ( SKILL_TASK_EASY * user.skills.getRating(SKILL_SURGERY) ))// 8 secs non-trained, 5 amateur
		if(!do_after(user, fumbling_time, NONE, M, BUSY_ICON_UNSKILLED) || QDELETED(src))
			return

	visible_message("[user] starts putting [M] into [src].", 3)

	if(!do_after(user, 10, IGNORE_HELD_ITEM, M, BUSY_ICON_GENERIC) || QDELETED(src))
		return

	if(occupant)
		to_chat(user, span_notice("[src] is already occupied!"))
		return

	if(!M || !G)
		return

	M.forceMove(src)
	occupant = M
	update_icon()
	var/implants = list(/obj/item/implant/neurostim)
	var/mob/living/carbon/human/H = occupant
	med_scan(H, null, implants, TRUE)
	start_processing()

	if(automaticmode)
		say("Automatic mode engaged, initialising procedures.")
		addtimer(CALLBACK(src, PROC_REF(auto_start)), 5 SECONDS)


/////////////////////////////////////////////////////////////

//Auto Doc console that links up to it.
/obj/machinery/computer/autodoc_console
	name = "autodoc medical system control console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeperconsole"
	screen_overlay = "sleeperconsole_emissive"
	light_color = LIGHT_COLOR_EMISSIVE_RED
	req_one_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_MEDPREP) //Valid access while locked
	density = FALSE
	idle_power_usage = 40
	dir = EAST
	var/obj/item/radio/headset/mainship/doc/radio
	var/obj/item/reagent_containers/blood/OMinus/blood_pack
	///connected autodoc
	var/obj/machinery/autodoc/connected = null
	///Are notifications for patient discharges turned on?
	var/release_notice = TRUE
	///Medics, Doctors and so on can lock this
	var/locked = FALSE

/obj/machinery/computer/autodoc_console/Initialize(mapload)
	. = ..()
	connected = locate(/obj/machinery/autodoc, get_step(src, REVERSE_DIR(dir)))
	if(connected)
		connected.connected = src
	radio = new(src)
	blood_pack = new(src)


/obj/machinery/computer/autodoc_console/Destroy()
	QDEL_NULL(radio)
	QDEL_NULL(blood_pack)
	if(connected)
		connected.connected = null
		connected = null
	return ..()

/obj/machinery/computer/autodoc_console/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!connected || !connected.is_operational())
		return FALSE

	if(locked && !allowed(user))
		return FALSE

	return TRUE



/obj/machinery/computer/autodoc_console/interact(mob/user)
	. = ..()
	if(.)
		return

	var/dat = ""

	if(locked)
		dat += "<hr>Lock Console</span> | <a href='?src=[text_ref(src)];locktoggle=1'>Unlock Console</a><BR>"
	else
		dat += "<hr><a href='?src=[text_ref(src)];locktoggle=1'>Lock Console</a> | Unlock Console<BR>"

	if(release_notice)
		dat += "<hr>Notifications On</span> | <a href='?src=[text_ref(src)];noticetoggle=1'>Notifications Off</a><BR>"
	else
		dat += "<hr><a href='?src=[text_ref(src)];noticetoggle=1'>Notifications On</a> | Notifications Off<BR>"

	if(connected.automaticmode)
		dat += "<hr>[span_notice("Automatic Mode")] | <a href='?src=[text_ref(src)];automatictoggle=1'>Manual Mode</a>"
	else
		dat += "<hr><a href='?src=[text_ref(src)];automatictoggle=1'>Automatic Mode</a> | Manual Mode"

	dat += "<hr><font color='#487553'><B>Occupant Statistics:</B></FONT><BR>"
	if(!connected.occupant)
		dat += "No occupant detected."
		var/datum/browser/popup = new(user, "autodoc", "<div align='center'>Autodoc Console</div>", 600, 600)
		popup.set_content(dat)
		popup.open()
		return

	var/t1
	switch(connected.occupant.stat)
		if(CONSCIOUS)
			t1 = "Conscious"
		if(UNCONSCIOUS)
			t1 = "<font color='#487553'>Unconscious</font>"
		if(DEAD)
			t1 = "<font color='#b54646'>*Dead*</font>"
	var/operating
	switch(connected.surgery)
		if(0)
			operating = "Not in surgery"
		if(1)
			operating = "<font color='#b54646'><B>SURGERY IN PROGRESS: MANUAL EJECTION ONLY TO BE ATTEMPTED BY TRAINED OPERATORS!</B></FONT>"
	var/health_ratio = connected.occupant.health * 100 / connected.occupant.maxHealth
	dat += "[health_ratio > 50 ? "<font color='#487553'>" : "<font color='#b54646'>"]\tHealth %: [round(health_ratio)] ([t1])</FONT><BR>"
	var/pulse = connected.occupant.handle_pulse()
	dat += "[pulse == PULSE_NONE || pulse == PULSE_THREADY ? "<font color='#b54646'>" : "<font color='#487553'>"]\t-Pulse, bpm: [connected.occupant.get_pulse(GETPULSE_TOOL)]</FONT><BR>"
	dat += "[connected.occupant.getBruteLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Brute Damage %: [connected.occupant.getBruteLoss()]</FONT><BR>"
	dat += "[connected.occupant.getOxyLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Respiratory Damage %: [connected.occupant.getOxyLoss()]</FONT><BR>"
	dat += "[connected.occupant.getToxLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Toxin Content %: [connected.occupant.getToxLoss()]</FONT><BR>"
	dat += "[connected.occupant.getFireLoss() < 60 ? "<font color='#487553'>" : "<font color='#b54646'>"]\t-Burn Severity %: [connected.occupant.getFireLoss()]</FONT><BR>"

	dat += "<hr> Surgery Queue:<br>"

	var/list/surgeryqueue = list()

	var/datum/data/record/N = null
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (R.fields["name"] == connected.occupant.real_name)
			N = R
	if(isnull(N))
		N = create_medical_record(connected.occupant)

	if(connected.automaticmode)
		var/list/autosurgeries = N.fields["autodoc_data"]
		if(length(autosurgeries))
			dat += "[span_danger("Automatic Mode Ready.")]<br>"
		else

			dat += "[span_danger("Automatic Mode Unavaliable, Scan Patient First.")]<br>"
	else
		if(!isnull(N.fields["autodoc_manual"]))
			for(var/datum/autodoc_surgery/A in N.fields["autodoc_manual"])
				switch(A.type_of_surgery)
					if(EXTERNAL_SURGERY)
						switch(A.surgery_procedure)
							if(ADSURGERY_BRUTE)
								surgeryqueue["brute"] = 1
								dat += "Surgical Brute Damage Treatment"
							if(ADSURGERY_BURN)
								surgeryqueue["burn"] = 1
								dat += "Surgical Burn Damage Treatment"
							if(ADSURGERY_TOXIN)
								surgeryqueue["toxin"] = 1
								dat += "Toxin Damage Chelation"
							if(ADSURGERY_DIALYSIS)
								surgeryqueue["dialysis"] = 1
								dat += "Dialysis"
							if(ADSURGERY_BLOOD)
								surgeryqueue["blood"] = 1
								dat += "Blood Transfer"
					if(ORGAN_SURGERY)
						switch(A.surgery_procedure)
							if(ADSURGERY_GERMS)
								surgeryqueue["organgerms"] = 1
								dat += "Organ Infection Treatment"
							if(ADSURGERY_DAMAGE)
								surgeryqueue["organdamage"] = 1
								dat += "Surgical Organ Damage Treatment"
							if(ADSURGERY_EYES)
								surgeryqueue["eyes"] = 1
								dat += "Corrective Eye Surgery"
					if(LIMB_SURGERY)
						switch(A.surgery_procedure)
							if(ADSURGERY_INTERNAL)
								surgeryqueue["internal"] = 1
								dat += "Internal Bleeding Surgery"
							if(ADSURGERY_BROKEN)
								surgeryqueue["broken"] = 1
								dat += "Broken Bone Surgery"
							if(ADSURGERY_MISSING)
								surgeryqueue["missing"] = 1
								dat += "Limb Replacement Surgery"
							if(ADSURGERY_NECRO)
								surgeryqueue["necro"] = 1
								dat += "Necrosis Removal Surgery"
							if(ADSURGERY_SHRAPNEL)
								surgeryqueue["shrapnel"] = 1
								dat += "Foreign Body Removal Surgery"
							if(ADSURGERY_GERM)
								surgeryqueue["limbgerm"] = 1
								dat += "Limb Disinfection Procedure"
							if(ADSURGERY_FACIAL)
								surgeryqueue["facial"] = 1
								dat += "Facial Reconstruction Surgery"
							if(ADSURGERY_OPEN)
								surgeryqueue["open"] = 1
								dat += "Close Open Incision"
				dat += "<br>"

	dat += "<hr> Med-Pod Status: [operating] "
	dat += "<hr><a href='?src=[text_ref(src)];clear=1'>Clear Surgery Queue</a>"
	dat += "<hr><a href='?src=[text_ref(src)];refresh=1'>Refresh Menu</a>"
	dat += "<hr><a href='?src=[text_ref(src)];surgery=1'>Begin Surgery Queue</a>"
	dat += "<hr><a href='?src=[text_ref(src)];ejectify=1'>Eject Patient</a>"
	if(!connected.surgery)
		if(connected.automaticmode)
			dat += "<hr>Manual Surgery Interface Unavaliable, Automatic Mode Engaged."
		else
			dat += "<hr>Manual Surgery Interface<hr>"
			dat += "<b>Trauma Surgeries</b>"
			dat += "<br>"
			if(isnull(surgeryqueue["brute"]))
				dat += "<a href='?src=[text_ref(src)];brute=1'>Surgical Brute Damage Treatment</a><br>"
			if(isnull(surgeryqueue["burn"]))
				dat += "<a href='?src=[text_ref(src)];burn=1'>Surgical Burn Damage Treatment</a><br>"
			dat += "<b>Orthopedic Surgeries</b>"
			dat += "<br>"
			if(isnull(surgeryqueue["broken"]))
				dat += "<a href='?src=[text_ref(src)];broken=1'>Broken Bone Surgery</a><br>"
			if(isnull(surgeryqueue["internal"]))
				dat += "<a href='?src=[text_ref(src)];internal=1'>Internal Bleeding Surgery</a><br>"
			if(isnull(surgeryqueue["shrapnel"]))
				dat += "<a href='?src=[text_ref(src)];shrapnel=1'>Foreign Body Removal Surgery</a><br>"
			if(isnull(surgeryqueue["missing"]))
				dat += "<a href='?src=[text_ref(src)];missing=1'>Limb Replacement Surgery</a><br>"
			dat += "<b>Organ Surgeries</b>"
			dat += "<br>"
			if(isnull(surgeryqueue["organdamage"]))
				dat += "<a href='?src=[text_ref(src)];organdamage=1'>Surgical Organ Damage Treatment</a><br>"
			if(isnull(surgeryqueue["organgerms"]))
				dat += "<a href='?src=[text_ref(src)];organgerms=1'>Organ Infection Treatment</a><br>"
			if(isnull(surgeryqueue["eyes"]))
				dat += "<a href='?src=[text_ref(src)];eyes=1'>Corrective Eye Surgery</a><br>"
			dat += "<b>Hematology Treatments</b>"
			dat += "<br>"
			if(isnull(surgeryqueue["blood"]))
				dat += "<a href='?src=[text_ref(src)];blood=1'>Blood Transfer</a><br>"
			if(isnull(surgeryqueue["toxin"]))
				dat += "<a href='?src=[text_ref(src)];toxin=1'>Toxin Damage Chelation</a><br>"
			if(isnull(surgeryqueue["dialysis"]))
				dat += "<a href='?src=[text_ref(src)];dialysis=1'>Dialysis</a><br>"
			if(isnull(surgeryqueue["necro"]))
				dat += "<a href='?src=[text_ref(src)];necro=1'>Necrosis Removal Surgery</a><br>"
			if(isnull(surgeryqueue["limbgerm"]))
				dat += "<a href='?src=[text_ref(src)];limbgerm=1'>Limb Disinfection Procedure</a><br>"
			dat += "<b>Special Surgeries</b>"
			dat += "<br>"
			if(isnull(surgeryqueue["facial"]))
				dat += "<a href='?src=[text_ref(src)];facial=1'>Facial Reconstruction Surgery</a><br>"
			if(isnull(surgeryqueue["open"]))
				dat += "<a href='?src=[text_ref(src)];open=1'>Close Open Incision</a><br>"

	var/datum/browser/popup = new(user, "autodoc", "<div align='center'>Autodoc Console</div>", 600, 600)
	popup.set_content(dat)
	popup.open()


/obj/machinery/computer/autodoc_console/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(!connected)
		return

	if(ishuman(connected.occupant))
		// manual surgery handling
		var/datum/data/record/N = null
		for(var/i in GLOB.datacore.medical)
			var/datum/data/record/R = i
			if(R.fields["name"] == connected.occupant.real_name)
				N = R

		if(isnull(N))
			N = create_medical_record(connected.occupant)

		var/needed = 0 // this is to stop someone just choosing everything
		if(href_list["brute"])
			N.fields["autodoc_manual"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,ADSURGERY_BRUTE)

		if(href_list["burn"])
			N.fields["autodoc_manual"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,ADSURGERY_BURN)

		if(href_list["toxin"])
			N.fields["autodoc_manual"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,ADSURGERY_TOXIN)

		if(href_list["dialysis"])
			N.fields["autodoc_manual"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,ADSURGERY_DIALYSIS)

		if(href_list["blood"])
			N.fields["autodoc_manual"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,ADSURGERY_BLOOD)

		if(href_list["organgerms"])
			N.fields["autodoc_manual"] += create_autodoc_surgery(null,ORGAN_SURGERY,ADSURGERY_GERMS)

		if(href_list["eyes"])
			N.fields["autodoc_manual"] += create_autodoc_surgery(null,ORGAN_SURGERY,ADSURGERY_EYES,0,connected.occupant.internal_organs_by_name["eyes"])

		if(href_list["organdamage"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				for(var/x in L.internal_organs)
					var/datum/internal_organ/I = x
					if(I.robotic == ORGAN_ASSISTED || I.robotic == ORGAN_ROBOT)
						continue
					if(I.damage > 0)
						N.fields["autodoc_manual"] += create_autodoc_surgery(L,ORGAN_SURGERY,ADSURGERY_DAMAGE,0,I)
						needed++
			if(!needed)
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,ORGAN_SURGERY,ADSURGERY_DAMAGE,1)

		if(href_list["internal"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(length(L.wounds))
					N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_INTERNAL)
					needed++
			if(!needed)
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,ADSURGERY_INTERNAL,1)

		if(href_list["broken"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(L.limb_status & LIMB_BROKEN)
					N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_BROKEN)
					needed++
			if(!needed)
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,ADSURGERY_BROKEN,1)

		if(href_list["missing"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(L.limb_status & LIMB_DESTROYED && !(L.parent.limb_status & LIMB_DESTROYED) && L.body_part != HEAD)
					N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_MISSING)
					needed++
			if(!needed)
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,ADSURGERY_MISSING,1)

		if(href_list["necro"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(L.limb_status & LIMB_NECROTIZED)
					N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_NECRO)
					needed++
			if(!needed)
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,ADSURGERY_NECRO,1)


		if(href_list["shrapnel"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				var/skip_embryo_check = FALSE
				var/obj/item/alien_embryo/A = locate() in connected.occupant
				for(var/I in L.implants)
					if(is_type_in_list(I, GLOB.known_implants))
						continue
					N.fields["autodoc_manual"] += create_autodoc_surgery(L, LIMB_SURGERY,ADSURGERY_SHRAPNEL)
					needed++
					if(L.body_part == CHEST)
						skip_embryo_check = TRUE
				if(A && L.body_part == CHEST && !skip_embryo_check) //If we're not already doing a shrapnel removal surgery of the chest proceed.
					N.fields["autodoc_manual"] += create_autodoc_surgery(L, LIMB_SURGERY,ADSURGERY_SHRAPNEL)
					needed++

			if(!needed)
				N.fields["autodoc_manual"] += create_autodoc_surgery(null, LIMB_SURGERY,ADSURGERY_SHRAPNEL, 1)

		if(href_list["limbgerm"])
			N.fields["autodoc_manual"] += create_autodoc_surgery(null, LIMB_SURGERY,ADSURGERY_GERM)

		if(href_list["facial"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(!istype(L, /datum/limb/head))
					continue
				var/datum/limb/head/J = L
				if(J.disfigured || J.face_surgery_stage)
					N.fields["autodoc_manual"] += create_autodoc_surgery(L, LIMB_SURGERY,ADSURGERY_FACIAL)
				else
					N.fields["autodoc_manual"] += create_autodoc_surgery(L, LIMB_SURGERY,ADSURGERY_FACIAL, 1)
				break

		if(href_list["open"])
			for(var/i in connected.occupant.limbs)
				var/datum/limb/L = i
				if(L.surgery_open_stage)
					N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,ADSURGERY_OPEN)
					needed++
			if(href_list["open"])
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,ADSURGERY_OPEN,1)

		// The rest
		if(href_list["clear"])
			N.fields["autodoc_manual"] = list()

	if(href_list["locktoggle"]) //Toggle the autodoc lock on/off if we have authorization.
		if(allowed(usr))
			locked = !locked
			connected.locked = !connected.locked
		else
			to_chat(usr, span_warning("Access denied."))
			playsound(loc,'sound/machines/buzz-two.ogg', 25, 1)

	if(href_list["noticetoggle"]) //Toggle notifications on/off if we have authorization.
		if(allowed(usr))
			release_notice = !release_notice
		else
			to_chat(usr, span_warning("Access denied."))
			playsound(loc,'sound/machines/buzz-two.ogg', 25, 1)

	if(href_list["automatictoggle"])
		connected.automaticmode = !connected.automaticmode

	if(href_list["surgery"])
		if(connected.occupant)
			connected.surgery_op()

	if(href_list["ejectify"])
		connected.eject()

	updateUsrDialog()


/obj/machinery/autodoc/event
	event = 1

/obj/machinery/computer/autodoc_console/examine(mob/living/user)
	. = ..()
	if(locked)
		. += span_warning("It's currently locked down!")
	if(release_notice)
		. += span_notice("Release notifications are turned on.")

/obj/machinery/autodoc/examine(mob/living/user)
	. = ..()
	to_chat(user, span_notice("Its metal reservoir contains [stored_metal] of [stored_metal_max] units."))
	if(!occupant) //Allows us to reference medical files/scan reports for cryo via examination.
		return
	if(!ishuman(occupant))
		return
	var/active = ""
	if(surgery)
		active += " Surgical procedures are in progress."
	if(!hasHUD(user,"medical"))
		. += span_notice("It contains: [occupant].[active]")
		return
	var/mob/living/carbon/human/H = occupant
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (!R.fields["name"] == H.real_name)
			continue
		if(!(R.fields["last_scan_time"]))
			. += span_deptradio("No scan report on record")
		else
			. += span_deptradio("<a href='?src=[text_ref(src)];scanreport=1'>It contains [occupant]: Scan from [R.fields["last_scan_time"]].[active]</a>")
		break

/obj/machinery/autodoc/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if (!href_list["scanreport"])
		return
	if(!hasHUD(usr,"medical"))
		return
	if(!ishuman(occupant))
		return
	var/mob/living/carbon/human/H = occupant
	for(var/datum/data/record/R in GLOB.datacore.medical)
		if (!R.fields["name"] == H.real_name)
			continue
		if(R.fields["last_scan_time"] && R.fields["last_scan_result"])
			var/datum/browser/popup = new(usr, "scanresults", "<div align='center'>Last Scan Result</div>", 430, 600)
			popup.set_content(R.fields["last_scan_result"])
			popup.open(FALSE)
		break
