//max channel is 1024. Only go lower from here, because byond tends to pick the first availiable channel to play sounds on
#define CHANNEL_LOBBYMUSIC 1024
#define CHANNEL_AMBIENT 1023
#define CHANNEL_NOTIFY 1022 // observer, new player, vote notifications
#define CHANNEL_VOX 1021 //vox announcements from AI
#define CHANNEL_ANNOUNCEMENTS 1020 // IC priority announcements, hivemind messages etc
#define CHANNEL_CINEMATIC 1019
#define CHANNEL_ADMIN 1018
#define CHANNEL_MIDI 1017
#define CHANNEL_AMBIENCE 1016

//THIS SHOULD ALWAYS BE THE LOWEST ONE!
//KEEP IT UPDATED

#define CHANNEL_HIGHEST_AVAILABLE 1015

#define MAX_INSTRUMENT_CHANNELS (128 * 6)

#define FALLOFF_SOUNDS 1

///Frequency stuff only works with 45kbps oggs.
#define GET_RAND_FREQUENCY (rand(32000, 55000))
