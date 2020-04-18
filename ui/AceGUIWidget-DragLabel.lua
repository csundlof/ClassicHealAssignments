--[[-----------------------------------------------------------------------------
DragLabel Custom Widget
-------------------------------------------------------------------------------]]
local Type, Version = "DragLabel", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local select, pairs = select, pairs

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function UpdateImageAnchor(self)
	if self.resizing then return end
	local frame = self.frame
	local width = frame.width or frame:GetWidth() or 0
	local image = self.image
	local label = self.label
	local height

	label:ClearAllPoints()
	image:ClearAllPoints()

	if self.imageshown then
		local imagewidth = image:GetWidth()
		if (width - imagewidth) < 200 or (label:GetText() or "") == "" then
			-- image goes on top centered when less than 200 width for the text, or if there is no text
			image:SetPoint("TOP")
			label:SetPoint("TOP", image, "BOTTOM")
			label:SetPoint("LEFT")
			label:SetWidth(width)
			height = image:GetHeight() + label:GetStringHeight()
		else
			-- image on the left
			image:SetPoint("TOPLEFT")
			if image:GetHeight() > label:GetStringHeight() then
				label:SetPoint("LEFT", image, "RIGHT", 4, 0)
			else
				label:SetPoint("TOPLEFT", image, "TOPRIGHT", 4, 0)
			end
			label:SetWidth(width - imagewidth - 4)
			height = max(image:GetHeight(), label:GetStringHeight())
		end
	else
		-- no image shown
		label:SetPoint("TOPLEFT")
		label:SetWidth(width)
		height = label:GetStringHeight()
	end

	-- avoid zero-height labels, since they can used as spacers
	if not height or height == 0 then
		height = 1
	end

	self.resizing = true
	frame:SetHeight(height)
	frame.height = height
	self.resizing = nil
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Control_OnMouseDown(frame, button)
	frame.obj:Fire("OnMouseDown", button)
   AceGUI:ClearFocus()
end

local function Control_OnMouseUp(frame, button)
	frame.obj:Fire("OnMouseUp", button)
   AceGUI:ClearFocus()
end

local function Control_OnDragStart(frame, button)
	frame.obj:Fire("OnDragStart", button)
   AceGUI:ClearFocus()
end

local function Control_OnDragStop(frame)
	frame.obj:Fire("OnDragStop")
   AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetWidth(200)
      self:SetText()
		self:SetColor()
		self:SetDisabled(false)
	end,
   
   ["OnWidthSet"] = function(self, width)
		UpdateImageAnchor(self)
	end,

   ["SetText"] = function(self, text)
		self.label:SetText(text)
		UpdateImageAnchor(self)
	end,

	["SetColor"] = function(self, r, g, b)
		if not (r and g and b) then
			r, g, b = 1, 1, 1
		end
		self.label:SetVertexColor(r, g, b)
	end,

   ["SetDisabled"] = function(self,disabled)
		self.disabled = disabled
		if disabled then
			self.frame:EnableMouse(false)
			self.label:SetTextColor(0.5, 0.5, 0.5)
		else
			self.frame:EnableMouse(true)
			self.label:SetTextColor(1, 1, 1)
		end
	end
}
--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
   local frame = CreateFrame("Frame", nil, UIParent)
   frame:Hide()

   frame:SetMovable(true)
   frame:EnableMouse(true)
   frame:RegisterForDrag("LeftButton")

   local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	local image = frame:CreateTexture(nil, "BACKGROUND")

	-- create widget
	local widget = {
		label = label,
		image = image,
		frame = frame,
		type  = Type
	}

   frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnMouseDown", Control_OnMouseDown)
   frame:SetScript("OnMouseUp", Control_OnMouseUp)
	frame:SetScript("OnDragStart", Control_OnDragStart)
   frame:SetScript("OnDragStop", Control_OnDragStop)

   for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)

--	local frame = label.frame
--	frame:EnableMouse(true)

	--local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	--highlight:SetTexture(nil)
	--highlight:SetAllPoints()
	--highlight:SetBlendMode("ADD")

	--label.highlight = highlight
	--label.type = Type
	--label.LabelOnAcquire = label.OnAcquire
	--for method, func in pairs(methods) do
	--	label[method] = func
	--end
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)