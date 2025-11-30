local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

--------------------------------------------------------
-- Bảng lưu trữ các model đã ESP
--------------------------------------------------------
local espModels = {}

--------------------------------------------------------
-- Hàm tạo ESP + BillboardGui hiển thị distance
--------------------------------------------------------
local function createESP(model)
    if not model or not model.Parent then return end
    if model:FindFirstChild("ESP_DreadDucky") then return end
    local hrpTarget = model:FindFirstChild("HumanoidRootPart")
    if not hrpTarget then return end

    -- Folder chứa ESP
    local folder = Instance.new("Folder")
    folder.Name = "ESP_DreadDucky"
    folder.Parent = model

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "Highlight"
    highlight.FillColor = Color3.fromRGB(255, 50, 50)
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 0.2
    highlight.Adornee = model
    highlight.Parent = folder

    -- BillboardGui hiển thị distance
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
    RunService.RenderStepped:Connect(function()
        if not model.Parent then return end
        if hrp and hrp.Parent then
            text.Text = string.format("%.0f", (hrp.Position - hrpTarget.Position).Magnitude) .. "m"
        end
    end)
end

--------------------------------------------------------
-- Hàm refresh ESP: xóa hết ESP cũ và tạo lại
--------------------------------------------------------
local function refreshESP()
    for model, _ in pairs(espModels) do
        if model and model.Parent then
            local espFolder = model:FindFirstChild("ESP_DreadDucky")
            if espFolder then espFolder:Destroy() end
            createESP(model)
        else
            espModels[model] = nil
        end
    end
end

--------------------------------------------------------
-- Bắt model mới xuất hiện
--------------------------------------------------------
workspace.DescendantAdded:Connect(function(child)
    if child:IsA("Model") and child.Name == "DreadDucky" then
        espModels[child] = true
        createESP(child)
    end
end)

--------------------------------------------------------
-- Quét workspace lần đầu nhưng chỉ một lần
--------------------------------------------------------
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Model") and obj.Name == "DreadDucky" then
        espModels[obj] = true
        createESP(obj)
    end
end

--------------------------------------------------------
-- Lặp refresh ESP mỗi 2 giây
--------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(2)
        refreshESP()
    end
end)
