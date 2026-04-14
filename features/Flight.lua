local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Flight = {}
Flight.Enabled = false
Flight.Speed = 50
Flight.Connection = nil

local function updateFlight()
    if not Flight.Enabled then return end
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    local flyVel = hrp:FindFirstChild("FlyVelocity")
    local flyGyro = hrp:FindFirstChild("FlyGyro")
    
    if flyVel and flyGyro then
        local moveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + Camera.CFrame.LookVector * Flight.Speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - Camera.CFrame.LookVector * Flight.Speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - Camera.CFrame.RightVector * Flight.Speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + Camera.CFrame.RightVector * Flight.Speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, Flight.Speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVector = moveVector - Vector3.new(0, Flight.Speed, 0)
        end
        
        flyVel.Velocity = moveVector
        flyGyro.CFrame = Camera.CFrame
    end
end

function Flight:Toggle(state)
    self.Enabled = state
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if state then
        if humanoid then humanoid.PlatformStand = true end
        
        local flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Name = "FlyVelocity"
        flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = hrp
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.Name = "FlyGyro"
        bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyGyro.P = 10000
        bodyGyro.CFrame = hrp.CFrame
        bodyGyro.Parent = hrp

        self.Connection = RunService.RenderStepped:Connect(updateFlight)
    else
        if humanoid then humanoid.PlatformStand = false end
        if hrp:FindFirstChild("FlyVelocity") then hrp.FlyVelocity:Destroy() end
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        if self.Connection then self.Connection:Disconnect(); self.Connection = nil end
    end
end

return Flight
