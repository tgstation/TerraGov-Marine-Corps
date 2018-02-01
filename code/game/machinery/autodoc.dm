//Autodoc
/obj/machinery/autodoc
	name = "\improper autodoc medical system"
	desc = "A fancy machine developed to be capable of operating on people with minimal human intervention. The interface is rather complex and would only be useful to trained Doctors however."
	icon = 'icons/obj/machines/cryogenics.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1
	var/mob/living/carbon/human/occupant = null
	var/surgery_todo_list = list() //a list of surgeries to do.
//	var/surgery_t = 0 //Surgery timer in seconds.
	var/surgery = 0 //Are we operating or no? 0 for no, 1 for yes
	var/surgery_mod = 1 //What multiple to increase the surgery timer? This is used for any non-WO maps or events that are done.
	var/obj/item/reagent_container/blood/OMinus/blood_pack = new()
	var/filtering = 0
	var/blood_transfer = 0
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_toxin = 0

	req_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY) // limit to doc IDs

	//It uses power
	use_power = 1
	idle_power_usage = 15
	active_power_usage = 450 //Capable of doing various activities

	var/stored_metal = 500 // starts with 500 metal loaded

/obj/machinery/autodoc/process()
	set background=1
	updateUsrDialog()
	if(occupant)
		if(occupant.stat == DEAD)
			visible_message("[src] speaks: Patient has expired.")
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
					if(x.name == "Blood")
						continue
					occupant.reagents.remove_reagent(x.id, 3) // same as sleeper, may need reducing
					filtered += 3
				if(!filtered)
					filtering = 0
					visible_message("[src] speaks: Blood filtering complete.")
			if(blood_transfer)
				if(occupant.vessel.get_reagent_amount("blood") < BLOOD_VOLUME_NORMAL)
					if(blood_pack.reagents.get_reagent_amount("blood") < 4)
						blood_pack.reagents.add_reagent("blood", 195, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"="O-","resistances"=null,"trace_chem"=null))
						visible_message("[src] speaks: Blood reserves depleted, switching to fresh bag.")
					blood_pack.reagents.trans_to(occupant, 4) // give them some blood, same as iv stand
				else
					blood_transfer = 0
					visible_message("[src] speaks: Blood transfer complete.")
			if(heal_brute)
				if(occupant.getBruteLoss() > 0)
					occupant.heal_limb_damage(3,0)
				else
					heal_brute = 0
					visible_message("[src] speaks: Surgical trauma repairs complete.")
			if(heal_burn)
				if(occupant.getFireLoss() > 0)
					occupant.heal_limb_damage(0,3)
				else
					heal_burn = 0
					visible_message("[src] speaks: Skin grafts complete.")
			if(heal_toxin)
				if(occupant.getToxLoss() > 0)
					occupant.adjustToxLoss(-3)
				else
					heal_toxin = 0
					visible_message("[src] speaks: Kelation complete.")


#define LIMB_SURGERY 1
#define ORGAN_SURGERY 2
#define EXTERNAL_SURGERY 3

#define UNNEEDED_DELAY 100 // how long to waste if someone queues an unneeded surgery

/datum/autodoc_surgery
	var/datum/limb/limb_ref = null
	var/datum/internal_organ/organ_ref = null
	var/type_of_surgery = 0 // the above constants
	var/surgery_procedure = "" // text of surgery
	var/automatic = 0
	var/unneeded = 0

proc/create_autodoc_surgery(surg_ref, type_of_surgery, surgery_procedure, automatic=1, unneeded=0)
	var/datum/autodoc_surgery/A = new()
	A.type_of_surgery = type_of_surgery
	A.surgery_procedure = surgery_procedure
	A.automatic = automatic
	A.unneeded = unneeded
	switch(type_of_surgery)
		if(LIMB_SURGERY)
			A.limb_ref = surg_ref
		if(ORGAN_SURGERY)
			A.organ_ref = surg_ref
	return A

/obj/machinery/autodoc/allow_drop()
	return 0

proc/generate_autodoc_surgery_list(mob/living/carbon/human/M)
	if(!ishuman(M))
		return null
	var/surgery_list = list()
	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/loyalty, /obj/item/implant/tracking)

	for(var/datum/internal_organ/I in M.internal_organs)
		if(I.robotic == ORGAN_ASSISTED||I.robotic == ORGAN_ROBOT)
			// we can't deal with these
			continue
		if(I.germ_level > 1)
			surgery_list += create_autodoc_surgery(I,ORGAN_SURGERY,"germs")
		if(I.damage > 0)
			surgery_list += create_autodoc_surgery(I,ORGAN_SURGERY,"damage")

	for(var/datum/limb/L in M.limbs)
		if(L)
			for(var/datum/wound/W in L.wounds)
				if(W.internal)
					surgery_list += create_autodoc_surgery(L,LIMB_SURGERY,"internal")
					break

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
	if(M.getBruteLoss() > 0)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,"brute")
	if(M.getFireLoss() > 0)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,"burn")
	if(M.getToxLoss() > 0)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,"toxin")
	var/overdoses = 0
	for(var/datum/reagent/x in M.reagents.reagent_list)
		if(x.name == "Blood")
			continue
		if(istype(x,/datum/reagent/toxin)||M.reagents.get_reagent_amount(x.id) > x.overdose)
			overdoses++
	if(overdoses)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,"dialysis")
	if(M.vessel.get_reagent_amount("blood") < BLOOD_VOLUME_NORMAL)
		surgery_list += create_autodoc_surgery(null,EXTERNAL_SURGERY,"blood")
	return surgery_list

/obj/machinery/autodoc/proc/surgery_op(mob/living/carbon/M)
	if(M.stat == DEAD||!ishuman(M))
		visible_message("[src] buzzes.")
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

	if(isnull(N.fields["autodoc_data"]))
		visible_message("\The [src] buzzes, no surgical procedures were queued.")
		return

	visible_message("\The [src] begins to operate, loud audiable clicks lock the pod.")
	surgery = 1

	var/list/surgery_todo_list = N.fields["autodoc_data"]
	var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/loyalty, /obj/item/implant/tracking)

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
		if(S.automatic)
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

						sleep(INCISION_MANAGER_MAX_DURATION*surgery_mod)

						if(!(S.organ_ref.parent_limb == "groin"))
							sleep(SAW_OPEN_ENCASED_MAX_DURATION*surgery_mod)
							sleep(RETRACT_OPEN_ENCASED_MAX_DURATION*surgery_mod)

						if(!istype(S.organ_ref,/datum/internal_organ/brain))
							sleep(FIX_ORGAN_MAX_DURATION*surgery_mod)
						else
							if(S.organ_ref.damage > BONECHIPS_MAX_DAMAGE)
								sleep(HEMOTOMA_MAX_DURATION*surgery_mod)
							sleep(BONECHIPS_REMOVAL_MAX_DURATION*surgery_mod)
						if(!surgery) break
						S.organ_ref.rejuvenate()
						// close them
						if(!(S.organ_ref.parent_limb == "groin")) // TODO: fix brute damage before closing
							sleep(RETRACT_CLOSE_ENCASED_MAX_DURATION*surgery_mod)
							sleep(BONEGEL_CLOSE_ENCASED_MAX_DURATION*surgery_mod)
						sleep(CAUTERY_MAX_DURATION*surgery_mod)

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
						if(istype(S.limb_ref.name,/datum/limb/chest)||istype(S.limb_ref.name,/obj/item/limb/head))
							sleep(SAW_OPEN_ENCASED_MAX_DURATION*surgery_mod)
							sleep(RETRACT_OPEN_ENCASED_MAX_DURATION*surgery_mod)
						sleep(NECRO_REMOVE_MAX_DURATION*surgery_mod)
						sleep(NECRO_TREAT_MAX_DURATION*surgery_mod)
						S.limb_ref.status &= ~LIMB_NECROTIZED
						H.update_body()

						if(istype(S.limb_ref.name,/datum/limb/chest)||istype(S.limb_ref.name,/obj/item/limb/head))
							sleep(RETRACT_CLOSE_ENCASED_MAX_DURATION*surgery_mod)
							sleep(BONEGEL_CLOSE_ENCASED_MAX_DURATION*surgery_mod)
						close_incision(H,S.limb_ref)

					if("shrapnel")
						if(prob(30)) visible_message("\The [src] speaks, Beginning shrapnel removal.");
						if(S.unneeded)
							sleep(UNNEEDED_DELAY)
							visible_message("\The [src] speaks, Procedure has been deemed unnecessary.");
							surgery_todo_list -= S
							continue

						open_incision(H,S.limb_ref)
						if(istype(S.limb_ref.name,/datum/limb/chest)||istype(S.limb_ref.name,/obj/item/limb/head))
							sleep(SAW_OPEN_ENCASED_MAX_DURATION*surgery_mod)
							sleep(RETRACT_OPEN_ENCASED_MAX_DURATION*surgery_mod)
						if(S.limb_ref.implants.len)
							for(var/obj/item/I in S.limb_ref.implants)
								if(!surgery) break
								if(!is_type_in_list(I,known_implants))
									sleep(HEMOSTAT_REMOVE_MAX_DURATION*surgery_mod)
									S.limb_ref.implants -= I
									cdel(I)
						if(istype(S.limb_ref.name,/datum/limb/chest)||istype(S.limb_ref.name,/obj/item/limb/head))
							sleep(RETRACT_CLOSE_ENCASED_MAX_DURATION*surgery_mod)
							sleep(BONEGEL_CLOSE_ENCASED_MAX_DURATION*surgery_mod)
						if(!surgery) break
						close_incision(H,S.limb_ref)

					if("germ")
						if(prob(30)) visible_message("\The [src] speaks, Beginning limb disinfection.");

						var/datum/reagent/R = chemical_reagents_list["spaceacillin"]
						var/amount = (R.overdose/2) - H.reagents.get_reagent_amount("spaceacillin")
						var/inject_per_second = 3
						while(amount > 0)
							if(!surgery) break
							if(amount < inject_per_second)
								H.reagents.add_reagent("spaceacillin",amount)
								break
							else
								H.reagents.add_reagent("spaceacillin",inject_per_second)
								amount -= inject_per_second
								sleep(10)

					if("open")
						if(prob(30)) visible_message("\The [src] croaks, Closing surgical incision.");
						close_incision(H,S.limb_ref)

		if(prob(30)) visible_message("\The [src] speaks, Procedure complete.");
		surgery_todo_list -= S
		continue

	while(heal_brute||heal_burn||heal_toxin||filtering||blood_transfer)
		sleep(20)
		if(prob(5)) visible_message("\The [src] beeps as it continues working.");

	visible_message("\The [src] clicks and opens up having finished the requested operations.")
	go_out()
	icon_state = "sleeper_0"
	surgery = 0

/obj/machinery/autodoc/proc/open_incision(mob/living/carbon/human/target, var/datum/limb/L)
	if(target && L)
		sleep(INCISION_MANAGER_MAX_DURATION*surgery_mod)
		L.createwound(CUT, 1)
		L.clamp() //Hemostat function, clamp bleeders
		L.surgery_open_stage = 2 //Can immediately proceed to other surgery steps
		target.updatehealth()

/obj/machinery/autodoc/proc/close_incision(mob/living/carbon/human/target, var/datum/limb/L)
	if(target && L)
		sleep(CAUTERY_MAX_DURATION*surgery_mod)
		L.surgery_open_stage = 0
		L.germ_level = 0
		L.status &= ~LIMB_BLEEDING
		target.updatehealth()

/obj/machinery/autodoc/verb/eject()
	set name = "Eject Med-Pod"
	set category = "Object"
	set src in oview(1)

	if(surgery && occupant)
		visible_message("\The [src] malfunctions as you abort the surgery.")
		occupant.take_limb_damage(rand(30,50),rand(30,50))
		surgery = 0
	if(usr.stat != 0) return
	go_out()
	add_fingerprint(usr)

/obj/machinery/autodoc/verb/move_inside()
	set name = "Enter Med-Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr))) return

	if(occupant)
		usr << "<span class='notice'>[src] is already occupied!</span>"
		return

	if(stat & (NOPOWER|BROKEN))
		usr << "<span class='notice'>[src] is non-functional!</span>"
		return

	usr.visible_message("<span class='notice'>[usr] starts climbing into [src].</span>",
	"<span class='notice'>You start climbing into [src].</span>")
	if(do_after(usr, 20, FALSE, 5, BUSY_ICON_CLOCK))
		if(occupant)
			usr << "<span class='notice'>[src] is already occupied!</span>"
			return
		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		update_use_power(2)
		occupant = usr
		icon_state = "sleeper_1"

		for(var/obj/O in src)
			cdel(O)
		add_fingerprint(usr)

/obj/machinery/autodoc/proc/go_out()
	if(!occupant) return
	occupant.forceMove(loc)
	occupant = null
	update_use_power(1)
	icon_state = "sleeper_0"

/obj/machinery/autodoc/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/M = W
		user << "<span class='notice'>\The [src] processes \the [W].</span>"
		stored_metal += M.amount * 100
		user.drop_held_item()
		cdel(W)
		return
	if(istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(!ismob(G.grabbed_thing))
			return
		var/mob/M = G.grabbed_thing
		if(src.occupant)
			user << "<span class='notice'>[src] is already occupied!</span>"
			return

		if(stat & (NOPOWER|BROKEN))
			user << "<span class='notice'>[src] is non-functional!</span>"
			return

		visible_message("[user] starts putting [M] into [src].", 3)

		if(do_after(user, 20, FALSE, 5, BUSY_ICON_CLOCK))
			if(src.occupant)
				user << "<span class='notice'>[src] is already occupied!</span>"
				return
			if(!G || !G.grabbed_thing) return
			M.forceMove(src)
			update_use_power(2)
			occupant = M
			icon_state = "sleeper_1"

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

	New()
		..()
		spawn(5)
			connected = locate(/obj/machinery/autodoc, get_step(src, WEST))

/obj/machinery/autodoc_console/process()
	if(stat & (NOPOWER|BROKEN))
		if(icon_state != "sleeperconsole-p")
			icon_state = "sleeperconsole-p"
		return
	if(icon_state != "sleeperconsole")
		icon_state = "sleeperconsole"
	updateUsrDialog()

/obj/machinery/autodoc_console/attack_hand(mob/living/user)
	if(..())
		return
	var/dat = ""
	if(!connected || (connected.stat & (NOPOWER|BROKEN)))
		dat += "This console is not connected to a Med-Pod or the Med-Pod is non-functional."
		user << "This console seems to be powered down."
	else
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.surgery < SKILL_SURGERY_TRAINED)
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
			dat += text("<hr> Surgery Queue:<br>")

			var/list/surgeryqueue = list()

			var/datum/data/record/N = null
			for(var/datum/data/record/R in data_core.medical)
				if (R.fields["name"] == connected.occupant.real_name)
					N = R
			if(isnull(N))
				N = create_medical_record(connected.occupant)

			if(!isnull(N.fields["autodoc_data"]))
				//world << "AUTODOC DEBUG: non null autodoc data"
				for(var/datum/autodoc_surgery/A in N.fields["autodoc_data"])
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
									dat += "Toxin Damage Kelation"
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
								if("open")
									surgeryqueue["open"] = 1
									dat += "Close Open Incision"
					if(A.automatic)
						surgeryqueue["automatic"] = 1
						dat += " in Automatic Mode<br>"
					else
						dat += " in Manual Mode<br>"

			dat += "<hr> Med-Pod Status: [operating] "
			dat += "<hr><a href='?src=\ref[src];clear=1'>Clear Surgery Queue</a>"
			dat += "<hr><a href='?src=\ref[src];refresh=1'>Refresh Menu</a>"
			dat += "<hr><a href='?src=\ref[src];surgery=1'>Begin Surgery Queue</a>"
			dat += "<hr><a href='?src=\ref[src];ejectify=1'>Eject Patient</a>"
			if(!connected.surgery)
				if(surgeryqueue["automatic"])
					dat += "<hr>Manual Surgery Interface Unavaliable, Automatic Surgeries Queued"
				else
					dat += "<hr>Manual Surgery Interface<hr>"
					if(isnull(surgeryqueue["brute"]))
						dat += "<a href='?src=\ref[src];brute=1'>Surgical Brute Damage Treatment</a><br>"
					if(isnull(surgeryqueue["burn"]))
						dat += "<a href='?src=\ref[src];burn=1'>Surgical Burn Damage Treatment</a><br>"
					if(isnull(surgeryqueue["toxin"]))
						dat += "<a href='?src=\ref[src];toxin=1'>Toxin Damage Kelation</a><br>"
					if(isnull(surgeryqueue["dialysis"]))
						dat += "<a href='?src=\ref[src];dialysis=1'>Dialysis</a><br>"
					if(isnull(surgeryqueue["blood"]))
						dat += "<a href='?src=\ref[src];blood=1'>Blood Transfer</a><br>"
					if(isnull(surgeryqueue["organgerms"]))
						dat += "<a href='?src=\ref[src];organgerms=1'>Organ Infection Treatment</a><br>"
					if(isnull(surgeryqueue["organdamage"]))
						dat += "<a href='?src=\ref[src];organdamage=1'>Surgical Organ Damage Treatment</a><br>"
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
		// manual surgery handling
		var/datum/data/record/N = null
		for(var/datum/data/record/R in data_core.medical)
			if (R.fields["name"] == connected.occupant.real_name)
				N = R
		if(isnull(N))
			N = create_medical_record(connected.occupant)

		var/needed = 0 // this is to stop someone just choosing everything
		if(href_list["brute"])
			N.fields["autodoc_data"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,"brute",0)
			updateUsrDialog()
		if(href_list["burn"])
			N.fields["autodoc_data"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,"burn",0)
			updateUsrDialog()
		if(href_list["toxin"])
			N.fields["autodoc_data"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,"toxin",0)
			updateUsrDialog()
		if(href_list["dialysis"])
			N.fields["autodoc_data"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,"dialysis",0)
			updateUsrDialog()
		if(href_list["blood"])
			N.fields["autodoc_data"] += create_autodoc_surgery(null,EXTERNAL_SURGERY,"blood",0)
			updateUsrDialog()
		if(href_list["organgerms"])
			N.fields["autodoc_data"] += create_autodoc_surgery(null,ORGAN_SURGERY,"germs",0)
			updateUsrDialog()
		if(href_list["organdamage"])
			for(var/datum/internal_organ/I in connected.occupant.internal_organs)
				if(I.robotic == ORGAN_ASSISTED||I.robotic == ORGAN_ROBOT)
					// we can't deal with these
					continue
				if(I.damage > 0)
					N.fields["autodoc_data"] += create_autodoc_surgery(I,ORGAN_SURGERY,"damage",0)
					needed++
			if(!needed)
				N.fields["autodoc_data"] += create_autodoc_surgery(null,ORGAN_SURGERY,"damage",0,1)
			updateUsrDialog()

		if(href_list["internal"])
			for(var/datum/limb/L in connected.occupant.limbs)
				if(L)
					for(var/datum/wound/W in L.wounds)
						if(W.internal)
							N.fields["autodoc_data"] += create_autodoc_surgery(L,LIMB_SURGERY,"internal",0)
							needed++
							break
			if(!needed)
				N.fields["autodoc_data"] += create_autodoc_surgery(null,LIMB_SURGERY,"internal",0,1)
			updateUsrDialog()

		if(href_list["broken"])
			for(var/datum/limb/L in connected.occupant.limbs)
				if(L)
					if(L.status & LIMB_BROKEN)
						N.fields["autodoc_data"] += create_autodoc_surgery(L,LIMB_SURGERY,"broken",0)
						needed++
			if(!needed)
				N.fields["autodoc_data"] += create_autodoc_surgery(null,LIMB_SURGERY,"broken",0,1)
			updateUsrDialog()

		if(href_list["missing"])
			for(var/datum/limb/L in connected.occupant.limbs)
				if(L)
					if(L.status & LIMB_DESTROYED)
						if(!(L.parent.status & LIMB_DESTROYED) && L.name != "head")
							N.fields["autodoc_data"] += create_autodoc_surgery(L,LIMB_SURGERY,"missing",0)
							needed++
			if(!needed)
				N.fields["autodoc_data"] += create_autodoc_surgery(null,LIMB_SURGERY,"missing",0,1)
			updateUsrDialog()

		if(href_list["necro"])
			for(var/datum/limb/L in connected.occupant.limbs)
				if(L)
					if(L.status & LIMB_NECROTIZED)
						N.fields["autodoc_data"] += create_autodoc_surgery(L,LIMB_SURGERY,"necro",0)
						needed++
			if(!needed)
				N.fields["autodoc_data"] += create_autodoc_surgery(null,LIMB_SURGERY,"necro",0,1)
			updateUsrDialog()

		if(href_list["shrapnel"])
			var/known_implants = list(/obj/item/implant/chem, /obj/item/implant/death_alarm, /obj/item/implant/loyalty, /obj/item/implant/tracking)
			for(var/datum/limb/L in connected.occupant.limbs)
				if(L)
					if(L.implants.len)
						for(var/I in L.implants)
							if(!is_type_in_list(I,known_implants))
								N.fields["autodoc_data"] += create_autodoc_surgery(L,LIMB_SURGERY,"shrapnel",0)
								needed++
			if(!needed)
				N.fields["autodoc_data"] += create_autodoc_surgery(null,LIMB_SURGERY,"shrapnel",0,1)
			updateUsrDialog()

		if(href_list["limbgerm"])
			N.fields["autodoc_data"] += create_autodoc_surgery(null,LIMB_SURGERY,"germs",0)
			updateUsrDialog()
		if(href_list["open"])
			for(var/datum/limb/L in connected.occupant.limbs)
				if(L)
					if(L.surgery_open_stage)
						N.fields["autodoc_data"] += create_autodoc_surgery(L,LIMB_SURGERY,"open",0)
						needed++
			if(href_list["limbgerm"])
				N.fields["autodoc_data"] += create_autodoc_surgery(null,LIMB_SURGERY,"open",0,1)
			updateUsrDialog()

		// The rest
		if(href_list["clear"])
			N.fields["autodoc_data"] = list()
			updateUsrDialog()
		if(href_list["refresh"])
			updateUsrDialog()
		if(href_list["surgery"])
			connected.surgery_op(src.connected.occupant)
			updateUsrDialog()
		if(href_list["ejectify"])
			connected.eject()
			updateUsrDialog()
		add_fingerprint(usr)
