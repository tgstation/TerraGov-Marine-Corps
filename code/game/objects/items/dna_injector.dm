/obj/item/dnainjector
	name = "DNA-Injector"
	desc = "This injects the person with DNA."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "dnainjector"
	var/block=0
	var/datum/dna2/record/buf=null
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/uses = 1
	var/nofail
	var/is_bullet = 0

	// USE ONLY IN PREMADE SYRINGES.  WILL NOT WORK OTHERWISE.
	var/datatype=0
	var/value=0

/obj/item/dnainjector/New()
	if(datatype && block)
		buf=new
		buf.dna=new
		buf.types = datatype
		buf.dna.ResetSE()
		//testing("[name]: DNA2 SE blocks prior to SetValue: [english_list(buf.dna.SE)]")
		SetValue(src.value)
		//testing("[name]: DNA2 SE blocks after SetValue: [english_list(buf.dna.SE)]")

/obj/item/dnainjector/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/item/dnainjector/proc/GetRealBlock(var/selblock)
	if(selblock==0)
		return block
	else
		return selblock

/obj/item/dnainjector/proc/GetState(var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEState(real_block)
	else
		return buf.dna.GetUIState(real_block)

/obj/item/dnainjector/proc/SetState(var/on, var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEState(real_block,on)
	else
		return buf.dna.SetUIState(real_block,on)

/obj/item/dnainjector/proc/GetValue(var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.GetSEValue(real_block)
	else
		return buf.dna.GetUIValue(real_block)

/obj/item/dnainjector/proc/SetValue(var/val,var/selblock=0)
	var/real_block=GetRealBlock(selblock)
	if(buf.types&DNA2_BUF_SE)
		return buf.dna.SetSEValue(real_block,val)
	else
		return buf.dna.SetUIValue(real_block,val)

/obj/item/dnainjector/proc/inject(mob/M as mob, mob/user as mob)
	if(istype(M,/mob/living))
		M.radiation += rand(5,20)

	if (!(NOCLONE in M.mutations)) // prevents drained people from having their DNA changed
		if (buf.types & DNA2_BUF_UI)
			if (!block) //isolated block?
				M.UpdateAppearance(buf.dna.UI.Copy())
				if (buf.types & DNA2_BUF_UE) //unique enzymes? yes
					M.real_name = buf.dna.real_name
					M.name = buf.dna.real_name
				uses--
			else
				M.dna.SetUIValue(block,src.GetValue())
				M.UpdateAppearance()
				uses--
		if (buf.types & DNA2_BUF_SE)
			if (!block) //isolated block?
				M.dna.SE = buf.dna.SE.Copy()
				M.dna.UpdateSE()
			else
				M.dna.SetSEValue(block,src.GetValue())
			domutcheck(M, null, block!=null)
			uses--
			if(prob(5))
				trigger_side_effect(M)

	spawn(0)//this prevents the collapse of space-time continuum
		if (user)
			user.temp_drop_inv_item(src)
		cdel(src)
	return uses

/obj/item/dnainjector/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob))
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return

	M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [name] by [user.name] ([user.ckey])</font>")
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [name] to inject [M.name] ([M.ckey])</font>")
	log_attack("[user.name] ([user.ckey]) used the [name] to inject [M.name] ([M.ckey])")

	if (user)
		if (ishuman(M))
			if(!user.action_busy)
				if (buf && buf.types & DNA2_BUF_SE)
					if(block)// Isolated injector
						testing("Isolated block [block] injector with contents: [GetValue()]")
						if (GetState() && block == MONKEYBLOCK && istype(M, /mob/living/carbon/human)  )
							message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] \red(MONKEY)")
							log_attack("[key_name(user)] injected [key_name(M)] with the Isolated [name] (MONKEY)")
							log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] \red(MONKEY)")
						else
							log_attack("[key_name(user)] injected [key_name(M)] with the Isolated [name]")
					else
						testing("DNA injector with contents: [english_list(buf.dna.SE)]")
						if (GetState(MONKEYBLOCK) && istype(M, /mob/living/carbon/human) )
							message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] \red(MONKEY)")
							log_attack("[key_name(user)] injected [key_name(M)] with the [name] (MONKEY)")
							log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] \red(MONKEY)")
						else
	//						message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
							log_attack("[key_name(user)] injected [key_name(M)] with the [name]")
				else
	//				message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
					log_attack("[key_name(user)] injected [key_name(M)] with the [name]")


				user.visible_message("\red <B>[user] is trying to inject [M] with [src]!</B>")
				if(do_mob(user, M, HUMAN_STRIP_DELAY, BUSY_ICON_GENERIC, BUSY_ICON_GENERIC))
					if(src == user.get_active_hand())
						add_fingerprint(user)
						inject(M, user)
						user.visible_message("\red [user] injects [M] with the DNA Injector!")


		else

			for(var/mob/O in viewers(M, null))
				O.show_message(text("\red [] has been injected with [] by [].", M, src, user), 1)
				//Foreach goto(192)
			if (!(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey)))
				user << "\red Apparently it didn't work."
				return

			if (buf && buf.types & DNA2_BUF_SE)
				if(block)// Isolated injector
					testing("Isolated block [block] injector with contents: [GetValue()]")
					if (GetState() && block == MONKEYBLOCK && istype(M, /mob/living/carbon/human)  )
						message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] \red(MONKEY)")
						log_attack("[key_name(user)] injected [key_name(M)] with the Isolated [name] (MONKEY)")
						log_game("[key_name_admin(user)] injected [key_name_admin(M)] with the Isolated [name] \red(MONKEY)")
					else
						log_attack("[key_name(user)] injected [key_name(M)] with the Isolated [name]")
				else
					testing("DNA injector with contents: [english_list(buf.dna.SE)]")
					if (GetState(MONKEYBLOCK) && istype(M, /mob/living/carbon/human))
						message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name] \red(MONKEY)")
						log_game("[key_name(user)] injected [key_name(M)] with the [name] (MONKEY)")
					else
//						message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
						log_game("[key_name(user)] injected [key_name(M)] with the [name]")
			else
//					message_admins("[key_name_admin(user)] injected [key_name_admin(M)] with the [name]")
				log_game("[key_name(user)] injected [key_name(M)] with the [name]")

			inject(M, user)//Now we actually do the heavy lifting.

			/*
			A user injecting themselves could mean their own transformation and deletion of mob.
			I don't have the time to figure out how this code works so this will do for now.
			I did rearrange things a bit.
			*/
			if(user)//If the user still exists. Their mob may not.
				if(M)//Runtime fix: If the mob doesn't exist, mob.name doesnt work. - Nodrak
					user.show_message(text("\red You inject [M.name]"))
				else
					user.show_message(text("\red You finish the injection."))




/obj/item/dnainjector/hulkmut
	name = "DNA-Injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = HULKBLOCK
		..()

/obj/item/dnainjector/antihulk
	name = "DNA-Injector (Anti-Hulk)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = HULKBLOCK
		..()

/obj/item/dnainjector/xraymut
	name = "DNA-Injector (Xray)"
	desc = "Finally you can see what the Captain does."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 8
	New()
		block = XRAYBLOCK
		..()

/obj/item/dnainjector/antixray
	name = "DNA-Injector (Anti-Xray)"
	desc = "It will make you see harder."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 8
	New()
		block = XRAYBLOCK
		..()

/obj/item/dnainjector/firemut
	name = "DNA-Injector (Fire)"
	desc = "Gives you fire."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 10
	New()
		block = FIREBLOCK
		..()

/obj/item/dnainjector/antifire
	name = "DNA-Injector (Anti-Fire)"
	desc = "Cures fire."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 10
	New()
		block = FIREBLOCK
		..()

/obj/item/dnainjector/telemut
	name = "DNA-Injector (Tele.)"
	desc = "Super brain man!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 12
	New()
		block = TELEBLOCK
		..()

/obj/item/dnainjector/antitele
	name = "DNA-Injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 12
	New()
		block = TELEBLOCK
		..()

/obj/item/dnainjector/nobreath
	name = "DNA-Injector (No Breath)"
	desc = "Hold your breath and count to infinity."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = NOBREATHBLOCK
		..()

/obj/item/dnainjector/antinobreath
	name = "DNA-Injector (Anti-No Breath)"
	desc = "Hold your breath and count to 100."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = NOBREATHBLOCK
		..()

/obj/item/dnainjector/remoteview
	name = "DNA-Injector (Remote View)"
	desc = "Stare into the distance for a reason."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = REMOTEVIEWBLOCK
		..()

/obj/item/dnainjector/antiremoteview
	name = "DNA-Injector (Anti-Remote View)"
	desc = "Cures green skin."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = REMOTEVIEWBLOCK
		..()

/obj/item/dnainjector/regenerate
	name = "DNA-Injector (Regeneration)"
	desc = "Healthy but hungry."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = REGENERATEBLOCK
		..()

/obj/item/dnainjector/antiregenerate
	name = "DNA-Injector (Anti-Regeneration)"
	desc = "Sickly but sated."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = REGENERATEBLOCK
		..()

/obj/item/dnainjector/runfast
	name = "DNA-Injector (Increase Run)"
	desc = "Running Man."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = INCREASERUNBLOCK
		..()

/obj/item/dnainjector/antirunfast
	name = "DNA-Injector (Anti-Increase Run)"
	desc = "Walking Man."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = INCREASERUNBLOCK
		..()

/obj/item/dnainjector/morph
	name = "DNA-Injector (Morph)"
	desc = "A total makeover."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = MORPHBLOCK
		..()

/obj/item/dnainjector/antimorph
	name = "DNA-Injector (Anti-Morph)"
	desc = "Cures identity crisis."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = MORPHBLOCK
		..()

/* No COLDBLOCK on bay
/obj/item/dnainjector/cold
	name = "DNA-Injector (Cold)"
	desc = "Feels a bit chilly."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = COLDBLOCK
		..()

/obj/item/dnainjector/anticold
	name = "DNA-Injector (Anti-Cold)"
	desc = "Feels room-temperature."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = COLDBLOCK
		..()
*/

/obj/item/dnainjector/noprints
	name = "DNA-Injector (No Prints)"
	desc = "Better than a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = NOPRINTSBLOCK
		..()

/obj/item/dnainjector/antinoprints
	name = "DNA-Injector (Anti-No Prints)"
	desc = "Not quite as good as a pair of budget insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = NOPRINTSBLOCK
		..()

/obj/item/dnainjector/insulation
	name = "DNA-Injector (Shock Immunity)"
	desc = "Better than a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = SHOCKIMMUNITYBLOCK
		..()

/obj/item/dnainjector/antiinsulation
	name = "DNA-Injector (Anti-Shock Immunity)"
	desc = "Not quite as good as a pair of real insulated gloves."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = SHOCKIMMUNITYBLOCK
		..()

/obj/item/dnainjector/midgit
	name = "DNA-Injector (Small Size)"
	desc = "Makes you shrink."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = SMALLSIZEBLOCK
		..()

/obj/item/dnainjector/antimidgit
	name = "DNA-Injector (Anti-Small Size)"
	desc = "Makes you grow. But not too much."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = SMALLSIZEBLOCK
		..()

/////////////////////////////////////
/obj/item/dnainjector/antiglasses
	name = "DNA-Injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 1
	New()
		block = GLASSESBLOCK
		..()

/obj/item/dnainjector/glassesmut
	name = "DNA-Injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 1
	New()
		block = GLASSESBLOCK
		..()

/obj/item/dnainjector/epimut
	name = "DNA-Injector (Epi.)"
	desc = "Shake shake shake the room!"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 3
	New()
		block = HEADACHEBLOCK
		..()

/obj/item/dnainjector/antiepi
	name = "DNA-Injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 3
	New()
		block = HEADACHEBLOCK
		..()

/obj/item/dnainjector/anticough
	name = "DNA-Injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 5
	New()
		block = COUGHBLOCK
		..()

/obj/item/dnainjector/coughmut
	name = "DNA-Injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 5
	New()
		block = COUGHBLOCK
		..()

/obj/item/dnainjector/clumsymut
	name = "DNA-Injector (Clumsy)"
	desc = "Makes clumsy minions."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 6
	New()
		block = CLUMSYBLOCK
		..()

/obj/item/dnainjector/anticlumsy
	name = "DNA-Injector (Anti-Clumy)"
	desc = "Cleans up confusion."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 6
	New()
		block = CLUMSYBLOCK
		..()

/obj/item/dnainjector/antitour
	name = "DNA-Injector (Anti-Tour.)"
	desc = "Will cure tourrets."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 7
	New()
		block = TWITCHBLOCK
		..()

/obj/item/dnainjector/tourmut
	name = "DNA-Injector (Tour.)"
	desc = "Gives you a nasty case off tourrets."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 7
	New()
		block = TWITCHBLOCK
		..()

/obj/item/dnainjector/stuttmut
	name = "DNA-Injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 9
	New()
		block = NERVOUSBLOCK
		..()

/obj/item/dnainjector/antistutt
	name = "DNA-Injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 9
	New()
		block = NERVOUSBLOCK
		..()

/obj/item/dnainjector/blindmut
	name = "DNA-Injector (Blind)"
	desc = "Makes you not see anything."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 11
	New()
		block = BLINDBLOCK
		..()

/obj/item/dnainjector/antiblind
	name = "DNA-Injector (Anti-Blind)"
	desc = "ITS A MIRACLE!!!"
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 11
	New()
		block = BLINDBLOCK
		..()

/obj/item/dnainjector/deafmut
	name = "DNA-Injector (Deaf)"
	desc = "Sorry, what did you say?"
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 13
	New()
		block = DEAFBLOCK
		..()

/obj/item/dnainjector/antideaf
	name = "DNA-Injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 13
	New()
		block = DEAFBLOCK
		..()

/obj/item/dnainjector/hallucination
	name = "DNA-Injector (Halluctination)"
	desc = "What you see isn't always what you get."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 2
	New()
		block = HALLUCINATIONBLOCK
		..()

/obj/item/dnainjector/antihallucination
	name = "DNA-Injector (Anti-Hallucination)"
	desc = "What you see is what you get."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 2
	New()
		block = HALLUCINATIONBLOCK
		..()

/obj/item/dnainjector/h2m
	name = "DNA-Injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	datatype = DNA2_BUF_SE
	value = 0xFFF
	//block = 14
	New()
		block = MONKEYBLOCK
		..()

/obj/item/dnainjector/m2h
	name = "DNA-Injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	datatype = DNA2_BUF_SE
	value = 0x001
	//block = 14
	New()
		block = MONKEYBLOCK
		..()