-- function to load in custom widget layouts for AceGUI
local AceGUI = LibStub("AceGUI-3.0")


function uiRegisterCustomLayouts() 
   AceGUI:RegisterLayout("mainWindowLayout",

   function(content, children)
      for i = 1, #children do
            local child = children[i]
            local frame = child.frame
            
        if child:GetUserData("name") ~= nil then
            if child:GetUserData("name") == "healerGroup" then 
               child:SetPoint("TOPLEFT",content,"TOPLEFT",0,0)
            elseif child:GetUserData("name") == "assignmentWindow" then
               child:SetPoint("TOPLEFT",content,"TOPLEFT",100,0)
               child:SetPoint("TOPRIGHT", content, "TOPRIGHT", -175, 0)
            elseif child:GetUserData("name") == "presetMaster" then
               child:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, 0)
            elseif child:GetUserData("name") == "announceMaster" then
               child:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -122,-28)
            end
         end
      end
   end)

   AceGUI:RegisterLayout("AnnouncementsPane",
      function(content, children)
         for i = 1, #children do
            local child = children[i]
            local frame = child.frame
      
            if child:GetUserData("name") ~= nil then
               if child:GetUserData("name") == "dropdown" then 
                  child:SetPoint("TOP",content,"TOP", 0, 5)
               elseif child:GetUserData("name") == "announceButton" then
                  child:SetPoint("TOP",content,"BOTTOM",0,25)
            end
         end
      end
   end)
end