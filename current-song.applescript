-- Return the current playing song to be displayed with GeekTool.
-- Supports iTunes, Spotify, and cmus (C* Music Player).
-- Author: Adam Schwartz
-- Created: 2014-06-06
-- Updated: 2015-03-22

on run
	set info to ""
	-- Display song info from cmus
	set cmus_status to do shell script "/usr/local/Cellar/cmus/2.5.1/bin/cmus-remote -Q | grep 'status' | cut -d ' ' -f 2-"
	
	if cmus_status is "playing" then
		set _title to do shell script "/usr/local/Cellar/cmus/2.5.1/bin/cmus-remote -Q | grep 'title' | cut -d ' ' -f 3-"
		set _artist to do shell script "/usr/local/Cellar/cmus/2.5.1/bin/cmus-remote -Q | grep -e '[^m]artist' | cut -d ' ' -f 3-"
		set _album to do shell script "/usr/local/Cellar/cmus/2.5.1/bin/cmus-remote -Q | grep -e 'album[^a]' | cut -d ' ' -f 3-"
		set info to _title & return & _artist & return & _album as string
		return info
	end if
	-- Display song info from mpc
	try
		set info to do shell script "/usr/local/Cellar/mpc/0.26/bin/mpc -f \"%title%
%artist%
%album%\" | head -3"
		-- note: applescript compiles `\n` out of the string
	end try
	if info contains "volume:" then
		set info to ""
	end if
	return info
	-- Display song info from Spotify
	if application "Spotify" is running then
		tell application "System Events"
			set runCount to count (every process whose name is "Spotify")
		end tell
		if runCount > 0 then
			tell application "Spotify"
				if player state is playing then
					set the sound volume to 100
					set _artist to artist of current track
					set _title to name of current track
					set _album to album of current track
					set info to _title & return & _artist & return & _album as string
					if info contains "http" or info contains "spotify:" then
						set info to ""
						set the sound volume to 0 -- mute Spotify during advertisements like Spotifree
						play
					end if
				end if
			end tell
		end if
		if info is not "" then return info
	end if
	-- Display song info from iTunes
	if application "iTunes" is running then
		tell application "System Events"
			set runCount to count (every process whose name is "iTunes")
		end tell
		if runCount > 0 then
			tell application "iTunes"
				if player state is playing then
					set _artist to artist of current track
					set _title to name of current track
					set _album to album of current track
					set info to _title & return & _artist & return & _album as string
				end if
			end tell
		end if
		return info
	end if
end run