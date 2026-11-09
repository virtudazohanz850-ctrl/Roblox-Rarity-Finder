-- LIVE RARITY FINDER
-- Epic / Legendary / Mythic / Secret

local WS = game:GetService("Workspace")
local CG = game:GetService("CoreGui")

local COLORS = {
    Epic = Color3.fromRGB(170, 80, 255),
    Legendary = Color3.fromRGB(255, 170, 0),
    Mythic = Color3.fromRGB(255, 50, 50),
    Secret = Color3.fromRGB(220, 50, 255)
}

local found = {}

local gui = Instance.new("ScreenGui")
gui.Name = "LiveRarityFinder"
gui.ResetOnSpawn = false
gui.Parent = CG

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280, 300)
frame.Position = UDim2.new(0, 15, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "LIVE RARITY FINDER"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(5, 40)
list.Size = UDim2.new(1, -10, 1, -45)
list.BackgroundTransparency = 1
list.ScrollBarThickness = 5
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

local function getRarity(obj)
    local current = obj

    for _ = 1, 8 do
        if not current then break end

        for _, key in ipairs({"Rarity", "Tier"}) do
            local value = current:GetAttribute(key)
            if value and COLORS[tostring(value)] then
                return tostring(value)
            end
        end

        for _, child in ipairs(current:GetChildren()) do
            if child:IsA("StringValue") then
                local value = tostring(child.Value)
                if COLORS[value] then
                    return value
                end
            end
        end

        current = current.Parent
    end
end

local function addItem(obj)
    if found[obj] then return end

    local rarity = getRarity(obj)
    if not rarity then return end

    local position
    if obj:IsA("BasePart") then
        position = obj.Position
    elseif obj:IsA("Model") then
        position = obj:GetPivot().Position
    else
        return
    end

    found[obj] = true

    local entry = Instance.new("TextLabel")
    entry.Size = UDim2.new(1, -5, 0, 42)
    entry.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    entry.TextColor3 = COLORS[rarity]
    entry.TextSize = 13
    entry.TextWrapped = true
    entry.Font = Enum.Font.GothamBold
    entry.Text = rarity .. " | " .. obj.Name ..
        "\nX: " .. math.floor(position.X) ..
        " Y: " .. math.floor(position.Y) ..
        " Z: " .. math.floor(position.Z)
    entry.Parent = list

    task.defer(function()
        list.CanvasSize = UDim2.new(
            0, 0, 0, layout.AbsoluteContentSize.Y + 10
        )
    end)
end

local function watch(obj)
    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end

    task.delay(0.3, function()
        if obj.Parent then
            addItem(obj)
        end
    end)

    obj.AttributeChanged:Connect(function()
        addItem(obj)
    end)

    obj.ChildAdded:Connect(function()
        task.delay(0.1, function()
            addItem(obj)
        end)
    end)
end

WS.DescendantAdded:Connect(watch)

print("LIVE RARITY FINDER STARTED")
