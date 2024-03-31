/datum/voicepack/male/evil/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("critpain")
			used = list('sound/vo/male/evil/critpain (1).ogg','sound/vo/male/evil/critpain (2).ogg','sound/vo/male/evil/critpain (3).ogg')
		if("firescream")
			used = list('sound/vo/male/evil/firescream (1).ogg','sound/vo/male/evil/firescream (2).ogg','sound/vo/male/evil/firescream (3).ogg','sound/vo/male/evil/firescream (4).ogg','sound/vo/male/evil/firescream (5).ogg','sound/vo/male/evil/firescream (6).ogg')
		if("grumble")
			used = 'sound/vo/male/evil/grumble.ogg'
		if("laugh")
			used = list('sound/vo/male/evil/laugh (1).ogg','sound/vo/male/evil/laugh (2).ogg','sound/vo/male/evil/laugh (3).ogg','sound/vo/male/evil/laugh (4).ogg','sound/vo/male/evil/laugh (5).ogg','sound/vo/male/evil/laugh (6).ogg','sound/vo/male/evil/laugh (7).ogg','sound/vo/male/evil/laugh (8).ogg')
		if("pain")
			used = list('sound/vo/male/evil/pain (1).ogg','sound/vo/male/evil/pain (2).ogg','sound/vo/male/evil/pain (3).ogg','sound/vo/male/evil/pain (4).ogg','sound/vo/male/evil/pain (5).ogg','sound/vo/male/evil/pain (6).ogg','sound/vo/male/evil/pain (7).ogg','sound/vo/male/evil/pain (8).ogg')
		if("painmoan")
			used = list('sound/vo/male/evil/painmoan (1).ogg','sound/vo/male/evil/painmoan (2).ogg','sound/vo/male/evil/painmoan (3).ogg','sound/vo/male/evil/painmoan (4).ogg','sound/vo/male/evil/painmoan (5).ogg')
		if("painscream")
			used = list('sound/vo/male/evil/painscream (1).ogg','sound/vo/male/evil/painscream (2).ogg')
		if("rage")
			used = list('sound/vo/male/evil/rage (1).ogg','sound/vo/male/evil/rage (2).ogg')

	if(!used)
		used = ..(soundin, modifiers)
	return used

//tyrants, bandits

/datum/voicepack/male/evil/blkknight/get_sound(soundin, modifiers)
	var/used
	switch(soundin)
		if("laugh")
			used = list('sound/vo/male/evil/blkknightlaugh.ogg')

	if(!used)
		used = ..(soundin, modifiers)
	return used

//tyrants, bandits