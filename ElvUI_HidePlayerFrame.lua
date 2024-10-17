local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, ns = ...

local HidePlayerFrame = E:NewModule("HidePlayerFrame", "AceEvent-3.0")

-- Default options
P["HidePlayerFrame"] = {
    enabled = true,
}

-- Module initialization
function HidePlayerFrame:Initialize()
    -- Initialize the database
    self.db = E.db.HidePlayerFrame
    
    -- Register plugin with ElvUI
    EP:RegisterPlugin(addon, self.InsertOptions)
    
    -- Register events
    self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdatePlayerFrame")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdatePlayerFrame")
    self:RegisterEvent("UNIT_EXITED_VEHICLE", "UpdatePlayerFrame")
    self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UpdatePlayerFrame")
    
    -- Hook into ElvUI's UF update function
    if ElvUF and ElvUF.units and ElvUF.units.player then
        hooksecurefunc(ElvUF.units.player, "Update", function() self:UpdatePlayerFrame() end)
    end
    
    -- Initial update
    self:UpdatePlayerFrame()
end

-- Function to update player frame visibility
function HidePlayerFrame:UpdatePlayerFrame()
    if not E.private.unitframe.enable then return end
    
    local playerFrame = _G["ElvUF_Player"]
    if not playerFrame then return end
    
    if self.db.enabled and (IsInGroup() or IsInRaid()) and not UnitHasVehicleUI("player") then
        playerFrame:Hide()
    else
        playerFrame:Show()
    end
end

-- Options table
function HidePlayerFrame:InsertOptions()
    E.Options.args.HidePlayerFrame = {
        order = 100,
        type = "group",
        name = "Hide Player Frame",
        args = {
            enabled = {
                order = 1,
                type = "toggle",
                name = "Enable",
                desc = "Enable hiding player frame in party/raid",
                get = function(info) return E.db.HidePlayerFrame.enabled end,
                set = function(info, value)
                    E.db.HidePlayerFrame.enabled = value
                    HidePlayerFrame:UpdatePlayerFrame()
                end,
            },
        },
    }
end

-- Initialize the module
E:RegisterModule(HidePlayerFrame:GetName())