game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "c17.fucker",
    Text = "Thanks for using c17.fucker!"
})

local libary = loadstring(game:HttpGet("https://raw.githubusercontent.com/imagoodpersond/puppyware/main/lib"))()
local NotifyLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/imagoodpersond/puppyware/main/notify"))()
local Notify = NotifyLibrary.Notify
getgenv().closest = "closest to mouse"
getgenv().color = Color3.fromRGB(255, 255, 255)

--// Service Handler \\--
local GetService = setmetatable({}, {
    __index = function(self, key)
        return game:GetService(key)
    end
})

pcall(function()
    local ScriptContext = cloneref(game:GetService("ScriptContext"))
    ScriptContext:SetTimeout(0.15)
    ScriptContext.Error:Connect(function()end)
end)

local Window = libary:new({name = "c17.fucker", accent = Color3.fromRGB(244, 95, 115), textsize = 13})
local AimingTab = Window:page({name = "c17.main"})

local SAimSection = AimingTab:section({name = "melee", side = "left",size = 180})
local plrs = cloneref(game:GetService("Players")) or game:GetService("Players")
local rs = cloneref(game:GetService("RunService")) or game:GetService("RunService")
local plr = plrs.LocalPlayer
local target1 = nil;
getgenv().highlight = false

function gettarget()
    if getgenv().closest == "closest to mouse" then 
        return plr:GetMouse().Hit.Position
    end
    return plr.Character:WaitForChild("HumanoidRootPart").Position
end

function getcp()
	local maxdis = math.huge
	local target = nil
	for i,v in next, plrs:GetChildren() do
		if v.Character and v ~= plr and v.Character.HumanoidRootPart and v.Character.Humanoid.Health ~= 0 and v.Team ~= plr.Team then
			local mag = (gettarget() - v.Character.HumanoidRootPart.Position).Magnitude
			if mag < maxdis then
				maxdis = mag
				target = v
			end
		end
	end
	return target
end

rs.RenderStepped:Connect(function()
    if getcp() and getcp().Character then 
        target1 = getcp()
    end
    if getgenv().highlight and target1 and target1.Character then 
        local h = Instance.new("Highlight", target1.Character)
        h.FillColor = getgenv().color
        h.OutlineColor = getgenv().color
        game:GetService("Debris"):AddItem(h, 0.1)
    end
end)



getgenv().sim = false
getgenv().simcolor = Color3.fromRGB(255, 255, 25)
getgenv().rainbowsim = false
local function randomRGB()
    return Color3.fromRGB(
        Random.new():NextInteger(0, 255),
        Random.new():NextInteger(0, 255),
        Random.new():NextInteger(0, 255)
    )
end

function findplayer(test)
    for i,v in next, game.Players:GetPlayers() do 
        if string.find(string.lower(tostring(v)), test) then 
           return v
           end
     end
     return false
end

function simbeam()
    task.spawn(function()
        local part = Instance.new("Part", workspace.TeleportParts)
        part.Size = Vector3.new(0.2, 0.2, (plr.Character.HumanoidRootPart.Position - target1.Character.Head.Position).Magnitude) 
        part.Anchored = true
        part.CanCollide = false
        
        if not getgenv().rainbowsim then 
            part.Color = getgenv().simcolor
        else
            part.Color = randomRGB() 
        end
        
        part.Material = Enum.Material.Neon
        
        local toolHandle = plr.Character:FindFirstChildWhichIsA("Tool") and plr.Character:FindFirstChildWhichIsA("Tool").Handle
        if toolHandle and toolHandle.Parent:FindFirstChild("MeleeConfiguration") then
            local midpoint = (toolHandle.Position + target1.Character.Head.Position) / 2
            part.Position = midpoint
            part.CFrame = CFrame.new(midpoint, target1.Character.Head.Position)
        else
            return
        end
        
        task.wait(0.5)
        part:Destroy()
    end)
end

getgenv().killaura = false
SAimSection:toggle({name = "toggle killaura", def = false, callback = function(Boolean)
    getgenv().killaura = Boolean
    task.spawn(function()
        while getgenv().killaura and task.wait() do 
            local ec, er = pcall(function()
                local ohInstance1 = target1.Character.Head
                local ohInstance2 = target1.Character.Humanoid
                game:GetService("ReplicatedStorage").eTech.Remotes.MeleeDamage:FireServer(ohInstance1, ohInstance2)
                
                if plr.Character:FindFirstChildOfClass("Tool") and plr.Character:FindFirstChildOfClass("Tool"):FindFirstChild("MeleeConfiguration") then 
                    local ohString1 = "Hit"
                    game:GetService("ReplicatedStorage").eTech.Remotes.MeleeEffect:FireServer(ohString1)
                    plr.Character:FindFirstChildOfClass("Tool"):FindFirstChild("MeleeConfiguration").Sounds.Hit:Play() -- Fixed syntax here
                end
                
                if getgenv().sim then 
                    simbeam()
                end
            end)
            if er then 
                print(tostring(er))
            end
        end
    end)
end})

function getplrs()
    local plrs111 = {}
    for _, v in ipairs(game:GetService("Players"):GetChildren()) do 
        table.insert(plrs111, v.Name) 
    end
    return plrs111
end

getgenv().targettingnow = false
getgenv().currenttarget = nil
getgenv().interval = 0
local function update()
    local playerList = getplrs()
    SAimSection:dropdown({
        name = "target player", 
        def = game:GetService("Players").LocalPlayer.Name, 
        max = 10, 
        options = playerList, 
        callback = function(part)
            getgenv().currenttarget = part
        end
    })
end
update()
game:GetService("Players").PlayerAdded:Connect(updateDropdown)
game:GetService("Players").PlayerRemoving:Connect(updateDropdown)


function gettool()
    for i,v in next, plr.Backpack:GetChildren() do 
        if v:IsA("Tool") and v:FindFirstChild("MeleeConfiguration") then 
            return v
        end
    end
    return nil
end

getgenv().notifyondeath = false

SAimSection:slider({name = "target interval", def = 0, max = 10, min = 0, rounding = true, callback = function(Value)
    getgenv().interval = Value
end})

getgenv().targethp = false
SAimSection:toggle({
    name = "kill target", 
    def = false, 
    callback = function(Boolean)
        getgenv().targettingnow = Boolean
        task.spawn(function()
            local ogp = game:GetService("Players").LocalPlayer.Character.Humanoid.RootPart.Position
            if game:GetService("Players"):FindFirstChild(getgenv().currenttarget) then
              pcall(function()
                if getgenv().notifyondeath then 
                    game:GetService("Players"):FindFirstChild(getgenv().currenttarget).Character.Humanoid.Died:Connect(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "c17.fucker",
                            Text = "Succesfully killed: " .. tostring(game:GetService("Players"):FindFirstChild(getgenv().currenttarget))
                        })
                    end)
                end
              end)
              task.spawn(function()
                while getgenv().targethp and task.wait(1) and getgenv().targettingnow do 
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "c17.fucker",
                        Text = "Target HP: " .. tostring(game:GetService("Players"):FindFirstChild(getgenv().currenttarget).Character.Humanoid.Health)
                    })
                end
              end)
                while getgenv().targettingnow and task.wait(getgenv().interval) do 
                    pcall(function()
                        workspace.CurrentCamera.CameraSubject = game:GetService("Players"):FindFirstChild(getgenv().currenttarget).Character
                        local targetnew = game:GetService("Players"):FindFirstChild(getgenv().currenttarget)
                        if targetnew.Character.Humanoid.Health == 0 then 
                            getgenv().targettingnow = false
                        end
                        if gettool() then 
                            plr.Character.Humanoid:EquipTool(gettool())
                        end
                        task.spawn(function()
                            if getgenv().sim then 
                                local part = Instance.new("Part", workspace.TeleportParts)
                                part.Size = Vector3.new(0.2, 0.2, (plr.Character.HumanoidRootPart.Position - game:GetService("Players"):FindFirstChild(getgenv().currenttarget).Character.Head.Position).Magnitude) 
                                part.Anchored = true
                                part.CanCollide = false
                                
                                if not getgenv().rainbowsim then 
                                    part.Color = getgenv().simcolor
                                else
                                    part.Color = randomRGB() 
                                end
                                
                                part.Material = Enum.Material.Neon
                                
                                local toolHandle = plr.Character:FindFirstChildWhichIsA("Tool") and plr.Character:FindFirstChildWhichIsA("Tool").Handle
                                if toolHandle and toolHandle.Parent:FindFirstChild("MeleeConfiguration") then
                                    local midpoint = (toolHandle.Position + target1.Character.Head.Position) / 2
                                    part.Position = midpoint
                                    part.CFrame = CFrame.new(midpoint, target1.Character.Head.Position)
                                else
                                    return
                                end
                                
                                task.wait(0.5)
                                part:Destroy()
                            end
                        end)
                        plr.Character.HumanoidRootPart.CFrame = targetnew.Character.HumanoidRootPart.CFrame * CFrame.new(0, -10, 0)

                        local ohInstance1 = targetnew.Character.Head
                        local ohInstance2 = targetnew.Character.Humanoid
                        game:GetService("ReplicatedStorage").eTech.Remotes.MeleeDamage:FireServer(ohInstance1, ohInstance2)

                        local ohString1 = "Hit"
                        game:GetService("ReplicatedStorage").eTech.Remotes.MeleeEffect:FireServer(ohString1)
                        plr.Character:FindFirstChildOfClass("Tool"):FindFirstChild("MeleeConfiguration").Sounds.Hit:Play()
                    end)
                end
                task.wait()
            
                for i = 1, 30 do
                    workspace.CurrentCamera.CameraSubject = game:GetService("Players").LocalPlayer.Character
                    task.wait(0.05)
                    plr.Character.HumanoidRootPart.CFrame = CFrame.new(ogp)
                end
            end
        end)
    end
})

SAimSection:toggle({name = "notify on death", def = false, callback = function(Boolean)
    getgenv().notifyondeath = Boolean
end})

SAimSection:toggle({name = "notify hp", def = false, callback = function(Boolean)
    getgenv().targethp = Boolean
end})


local movesec = AimingTab:section({name = "movement", side = "left",size = 205})

getgenv().modifyspeed = false
getgenv().walkSpeed = 13
getgenv().runSpeed = 21

movesec:slider({name = "runSpeed", def = 21, max = 50, min = 0, rounding = true, callback = function(Value)
    getgenv().runSpeed = Value
end})

movesec:slider({name = "walkSpeed", def = 13, max = 50, min = 0, rounding = true, callback = function(Value)
    getgenv().walkSpeed = Value
end})

getgenv().spinbotpower = 50

movesec:slider({name = "spinbot power", def = 50, max = 2000, min = 0, rounding = true, callback = function(Value)
    getgenv().spinbotpower = Value
end})

movesec:toggle({name = "modify speed", def = false, callback = function(Boolean)
    getgenv().modifyspeed = Boolean
    if not getgenv().modifyspeed  then 
        for i,v in next, getgc(true) do
            if type(v) == 'table' and rawget(v, "regen") then
                rawset(v, "walkSpeed", 13)
                rawset(v, "runSpeed", 21)
                 end
            end
        else
            for i,v in next, getgc(true) do
                if type(v) == 'table' and rawget(v, "regen") then
                    rawset(v, "walkSpeed", getgenv().walkSpeed)
                    rawset(v, "runSpeed", getgenv().runSpeed)
                     end
                end
    end
end})
getgenv().spoof = true


task.spawn(function()
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldindex = gmt.__index
    gmt.__index = newcclosure(function(self,b)
    if b == "WalkSpeed" and getgenv().spoof then
    return 13
    end
    return oldindex(self,b)
    end)
end)

getgenv().spinbotspinning = false
movesec:toggle({name = "toggle spinbot", def = false, callback = function(Boolean)
    getgenv().spinbotspinning = Boolean
    task.spawn(function()
     while getgenv().spinbotspinning and task.wait() do
         pcall(function()
             local hrp = plr.Character:WaitForChild("HumanoidRootPart")
             hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(getgenv().spinbotpower), 0)
         end)
     end
    end)
 end})

movesec:toggle({name = "spoof speed", def = true, callback = function(Boolean)
    getgenv().spoof = Boolean
end})



movesec:button({name = "fly (x)", callback = function()
    local mouse = game.Players.LocalPlayer:GetMouse()
    localplayer = game.Players.LocalPlayer
    if workspace:FindFirstChild("Core") then
     workspace.Core:Destroy()
    end
    local Core = Instance.new("Part", workspace.TeleportParts)
    Core.Name = "Core"
    Core.Size = Vector3.new(0.05, 0.05, 0.05)
    spawn(function()
     Core.Parent = workspace
     local Weld = Instance.new("Weld", Core)
     Weld.Part0 = Core
     Weld.Part1 = localplayer.Character.LowerTorso
     Weld.C0 = CFrame.new(0, 0, 0)
    end)
    workspace:WaitForChild("Core")
    local torso = workspace.Core
    flying = true
    local speed=10
    local keys={a=false,d=false,w=false,s=false}
    local e1
    local e2
    local function start()
    local pos = Instance.new("BodyPosition",torso)
    local gyro = Instance.new("BodyGyro",torso)
    pos.Name="EPIXPOS"
    pos.maxForce = Vector3.new(math.huge, math.huge, math.huge)
    pos.position = torso.Position
    gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    gyro.cframe = torso.CFrame
    repeat wait() localplayer.Character.Humanoid.PlatformStand = true
     local new=gyro.cframe - gyro.cframe.p + pos.position
     if not keys.w and not keys.s and not keys.a and not keys.d then
      speed=5
     end
     if keys.w then
      new = new + workspace.CurrentCamera.CoordinateFrame.lookVector * speed
      speed=speed+0
     end
     if keys.s then
      new = new - workspace.CurrentCamera.CoordinateFrame.lookVector * speed
      speed=speed+0
     end
     if keys.d then
      new = new * CFrame.new(speed,0,0)
      speed=speed+0
     end
     if keys.a then
      new = new * CFrame.new(-speed,0,0)
      speed=speed+0
     end
     if speed>10 then
      speed=5
     end
     pos.position=new.p
     if keys.w then
      gyro.cframe = workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(-math.rad(speed*0),0,0)
     elseif keys.s then
      gyro.cframe = workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(math.rad(speed*0),0,0)
     else
      gyro.cframe = workspace.CurrentCamera.CoordinateFrame
     end
    until flying == false
    if gyro then gyro:Destroy() end
    if pos then pos:Destroy() end
    flying=false
    localplayer.Character.Humanoid.PlatformStand=false
    speed=10
    end
    e1=mouse.KeyDown:connect(function(key)
     if not torso or not torso.Parent then flying=false e1:disconnect() e2:disconnect() return end
     if key=="w" then
      keys.w=true
     elseif key=="s" then
      keys.s=true
     elseif key=="a" then
      keys.a=true
     elseif key=="d" then
      keys.d=true
     elseif key=="x" then
      if flying==true then
       flying=false
      else
       flying=true
       start()
      end
     end
    end)
    e2=mouse.KeyUp:connect(function(key)
     if key=="w" then
      keys.w=false
     elseif key=="s" then
      keys.s=false
     elseif key=="a" then
      keys.a=false
     elseif key=="d" then
      keys.d=false
     end
    end)
    start()
   end})
   local lad = {"Head", "UpperTorso", "HumanoidRootPart", "RightUpperLeg", "RightUpperArm", "RightLowerLeg", "RightLowerArm", "RightHand", "RightFoot", "LowerTorso", "LeftUpperLeg", "LeftUpperArm", "LeftLowerLeg", "LeftLowerArm", "LeftHand", "LeftHand"}
 
   getgenv().silentaim = false
   getgenv().hitpart = "Head"
   getgenv().range = 1000
   getgenv().randomredire = false
   getgenv().wallbang = false
   task.spawn(function()
    if hookmetamethod then
    local saimh;
    saimh = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
    local method = getnamecallmethod():lower()
    local args = {...}
    if tostring(method) == "findpartonraywithignorelist" and getgenv().silentaim and target1.Character and target1 and string.lower(tostring(getfenv(0).script)) == "directory" then
    local targetPosition = target1.Character[getgenv().hitpart].Position
    if getgenv().randomredire then
    targetPosition = target1.Character[lad[math.random(1, #lad)]].Position
    end
    local origin = args[1].Origin
    local direction = (targetPosition - origin).Unit
        args[1] = Ray.new(origin, direction * getgenv().range)
     if getgenv().wallbang then
        args[2] = {workspace.VisceratorDispensers, workspace.Trash, workspace.TempRays, workspace.TeleportParts, workspace.Targets, workspace.Surface, workspace.Striders, workspace.Sounds, workspace.ShopAreas, workspace.Sewers, workspace.SecurityCameras, workspace.Scanners, workspace.Rollermines, workspace.RollerSpawns, workspace.RebelLockers, workspace.RazorShields, workspace.Props, workspace.ProductionLines, workspace.MissileMagnets, workspace.Mines, workspace.MineSpawns, workspace.Manhacks, workspace.JuryTPs, workspace.JobInteracts, workspace.Items, workspace.InfraredPoints, workspace.Ignore, workspace.Global_Ambience, workspace.GamepassParts, workspace.EvoSpawners, workspace.EmplacementGuns, workspace.Elevator, workspace.Effects, workspace.DeployedMHs, workspace.Config, workspace.Citizen, workspace.Choosing, workspace.Chargers, workspace.CameraConsoles, workspace.ArmouryDispenser, workspace["Apartment Doors"]}
        
    end
    if getgenv().sim then 
        task.spawn(function()
            local part = Instance.new("Part", workspace.TeleportParts)
            part.Size = Vector3.new(0.2, 0.2, (plr.Character.HumanoidRootPart.Position - target1.Character.Head.Position).Magnitude) 
            part.Anchored = true
            part.CanCollide = false
            
            if not getgenv().rainbowsim then 
                part.Color = getgenv().simcolor
            else
                part.Color = randomRGB() 
            end
            
            part.Material = Enum.Material.Neon
            

                local midpoint = (origin + target1.Character.Head.Position) / 2
                part.Position = midpoint
                part.CFrame = CFrame.new(midpoint, target1.Character.Head.Position)

            task.wait(0.5)
            part:Destroy()
        end)
    end
    return saimh(Self, table.unpack(args))
    end
    return saimh(Self, ...)
    end))
end
end)

   local silentaim = AimingTab:section({name = "silent aim", side = "right",size = 160})

   silentaim:slider({name = "silent aim range", def = 1000, max = 100000, min = 0, rounding = true, callback = function(Value)
    getgenv().range = Value
end})

silentaim:dropdown({name = "hit part", def = "Head", max = 5, options = {"Head", "UpperTorso", "HumanoidRootPart", "RightUpperLeg", "RightUpperArm", "RightLowerLeg", "RightLowerArm", "RightHand", "RightFoot", "LowerTorso", "LeftUpperLeg", "LeftUpperArm", "LeftLowerLeg", "LeftLowerArm", "LeftHand", "LeftHand"}, callback = function(part)
    getgenv().hitpart = part
end})

silentaim:toggle({name = "toggle silent aim", def = false, callback = function(Boolean)
    getgenv().silentaim = Boolean
end})

silentaim:toggle({name = "toggle random redirection", def = false, callback = function(Boolean)
    getgenv().randomredire = Boolean
end})

silentaim:toggle({name = "toggle wallbang", def = false, callback = function(Boolean)
    getgenv().wallbang = Boolean
end})

local settings = AimingTab:section({name = "settings", side = "right",size = 170})


settings:toggle({name = "rainbow beam", def = false, callback = function(Boolean)
    getgenv().rainbowsim = Boolean
end})

settings:toggle({name = "simulate beam", def = false, callback = function(Boolean)
    getgenv().sim = Boolean
end})

settings:colorpicker({name = "beam color", cpname = "", def = Color3.new(255, 255, 255), callback = function(color)
    getgenv().simcolor = color
end})


settings:dropdown({name = "targetting", def = "closest to mouse", max = 2, options = {"closest to mouse", "closest to player"}, callback = function(part)
    getgenv().closest = part
end})


settings:colorpicker({name = "highlight color", cpname = "", def = Color3.new(255, 255, 255), callback = function(color)
    getgenv().color = color
end})


settings:toggle({name = "highlight target", def = false, callback = function(Boolean)
    getgenv().highlight = Boolean
end})



local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/VaxKs/gfe/main/Esp.lua"))()
getgenv().global = getgenv()
function global.declare(self, index, value, check)
    if self[index] == nil then
        self[index] = value
    elseif check then
        local methods = {
            "remove",
            "Disconnect"
        }
        for _, method in methods do
            pcall(function()
                value[method](value)
            end)
        end
    end
    return self[index]
end

declare(features, "visuals", {
    ["enabled"] = true,
    ["teamCheck"] = false,
    ["teamColor"] = true,
    ["renderDistance"] = 2000,
    ["boxes"] = {
        ["enabled"] = true,
        ["color"] = Color3.fromRGB(255, 255, 255),
        ["outline"] = {
            ["enabled"] = true,
            ["color"] = Color3.fromRGB(0, 0, 0),
        },
        ["filled"] = {
            ["enabled"] = true,
            ["color"] = Color3.fromRGB(255, 255, 255),
            ["transparency"] = 0.25
        },
    },
    ["names"] = {
        ["enabled"] = true,
        ["color"] = Color3.fromRGB(255, 255, 255),
        ["outline"] = {
            ["enabled"] = true,
            ["color"] = Color3.fromRGB(0, 0, 0),
        },
    },
    ["health"] = {
        ["enabled"] = true,
        ["color"] = Color3.fromRGB(0, 255, 0),
        ["colorLow"] = Color3.fromRGB(255, 0, 0),
        ["outline"] = {
            ["enabled"] = false,
            ["color"] = Color3.fromRGB(0, 255, 0)
        },
        ["text"] = {
            ["enabled"] = false,
            ["outline"] = {
                ["enabled"] = false,
            },
        }
    },
    ["distance"] = {
        ["enabled"] = true,
        ["color"] = Color3.fromRGB(255, 255, 255),
        ["outline"] = {
            ["enabled"] = true,
            ["color"] = Color3.fromRGB(0, 0, 0),
        },
    },
    ["weapon"] = {
        ["enabled"] = true,
        ["color"] = Color3.fromRGB(255, 255, 255),
        ["outline"] = {
            ["enabled"] = true,
            ["color"] = Color3.fromRGB(0, 0, 0),
        },
    }
})


local visuals = features.visuals

visuals.weapon.enabled = false
visuals.distance.enabled = false
visuals.health.enabled = false
visuals.names.enabled = false
visuals.health.text.enabled = false
visuals.boxes.enabled = false


local visualsta = AimingTab:section({name = "visuals", side = "right",size = 170})



visualsta:toggle({name = "enable team color", def = true, callback = function(Boolean)
    visuals.teamColor = Boolean
    visuals.enabled = true
end})


visualsta:toggle({name = "enable team check", def = false, callback = function(Boolean)
    visuals.teamCheck = Boolean
    visuals.enabled = true
end})

visualsta:toggle({name = "box esp", def = false, callback = function(Boolean)
    visuals.boxes.enabled = Boolean
    visuals.enabled = true
end})

visualsta:colorpicker({name = "box fill", cpname = "", def = Color3.new(255, 255, 255), callback = function(color)
    visuals.boxes.fill.color = color
    visuals.enabled = true
end})

visualsta:colorpicker({name = "box outline", cpname = "", def = Color3.new(255, 255, 255), callback = function(color)
end})

visualsta:toggle({name = "health esp", def = false, callback = function(Boolean)
    visuals.health.enabled = Boolean
    visuals.enabled = true
end})

visualsta:colorpicker({name = "health color", cpname = "", def = Color3.new(255, 255, 255), callback = function(color)
    visuals.health.color = color
    visuals.enabled = true
end})

local gm = AimingTab:section({name = "gun mods", side = "left",size = 120})

function hashguns()
    task.spawn(function()
        for i,v in next, game:GetService("Players").LocalPlayer.Character:GetChildren() do 
            if v:IsA("Tool") and v:FindFirstChild("BlasterSettings") then 
                v.Name = tostring(math.random(1,900))
            end
        end
    end)
    for i,v in next, game:GetService("Players").LocalPlayer.Backpack:GetChildren() do 
        if v:IsA("Tool") and v:FindFirstChild("BlasterSettings") then 
            v.Name = tostring(math.random(1,900))
        end
    end
    return
end

function getguns()
    local guns = {}
    task.spawn(function()
        for i,v in next, game:GetService("Players").LocalPlayer.Character:GetChildren() do 
            if v:IsA("Tool") and v:FindFirstChild("BlasterSettings") then 
                table.insert(guns, v)
            end
        end
    end)
    for i,v in next, game:GetService("Players").LocalPlayer.Backpack:GetChildren() do 
        if v:IsA("Tool") and v:FindFirstChild("BlasterSettings") then 
            table.insert(guns, v)
        end
    end
    return guns
end

getgenv().modmode = "Auto"

gm:dropdown({
    name = "modify mode", 
    def = "Auto", 
    max = 3, 
    options = {"Auto", "Semi", "Shotgun"}, 
    callback = function(part)
        getgenv().modmode = part
        hashguns()
        for i,v in next, getguns() do 
            pcall(function()
                v:FindFirstChild("BlasterSettings").Settings.Mode.Value = getgenv().modmode
            end)
        end
    end
})

gm:slider({name = "modify spread", def = 0, max = 1000, min = 0, rounding = true, callback = function(Value)
    hashguns()
    for i,v in next, getguns() do 
        pcall(function()
            v:FindFirstChild("BlasterSettings").Stats.Spread.Value = Value
        end)
    end
end})
local balls = require(game:GetService("Players").LocalPlayer.PlayerScripts.eTech.Services.ToolsService)
getgenv().infammo = false
gm:toggle({name = "infinite ammo", def = false, callback = function(Boolean)
    getgenv().infammo = Boolean
    task.spawn(function()
        while getgenv().infammo and task.wait(0.5) do 
pcall(function()
   for i,v in next, getguns() do 
    pcall(function()
        if v:FindFirstChild("ServerAmmo") then 
            v:FindFirstChild("ServerAmmo").Value = v:FindFirstChild("BlasterSettings").Stats.MaxAmmo.Value
        end
        if v:FindFirstChild("Ammo") then 
            v:FindFirstChild("Ammo").Value = v:FindFirstChild("BlasterSettings").Stats.MaxAmmo.Value
        end
    end)
   end
    game:GetService("ReplicatedStorage").eTech.Remotes.BlasterReload:FireServer()
end)
        end
    end)

    pcall(function()
        if Boolean then 
            debug.setconstant(balls.Objects.BlasterWeapon.Fire, 7, 0)
                else
                    debug.setconstant(balls.Objects.BlasterWeapon.Fire, 7, 1)
                end
    end)
end})

local misc = Window:page({name = "c17.misc"})

local practical = misc:section({name = "quick trigger", side = "left",size = 130})

local ts = cloneref(game:GetService("TweenService")) or game:GetService("TweenService")

practical:button({name = "become rebel", callback = function()
    task.spawn(function()
        local ogp = plr.Character:WaitForChild("Humanoid").RootPart.Position
        local hrp = plr.Character:WaitForChild("HumanoidRootPart")
        hrp.CFrame = hrp.CFrame * CFrame.new(0, -20, 0)
        local cf = CFrame.new(-189.872269, 125.57003, 1446.0553, -0.998132467, 0, 0.0610874444, 0, 1, 0, -0.0610874444, 0, -0.998132467)
        local test = ts:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = cf})
        test:Play()
        test.Completed:Connect(function()
hrp.CFrame = CFrame.new(-189.872269, 125.57003, 1446.0553, -0.998132467, 0, 0.0610874444, 0, 1, 0, -0.0610874444, 0, -0.998132467)
for i = 1,5 do
task.wait(0.05)
local ohString1 = "REBEL"
game:GetService("ReplicatedStorage").eTech.Remotes.ChangeClothes:FireServer(ohString1)
end
task.wait()
local s2 = ts:Create(hrp, TweenInfo.new(2, Enum.EasingStyle.Linear), {CFrame = CFrame.new(ogp)})
s2:Play()
        end)
    end)
   end})
   

   practical:button({name = "steal register", callback = function()
    task.spawn(function()
        local ogp = plr.Character:WaitForChild("Humanoid").RootPart.Position
        local hrp = plr.Character:WaitForChild("HumanoidRootPart")
        if (workspace.Surface["City-17"].cashregister01a:FindFirstChildWhichIsA("ProximityPrompt").Enabled == false) then
game:GetService("StarterGui"):SetCore("SendNotification", {
Title = "c17.fucker",
Text = "Register has not spawned/is in cooldown!"
})
            return
        end
        for i = 1,5 do
        task.wait(0.05)
        hrp.CFrame = workspace.Surface["City-17"].cashregister01a.CFrame * CFrame.new(0, -10, 0)
        fireproximityprompt(workspace.Surface["City-17"].cashregister01a:FindFirstChildWhichIsA("ProximityPrompt"), 10)
        end
        task.wait()
        hrp.CFrame = CFrame.new(ogp)
    end)
   end})
   

   practical:button({name = "trigger green card", callback = function()
    task.spawn(function()
        local ogp = plr.Character:WaitForChild("Humanoid").RootPart.Position
        local hrp = plr.Character:WaitForChild("HumanoidRootPart")
        local cf = workspace.Ignore.Map.LegalBorderCheck.CFrame * CFrame.new(0, -15, 0)
        local test = ts:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = cf})
        test:Play()
        test.Completed:Connect(function()
            ts:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(ogp)}):Play()
        end)
    end)
   end})
   
   practical:button({name = "trigger red card", callback = function()
    task.spawn(function()
        local ogp = plr.Character:WaitForChild("Humanoid").RootPart.Position
        local hrp = plr.Character:WaitForChild("HumanoidRootPart")
        local cf = workspace.Ignore.Map.IllegalBorderCheck.CFrame * CFrame.new(0, -15, 0)
        local test = ts:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = cf})
        test:Play()
        test.Completed:Connect(function()
            ts:Create(hrp, TweenInfo.new(1, Enum.EasingStyle.Linear), {CFrame = CFrame.new(ogp)}):Play()
        end)
    end)
   end})
   
   local anims = misc:section({name = "animations", side = "left",size = 140})
   local animationid = "rbxassetid://11148924627"
   anims:dropdown({
    name = "play animation", 
    def = "Kneeling", 
    max = 10, 
    options = {"Kneeling", "Cleaning", "Lockpicking"}, 
    callback = function(part)
        if part == "Kneeling" then 
            animationid = "rbxassetid://11148924627"
        elseif part == "Cleaning" then 
            animationid = "rbxassetid://15618706150"
        elseif part == "Lockpicking" then 
            animationid = "rbxassetid://15618735458"
        end
    end
})

getgenv().animspeed = 0
getgenv().speedenabled = false
local tra;
anims:toggle({name = "play animation", def = false, callback = function(Boolean)
    if Boolean then 
        local anim = Instance.new("Animation", workspace)
        anim.AnimationId = animationid
        if getgenv().speedenabled then 
        tra:AdjustSpeed(getgenv().animspeed)
        end
        tra = plr.Character.Humanoid:LoadAnimation(anim)
        tra:Play()
    else
        if tra then 
            tra:Stop()
        end
    end
end})


anims:toggle({name = "use adjust speed", def = false, callback = function(Boolean)
    getgenv().speedenabled = Boolean
end})

anims:slider({name = "adjust speed", def = 0, max = 10, min = 0, rounding = true, callback = function(Value)
    getgenv().animspeed = Value
end})

local detection = misc:section({name = "trolling", side = "right",size = 180})
getgenv().detect = false
getgenv().shake = false
getgenv().action = "Notify"
task.spawn(function()
    local hi;

    hi = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
        local args = {...}
        local method = getnamecallmethod():lower()
        if tostring(Self) == "CmdrEvent" and tostring(method) == "fireserver" and getgenv().detect then
            function getspectate()
                for i,v in next, args[1] do
                    return v
                end
            end
            local admin = getspectate()
              if getgenv().action == "Notify" then 
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "c17.fucker",
                    Text = "You are being spectated by " .. tostring(admin)
                 })
              end

              if getgenv().action == "Kick" then 
                plr:Kick("Spectate Detection: " .. tostring(admin))
              end

            return hi
            end
        return hi(Self, ...)
        end))
end)

detection:dropdown({
    name = "spectate action", 
    def = "Notify", 
    max = 2, 
    options = {"Notify", "Kick"}, 
    callback = function(part)
        getgenv().action = part
    end
})

detection:toggle({name = "use spectate detection", def = false, callback = function(Boolean)
    getgenv().detect = Boolean
end})
getgenv().spower = 500
detection:slider({name = "seizure power", def = 0, max = 1000, min = 0, rounding = true, callback = function(Value)
    getgenv().spower = Value
end})

detection:toggle({name = "toggle seizure", def = false, callback = function(Boolean)
    getgenv().shake = Boolean
    task.spawn(function()
        while getgenv().shake do
            local offsetX = math.random(getgenv().spower, getgenv().spower)
            local offsetY = math.random(getgenv().spower, getgenv().spower)
            local offsetZ = math.random(getgenv().spower, getgenv().spower)
        
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.new(offsetX, offsetY, offsetZ)
        
            local rotationX = math.random(getgenv().spower, getgenv().spower)
            local rotationY = math.random(getgenv().spower, getgenv().spower)
            local rotationZ = math.random(getgenv().spower, getgenv().spower)
            workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(math.rad(rotationX), math.rad(rotationY), math.rad(rotationZ))
        
            wait(0)
        end
    end)
end})
getgenv().anticuff = false
getgenv().anticufftp = true
local deb = false
function spawn()
    if plrs.LocalPlayer.Team ~= game:GetService("Teams")["The Combine"] then return end
	local hum = plrs.LocalPlayer.Character:WaitForChild("Humanoid")
	game:GetService("StarterGui"):SetCore("SendNotification", {
Title = "c17.fucker",
Text = "Escaping cuffs..."
	})
	local ogp = hum.RootPart.Position
game:GetService("ReplicatedStorage").eTech.Remotes.ChangeTeam:FireServer()
   local ohTable1 = {
	["SkinTone"] = Color3.new(0.972549, 0.768627, 0.584314),
	["HairColor"] = Color3.new(0, 0, 0),
	["Team"] = "The Combine",
	["IsRebel"] = false,
	["Morph"] = "CIVILIAN"
}

game:GetService("ReplicatedStorage").GalacticTech.Remotes.CompleteCharacter:FireServer(ohTable1)
task.delay(0.5, function()
	for i = 1,20 do 
		task.wait(0.05)
		local ssss, eeee = pcall(function()
            if getgenv().anticufftp then
			plrs.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(ogp)
            end
		end)
		if eeee then 
		print(tostring(eeee))
		end
	 end
	 task.wait()
	 game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "c17.fucker",
		Text = "Succesfully escaped cuffs!"
			})
end)
task.spawn(function()
    for i = 1,30 do 
       task.wait(0.05)
	   game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    end
end)
end

plrs.LocalPlayer.PlayerGui.ChildAdded:Connect(function(v)
    if v:IsA("ScreenGui") and v.Name == "MainMenu" and getgenv().anticuff then 
       v:Destroy() 
    end
end)

plrs.LocalPlayer.CharacterAdded:Connect(function(char1)
    char1:WaitForChild("Humanoid").Changed:Connect(function()
        local hum = char1:FindFirstChild("Humanoid")
        if hum:GetState() == Enum.HumanoidStateType.PlatformStanding and not deb and getgenv().anticuff then 
            if not deb then 
				spawn()
			end
			deb = true
			task.delay(2, function()
				deb = false
			end)
            task.wait()
        end
    end)
end)

detection:toggle({name = "tp back (anti cuff)", def = true, callback = function(Boolean)
    getgenv().anticufftp = Boolean
end})

detection:toggle({name = "anti cuff", def = false, callback = function(Boolean)
    getgenv().anticuff = Boolean
    if Boolean then 
        spawn()
    end
end})

local autofarm = misc:section({name = "autofarm", side = "left",size = 130})
getgenv().scrp = false
getgenv().method = "quick tp"
getgenv().tweenspeed = 2

autofarm:toggle({name = "scrap autofarm", def = false, callback = function(Boolean)
    getgenv().scrp = Boolean
task.spawn(function()
    local ogp = plr.Character:WaitForChild("Humanoid").RootPart.Position
    while wait() and getgenv().scrp do
      pcall(function()
        for i,v in next, workspace.Trash:GetChildren() do
            if v:IsA("BasePart") and v.ProximityPrompt then
               if getgenv().method == "quick tp" then 
                plr.Character.HumanoidRootPart.CFrame = v.CFrame * CFrame.new(0, -10, 0)
                fireproximityprompt(v.ProximityPrompt, 10)
               else
                local cf = v.CFrame * CFrame.new(0, -10, 0)
                local tsn = ts:Create(plr.Character.HumanoidRootPart, TweenInfo.new(getgenv().tweenspeed, Enum.EasingStyle.Linear), {CFrame = cf})
                tsn:Play()
                tsn.Completed:Connect(function()
                    plr.Character.HumanoidRootPart.CFrame = v.CFrame
                    fireproximityprompt(v.ProximityPrompt, 10)
                    task.wait(1)
                end)
               end
            end
        end
      end)
    end
    task.wait()
for i = 1,10 do
task.wait(0.05)
plr.Character.HumanoidRootPart.CFrame = CFrame.new(ogp)
end
end)
end})

autofarm:dropdown({name = "teleport method", def = "Quick TP", max = 2, options = {"Quick TP", "Tweening"}, callback = function(part)
    getgenv().method = part
end})

autofarm:slider({name = "tween speed", def = 2, max = 10, min = 0, rounding = true, callback = function(Value)
    getgenv().tweenspeed = Value
end})


local msic = misc:section({name = "misc", side = "right",size = 320})
getgenv().gun = "USP Match"
msic:dropdown({name = "select gun", def = "USP Match", max = 5, options = {"USP Match", "Colt Python", "SMG", "SPAS-12", "Crossbow", "Health Vial", "Lockpick"}, callback = function(part)
    getgenv().gun = part
end})


msic:button({name = "buy weapon", callback = function()
    task.spawn(function()
        local ogp = plr.Character:WaitForChild("Humanoid").RootPart.Position
local c = workspace.ShopAreas:GetChildren()[3].DealerArea.CFrame
        plr.Character.HumanoidRootPart.CFrame = c
        task.wait(0.5)
        local ohInstance1 = game:GetService("ReplicatedStorage").eTech.Info.Shops["Gun Shop"]
		local ohString2 = getgenv().gun
		game:GetService("ReplicatedStorage").eTech.Remotes.PurchaseHandler:InvokeServer(ohInstance1, ohString2)
        task.wait(0.5)
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(ogp)
    end)
   end})


   msic:button({name = "grab weapon", callback = function()
    local ogp = plr.Character:WaitForChild("Humanoid").RootPart.Position

    if not workspace.Items:FindFirstChild(getgenv().gun) then 
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "c17.fucker",
            Text = "Weapon not found dropped!"
        })
        return 
    end

    for i,v in next, workspace.Items:GetChildren() do 
       pcall(function()
        if v.Name == getgenv().gun then 
            for i = 1,20 do 
                task.wait(0.05)
                plr.Character.HumanoidRootPart.CFrame = v:FindFirstChild("Handle").CFrame
                fireproximityprompt(v:FindFirstChild("Handle"):FindFirstChildOfClass("ProximityPrompt"), 10)
            end
        end
       end)
    end
    for i = 1,3 do 
        task.wait(0.05)
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(ogp)
    end
   end})


   
   msic:toggle({name = "infinite stamina", def = fake, callback = function(Boolean)
    plr:SetAttribute('InfStamina', Boolean)
end})

getgenv().chrageraura = false
msic:toggle({name = "auto heal charger", def = fake, callback = function(Boolean)
    getgenv().chrageraura = Boolean
    task.spawn(function()

        while getgenv().chrageraura and task.wait() do
            pcall(function()
                for i,v in next, workspace.Chargers:GetChildren() do
                    if v.Name == "HealthStation" then
                        local mag = (v:WaitForChild("Meshes/health_charger").Position - plr.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
                        if mag < 20 then
    
                            print("TEST")
                            v:WaitForChild("Meshes/health_charger"):FindFirstChild("ProximityPrompt"):InputHoldBegin()
                        end
                    end
                end
            end)
        end
    end)
end})
getgenv().forcere = false
msic:toggle({name = "force rebel tag", def = fake, callback = function(Boolean)
    getgenv().forcere = Boolean
end})


task.spawn(function()
    local retard;
    retard = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if tostring(Self) == "CompleteCharacter" and tostring(method) == "FireServer" and getgenv().forcere then
        args[1]["IsRebel"] = true
        
        return retard(Self, table.unpack(args))
        end 
        return retard(Self, ...)
        end))
    end)

   




   -- semi god mode
   -- fake being cuffed
   -- grabb dropped tool
   -- fake username
   -- fake credits
   -- fling player
   -- fling all
   -- factory autofarm maybe
   -- play sound (guns)
   -- annoy all (tp and chat)
