/obj/item/device/aicard
	name = "inteliCard"
	icon = 'icons/obj/items/pda.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	w_class = 2.0
	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	var/flush = null
	origin_tech = "programming=4;materials=4"


	attack(mob/living/silicon/ai/M as mob, mob/user as mob)
		if(!isAI(M))//If target is not an AI.
			return ..()

		log_combat(user, M, "carded", src)
		msg_admin_attack("[ADMIN_TPMONTY(usr)] used the [src.name] to card [ADMIN_TPMONTY(M)].")

		transfer_ai("AICORE", "AICARD", M, user)
		return

	attack(mob/living/silicon/decoy/M as mob, mob/user as mob)
		if (!istype (M, /mob/living/silicon/decoy))
			return ..()
		else
			M.death()
			to_chat(user, "<b>ERROR ERROR ERROR</b>")

	attack_self(mob/user)
		if (!in_range(src, user))
			return
		user.set_interaction(src)
		var/dat = "<TT><B>Intelicard</B><BR>"
		var/laws
		for(var/mob/living/silicon/ai/A in src)
			dat += "Stored AI: [A.name]<br>System integrity: [(A.health+100)/2]%<br>"

			for (var/law in A.laws.ion)
				if(law)
					laws += "[ionnum()]: [law]<BR>"

			if (A.laws.zeroth)
				laws += "0: [A.laws.zeroth]<BR>"

			var/number = 1
			for (var/index = 1, index <= A.laws.inherent.len, index++)
				var/law = A.laws.inherent[index]
				if (length(law) > 0)
					laws += "[number]: [law]<BR>"
					number++

			for (var/index = 1, index <= A.laws.supplied.len, index++)
				var/law = A.laws.supplied[index]
				if (length(law) > 0)
					laws += "[number]: [law]<BR>"
					number++

			dat += "Laws:<br>[laws]<br>"

			if (A.stat == 2)
				dat += "<b>AI nonfunctional</b>"
			else
				if (!src.flush)
					dat += {"<A href='byond://?src=\ref[src];choice=Wipe'>Wipe AI</A>"}
				else
					dat += "<b>Wipe in progress</b>"
				dat += "<br>"
				dat += {"<a href='byond://?src=\ref[src];choice=Wireless'>[A.control_disabled ? "Enable" : "Disable"] Wireless Activity</a>"}
				dat += "<br>"
				dat += "Subspace Transceiver is: [A.aiRadio.disabledAi ? "Disabled" : "Enabled"]"
				dat += "<br>"
				dat += {"<a href='byond://?src=\ref[src];choice=Radio'>[A.aiRadio.disabledAi ? "Enable" : "Disable"] Subspace Transceiver</a>"}
				dat += "<br>"
				dat += {"<a href='byond://?src=\ref[src];choice=Close'> Close</a>"}
		user << browse(dat, "window=aicard")
		onclose(user, "aicard")
		return

	Topic(href, href_list)
		var/mob/U = usr
		if (!in_range(src, U)||U.interactee!=src)//If they are not in range of 1 or less or their machine is not the card (ie, clicked on something else).
			U << browse(null, "window=aicard")
			U.unset_interaction()
			return

		add_fingerprint(U)
		U.set_interaction(src)

		switch(href_list["choice"])//Now we switch based on choice.
			if ("Close")
				U << browse(null, "window=aicard")
				U.unset_interaction()
				return

			if ("Radio")
				for(var/mob/living/silicon/ai/A in src)
					A.aiRadio.disabledAi = !A.aiRadio.disabledAi
					to_chat(A, "Your Subspace Transceiver has been: [A.aiRadio.disabledAi ? "disabled" : "enabled"]")
					to_chat(U, "You [A.aiRadio.disabledAi ? "Disable" : "Enable"] the AI's Subspace Transceiver")

			if ("Wipe")
				var/confirm = alert("Are you sure you want to wipe this card's memory? This cannot be undone once started.", "Confirm Wipe", "Yes", "No")
				if(confirm == "Yes")
					if(isnull(src)||!in_range(src, U)||U.interactee!=src)
						U << browse(null, "window=aicard")
						U.unset_interaction()
						return
					else
						flush = 1
						for(var/mob/living/silicon/ai/A in src)
							A.suiciding = 1
							to_chat(A, "Your core files are being wiped!")
							while (A.stat != 2)
								A.adjustOxyLoss(2)
								A.updatehealth()
								sleep(10)
							flush = 0

			if ("Wireless")
				for(var/mob/living/silicon/ai/A in src)
					A.control_disabled = !A.control_disabled
					to_chat(A, "The intelicard's wireless port has been [A.control_disabled ? "disabled" : "enabled"]!")
					if (A.control_disabled)
						overlays -= image('icons/obj/items/pda.dmi', "aicard-on")
					else
						overlays += image('icons/obj/items/pda.dmi', "aicard-on")
		attack_self(U)
