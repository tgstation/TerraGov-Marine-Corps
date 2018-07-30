//Autodoc
/obj/machinery/autodoc
	name = "\improper autodoc medical system"
	desc = "A fancy machine developed to be capable of operating on people with minimal human intervention. The interface is rather complex and would only be useful to trained Doctors however."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "autodoc_open"
	density = 1
	anchored = 1
	var/mob/living/carbon/human/occupant = null
	var/list/surgery_todo_list = list() //a list of surgeries to do.
//	var/surgery_t = 0 //Surgery timer in seconds.
	var/surgery = 0 //Are we operating or no? 0 for no, 1 for yes
	var/surgery_mod = 1 //What multiple to increase the surgery timer? This is used for any non-WO maps or events that are done.
	var/obj/item/reagent_container/blood/OMinus/blood_pack = new()
	var/filtering = 0
	var/blood_transfer = 0
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_toxin = 0
	var/automaticmode = 0
	var/event = 0

	var/obj/machinery/autodoc_console/connected

	//req_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY) // limit to doc IDs

	//It uses power
	use_power = 1
	idle_power_usage = 15
	active_power_usage = 450 //Capable of doing various activities

	var/stored_metal = 500 // starts with 500 metal loaded

/obj/machinery/autodoc/power_change(var/area/master_area = null)
	..()
	if(stat & NOPOWER)
		visible_message("\The [src] engages the safety override, ejecting the occupant.")
		surgery = 0
		go_out()
		return

/obj/machinery/autodoc/process()
	updateUsrDialog()
	if(occupant)
		if(occupant.stat == DEAD)
			visible_message("\The [src] speaks: Patient has expired.")
			surgery = 0
			go_out()
			return
		if(surgery)
			// keep them alive
			occupant.adjustToxLoss(-1 * REM) // pretend they get IV dylovene
			occupant.adjustOxyLoss(-occupant.getOxyLoss()) // keep them breathing, pretend they get IV dexplus
			if(filtering)
				var/filtered = 0
				for(var/datum/reagent/x in occupant.reagents.reagent_list)
					occupant.reagents.remove_reagent(x.id, 3) // same as sleeper, may need reducing
					filtered += 3
				if(!filtered)
					filtering = 0
					visible_message("\The [src] speaks: Blood filtering complete.")
				else if(prob(10))
					visible_message("\The [src] whirrs and gurgles as the dialysis module operates.")
					occupant << "<span class='info'>You feel slightly better.</span>"
			if(blood_transfer)
				if(occupant.blood_volume < BLOOD_VOLUME_NORMAL)
					if(blood_pack.reagents.get_reagent_amount("blood") < 4)
						blood_pack.reagents.add_reagent("blood", 195, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"="O-","resistances"=null))
						visible_message("\The [src] speaks: Blood reserves depleted, switching to fresh bag.")
					occupant.inject_blood(blood_pack, 8) // double iv stand rate
					if(prob(10))
						visible_message("\The [src] whirrs and gurgles as it tranfuses blood.")
						occupant << "<span class='info'>You feel slightly less faint.</span>"
				else
					blood_transfer = 0
					visible_message("\The [src] speaks: Blood transfer complete.")
			if(heal_brute)
				if(occupant.getBruteLoss() > 0)
					occupant.heal_limb_damage(3,0)
					if(prob(10))
						visible_message("\The [src] whirrs and clicks as it stitches flesh together.")
						occupant << "<span class='info'>You feel your wounds being stitched and sealed shut.</span>"
				else
					heal_brute = 0
					visible_message("\The [src] speaks: Trauma repair surgery complete.")
			if(heal_burn)
				if(occupant.getFireLoss() > 0)
					occupant.heal_limb_damage(0,3)
					if(prob(10))
						visible_message("\The [src] whirrs and clicks as it grafts synthetic skin.")
						occupant << "<span class='info'>You feel your burned flesh being sliced away and replaced.</span>"
				else
					heal_burn = 0
					visible_message("\The [src] speaks: Skin grafts complete.")
			if(heal_toxin)
				if(occupant.getToxLoss() > 0)
					occupant.adjustToxLoss(-3)
					if(prob(10))
						visible_message("\The [src] whirrs and gurgles as it kelates the occupant.")
						occupant << "<span class='info'>You feel slighly less ill.</span>"
				else
					heal_toxin = 0
					visible_message("\The [src] speaks: Chelation complete.")


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

/obj/machinery/autodoc/allow_drop()
	return 0

/proc/generate_autodoc_surgery_list(mob/living/carbon/human/M)
	if(!ishuman(M))
		return list()
	var/surgery_list = list()
	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/loyalty, /obj/item/implant/tracking, /obj/item/implant/neurostim)

	for(var/datum/limb/L in M.limbs)
		if(L)
			for(var/datum/wound/W in L.wounds)
				if(W.internal)
					surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,"internal")
					break

			var/organdamagesurgery = 0
			for(var/datum/internal_organ/I in L.internal_organs)
				if(I.robotic == ORGAN_ASSISTED||I.robotic == ORGAN_ROBOT)
					// we can't deal with these
					continue
				if(I.germ_level > 1)
					surgery_list += create_autodoc_surgery(L,ORGAN_SURGERY,"germs",0,I)
				if(I.damage > 0)
					if(I.name == "eyeballs") // treat eye surgery differently
						continue
					if(organdamagesurgery > 0) continue // avoid duplicates
					surgery_list += create_autodoc_surgery(L,ORGAN_SURGERY,"damage",0,I)
					organdamagesurgery++

			if(istype(L,/datum/limb/head))
				var/datum/limb/head/H = L
				if(H.disfigured || H.face_surgery_stage > 0)
					surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,"facial")

			if(L.status & LIMB_BROKEN)
				surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,"broken")
			if(L.status & LIMB_DESTROYED)
				if(!(L.parent.status & LIMB_DESTROYED) && L.name != "head")
					surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,"missing")
			if(L.status & LIMB_NECROTIZED)
				surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,"necro")
			if(L.implants.len)
				for(var/I in L.implants)
					if(!is_type_in_list(I,known_implants))
						surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,"shrapnel")
			if(L.germ_level > INFECTION_LEVEL_ONE)
				surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,"germs")
			if(L.surgery_open_stage)
				surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,"open")
	var/datum/internal_organ/I = M.internal_organs_by_name["eyes"]
	if(I && (M.disabilities & NEARSIGHTED || M.sdisabilities & BLIND || I.damage > 0))
		surgery_list += create_autodoc_surgery(null,ORGAN_SURGERY,"eyes",0,I)
	if(M.getBruteLoss() > 0)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,"brute")
	if(M.getFireLoss() > 0)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,"burn")
	if(M.getToxLoss() > 0)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,"toxin")
	var/overdoses = 0
	for(var/datum/reagent/x in M.reagents.reagent_list)
		if(istype(x,/datum/reagent/toxin)||M.reagents.get_reagent_amount(x.id) > x.overdose)
			overdoses++
	if(overdoses)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,"dialysis")
	if(M.blood_volume < BLOOD_VOLUME_NORMAL)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,"blood")
	return surgery_list

/obj/machinery/autodoc/proc/surgery_op(mob/living/carbon/M)
	if(M.stat == DEAD||!ishuman(M))
		visible_message("\The [src] buzzes.")
		src.go_out() //kick them out too.
		return

	var/mob/living/carbon/human/H = M
	var/datum/data/record/N = null
	for(var/datum/data/record/R in data_core.medical)
		if (R.fields["name"] == H.real_name)
			N = R
	if(isnull(N))
		visible_message("\The [src] buzzes: No records found for occupant.")
		src.go_out() //kick them out too.
		return

	var/list/surgery_todo_list
	if(automaticmode)
		surgery_todo_list = N.fields["autodoc_data"]
	else
		surgery_todo_list = N.fields["autodoc_manual"]

	if(!surgery_todo_list.len)
		visible_message("\The [src] buzzes, no surgical procedures were queued.")
		return

	visible_message("\The [src] begins to operate, loud audible clicks lock the pod.")
	surgery = 1
	icon_state = "autodoc_operate"

	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/loyalty, /obj/item/implant/tracking, /obj/item/implant/neurostim)

	for(var/datum/autodoc_surgery/A in surgery_todo_list)
		if(A.type_of_surgery == EXTERNAL_SURGERY)
			switch(A.surgery_procedure)
				if("brute")
					heal_brute = 1
				if("burn")
					heal_burn = 1
				if("toxin")
					heal_toxin = 1
				if("dialysis")
					filtering = 1
				if("blood")
					blood_transfer = 1
			surgery_todo_list -= A

	var/currentsurgery = 1
	while(surgery_todo_list.len > 0)
		if(!surgery)
			break;
		sleep(-1)
		var/datum/autodoc_surgery/S = surgery_todo_list[currentsurgery]
		if(automaticmode)
			surgery_mod = 1.5 // automatic mode takes longer
		else
			surgery_mod = 1 // might need tweaking

		switch(S.type_of_surgery)
			if(ORGAN_SURGERY)
				switch(S.surgery_procedure)
					if("germs") // Just dose them with the maximum amount of antibiotics and hope for the best
						if(prob(30)) visible_message("\The [src] speaks, Beginning organ disinfection.");
						var/datum/reagent/R = chemical_reagents_list["spaceacillin"]
						var/amount = R.overdose - H.reagents.get_reagent_amount("spaceacillin")
						var/inject_per_second = 3
						occupant << "<span class='info'>You feel a soft prick from a needle.</span>"
						while(amount > 0)
							if(!surgery) break
							if(amount < inject_per_second)
								H.reagents.add_reagent("spaceacillin",amount)
								break
							else
								H.reagents.add_reagent("spaceacillin",inject_per_second)
								amount -= inject_per_second
								sleep(10*surgery_mod)

					if("damage")
						if(prob(30)) visible_message("\The [src] speaks, Beginning organ restoration.");
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							visible_message("\The [src] speaks, Procedure has been deemed unnecessary.");
							surgery_todo_list -= S
							continue
						open_incision(H,S.limb_ref)

						if(S.limb_ref.name != "groin")
							open_encased(H,S.limb_ref)

						if(!istype(S.organ_ref,/datum/internal_organ/brain))
							sleep(FIX_ORGAN_MAX_DURATION*surgery_mod)
						else
							if(S.organ_ref.damage > BONECHIPS_MAX_DAMAGE)
								sleep(HEMOTOMA_MAX_DURATION*surgery_mod)
							sleep(BONECHIPS_REMOVAL_MAX_DURATION*surgery_mod)
						if(!surgery) break
						if(istype(S.organ_ref,/datum/internal_organ))
							S.organ_ref.rejuvenate()
						else
							visible_message("\The [src] speaks, Organ is missing.");

						// close them
						if(S.limb_ref.name != "groin") // TODO: fix brute damage before closing
							close_encased(H,S.limb_ref)
						close_incision(H,S.limb_ref)

					if("eyes")
						if(prob(30)) visible_message("\The [src] speaks, Beginning corrective eye surgery.");
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							visible_message("\The [src] speaks, Procedure has been deemed unnecessary.");
							surgery_todo_list -= S
							continue
						if(istype(S.organ_ref,/datum/internal_organ/eyes))
							var/datum/internal_organ/eyes/E = S.organ_ref

							if(E.eye_surgery_stage == 0)
								sleep(EYE_CUT_MAX_DURATION)
								if(!surgery) break
								E.eye_surgery_stage = 1
								H.disabilities |= NEARSIGHTED // code\#define\mobs.dm

							if(E.eye_surgery_stage == 1)
								sleep(EYE_LIFT_MAX_DURATION)
								if(!surgery) break
								E.eye_surgery_stage = 2

							if(E.eye_surgery_stage == 2)
								sleep(EYE_MEND_MAX_DURATION)
								if(!surgery) break
								E.eye_surgery_stage = 3

							if(E.eye_surgery_stage == 3)
								sleep(EYE_CAUTERISE_MAX_DURATION)
								if(!surgery) break
								H.disabilities &= ~NEARSIGHTED
								H.sdisabilities &= ~BLIND
								E.damage = 0
								E.eye_surgery_stage = 0


			if(LIMB_SURGERY)
				switch(S.surgery_procedure)
					if("internal")
						if(prob(30)) visible_message("\The [src] speaks, Beginning internal bleeding procedure.");
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							visible_message("\The [src] speaks, Procedure has been deemed unnecessary.");
							surgery_todo_list -= S
							continue
						open_incision(H,S.limb_ref)
						for(var/datum/wound/W in S.limb_ref.wounds)
							if(!surgery) break
							if(W.internal)
								sleep(FIXVEIN_MAX_DURATION*surgery_mod)
								S.limb_ref.wounds -= W
						if(!surgery) break
						close_incision(H,S.limb_ref)

					if("broken")
						if(prob(30)) visible_message("\The [src] speaks, Beginning broken bone procedure.");
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							visible_message("\The [src] speaks, Procedure has been deemed unnecessary.");
							surgery_todo_list -= S
							continue
						open_incision(H,S.limb_ref)
						sleep(BONEGEL_REPAIR_MAX_DURATION*surgery_mod)
						sleep(BONESETTER_MAX_DURATION*surgery_mod)
						if(S.limb_ref.brute_dam > 20)
							sleep(((S.limb_ref.brute_dam - 20)/2)*surgery_mod)
							if(!surgery) break
							S.limb_ref.heal_damage(S.limb_ref.brute_dam - 20,0)
						if(!surgery) break
						S.limb_ref.status &= ~LIMB_BROKEN
						S.limb_ref.status &= ~LIMB_SPLINTED
						S.limb_ref.status |= LIMB_REPAIRED
						S.limb_ref.perma_injury = 0
						close_incision(H,S.limb_ref)

					if("missing")
						if(prob(30)) visible_message("\The [src] speaks, Beginning limb replacement.");
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							visible_message("\The [src] speaks, Procedure has been deemed unnecessary.");
							surgery_todo_list -= S
							continue

						sleep(ROBOLIMB_CUT_MAX_DURATION*surgery_mod)
						sleep(ROBOLIMB_MEND_MAX_DURATION*surgery_mod)
						sleep(ROBOLIMB_PREPARE_MAX_DURATION*surgery_mod)

						if(stored_metal < LIMB_METAL_AMOUNT)
							visible_message("\The [src] croaks, Metal reserves depleted.")
							playsound(src.loc, 'sound/machines/buzz-two.ogg', 15, 1)
							surgery_todo_list -= S
							continue // next surgery

						stored_metal -= LIMB_METAL_AMOUNT

						if(S.limb_ref.parent.status & LIMB_DESTROYED) // there's nothing to attach to
							visible_message("\The [src] croaks, Limb attachment failed.")
							playsound(src.loc, 'sound/machines/buzz-two.ogg', 15, 1)
							surgery_todo_list -= S
							continue

						if(!surgery) break
						S.limb_ref.status |= LIMB_AMPUTATED
						S.limb_ref.setAmputatedTree()
						S.limb_ref.limb_replacement_stage = 0

						var/spillover = LIMB_PRINTING_TIME - (ROBOLIMB_PREPARE_MAX_DURATION+ROBOLIMB_MEND_MAX_DURATION+ROBOLIMB_CUT_MAX_DURATION)
						if(spillover > 0)
							sleep(spillover*surgery_mod)

						sleep(ROBOLIMB_ATTACH_MAX_DURATION*surgery_mod)
						if(!surgery) break
						S.limb_ref.robotize()
						H.update_body()
						H.updatehealth()
						H.UpdateDamageIcon()

					if("necro")
						if(prob(30)) visible_message("\The [src] speaks, Beginning necrotic tissue removal.");
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							visible_message("\The [src] speaks, Procedure has been deemed unnecessary.");
							surgery_todo_list -= S
							continue

						open_incision(H,S.limb_ref)
						sleep(NECRO_REMOVE_MAX_DURATION*surgery_mod)
						sleep(NECRO_TREAT_MAX_DURATION*surgery_mod)
						S.limb_ref.status &= ~LIMB_NECROTIZED
						H.update_body()

						close_incision(H,S.limb_ref)

					if("shrapnel")
						if(prob(30)) visible_message("\The [src] speaks, Beginning shrapnel removal.");
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							visible_message("\The [src] speaks, Procedure has been deemed unnecessary.");
							surgery_todo_list -= S
							continue

						open_incision(H,S.limb_ref)
						if(S.limb_ref.name == "chest" || S.limb_ref.name == "head")
							open_encased(H,S.limb_ref)
						if(S.limb_ref.implants.len)
							for(var/obj/item/I in S.limb_ref.implants)
								if(!surgery) break
								if(!is_type_in_list(I,known_implants))
									sleep(HEMOSTAT_REMOVE_MAX_DURATION*surgery_mod)
									S.limb_ref.implants -= I
									cdel(I)
						if(S.limb_ref.name == "chest" || S.limb_ref.name == "head")
							close_encased(H,S.limb_ref)
						if(!surgery) break
						close_incision(H,S.limb_ref)

					if("germ")
						if(prob(30)) visible_message("\The [src] speaks, Beginning limb disinfection.");

						var/datum/reagent/R = chemical_reagents_list["spaceacillin"]
						var/amount = (R.overdose/2) - H.reagents.get_reagent_amount("spaceacillin")
						var/inject_per_second = 3
						occupant << "<span class='info'>You feel a soft prick from a needle.</span>"
						while(amount > 0)
							if(!surgery) break
							if(amount < inject_per_second)
								H.reagents.add_reagent("spaceacillin",amount)
								break
							else
								H.reagents.add_reagent("spaceacillin",inject_per_second)
								amount -= inject_per_second
								sleep(10)

					if("facial") // dumb but covers for incomplete facial surgery
						if(prob(30)) visible_message("\The [src] speaks, Beginning Facial Reconstruction Surgery.");
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							visible_message("\The [src] speaks, Procedure has been deemed unnecessary.");
							surgery_todo_list -= S
							continue
						if(istype(S.limb_ref,/datum/limb/head))
							var/datum/limb/head/F = S.limb_ref
							if(F.face_surgery_stage == 0)
								sleep(FACIAL_CUT_MAX_DURATION)
								if(!surgery) break
								F.face_surgery_stage = 1
							if(F.face_surgery_stage == 1)
								sleep(FACIAL_MEND_MAX_DURATION)
								if(!surgery) break
								F.face_surgery_stage = 2
							if(F.face_surgery_stage == 2)
								sleep(FACIAL_FIX_MAX_DURATION)
								if(!surgery) break
								F.face_surgery_stage = 3
							if(F.face_surgery_stage == 3)
								sleep(FACIAL_CAUTERISE_MAX_DURATION)
								if(!surgery) break
								F.status &= ~LIMB_BLEEDING
								F.disfigured = 0
								F.owner.name = F.owner.get_visible_name()
								F.face_surgery_stage = 0

					if("open")
						if(prob(30)) visible_message("\The [src] croaks, Closing surgical incision.");
						close_encased(H,S.limb_ref)
						close_incision(H,S.limb_ref)

		if(prob(30)) visible_message("\The [src] speaks, Procedure complete.");
		surgery_todo_list -= S
		continue

	while(heal_brute||heal_burn||heal_toxin||filtering||blood_transfer)
		if(!surgery) break
		sleep(20)
		if(prob(5)) visible_message("\The [src] beeps as it continues working.");

	visible_message("\The [src] clicks and opens up having finished the requested operations.")
	surgery = 0
	go_out()


/obj/machinery/autodoc/proc/open_incision(mob/living/carbon/human/target, var/datum/limb/L)
	if(target && L && L.surgery_open_stage < 2)
		sleep(INCISION_MANAGER_MAX_DURATION*surgery_mod)
		if(!surgery) return
		L.createwound(CUT, 1)
		L.clamp() //Hemostat function, clamp bleeders
		L.surgery_open_stage = 2 //Can immediately proceed to other surgery steps
		target.updatehealth()

/obj/machinery/autodoc/proc/close_incision(mob/living/carbon/human/target, var/datum/limb/L)
	if(target && L && 0 < L.surgery_open_stage <= 2)
		sleep(CAUTERY_MAX_DURATION*surgery_mod)
		if(!surgery) return
		L.surgery_open_stage = 0
		L.germ_level = 0
		L.status &= ~LIMB_BLEEDING
		target.updatehealth()

/obj/machinery/autodoc/proc/open_encased(mob/living/carbon/human/target, var/datum/limb/L)
	if(target && L && L.surgery_open_stage >= 2)
		if(L.surgery_open_stage == 2) // this will cover for half completed surgeries
			sleep(SAW_OPEN_ENCASED_MAX_DURATION*surgery_mod)
			if(!surgery) return
			L.surgery_open_stage = 2.5
		if(L.surgery_open_stage == 2.5)
			sleep(RETRACT_OPEN_ENCASED_MAX_DURATION*surgery_mod)
			if(!surgery) return
			L.surgery_open_stage = 3

/obj/machinery/autodoc/proc/close_encased(mob/living/carbon/human/target, var/datum/limb/L)
	if(target && L && L.surgery_open_stage > 2)
		if(L.surgery_open_stage == 3) // this will cover for half completed surgeries
			sleep(RETRACT_CLOSE_ENCASED_MAX_DURATION*surgery_mod)
			if(!surgery) return
			L.surgery_open_stage = 2.5
		if(L.surgery_open_stage == 2.5)
			sleep(BONEGEL_CLOSE_ENCASED_MAX_DURATION*surgery_mod)
			if(!surgery) return
			L.surgery_open_stage = 2

/obj/machinery/autodoc/verb/eject()
	set name = "Eject Med-Pod"
	set category = "Object"
	set src in oview(1)
	if(usr.stat == DEAD)
		return // nooooooooooo
	if(occupant)
		if(isXeno(usr)) // let xenos eject people hiding inside.
			message_staff("[key_name(usr)] ejected [key_name(occupant)] from the autodoc.")
			log_admin("[key_name(usr)] ejected [key_name(occupant)] from the autodoc.")
			go_out()
			add_fingerprint(usr)
			return
		if(!ishuman(usr))
			return
		if(usr == occupant)
			if(surgery)
				usr << "<span class='warning'>There's no way you're getting out while this thing is operating on you!</span>"
			else
				visible_message("[usr] engages the internal release mechanism, and climbs out of \the [src].")
			return
		if(usr.mind && usr.mind.cm_skills && usr.mind.cm_skills.surgery < SKILL_SURGERY_TRAINED && !event)
			usr << "<span class='warning'>You don't have the training to use this.</span>"
			return
		if(surgery)
			visible_message("\The [src] malfunctions as [usr] aborts the surgery in progress.")
			occupant.take_limb_damage(rand(30,50),rand(30,50))
			surgery = 0
			// message_staff for now, may change to message_admins later
			message_staff("[key_name(usr)] ejected [key_name(occupant)] from the autodoc during surgery causing damage.")
			log_admin("[key_name(usr)] ejected [key_name(occupant)] from the autodoc during surgery causing damage.")
		go_out()
		add_fingerprint(usr)

/obj/machinery/autodoc/verb/move_inside()
	set name = "Enter Med-Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0 || !ishuman(usr)) return

	if(occupant)
		usr << "<span class='notice'>\The [src] is already occupied!</span>"
		return

	if(stat & (NOPOWER|BROKEN))
		usr << "<span class='notice'>\The [src] is non-functional!</span>"
		return

	if(usr.mind && usr.mind.cm_skills && usr.mind.cm_skills.surgery < SKILL_SURGERY_TRAINED && !event)
		usr << "<span class='warning'>You're going to need someone trained in the use of \the [src] to help you get into it.</span>"
		return

	usr.visible_message("<span class='notice'>[usr] starts climbing into \the [src].</span>",
	"<span class='notice'>You start climbing into \the [src].</span>")
	if(do_after(usr, 20, FALSE, 5, BUSY_ICON_GENERIC))
		if(occupant)
			usr << "<span class='notice'>\The [src] is already occupied!</span>"
			return
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		update_use_power(2)
		occupant = usr
		icon_state = "autodoc_closed"
		start_processing()
		connected.start_processing()

		for(var/obj/O in src)
			cdel(O)
		add_fingerprint(usr)

/obj/machinery/autodoc/proc/go_out()
	if(!occupant) return
	occupant.forceMove(loc)
	occupant = null
	surgery_todo_list = list()
	update_use_power(1)
	icon_state = "autodoc_open"
	stop_processing()
	connected.stop_processing()
	connected.process() // one last update

/obj/machinery/autodoc/attackby(obj/item/W, mob/living/user)
	if(!ishuman(user))
		return // no
	if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		user << "<span class='notice'>\The [src] processes \the [W].</span>"
		stored_metal += M.amount * 100
		user.drop_held_item()
		cdel(W)
		return
	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(!ishuman(G.grabbed_thing)) // stop fucking monkeys and xenos being put in.
			return
		var/mob/M = G.grabbed_thing
		if(src.occupant)
			user << "<span class='notice'>\The [src] is already occupied!</span>"
			return

		if(stat & (NOPOWER|BROKEN))
			user << "<span class='notice'>\The [src] is non-functional!</span>"
			return

		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.surgery < SKILL_SURGERY_TRAINED && !event)
			user << "<span class='warning'>You have no idea how to put someone into \the [src]!</span>"
			return

		visible_message("[user] starts putting [M] into [src].", 3)

		if(do_after(user, 20, FALSE, 5, BUSY_ICON_GENERIC))
			if(src.occupant)
				user << "<span class='notice'>\The [src] is already occupied!</span>"
				return
			if(!G || !G.grabbed_thing) return
			M.forceMove(src)
			update_use_power(2)
			occupant = M
			icon_state = "autodoc_closed"
			start_processing()
			connected.start_processing()

			add_fingerprint(user)

/////////////////////////////////////////////////////////////

//Auto Doc console that links up to it.
/obj/machinery/autodoc_console
	name = "\improper autodoc medical system control console"
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/autodoc/connected = null
	anchored = 1 //About time someone fixed this.
	density = 0

	use_power = 1
	idle_power_usage = 40

/obj/machinery/autodoc_console/New()
	..()
	spawn(5)
		connected = locate(/obj/machinery/autodoc, get_step(src, WEST))
		connected.connected = src

/obj/machinery/autodoc_console/power_change(var/area/master_area = null)
	..()
	if(stat & NOPOWER)
		if(icon_state != "sleeperconsole-p")
			icon_state = "sleeperconsole-p"
		return
	if(icon_state != "sleeperconsole")
		icon_state = "sleeperconsole"

/obj/machinery/autodoc_console/process()
	updateUsrDialog()

/obj/machinery/autodoc_console/attack_hand(mob/living/user)
	if(..())
		return
	var/dat = ""
	if(!connected || (connected.stat & (NOPOWER|BROKEN)))
		dat += "This console is not connected to a Med-Pod or the Med-Pod is non-functional."
		user << "This console seems to be powered down."
	else
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.surgery < SKILL_SURGERY_TRAINED && !connected.event)
			user << "<span class='warning'>You have no idea how to use this.</span>"
			return
		var/mob/living/occupant = connected.occupant
		dat += "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
		if(occupant)
			var/t1
			switch(occupant.stat)
				if(0)	t1 = "Conscious"
				if(1)	t1 = "<font color='blue'>Unconscious</font>"
				if(2)	t1 = "<font color='red'>*Dead*</font>"
			var/operating
			switch(connected.surgery)
				if(0) operating = "Not in surgery"
				if(1) operating = "IN SURGERY: DO NOT MANUALLY EJECT OR PATIENT HARM WILL BE CAUSED"
			dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), round(occupant.health), t1)
			if(iscarbon(occupant))
				var/mob/living/carbon/C = occupant
				dat += text("[]\t-Pulse, bpm: []</FONT><BR>", (C.pulse == PULSE_NONE || C.pulse == PULSE_THREADY ? "<font color='red'>" : "<font color='blue'>"), C.get_pulse(GETPULSE_TOOL))
			dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.getBruteLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getBruteLoss())
			dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.getOxyLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getOxyLoss())
			dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.getToxLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getToxLoss())
			dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.getFireLoss() < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.getFireLoss())
			//dat += text("<HR> Surgery Estimate: [] seconds<BR>", (connected.surgery_t * 0.1))
			if(connected.automaticmode)
				dat += "<hr><span class='notice'>Automatic Mode</span> | <a href='?src=\ref[src];automatictoggle=1'>Manual Mode</a>"
			else
				dat += "<hr><a href='?src=\ref[src];automatictoggle=1'>Automatic Mode</a> | <span class='notice'>Manual Mode</span>"
			dat += "<hr> Surgery Queue:<br>"

			var/list/surgeryqueue = list()

			var/datum/data/record/N = null
			for(var/datum/data/record/R in data_core.medical)
				if (R.fields["name"] == connected.occupant.real_name)
					N = R
			if(isnull(N))
				N = create_medical_record(connected.occupant)
			var/list/autosurgeries = N.fields["autodoc_data"]
			if(connected.automaticmode)
				if(autosurgeries.len)
					dat += "<span class='danger'>Automatic Mode Ready.</span><br>"
				else
					dat += "<span class='danger'>Automatic Mode Unavaliable, Scan Patient First.</span><br>"
			else
				if(!isnull(N.fields["autodoc_manual"]))
					//world << "AUTODOC DEBUG: non null autodoc data"
					for(var/datum/autodoc_surgery/A in N.fields["autodoc_manual"])
						//world << "AUTODOC DEBUG: found a surgery"
						switch(A.type_of_surgery)
							if(EXTERNAL_SURGERY)
								switch(A.surgery_procedure)
									if("brute")
										surgeryqueue["brute"] = 1
										dat += "Surgical Brute Damage Treatment"
									if("burn")
										surgeryqueue["burn"] = 1
										dat += "Surgical Burn Damage Treatment"
									if("toxin")
										surgeryqueue["toxin"] = 1
										dat += "Toxin Damage Chelation"
									if("dialysis")
										surgeryqueue["dialysis"] = 1
										dat += "Dialysis"
									if("blood")
										surgeryqueue["blood"] = 1
										dat += "Blood Transfer"
							if(ORGAN_SURGERY)
								switch(A.surgery_procedure)
									if("germs")
										surgeryqueue["organgerms"] = 1
										dat += "Organ Infection Treatment"
									if("damage")
										surgeryqueue["organdamage"] = 1
										dat += "Surgical Organ Damage Treatment"
									if("eyes")
										surgeryqueue["eyes"] = 1
										dat += "Corrective Eye Surgery"
							if(LIMB_SURGERY)
								switch(A.surgery_procedure)
									if("internal")
										surgeryqueue["internal"] = 1
										dat += "Internal Bleeding Surgery"
									if("broken")
										surgeryqueue["broken"] = 1
										dat += "Broken Bone Surgery"
									if("missing")
										surgeryqueue["missing"] = 1
										dat += "Limb Replacement Surgery"
									if("necro")
										surgeryqueue["necro"] = 1
										dat += "Necrosis Removal Surgery"
									if("shrapnel")
										surgeryqueue["shrapnel"] = 1
										dat += "Shrapnel Removal Surgery"
									if("germ")
										surgeryqueue["limbgerm"] = 1
										dat += "Limb Disinfection Procedure"
									if("facial")
										surgeryqueue["facial"] = 1
										dat += "Facial Reconstruction Surgery"
									if("open")
										surgeryqueue["open"] = 1
										dat += "Close Open Incision"
						dat += "<br>"

			dat += "<hr> Med-Pod Status: [operating] "
			dat += "<hr><a href='?src=\ref[src];clear=1'>Clear Surgery Queue</a>"
			dat += "<hr><a href='?src=\ref[src];refresh=1'>Refresh Menu</a>"
			dat += "<hr><a href='?src=\ref[src];surgery=1'>Begin Surgery Queue</a>"
			dat += "<hr><a href='?src=\ref[src];ejectify=1'>Eject Patient</a>"
			if(!connected.surgery)
				if(connected.automaticmode)
					dat += "<hr>Manual Surgery Interface Unavaliable, Automatic Mode Engaged."
				else
					dat += "<hr>Manual Surgery Interface<hr>"
					if(isnull(surgeryqueue["brute"]))
						dat += "<a href='?src=\ref[src];brute=1'>Surgical Brute Damage Treatment</a><br>"
					if(isnull(surgeryqueue["burn"]))
						dat += "<a href='?src=\ref[src];burn=1'>Surgical Burn Damage Treatment</a><br>"
					if(isnull(surgeryqueue["toxin"]))
						dat += "<a href='?src=\ref[src];toxin=1'>Toxin Damage Chelation</a><br>"
					if(isnull(surgeryqueue["dialysis"]))
						dat += "<a href='?src=\ref[src];dialysis=1'>Dialysis</a><br>"
					if(isnull(surgeryqueue["blood"]))
						dat += "<a href='?src=\ref[src];blood=1'>Blood Transfer</a><br>"
					if(isnull(surgeryqueue["organgerms"]))
						dat += "<a href='?src=\ref[src];organgerms=1'>Organ Infection Treatment</a><br>"
					if(isnull(surgeryqueue["organdamage"]))
						dat += "<a href='?src=\ref[src];organdamage=1'>Surgical Organ Damage Treatment</a><br>"
					if(isnull(surgeryqueue["eyes"]))
						dat += "<a href='?src=\ref[src];eyes=1'>Corrective Eye Surgery</a><br>"
					if(isnull(surgeryqueue["internal"]))
						dat += "<a href='?src=\ref[src];internal=1'>Internal Bleeding Surgery</a><br>"
					if(isnull(surgeryqueue["broken"]))
						dat += "<a href='?src=\ref[src];broken=1'>Broken Bone Surgery</a><br>"
					if(isnull(surgeryqueue["missing"]))
						dat += "<a href='?src=\ref[src];missing=1'>Limb Replacement Surgery</a><br>"
					if(isnull(surgeryqueue["necro"]))
						dat += "<a href='?src=\ref[src];necro=1'>Necrosis Removal Surgery</a><br>"
					if(isnull(surgeryqueue["shrapnel"]))
						dat += "<a href='?src=\ref[src];shrapnel=1'>Shrapnel Removal Surgery</a><br>"
					if(isnull(surgeryqueue["limbgerm"]))
						dat += "<a href='?src=\ref[src];limbgerm=1'>Limb Disinfection Procedure</a><br>"
					if(isnull(surgeryqueue["facial"]))
						dat += "<a href='?src=\ref[src];facial=1'>Facial Reconstruction Surgery</a><br>"
					if(isnull(surgeryqueue["open"]))
						dat += "<a href='?src=\ref[src];open=1'>Close Open Incision</a><br>"
		else
			dat += "The Med-Pod is empty."
	dat += text("<br><br><a href='?src=\ref[];mach_close=sleeper'>Close</a>", user)
	user << browse(dat, "window=sleeper;size=600x600")
	onclose(user, "sleeper")

/obj/machinery/autodoc_console/Topic(href, href_list)
	if(..())
		return
	if((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
		usr.set_interaction(src)

		if(connected.occupant && ishuman(connected.occupant))
			// manual surgery handling
			var/datum/data/record/N = null
			for(var/datum/data/record/R in data_core.medical)
				if (R.fields["name"] == connected.occupant.real_name)
					N = R
			if(isnull(N))
				N = create_medical_record(connected.occupant)

			var/needed = 0 // this is to stop someone just choosing everything
			if(href_list["brute"])
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,"brute")
				updateUsrDialog()
			if(href_list["burn"])
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,"burn")
				updateUsrDialog()
			if(href_list["toxin"])
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,"toxin")
				updateUsrDialog()
			if(href_list["dialysis"])
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,"dialysis")
				updateUsrDialog()
			if(href_list["blood"])
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,"blood")
				updateUsrDialog()
			if(href_list["organgerms"])
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,ORGAN_SURGERY,"germs")
				updateUsrDialog()
			if(href_list["eyes"])
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,ORGAN_SURGERY,"eyes",0,connected.occupant.internal_organs_by_name["eyes"])
				updateUsrDialog()
			if(href_list["organdamage"])
				for(var/datum/limb/L in connected.occupant.limbs)
					if(L)
						for(var/datum/internal_organ/I in L.internal_organs)
							if(I.robotic == ORGAN_ASSISTED||I.robotic == ORGAN_ROBOT)
								// we can't deal with these
								continue
							if(I.damage > 0)
								N.fields["autodoc_manual"] += create_autodoc_surgery(L,ORGAN_SURGERY,"damage",0,I)
								needed++
				if(!needed)
					N.fields["autodoc_manual"] += create_autodoc_surgery(null,ORGAN_SURGERY,"damage",1)
				updateUsrDialog()

			if(href_list["internal"])
				for(var/datum/limb/L in connected.occupant.limbs)
					if(L)
						for(var/datum/wound/W in L.wounds)
							if(W.internal)
								N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,"internal")
								needed++
								break
				if(!needed)
					N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,"internal",1)
				updateUsrDialog()

			if(href_list["broken"])
				for(var/datum/limb/L in connected.occupant.limbs)
					if(L)
						if(L.status & LIMB_BROKEN)
							N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,"broken")
							needed++
				if(!needed)
					N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,"broken",1)
				updateUsrDialog()

			if(href_list["missing"])
				for(var/datum/limb/L in connected.occupant.limbs)
					if(L)
						if(L.status & LIMB_DESTROYED)
							if(!(L.parent.status & LIMB_DESTROYED) && L.name != "head")
								N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,"missing")
								needed++
				if(!needed)
					N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,"missing",1)
				updateUsrDialog()

			if(href_list["necro"])
				for(var/datum/limb/L in connected.occupant.limbs)
					if(L)
						if(L.status & LIMB_NECROTIZED)
							N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,"necro")
							needed++
				if(!needed)
					N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,"necro",1)
				updateUsrDialog()

			if(href_list["shrapnel"])
				var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/loyalty, /obj/item/implant/tracking, /obj/item/implant/neurostim)
				for(var/datum/limb/L in connected.occupant.limbs)
					if(L)
						if(L.implants.len)
							for(var/I in L.implants)
								if(!is_type_in_list(I,known_implants))
									N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,"shrapnel")
									needed++
				if(!needed)
					N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,"shrapnel",1)
				updateUsrDialog()
			if(href_list["limbgerm"])
				N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,"germ")
				updateUsrDialog()

			if(href_list["facial"])
				for(var/datum/limb/L in connected.occupant.limbs)
					if(L)
						if(istype(L,/datum/limb/head))
							var/datum/limb/head/J = L
							if(J.disfigured || J.face_surgery_stage)
								N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,"facial")
							else
								N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,"facial",1)
							updateUsrDialog()
							break

			if(href_list["open"])
				for(var/datum/limb/L in connected.occupant.limbs)
					if(L)
						if(L.surgery_open_stage)
							N.fields["autodoc_manual"] += create_autodoc_surgery(L,LIMB_SURGERY,"open")
							needed++
				if(href_list["open"])
					N.fields["autodoc_manual"] += create_autodoc_surgery(null,LIMB_SURGERY,"open",1)
				updateUsrDialog()

			// The rest
			if(href_list["clear"])
				N.fields["autodoc_manual"] = list()
				updateUsrDialog()
		if(href_list["automatictoggle"])
			connected.automaticmode = !connected.automaticmode
			updateUsrDialog()
		if(href_list["refresh"])
			updateUsrDialog()
		if(href_list["surgery"])
			if(connected.occupant)
				connected.surgery_op(src.connected.occupant)
			updateUsrDialog()
		if(href_list["ejectify"])
			connected.eject()
			updateUsrDialog()
		add_fingerprint(usr)

/obj/machinery/autodoc/event
	event = 1
