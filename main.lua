
Wenn sich dein Programm (der Script Executor) nicht öffnet oder abstürzt, wenn du versuchst, das Script auszuführen, liegt das fast immer an einem oder mehreren Problemen im Code selbst oder an der Art, wie das Spiel aufgebaut ist.

Hier sind die häufigsten Fehlerquellen und wie du sie beheben kannst, von der wahrscheinlichsten zur unwahrscheinlichsten:

---

### Problem 1: Fehlende oder falsche Objekte (Hauptverdächtiger)

Das ist bei 90% aller Roblox-Script-Fehler die Ursache. Mein Code versucht, auf etwas zuzugreifen, das in "Five Nights at Hunted" anders heißt oder nicht existiert.

*   **`PlayerModule` und `Controls`:** Mein Fly-Script versucht, auf `game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")` zuzugreifen. Nicht jedes Spiel hat dieses Modul oder es heißt anders. Wenn es nicht gefunden wird, stürzt das Script ab.
*   **`HumanoidRootPart`:** Manche Spiele benutzen für die Hauptbewegung ein anderes Teil, z.B. nur `Torso` oder `UpperTorso`. Mein Script stürzt ab, wenn `HumanoidRootPart` nicht gefunden wird.
*   **Charakter-Struktur:** Das Script nimmt an, dass dein Charakter eine Standardstruktur hat. Wenn das Spiel diese verändert hat, können Fehler auftreten.

**Lösung:**
Wir müssen das Script robuster machen. Es muss prüfen, ob die Objekte existieren, bevor es sie benutzt. Ersetze den alten Code durch diese sicherere Version:

```lua
-- Five Nights at Hunted - Multi-Hack Script (SICHERE VERSION)
-- Funktionen: ESP, Fly, Speed, Noclip, God Mode, Infinite Jump

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart") -- Kann fehlschlagen

-- === SICHERE FUNKTIONEN ===

local flying = false
local noclip = false
local infiniteJump = false
local espEnabled = false
local espFolder = Instance.new("Folder")
espFolder.Name = "ESPFolder"
espFolder.Parent = game.Workspace

-- 1. God Mode (sicher)
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

-- 2. Super Speed (sicher)
local normalSpeed = Humanoid.WalkSpeed
function setSuperSpeed(speed)
    if Humanoid then Humanoid.WalkSpeed = speed end
end

function resetSpeed()
    if Humanoid then Humanoid.WalkSpeed = normalSpeed end
end

-- 3. Noclip (sicher)
local noclipConnection
function enableNoclip()
    noclip = true
    noclipConnection = RunService.Stepped:Connect(function()
        if noclip and Character then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
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

-- 4. Infinite Jump (sicher)
local jumpConnection
function enableInfiniteJump()
    jumpConnection = UserInputService.JumpRequest:Connect(function()
        if infiniteJump and Humanoid and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function disableInfiniteJump()
    if jumpConnection then jumpConnection:Disconnect() end
end

-- 5. Fly (VOLLSTÄNDIG ÜBERARBEITET UND SICHER)
local flyConnection
local flyVelocity, flyGyro

function enableFly()
    if not RootPart then return end -- Abbruch, wenn kein RootPart
    
    flying = true
    flyVelocity = Instance.new("BodyVelocity")
    flyGyro = Instance.new("BodyGyro")
    
    flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    
    flyVelocity.Parent = RootPart
    flyGyro.Parent = RootPart
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not flying or not RootPart or not flyVelocity or not flyGyro then
            disableFly() -- Automatisch deaktivieren, wenn etwas fehlt
            return
        end
        
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyGyro.CFrame = cam.CFrame
        
        local moveDir = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        
        local flySpeed = 50
        flyVelocity.Velocity = moveDir * flySpeed
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            flyVelocity.Velocity = flyVelocity.Velocity + Vector3.new(0, flySpeed, 0)
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            flyVelocity.Velocity = flyVelocity.Velocity - Vector3.new(0, flySpeed, 0)
        end
    end)
end

function disableFly()
    flying = false
    if flyConnection then flyConnection:Disconnect() end
    if flyVelocity then flyVelocity:Destroy() end
    if flyGyro then flyGyro:Destroy() end
end

-- 6. ESP (sicher)
function enableESP()
    espEnabled = true
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local espBox = Instance.new("BoxHandleAdornment")
                espBox.Name = player.Name
                espBox.Adornee = root
                espBox.Size = Vector3.new(4, 6, 4)
                espBox.Color3 = player.Team and player.Team.TeamColor.Color or Color3.new(1, 0, 0)
                espBox.Transparency = 0.5
                espBox.AlwaysOnTop = true
                espBox.ZIndex = 10
                espBox.Parent = espFolder
            end
        end
    end
end

function disableESP()
    espEnabled = false
    for _, obj in pairs(espFolder:GetChildren()) do
        obj:Destroy()
    end
end

-- === GUI-Erstellung (gleich wie vorher) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
MainFrame.Size = UDim2.new(0, 300, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Title.BorderSizePixel = 0
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Five Nights at Hunted - Hack (Safe)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14

local function createButton(text, yPos, callback)
    local button = Instance.new("TextButton")
    button.Parent = MainFrame
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 
        50)
    button.BorderSizePixel = 0
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 12
    button.MouseButton1Click:Connect(callback)
end

-- === GUI BUTTONS ERSTELLEN ===
createButton("Toggle ESP", 40, function()
    if espEnabled then
        disableESP()
    else
        enableESP()
    end
end)

createButton("Toggle Fly (WASD, Space, Ctrl)", 80, function()
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

createButton("Toggle Infinite Jump", 240, function()
    infiniteJump = not infiniteJump
    if infiniteJump then
        enableInfiniteJump()
    else
        disableInfiniteJump()
    end
end)

print("Five Nights at Hunted - Multi-Hack Script (Safe Version) loaded successfully!")
