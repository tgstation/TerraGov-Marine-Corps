/*
* Paper
* also scraps of paper
*/

/obj/item/paper
	name = "paper"
	gender = PLURAL
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "paper"
	item_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	flags_equip_slot = ITEM_SLOT_HEAD
	flags_armor_protection = HEAD
	attack_verb = list("bapped")

	var/info		//What's actually written on the paper.
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamps		//The (text for the) stamps on the paper.
	var/fields		//Amount of user created fields
	var/list/stamped
	var/ico[0]      //Icons and
	var/offset_x[0] //offsets stored for later
	var/offset_y[0] //usage by the photocopier
	var/rigged = 0
	var/spam_flag = 0

	var/const/deffont = PAPER_DEFAULT_FONT
	var/const/signfont = PAPER_SIGN_FONT
	var/const/crayonfont = PAPER_CRAYON_FONT

//lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!

/obj/item/paper/Initialize()
	. = ..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)
	stamps = ""

	if(info != initial(info))
		info = html_encode(info)
		info = replacetext(info, "\n", "<BR>")
		info = parsepencode(info)

	update_icon()
	updateinfolinks()

/obj/item/paper/update_icon()
	if(icon_state == "paper_talisman")
		return
	if(info)
		icon_state = "paper_words"
		return
	icon_state = "paper"

/obj/item/paper/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user)) //You need to be next to the paper in order to read it.
		if(!(isobserver(user) || ishuman(user) || issilicon(user)))
			// Show scrambled paper if they aren't a ghost, human, or silicone.
			usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)][stamps]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
		else
			user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info][stamps]</BODY></HTML>", "window=[name]")
			onclose(user, "[name]")
	else
		. += span_notice("It is too far away to read.")


/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	var/n_name = stripped_input(usr, "What would you like to label the paper?", "Paper Labelling")
	if((loc == usr && usr.stat == 0))
		name = "[(n_name ? text("[n_name]") : "paper")]"



/obj/item/paper/attack_ai(mob/living/silicon/ai/user as mob)
	var/dist
	if(istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2)
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info][stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")
	else
		//Show scrambled paper
		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[stars(info)][stamps]</BODY></HTML>", "window=[name]")
		onclose(usr, "[name]")


/obj/item/paper/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(user.zone_selected == "eyes")
		user.visible_message(span_notice("You show the paper to [M]. "), \
			span_notice(" [user] holds up a paper and shows it to [M]. "))
		examine(M)

	else if(user.zone_selected == "mouth") // lipstick wiping
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, span_notice("You wipe off the lipstick with [src]."))
				H.lip_style = null
				H.update_body()
			else
				user.visible_message(span_warning("[user] begins to wipe [H]'s lipstick off with \the [src]."), \
									span_notice("You begin to wipe off [H]'s lipstick."))
				if(do_after(user, 10, TRUE, H, BUSY_ICON_FRIENDLY))
					user.visible_message(span_notice("[user] wipes [H]'s lipstick off with \the [src]."), \
										span_notice("You wipe off [H]'s lipstick."))
					H.lip_style = null
					H.update_body()

/obj/item/paper/proc/addtofield(id, text, links = 0)
	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(locid < 15)	//hey whoever decided a while(1) was a good idea here, i hate you
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart == 0)
			return	//No field found with matching id

		if(links)
			laststart = istart + length(info_links[istart])
		else
			laststart = istart + length(info[istart])
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		updateinfolinks()

/obj/item/paper/proc/updateinfolinks()
	info_links = info
	for(var/i=1,  i<=min(fields, 15), i++)
		addtofield(i, "<font face=\"[deffont]\"><A href='?src=\ref[src];write=[i]'>write</A></font>", 1)
	info_links = info_links + "<font face=\"[deffont]\"><A href='?src=\ref[src];write=end'>write</A></font>"


/obj/item/paper/proc/clearpaper()
	info = null
	stamps = null
	stamped = list()
	overlays.Cut()
	updateinfolinks()
	update_icon()


/obj/item/paper/proc/parsepencode(t, obj/item/tool/pen/P, mob/user as mob, iscrayon = 0)
	t = parse_pencode(t, P, user, iscrayon) // Wrap the global proc

	//Count the fields
	var/laststart = 1
	while(fields < 15)
		var/i = findtext(t, "<span class=\"paper_field\">", laststart)
		if(i==0)
			break
		laststart = i+1
		fields = min(fields+1, 20)
	return t


/obj/item/paper/proc/openhelp(mob/user as mob)
	user << browse({"<HTML><HEAD><TITLE>Pen Help</TITLE></HEAD>
	<BODY>
		<b><center>Crayon&Pen commands</center></b><br>
		<br>
		\[br\] : Creates a linebreak.<br>
		\[center\] - \[/center\] : Centers the text.<br>
		\[h1\] - \[/h1\] : Makes the text a first level heading<br>
		\[h2\] - \[/h2\] : Makes the text a second level heading<br>
		\[h3\] - \[/h3\] : Makes the text a third level heading<br>
		\[b\] - \[/b\] : Makes the text <b>bold</b>.<br>
		\[i\] - \[/i\] : Makes the text <i>italic</i>.<br>
		\[u\] - \[/u\] : Makes the text <u>underlined</u>.<br>
		\[large\] - \[/large\] : Increases the <font size = \"4\">size</font> of the text.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		\[small\] - \[/small\] : Decreases the <font size = \"1\">size</font> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule.
	</BODY></HTML>"}, "window=paper_help")

/obj/item/paper/proc/burnpaper(obj/item/P, mob/user)
	var/class = "<span class='warning'>"

	if(P.heat >= 400 && !user.restrained())
		if(istype(P, /obj/item/tool/lighter/zippo))
			class = "<span class='rose'>"

		user.visible_message("[class][user] holds \the [P] up to \the [src], it looks like [user.p_theyre()] trying to burn it!</span>", \
		"[class]You hold \the [P] up to \the [src], burning it slowly.</span>")

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_held_item() == P && P.heat)
				user.visible_message("[class][user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
				"[class]You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")

				if(user.get_inactive_held_item() == src)
					user.dropItemToGround(src)

				new /atom/movable/effect/decal/cleanable/ash(src.loc)
				qdel(src)

			else
				to_chat(user, span_warning("You must hold \the [P] steady to burn \the [src]."))


/obj/item/paper/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["write"])
		var/id = href_list["write"]
		var/t =  stripped_multiline_input(usr, "Enter what you want to write:", "Write", "", MAX_MESSAGE_LEN)
		log_paper("[key_name(usr)] wrote: [t]")

		var/obj/item/i = usr.get_active_held_item() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.
		var/iscrayon = 0
		if(!istype(i, /obj/item/tool/pen))
			if(!istype(i, /obj/item/toy/crayon))
				return
			iscrayon = 1


		// if paper is not in usr, then it must be near them, or in a clipboard or folder, which must be in or near usr
		if(src.loc != usr && !src.Adjacent(usr) && !((istype(src.loc, /obj/item/clipboard) || istype(src.loc, /obj/item/folder)) && (src.loc.loc == usr || src.loc.Adjacent(usr)) ) )
			return

		t = replacetext(t, "\n", "<BR>")
		t = parsepencode(t, i, usr, iscrayon) // Encode everything from pencode to html

		if(id!="end")
			addtofield(text2num(id), t) // He wants to edit a field, let him.
		else
			info += t // Oh, he wants to edit to the end of the file, let him.
			updateinfolinks()

		usr << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links][stamps]</BODY></HTML>", "window=[name]") // Update the window

		playsound(loc, pick('sound/items/write1.ogg','sound/items/write2.ogg'), 15, 1)

		update_icon()


/obj/item/paper/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/paper) || istype(I, /obj/item/photo))
		if(istype(I, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = I
			if(!C.iscopy && !C.copied)
				to_chat(user, span_notice("Take off the carbon copy first."))
				return
		if(loc != user)
			return
		var/obj/item/paper_bundle/B = new(get_turf(user))
		if(name != "paper")
			B.name = name
		else if(I.name != "paper" && I.name != "photo")
			B.name = I.name
		user.dropItemToGround(I)
		user.dropItemToGround(src)
		to_chat(user, span_notice("You clip \the [I] to [src]."))
		B.attach_doc(src, user, TRUE)
		B.attach_doc(I, user, TRUE)
		user.put_in_hands(B)

	else if(istype(I, /obj/item/tool/pen) || istype(I, /obj/item/toy/crayon))
		user << browse("<HTML><HEAD><TITLE>[name]</TITLE></HEAD><BODY>[info_links][stamps]</BODY></HTML>", "window=[name]")

	else if(istype(I, /obj/item/tool/stamp))
		if((!in_range(src, user) && loc != user && !(istype(loc, /obj/item/clipboard)) && loc.loc != user && user.get_active_held_item() != I))
			return

		stamps += (stamps == "" ? "<HR>" : "<BR>") + "<i>This paper has been stamped with \the [I].</i>"

		var/image/stampoverlay = image('icons/obj/items/paper.dmi')
		var/x
		var/y
		if(istype(I, /obj/item/tool/stamp/captain) || istype(I, /obj/item/tool/stamp/centcom))
			x = rand(-2, 0)
			y = rand(-1, 2)
		else
			x = rand(-2, 2)
			y = rand(-3, 2)
		offset_x += x
		offset_y += y
		stampoverlay.pixel_x = x
		stampoverlay.pixel_y = y

		if(!ico)
			ico = new
		ico += "paper_[I.icon_state]"
		stampoverlay.icon_state = "paper_[I.icon_state]"

		if(!stamped)
			stamped = new
		stamped += I.type
		overlays += stampoverlay

		to_chat(user, span_notice("You stamp the paper with your rubber stamp."))
		playsound(src, 'sound/items/stamp.ogg', 15, 1)

	else if(I.heat >= 400)
		burnpaper(I, user)


/*
* Premade paper
*/


/obj/item/paper/commendation
	name = "Commendation"
	info = "<center><H1>Commendation<H2>of Medical Excellence</H2></H1><br>Proudly presented to<br><H2><I><span class=\"paper_field\"></span></I></H2><b>for superior performance and excellency in medical skills.</b><br><br><hr><br><small>They have gone above and beyond in saving human lives, treating wounded, medical knowledge and surgical performance. Even when working in a difficult environment, they have shown outstanding courage, determination and commitment to save those in need. <small><span class=\"paper_field\"></span></small><br><br>They are a true example of the ideal doctor.</small><br><br><hr><br><b>Date</b><br><I><span class=\"paper_field\"></span> - 2186</I><br><br><b>Granted by</b><br><I>Prof. <span class=\"paper_field\"></span></I><br><small>Chief Medical Officer</small><br><span class=\"paper_field\"></span></center>"
	icon_state = "commendation"
	fields = 5

/obj/item/paper/commendation/update_icon() //it looks fancy and we want it to stay fancy.
	return
/*Let this be a lesson about pre-made forms.

when building your paper, use the above parsed pen code in parsepencode(). no square bracket anything in the info field.
Specifically for the field parts, use <span class=\"paper_field\"></span>.
then, for every time you included a field, increment fields. */

/obj/item/paper/Court
	name = "Judgement"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/paper/Toxin
	name = "Chemical Information"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Phoron:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter phoron after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Phoron.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep phoron.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSoporific T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effect are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/paper/hydroponics
	name = "Greetings from Billy Bob"
	info = "<B>Hey fellow botanist!</B><BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effect<BR>\nIn Liberty caps, potency = drug power + effect<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/paper/djstation
	name = "DJ Listening Outpost"
	info = "<B>Welcome new owner!</B><BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multi-tool</li><li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li><li>Turn all the machines on, it has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = TRUE

/obj/item/paper/jobs
	name = "Job Information"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Detective</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Phoron Technicians as phoron is the material they routinly handle.<BR>\n1. Research phoron<BR>\n2. Make sure all phoron is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"
	var/photo_id = 0.0
	item_state = "paper"

/obj/item/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alarms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/paper/prison_station/test_log
	name = "paper- 'Test Log'"
	info = "<p style=\"text-align: center;\"><sub>TEST LOG</sub></p><p>SPECIMEN: Bioweapon candidate Kappa. Individual 3</p><BR>\n<p>-</p><p>PROCEDURE: Observation</p><p>RESULTS: Specimen paces around cell. Appears agitated. Vocalisations.</p><p>-</p><p>PROCEDURE: Simian test subject</p><p>RESULTS: Devoured by specimen. No significant difference from last simian test.</p><p><em>Note: Time to amp it up</em></p><p>-</p><p>PROCEDURE: Human test subject (D-1). Instructed to \"pet it like a dog\"</p><p>RESULTS: Specimen and D-1 stare at each other for approximately two seconds. D-1 screams and begins pounding on observation window, begging to be released. Specimen pounces on D-1. Specimen kills D-1 with multiple slashes from its foreclaws.</p><p><em>Note: Promising!</em></p><p>-</p><p>PROCEDURE: Two human test subjects (D-2, D-3). Instructed to subdue specimen</p><p>RESULTS: D-2 and D-3 slowly approach specimen. D-3 punches specimen on forehead to no noticeable effect. Specimen pounces on D-3, then kills him with multiple slashes from its foreclaws. D-2 screams and begins pounding on observation window. Specimen pounces on D-2, then kills him with multiple slashes from its foreclaws.</p><p>Specimen begins slashing at observation access doors. Exhibiting an unexpected amount of strength, it is able to d~</p>"

/obj/item/paper/prison_station/monkey_note
	name = "paper- 'Note on simian test subjects'"
	info = "Keep an eye on the monkeys, and keep track of the numbers. We just found out that they can crawl through air vents and into the atmospheric system.<BR>\n<BR>\nI'd rather not have to explain to the Warden how the prisoners managed to acquire a new \"pet\". Again."

/obj/item/paper/prison_station/warden_note
	name = "paper- 'Final note'"
	info = "<p>Not much time left. Note to whoever may respond to the distress signal</p><p>Initially, there was a collision into the south high-security cellblock. We thought it was a pirate attack</p><p>It was, but something happened in the civilian residences. We were too tied up with the pirates to respond</p><p>Half the guards are dead. Most of the remainder not accounted for</p><p>Many likely trapped in yard when central lockdown activated. Timed lockdown of civilian residences also activated</p><p>Lockdown of civilian residences will automatically lift at 12:35</p><p>Central lockdown at 12:50</p><p>something comes</p>"

/obj/item/paper/prison_station/chapel_program
	name = "paper= 'Chapel service program'"
	info = "\"And when he had opened the fourth seal, I heard the voice of the fourth beast say, Come and see.<BR>\n<BR>\nAnd I looked, and behold a pale horse: and his name that sat on him was Death, and Hell followed with him. And power was given unto them over the fourth part of the earth, to kill with sword, and with hunger, and with death, and with the beasts of the earth.\"<BR>\n<BR>\n<BR>\n<BR>\n\"Chaplain:  Lord, have mercy.   All:  Lord, have mercy.<BR>\nChaplain:  Christ, have mercy.  All:  Christ, have mercy.<BR>\nChaplain:  Lord, have mercy.   All:  Lord, have mercy.\"<BR>\n<BR>\n<BR>\n<BR>\n<em>These are the only two readable sections. The rest is covered in smears of blood.</em>"

/obj/item/paper/prison_station/inmate_handbook
	name = "paper= 'Inmate Rights, Privileges and Responsibilities'"
	info = "<p style=\"text-align: center;\"><sub>FIORINA ORBITAL PENITENTIARY</sub></p><p style=\"text-align: center;\"><sub>INMATE RIGHTS, PRIVILEGES AND RESPONSIBILITIES</sub></p><p>RIGHTS</p><p>As per the Corrections Act 2087, you have the right to the following:</p><p>1. You have the right to be treated impartially and fairly by all personnel.<BR>\n2. You have the right to be informed of the rules, procedures, and schedules.<BR>\n3. You have the right to freedom of religious affiliation and voluntary religious worship.<BR>\n4. You have the right to health care which includes meals, proper bedding and clothing and a laundry schedule for cleanliness of the same, an opportunity to shower regularly, proper ventilation for warmth and fresh air, a regular exercise period, toilet articles, medical, and dental treatment.</p><p>PRIVILEGES</p><p>You do NOT have the right to the following; these are privileges granted by the institution, and may be revoked at ANY time for ANY reason:</p><p>1. You may be granted the privilege to visitation and correspondence with family members and friends.<BR>\n2. You may be granted the privilege to reading materials for educational purposes and for your own enjoyment.<BR>\n3. You may be granted the privilege to limited personal money to purchase items from the prison store.</p><p>RESPONSIBILITIES</p><p>Inmates must fufill the following responsibilities:</p><p>1. You have the responsibility to know and abide by all rules, procedures, and schedules.<BR>\n2. You have the responsibility to obey any and all commands from personnel.<BR>\n3. You have the responsibility to recognize and respect the rights of other inmates.<BR>\n4. You have the responsibility to not waste food, to follow the laundry and shower schedule, maintain neat and clean living quarters, keep your area free of contraband, and seek medical and dental care as you may need it.<BR>\n5. You have the responsibility to conduct yourself properly during visits, not accept or pass contraband, and not violate the law or institution rules or institution guidelines through your correspondence.<BR>\n6. You have the responsibility to meet your financial obligations including, but not limited to, court imposed assessments, fines, and restitution.<BR>\n<B>7. You have the responsibility to coorporate with the Fiorina Orbital Penitentiary's Medical Research Department in any and all research studies.</B></p>"

/obj/item/paper/prison_station/pirate_note
	name = "paper= 'Captain's log'"
	info = "<p>We found him.</p><p>His location, anyway. Figures that he'd end up in the Fop, given our reputation.</p><p>As good an escape artist he is, he ain't getting out by himself. Too many security measures, and no way off without a ship. They're prepared for anything coming from inside.</p><p>They AREN'T prepared for a \"tramp freighter\" ramming straight through their hull.</p><p>Hang tight, Jack. We're coming for you."

/obj/item/paper/prison_station/nursery_rhyme
	info = "<p>Mary had a little lamb,<BR>\nits fleece was white as snow;<BR>\nAnd everywhere that Mary went,<BR>\nthe lamb was sure to go.</p><p>It followed her to school one day,<BR>\nwhich was against the rule;<BR>\nIt made the children laugh and play,<BR>\nto see a lamb at school.</p><p>And so the teacher turned it out,<BR>\nbut still it lingered near,<BR>\nAnd waited patiently about,<BR>\ntill Mary did appear.</p><p>\"Why does the lamb love Mary so?\"<BR>\nthe eager children cry;<BR>\n\"Why, Mary loves the lamb, you know\",<BR>\nthe teacher did reply."

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"

/obj/item/paper/crumpled/update_icon()
	return

/obj/item/paper/crumpled/bloody/
	icon_state = "scrap_bloodied"

/obj/item/paper/crumpled/bloody/csheet
	info = "<b>Character Sheet</b>\n\nKorbath the Barbarian\nLevel 6 Barbarian\nHitpoints: 47/93\nSTR: 18\nDEX: 14\nCON: 16\nINT: 8\nWIS: 11\nCHA: 15\n\n<B>Inventory:</b>\nGreatsword +3 \nChain M--\n\n\nThe rest of the page is covered in smears of blood."

/obj/item/paper/chemsystem
	name = "Vali manual"
	info = {"<b>How to use the Vali system</b><BR>
	The Vali system uses green blood to provide healing and other effects.<BR>
	Green blood is collected by attacking with a connected weapon.<BR>
	<BR>
	<b>Active effect:</b><BR>
	> You get brute and burn healing every 2 seconds.<BR>
	> For the first 20 seconds you also get stamina regeneration every 2 seconds that gets decreased to 0 over time.<BR>
	> These effects get boosted and new effects might be added for the time the system is active, if you have certain amount of certain reagents at the time of activation.
	For this check the reagent information from the configurations menu.<BR>
	<BR>
	<b>Configurations menu:</b><BR>
	From here you can configure the system.<BR>
	> Connect - Connects/disconnects to/from the Vali system a system-compatible item you are holding.<BR>
	> Extract - Fills the reagent container you are holding with 10u of green blood from the system's storage. Green blood can be used to duplicate bicaridine/kelotane/tramadol/dylovene.<BR>
	> Switch boost - switches between the boost tiers that the system offers. Usually the stronger the boost, the more green blood is required for operation.<BR>
	<BR>
	<b>On-Off button</b><BR>
	As the name implies, you switch the system's reagent boosting ability on or off with it.<BR>
	> The system can stay on for 20 seconds before you get necrotized flesh from keeping it on.<BR>
	<BR>
	<b>Pre-loading reagents using the Load action in configurations</b><BR>
	> 60u capacity<BR>
	> Can't load pills.<BR>
	> When you are holding a filled liquid holder, you can load its contents into the Vali system's reagent tank.<BR>
	> When you are holding an empty liquid holder, you can empty the Vali's reagent tank into it.<BR>
	> When you aren't holding a liquid holder, you can pick whether you would like the internal tank's reagents to be automatically injected on activation or not.<BR>"}

/obj/item/paper/brassnote
	name = "Brass Note"
	icon = 'icons/obj/items/paper.dmi'
	icon_state = "brassplate"
	info = {"...Gur Rzvarapr fcbxr nzbatfg uvf sbyybjref va gur sbhy cynvaf bs gur nfura jbeyq jvgu juvpu gurl ynvq gurve urnqf, naq ol gur jvyy bs gur Vzzbegny Whfgvpne, naq gur gbbyf bs gur zvtugl Nezbere, gurl pbafgehpgrq n gbby fb inyvnag naq cbjreshy gung gur qrivyvfu ubhaqf bs Ane'fvr pbhyq qb anhtug ohg dhnxr nzbatfg gurzfryirf nf gur Oenff Tniry chevsvrq gur jbeyq nebhaq vg."}

/obj/item/paper/xenofinance
	name = "To T. Jackson"
	info = {"Boss, I know i'm the one who handles this place's finances, but are you KIDDING ME? Have you not even looked at the things we're importing? Why are we buying so much relating to our science department? <BR>
	How much can you even research down here? And don't think I didn't notice you almost doubled our mining staff! Not to mention how our general security has been replaced by these new PMCs. <BR>
	We had to build an entire second dormitory for all these new workers! You NEED to have a look at our balance, because if we don't make some changes soon, this place is going under! - F. Arrek"}

/obj/item/paper/xenoresearch1
	name = "Project X^2.I, 1"
	info = {"This is Xenobiologist Dr. Evan Reiker, reporting our current progress in the X^2 project. From the samples we've been able to grow in the lab, we've discovered a lot about these creatures. <BR>
	We haven't had much time, but we've been able to "tap into" per-se, some aspects of their biology, namely with the new 'XT-S' HUD device. As long as we don't allow a full specimen to be grown, <BR>
	we should be perfectly fine."}

/obj/item/paper/xenoresearch2
	name = "Project X^2.I, 2"
	info = {"This is, again, Dr. Evan Reiker of the X^2 project. The Site Manager has forced us to drop our other projects and focus on growing full specimens. <BR>
	We've tried to reason with him about it, however he just thinks that these new PMCs can handle any potential breaches. He doesn't understand the full capability of these creatures. <BR>
	We're pressing on and trying to do it as safely as possible. On the bright side, it has helped us learn more about the species, including potentially psychic aspects regarding their leader castes. Atleast we're getting more funding."}

/obj/item/paper/xenoresearch3
	name = "Proje- Oh who the fuck cares."
	info = {"That coniving son of a bitch! Research has continually been asked by the S.M to hand over some of our fully-grown subjects for "Off-site testing", like we believe him. <BR>
	Everyone here thinks that he's selling these damn things for profit. It'd make sense since we didn't make too much money to begin with. Does he really not understand the severity of this? <BR>
	Not even that, he's also cutting our security funding because "Nothing's happened yet, and it costs money!" of course it costs money, because money is all you care about, isn't it? <BR>
	I'm still on the payroll, so I can't just get in his face about this, but when these papers get out, hot damn if he isn't gonna get the government's ass on him. - E. Reiker"}

/obj/item/paper/clockresearch1
	name = "Weird Project"
	info = {"The science boys over at the lab keep talking about this weird project they're trying to get me to help them work on. No clue what they're on about, something about clocks? <BR>
	Whatever it is, they need to shut up about it! I've told them over and over again that we're focusing on xenobiology, and we can't just shift gears (heh) to some magical cult thing nobody's ever heard of! <BR>
	I swear, if they don't shut up about this, I'm gonna have that catwalk up north broken! - T. Jackson"}

/obj/item/paper/clockresearch2
	name = "Bloodied note"
	info = {"After doing some ultrasound examination of the strange cave formation, we've uncovered a strange metallic device. It seems to be capable of accepting data discs from the images <BR>
	we've uncovered. This is a massive breakthrough in our progress! We haven't breached into the area yet, but we've moved in some consoles in case it's compatible with the technology we have. <BR>
	Though, it seems there's another chamber in front of it. Scans show some kind of moving figures, though the scanner might just be broken or misinterpreting some basalt dust."}

/obj/item/paper/chemistry
	name = "Notice from Terragov"
	info = {"After a routine inspection from the Terragov Chemical Regulatory comittee, we have found that this vessel has, one, an unlicensed access issue that must be amended, and two, nearly double the authorized deployment of chemical vendors. <BR>
	We are updating the access requirements on your chemistry bay, as well as confiscating the additional vendors until further notice. Have a nice day."}

/obj/item/paper/memorial
	name = "Memorial Note"
	info = {"May the souls of our fallen brothers be at rest; not that we may find solace in their passing, but that we should take our due initiative to press on in their memory."}
