/obj/item/organ
	name = "organ"
	desc = "It looks like it probably just plopped out."
	icon = 'icons/obj/items/organs.dmi'
	icon_state = "appendix"

	health = 100                              // Process() ticks before death.

	var/fresh = 3                             // Squirts of blood left in it.
	var/dead_icon                             // Icon used when the organ dies.
	var/robotic                               // Is the limb prosthetic?
	var/organ_tag                             // What slot does it go in?
	var/organ_type = /datum/internal_organ    // Used to spawn the relevant organ data when produced via a machine or spawn().
	var/datum/internal_organ/organ_data       // Stores info when removed.

/obj/item/organ/attack_self(mob/user as mob)

	// Convert it to an edible form, yum yum.
	if(!robotic && user.a_intent == "help" && user.zone_selected == "mouth")
		bitten(user)
		return

/obj/item/organ/New(loc, organ_datum)
	..()
	create_reagents(5)
	if(organ_datum)
		organ_data = organ_datum
	else
		organ_data = new organ_type()
	if(!robotic)
		processing_objects += src


/obj/item/organ/Dispose()
	if(!robotic) processing_objects -= src
	. = ..()

/obj/item/organ/process()

	if(robotic)
		processing_objects -= src
		return

	// Don't process if we're in a freezer, an MMI or a stasis bag. //TODO: ambient temperature?
	if(istype(loc,/obj/item/device/mmi) || istype(loc,/obj/item/bodybag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer))
		return

	if(fresh && prob(40))
		fresh--
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
		if(B)
			var/turf/TU = get_turf(src)
			var/list/L = list()
			if(B.data["blood_DNA"])
				L = list(B.data["blood_DNA"] = B.data["blood_type"])
			TU.add_blood(L, B.color)
		//blood_splatter(src,B,1)

	health -= rand(0,1)
	if(health <= 0)
		die()

/obj/item/organ/proc/die()
	name = "dead [initial(name)]"
	if(dead_icon) icon_state = dead_icon
	health = 0
	processing_objects -= src
	//TODO: Grey out the icon state.
	//TODO: Inject an organ with peridaxon to make it alive again.


// Brain is defined in brain_item.dm.
/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "heart"
	fresh = 6 // Juicy.
	dead_icon = "heart-off"
	organ_type = /datum/internal_organ/heart

/obj/item/organ/lungs
	name = "lungs"
	icon_state = "lungs"
	gender = PLURAL
	organ_tag = "lungs"
	organ_type = /datum/internal_organ/lungs

/obj/item/organ/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	gender = PLURAL
	organ_tag = "kidneys"
	organ_type = /datum/internal_organ/kidneys

/obj/item/organ/eyes
	name = "eyeballs"
	icon_state = "eyes"
	gender = PLURAL
	organ_tag = "eyes"
	organ_type = /datum/internal_organ/eyes
	var/eye_colour

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	organ_tag = "liver"
	organ_type = /datum/internal_organ/liver

/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	organ_type = /datum/internal_organ/appendix
	organ_tag = "appendix"

//These are here so they can be printed out via the fabricator.
/obj/item/organ/heart/prosthetic
	name = "circulatory pump"
	icon_state = "heart-prosthetic"
	robotic = ORGAN_ROBOT
	organ_type = /datum/internal_organ/heart/prosthetic

/obj/item/organ/lungs/prosthetic
	robotic = ORGAN_ROBOT
	name = "gas exchange system"
	icon_state = "lungs-prosthetic"
	organ_type = /datum/internal_organ/lungs/prosthetic

/obj/item/organ/kidneys/prosthetic
	robotic = ORGAN_ROBOT
	name = "prosthetic kidneys"
	icon_state = "kidneys-prosthetic"
	organ_type = /datum/internal_organ/kidneys/prosthetic


/obj/item/organ/eyes/prosthetic
	robotic = ORGAN_ROBOT
	name = "visual prosthesis"
	icon_state = "eyes-prosthetic"
	organ_type = /datum/internal_organ/eyes/prosthetic

/obj/item/organ/liver/prosthetic
	robotic = ORGAN_ROBOT
	name = "toxin filter"
	icon_state = "liver-prosthetic"
	organ_type = /datum/internal_organ/liver/prosthetic

/obj/item/organ/brain/prosthetic
	robotic = ORGAN_ROBOT
	name = "cyberbrain"
	icon_state = "brain-prosthetic"
	organ_type = /datum/internal_organ/brain/prosthetic


/obj/item/organ/proc/removed(var/mob/living/target,var/mob/living/user)

	if(!target || !user)
		return

	if(organ_data.vital)
		user.attack_log += "\[[time_stamp()]\]<font color='red'> removed a vital organ ([src]) from [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		target.attack_log += "\[[time_stamp()]\]<font color='orange'> had a vital organ ([src]) removed by [user.name] ([user.ckey]) (INTENT: [uppertext(user.a_intent)])</font>"
		msg_admin_attack("[user.name] ([user.ckey]) removed a vital organ ([src]) from [target.name] ([target.ckey]) (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		target.death()

/obj/item/organ/appendix/removed(var/mob/living/target,var/mob/living/user)

	..()

	var/inflamed = 0
	for(var/datum/disease/appendicitis/appendicitis in target.viruses)
		inflamed = 1
		appendicitis.cure()
		target.resistances += appendicitis

	if(inflamed)
		icon_state = "appendixinflamed"
		name = "inflamed appendix"

/obj/item/organ/eyes/removed(var/mob/living/target,var/mob/living/user)

	if(!eye_colour)
		eye_colour = list(0,0,0)

	..() //Make sure target is set so we can steal their eye colour for later.
	var/mob/living/carbon/human/H = target
	if(istype(H))
		eye_colour = list(
			H.r_eyes ? H.r_eyes : 0,
			H.g_eyes ? H.g_eyes : 0,
			H.b_eyes ? H.b_eyes : 0
			)

		// Leave bloody red pits behind!
		H.r_eyes = 128
		H.g_eyes = 0
		H.b_eyes = 0
		H.update_body()

/obj/item/organ/proc/replaced(var/mob/living/target)
	return

/obj/item/organ/eyes/replaced(var/mob/living/target)

	// Apply our eye colour to the target.
	var/mob/living/carbon/human/H = target
	if(istype(H) && eye_colour)
		H.r_eyes = eye_colour[1]
		H.g_eyes = eye_colour[2]
		H.b_eyes = eye_colour[3]
		H.update_body()

/obj/item/organ/proc/bitten(mob/user)

	if(robotic)
		return

	user << "\blue You take an experimental bite out of \the [src]."
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
	if(B)
		var/turf/TU = get_turf(src)
		var/list/L = list()
		if(B.data["blood_DNA"])
			L = list(B.data["blood_DNA"] = B.data["blood_type"])
		TU.add_blood(L, B.color)


	user.temp_drop_inv_item(src)
	var/obj/item/reagent_container/food/snacks/organ/O = new(get_turf(src))
	O.name = name
	O.icon_state = dead_icon ? dead_icon : icon_state

	// Pass over the blood.
	reagents.trans_to(O, reagents.total_volume)

	if(fingerprints) O.fingerprints = fingerprints.Copy()
	if(fingerprintshidden) O.fingerprintshidden = fingerprintshidden.Copy()
	if(fingerprintslast) O.fingerprintslast = fingerprintslast

	user.put_in_active_hand(O)
	cdel(src)