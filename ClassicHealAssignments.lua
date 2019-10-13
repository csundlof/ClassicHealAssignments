require("utils.table")

local ClassicHealAssignments = LibStub("AceAddon-3.0"):NewAddon("ClassicHealAssignments", "AceConsole-3.0", "AceEvent-3.0");
local AceGUI = LibStub("AceGUI-3.0")
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local mainWindow = AceGUI:Create("Frame")
mainWindow:SetTitle("Classic Heal Assignments")
mainWindow:SetStatusText("Classic Heal Assignments")
mainWindow:SetLayout("Flow")
mainWindow:SetWidth("1000")

local healerGroup = AceGUI:Create("InlineGroup")
healerGroup:SetTitle("Healers")
healerGroup:SetWidth(80)
healerGroup:SetFullHeight(true)
mainWindow:AddChild(healerGroup)

local announceButton = AceGUI:Create("Button")
announceButton:SetText("Announce assignments")
announceButton:SetCallback("OnClick", function() AnnounceHealers() end)
mainWindow:AddChild(announceButton)

local playerFrames = {}

local assignmentGroups = {}

local assignedHealers = {}

local debug = false

if not debug then
   mainWindow:Hide()
end

local classes = {}
local roles = {}

local healerColors = {["Druid"] = {1.00, 0.49, 0.04}, ["Priest"] = {1.00, 1.00, 1.00}, ["Paladin"] = {0.96, 0.55, 0.73}, ["Shaman"] = {0.96, 0.55, 0.73}}

function ClassicHealAssignments:OnInitialize()
      -- Called when the addon is loaded

      -- Print a message to the chat frame
      self:Print("OnInitialize Event Fired: Hello")
end


function ClassicHealAssignments:OnEnable()
      -- Called when the addon is enabled

      -- Print a message to the chat frame
      self:Print("OnEnable Event Fired: Hello, again ;)")
      UpdateFrame()
end


function ClassicHealAssignments:OnDisable()
      -- Called when the addon is disabled
end


ClassicHealAssignments:RegisterChatCommand("heal", "ShowFrame")


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

   --AnnounceHealers()
end


function UpdateFrame()
   if debug then
      print("\n-----------\nUPDATE")
   end
   local roles = {}
   roles["DISPELS"] = {"DISPELS"}
   roles["RAID"] = {"RAID"}
   local classes = {}
   local dispellerList = {}

   for i=1, MAX_RAID_MEMBERS do
      local name, _, _, _, class, _, _, _, _, role, _, _ = GetRaidRosterInfo(i);
      if name then
         if not classes[class] then
            classes[class] = {}
         end
         if role ~= nil and not roles[role] then
            roles[role] = {}
         end

         print(role)

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

   local healerList = {}

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
         tinsert(dispellerList, player)
      end
   end

   for role, players in pairs(roles) do
      if role == "MAINTANK" then
         for _, player in ipairs(players) do
            CreateAssignmentGroup(player, healerList)
            print(player)
         end
      elseif role == "RAID" then
         CreateAssignmentGroup("RAID", healerList)
      elseif role == "DISPELS" then
         CreateAssignmentGroup("DISPELS", dispellerList)
      end
   end
end


function AssignHealer(widget, event, key, checked, healerList)
   local target = widget:GetUserData("target")
   if not assignedHealers[target] then
      assignedHealers[target] = {}
      print("creating assigned healers dict")
   end
   if checked then
      print("assigning " .. healerList[key] .. " to " .. target)
      tinsert(assignedHealers[target], healerList[key])
   else
      local healerIndex = table.indexOf(assignedHealers[target], healerList[key])
      tremove(assignedHealers[target], healerIndex)
   end
end


function CreateHealerDropdown(healers)
   local dropdown = AceGUI:Create("Dropdown")
   dropdown:SetList(healers)
   dropdown:SetText("Assign healer")
   dropdown:SetFullWidth(true)
   dropdown:SetMultiselect(true)
   return dropdown
end


function AnnounceHealers()
   if debug then
      print("\n-----------\nASSIGNMENTS")
   end
   SendChatMessage("Healing assignments", "RAID", nil)
   for target, healers in pairs(assignedHealers) do
      if healers ~= nil then
         local assignment = target ..': ' .. table.concat(healers, ", ")
         if debug then
            print(assignment)
         end
         SendChatMessage(assignment, "RAID", nil)
      end
   end
end


function CreateAssignmentGroup(assignment, playerList)
   local nameframe = AceGUI:Create("InlineGroup")
   nameframe:SetTitle(assignment)
   nameframe:SetWidth(140)
   assignmentGroups[assignment] = nameframe
   mainWindow:AddChild(nameframe)
   local dropdown = CreateHealerDropdown(playerList)
   dropdown:SetUserData("target", assignment)
   dropdown:SetCallback("OnValueChanged", function(widget, event, key, checked) AssignHealer(widget, event, key, checked, playerList) end)
   nameframe:AddChild(dropdown)
end