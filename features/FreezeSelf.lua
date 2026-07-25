local LocalPlayer = game:GetService("Players").LocalPlayer

local frozenCF = nil
local frozenHRP = nil
local frozenConn = nil

local function enableFreeze()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    frozenHRP = hrp
    frozenCF  = hrp.CFrame
    hrp.Anchored = true
    frozenConn = game:GetService("RunService").Stepped:Connect(function()
        if not getgenv().freezeSelfEnabled or not getgenv().scriptEnabled then return end
        if frozenHRP and frozenHRP.Parent then
            frozenHRP.CFrame = frozenCF
        end
    end)
end

local function disableFreeze()
    getgenv().freezeSelfEnabled = false
    if frozenConn then frozenConn:Disconnect(); frozenConn = nil end
    if frozenHRP and frozenHRP.Parent then
        frozenHRP.Anchored = false
    end
    frozenHRP = nil; frozenCF = nil
end

getgenv().FreezeSelfButton.MouseButton1Click:Connect(function()
    if not getgenv().scriptEnabled then return end
    getgenv().freezeSelfEnabled = not getgenv().freezeSelfEnabled
    getgenv().FreezeSelfButton.Text = "Freeze Self: " .. (getgenv().freezeSelfEnabled and "ON" or "OFF")
    getgenv().FreezeSelfButton.BackgroundColor3 = getgenv().freezeSelfEnabled and getgenv().COL_ON or getgenv().COL_OFF
    if getgenv().freezeSelfEnabled then enableFreeze() else disableFreeze() end
end)

getgenv().disableFreeze = disableFreeze
