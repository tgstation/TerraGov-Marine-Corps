/datum/voicepack/female/dwarf/get_sound(soundin, modifiers)
	var/used
	switch(modifiers)
		if("old")
			used = getfold(soundin)
		if("young")
			used = getfyoung(soundin)
		if("silenced")
			used = getfsilenced(soundin)
	if(!used)
		switch(soundin)
			if("chuckle")
				used = list('sound/vo/female/dwarf/chuckle (1).ogg','sound/vo/female/dwarf/chuckle (2).ogg','sound/vo/female/dwarf/chuckle (3).ogg')
			if("laugh")
				used = list('sound/vo/female/dwarf/laugh (1).ogg','sound/vo/female/dwarf/laugh (2).ogg','sound/vo/female/dwarf/laugh (3).ogg')


	if(!used) //we haven't found a racial specific sound so use generic
		used = ..(soundin)
	return used