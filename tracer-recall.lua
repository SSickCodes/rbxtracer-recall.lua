local player = game.Players.LocalPlayer

-- Function to setup the script for a character
local function setupCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    -- Only run for 7DaRaven
    if player.Name == "7DaRaven" then
        local lastHealth = humanoid.Health
        local savedPosition = rootPart.CFrame
        local savedHealth = humanoid.Health
        local isRecalling = false
        local connections = {}  -- Store connections to disconnect on death
        
        print("🔄 Script initialized for new character!")
        print("📍 Spawn position saved:", savedPosition)
        
        -- E Key Recall Function
        local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.KeyCode == Enum.KeyCode. E then
                if isRecalling then
                    print("⏳ Already recalling!")
                    return
                end
                
                if not rootPart.Parent then
                    print("❌ Cannot recall - character is dead!")
                    return
                end
                
                isRecalling = true
                print("⏮️ RECALL!  Flying back to previous position...")
                print("Saved Position:", savedPosition)
                print("Saved Health:", savedHealth)
                
                -- Create visual effect
                local recallEffect = Instance.new("Part")
                recallEffect.Shape = Enum.PartType. Ball
                recallEffect.Material = Enum.Material.Neon
                recallEffect.BrickColor = BrickColor.new("Bright blue")
                recallEffect.Size = Vector3.new(3, 3, 3)
                recallEffect.Anchored = true
                recallEffect. CanCollide = false
                recallEffect.Transparency = 0.3
                recallEffect.CFrame = rootPart.CFrame
                recallEffect.Parent = workspace
                
                -- Tween info
                local tweenInfo = TweenInfo. new(
                    0.8,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.InOut
                )
                
                -- Create tween to fly back
                local tween = TweenService:Create(rootPart, tweenInfo, {
                    CFrame = savedPosition
                })
                
                -- Tween the visual effect
                local effectTween = TweenService: Create(recallEffect, tweenInfo, {
                    CFrame = savedPosition,
                    Transparency = 1
                })
                
                -- Play both tweens
                tween:Play()
                effectTween:Play()
                
                -- Wait for tween to finish
                tween.Completed:Wait()
                
                -- Restore health
                humanoid.Health = savedHealth
                
                -- Cleanup
                recallEffect:Destroy()
                
                print("✅ Recall complete!  Health restored to:", savedHealth)
                
                wait(1)
                isRecalling = false
            end
        end)
        
        table.insert(connections, inputConnection)
        
        -- Health tracking loop
        local healthLoopActive = true
        spawn(function()
            while healthLoopActive and humanoid.Parent do
                local currentHealth = humanoid.Health
                
                -- Damage taken
                if currentHealth < lastHealth and currentHealth > 0 then
                    -- Save BEFORE teleporting
                    savedPosition = rootPart.CFrame
                    savedHealth = lastHealth
                    
                    local currentPos = rootPart.Position
                    local randomX = math.random(-15, 15)
                    local randomZ = math.random(-15, 15)
                    
                    rootPart.CFrame = CFrame.new(
                        currentPos.X + randomX,
                        currentPos. Y,
                        currentPos.Z + randomZ
                    )
                    
                    print("💥 Damaged! Teleported 15 studs.  Health:", currentHealth)
                    print("📍 Saved position for recall")
                end
                
                -- Health regen
                if currentHealth > lastHealth then
                    -- Save BEFORE teleporting
                    savedPosition = rootPart.CFrame
                    savedHealth = lastHealth
                    
                    local currentPos = rootPart.Position
                    local randomX = math.random(-25, 25)
                    local randomZ = math.random(-25, 25)
                    
                    rootPart.CFrame = CFrame.new(
                        currentPos.X + randomX,
                        currentPos.Y,
                        currentPos.Z + randomZ
                    )
                    
                    print("💚 Regenerating!  Teleported 25 studs.  Health:", currentHealth)
                    print("📍 Saved position for recall")
                end
                
                lastHealth = currentHealth
                wait(0.005)
            end
        end)
        
        -- Cleanup when character dies
        humanoid.Died:Connect(function()
            print("💀 Character died - cleaning up script...")
            healthLoopActive = false
            
            -- Disconnect all connections
            for _, connection in pairs(connections) do
                connection: Disconnect()
            end
            
            print("🔄 Script will reset on respawn!")
        end)
    end
end

-- Setup for current character if it exists
if player.Character then
    setupCharacter(player.Character)
end

-- Setup for new characters when player respawns
player.CharacterAdded:Connect(function(character)
    print("🎮 New character detected - reinitializing script...")
    wait(0.5)  -- Wait for character to fully load
    setupCharacter(character)
end)
