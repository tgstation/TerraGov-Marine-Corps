//The return of data disks?? Just for transferring between genetics machine/cloning machine.
//TO-DO: Make the genetics machine accept them.
/obj/item/disk/data
	name = "Cloning Data Disk"
	icon_state = "datadisk0" //Gosh I hope syndies don't mistake them for the nuke disk.
	item_state = "card-id"
	w_class = 1
	var/datum/dna2/record/buf=null
	var/read_only = 0 //Well,it's still a floppy disk

/obj/item/disk/data/Initialize()
	. = ..()
	buf = new
	buf.dna=new

/obj/item/disk/data/demo
	name = "data disk - 'God Emperor of Mankind'"
	read_only = 1

	New()
		Initialize()
		buf.types=DNA2_BUF_UE|DNA2_BUF_UI
		//data = "066000033000000000AF00330660FF4DB002690"
		//data = "0C80C80C80C80C80C8000000000000161FBDDEF" - Farmer Jeff
		buf.dna.real_name="God Emperor of Mankind"
		buf.dna.unique_enzymes = md5(buf.dna.real_name)
		buf.dna.UI=list(0x066,0x000,0x033,0x000,0x000,0x000,0xAF0,0x033,0x066,0x0FF,0x4DB,0x002,0x690)
		//buf.dna.UI=list(0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x0C8,0x000,0x000,0x000,0x000,0x161,0xFBD,0xDEF) // Farmer Jeff
		buf.dna.UpdateUI()

/obj/item/disk/data/monkey
	name = "data disk - 'Mr. Muggles'"
	read_only = 1

	New()
		Initialize()
		buf.types=DNA2_BUF_SE
		var/list/new_SE=list(0x098,0x3E8,0x403,0x44C,0x39F,0x4B0,0x59D,0x514,0x5FC,0x578,0x5DC,0x640,0x6A4)
		for(var/i=new_SE.len;i<=DNA_SE_LENGTH;i++)
			new_SE += rand(1,1024)
		buf.dna.SE=new_SE
		buf.dna.SetSEValueRange(MONKEYBLOCK,0xDAC, 0xFFF)

//Find a dead mob with a brain and client.
/proc/find_dead_player(var/find_key)
	if (isnull(find_key))
		return

	var/mob/selected = null
	for(var/mob/living/M in GLOB.player_list)
		//Dead people only thanks!
		if ((M.stat != 2) || (!M.client))
			continue
		//They need a brain!
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species.has_organ["brain"] && !H.has_brain())
				continue
		if (M.ckey == find_key)
			selected = M
			break
	return selected

//Disk stuff.
/obj/item/disk/data/New()
	..()
	var/diskcolor = pick(0,1,2)
	src.icon_state = "datadisk[diskcolor]"

/obj/item/disk/data/attack_self(mob/user as mob)
	src.read_only = !src.read_only
	to_chat(user, "You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"].")

/obj/item/disk/data/examine(mob/user)
	..()
	to_chat(user, "The write-protect tab is set to [read_only ? "protected" : "unprotected"].")
	return

//Health Tracker Implant

/obj/item/implant/health
	name = "health implant"
	var/healthstring = ""

/obj/item/implant/health/proc/sensehealth()
	if (!src.implanted)
		return "ERROR"
	else
		if(isliving(src.implanted))
			var/mob/living/L = src.implanted
			src.healthstring = "[round(L.getOxyLoss())] - [round(L.getFireLoss())] - [round(L.getToxLoss())] - [round(L.getBruteLoss())]"
		if (!src.healthstring)
			src.healthstring = "ERROR"
		return src.healthstring

/*
 *	Diskette Box
 */

/obj/item/storage/box/disks
	name = "Diskette Box"
	icon_state = "disk_kit"
	spawn_type = /obj/item/disk/data
	spawn_number = 7