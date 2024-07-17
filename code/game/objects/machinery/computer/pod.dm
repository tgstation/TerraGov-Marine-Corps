/obj/machinery/computer/pod
	name = "Pod Launch Control"
	desc = "A controll for launching pods. Some people prefer firing Mechas."
	icon_state = "computer"
	screen_overlay = "computer_generic"
	circuit = /obj/item/circuitboard/computer/pod
	var/id = 1
	var/timing = 0
	var/time = 30
	var/title = "Mass Driver Controls"

/obj/machinery/computer/pod/old
	icon_state = "old"
	screen_overlay = "old_screen"
	name = "DoorMex Control Computer"
	title = "Door Controls"

/obj/machinery/computer/pod/old/syndicate
	name = "ProComp Executive IIc"
	desc = "The Syndicate operate on a tight budget. Operates external airlocks."
	title = "External Airlock Controls"

/obj/machinery/computer/pod/old/swf
	name = "Magix System IV"
	desc = "An arcane artifact that holds much magic. Running E-Knock 2.2: Sorceror's Edition"
