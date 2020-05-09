//max channel is 1024. Only go lower from here, because byond tends to pick the first availiable channel to play sounds on
#define CHANNEL_LOBBYMUSIC 1024
#define CHANNEL_AMBIENT 1023
#define CHANNEL_NOTIFY 1022 // observer, new player, vote notifications
#define CHANNEL_ANNOUNCEMENTS 1021 // IC priority announcements, hivemind messages etc
#define CHANNEL_CINEMATIC 1020
#define CHANNEL_ADMIN 1019
#define CHANNEL_MIDI 1018

//THIS SHOULD ALWAYS BE THE LOWEST ONE!
//KEEP IT UPDATED

#define CHANNEL_HIGHEST_AVAILABLE 1017

#define FALLOFF_SOUNDS 1

///Frequency stuff only works with 45kbps oggs.
#define GET_RAND_FREQUENCY (rand(32000, 55000))
