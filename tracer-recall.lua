-- Enhanced Tracer-Style Script with Ultra-Fast Dash
-- Created for SSickCodes
-- E = Recall | Q = Dash (3 charges, 25ms cooldown)

local player = game.Players.LocalPlayer
local StarterGui = game: GetService("StarterGui")

-- ========== EASY CONFIGURATION SECTION ==========
local CONFIG = {
    DASH_CHARGES = 3,
    DASH_DISTANCE = 25,
    DASH_COOLDOWN = 0.030,
    DASH_SPEED = 0.15,
    
    DASH_COLOR = Color3.fromRGB(0, 255, 255),
    TRAIL_COLOR = Color3.fromRGB(0, 150, 255),
    
    DASH_SOUND_ID = "rbxassetid://1238240145",
    SOUND_VOLUME = 0.0,
    
    DASH_KEY = Enum.KeyCode.Q,
    RECALL_KEY = Enum.KeyCode.E,
}
-- ========== END OF CONFIGURATION ==========

-- Simple notification function using Roblox built-in
local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 2,
    })
end

local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    local lastHealth = humanoid.Health
    local savedPosition = rootPart.CFrame
    local savedHealth = humanoid.Health
    local isRecalling = false
    local isDashing = false
    local connections = {}
    
    local dashCharges = CONFIG.DASH_CHARGES
    local isOnCooldown = false
    
    print("Script initialized!")
    print("Dash charges:  " .. dashCharges ..  "/" .. CONFIG.DASH_CHARGES)
    print("Cooldown: " .. (CONFIG.DASH_COOLDOWN * 1000) .. "ms")
    
    local function getMovementDirection()
        local moveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + Vector3.new(0, 0, -1)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector + Vector3.new(0, 0, 1)
        end
        if UserInputService: IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector + Vector3.new(-1, 0, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + Vector3.new(1, 0, 0)
        end
        
        if moveVector.Magnitude == 0 then
            moveVector = Vector3.new(0, 0, -1)
        end
        
        return moveVector. Unit
    end
    
    local function performDash()
        if isDashing then
            return
        end
        
        if isOnCooldown then
            print("Dash recharging...")
            return
        end
        
        if dashCharges <= 0 then
            print("Out of charges!  Recharging...")
            isOnCooldown = true
            
            task.spawn(function()
                task.wait(CONFIG.DASH_COOLDOWN)
                dashCharges = CONFIG.DASH_CHARGES
                isOnCooldown = false
                print("Dash RECHARGED! Charges: " .. dashCharges)
                
                -- Show notification
                notify("DASH RECHARGED", dashCharges .. " charges ready!")
            end)
            return
        end
        
        if not rootPart.Parent then
            return
        end
        
        isDashing = true
        dashCharges = dashCharges - 1
        
        local direction = getMovementDirection()
        local cameraCFrame = workspace.CurrentCamera.CFrame
        local worldDirection = (cameraCFrame. RightVector * direction.X) + (cameraCFrame.LookVector * -direction.Z)
        worldDirection = Vector3.new(worldDirection.X, 0, worldDirection.Z).Unit
        
        local targetPosition = rootPart.Position + (worldDirection * CONFIG.DASH_DISTANCE)
        local targetCFrame = CFrame.new(targetPosition) * CFrame.Angles(0, math. atan2(worldDirection.X, worldDirection.Z), 0)
        
        print("DASH!  Charges left: " .. dashCharges)
        
        local dashEffect = Instance.new("Part")
        dashEffect.Shape = Enum.PartType. Ball
        dashEffect.Material = Enum.Material.Neon
        dashEffect.Color = CONFIG.DASH_COLOR
        dashEffect.Size = Vector3.new(2, 2, 2)
        dashEffect.Anchored = true
        dashEffect. CanCollide = false
        dashEffect.Transparency = 0.3
        dashEffect.CFrame = rootPart.CFrame
        dashEffect.Parent = workspace
        
        local trail = Instance.new("Part")
        trail.Shape = Enum.PartType. Cylinder
        trail.Material = Enum.Material.Neon
        trail.Color = CONFIG. TRAIL_COLOR
        trail.Size = Vector3.new(CONFIG.DASH_DISTANCE, 1, 1)
        trail.Anchored = true
        trail. CanCollide = false
        trail.Transparency = 0.5
        trail.CFrame = CFrame.new(rootPart.Position, targetPosition) * CFrame.new(0, 0, -CONFIG.DASH_DISTANCE/2) * CFrame.Angles(0, math.pi/2, 0)
        trail.Parent = workspace
        
        local sound = Instance.new("Sound")
        sound.SoundId = CONFIG.DASH_SOUND_ID
        sound.Volume = CONFIG. SOUND_VOLUME
        sound.PlaybackSpeed = 1.5
        sound.Parent = rootPart
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 1)
        
        local tweenInfo = TweenInfo.new(CONFIG.DASH_SPEED, Enum.EasingStyle. Quad, Enum.EasingDirection.Out)
        
        local tween = TweenService: Create(rootPart, tweenInfo, {CFrame = targetCFrame})
        local effectTween = TweenService:Create(dashEffect, tweenInfo, {CFrame = targetCFrame, Transparency = 1, Size = Vector3.new(4, 4, 4)})
        local trailTween = TweenService:Create(trail, tweenInfo, {Transparency = 1})
        
        tween:Play()
        effectTween:Play()
        trailTween: Play()
        
        tween.Completed:Wait()
        
        dashEffect:Destroy()
        trail:Destroy()
        
        task.wait(0.05)
        isDashing = false
    end
    
    local function performRecall()
        if isRecalling then
            return
        end
        
        if not rootPart.Parent then
            return
        end
        
        isRecalling = true
        print("RECALL!")
        
        local recallEffect = Instance.new("Part")
        recallEffect.Shape = Enum.PartType. Ball
        recallEffect.Material = Enum.Material.Neon
        recallEffect.BrickColor = BrickColor.new("Bright blue")
        recallEffect.Size = Vector3.new(3, 3, 3)
        recallEffect.Anchored = true
        recallEffect.CanCollide = false
        recallEffect.Transparency = 0.3
        recallEffect.CFrame = rootPart.CFrame
        recallEffect.Parent = workspace
        
        local tweenInfo = TweenInfo. new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        local tween = TweenService: Create(rootPart, tweenInfo, {CFrame = savedPosition})
        local effectTween = TweenService:Create(recallEffect, tweenInfo, {CFrame = savedPosition, Transparency = 1})
        
        tween: Play()
        effectTween: Play()
        tween.Completed:Wait()
        
        humanoid.Health = savedHealth
        recallEffect:Destroy()
        
        print("Recall complete!")
        notify("RECALL COMPLETE", "Health restored!")
        
        task.wait(1)
        isRecalling = false
    end
    
    local inputConnection = UserInputService. InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == CONFIG.DASH_KEY then
            performDash()
        elseif input.KeyCode == CONFIG. RECALL_KEY then
            performRecall()
        end
    end)
    
    table.insert(connections, inputConnection)
    
    local healthLoopActive = true
    task.spawn(function()
        while healthLoopActive and humanoid. Parent do
            local currentHealth = humanoid.Health
            
            if currentHealth < lastHealth and currentHealth > 0 then
                savedPosition = rootPart.CFrame
                savedHealth = lastHealth
                
                local currentPos = rootPart.Position
                rootPart.CFrame = CFrame.new(
                    currentPos.X + math.random(-15, 15),
                    currentPos.Y,
                    currentPos.Z + math.random(-15, 15)
                )
                
                print("Damaged! Health: " .. currentHealth)
            end
            
            if currentHealth > lastHealth then
                savedPosition = rootPart.CFrame
                savedHealth = lastHealth
                
                local currentPos = rootPart.Position
                rootPart.CFrame = CFrame.new(
                    currentPos.X + math.random(-25, 25),
                    currentPos.Y,
                    currentPos.Z + math.random(-25, 25)
                )
                
                print("Regenerating! Health: " .. currentHealth)
            end
            
            lastHealth = currentHealth
            task.wait(0.005)
        end
    end)
    
    humanoid.Died:Connect(function()
        print("Character died - cleaning up...")
        healthLoopActive = false
        
        for _, connection in pairs(connections) do
            connection: Disconnect()
        end
    end)
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    setupCharacter(character)
end)

print("Ultra-Fast Dash Script Loaded!")
print("Press Q to Dash | Press E to Recall")
notify("TRACER SCRIPT", "Loaded!  Q=Dash E=Recall")
