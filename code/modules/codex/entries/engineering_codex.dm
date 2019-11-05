/datum/codex_entry/apc
	associated_paths = list(/obj/machinery/power/apc)
	mechanics_text = "An APC (Area Power Controller) regulates and supplies backup power for the area they are in. Their power channels are divided \
	out into 'environmental' (Items that manipulate airflow and temperature), 'lighting' (the lights), and 'equipment' (Everything else that consumes power).  \
	Power consumption and backup power cell charge can be seen from the interface, further controls (turning a specific channel on, off or automatic, \
	toggling the APC's ability to charge the backup cell, or toggling power for the entire area via master breaker) first requires the interface to be unlocked \
	with an ID with Engineering access or by one of the station's robots or the artificial intelligence."

	antag_text = "Wires can be pulsed remotely with a signaler attached to it.  A powersink will also drain any APCs connected to the same wire the powersink is on."

/datum/codex_entry/inflatable_item
	associated_paths = list(/obj/item/inflatable)
	mechanics_text = "Inflate by using it in your hand.  The inflatable barrier will inflate on your tile.  To deflate it, use the 'deflate' verb."

/datum/codex_entry/inflatable_deployed
	associated_paths = list(/obj/structure/inflatable)
	mechanics_text = "To remove these safely, use the 'deflate' verb.  Hitting these with any objects will probably puncture and break it forever."

/datum/codex_entry/inflatable_door
	associated_paths = list(/obj/structure/inflatable/door)
	mechanics_text = "Click the door to open or close it.  It only stops air while closed.<br>\
	To remove these safely, use the 'deflate' verb.  Hitting these with any objects will probably puncture and break it forever."

/datum/codex_entry/welding_pack
	associated_paths = list(/obj/item/storage/backpack/marine/engineerpack)
	mechanics_text = "This pack acts as a portable source of welding fuel. Use a welder on it to refill its tank - but make sure it's not lit! You can use this kit on a fuel tank or appropriate reagent dispenser to replenish its reserves."
	lore_text = "The Shenzhen Chain of 2380 was an industrial accident of noteworthy infamy that occurred at Earth's L3 Lagrange Point. An apprentice welder, working for the Shenzhen Space Fabrication Group, failed to properly seal her fuel port, triggering a chain reaction that spread from laborer to laborer, instantly vaporizing a crew of fourteen. Don't let this happen to you!"
	antag_text = "In theory, you could hold an open flame to this pack and produce some pretty catastrophic results. The trick is getting out of the blast radius."

/datum/codex_entry/Det_Pack
	associated_paths = list(/obj/item/detpack)
	mechanics_text = "How to use, in 6 steps.<br>\
	<br>1. Activate the det pack in your hand to open a window.<br>\
	2. Check your Detonation Mode is set to the explosion you desire.<br>\
	3. Turn your det pack ON.<br>\
	4. Remember the frequency it is set to, or change it to one you desire.<br>\
	5. With your now activated Det Pack (tiny green light is on), place it on the wall/floor/object as desired by clicking with it in your hand.<br>\
	6. Send a signal with your singaler to activate your explosive."

	lore_text = "The Detonation pack is an improvement on the old Plastique Compound 4, commonly known as C4.<br><br>\
	The demands of the TGMC required a device that could be used as both a breaching charge and also as explosive ordanence.<br><br>\
	Thus the now common det pack was produced with a two stage explosive package. An inner package surrounded by metal shaping plates for breaching and a connected larger outer package that is able to provide a bigger bang when activated by the electronic detonation channel.<br><br>\
	There have been no incidents where the outer package was accidentally activated while the Det Pack was set on breaching mode."
