/obj/item/device/defibrillator
	name = "emergency defibrillator"
	desc = "A handheld emergency defibrillator, used to restore fibrillating patients. Can optionally bring people back from the dead."
	icon_state = "defib_full"
	item_state = "defib"
	flags_atom = FPRINT|CONDUCT
	flags_item = NOBLUDGEON
	flags_equip_slot = SLOT_WAIST
	force = 5
	throwforce = 5
	w_class = 3

	var/ready = 0
	var/damage_threshold = 8 //This is the maximum non-oxy damage the defibrillator will heal to get a patient above -100, in all categories
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
	var/charge_cost = 66 //How much energy is used.
	var/obj/item/cell/dcell = null
	var/datum/effect_system/spark_spread/sparks = new
	var/defib_cooldown = 0 //Cooldown for toggling the defib
	origin_tech = "biotech=3"

	suicide_act(mob/user)
		viewers(user) << "<span class='danger'>[user] is putting the live paddles on \his chest! It looks like \he's trying to commit suicide.</span>"
		return (FIRELOSS)

/mob/living/carbon/human/proc/check_tod()
	if(!undefibbable && world.time <= timeofdeath + revive_grace_period)
		return 1
	return 0

/obj/item/device/defibrillator/New()
	sparks.set_up(5, 0, src)
	sparks.attach(src)
	dcell = new/obj/item/cell(src)
	update_icon()

/obj/item/device/defibrillator/update_icon()
	icon_state = "defib"
	if(ready)
		icon_state += "_out"
	if(dcell && dcell.charge)
		switch(round(dcell.charge * 100 / dcell.maxcharge))
			if(67 to INFINITY)
				icon_state += "_full"
			if(34 to 66)
				icon_state += "_half"
			if(1 to 33)
				icon_state += "_low"
	else
		icon_state += "_empty"

/obj/item/device/defibrillator/attack_self(mob/living/carbon/human/user)

	if(defib_cooldown > world.time)
		return

	//Job knowledge requirement
	if (istype(user))
		if(user.mind && user.mind.cm_skills && user.mind.cm_skills.medical < SKILL_MEDICAL_MEDIC)
			user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
			return

	defib_cooldown = world.time + 20 //2 seconds cooldown every time the defib is toggled
	ready = !ready
	user.visible_message("<span class='notice'>[user] turns [src] [ready? "on and takes the paddles out" : "off and puts the paddles back in"].</span>",
	"<span class='notice'>You turn [src] [ready? "on and take the paddles out" : "off and put the paddles back in"].</span>")
	playsound(get_turf(src), "sparks", 25, 1, 4)
	update_icon()
	add_fingerprint(user)

/mob/living/carbon/human/proc/get_ghost()
	if(mind && !client) //Let's call up the correct ghost! Also, bodies with clients only, thank you.
		for(var/mob/dead/observer/G in player_list)
			if(G.mind == mind)
				var/mob/dead/observer/ghost = G
				if(ghost && ghost.client && ghost.can_reenter_corpse)
					return ghost
	return 0

/mob/living/carbon/human/proc/is_revivable()
	var/datum/internal_organ/heart/heart = internal_organs_by_name["heart"]

	if(!get_limb("head") || !heart || heart.is_broken() || !has_brain() || chestburst || (HUSK in mutations))
		return 0
	return 1

/obj/item/device/defibrillator/attack(mob/living/carbon/human/H, mob/living/carbon/human/user)

	if(defib_cooldown > world.time) //Both for pulling the paddles out (2 seconds) and shocking (1 second)
		return
	defib_cooldown = world.time + 20 //2 second cooldown before you can try shocking again

	if(user.action_busy) //Currently deffibing
		return

	var/defib_heal_amt = damage_threshold

	//job knowledge requirement
	if(user.mind && user.mind.cm_skills)
		if(user.mind.cm_skills.medical < SKILL_MEDICAL_MEDIC)
			user << "<span class='warning'>You don't seem to know how to use [src]...</span>"
			return
		else
			defib_heal_amt *= user.mind.cm_skills.medical*0.5 //more healing power when used by a doctor

	if(!ishuman(H) || isYautja(H))
		user << "<span class='warning'>You can't defibrilate [H]. You don't even know where to put the paddles!</span>"
		return
	if(!ready)
		user << "<span class='warning'>Take [src]'s paddles out first.</span>"
		return
	if(dcell.charge <= charge_cost)
		user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Internal battery depleted. Cannot analyze nor administer shock.</span>")
		return
	if(H.stat != DEAD)
		user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Vital signs detected. Aborting.</span>")
		return

	if(!H.is_revivable())
		user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Patient's general condition does not allow reviving.</span>")
		return

	if(H.wear_suit && (istype(H.wear_suit, /obj/item/clothing/suit/armor) || istype(H.wear_suit, /obj/item/clothing/suit/storage/marine)) && prob(95))
		user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Paddles registering >100,000 ohms, Possible cause: Suit or Armor interferring.</span>")
		return

	if((!H.check_tod() && !isSynth(H)) || H.suiciding) //synthetic species have no expiration date
		user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Patient is braindead.</span>")
		return

	var/mob/dead/observer/G = H.get_ghost()
	if(istype(G))
		G << 'sound/effects/adminhelp_new.ogg'
		G << "<span class='interface'><font size=3><span class='bold'>Someone is trying to revive your body. Return to it if you want to be resurrected!</span> \
		(Verbs -> Ghost -> Re-enter corpse, or <a href='?src=\ref[G];reentercorpse=1'>click here!</a>)</font></span>"
	else if(!H.client)
		//We couldn't find a suitable ghost, this means the person is not returning
		user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Patient has a DNR.</span>")
		return

	user.visible_message("<span class='notice'>[user] starts setting up the paddles on [H]'s chest</span>", \
	"<span class='notice'>You start setting up the paddles on [H]'s chest</span>")
	playsound(get_turf(src),'sound/items/defib_charge.ogg', 25, 0) //Do NOT vary this tune, it needs to be precisely 7 seconds

	if(do_mob(user, H, 70, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))

		//Do this now, order doesn't matter
		sparks.start()
		dcell.use(charge_cost)
		update_icon()
		playsound(get_turf(src), 'sound/items/defib_release.ogg', 25, 1)
		user.visible_message("<span class='notice'>[user] shocks [H] with the paddles.</span>",
		"<span class='notice'>You shock [H] with the paddles.</span>")
		H.visible_message("<span class='danger'>[H]'s body convulses a bit.</span>")
		defib_cooldown = world.time + 10 //1 second cooldown before you can shock again

		if(H.wear_suit && (istype(H.wear_suit, /obj/item/clothing/suit/armor) || istype(H.wear_suit, /obj/item/clothing/suit/storage/marine)) && prob(95))
			user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Defibrillation failed: Paddles registering >100,000 ohms, Possible cause: Suit or Armor interferring.</span>")
			return

		var/datum/internal_organ/heart/heart = H.internal_organs_by_name["heart"]
		if(heart && prob(25))
			heart.damage += 5 //Allow the defibrilator to possibly worsen heart damage. Still rare enough to just be the "clone damage" of the defib

		if(!H.is_revivable())
			user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Defibrillation failed. Patient's general condition does not allow reviving.</span>")
			return

		if((!H.check_tod() && !isSynth(H)) || H.suiciding) //synthetic species have no expiration date
			user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Patient's brain has decayed too much.</span>")
			return

		if(!H.client) //Freak case, no client at all. This is a braindead mob (like a colonist)
			user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: No soul detected, Attempting to revive...</span>")

		if(H.mind && !H.client) //Let's call up the correct ghost! Also, bodies with clients only, thank you.
			G = H.get_ghost()
			if(istype(G))
				user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Defibrillation failed. Patient's soul has almost departed, please try again.</span>")
				return
			//We couldn't find a suitable ghost, this means the person is not returning
			user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Patient has a DNR.</span>")
			return


		if(!H.client) //Freak case, no client at all. This is a braindead mob (like a colonist)
			user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Defibrillation failed. No soul detected.</span>")
			return

		//At this point, the defibrillator is ready to work
		H.adjustBruteLoss(-defib_heal_amt)
		H.adjustFireLoss(-defib_heal_amt)
		H.adjustToxLoss(-defib_heal_amt)
		H.adjustCloneLoss(-defib_heal_amt)
		H.adjustOxyLoss(-H.getOxyLoss())
		H.updatehealth() //Needed for the check to register properly
		if(H.health > config.health_threshold_dead)
			user.visible_message("<span class='notice'>\icon[src] \The [src] beeps: Defibrillation successful.</span>")
			living_mob_list.Add(H)
			dead_mob_list.Remove(H)
			H.timeofdeath = 0
			H.tod = null
			H.stat = UNCONSCIOUS
			H.emote("gasp")
			H.regenerate_icons()
			H.reload_fullscreens()
			H.update_canmove()
			H.flash_eyes()
			H.apply_effect(10, EYE_BLUR)
			H.apply_effect(10, PARALYZE)
			H.update_canmove()
			H.updatehealth() //One more time, so it doesn't show the target as dead on HUDs
			H << "<span class='notice'>You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane.</span>"
		else
			user.visible_message("<span class='warning'>\icon[src] \The [src] buzzes: Defibrillation failed. Vital signs are too weak, repair damage and try again.</span>") //Freak case
	else
		user.visible_message("<span class='warning'>[user] stops setting up the paddles on [H]'s chest</span>", \
		"<span class='warning'>You stop setting up the paddles on [H]'s chest</span>")
