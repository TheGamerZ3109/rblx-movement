--[[

NOTES:

the more I update it the less documented it becomes, im lazy, my apologies

dont take credit

written is VS Code using Rojo

]]

local plr = game:GetService("Players").LocalPlayer -- player object
local char = plr.Character or plr.CharacterAdded:Wait() -- character object
local humanoid = char:WaitForChild("Humanoid") -- humanoid object

game.Workspace.CurrentCamera.HeadLocked = true -- just set to false or comment out if this is causing issues in your game, it just sets the camera to follow the characters head object when for we ex. crouch

local UIS = game:GetService("UserInputService")

local crouchAnim = Instance.new("Animation") -- animation for crouching, set the id to your own, or dont, idk at this point
crouchAnim.Parent = script
crouchAnim.Name = "CrouchAnimation"
crouchAnim.AnimationId = "rbxassetid://9701823161"

local slideAnim = Instance.new("Animation") -- animation for sliding, set the id to your own, or dont, idk at this point
slideAnim.Parent = script
slideAnim.Name = "SlideAnimation"
slideAnim.AnimationId = "rbxassetid://9701872337"


--UNUSED
local rollAnim = Instance.new("Animation") -- animation for rolling, set the id to your own, or dont, idk at this point
rollAnim.Parent = script
rollAnim.Name = "RollAnimation"
rollAnim.AnimationId = "rbxassetid://9709580370"

local loadedAnims = { -- animations
    crouch = humanoid:LoadAnimation(crouchAnim),
    slide = humanoid:LoadAnimation(slideAnim)
}

local bools = { -- script wide booleans
    sprinting = false,
    crouching = false,
    sliding = false,

    canSprint = true,
    canCrouch = true,
    canSlide = false
}

local speeds = { -- amount that we add or subtract for the event
    sprinting = 7,
    crouching = 5,
    sliding = 12
}

local keys = { -- specified keys for each event, do NOT set any of them to the same key, it doesnt work, and im too lazy to fix it
    sprinting = Enum.KeyCode.LeftShift,
    crouching = Enum.KeyCode.C,
    sliding = Enum.KeyCode.X
}

local maxSlideTime = 2 -- max amount of time you can slide for before it auto stops you

function crouch(bool) -- crouching animations
    if bool then
        loadedAnims.crouch:Play()
    elseif not bool then
        loadedAnims.crouch:Stop()
    end
end

function slide(bool) -- sliding animations
    if bool then
        loadedAnims.slide:Play()
    elseif not bool then
        loadedAnims.slide:Stop()
    end
end

UIS.InputBegan:Connect(function(input, gameProcessedEvent) -- on a keydown
    if not gameProcessedEvent then -- if we are actually playing the game and arent like, in the chat

       if input.KeyCode == keys.sprinting then -- if we pressed the sprinting key

		if bools.canSprint == false then return end -- making sure we can sprint
        if bools.sprinting == true then return end -- making sure we arent already sprinting (this shouldnt be needed but whatever)

        humanoid.WalkSpeed += speeds.sprinting -- give them the extra sprinting speed
        bools.canSprint, bools.canCrouch, bools.sprinting = false, false, true -- set the new boolean values

        elseif input.KeyCode == keys.crouching then -- if we pressed the crouching key

        if bools.canCrouch == false then return end -- checking if we can crouch
        if bools.crouching == true then return end -- checking if we arent already crouching (this shouldnt be needed but whatever)
        if bools.sprinting == true then return end -- make sure we arent sprinting and crouching at the same time.. *hm* - My friend disproved this IRL but whatever
        
        humanoid.WalkSpeed -= speeds.crouching -- take away the crouching speed
        bools.canSprint, bools.canCrouch, bools.crouching = false, false, true -- set the booleans

        crouch(true) -- send the function for animations

        elseif input.KeyCode == keys.sliding then

            if bools.crouching == true then return end -- make sure we arent crouching
            if bools.sprinting == false then return end -- we have to sprint to slide
            if bools.canSlide == true then return end -- just checking.. we can slide right?

            humanoid.WalkSpeed -= speeds.sprinting -- take the sprinting speed to reset that
            humanoid.WalkSpeed += speeds.sliding -- add the sliding speed to make them go brrrr

            bools.canSprint, bools.canCrouch, bools.canSlide, bools.sliding, bools.crouching, bools.sprinting = false, false, false, true, false, false -- set *a lot* booleans

            slide(true) -- send the animation event

            while task.wait(maxSlideTime) do -- wait until the max slide time is up
				if bools.sliding == true then -- if we didnt already stop sliding

                    humanoid.WalkSpeed -= speeds.sliding -- remove the sliding speed

                     bools.canSprint, bools.canCrouch, bools.canSlide, bools.sliding, bools.crouching, bools.sprinting = true, true, false, false, false, false -- set *a lot* booleans

                    slide(false) -- animation function

					break -- break the loop so that we dont keep checking
				end
			end

    	end

    end
end)

UIS.InputEnded:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then

       if input.KeyCode == keys.sprinting then -- did we stop pressing the sprinting key

        if bools.canSprint == true then return end -- double checks with sprinting idk how to explain this
        if bools.sprinting == false then return end -- making sure we are actually sprinting

        humanoid.WalkSpeed -= speeds.sprinting -- take the extra sprinting speed
        bools.canSprint, bools.canCrouch, bools.sprinting = true, true, false -- set booleans
			
        elseif input.KeyCode == keys.crouching then -- did we stop pressing the crouch key

        if bools.canCrouch == true then return end -- double checks with crouching idk how to explain this
        if bools.crouching == false then return end -- just making sure we are crouchign
        if bools.sprinting == true then return end -- making sure we arent sprinting

        humanoid.WalkSpeed += speeds.crouching -- give them their speed back
        bools.canSprint, bools.canCrouch, bools.crouching = true, true, false -- set bools

        crouch(false) -- fire animation function

    elseif input.KeyCode == keys.sliding then -- did we stop pressing the sliding key

            if bools.crouching == true then return end -- we arent crouching
            if bools.sprinting == true then return end -- we arent sprinting
            if bools.canSlide == true then return end -- double check thing again xd
            if bools.sliding == false then return end -- making sure we can slide
            
            humanoid.WalkSpeed -= speeds.sliding -- give them the speed back

            bools.canSprint, bools.canCrouch, bools.canSlide, bools.sliding, bools.crouching, bools.sprinting = true, true, false, false, false, false -- set *a lot* booleans

            slide(false) -- fire the animation function
       end

    end
end)