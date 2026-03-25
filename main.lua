Absolut. Hier ist ein komplettes Lua-Script, das du mit einem Roblox Script Executor (wie Synapse X, KRNL, etc.) in "Five Nights at Hunted" verwenden kannst. Es enthält alle gewünschten Funktionen und eine einfache Benutzeroberfläche, um sie ein- und auszuschalten.

**WICHTIG:** Dieses Script funktioniert nur, wenn du es in einem funktionierenden Script Executor ausführst. Es ist kein Cheat Engine-Code.

```lua
-- Five Nights at Hunted - Multi-Hack Script by Venice
-- Funktionen: ESP, Fly, Speed, Noclip, God Mode, Infinite Jump

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- === GUI-Erstellung (Einfache Benutzeroberfläche) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Five Nights at Hunted - Hack"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14

-- === Variablen für die Hacks ===
local flying = false
local flySpeed = 50
local noclip = false
local infiniteJump = false
local espEnabled = false

local espFolder = Instance.new("Folder")
espFolder.Name = "ESPFolder"
espFolder.Parent = game.Workspace

-- === FUNKTIONEN ===

-- 1. God Mode
local godModeConnection
function enableGodMode()
    if godModeConnection then godModeConnection:Disconnect() end
    godModeConnection = Humanoid.HealthChanged:Connect(function(health)
        if health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
    Humanoid.MaxHealth = math.huge
    Humanoid.Health = math.huge
end

function disableGodMode()
    if godModeConnection then godModeConnection:Disconnect() end
    Humanoid.MaxHealth = 100
    Humanoid.Health = 100
end

-- 2. Super Speed
local normalSpeed = Humanoid.WalkSpeed
function setSuperSpeed(speed)
    Humanoid.WalkSpeed = speed
end

function resetSpeed()
    Humanoid.WalkSpeed = normalSpeed
end

-- 3. Noclip
local noclipConnection
function enableNoclip()
    noclip = true
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if noclip and Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function disableNoclip()
    noclip = false
    if noclipConnection then noclipConnection:Disconnect() end
    if Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- 4. Infinite Jump
local jumpConnection
function enableInfiniteJump()
    jumpConnection = UserInputService.JumpRequest:Connect(function()
        if infiniteJump and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function disableInfiniteJump()
    if jumpConnection then jumpConnection:Disconnect() end
end

-- 5. Fly
local flyConnection
local controls = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
local cam = game.Workspace.CurrentCamera

function enableFly()
    flying = true
    local bv = Instance.new("BodyVelocity")
    local bg = Instance.new("BodyGyro")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bv.Parent = RootPart
    bg.Parent = RootPart
    
    flyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if flying then
            bv.Velocity = Vector3.new(0, 0, 0)
            bg.CFrame = cam.CFrame
            
            local moveDir = controls:GetMoveVector()
            bv.Velocity = (cam.CFrame:VectorToWorldSpace(moveDir) * flySpeed) + Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                bv.Velocity = bv.Velocity + Vector3.new(0, flySpeed, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                bv.Velocity = bv.Velocity - Vector3.new(0, flySpeed, 0)
            end
        end
    end)
end

function disableFly()
    flying = false
    if flyConnection then flyConnection:Disconnect() end
    if RootPart:FindFirstChild("BodyVelocity") then RootPart:FindFirstChild("BodyVelocity"):Destroy() end
    if RootPart:FindFirstChild("BodyGyro") then RootPart:FindFirstChild("BodyGyro"):Destroy() end
end

-- 6. ESP
function enableESP()
    espEnabled = true
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local espBox = Instance.new("BoxHandleAdornment")
            espBox.Name = player.Name
            espBox.Adornee = player.Character.HumanoidRootPart
            espBox.Size = Vector3.new(4, 6, 4)
            espBox.Color3 = player.Team and player.Team.TeamColor.Color or Color3.new(1, 0, 0)
            espBox.Transparency = 0.5
            espBox.AlwaysOnTop = true
            espBox.ZIndex = 10
            espBox.Parent = espFolder

            local espName = Instance.new("BillboardGui")
            espName.Name = "NameTag"
            espName.Adornee = player.Character.HumanoidRootPart
            espName.Size = UDim2.new(0, 100, 0, 50)
            espName.StudsOffset = Vector3.new(0, 3, 0)
            espName.Parent = espFolder
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = Color3.new(1, 1, 1)
            nameLabel.TextStrokeTransparency = 0
            nameLabel.TextSize = 14
            nameLabel.Parent = espName
        end
    end
end

function disableESP()
    espEnabled = false
    for _, obj in pairs(espFolder:GetChildren()) do
        obj:Destroy()
    end
end

-- === GUI BUTTONS ===
local function createButton(text, yPos, callback)
    local button = Instance.new("TextButton")
    button.Parent = MainFrame
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12
    button.MouseButton1Click:Connect(callback)
end

createButton("Toggle ESP", 40, function()
    if espEnabled then
        disableESP()
    else
        enableESP()
    end
end)

createButton("Toggle Fly (Space/Ctrl)", 80, function()
    if flying then
        disableFly()
    else
        enableFly()
    end
end)

createButton("Toggle Super Speed", 120, function()
    if Humanoid.WalkSpeed > 20 then
        resetSpeed()
    else
        setSuperSpeed(100)
    end
end)

createButton("Toggle Noclip", 160, function()
    if noclip then
        disableNoclip()
    else
        enableNoclip()
    end
end)

createButton("Toggle God Mode", 200, function()
    if Humanoid.MaxHealth > 100 then
disableGodMode()
    else
        enableGodMode()
    end
end)

-- Infinite Jump Button
createButton("Toggle Infinite Jump", 240, function()
    infiniteJump = not infiniteJump
    if infiniteJump then
        enableInfiniteJump()
    else
        disableInfiniteJump()
    end
end)

print("Five Nights at Hunted - Multi-Hack Script loaded successfully!")
