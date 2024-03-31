/datum/voicepack/male/wizard/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("laugh")
			used = 'sound/vo/male/wizard/laugh.ogg'
	if(!used)
		used = ..(soundin, modifiers)
	return used
