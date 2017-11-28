# **Guild Raid Attendance**

This addon keeps track of raid loot and attendance for guild. Support **Loot Council** and **EPGP** (built-in EPGP module).

Please leave me a pm on curseforge if you want to help with the localization.</br>
[Submit a ticket](https://wow.curseforge.com/projects/guild-raid-attendance/issues), let me know what you need or what bugs you've found.

## Features

- **Compact attendance sheet:** simple and clear interface!
- **Build-in EPGP module:** No need to install other EPGP addon. Disabled by default, you can enable it at any time.
- **Completely in game:** Like QDKP addon, it stores EP/GP points in officer notes. Even if you don't use EPGP, you can also record raid loots and attendances with this addon.
- **Communication:** You can easily send raid attendances, loots and EPGP to raid members with this addon.

## Slash Commands

- **/gra** show GuildRaidAttendance.
- **/gra resetposition** reset GuildRaidAttendance frame position to center.

## Guide (Admin)

1. **Assign admin:** **In order to use GRA, your guild must have a GRA admin.**  
Add a newline for example: **#GRA:Archimonde** or multiple admins **#GRA:Archimonde,Sageras** to **guild information** (no spaces).

2. **Import members:** ***Config > Import*** to select your raid members.

3. **Init/Set EPGP (if your guild use EPGP):** ***Config > EPGP Options > Enable EPGP***. Auto decay is CURRENTLY not available, you have to do it manually.

4. **Set raid days:** ***Config > Attendance Sheet***, select raid days depending on your raid schedule. This also attendance sheet columns.

5. **Set raid start time:** ***Config > Attendance Sheet***, set raid start time for your team members. This time is used to check whether members are late or not. You can also set different times for each day.

6. After all above, you can get into raid instance. Start tracking raids by accepting ***Track This Raid*** dialog. And don't forget to send roster data to your raid members, or their GRA will show nothing.

## About raid log function

- **Manually add raids:** ***Raid Logs > New Raid Log*** then select date to add. After that, you can edit attendances of that day in ***Attendance Editor***.

- **Manually edit attendance:** ***Raid Logs > Attendance Editor***.</br>To change attendance, double click the gird in second column.</br>You can also edit the reason for each absentee, or edit the join time for each attendees. Just don't forget to press ***OK*** and ***Save All Changes*** when you're done.

- **Send raid logs data:** Select raid logs in the list, then click ***Send To Raid***. You can use ***Ctrl*** or ***Shift*** to do multiple selection.