local Camera = workspace.CurrentCamera

local FOVChanger = {}
FOVChanger.Enabled = false
FOVChanger.Value = 70
FOVChanger.DefaultValue = 70

function FOVChanger:Toggle(state)
    self.Enabled = state
    if state then
        Camera.FieldOfView = self.Value
    else
        Camera.FieldOfView = self.DefaultValue
    end
end

function FOVChanger:SetValue(val)
    self.Value = val
    if self.Enabled then
        Camera.FieldOfView = self.Value
    end
end

return FOVChanger
