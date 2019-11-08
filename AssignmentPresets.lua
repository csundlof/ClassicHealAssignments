-- Contains functions to generate a container with accompanying set of buttons in a given frame
-- to save the current state of the healer assignments and load them via onclick functions

local AceGUI = LibStub("AceGUI-3.0")

-- variables to store presets
local presetList = {}
local presetFrames = {}
local presetStore = "Default"
local presetEditBoxText = "Preset Name"

-- Sets up the Save & Delete buttons as well as the preset container; loads components onto the frame
function AssignmentPresetsSetupFrameContainers(frame)
   -- places preset container inside of main frame
   presetMaster = AceGUI:Create("SimpleGroup")
   presetMaster:SetWidth(160)
   frame:AddChild(presetMaster)

   -- holds all of the preset frames
   presetGroup = AceGUI:Create("InlineGroup")
   presetGroup:SetRelativeWidth(1)
   presetGroup:SetTitle("Presets")
   presetMaster:AddChild(presetGroup)

   -- saves the state of all healer assignments
   local savestateButton = AceGUI:Create("Button")
   savestateButton:SetText("Save")
   savestateButton:SetRelativeWidth(1)
   savestateButton:SetCallback("OnClick", function () SaveState(presetStore) end)
   presetMaster:AddChild(savestateButton)

   -- deletes the currently selected preset
   local deletestateButton = AceGUI:Create("Button")
   deletestateButton:SetText("Delete")
   deletestateButton:SetRelativeWidth(1)
   deletestateButton:SetCallback("OnClick", function() DeleteState(presetStore) end)
   presetMaster:AddChild(deletestateButton)
   
   -- text box to hold the preset name
   savestateNameBox = AceGUI:Create("EditBox")
   savestateNameBox:SetRelativeWidth(1)
   savestateNameBox:SetLabel("Preset Name")
   savestateNameBox:SetText(presetEditBoxText)
   savestateNameBox:SetCallback("OnEnterPressed", function(widget, event, text) presetStore = text end)
   presetMaster:AddChild(savestateNameBox)
end

-- add preset names to container
function AssignmentPresetsUpdatePresets()
   if presetList ~= nil then
      for presetName, assignments in pairs(presetList) do 
         if presetFrames[presetName] == nil then
               local nameframe = AceGUI:Create("InteractiveLabel")
               nameframe:SetRelativeWidth(1)
               nameframe:SetText(presetName)
            nameframe:SetHighlight(10, 145, 100)
            nameframe:SetCallback("OnClick", function() LoadState(presetName) end)
               presetFrames[presetName] = nameframe
            presetGroup:AddChild(nameframe)
         end
      end
   end
end

-- called during CleanupFrames() in main
function AssignmentPresetsCleanup()
   presetFrames = {}
end

-- Saves the current status of healers & their target
function SaveState(name)
   if debug then
      print("\n-----------\nSAVESTATE")
   end

   presetEditBoxText = name
   presetList[name] = {}
   presetList[name] = CopyArray(assignedHealers)

   CleanupFrame()
    SetupFrameContainers()
    UpdateFrame()
end

--Loads the state saved under the preset list
function LoadState(name)
   if debug then
      print("\n-----------\nLOADSTATE")
   end

   presetEditBoxText = name
   presetStore = name
   assignedHealers = {}
   assignedHealers = CopyArray(presetList[name])
   CleanupFrame()
    SetupFrameContainers()
    UpdateFrame()
end

-- deletes the preset with the current name in the edit text box
function DeleteState(name)
   if debug then
      print("\n-----------\nDELETESTATE")
   end
   presetList[name] = nil
   CleanupFrame()
   SetupFrameContainers()
   UpdateFrame()
end

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