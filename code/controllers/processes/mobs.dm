datum/controller/process/mobs

datum/controller/process/mobs/setup()
	name = "Mobs"
	schedule_interval = 20 //2 seconds

datum/controller/process/mobs/doWork()

	var/i = 1
	while(i<=mob_list.len)
		var/mob/M = mob_list[i]
		if(M)
			M.Life()
			i++
			continue
		mob_list.Cut(i,i+1)