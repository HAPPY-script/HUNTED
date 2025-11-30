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
-- TẠO ESP CHO MODEL (player, npc, hoặc model đặc biệt)
------------------------------------------------------------
local function createESP(model, isSpecial)
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

    if isSpecial then
        highlightColor = Color3.fromRGB(255, 255, 0) -- folder NPCs = vàng
    elseif isPlayerModel(model) then
        highlightColor = Color3.fromRGB(0, 255, 0) -- player = xanh
    else
        highlightColor = Color3.fromRGB(255, 50, 50) -- NPC thường = đỏ
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
    -- BillboardGui hiển thị distance (chỉ nếu có HRP)
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
-- ĐỆ QUY QUÉT TOÀN MAP
------------------------------------------------------------
local function scan(obj)
    for _, child in ipairs(obj:GetChildren()) do

        -- ESP cho folder đặc biệt workspace.NPCs
        if specialFolder and child:IsDescendantOf(specialFolder) and child:IsA("Model") then
            createESP(child, true)

        elseif child:IsA("Model") and child:FindFirstChild("Humanoid") then
            -- NPC hoặc Player có Humanoid
            if child:FindFirstChild("HumanoidRootPart") then
                createESP(child, false)
            end
        end

        scan(child)
    end
end

------------------------------------------------------------
-- BẮT MODEL MỚI XUẤT HIỆN
------------------------------------------------------------
workspace.DescendantAdded:Connect(function(child)

    -- Nếu là phần tử trong folder đặc biệt
    if specialFolder and child:IsDescendantOf(specialFolder) and child:IsA("Model") then
        createESP(child, true)
        return
    end

    -- Nếu là NPC có Humanoid
    if child:IsA("Humanoid") then
        local model = child.Parent
        if model and model:FindFirstChild("HumanoidRootPart") then
            createESP(model, false)
        end
    end
end)

------------------------------------------------------------
-- QUÉT BAN ĐẦU
------------------------------------------------------------
task.wait(1)
scan(workspace)
