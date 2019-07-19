--Made by Killers88, just group with the model to get it to work.  This button also works for Anything.
--Do not change anything besides the lines mentioned below.

model = script.Parent.Parent--Indicates that the script interacts with the model the button is grouped with.
messageText = ""--If you want a message to appear upon pressing, type it here.

message = Instance.new("Message")
message.Text = messageText
backup = model:clone()
enabled = true

function regenerate()
	message.Parent = game.Workspace -- <-- DEPRECATED
	model:remove()

	wait(2)--Change this number to display the regen message as long as you want in seconds.

	model = backup:clone()
	model.Parent = game.Workspace
	model:makeJoints()
	message.Parent = nil

	script.Disabled = true
	script.Parent.BrickColor = BrickColor.new(26)--Black
	wait(10)--Change this number to change the time in between regenerations via the button, in seconds..
	script.Parent.BrickColor = BrickColor.new(104)--Purple
	script.Disabled = false
end

function onTouched()	
	if enabled then
		regenerate()
	end
end

 script.Parent.ClickDetector.MouseClick:connect(onTouched)

--And it's done.  If there's anything wrong with this button, PM me.