
obj/item/limb
	icon = 'icons/mob/human_races/r_human.dmi'

obj/item/limb/New(loc, mob/living/carbon/human/H)
	..(loc)
	if(!istype(H))
		return
	if(H.dna)
		if(!blood_DNA)
			blood_DNA = list()
		blood_DNA[H.dna.unique_enzymes] = H.dna.b_type

	//Forming icon for the limb

	//Setting base icon for this mob's race
	var/icon/base
	if(H.species && H.species.icobase)
		base = icon(H.species.icobase)
	else
		base = icon('icons/mob/human_races/r_human.dmi')


	icon = base
	var/datum/ethnicity/E = ethnicities_list[H.ethnicity]
	var/datum/body_type/B = body_types_list[H.body_type]

	var/e_icon
	var/b_icon

	if (!E)
		e_icon = "western"
	else
		e_icon = E.icon_name

	if (!B)
		b_icon = "mesomorphic"
	else
		b_icon = B.icon_name

	icon_state = "[get_limb_icon_name(H.species, b_icon, H.gender, name, e_icon)]"
	dir = SOUTH
	transform = turn(transform, rand(70,130))



/obj/item/limb/l_arm
	name = "left arm"
	icon_state = "l_arm"
/obj/item/limb/l_foot
	name = "left foot"
	icon_state = "l_foot"
/obj/item/limb/l_hand
	name = "left hand"
	icon_state = "l_hand"
/obj/item/limb/l_leg
	name = "left leg"
	icon_state = "l_leg"
/obj/item/limb/r_arm
	name = "right arm"
	icon_state = "r_arm"
/obj/item/limb/r_foot
	name = "right foot"
	icon_state = "r_foot"
/obj/item/limb/r_hand
	name = "right hand"
	icon_state = "r_hand"
/obj/item/limb/r_leg
	name = "right leg"
	icon_state = "r_leg"

/obj/item/limb/head
	name = "head"
	icon_state = "head_m"
	unacidable = 1
	var/mob/living/brain/brainmob
	var/brain_op_stage = 0
	var/brain_item_type = /obj/item/organ/brain
	var/braindeath_on_decap = 1 //whether the brainmob dies when head is decapitated (used by synthetics)

/obj/item/limb/head/New(loc, mob/living/carbon/human/H)
	if(istype(H))
		src.icon_state = H.gender == MALE? "head_m" : "head_f"
	..()
	//Add (facial) hair.
	if(H.f_style)
		var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[H.f_style]
		if(facial_hair_style)
			var/icon/facial = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				facial.Blend(rgb(H.r_facial, H.g_facial, H.b_facial), ICON_ADD)

			overlays.Add(facial) // icon.Blend(facial, ICON_OVERLAY)

	if(H.h_style && !(H.head && (H.head.flags_inv_hide & HIDETOPHAIR)))
		var/datum/sprite_accessory/hair_style = hair_styles_list[H.h_style]
		if(hair_style)
			var/icon/hair = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				hair.Blend(rgb(H.r_hair, H.g_hair, H.b_hair), ICON_ADD)

			overlays.Add(hair) //icon.Blend(hair, ICON_OVERLAY)
	spawn(5)
	if(brainmob && brainmob.client)
		brainmob.client.screen.len = null //clear the hud

	//if(ishuman(H))
	//	if(H.gender == FEMALE)
	//		H.icon_state = "head_f"
	//	H.overlays += H.generate_head_icon()
	transfer_identity(H)

	name = "[H.real_name]'s head"

	H.regenerate_icons()

	if(braindeath_on_decap)
		brainmob.stat = DEAD
		brainmob.death()

/obj/item/limb/head/proc/transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->head
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob.container = src

/obj/item/limb/head/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/tool/surgery/scalpel))
		switch(brain_op_stage)
			if(0)
				user.visible_message("<span class='warning'>[brainmob] is beginning to have \his head cut open with [W] by [user].</span>", \
									"<span class='warning'>You cut [brainmob]'s head open with [W]!</span>")
				brainmob << "<span class='warning'>[user] begins to cut open your head with [W]!</span>"

				brain_op_stage = 1

			if(2)
				user.visible_message("<span class='warning'>[brainmob] is having \his connections to the brain delicately severed with [W] by [user].</span>", \
									"<span class='warning'>You cut [brainmob]'s head open with [W]!</span>")
				brainmob << "<span class='warning'>[user] begins to cut open your head with [W]!</span>"

				brain_op_stage = 3.0
			else
				..()
	else if(istype(W,/obj/item/tool/surgery/circular_saw))
		switch(brain_op_stage)
			if(1)
				user.visible_message("<span class='warning'>[brainmob] has \his head sawed open with [W] by [user].</span>", \
							"<span class='warning'>You saw [brainmob]'s head open with [W]!</span>")
				brainmob << "<span class='warning'>[user] saw open your head with [W]!</span>"
				brain_op_stage = 2
			if(3)
				user.visible_message("<span class='warning'>[brainmob] has \his spine's connection to the brain severed with [W] by [user].</span>", \
									"<span class='warning'>You sever [brainmob]'s brain's connection to the spine with [W]!</span>")
				brainmob << "<span class='warning'>[user] severs your brain's connection to the spine with [W]!</span>"

				user.attack_log += "\[[time_stamp()]\]<font color='red'> Debrained [brainmob.name] ([brainmob.ckey]) with [W.name] (INTENT: [uppertext(user.a_intent)])</font>"
				brainmob.attack_log += "\[[time_stamp()]\]<font color='orange'> Debrained by [user.name] ([user.ckey]) with [W.name] (INTENT: [uppertext(user.a_intent)])</font>"
				msg_admin_attack("[user] ([user.ckey]) debrained [brainmob] ([brainmob.ckey]) (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

				//TODO: ORGAN REMOVAL UPDATE.
				var/obj/item/organ/brain/B = new brain_item_type(loc)
				if(brainmob.stat != DEAD)
					brainmob.death() //brain mob doesn't survive outside a head
				B.transfer_identity(brainmob)

				brain_op_stage = 4.0
			else
				..()
	else
		..()


//synthetic head, allowing brain mob inside to talk
/obj/item/limb/head/synth
	name = "synthetic head"
	brain_item_type = /obj/item/organ/brain/prosthetic
	braindeath_on_decap = 0
