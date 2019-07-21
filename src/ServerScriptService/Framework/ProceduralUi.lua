local frame = Instance.new('Frame')
frame.BackgroundColor3 = Color3.new(1, 1, 1)
frame.BackgroundTransparency = .5
frame.BorderSizePixel = 0
frame.Size = UDim2.new(.25, 0, .25, 0)
 
for i, v in ipairs(game.Players:GetPlayers()) do
	local lframe = frame:Clone()
	lframe.Position = lframe.Position + UDim2.new(0, i, 0, i)
	lframe.Parent = game.Players.LocalPlayer.PlayerGui.Screen
end