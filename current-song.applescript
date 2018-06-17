-- Return the current playing song to be displayed with GeekTool.
-- Supports iTunes, Spotify, mpc, and cmus (C* Music Player).
-- Author: Adam Schwartz
-- Created: 2014-06-06
-- Updated: 2015-03-22

on run
	set info to ""
	-- Display song info from cmus
	set cmus_status to do shell script "/usr/local/Cellar/cmus/2.5.1/bin/cmus-remote -Q | grep 'status' | cut -d ' ' -f 2-"
	
	if cmus_status is "playing" then
		set _title to do shell script "/usr/local/bin/cmus-remote -Q | grep 'title' | cut -d ' ' -f 3-"
		set _artist to do shell script "/usr/local/bin/cmus-remote -Q | grep -e '[^m]artist' | cut -d ' ' -f 3-"
		set _album to do shell script "/usr/local/bin/cmus-remote -Q | grep -e 'album[^a]' | cut -d ' ' -f 3-"
		set info to _title & return & _artist & return & _album as string
		return info
	end if
	-- Display song info from mpc
	try
		set info to do shell script "/usr/local/bin/mpc -f \"%title%
%artist%
%album%\" | head -4"
		-- note: applescript compiles `\n` out of the string
	end try
	if info contains "[playing]" then
		return info
	else if info contains "[paused]" or info contains "volume:" then
		set info to ""
	end if
	-- Display song info from Spotify
	if application "Spotify" is running then
		tell application "System Events"
			set runCount to count (every process whose name is "Spotify")
		end tell
		if runCount > 0 then
			tell application "Spotify"
				if player state is playing then
					set _title to name of current track
					set _artist to artist of current track
					set _album to album of current track
					set info to _title & return & _artist & return & _album as string
					if _artist is equal to "" and _album is equal to "" then
						set info to ""
					end if
					return info
				end if
			end tell
		end if
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
					return info
				end if
			end tell
		end if
	end if
end run