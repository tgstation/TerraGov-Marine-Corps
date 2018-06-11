

Quick Startup guide for the MapDaemon script by MadSnailDisease

1. Install a jre of version 1.8 or later. (as of writing this, 1.8 is the most recent)
1.5. Set up your user variables for java for easier command line use https://stackoverflow.com/questions/1672281/environment-variables-for-java-installation
2. Properly configure the config.txt file to your specifications and change it to a .json file. This will mainly include a bunch of paths and the url and port for the server. "localhost" should be used for local testing,
	and "play.colonial-marines.com" for live tests. The port for colonial marines is 1400.
2.5 Edit run_mapdaemon.bat to have the proper .jar and log file locations.
4. Copy run_mapdaemon.bat to your DM project folder
5. Run the server using DD out of what you put for dest_base in config.json
	-> If you haven't used MapDaemon before it's important to copy the three binaries (.dmb, .int, and .rsc) to dest_base
6. If you do not want logs dumped to console and saved no matter what (understandably), change the "true" in run_mapdaemon.bat to a "false"
7. For voting, use the Map Vote verb under the OOC tab, and select which map you want to play.

How the MapDaemon works:
Server side:
	Votes are not taken until the round is over, and there will be a minimum of 30 seconds to vote before the bot grabs the info and processes it.
	The round will be delayed until the bot decides to resume it
	Admins will have a chance to delay the round if they are processing bans
	If you manually restart the server before MapDaemon finishes its business, the following could occur:
		The map and gamemode not lining up (unlikely)
		Resource conflicts, like when visual updates are pushed
		Other issues that generally come along when you restart a game mid-compile

Daemon side:
	The bot will ask the server if the round ended every 5 seconds, or whatever number you put into config.json
	When realizes that the round is over, it will wait 30 seconds and then retrieve the votes
	Once processed, it will modify the .dme, compile, and copy the .int, .rsc, and .dmb files over to the dest_base directory
	The bot will then tell the server to restart in a few seconds, telling admins to delay the round if they want to process bans
	Once the world is rebooted, the new map will be loaded up and ready, with the gamemode already changed.
	
If you want to run a test of a specific map, especially if it's a map or has code that is not already pulled, you'll need to pull, compile, and copy normally.

Updating code:
All you will need to do is pull from master and the next round will have the new updates.
Git integration is planned, either in a future watchdog script or this same script.
ATM it's not necessary since the same people with write access to the repo have access to the remote (as far as I know).
