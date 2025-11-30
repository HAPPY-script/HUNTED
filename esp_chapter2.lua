local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local specialFolder = workspace:FindFirstChild("NPCs") -- folder đặc biệt

------------------------------------------------------------
-- HÀM KIỂM TRA MODEL CÓ PHẢI PLAYER KHÔNG
------------------------------------------------------------
local function isPlayerModel(model)
    return Players:FindFirstChild(model.Name) ~= nil
end

------------------------------------------------------------
-- TẠO ESP CHO MODEL (Player hoặc Model trong NPCs)
------------------------------------------------------------
local function createESP(model, isNPCFolder)
    if not model or not model.Parent then return end

    -- Không tạo lại nếu đã có
    if model:FindFirstChild("NPC_ESP") then return end

    -- Tạo folder chứa ESP
    local folder = Instance.new("Folder")
    folder.Name = "NPC_ESP"
    folder.Parent = model

    --------------------------------------------------------
    -- XÁC ĐỊNH MÀU ESP
    --------------------------------------------------------
    local highlightColor

    if isNPCFolder then
        -- Model trong folder NPCs -> đỏ
        highlightColor = Color3.fromRGB(255, 50, 50)
    else
        -- Player -> xanh lá
        highlightColor = Color3.fromRGB(0, 255, 0)
    end

    --------------------------------------------------------
    -- Highlight
    --------------------------------------------------------
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillColor = highlightColor
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 0.2
    highlight.Adornee = model
    highlight.Parent = folder

    --------------------------------------------------------
    -- BillboardGui hiển thị distance (nếu có part để bám)
    --------------------------------------------------------
    local hrpTarget = model:FindFirstChild("HumanoidRootPart")
                    or model:FindFirstChildWhichIsA("BasePart")

    if hrpTarget then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "DistanceGui"
        billboard.Size = UDim2.new(0, 100, 0, 25)
        billboard.AlwaysOnTop = true
        billboard.Adornee = hrpTarget
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.Parent = folder

        local text = Instance.new("TextLabel")
        text.BackgroundTransparency = 1
        text.Size = UDim2.new(1, 0, 1, 0)
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextStrokeTransparency = 0.3
        text.Font = Enum.Font.SourceSansBold
        text.TextScaled = true
        text.Parent = billboard

        -- Cập nhật distance
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not model.Parent then
                conn:Disconnect()
                return
            end
            if not hrp or not hrp.Parent then return end

            local origin = hrpTarget.Position
            local dist = (hrp.Position - origin).Magnitude
            text.Text = string.format("%.0f", dist) .. "m"
        end)
    end
end

------------------------------------------------------------
-- QUÉT MODEL TRONG FOLDER NPCs
------------------------------------------------------------
local function scanNPCFolder()
    if not specialFolder then return end

    for _, child in ipairs(specialFolder:GetChildren()) do
        if child:IsA("Model") then
            createESP(child, true)
        end
    end
end

------------------------------------------------------------
-- ESP PLAYER
------------------------------------------------------------
local function setupPlayerESP(plr)
    if not plr.Character then
        plr.CharacterAdded:Wait()
    end

    local char = plr.Character or plr.CharacterAdded:Wait()
    createESP(char, false)

    plr.CharacterAdded:Connect(function(newChar)
        createESP(newChar, false)
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    setupPlayerESP(plr)
end

Players.PlayerAdded:Connect(setupPlayerESP)

------------------------------------------------------------
-- BẮT MODEL MỚI THÊM VÀO FOLDER NPCs
------------------------------------------------------------
if specialFolder then
    specialFolder.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            createESP(child, true)
        end
    end)
end

------------------------------------------------------------
-- QUÉT BAN ĐẦU
------------------------------------------------------------
task.wait(1)
scanNPCFolder()
