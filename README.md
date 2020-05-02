# ClassicHealAssignments
ClassicHealAssignments is a raid assignment helper for WoW Classic allowing players to quickly give healers and dispellers assignments using an in-game interface.

## Features
* Quickly assign healers to tanks or the raid using a graphical interface.
* Announce healing assignments in whispers or any channel you want.
* Automatically respond with healing assignments when players whisper you "heal"
* Create assignments ahead of time and save them for later loading.

## How to use
The ClassicHealAssignments GUI can be opened by typing /heal in game or by clicking the minimap button.  The GUI is only populated with data when the player is in a raid.

The GUI consists for 4 essential components: 
* The list of healers. This list gives the user a quick overview of healers in the raid, their classes, and whether or not they are assigned to anyone. Assigned healers will have an (X) next to their name.
* The Assignments section. This section contains all valid assignments and their assignees.
* The preset component. This allows you to assign players ahead of time and save the preset for later loading. Loading a template is done by clicking the template in the list of saved templates.
* The announcement component. Here you can set which channels to announce assignments to when clicking the 'Announce assignments' button.

By default only two potential assignment targets exist: RAID, and DISPELS. In order to assign healers to tanks, mark players as Main Tank in the Blizzard raid UI. The frame will automatically populate with tanks as they are assigned. Assignments are done by opening the dropdown by the assignment and selecting all players that should be assigned to the target. It is possible to assign players to multiple targets.

ClassicHealAssignments considers any Paladin, Priest, Druid, or Shaman to be a valid healer. In addition to the valid healers, mages are considered to be valid dispellers and can be assigned to DISPELS.
