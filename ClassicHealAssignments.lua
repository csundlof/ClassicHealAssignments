local ClassicHealAssignments = LibStub("AceAddon-3.0"):NewAddon("ClassicHealAssignments", "AceConsole-3.0", "AceEvent-3.0");
local AceGUI = LibStub("AceGUI-3.0")
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS

local mainWindow = AceGUI:Create("Frame")
mainWindow:SetTitle("Classic Heal Assignments")
mainWindow:SetStatusText("Classic Heal Assignments")
mainWindow:SetLayout("Flow")

local healerGroup = AceGUI:Create("InlineGroup")
healerGroup:SetTitle("Healers")
healerGroup:SetWidth(80)
healerGroup:SetFullHeight(true)
mainWindow:AddChild(healerGroup)


local playerFrames = {}

local assignmentGroups = {}

local assignedHealers = {}

--frame:Hide()

local classes = {}
local roles = {}

local healers = {["Druid"] = 105, ["Priest"] = 257, ["Paladin"] = 65, ["Shaman"] = 0}


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
	print("\n-----------\nHEAL")
	if mainWindow:IsVisible() then
		mainWindow:Hide()
	else 
		UpdateFrame()
		mainWindow:Show()
	end

	print("\n-----------\nASSIGNMENTS")
	for target, healers in pairs(assignedHealers) do
		print("TANK: " .. target .. " HEALERS: ")
		for _, healer in ipairs(healers) do
			print(" " .. healer)
		end
	end
end


function UpdateFrame()
	print("\n-----------\nUPDATE")
	roles = {}
	classes = {}
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
				print(name .. " was added")
				tinsert(classes[class], name)
				if role ~= nil then
					tinsert(roles[role], name)
				end
			end
		end
	end
	
	for class, players in pairs(classes) do
		if healers[class] ~= nil then
			for _, player in ipairs(players) do
				if playerFrames[player] == nil then
					local nameframe = AceGUI:Create("InteractiveLabel")
					--nameframe:SetHeight(12)
					nameframe:SetRelativeWidth(1)
					nameframe:SetText(player)
					nameframe:SetImage("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES", unpack({0.7421875, 0.98828125, 0, 0.25}))
					nameframe:SetImageSize(12, 12)
					nameframe:SetColor(1.00, 0.49, 0.04)
					nameframe:SetCallback("OnClick", function() print("hello") end)
					playerFrames[player] = nameframe
					healerGroup:AddChild(nameframe)
				end
				print(player)
			end
		end
	end

	for role, players in pairs(roles) do
		if role == "MAINTANK" then
			for _, player in ipairs(players) do
				if assignmentGroups[player] == nil then
					local nameframe = AceGUI:Create("InlineGroup")
					--nameframe:SetHeight(12)
					nameframe:SetTitle(player)
					nameframe:SetWidth(100)
					--nameframe:SetImage("Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES", unpack({0.7421875, 0.98828125, 0, 0.25}))
					--nameframe:SetImageSize(12, 12)
					--nameframe:SetColor(1.00, 0.49, 0.04)
					--nameframe:SetCallback("OnClick", function() print("hello") end)
					assignmentGroups[player] = nameframe
					mainWindow:AddChild(nameframe)
					for x=1, 5 do
						local editbox = AceGUI:Create("EditBox")
						editbox:SetText("Healer " .. x)
						editbox:DisableButton(true)
						editbox:SetRelativeWidth(1)
						editbox:SetUserData("target", player)
						editbox:SetCallback("OnEnterPressed", function(widget, event, text) AssignHealer(widget, event, text) end)
						nameframe:AddChild(editbox)
					end
				end
				print(player)
			end
		end
	end
end


function AssignHealer(widget, event, text)
	-- need to unassign healer from previous target as part of this
	local target = widget:GetUserData("target")
	if not assignedHealers[target] then
		assignedHealers[target] = {}
		print("creating assigned healers dict")
	end
	print("assigning " .. text .. " to " .. target)
	tinsert(assignedHealers[target], text)
end