local ClassicHealAssignments = LibStub("AceAddon-3.0"):NewAddon("ClassicHealAssignments", "AceConsole-3.0", "AceEvent-3.0");
local AceGUI = LibStub("AceGUI-3.0")
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local playerFrames = {}

local assignmentGroups = {}

local assignedHealers = {}

local classes = {}
local roles = {}

local healerColors = {["Druid"] = {1.00, 0.49, 0.04}, ["Priest"] = {1.00, 1.00, 1.00}, ["Paladin"] = {0.96, 0.55, 0.73}, ["Shaman"] = {0.96, 0.55, 0.73}}

local defaultChannels = {"SAY", "PARTY", "GUILD", "OFFICER", "YELL", "RAID", "RAID_WARNING"}
local activeChannels = {}
local channelDropdown = nil
local selectedChannels = {["RAID"] = "default"}

function ClassicHealAssignments:OnInitialize()
      ClassicHealAssignments:RegisterChatCommand("heal", "ShowFrame")
end


function ClassicHealAssignments:OnEnable()
      UpdateChannels()
      SetupFrame()
      SetupFrameContainers()
      UpdateFrame()
      RegisterEvents()

      debug = false

      if not debug then
         mainWindow:Hide()
      end
end


function ClassicHealAssignments:OnDisable()
end


function RegisterEvents()
   -- Listen for changes in raid roster
   ClassicHealAssignments:RegisterEvent("CHANNEL_UI_UPDATE", "HandleChannelUpdate")
   ClassicHealAssignments:RegisterEvent("GROUP_ROSTER_UPDATE", "HandleRosterChange")
end


function ClassicHealAssignments:ShowFrame(input)
   if debug then
      print("\n-----------\nHEAL")
   end
   if mainWindow:IsVisible() then
      mainWindow:Hide()
   else
      UpdateFrame()
      mainWindow:Show()
   end
end


function UpdateFrame()
   if debug then
      print("\n-----------\nUPDATE")
   end
   local roles = {}
   local classes = {}
   local dispellerList = {}
   local healerList = {}

   classes, roles = GetRaidRoster()

   roles["DISPELS"] = {"DISPELS"}
   roles["RAID"] = {"RAID"}

   for class, players in pairs(classes) do
      if healerColors[class] ~= nil then
         for _, player in ipairs(players) do
            if playerFrames[player] == nil then
               local nameframe = AceGUI:Create("InteractiveLabel")
               nameframe:SetRelativeWidth(1)
               nameframe:SetText(player)
               local classColors = healerColors[class]
               nameframe:SetColor(classColors[1], classColors[2], classColors[3])
               playerFrames[player] = nameframe
               healerGroup:AddChild(nameframe)
            end
            tinsert(healerList, player)
            tinsert(dispellerList, player)
            if debug then
               print(player)
            end
         end
      elseif class == "Mage" then
         for _, player in ipairs(players) do
            tinsert(dispellerList, player)
         end
      end
   end

   for role, players in pairs(roles) do
      if role == "MAINTANK" then
         for _, player in ipairs(players) do
            if assignmentGroups[player] == nil then
               CreateAssignmentGroup(player, healerList)
            end
            if debug then
               print(player)
            end
         end
      elseif role == "RAID" then
         if assignmentGroups[role] == nil then
            CreateAssignmentGroup("RAID", healerList)
         end
      elseif role == "DISPELS" then
         if assignmentGroups[role] == nil then
            CreateAssignmentGroup("DISPELS", dispellerList)
         end
      end
   end

   -- calling twice to avoid inconsistencies between re-renders
   mainWindow:DoLayout()
   mainWindow:DoLayout()
end


function AssignHealer(widget, event, key, checked, healerList)
   local target = widget:GetUserData("target")
   if not assignedHealers[target] then
      assignedHealers[target] = {}
      if debug then
         print("creating assigned healers dict")
      end
   end
   if checked then
      if debug then
         print("assigning " .. healerList[key] .. " to " .. target)
      end
      tinsert(assignedHealers[target], healerList[key])
   else
      local healerIndex = table.indexOf(assignedHealers[target], healerList[key])
      tremove(assignedHealers[target], healerIndex)
   end
end


function CreateHealerDropdown(healers, assignment)
   local dropdown = AceGUI:Create("Dropdown")
   dropdown:SetList(healers)
   dropdown:SetText("Assign healer")
   dropdown:SetFullWidth(true)
   dropdown:SetMultiselect(true)
   if assignedHealers[assignment] ~= nil then
      for _,v in ipairs(assignedHealers[assignment]) do
         dropdown:SetItemValue(table.indexOf(healers, v), true)
      end
   end
   return dropdown
end


function AnnounceHealers()
   if debug then
      print("\n-----------\nASSIGNMENTS")
   end
   AnnounceAssignments("Healing Assignments")
   for target, healers in pairs(assignedHealers) do
      if healers ~= nil then
         local assignment = target ..': ' .. table.concat(healers, ", ")
         if debug then
            print(assignment)
         end
         AnnounceAssignments(assignment)
      end
   end
end


function CreateAssignmentGroup(assignment, playerList)
   local nameframe = AceGUI:Create("InlineGroup")
   nameframe:SetTitle(assignment)
   nameframe:SetWidth(140)
   assignmentGroups[assignment] = nameframe
   assignmentWindow:AddChild(nameframe)
   local dropdown = CreateHealerDropdown(playerList, assignment)
   dropdown:SetUserData("target", assignment)
   dropdown:SetCallback("OnValueChanged", function(widget, event, key, checked) AssignHealer(widget, event, key, checked, playerList) end)
   nameframe:AddChild(dropdown)
end


function ClassicHealAssignments:HandleRosterChange()
   if IsInRaid() then
      CleanupFrame()
      SetupFrameContainers()
      UpdateFrame()
   end
end


function SelectChannel(widget, event, key, checked)
   local channels = GetAllChannelNames()
   local s = channels[key]
   if checked then
      if key <= #defaultChannels then
         selectedChannels[s] = "default"
      else
         selectedChannels[s] = activeChannels[s]
      end
   else
      selectedChannels[s] = nil
   end

   if debug then
      print("Selected channels:")
      for ch, id in pairs(selectedChannels) do
         print("ch="..ch.." id="..id)
      end
   end
end


function CreateChannelDropdown()
   local dropdown = AceGUI:Create("Dropdown")
   local channels = GetAllChannelNames()
   dropdown:SetList(channels)
   dropdown:SetLabel("Announcement channels")
   dropdown:SetText("Select channels")
   dropdown:SetWidth(100)
   dropdown:SetMultiselect(true)
   dropdown:SetCallback("OnValueChanged", function(widget, event, key, checked) SelectChannel(widget, event, key, checked) end)
   return dropdown
end


-- Sends MSG to preselected channels
function AnnounceAssignments(msg)
   for ch, id in pairs(selectedChannels) do
      if id == "default" then
         SendChatMessage(msg, ch, nil)
      else
         SendChatMessage(msg, "CHANNEL", nil, id)
      end
   end
end


function UpdateChannels()
   activeChannels = {}
   local channels = {GetChannelList()} --returns triads of values: id,name,disabled
   local blizzChannels = {EnumerateServerChannels()}
   for i = 1, table.getn(channels), 3 do
      local id, name = GetChannelName(channels[i])
      if name ~= nil then
         local prunedName = string.match(name, "(%w+)") --filter out blizzard channels
         if not tContains(blizzChannels, prunedName) then
            activeChannels[name] = id
         end
      else --only cleans selectedChannels if the channel name was removed from the list
        if selectedChannels[name] ~= nil then
            selectedChannels[name] = nil
        end
      end

   end
end


function GetAllChannelNames()
   local names = {}
   table.merge(names, defaultChannels)
   table.merge(names, table.getKeys(activeChannels))
   return names
end


function ClassicHealAssignments:HandleChannelUpdate()
   UpdateChannels()
   if debug then
      print(unpack(selectedChannels))
   end
   if channelDropdown ~= nil then
      local channels = GetAllChannelNames()
      channelDropdown:SetList(channels)
   end
end


function CleanupFrame()
   _, roles = GetRaidRoster()

   -- unassign healers from assignment targets that have been unchecked
   for assignment, assignmentFrame in pairs(assignmentGroups) do
      if assignment ~= "RAID" and assignment ~= "DISPELS" and (roles["MAINTANK"] == nil or not tContains(roles["MAINTANK"], assignment)) then
         assignedHealers[assignment] = nil
      end
   end

   assignmentGroups = {}
   playerFrames = {}
   mainWindow:ReleaseChildren()
end


function SetupFrame()
   mainWindow = AceGUI:Create("Frame")
   mainWindow:SetTitle("Classic Heal Assignments")
   mainWindow:SetStatusText("Classic Heal Assignments")
   mainWindow:SetLayout("Flow")
   mainWindow:SetWidth("1000")
end


function SetupFrameContainers()
   healerGroup = AceGUI:Create("InlineGroup")
   healerGroup:SetTitle("Healers")
   healerGroup:SetWidth(80)
   mainWindow:AddChild(healerGroup)

   assignmentWindow = AceGUI:Create("InlineGroup")
   assignmentWindow:SetTitle("Assignments")
   assignmentWindow:SetRelativeWidth(0.9)
   assignmentWindow:SetLayout("Flow")
   mainWindow:AddChild(assignmentWindow)

   local announceButton = AceGUI:Create("Button")
   announceButton:SetText("Announce assignments")
   announceButton:SetCallback("OnClick", function() AnnounceHealers() end)
   mainWindow:AddChild(announceButton)

   channelDropdown = CreateChannelDropdown()
   mainWindow:AddChild(channelDropdown)
end


function GetRaidRoster()
   local classes = {}
   local roles = {}

   for i=1, MAX_RAID_MEMBERS do
      local name, _, _, _, class, _, _, _, _, role, _, _ = GetRaidRosterInfo(i);
      if name then
         if not classes[class] then
            classes[class] = {}
         end
         if role ~= nil and not roles[role] then
            roles[role] = {}
         end

         if debug then
            print(role)
         end

         if not tContains(classes[class], name) then
            if debug then
               print(name .. " was added")
            end
            tinsert(classes[class], name)
            if role ~= nil then
               tinsert(roles[role], name)
            end
         end
      end
   end

   return classes, roles
end
