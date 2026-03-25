-- Five Nights: Hunted Script für Xenon
-- Geschwindigkeitsregler, Barrieren-Deaktivierer, Fliegen und NoClip

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- GUI Erstellung
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 300, 0, 280)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.new(0, 1, 0)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "F.N. Hunted - Multi-Hack"
Title.TextColor3 = Color3.new(0, 1, 0)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = MainFrame
SpeedLabel.Size = UDim2.new(0, 100, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 40)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 1.0"
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.Font = Enum.Font.SourceSans
SpeedLabel.TextSize = 14

local SpeedSlider = Instance.new("TextButton")
SpeedSlider.Parent = MainFrame
SpeedSlider.Size = UDim2.new(0, 200, 0, 20)
SpeedSlider.Position = UDim2.new(0, 50, 0, 65)
SpeedSlider.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
SpeedSlider.BorderSizePixel = 1
SpeedSlider.BorderColor3 = Color3.new(0, 1, 0)
SpeedSlider.Text = ""
SpeedSlider.AutoButtonColor = false

local FlyButton = Instance.new("TextButton")
FlyButton.Parent = MainFrame
FlyButton.Size = UDim2.new(0, 200, 0, 30)
FlyButton.Position = UDim2.new(0, 50, 0, 100)
FlyButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
FlyButton.BorderSizePixel = 1
FlyButton.BorderColor3 = Color3.new(0, 1, 0)
FlyButton.Text = "Fliegen: AUS"
FlyButton.TextColor3 = Color3.new(1, 0, 0)
FlyButton.Font = Enum.Font.SourceSansBold
FlyButton.TextSize = 16

local NoClipButton = Instance.new("TextButton")
NoClipButton.Parent = MainFrame
NoClipButton.Size = UDim2.new(0, 200, 0, 30)
NoClipButton.Position = UDim2.new(0, 50, 0, 140)
NoClipButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
NoClipButton.BorderSizePixel = 1
NoClipButton.BorderColor3 = Color3.new(0, 1, 0)
NoClipButton.Text = "NoClip: AUS"
NoClipButton.TextColor3 = Color3.new(1, 0, 0)
NoClipButton.Font = Enum.Font.SourceSansBold
NoClipButton.TextSize = 16

local BarrierButton = Instance.new("TextButton")
BarrierButton.Parent = MainFrame
BarrierButton.Size = UDim2.new(0, 200, 0, 30)
BarrierButton.Position = UDim2.new(0, 50, 0, 180)
BarrierButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
BarrierButton.BorderSizePixel = 1
BarrierButton.BorderColor3 = Color3.new(0, 1, 0)
BarrierButton.Text = "Barrieren: AKTIV"
BarrierButton.TextColor3 = Color3.new(1, 0, 0)
BarrierButton.Font = Enum.Font.SourceSansBold
BarrierButton.TextSize = 16

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MainFrame
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.BackgroundColor3 = Color3.new(0.5, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18

-- Variablen
local speedValue = 1.0
local barriersEnabled = true
local isDragging = false
local barrierParts = {}
local flying = false
local noClipEnabled = false
local flySpeed = 50
local bodyVelocity
local bodyGyro

-- Geschwindigkeitsfunktion
local function updateSpeed()
    if Humanoid then
        Humanoid.WalkSpeed = 16 * speedValue
    end
    SpeedLabel.Text = "Speed: " .. string.format("%.1f", speedValue)
end

-- Fliegen-Funktionen
local function startFly()
    if flying then return end
    
    flying = true
    FlyButton.Text = "Fliegen: AN"
    FlyButton.TextColor3 = Color3.new(0, 1, 0)
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = Humanoid.RootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.Parent = Humanoid.RootPart
    
    Humanoid.PlatformStand = true
end

local function stopFly()
    if not flying then return end
    
    flying = false
    FlyButton.Text = "Fliegen: AUS"
    FlyButton.TextColor3 = Color3.new(1, 0, 0)
    
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    
    Humanoid.PlatformStand = false
end

local function controlFly()
    if not flying then return end
    
    local camera = workspace.CurrentCamera
    local moveDirection = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        moveDirection = moveDirection + camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        moveDirection = moveDirection - camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        moveDirection = moveDirection - camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        moveDirection = moveDirection + camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end
    
    if bodyVelocity then
        bodyVelocity.Velocity = moveDirection * flySpeed * speedValue
    end
    
    if bodyGyro then
        bodyGyro.CFrame = camera.CFrame
    end
end

-- NoClip-Funktion
local function toggleNoClip()
    noClipEnabled = not noClipEnabled
    if noClipEnabled then
        NoClipButton.Text = "NoClip: AN"
        NoClipButton.TextColor3 = Color3.new(0, 1, 0)
    else
        NoClipButton.Text = "NoClip: AUS"
        NoClipButton.TextColor3 = Color3.new(1, 0, 0)
    end
end

-- Barrieren finden
local function findBarriers()
    barrierParts = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("WedgePart") then
            if obj.Name:lower():find("barrier") or obj.Name:lower():find("wall") or obj.Name:lower():find("block") or obj.Name:lower():find("fence") then
                table.insert(barrierParts, obj)
            end
        end
    end
end

-- Barrieren umschalten
local function toggleBarriers()
    barriersEnabled = not barriersEnabled
    if barriersEnabled then
        BarrierButton.Text = "Barrieren: AKTIV"
        BarrierButton.TextColor3 = Color3.new(1, 0, 0)
        for _, part in pairs(barrierParts) do
            if part and part.Parent then
                part.CanCollide = true
                part.Transparency = 0
            end
        end
    else
        BarrierButton.Text = "Barrieren: DEAKTIV"
        BarrierButton.TextColor3 = Color3.new(0, 1, 0)
        for _, part in pairs(barrierParts) do
            if part and part.Parent then
                part.CanCollide = false
                part.Transparency = 0.5
            end
        end
    end
end

-- Slider-Steuerung
SpeedSlider.MouseButton1Down:Connect(function()
    isDragging = true
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = input.Position
        local sliderPos = SpeedSlider.AbsolutePosition
        local sliderSize = SpeedSlider.AbsoluteSize
        
        local relativeX = math.clamp((mousePos.X - sliderPos.X) / sliderSize.X, 0, 1)
        speedValue = 0.1 + (relativeX * 4.9) -- 0.1 bis 5.0
        
        updateSpeed()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Button-Events
FlyButton.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
    else
        startFly()
    end
end)

NoClipButton.MouseButton1Click:Connect(toggleNoClip)
BarrierButton.MouseButton1Click:Connect(toggleBarriers)
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- NoClip und Fliegen-Loop
RunService.Stepped:Connect(function()
    -- NoClip
    if noClipEnabled and Character and Humanoid then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Fliegen-Steuerung
    controlFly()
end)

-- Initialisierung
findBarriers()
updateSpeed()

-- Automatische Aktualisierung der Barrieren
spawn(function()
    while ScreenGui.Parent do
        wait(5)
        findBarriers()
        if not barriersEnabled then
            for _, part in pairs(barrierParts) do
                if part and part.Parent then
                    part.CanCollide = false
                    part.Transparency = 0.5
                end
            end
        end
    end
end)

print("F.N. Hunted Multi-Hack geladen!")
print("Features: Geschwindigkeit, Fliegen, NoClip, Barrieren")
print("Fliegen-Steuerung: W/A/S/D zum Bewegen, Leertaste hoch, Strg runter")
