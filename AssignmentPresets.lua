-- Contains functions to generate a container with accompanying set of buttons in a given frame
-- to save the current state of the healer assignments and load them via onclick functions

local AceGUI = LibStub("AceGUI-3.0")

-- variables to store presets
local presetList = {}
local presetListReverse = {}

local presetFrames = {}
local selectedPreset = "Default"
local presetEditBoxText = "Preset Name"

-- Sets up the Save & Delete buttons as well as the preset container; loads components onto the frame
function AssignmentPresetsSetupFrameContainers(frame)
   -- places preset container inside of main frame
   presetMaster = AceGUI:Create("SimpleGroup")
   presetMaster:SetWidth(160)
   presetMaster:SetUserData("name", "presetMaster")
   frame:AddChild(presetMaster)

   -- holds all of the preset frames
   presetGroup = AceGUI:Create("InlineGroup")
   presetGroup:SetRelativeWidth(1)
   presetGroup:SetTitle("Presets")
   presetMaster:AddChild(presetGroup)

   -- saves the state of all healer assignments
   local savePresetButton = AceGUI:Create("Button")
   savePresetButton:SetText("Save")
   savePresetButton:SetRelativeWidth(1)
   savePresetButton:SetCallback("OnClick", function () SavePreset(selectedPreset) end)
   presetMaster:AddChild(savePresetButton)

   -- deletes the currently selected preset
   local deletePresetButton = AceGUI:Create("Button")
   deletePresetButton:SetText("Delete")
   deletePresetButton:SetRelativeWidth(1)
   deletePresetButton:SetCallback("OnClick", function() DeletePreset(selectedPreset) end)
   presetMaster:AddChild(deletePresetButton)
   
   -- text box to hold the preset name
   presetNameBox = AceGUI:Create("EditBox")
   presetNameBox:SetRelativeWidth(1)
   presetNameBox:SetLabel("Preset Name")
   presetNameBox:SetText(presetEditBoxText)
   presetNameBox:SetCallback("OnEnterPressed", function(widget, event, text) selectedPreset = text end)
   presetMaster:AddChild(presetNameBox)
end


-- add preset names to container
function AssignmentPresetsUpdatePresets()
   if presetList ~= nil then
      for presetName, assignments in pairs(presetList) do 
         if presetFrames[presetName] == nil then
            local nameFrame = AceGUI:Create("InteractiveLabel")
            nameFrame:SetRelativeWidth(1)
            nameFrame:SetText(presetName)
            nameFrame:SetHighlight(10, 145, 100)
            nameFrame:SetCallback("OnClick", function() LoadPreset(presetName) end)
            presetFrames[presetName] = nameFrame
            presetGroup:AddChild(nameFrame)
         end
      end
   end
end


-- called during CleanupFrames() in main
function AssignmentPresetsCleanup()
   presetFrames = {}
end


-- Saves the current status of healers & their target
function SavePreset(name)
   DebugPrint("\n-----------\nSavePreset")

   presetEditBoxText = name
   presetList[name] = {}
   presetList[name] = CopyArray(assignedHealers)

   presetListReverse[name] = {}
   presetListReverse[name] = CopyArray(reverseAssignments)

   CleanupFrame()
   SetupFrameContainers()
   UpdateFrame()
end


--  Loads the state saved under the preset list
function LoadPreset(name)
   DebugPrint("\n-----------\nLoadPreset")

   presetEditBoxText = name
   selectedPreset = name

   assignedHealers = {}
   assignedHealers = CopyArray(presetList[name])

   reverseAssignments = {}
   reverseAssignments = CopyArray(presetListReverse[name])

   CleanupFrame()
   SetupFrameContainers()
   UpdateFrame()
end


-- deletes the preset with the current name in the edit text box
function DeletePreset(name)
   DebugPrint("\n-----------\nDeletePreset")
   presetList[name] = nil
   CleanupFrame()
   SetupFrameContainers()
   UpdateFrame()
end


-- TODO #14: make this generic and move into table.lua
function CopyArray(array)
   local copyTargets = {}
   for target, healers in pairs(array) do
      local copyHealers = {}
      for i, players in ipairs(healers) do 
         copyHealers[i] = players 
      end
      copyTargets[target] = copyHealers
   end

   return copyTargets
end