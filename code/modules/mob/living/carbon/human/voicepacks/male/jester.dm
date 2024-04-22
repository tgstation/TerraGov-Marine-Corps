/datum/voicepack/male/jester/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("laugh")
			used = list('sound/vo/male/jester/laugh (1).ogg','sound/vo/male/jester/laugh (2).ogg','sound/vo/male/jester/laugh (3).ogg')
	if(!used)
		used = ..(soundin, modifiers)
	return used

/datum/voicepack/male/dwarf/jester/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("laugh")
			used = list('sound/vo/male/jester/laugh (1).ogg','sound/vo/male/jester/laugh (2).ogg','sound/vo/male/jester/laugh (3).ogg')
	if(!used)
		used = ..(soundin, modifiers)
	return used

/datum/voicepack/male/elf/jester/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("laugh")
			used = list('sound/vo/male/jester/laugh (1).ogg','sound/vo/male/jester/laugh (2).ogg','sound/vo/male/jester/laugh (3).ogg')
	if(!used)
		used = ..(soundin, modifiers)
	return used