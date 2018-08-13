-- self == L
-- rawset(t, key, value)
-- Sets the value associated with a key in a table without invoking any metamethods
-- t - A table (table)
-- key - A key in the table (cannot be nil) (value)
-- value - New value to set for the key (value)
select(2, ...).L = setmetatable({
	["GET_STARTED"] = [[
		<h1>Get Started</h1>
		<p>|cFFFF3030Assign admin:|r In order to use GRA, your guild must have a GRA admin.</p>
		<p>Add a newline for example: |cFF00CCFF#GRA:Admin|r or |cFF00CCFF#GRA:Admin1,Admin2,...|r to guild information (no spaces). Require a UI reload.</p>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\getting_started_1.tga" height="128" align="center"/>
		<p></p>
		<p>|cFFFF3030Import members:|r |cFF00CCFFConfig > Import|r to select your raid members.</p>
		<p></p>
		<p>|cFFFF3030Init/Set EPGP (if your guild use EPGP):|r |cFF00CCFFConfig > EPGP Options > Enable EPGP|r. Auto decay is CURRENTLY not available, you have to do it manually.</p>
		<p></p>
		<p>|cFFFF3030Set raid days:|r |cFF00CCFFConfig > Attendance Sheet|r, select raid days to show in the attendance sheet.</p>
		<p></p>
		<p>|cFFFF3030Set raid start time:|r |cFF00CCFFConfig > Attendance Sheet|r, set |cFF00CCFFRaid Start Time|r for your raid. This time is used to check whether members are late or not. You can also set different times for each day.</p>
		<p></p>
		<p>After all above, you can get into raid instance. Start tracking raids by accepting |cFF00CCFFTrack This Raid|r dialog. And don't forget to send roster data to your raid members, or their GRA will show nothing.</p>
	]],
	["EPGP_OPTIONS"] = [[
		<h1>EPGP Options</h1>
		<p>Visit <a href="link">https://wow.gamepedia.com/EPGP</a> for further details about EPGP system.</p>
		<p></p>
		<p>|cFFFF3030All EPGP data are stored in officer notes.|r Your guild leader should revoke the privilege to edit officer note from most of guild members.</p>
		<p></p>
		<p>|cFFFF3030Decay:|r After this, all EP an GP will be converted to integer.</p>
		<p>|cFFFF3030Reset EPGP:|r Set all members' EP and GP to 0.</p>
		<p>This will NOT reset your addon data (roster, logs...). And this will have NO effect on the members who are not in the roster.</p>
	]],
	["START_TRACKING"] = [[
		<h1>Start Tracking</h1>
		<p>Get into raid instance, accept |cFF00CCFFTrack This Raid|r dialog, done!</p>
		<p>You can manually start or stop tracking by clicking |cFF00CCFFTRACK|r button at the top left corner.</p>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\start_tracking_1.tga" height="32" align="center"/>
		<br/>
		<p>|cFFFF3030Join Time:|r automatically recorded, but can be edited at any time. You should manually set it for the members imported after you have started tracking.</p>
		<p><a href="EDIT_ATTENDANCE">Check here for more information.|r</a></p>
	]],
	["ROSTER"] = [[
		<h1>Import</h1>
		<p>|cFF00CCFFConfig > Import|r, select members then |cFF00CCFFImport|r.</p>
		<br/>
		<h1>Rename</h1>
		<p>|cFF00CCFFConfig > Modify|r, double-click on the member, input new name (fullname, include realm name). Don't forget to |cFF00CCFFSave All Changes|r.</p>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\roster_1.tga" height="64" align="center"/>
		<br/>
		<h1>Delete</h1>
		<p>|cFF00CCFFConfig > Modify|r, simply click the "×" button. Don't forget to |cFF00CCFFSave All Changes|r.</p>
		<br/>
		<h1>Send Roster Data</h1>
		<p>|cFF00CCFFConfig > Send Roster|r, you should always send the newest roster data to your raid members, otherwise they can't find newly added members in their roster.</p> 
	]],
	["RAID_LOGS"] = [[
		<h1>Create</h1>
		<p>|cFF00CCFFRaid Logs > New Raid Log|r, select date then |cFF00CCFFCreate|r.</p>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\raid_log_1.tga" height="64" align="center"/>
		<br/>
		<h1>Delete</h1>
		<p>Select multiple logs with the Ctrl and Shift keys, then |cFF00CCFFDelete Raid Log|r.</p>
		<p>Deleting raid logs will |cFFFF3030NOT|r undo changes to EPGP. You have to delete each entry first if you want to undo these changes.</p>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\raid_log_2.tga" height="128" align="center"/>
		<br/>
		<h1>Send</h1>
		<p>Select multiple logs with the Ctrl and Shift keys, then |cFF00CCFFSend To Raid|r.</p>
		<p>Only the members in your raid/party can receive your data.</p>
	]],
	["EDIT_ATTENDANCE"] = [[
		<h1>Edit Attendance</h1>
		<p>|cFF00CCFFRaid Logs > select a raid date > Attendance Editor|r</p>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\edit_attendance_1.tga" height="256" align="center"/>
		<p></p>
		<p>|cFF00CCFFDouble-click on the second column|r, select attendance status.</p>
		<p>|cFF00CCFFClick on the third column|r, set join time (Present) or note (Absent).</p>
		<p>You can also set Raid Start Time for this day.</p>
	]],
	["RAID_LOG_ENTRIES"] = [[
		<h1>Create A New Raid Log Entry</h1>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\raid_log_entries_1.tga" height="64" align="center"/>
		<p>|cFFFF3030EPGP:|r |cFF00CCFFEP Award|r, |cFF00CCFFGP Credit|r, |cFF00CCFFPenalize|r.</p>
		<p>|cFF00CCFFGP Credit:|r Value editbox has a built-in simple arithmetic expression evaluator. I recommend that you use integer instead of decimal.</p>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\raid_log_entries_2.tga" height="64" align="center"/>
		<p>|cFF00CCFFPenalize:|r -EP or +GP, can be changed at any time.</p>
		<p></p>
		<p>|cFFFF3030Loot Council:|r |cFF00CCFFRecord Loot|r</p>
		<br/>
		<h1>Create A New Raid Log Entry Using Float Buttons</h1>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\raid_log_entries_3.tga" height="64" align="center"/>
		<p>|cFF00CCFFLeft-click|r to create a new raid log entry.</p>
		<p>|cFF00CCFFRight-click|r to hide.</p>
		<br/>
		<h1>Edit/Delete A Raid Log Entry</h1>
		<p>|cFFFF3030Edit:|r just click on it!</p>
		<p>|cFFFF3030Delete:|r just click on "×"!</p>
	]],
	["LOOT_DISTRIBUTION_TOOL"] = [[
		<h1>Config</h1>
		<p>|cFFFF3030You still need to distribute loot through loot window.</p>
		<p>|cFF00CCFFConfig > Loot Distr|r</p>
		<p>|cFFFF3030Set quick note buttons (up to 5)|r, these buttons will show when you click |cFF00CCFFNote|r.</p>
		<p>|cFFFF3030Set reply buttons (up to 7, loot master only)|r, |cFF00CCFFNote|r and |cFF00CCFFPass|r buttons are added to the right of the loot frame automatically.</p>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\loot_distr_1.tga" height="256" align="center"/>
		<h1>Loot Frame</h1>
		<p>|cFF00CCFFS:|r socket.</p>
		<p>|cFFFF3030Red ilvl background:|r Warforged or Titanforged.</p>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\loot_distr_2.tga" height="128" align="center"/>
		<br/>
		<h1>Distribution Frame</h1>
		<p>This frame will show automatically if you're loot master.</p>
		<p>Actually, anyone can access this frame through this command: |cFF00CCFF/gra loot|r.</p>
		<img src="Interface\AddOns\GuildRaidAttendance\Media\Help\loot_distr_3.tga" height="256" align="center"/>
	]],
	["SLASH_COMMANDS"] = [[
		<h1>Slash Commands</h1>
		<p>|cFF00CCFF/gra|r: show GRA main frame.</p>
		<p>|cFF00CCFF/gra anchor|r: show/hide GRA popups anchor.</p>
		<p>|cFF00CCFF/gra exportlocale|r: view localized strings.</p>
		<p>|cFF00CCFF/gra minimap|r: show/hide GRA minimap icon.</p>
		<p>|cFF00CCFF/gra loot|r: show GRA distribution frame.</p>
		<p>|cFF00CCFF/gra resetposition|r: reset the position of GRA main frame to center.</p>
		<p>|cFF00CCFF/gra resetscale|r: reset the scale of GRA frames to their defaults.</p>
	]],
	["r80-beta"] = [[
		<h1>Sorry for the late update.</h1>
		<p>It is highly recommended that you reset all GRA data before using it.</p>
		<p>(Config > Profile > Reset Current Profile)</p>
		<br/>
		<h1>About The Next Version</h1>
		<p>r81-release will be released before Uldir.</p>
		<p>EPGP, DKP will be removed.</p>
		<p>Record Loot may be removed. If you want to keep it, tell me.</p>
		<p>The new PLoot Helper will be just like the former Loot Distribution tool.</p>
		<br/>
		<h1>You can submit a ticket on GitHub or send me an email to do a Feature Request/Bug Report.</h1>
		<h1>Thank you :)</h1>
	]],
}, {
	__index = function(self, Key)
		if (Key ~= nil) then
			rawset(self, Key, Key)
			return Key
		end
	end
})