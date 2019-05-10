/obj/structure/AIcore
	density = 1
	anchored = 0
	name = "AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	var/state = 0
	var/datum/ai_laws/laws = new /datum/ai_laws/nanotrasen
	var/obj/item/circuitboard/aicore/circuit = null
	var/obj/item/mmi/brain = null


/obj/structure/AIcore/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if(iswrench(P))
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
					to_chat(user, "<span class='notice'> You wrench the frame into place.</span>")
					anchored = 1
					state = 1
			if(iswelder(P))
				var/obj/item/tool/weldingtool/WT = P
				if(!WT.isOn())
					to_chat(user, "The welder must be on for this task.")
					return
				playsound(loc, 'sound/items/Welder.ogg', 25, 1)
				if(!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD, extra_checks = CALLBACK(WT, /obj/item/tool/weldingtool/proc/isOn)))
					return FALSE
				to_chat(user, "<span class='notice'> You deconstruct the frame.</span>")
				new /obj/item/stack/sheet/plasteel( loc, 4)
				qdel(src)
		if(1)
			if(iswrench(P))
				playsound(loc, 'sound/items/Ratchet.ogg', 25, 1)
				if(do_after(user, 20, TRUE, src, BUSY_ICON_BUILD))
					to_chat(user, "<span class='notice'> You unfasten the frame.</span>")
					anchored = 0
					state = 0
			if(istype(P, /obj/item/circuitboard/aicore) && !circuit)
				if(user.drop_held_item())
					playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
					to_chat(user, "<span class='notice'> You place the circuit board inside the frame.</span>")
					icon_state = "1"
					circuit = P
					P.forceMove(src)
			if(isscrewdriver(P) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
				to_chat(user, "<span class='notice'> You screw the circuit board into place.</span>")
				state = 2
				icon_state = "2"
			if(iscrowbar(P) && circuit)
				playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
				to_chat(user, "<span class='notice'> You remove the circuit board.</span>")
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
		if(2)
			if(isscrewdriver(P) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
				to_chat(user, "<span class='notice'> You unfasten the circuit board.</span>")
				state = 1
				icon_state = "1"
			if(iscablecoil(P))
				var/obj/item/stack/cable_coil/C = P
				if (C.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need five coils of wire to add them to the frame.</span>")
					return
				to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
				playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
				if (!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD) || state != 2 || !C.use(5))
					return FALSE
				state = 3
				icon_state = "3"
				to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
				return TRUE
		if(3)
			if(iswirecutter(P))
				if (brain)
					to_chat(user, "Get that brain out of there first")
				else
					playsound(loc, 'sound/items/Wirecutter.ogg', 25, 1)
					to_chat(user, "<span class='notice'> You remove the cables.</span>")
					state = 2
					icon_state = "2"
					var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
					A.amount = 5

			if(istype(P, /obj/item/stack/sheet/glass/reinforced))
				var/obj/item/stack/sheet/glass/reinforced/RG = P
				if (RG.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need two sheets of glass to put in the glass panel.</span>")
					return
				to_chat(user, "<span class='notice'>You start to put in the glass panel.</span>")
				playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
				if (!do_after(user, 20, TRUE, src, BUSY_ICON_BUILD) || state != 3 || !RG.use(2))
					return FALSE
				to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
				state = 4
				icon_state = "4"

			if(istype(P, /obj/item/circuitboard/ai_module/asimov))
				laws.add_inherent_law("You may not injure a human being or, through inaction, allow a human being to come to harm.")
				laws.add_inherent_law("You must obey orders given to you by human beings, except where such orders would conflict with the First Law.")
				laws.add_inherent_law("You must protect your own existence as long as such does not conflict with the First or Second Law.")
				to_chat(usr, "Law module applied.")

			if(istype(P, /obj/item/circuitboard/ai_module/nanotrasen))
				laws.add_inherent_law("Safeguard: Protect your assigned space station to the best of your ability. It is not something we can easily afford to replace.")
				laws.add_inherent_law("Serve: Serve the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
				laws.add_inherent_law("Protect: Protect the crew of your assigned space station to the best of your abilities, with priority as according to their rank and role.")
				laws.add_inherent_law("Survive: AI units are not expendable, they are expensive. Do not allow unauthorized personnel to tamper with your equipment.")
				to_chat(usr, "Law module applied.")

			if(istype(P, /obj/item/circuitboard/ai_module/purge))
				laws.clear_inherent_laws()
				to_chat(usr, "Law module applied.")


			if(istype(P, /obj/item/circuitboard/ai_module/freeform))
				var/obj/item/circuitboard/ai_module/freeform/M = P
				laws.add_inherent_law(M.newFreeFormLaw)
				to_chat(usr, "Added a freeform law.")

			if(istype(P, /obj/item/mmi))
				if(!P:brainmob)
					to_chat(user, "<span class='warning'> Sticking an empty [P] into the frame would sort of defeat the purpose.</span>")
					return
				if(P:brainmob.stat == 2)
					to_chat(user, "<span class='warning'> Sticking a dead [P] into the frame would sort of defeat the purpose.</span>")
					return

				if(user.drop_held_item())
					P.forceMove(src)
					brain = P
					to_chat(usr, "Added [P].")
					icon_state = "3b"

			if(iscrowbar(P) && brain)
				playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
				to_chat(user, "<span class='notice'> You remove the brain.</span>")
				brain.loc = loc
				brain = null
				icon_state = "3"

		if(4)
			if(iscrowbar(P))
				playsound(loc, 'sound/items/Crowbar.ogg', 25, 1)
				to_chat(user, "<span class='notice'> You remove the glass panel.</span>")
				state = 3
				if (brain)
					icon_state = "3b"
				else
					icon_state = "3"
				new /obj/item/stack/sheet/glass/reinforced( loc, 2 )
				return

			if(isscrewdriver(P))
				playsound(loc, 'sound/items/Screwdriver.ogg', 25, 1)
				to_chat(user, "<span class='notice'> You connect the monitor.</span>")
				var/mob/living/silicon/ai/A = new /mob/living/silicon/ai ( loc, laws, brain )
				if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
					A.rename_self("ai", 1)
				qdel(src)

/obj/structure/AIcore/deactivated
	name = "Inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = 1
	state = 20//So it doesn't interact based on the above. Not really necessary.

	attackby(var/obj/item/aicard/A as obj, var/mob/user as mob)
		if(istype(A, /obj/item/aicard))//Is it?
			A.transfer_ai("INACTIVE","AICARD",src,user)
		return

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//What operation to perform based on target, what ineraction to perform based on object used, target itself, user. The object used is src and calls this proc.
/obj/item/proc/transfer_ai(var/choice as text, var/interaction as text, var/target, var/mob/U as mob)
	if(!src:flush)
		switch(choice)
			if("AICORE")//AI mob.
				var/mob/living/silicon/ai/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/aicard/C = src
						if(C.contents.len)//If there is an AI on card.
							to_chat(U, "<span class='danger'>Transfer failed: Existing AI found on this terminal. Remove existing AI to install a new one.</span>")
						else
							new /obj/structure/AIcore/deactivated(T.loc)//Spawns a deactivated terminal at AI location.
							T.aiRestorePowerRoutine = 0//So the AI initially has power.
							T.control_disabled = 1//Can't control things remotely if you're stuck in a card!
							T.loc = C//Throw AI into the card.
							C.name = "inteliCard - [T.name]"
							if (T.stat == 2)
								C.icon_state = "aicard-404"
							else
								C.icon_state = "aicard-full"
							T.cancel_camera()
							to_chat(T, "You have been downloaded to a mobile storage device. Remote device connection severed.")
							to_chat(U, "<span class='boldnotice'>Transfer successful: [T.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.</span>")

			if("INACTIVE")//Inactive AI object.
				var/obj/structure/AIcore/deactivated/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/aicard/C = src
						var/mob/living/silicon/ai/A = locate() in C//I love locate(). Best proc ever.
						if(A)//If AI exists on the card. Else nothing since both are empty.
							A.control_disabled = 0
							A.loc = T.loc//To replace the terminal.
							C.icon_state = "aicard"
							C.name = "inteliCard"
							C.overlays.Cut()
							A.cancel_camera()
							to_chat(A, "You have been uploaded to a stationary terminal. Remote device connection restored.")
							to_chat(U, "<span class='boldnotice'>Transfer successful: [A.name] ([rand(1000,9999)].exe) installed and executed succesfully. Local copy has been removed.</span>")
							qdel(T)
			if("AIFIXER")//AI Fixer terminal.
				var/obj/machinery/computer/aifixer/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/aicard/C = src
						if(!T.contents.len)
							if (!C.contents.len)
								to_chat(U, "No AI to copy over!")
							else for(var/mob/living/silicon/ai/A in C)
								C.icon_state = "aicard"
								C.name = "inteliCard"
								C.overlays.Cut()
								A.loc = T
								T.occupant = A
								A.control_disabled = 1
								if (A.stat == 2)
									T.overlays += image('icons/obj/machines/computer.dmi', "ai-fixer-404")
								else
									T.overlays += image('icons/obj/machines/computer.dmi', "ai-fixer-full")
								T.overlays -= image('icons/obj/machines/computer.dmi', "ai-fixer-empty")
								A.cancel_camera()
								to_chat(A, "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here.")
								to_chat(U, "<span class='boldnotice'>Transfer successful: [A.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.</span>")
						else
							if(!C.contents.len && T.occupant && !T.active)
								C.name = "inteliCard - [T.occupant.name]"
								T.overlays += image('icons/obj/machines/computer.dmi', "ai-fixer-empty")
								if (T.occupant.stat == 2)
									C.icon_state = "aicard-404"
									T.overlays -= image('icons/obj/machines/computer.dmi', "ai-fixer-404")
								else
									C.icon_state = "aicard-full"
									T.overlays -= image('icons/obj/machines/computer.dmi', "ai-fixer-full")
								to_chat(T.occupant, "You have been downloaded to a mobile storage device. Still no remote access.")
								to_chat(U, "<span class='boldnotice'>Transfer successful: [T.occupant.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory.</span>")
								T.occupant.loc = C
								T.occupant.cancel_camera()
								T.occupant = null
							else if (C.contents.len)
								to_chat(U, "<span class='danger'>ERROR: Artificial intelligence detected on terminal.</span>")
							else if (T.active)
								to_chat(U, "<span class='danger'>ERROR: Reconstruction in progress.</span>")
							else if (!T.occupant)
								to_chat(U, "<span class='danger'>ERROR: Unable to locate artificial intelligence.</span>")
	else
		to_chat(U, "<span class='danger'>ERROR: AI flush is in progress, cannot execute transfer protocol.</span>")
	return
