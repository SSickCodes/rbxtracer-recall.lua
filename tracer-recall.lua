local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character: WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Only run for 7DaRaven
if player.Name == "7DaRaven" then
    local lastHealth = humanoid.Health
    local savedPosition = rootPart.CFrame
    local savedHealth = humanoid.Health
    local isRecalling = false
    
    -- E Key Recall Function
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input. KeyCode == Enum.KeyCode.E then
            if isRecalling then
                print("⏳ Already recalling!")
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
            recallEffect. Anchored = true
            recallEffect.CanCollide = false
            recallEffect. Transparency = 0.3
            recallEffect.CFrame = rootPart.CFrame
            recallEffect.Parent = workspace
            
            -- Tween info
            local tweenInfo = TweenInfo.new(
                0.8,
                Enum. EasingStyle.Quad,
                Enum.EasingDirection.InOut
            )
            
            -- Create tween to fly back
            local tween = TweenService:Create(rootPart, tweenInfo, {
                CFrame = savedPosition
            })
            
            -- Tween the visual effect
            local effectTween = TweenService:Create(recallEffect, tweenInfo, {
                CFrame = savedPosition,
                Transparency = 1
            })
            
            -- Play both tweens
            tween:Play()
            effectTween:Play()
            
            -- Wait for tween to finish
            tween.Completed:Wait()
            
            -- Restore health
            humanoid. Health = savedHealth
            
            -- Cleanup
            recallEffect:Destroy()
            
            print("✅ Recall complete! Health restored to:", savedHealth)
            
            wait(1)
            isRecalling = false
        end
    end)
    
    -- Health tracking loop
    spawn(function()
        while true do
            local currentHealth = humanoid.Health
            
            -- Damage taken
            if currentHealth < lastHealth then
                -- Save BEFORE teleporting
                savedPosition = rootPart.CFrame
                savedHealth = lastHealth
                
                local currentPos = rootPart.Position
                local randomX = math.random(-15, 15)
                local randomZ = math.random(-15, 15)
                
                rootPart.CFrame = CFrame.new(
                    currentPos.X + randomX,
                    currentPos.Y,
                    currentPos.Z + randomZ
                )
                
                print("💥 Damaged!  Teleported 15 studs. Health:", currentHealth)
                print("📍 Saved position for recall")
            end
            
            -- Health regen
            if currentHealth > lastHealth then
                -- Save BEFORE teleporting
                savedPosition = rootPart. CFrame
                savedHealth = lastHealth
                
                local currentPos = rootPart.Position
                local randomX = math.random(-25, 25)
                local randomZ = math.random(-25, 25)
                
                rootPart.CFrame = CFrame.new(
                    currentPos.X + randomX,
                    currentPos.Y,
                    currentPos.Z + randomZ
                )
                
                print("💚 Regenerating! Teleported 25 studs. Health:", currentHealth)
                print("📍 Saved position for recall")
            end
            
            lastHealth = currentHealth
            wait(0.005)
        end
    end)
end
