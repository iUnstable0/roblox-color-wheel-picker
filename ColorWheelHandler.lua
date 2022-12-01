local F = script.Parent:WaitForChild('Frame');
local colourWheel = F:WaitForChild("ColourWheel");
local wheelPicker = colourWheel:WaitForChild("Picker");
local darknessPicker = F:WaitForChild("DarknessPicker");
local darknessSlider = darknessPicker:WaitForChild("Slider");
local colourDisplay = F:WaitForChild("ColourDisplay");
local uis = game:GetService("UserInputService");
local buttonDown = false
local movingSlider = false

local function updateColour(centreOfWheel)
	local colourPickerCentre = Vector2.new(
		colourWheel.Picker.AbsolutePosition.X + (colourWheel.Picker.AbsoluteSize.X/2),
		colourWheel.Picker.AbsolutePosition.Y + (colourWheel.Picker.AbsoluteSize.Y/2)
	)
	local h = (math.pi - math.atan2(colourPickerCentre.Y - centreOfWheel.Y, colourPickerCentre.X - centreOfWheel.X)) / (math.pi * 2)

	local s = (centreOfWheel - colourPickerCentre).Magnitude / (colourWheel.AbsoluteSize.X/2)

	local v = math.abs((darknessSlider.AbsolutePosition.Y - darknessPicker.AbsolutePosition.Y) / darknessPicker.AbsoluteSize.Y - 1)


	local hsv = Color3.fromHSV(math.clamp(h, 0, 1), math.clamp(s, 0, 1), math.clamp(v, 0, 1))


	colourDisplay.ImageColor3 = hsv
	--print(hsv)
	darknessPicker.UIGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromHSV(math.clamp(h, 0, 1), math.clamp(s, 0, 1), 1)), 
		ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
	}
end


colourWheel.MouseButton1Down:Connect(function()
	buttonDown = true
end)

darknessPicker.MouseButton1Down:Connect(function()
	movingSlider = true
end)


uis.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	buttonDown = false
	movingSlider = false
end)


uis.InputChanged:Connect(function(input)

	if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end


	local mousePos = uis:GetMouseLocation() - Vector2.new(0, game:GetService("GuiService"):GetGuiInset().Y)

	local centreOfWheel = Vector2.new(colourWheel.AbsolutePosition.X + (colourWheel.AbsoluteSize.X/2), colourWheel.AbsolutePosition.Y + (colourWheel.AbsoluteSize.Y/2))

	local distanceFromWheel = (mousePos - centreOfWheel).Magnitude

	--print(distanceFromWheel)
	if distanceFromWheel <= colourWheel.AbsoluteSize.X/2 and buttonDown then
		--if buttonDown then
		--print(mousePos.X - colourWheel.AbsolutePosition.X, distanceFromWheel)
		wheelPicker.Position = UDim2.new(0, mousePos.X - colourWheel.AbsolutePosition.X, 0, mousePos.Y - colourWheel.AbsolutePosition.Y)


	elseif movingSlider then

		darknessSlider.Position = UDim2.new(darknessSlider.Position.X.Scale, 0, 0, 
			math.clamp(
				mousePos.Y - darknessPicker.AbsolutePosition.Y, 
				0, 
				darknessPicker.AbsoluteSize.Y)
		)

		local outOfBounds = false

		if darknessSlider.Position.Y.Offset <= 10 or darknessSlider.Position.Y.Offset >= darknessPicker.AbsoluteSize.Y - 10 then
			outOfBounds = true
		end

		-- print(outOfBounds)

		if outOfBounds then
			local lol = darknessSlider.Position.Y.Offset

			if darknessSlider.Position.Y.Offset >= darknessPicker.AbsoluteSize.Y - 10 then
				lol = darknessPicker.AbsoluteSize.Y - darknessSlider.Position.Y.Offset
				-- print("IS BOTTOMIE")
			end

			darknessSlider.Size = UDim2.new((lol/10) + 0.3, 0, darknessSlider.Size.Y.Scale, darknessSlider.Size.Y.Offset)
		else
			darknessSlider.Size = UDim2.new(1, 0, darknessSlider.Size.Y.Scale, darknessSlider.Size.Y.Offset)
		end

	elseif buttonDown then

		local angle = math.atan2(mousePos.Y - centreOfWheel.Y, mousePos.X - centreOfWheel.X)
		local x = math.cos(angle) * colourWheel.AbsoluteSize.X/2
		local y = math.sin(angle) * colourWheel.AbsoluteSize.X/2
		wheelPicker.Position = UDim2.new(
			0,
			x + colourWheel.AbsoluteSize.X/2,
			0,
			y + colourWheel.AbsoluteSize.Y/2
		)
	end


	updateColour(centreOfWheel)
end)