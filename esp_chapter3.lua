local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

--------------------------------------------------------
-- Hàm tạo ESP + BillboardGui hiển thị distance
--------------------------------------------------------
local function createESP(model)
    if not model:FindFirstChild("HumanoidRootPart") then return end
    if model:FindFirstChild("ESP_DreadDucky") then return end -- tránh tạo lại

    -- Folder chứa ESP
    local folder = Instance.new("Folder")
    folder.Name = "ESP_DreadDucky"
    folder.Parent = model

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.FillColor = Color3.fromRGB(255, 50, 50) -- NPC đỏ
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 0.2
    highlight.Adornee = model
    highlight.Parent = folder

    -- BillboardGui hiển thị distance
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DistanceGui"
    billboard.Size = UDim2.new(0, 100, 0, 25)
    billboard.AlwaysOnTop = true
    billboard.Adornee = model:FindFirstChild("HumanoidRootPart")
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

    -- Cập nhật distance liên tục
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not model.Parent then
            conn:Disconnect()
            return
        end
        if not hrp or not hrp.Parent then return end

        local npcHRP = model:FindFirstChild("HumanoidRootPart")
        if not npcHRP then return end

        local dist = (hrp.Position - npcHRP.Position).Magnitude
        text.Text = string.format("%.0f", dist) .. "m"
    end)
end

--------------------------------------------------------
-- ĐỆ QUY QUÉT TOÀN BỘ WORKSPACE
--------------------------------------------------------
local function scan(obj)
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("Model") and child.Name == "DreadDucky" then
            if child:FindFirstChild("HumanoidRootPart") then
                createESP(child)
            end
        end
        scan(child)
    end
end

--------------------------------------------------------
-- BẮT MODEL mới xuất hiện
--------------------------------------------------------
workspace.DescendantAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == "DreadDucky" then
        if child:FindFirstChild("HumanoidRootPart") then
            createESP(child)
        end
    end
end)

--------------------------------------------------------
-- Quét lần đầu
--------------------------------------------------------
task.wait(1)
scan(workspace)
