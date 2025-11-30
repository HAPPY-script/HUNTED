local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

--------------------------------------------------------
-- Bảng lưu model + object ESP để cập nhật distance
--------------------------------------------------------
local espModels = {}

--------------------------------------------------------
-- Hàm tạo ESP
--------------------------------------------------------
local function createESP(model)
	if not model or not model.Parent then return end
	if model:FindFirstChild("ESP_DreadDucky") then return end
	local hrpTarget = model:FindFirstChild("HumanoidRootPart")
	if not hrpTarget then return end

	local folder = Instance.new("Folder")
	folder.Name = "ESP_DreadDucky"
	folder.Parent = model

	local highlight = Instance.new("Highlight")
	highlight.Name = "Highlight"
	highlight.FillColor = Color3.fromRGB(255, 50, 50)
	highlight.FillTransparency = 0.25
	highlight.OutlineTransparency = 0.2
	highlight.Adornee = model
	highlight.Parent = folder

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

	-- lưu vào espModels để vòng RenderStepped update
	espModels[model] = {
		hrp = hrpTarget,
		text = text,
	}
end

--------------------------------------------------------
-- Refresh ESP (xóa và tạo lại)
--------------------------------------------------------
local function refreshESP()
	for model, data in pairs(espModels) do
		if not model or not model.Parent then
			espModels[model] = nil
		else
			local espFolder = model:FindFirstChild("ESP_DreadDucky")
			if espFolder then espFolder:Destroy() end
			createESP(model)
		end
	end
end

--------------------------------------------------------
-- Update distance 60fps (CHỈ 1 vòng duy nhất)
--------------------------------------------------------
RunService.RenderStepped:Connect(function()
	if not hrp or not hrp.Parent then return end
	for model, data in pairs(espModels) do
		if model.Parent and data.hrp.Parent then
			local dist = (hrp.Position - data.hrp.Position).Magnitude
			data.text.Text = string.format("%.0f", dist) .. "m"
		end
	end
end)

--------------------------------------------------------
-- Bắt model mới xuất hiện
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
for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("Model") and obj.Name == "DreadDucky" then
		if obj:FindFirstChild("HumanoidRootPart") then
			createESP(obj)
		end
	end
end

--------------------------------------------------------
-- Refresh ESP mỗi 2 giây
--------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(2)
		refreshESP()
	end
end)
