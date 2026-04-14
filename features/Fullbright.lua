local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local Fullbright = {}
Fullbright.Enabled = false
Fullbright.Connection = nil
Fullbright.Originals = {}

local function apply()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 1e9
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
end

function Fullbright:Toggle(state)
    self.Enabled = state
    
    if state then
        -- Save originals
        self.Originals.Brightness = Lighting.Brightness
        self.Originals.ClockTime = Lighting.ClockTime
        self.Originals.FogEnd = Lighting.FogEnd
        self.Originals.GlobalShadows = Lighting.GlobalShadows
        self.Originals.OutdoorAmbient = Lighting.OutdoorAmbient
        
        apply()
        self.Connection = RunService.Heartbeat:Connect(function()
            if self.Enabled then apply() end
        end)
    else
        if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
        -- Restore (simplified)
        if self.Originals.Brightness then
            Lighting.Brightness = self.Originals.Brightness
            Lighting.ClockTime = self.Originals.ClockTime
            Lighting.FogEnd = self.Originals.FogEnd
            Lighting.GlobalShadows = self.Originals.GlobalShadows
            Lighting.OutdoorAmbient = self.Originals.OutdoorAmbient
        end
    end
end

return Fullbright
