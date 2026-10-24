-- Deobfuscated by Meow Hook (Nocta mystical.x0p)
-- Force global UI scale to stay at 1 permanently and prevent shrinking
-- Run this ONCE at the very top of your script before anything else

-- ══════════════════════════════════════════════════════════════
--  PHONKWARE KEY SYSTEM
-- ══════════════════════════════════════════════════════════════
do
    local KEY_URL  = "https://gist.githubusercontent.com/stxf002/c1346ab05de639ea5b85d345463d5cd9/raw/keys.txt"
    local KEY_FILE = "sussywarev_2/key.txt"   -- remembers key so user only types it once

    -- try to load a previously saved key
    local savedKey = ""
    pcall(function()
        if isfile and isfile(KEY_FILE) then
            savedKey = readfile(KEY_FILE):gsub("%s", "")
        end
    end)

    -- CONSUME_URL: a Google Apps Script web app that removes a key from the gist
    -- Set this to your deployed Apps Script URL (see setup instructions)
    local CONSUME_URL = "https://script.google.com/macros/s/AKfycbyiH6tUe9xVs24Hwc5Hadj_YmF4A6vvcFTNaEmKIrZ8wswV3wOI6gV-afuE19Ee7IZ4Gw/exec"

    local function fetchValidKeys()
        local ok, body = pcall(game.HttpGet, game, KEY_URL)
        if not ok or type(body) ~= "string" then return nil end
        local t = {}
        for line in body:gmatch("[^\n\r]+") do
            local k = line:gsub("%s", "")
            if k ~= "" then t[k] = true end
        end
        return t
    end

    -- calls the Apps Script to remove the key from gist (one-time use)
    local function consumeKey(key)
        pcall(function()
            game:HttpGet(CONSUME_URL .. "?action=consume&key=" .. key)
        end)
    end

    local function buildUI(onSubmit)
        local sg = Instance.new("ScreenGui")
        sg.Name          = "PhonkWareKey"
        sg.ResetOnSpawn  = false
        sg.DisplayOrder  = 9999
        pcall(function() sg.Parent = game:GetService("CoreGui") end)
        if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer.PlayerGui end

        -- backdrop
        local backdrop = Instance.new("Frame")
        backdrop.Size                = UDim2.new(1, 0, 1, 0)
        backdrop.BackgroundColor3    = Color3.fromRGB(0, 0, 0)
        backdrop.BackgroundTransparency = 0.45
        backdrop.BorderSizePixel     = 0
        backdrop.ZIndex              = 1
        backdrop.Parent              = sg

        -- card
        local card = Instance.new("Frame")
        card.Size             = UDim2.new(0, 360, 0, 160)
        card.Position         = UDim2.new(0.5, -180, 0.5, -80)
        card.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
        card.BorderSizePixel  = 0
        card.ZIndex           = 2
        card.Parent           = sg
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

        -- accent bar
        local bar = Instance.new("Frame")
        bar.Size             = UDim2.new(1, 0, 0, 3)
        bar.BackgroundColor3 = Color3.fromRGB(190, 60, 220)
        bar.BorderSizePixel  = 0
        bar.ZIndex           = 3
        bar.Parent           = card
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)

        local function lbl(text, y, size, color, bold)
            local l = Instance.new("TextLabel")
            l.Size               = UDim2.new(1, -24, 0, 24)
            l.Position           = UDim2.new(0, 12, 0, y)
            l.BackgroundTransparency = 1
            l.Text               = text
            l.TextColor3         = color or Color3.fromRGB(220, 220, 220)
            l.TextSize           = size or 14
            l.Font               = bold and Enum.Font.GothamBold or Enum.Font.Gotham
            l.TextXAlignment     = Enum.TextXAlignment.Left
            l.ZIndex             = 3
            l.Parent             = card
            return l
        end

        lbl("PhonkWare", 10, 17, Color3.fromRGB(200, 70, 230), true)
        lbl("Enter your key to continue", 32, 13, Color3.fromRGB(150, 150, 150))

        local box = Instance.new("TextBox")
        box.Size             = UDim2.new(1, -24, 0, 34)
        box.Position         = UDim2.new(0, 12, 0, 60)
        box.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
        box.TextColor3       = Color3.fromRGB(255, 255, 255)
        box.PlaceholderText  = "PHONK-XXXXXXXX"
        box.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
        box.Text             = savedKey
        box.TextSize         = 14
        box.Font             = Enum.Font.Gotham
        box.ClearTextOnFocus = false
        box.ZIndex           = 3
        box.Parent           = card
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(1, -24, 0, 30)
        btn.Position         = UDim2.new(0, 12, 0, 102)
        btn.BackgroundColor3 = Color3.fromRGB(170, 50, 200)
        btn.TextColor3       = Color3.fromRGB(255, 255, 255)
        btn.Text             = "Submit"
        btn.TextSize         = 14
        btn.Font             = Enum.Font.GothamBold
        btn.ZIndex           = 3
        btn.Parent           = card
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local status = lbl("", 138, 12, Color3.fromRGB(255, 80, 80))
        status.TextXAlignment = Enum.TextXAlignment.Center

        btn.MouseButton1Click:Connect(function()
            onSubmit(box.Text:gsub("%s", ""), sg, status, btn)
        end)

        -- also submit on Enter
        box.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                onSubmit(box.Text:gsub("%s", ""), sg, status, btn)
            end
        end)
    end

    -- check & gate
    local thread = coroutine.running()
    local passed = false

    -- fast path: if we have a saved key try it silently first
    if savedKey ~= "" then
        local keys = fetchValidKeys()
        if keys and keys[savedKey] then
            passed = true
        end
    end

    if not passed then
        buildUI(function(inputKey, sg, status, btn)
            btn.Text = "Checking..."
            task.spawn(function()
                local keys = fetchValidKeys()
                if not keys then
                    status.Text = "Could not reach key server — check your internet"
                    btn.Text = "Submit"
                    return
                end
                if keys[inputKey] then
                    status.TextColor3 = Color3.fromRGB(80, 220, 80)
                    status.Text = "✓ Valid! Activating..."
                    -- consume key from gist (one-time use — removes it so nobody else can use it)
                    consumeKey(inputKey)
                    -- save key locally so re-executes work without needing a new key
                    pcall(function()
                        if not isfolder("sussywarev_2") then makefolder("sussywarev_2") end
                        writefile(KEY_FILE, inputKey)
                    end)
                    task.wait(0.8)
                    sg:Destroy()
                    passed = true
                    coroutine.resume(thread)
                else
                    status.TextColor3 = Color3.fromRGB(255, 80, 80)
                    status.Text = "✗ Invalid or expired key"
                    btn.Text = "Submit"
                end
            end)
        end)
        coroutine.yield()
    end

    if not passed then return end
end
-- ══════════════════════════════════════════════════════════════

pcall(function()
    if isfolder and not isfolder("sussywarev_2") then
        makefolder("sussywarev_2")
    end

    if writefile then
        -- Write it just once on startup so it never loops or crashes
        writefile("sussywarev_2/ui_size.txt", "950,700")
    end
end)
getgenv().phonk_ui_scale = 1

(function()
	do
		local function fn7(arg)
			return arg
		end

		eli_inext = function(arg, arg2)
			local n = arg2 + 1
			local v = arg[n]
			if v ~= nil then
				return n, v
			end
		end

		eli_ipairs = function(arg)
			return eli_inext, arg, 0
		end

		eli_pairs = function(arg)
			return next, arg, nil
		end

		if not cloneref then
			cloneref = function(arg)
				return arg
			end
		end

		if hookfunction and newcclosure and getcallingscript then
			pcall(function()
				local v = nil

				local function fn8(arg, arg2)
					if type(arg2) == "table" and rawget(arg2, "__mode") == "kv" then
						local v2 = getcallingscript()
						if v2 and v2.Name == "MiscellaneousController" then
							return v(arg, {})
						end
					end

					return v(arg, arg2)
				end

				v = hookfunction
				v = v(setmetatable, newcclosure(fn8))
			end)

			pcall(function()
				local v = nil

				local function fn8(arg)
					if type(arg) == "table" then
						local v2 = getcallingscript()
						if v2 and v2.Name == "MiscellaneousController" then
							return 3
						end
					end

					return v(arg)
				end

				v = hookfunction
				v = v(rawlen, newcclosure(fn8))
			end)
		end

		print("[PhonkWare] antidetect ready")

		pcall(function()
			if not (hookfunction and newcclosure and getrenv) then
				return
			end
			local v = nil
			local v2 = newcclosure

			local function fn8(arg, arg2)
				if arg2 and typeof(arg2) == "table" and rawget(arg2, "__mode") == "kv" then
					if debug.traceback():find("MiscellaneousController") then
						return v({ 1, 2, 3 }, {})
					end
				end

				return v(arg, arg2)
			end

			v = hookfunction
			v = v(getrenv().setmetatable, v2(fn8))
		end)

		coroutine.wrap(function()
			pcall(function()
				local tbl2 = { "anticheat", "ac", "detection", "ban", "kick", "security", "moderation" }

				local function fn8(arg)
					arg.Disabled = true
				end

				local function fn9(arg)
					if arg:IsA("LocalScript") or arg:IsA("ModuleScript") then
						local v = string.lower(arg.Name)

						for _, v2 in eli_ipairs(tbl2) do
							if string.find(v, v2, 1, true) then
								pcall(fn8, arg)
								break
							end
						end
					end
				end

				local function fn10(descendant)
					pcall(fn9, descendant)
				end

				pcall(function()
					game.DescendantAdded:Connect(fn10)
				end)

				pcall(function()
					local descendants = game:GetDescendants()

					for i = 1, #descendants do
						fn10(descendants[i])

						if i % 4000 == 0 then
							task.wait()
						end
					end
				end)
			end)

			pcall(function()
				local NetworkClient = game:GetService("NetworkClient")

				if NetworkClient then
					NetworkClient.ChildAdded:Connect(function(child)
						pcall(function()
							local ok, result = pcall(function()
								return child.Name:lower()
							end)

							if ok and result then
								if result:find("anticheat") or result:find("detection") then
									pcall(function()
										child:Destroy()
									end)
								end
							end
						end)
					end)
				end
			end)
		end)()

		pcall(function()
			local remoteEvent = Instance.new("RemoteEvent")
			remoteEvent.Name = "ClientAlert"
			remoteEvent.Parent = LocalPlayer
		end)

		task.spawn(function()
			pcall(fn7(function()
				if type(getgc) ~= "function" then
					return
				end
				local localScript3 = game:GetService("ReplicatedFirst"):WaitForChild("LocalScript3", 10)
				local v = getgc(false)

				for i = 1, #v do
					local v2 = v[i]

					if type(v2) == "function" and (type(islclosure) ~= "function" or islclosure(v2)) then
						local ok, result = pcall(getfenv, v2)

						if ok and type(result) == "table" then
							local ok2, result2 = pcall(function()
								return rawget(result, "script")
							end)

							if ok2 and result2 and typeof(result2) == "Instance" then
								local ok3, result3 = pcall(tostring, result2)

								if ok3 and (result2 == localScript3 or type(result3) == "string" and result3:find("LoadingScreen")) then
									local ok4, result4 = pcall(debug.getconstants, v2)

									if ok4 and type(result4) == "table" then
										for _, v3 in eli_ipairs(result4) do
											if type(v3) == "string" and (v3:find("TakeTheL") or v3:find("ban") or v3:find("kick")) then
												pcall(function()
													hookfunction(v2, function()
													end)
												end)

												break
											end
										end
									end
								end
							end
						end
					end

					if i % 1500 == 0 then
						task.wait()
					end
				end
			end))
		end)

	end

	local now = os.clock()

	while game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") do
		if not (os.clock() - now > 8) then
			task.wait(0.1)
			continue
		end
		break
	end

	getgenv().silent_load = false

	do
		local chunk, v = loadstring(game:HttpGet("https://raw.githubusercontent.com/Anonymus23231/thing/refs/heads/main/Lib") .. [[

getgenv().ThemeManager = ThemeManager
getgenv().SaveManager = SaveManager
getgenv().Trove = Trove
]])

		if not chunk then
			error("[PhonkWare] failed to compile lib: " .. tostring(v))
		end

		local ok, result = pcall(chunk)

		if not ok then
			error("[PhonkWare] failed to run lib: " .. tostring(result))
		end
	end

	local library
	library = getgenv().Library
	local themeManager
	themeManager = getgenv().ThemeManager
	local saveManager
	saveManager = getgenv().SaveManager
	local options, toggles, v, v2

	do
		local trove_ = getgenv().Trove

		if not library then
			error("[PhonkWare] Library missing after load")
		end

		if not trove_ then
			trove_ = {}
			trove_.__index = trove_

			trove_.new = function()
				return setmetatable({ _objects = {} }, trove_)
			end

			trove_.Add = function(arg, arg2)
				arg._objects[#arg._objects + 1] = arg2
				return arg2
			end

			trove_.Destroy = function(arg)
				for i = #arg._objects, 1, -1 do
					local v3 = arg._objects[i]

					pcall(function()
						if typeof(v3) == "RBXScriptConnection" then
							v3:Disconnect()
						elseif typeof(v3) == "Instance" then
							v3:Destroy()
						elseif type(v3) == "function" then
							v3()
						elseif type(v3) == "table" and v3.Destroy then
							v3:Destroy()
						end
					end)
				end

				arg._objects = {}
			end

			trove_.Clean = trove_.Destroy
		end

		themeManager = themeManager or {
			SetLibrary = function()
			end,
			SetFolder = function()
			end,
			BuildConfigSection = function()
			end,
			IgnoreThemeSettings = function()
			end,
		}

		saveManager = saveManager or {
			SetLibrary = function()
			end,
			SetFolder = function()
			end,
			BuildConfigSection = function()
			end,
			IgnoreThemeSettings = function()
			end,
			SetIgnoreIndexes = function()
			end,
			LoadAutoloadConfig = function()
			end,
		}

		getgenv().Library = library
		options = library.Options
		toggles = library.Toggles
		getgenv().silent_load = false

		getgenv().phonk_mobile_btns = getgenv().phonk_mobile_btns or {
			eu = false,
			aimbot = false,
			underground = false,
			tp = false,
			fly = false,
			freecam = false,
			ragebot = false,
			triggerbot = false,
			silent = false,
		}

		local function fn7()
			local currentCamera = workspace.CurrentCamera
			local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(1920, 1080)
			return math.clamp(math.min(viewportSize.X / 1920, viewportSize.Y / 1080), 0.5, 1.4)
		end

		getgenv().phonk_ui_scale = 1

		getgenv().phonk_apply_ui_scale = function(parent)
			if not parent then
				return
			end
			local phonkUiScale = 1
			local phonkUIScale = parent:FindFirstChild("PhonkUIScale")

			if not phonkUIScale then
				phonkUIScale = Instance.new("UIScale")
				phonkUIScale.Name = "PhonkUIScale"
				phonkUIScale.Parent = parent
			end

			phonkUIScale.Scale = phonkUiScale
		end

		local phonkUiScale = getgenv().phonk_ui_scale
		local floor = math.floor

    -- 2. Then your window creation follows right after:
    v = library:CreateWindow({
        Title = "SussyWare | Universal Hybrid Suite (Players & Zombies)",
        AutoShow = true,
        SubTitle = "",
        Center = true,
        Resizable = true,
        Draggable = true,
        Size = UDim2.new(0, 950, 0, 700),
    })

    -- Force the window size immediately after creation and layout init
    pcall(function()
        if v then
            -- If the library has a built-in resize or holder property, apply it here
            if v.Holder then
                v.Holder.Size = UDim2.new(0, 950, 0, 700)
            end
            if v.Outer then
                v.Outer.Size = UDim2.new(0, 950, 0, 700)
            end
        end
    end)
     pcall(function()
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local lastState = nil
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if getgenv().PhonkWare_Unloaded then return end
        if not library then return end
        
        local isOpen = library.MenuOpen
        
        if isOpen then
            -- Force the cursor to stay visible and unlocked every frame while the menu is open
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end
        
        if isOpen ~= lastState then
            lastState = isOpen
            task.defer(function()
                if isOpen then
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                    UserInputService.MouseIconEnabled = true
                    pcall(function()
                        LocalPlayer.CameraMode = Enum.CameraMode.Classic
                    end)
                else
                    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                    UserInputService.MouseIconEnabled = false
                end
            end)
        end
    end)
end)
        

		-- Paste this line right here to force the window to be large instantly:
		pcall(function() v.Outer.Size = UDim2.fromOffset(1100, 800) end)

		pcall(function()
			local screenGui = library.ScreenGui

			if screenGui then
				local phonkUIScale = screenGui:FindFirstChild("PhonkUIScale")

				if phonkUIScale then
					phonkUIScale:Destroy()
				end

				local uiScale = Instance.new("UIScale")
				uiScale.Name = "PhonkUIScale"
				uiScale.Scale = phonkUiScale
				uiScale.Parent = screenGui
			end
		end)

		pcall(function()
    local v3 = v
    local outer

    if v then
        outer = v.Outer
    else
        outer = v3
    end

    if not outer then
        return
    end
    local UserInputService = game:GetService("UserInputService")

    local function fn8()
        -- Force table values to 950 and 700 instead of letting it shrink in memory
        getgenv().elisium_ui_size = { 950, 700 }
        getgenv().phonk_ui_size = { 950, 700 }

        pcall(function()
    if isfolder and not isfolder("sussywarev_2") then
        makefolder("sussywarev_2")
    end

    if writefile then
        -- Force-write 950,700 into the new sussywarev_2 folder
        writefile("sussywarev_2/ui_size.txt", "950,700")
    end
end)
    
    -- Run it once immediately to enforce the size
    fn8()
			end

			pcall(function()
    local phonkUiSize = getgenv().phonk_ui_size or getgenv().elisium_ui_size

    if not phonkUiSize and isfile and isfile("sussywarev_2/ui_size.txt") then
        local txt = readfile("sussywarev_2/ui_size.txt")
        -- Update this pattern to match a comma OR a space ([,%s]+)
        local match, v4 = tostring(txt):match("(%d+)[,%s]+(%d+)")

        if match and v4 then
            phonkUiSize = {}
            local num = tonumber(match)
            local v5 = tonumber
            phonkUiSize[1] = num

            do
                local values = table.pack(v5(v4))
                table.move(values, 1, values.n, 2, phonkUiSize)
            end
        end
    end

				if type(phonkUiSize) == "table" and phonkUiSize[1] and phonkUiSize[2] then
					local clamp = math.clamp
					local v4 = phonkUiSize[2]
					outer.Size = UDim2.fromOffset(math.clamp(phonkUiSize[1], 280, 1200), clamp(v4, 240, 1000))
				end
			end)

			for _, descendant in ipairs(outer:GetDescendants()) do
				if descendant:IsA("TextButton") and (descendant.Name == "Handle" or descendant.Name:lower():find("resize")) then
					descendant.Size = UDim2.fromOffset(44, 44)
					descendant.ZIndex = 100
				end
			end

			if outer:FindFirstChild("PhonkResizeHandle") then
				outer.PhonkResizeHandle:Destroy()
			end

			local textButton = Instance.new("TextButton")
			textButton.Name = "PhonkResizeHandle"
			textButton.AnchorPoint = Vector2.new(1, 1)
			textButton.Position = UDim2.new(1, -2, 1, -2)
			textButton.Size = UDim2.fromOffset(48, 48)
			textButton.BackgroundColor3 = library.AccentColor or Color3.fromRGB(196, 30, 58)
			textButton.BackgroundTransparency = 0.35
			textButton.BorderSizePixel = 0
			textButton.Text = ""
			textButton.AutoButtonColor = false
			textButton.ZIndex = 120
			textButton.Active = true
			textButton.Parent = outer
			Instance.new("UICorner", textButton).CornerRadius = UDim.new(0, 8)
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Color = library.AccentColor or Color3.fromRGB(196, 30, 58)
			uiStroke.Thickness = 1.5
			uiStroke.Transparency = 0.2
			uiStroke.Parent = textButton

			for i = 1, 3 do
				local frame = Instance.new("Frame")
				frame.AnchorPoint = Vector2.new(1, 1)
				frame.Position = UDim2.new(1, -6, 1, -6 - (i - 1) * 7)
				frame.Size = UDim2.fromOffset(10 + (i - 1) * 6, 2)
				frame.BackgroundColor3 = Color3.new(1, 1, 1)
				frame.BackgroundTransparency = 0.25
				frame.BorderSizePixel = 0
				frame.ZIndex = 121
				frame.Parent = textButton
			end

			local flag = false
			local vector2 = nil
			local absoluteSize = nil

			local function fn9(arg)
				flag = true
				vector2 = Vector2.new(arg.Position.X, arg.Position.Y)
				absoluteSize = outer.AbsoluteSize
			end

			textButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					fn9(input)
				end
			end)

			local connection = UserInputService.InputChanged:Connect(function(input)
				if not flag then
					return
				end

				if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
					return
				end
				local vector22 = Vector2.new(input.Position.X, input.Position.Y)
				local n = math.clamp(absoluteSize.X + vector22.X - vector2.X, 280, 1200)
				local n2 = math.clamp(absoluteSize.Y + vector22.Y - vector2.Y, 240, 1000)
				local floor2 = math.floor
				outer.Size = UDim2.fromOffset(math.floor(n), floor2(n2))
			end)

			local connection2 = UserInputService.InputEnded:Connect(function(input)
				if not flag then
					return
				end

				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					flag = false
					fn8()
				end
			end)

			if trove then
			end

			getgenv().phonk_resize_cleanup = function()
				pcall(function()
					connection:Disconnect()
				end)

				pcall(function()
					connection2:Disconnect()
				end)

				pcall(function()
					textButton:Destroy()
				end)
			end
		end)

		pcall(function()
			if workspace.CurrentCamera then
				trove = trove
			end
		end)

		if GLOBAL_TROVE then
			pcall(function()
				GLOBAL_TROVE:Destroy()
			end)
		end

		v2 = trove_.new()
		getgenv().GLOBAL_TROVE = v2

		pcall(function()
			local function fn8()
				-- Force scale to 1 permanently
				local v3 = 1
				getgenv().phonk_ui_scale = v3
				local screenGui = library.ScreenGui

				if screenGui then
					local phonkUIScale = screenGui:FindFirstChild("PhonkUIScale")

					if not phonkUIScale then
						phonkUIScale = Instance.new("UIScale")
						phonkUIScale.Name = "PhonkUIScale"
						phonkUIScale.Parent = screenGui
					end

					phonkUIScale.Scale = v3
				end

				for _, v4 in ipairs({ "PhonkWare_MobileLogo", "PhonkWareKeySystem", "PhonkWareEUCounter" }) do
					local v5 = nil

					pcall(function()
						if gethui then
							v5 = gethui():FindFirstChild(v4)
						end
					end)

					if not v5 then
						pcall(function()
							v5 = game:GetService("CoreGui"):FindFirstChild(v4)
						end)
					end

					if v5 then
						local phonkUIScale = v5:FindFirstChild("PhonkUIScale")

						if not phonkUIScale then
							phonkUIScale = Instance.new("UIScale")
							phonkUIScale.Name = "PhonkUIScale"
							phonkUIScale.Parent = v5
						end

						phonkUIScale.Scale = v3
					end
				end
			end

			fn8()
			local currentCamera = workspace.CurrentCamera

			if currentCamera then
				v2:Add(currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fn8))
			end

			v2:Add(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
				task.wait()
				local currentCamera2 = workspace.CurrentCamera

				if currentCamera2 then
					v2:Add(currentCamera2:GetPropertyChangedSignal("ViewportSize"):Connect(fn8))
					fn8()
				end
			end))
		end)
	end

	library:OnUnload(function()
		pcall(function()
			GLOBAL_TROVE:Destroy()
		end)

		getgenv().Library = nil
	end)

	local v3
	v3 = cloneref(game:GetService("ReplicatedStorage"))
	local v4
	v4 = cloneref(game:GetService("Players"))
	local v5
	v5 = cloneref(game:GetService("RunService"))
	local v6
	v6 = cloneref(game:GetService("UserInputService"))
	local v7
	v7 = cloneref(game:GetService("Lighting"))
	local localPlayer2
	localPlayer2 = v4.LocalPlayer
	local currentCamera
	currentCamera = workspace.CurrentCamera
	local MechanicsController
	MechanicsController = require(localPlayer2.PlayerScripts.Controllers.MechanicsController)
	local CameraController
	CameraController = require(localPlayer2.PlayerScripts.Controllers.CameraController)
	local ItemLibrary
	ItemLibrary = require(v3.Modules.ItemLibrary)
	oldoffsets = oldoffsets or {}
	local tbl2

	tbl2 = {
		Combat = v:AddTab("combat"),
		Ragebot = v:AddTab("ragebot"),
		World = v:AddTab("world"),
		Visuals = v:AddTab("visuals"),
		Character = v:AddTab("character"),
		Misc = v:AddTab("misc"),
		Optimizations = v:AddTab("optimizations"),
		["UI Settings"] = v:AddTab("settings"),
	}

	getgenv().phonk = {
		world = {
			weather = { enable = false, color = Color3.fromRGB(255, 255, 255), rate = 100, type = "snow" },
			skybox = {
				enable = false,
				selected = "Deep Space",
				rotate = false,
				rotate_speed = 1,
				rotate_direction = "Horizontal",
				rotate_method = "Spin",
				remove_sun = false,
				remove_moon = false,
				remove_stars = false,
			},
			third_person = { enable = false },
			stretched_res = { enable = false, amount = 0.2 },
			fov_changer = { enable = false, fov = 80 },
		},
		death_effects = { enable = false, type = "Explosion", color = Color3.fromRGB(120, 81, 166) },
		disable_anims = { enable = false, select = {} },
		viewmodel_chams = {
			weapon_chams = {
				enable = false,
				color = Color3.fromRGB(255, 255, 255),
				material = "Neon",
				transparency = 0,
			},
			arm_chams = {
				enable = false,
				color = Color3.fromRGB(255, 255, 255),
				material = "Neon",
				transparency = 0,
				invisible = false,
			},
			weapon_highlight = {
				enable = false,
				color = Color3.fromRGB(255, 255, 255),
				transparency = 0.5,
				outline_color = Color3.fromRGB(255, 255, 255),
				outline_transparency = 0,
			},
			arm_highlight = {
				enable = false,
				color = Color3.fromRGB(255, 255, 255),
				transparency = 0.5,
				outline_color = Color3.fromRGB(255, 255, 255),
				outline_transparency = 0,
			},
		},
		slide_boost = { enable = false, speed = 60 },
		walkspeed = { enable = false, multiplier = 1.5 },
		fly = { enable = false, speed = 50 },
		freecam = { enable = false, speed = 20 },
		eu_counter = { enable = false },
		silent_aim = {
			enable = false,
			hit_part = "Head",
			fov_radius = 300,
			show_fov = true,
			fov_color = Color3.fromRGB(255, 255, 255),
		},
		ragebot = { enable = false, prediction = true, tp_duration = 0.08, y_offset = 5, team_check = true },
		no_arm = { enable = false },
		tp_player = { y_offset = 0, method = "closest", team_check = true, prediction = true },
		animation = { enable = false, select_animation = "Meditate", speed = 2 },
		optimizations = {
			no_particles = false,
			no_shadows = false,
			low_quality = false,
			no_postfx = false,
			no_textures = false,
			no_atmosphere = false,
			fps_cap_enable = false,
			fps_cap = 60,
		},
		device_spoof = { enable = false, type = "MouseKeyboard" },
		-- NEW FEATURES
		anti_aim = {
			enable = false,
			pitch_offset = 0,
			yaw_offset = 0,
			body_misalign = false,
			misalign_angle = 180,
			zero_velocity = false,
		},
		anti_ragebot = {
			enable = false,
			counter_kicia = false,
			counter_solix = false,
			counter_unnamed = false,
			counter_nebula = false,
			riot_redirect = false,
			anti_katana = false,
		},
		voidspam_btn = {
			enable = false,
			x = 400000000,
			y = 400000000,
			z = 400000000,
		},
		voidhide = {
			enable = false,
			x = 0,
			y = 400000000,
			z = 0,
		},
		strafe = {
			enable = false,
			radius = 4,
			speed = 12,
		},
		slingshot_bypass = { enable = false },
		sound_spammer = { enable = false, type = "DoubleJump" },
		spoof = { level = { enable = false, value = 9 }, streak = { enable = false, value = 9 } },
		profile = { spoof_local = false, spoof_local_name = "", spoof_other = false, spoof_other_name = "" },
		char_spoof = { enable = false, selected = "", saved = {}, last_id = nil },
		infinite_double_jump = { enable = false },
		viewmodel_offsets = { enable = false, x = 0, y = 0, z = 0 },
		hitsounds = { enable = false, selected = "hitmarker", custom_id = "", volume = 1, pitch = 1 },
		remove_muzzle = { enable = false },
		remove_gun_sounds = { enable = false },
		damage_numbers = {
			enable = false,
			color1 = Color3.fromRGB(255, 80, 80),
			color2 = Color3.fromRGB(255, 200, 80),
			color_type = "Static",
			font = "GothamBold",
			text_size = 18,
			duration = 0.8,
			rise = 42,
			remove_ingame = true,
		},
		map_textures = { enable = false, material = "Neon", color = Color3.fromRGB(255, 255, 255) },
		unlock_all = { enable = false },
	}

	local phonk
	phonk = getgenv().phonk
	phonk.gun_mods = phonk.gun_mods or { enable = false }
	phonk.underground = phonk.underground or { enable = false, depth = 5.8 }
	phonk.fly = phonk.fly or { enable = false, speed = 50 }
	phonk.freecam = phonk.freecam or { enable = false, speed = 20 }
	phonk.eu_counter = phonk.eu_counter or { enable = false }

	phonk.silent_aim = phonk.silent_aim or {
		enable = false,
		hit_part = "Head",
		fov_radius = 300,
		show_fov = true,
		fov_color = Color3.fromRGB(255, 255, 255),
	}

	phonk.ragebot = phonk.ragebot or {
		enable = false, prediction = true, tp_duration = 0.08, y_offset = 5, team_check = true,
		-- fake pos / void & timing
		height = 12,
		spin_speed = 360,
		desync_walk = false,
		fast_fire = false,
		shoot_frames = 2,
		ignore_after_spawn = 35,
		fire_rate_override = false,
		auto_equip = false,
		auto_swap_empty = false,
		void_spam = false,
		void_spam_when = "Between every shot",
		void_distance = 4,
		void_spread = 2000000,
		arrive_time = 0,
		stay_after_shot = 1,
		secure_hp_lead = false,
		lead_margin = 1,
		random_timing = false,
		timing_jitter = 40,
		-- smart position
		smart_position = true,
		prefer_inside_walls = false,
		spot_dist_min = 3,
		spot_dist_max = 14,
		only_when_safe = false,
		avoid_melee = false,
		melee_reach = 10,
		vary_position = true,
		vary_amount = 6,
		move_spot_every = 600,
		avoid_riot_shields = false,
		shield_cone = 80,
		back_shield_cone = 60,
	}

	phonk.crosshair = phonk.crosshair or {
		enable = false,
		style = "cross",
		lines = true,
		top_line = true,
		bottom_line = true,
		left_line = true,
		right_line = true,
		rotation = 0,
		length = 6,
		thickness = 1,
		gap = 3,
		color = Color3.fromRGB(0, 255, 170),
		outline = false,
		outline_color = Color3.fromRGB(0, 0, 0),
		dot = false,
		rotating = false,
		rotating_speed = 120,
		spread = false,
		spread_scale = 1,
		animation = false,
		animation_mode = "pulse",
		animation_speed = 3,
		fade = false,
		fade_color = Color3.fromRGB(255, 0, 170),
		follow_target = false,
		follow_source = "target",
		shimmer = false,
		shimmer_speed = 4,
		text_enable = false,
		text_content = "PhonkWare",
		text_font = "Plex",
		text_size = 16,
		text_offset = 18,
		text_color = Color3.fromRGB(255, 255, 255),
		text_outline = true,
		text_animation = false,
	}

	phonk.no_arm = phonk.no_arm or { enable = false }
	phonk.tp_player = phonk.tp_player or { y_offset = 0, method = "closest", team_check = true, prediction = true }

	if phonk.tp_player.prediction == nil then
		phonk.tp_player.prediction = true
	end

	phonk.char_spoof = phonk.char_spoof or { enable = false, selected = "", saved = {}, last_id = nil }

	phonk.targeting = phonk.targeting or {
		max_distance = 800,
		part = "Head",
		visible_only = false,
		riot_shield = false,
		anti_katana = false,
	}

	phonk.targeting.anti_katana = phonk.targeting.anti_katana or false

	phonk.aimbot = phonk.aimbot or {
		enable = false,
		show_fov = true,
		fov_radius = 180,
		fov_color = Color3.fromRGB(196, 30, 58),
		smoothing = 1,
		closest_part = false,
	}

	phonk.triggerbot = phonk.triggerbot or { enable = false, team_check = true, reaction_time = 0.05, shoot_delay = 0.1, max_distance = 500 }

	phonk.esp = phonk.esp or {
		enable = false,
		team_check = true,
		box = { enable = true, color = Color3.fromRGB(196, 30, 58), thickness = 1 },
		name = { enable = true, color = Color3.fromRGB(255, 255, 255) },
		health = { enable = true, color = Color3.fromRGB(80, 220, 80) },
		distance = { enable = true, color = Color3.fromRGB(200, 200, 200) },
		weapon = { enable = false, color = Color3.fromRGB(200, 200, 200) },
		tracer = { enable = false, color = Color3.fromRGB(196, 30, 58), origin = "bottom" },
		skeleton = { enable = false, color = Color3.fromRGB(255, 255, 255) },
		head_circle = { enable = false, color = Color3.fromRGB(255, 255, 255) },
		offscreen_arrows = { enable = false, color = Color3.fromRGB(196, 30, 58), radius = 100 },
		movement_trail = { enable = false, color = Color3.fromRGB(100, 200, 255) },
		movement_prediction = { enable = false, color = Color3.fromRGB(255, 200, 0) },
		highlight = {
			enable = true,
			fill_color = Color3.fromRGB(196, 30, 58),
			fill_transparency = 0.45,
			outline_color = Color3.fromRGB(255, 255, 255),
			outline_transparency = 0,
		},
		chams = {
			enable = false,
			material = "Neon",
			color = Color3.fromRGB(196, 30, 58),
			transparency = 0,
			ghost = false,
			strip_textures = false,
		},
	}

	phonk.world.atmosphere = phonk.world.atmosphere or {
		enable = false,
		density = 0.3,
		offset = 0.25,
		color = Color3.fromRGB(140, 40, 40),
		decay = Color3.fromRGB(80, 20, 20),
		glare = 0.2,
		haze = 1.5,
	}

	phonk.world.color_correction = phonk.world.color_correction or {
		enable = false,
		brightness = 0.05,
		contrast = 0.15,
		saturation = 0.1,
		tint = Color3.fromRGB(255, 180, 180),
	}

	do
		local flag = false

		local function phonkApplyGunMods()
			if not phonk.gun_mods.enable then
				return
			end
			local ok, result = pcall(require, v3.Modules.ItemLibrary)

			if ok and result and result.Items then
				for _, item in pairs(result.Items) do
					if typeof(item) == "table" then
						if item.ShootSpread ~= nil then
							item.ShootSpread = 0
						end

						if item.ShootAccuracy ~= nil then
							item.ShootAccuracy = 0
						end

						if item.ShootRecoil ~= nil then
							item.ShootRecoil = 0
						end

						if item.ShootCooldown ~= nil then
							item.ShootCooldown = 0.001
						end

						if item.ShootBurstCooldown ~= nil then
							item.ShootBurstCooldown = 0.001
						end

						if item.AttackCooldown ~= nil then
							item.AttackCooldown = 0
						end

						if item.SwingCooldown ~= nil then
							item.SwingCooldown = 0
						end

						if item.MeleeCooldown ~= nil then
							item.MeleeCooldown = 0
						end

						if item.Cooldown ~= nil then
							item.Cooldown = 0
						end

						if item.RecoveryTime ~= nil then
							item.RecoveryTime = 0
						end

						if item.ResetTime ~= nil then
							item.ResetTime = 0
						end
					end
				end
			end

			if not flag then
				local ClientItem = nil

				for i = 1, 5 do
					pcall(function()
						ClientItem = require(localPlayer2.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
					end)

					if not ClientItem then
						task.wait(0.1)
						continue
					end
					break
				end

				if ClientItem and ClientItem.Input then
					flag = true
					local input = ClientItem.Input

					ClientItem.Input = function(...)
						local v8 = table.pack(...)

						if phonk.gun_mods.enable then
							local tbl3 = { ... }

							if type(tbl3[1]) == "table" and tbl3[1].Info then
								tbl3[1].Info.ShootRecoil = 0
								tbl3[1].Info.ShootSpread = 0
								tbl3[1].Info.ProjectileSpeed = 99999999
								tbl3[1].Info.ShootCooldown = 0
								tbl3[1].Info.QuickShotCooldown = 0
							end

							return input(table.unpack(v8, 1, v8.n))
						end

						return input(...)
					end
				end
			end
		end

		v2:Add(v5.Heartbeat:Connect(function()
			if phonk.gun_mods.enable then
				phonkApplyGunMods()
			end
		end))

		pcall(function()
			local ok, result = pcall(function()
				return require(localPlayer2.PlayerScripts.Modules.ItemTypes.Gun)
			end)

			if ok and result and result.IsFullyAiming then
				local isFullyAiming = result.IsFullyAiming

				result.IsFullyAiming = function(arg, ...)
					if phonk.gun_mods.enable then
						return true
					end
					return isFullyAiming(arg, ...)
				end
			end
		end)

		getgenv().phonk_apply_gun_mods = phonkApplyGunMods
	end

	do
		local Utility = nil
		local EnumLibrary = nil
		local GameplayUtility = nil

		pcall(function()
			Utility = require(v3.Modules.Utility)
		end)

		pcall(function()
			EnumLibrary = require(v3.Modules.EnumLibrary)
		end)

		pcall(function()
			GameplayUtility = require(v3.Modules.GameplayUtility)
		end)

		local circle = nil

		pcall(function()
			circle = Drawing.new("Circle")
			circle.Thickness = 1
			circle.Filled = false
			circle.Visible = false

			v2:Add(function()
				pcall(function()
					circle:Remove()
				end)
			end)
		end)

		local function fn7()
			if not phonk.silent_aim.enable then
				return false
			end
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			if phonkMobileBtns and phonkMobileBtns.silent then
				return true
			end
			local v8 = options
			local silentAimKey

			if options then
				silentAimKey = options.silent_aim_key
			else
				silentAimKey = v8
			end

			if not silentAimKey then
				return true
			end

			if type(silentAimKey.GetState) == "function" then
				local ok, result = pcall(function()
					return silentAimKey:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if silentAimKey.Mode == "Always" then
				return true
			end

			if silentAimKey.Mode == "Toggle" then
				return silentAimKey.Toggled == true
			end

			if silentAimKey.Mode == "Hold" and silentAimKey.Value and silentAimKey.Value ~= "None" then
				local ok, result = pcall(function()
					return v6:IsKeyDown(Enum.KeyCode[silentAimKey.Value])
				end)

				return ok and result == true
			end

			return false
		end

		local function fn8()
			if not fn7() then
				return nil
			end
			local currentCamera2 = workspace.CurrentCamera
			if not currentCamera2 then
				return nil
			end
			local n = currentCamera2.ViewportSize / 2
			local fovRadius = phonk.silent_aim.fov_radius or 300
			local hitPart = phonk.silent_aim.hit_part or "Head"
			local v8 = nil

			for _, v9 in ipairs(game:GetService("CollectionService"):GetTagged("Entity")) do
				if v9 ~= localPlayer2.Character then
					local v10 = v9:FindFirstChild(hitPart, true)

					if not (not v10 or not v10:IsA("BasePart")) then
						local v11, v12 = currentCamera2:WorldToViewportPoint(v10.Position)

						if v12 then
							local magnitude = (Vector2.new(v11.X, v11.Y) - n).Magnitude

							if magnitude < fovRadius then
								fovRadius = magnitude
								v8 = v10
							end
						end
					end
				end
			end

			return v8
		end

		local function fn9(arg, arg2)
			if not Utility or not arg2 then
				return nil
			end
			local cFrame = arg2.CFrame

			return {
				[utf8.char(1)] = {
					[utf8.char(0)] = Utility:EncodeCFrame(CFrame.lookAt(arg, arg2.Position)),
					[utf8.char(1)] = Utility:EncodeCFrame(cFrame),
					[utf8.char(2)] = arg2,
					[utf8.char(3)] = Utility:EncodeCFrame(cFrame:ToObjectSpace(CFrame.new(arg2.Position))),
				},
			}
		end

		v2:Add(v5.RenderStepped:Connect(function()
			if not circle then
				return
			end
			local showFov = fn7() and phonk.silent_aim.show_fov
			circle.Visible = showFov and true or false
			if not showFov then
				return
			end
			local currentCamera2 = workspace.CurrentCamera
			if not currentCamera2 then
				return
			end
			circle.Position = currentCamera2.ViewportSize / 2
			circle.Radius = phonk.silent_aim.fov_radius or 300
			circle.Color = phonk.silent_aim.fov_color or Color3.new(1, 1, 1)
		end))

		pcall(function()
			if not GameplayUtility or not GameplayUtility.GetEntitiesFromRaycast then
				return
			end
			local getEntitiesFromRaycast = GameplayUtility.GetEntitiesFromRaycast

			GameplayUtility.GetEntitiesFromRaycast = function(arg, arg2, arg3, arg4, arg5, arg6, ...)
				if fn7() then
					local v8 = fn8()

					if v8 then
						local magnitude = (v8.Position - arg4).Magnitude
						arg5 = (v8.Position - arg4).Unit

						if magnitude > arg6 then
							arg6 = magnitude + 5
						end
					end
				end

				local v8 = table.pack(...)
				local v9 = getEntitiesFromRaycast
				v8.n = 7 + v8.n - 1
				table.move(v8, 1, v8.n, 7, v8)
				v8[1] = arg
				v8[2] = arg2
				v8[3] = arg3
				v8[4] = arg4
				v8[5] = arg5
				v8[6] = arg6
				return v9(table.unpack(v8, 1, v8.n))
			end
		end)

		pcall(function()
			local useItem = v3.Remotes.Replication.Fighter.UseItem
			if not useItem or type(hookfunction) ~= "function" then
				return
			end
			local v8 = nil

			local function fn10(arg, arg2, arg3, arg4, arg5, ...)
				if fn7() and EnumLibrary and arg3 == EnumLibrary:ToEnum("StartShooting") then
					local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
					local v9 = fn8()

					if humanoidRootPart and v9 then
						arg4 = fn9(humanoidRootPart.Position, v9) or arg4
					end
				end

				local v9 = v8
				local v10 = table.pack(...)
				v10.n = 6 + v10.n - 1
				table.move(v10, 1, v10.n, 6, v10)
				v10[1] = arg
				v10[2] = arg2
				v10[3] = arg3
				v10[4] = arg4
				v10[5] = arg5
				return v9(table.unpack(v10, 1, v10.n))
			end

			if type(newcclosure) == "function" then
				v8 = hookfunction
				v8 = v8(useItem.FireServer, newcclosure(fn10))
			else
				v8 = hookfunction
				v8 = v8(useItem.FireServer, fn10)
			end
		end)
	end

	pcall(function()
		local ok, result = pcall(function()
			return require(localPlayer2.PlayerScripts.Modules.ItemTypes.Gun)
		end)

		if ok and result and result.IsFullyAiming and not result.__phonk_sa_hooked then
			result.__phonk_sa_hooked = true
			local isFullyAiming = result.IsFullyAiming

			result.IsFullyAiming = function(arg, ...)
				if phonk.silent_aim.enable or phonk.gun_mods.enable then
					return true
				end
				return isFullyAiming(arg, ...)
			end
		end
	end)

	do
		local phonkUnderground = {
			active = false,
			saved_pos = nil,
			original_collide = {},
			last_key_state = false,
			tp_override = false,
		}

		getgenv().phonk_underground = phonkUnderground

		local function fn7(arg)
			local tbl3 = {}
			if not arg then
				return tbl3
			end

			for _, descendant in ipairs(arg:GetDescendants()) do
				if descendant:IsA("BasePart") then
					tbl3[#tbl3 + 1] = descendant
				end
			end

			return tbl3
		end

		local function fn8(arg, canCollide)
			for _, v8 in ipairs(arg) do
				pcall(function()
					v8.CanCollide = canCollide
				end)
			end
		end

		local function fn9(arg)
			local tbl3 = {}

			for _, v8 in ipairs(arg) do
				tbl3[v8] = v8.CanCollide
			end

			return tbl3
		end

		local function fn10(arg)
			for k, v8 in pairs(arg) do
				pcall(function()
					if k and k.Parent then
						k.CanCollide = v8
					end
				end)
			end
		end

		local function fn11(arg, arg2, arg3)
			local character = localPlayer2.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end

			pcall(function()
				local n = humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position
				humanoidRootPart.CFrame = CFrame.new(arg, arg2, arg3) * n
				humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				humanoidRootPart.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		local function fn12()
			if phonkUnderground.saved_pos then
				fn11(phonkUnderground.saved_pos.X, phonkUnderground.saved_pos.Y, phonkUnderground.saved_pos.Z)
			end

			fn10(phonkUnderground.original_collide)
			phonkUnderground.original_collide = {}
			phonkUnderground.active = false
			phonkUnderground.saved_pos = nil
			phonkUnderground.tp_override = false
		end

		local function fn13()
			local character = localPlayer2.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return
			end
			phonkUnderground.saved_pos = humanoidRootPart.Position
			local v8 = fn7(character)
			phonkUnderground.original_collide = fn9(v8)
			fn8(v8, false)
			phonkUnderground.active = true
		end

		local function fn14(arg)
			local v8 = options[arg]
			if not v8 or not v8.GetState then
				return false
			end

			local ok, result = pcall(function()
				return v8:GetState()
			end)

			return ok and result == true
		end

		v2:Add(v5.Heartbeat:Connect(function()
			if not phonk.underground.enable then
				if phonkUnderground.active then
					fn12()
				end

				phonkUnderground.last_key_state = false
				return
			end

			local character = localPlayer2.Character

			if not (character and character:FindFirstChild("HumanoidRootPart")) then
				if phonkUnderground.active then
					phonkUnderground.active = false
					phonkUnderground.saved_pos = nil
					phonkUnderground.original_collide = {}
				end

				return
			end

			local phonkMobileBtns = getgenv().phonk_mobile_btns
			local ugKey = fn14("ug_key") or phonkMobileBtns and phonkMobileBtns.underground == true

			if ugKey and not phonk.underground.enable then
				phonk.underground.enable = true
			end

			if ugKey and not phonkUnderground.active then
				fn13()
			elseif not ugKey and phonkUnderground.active then
				fn12()
			end

			if phonkUnderground.active and phonkUnderground.saved_pos and not phonkUnderground.tp_override then
				local value

				if options and options.ug_depth and type(options.ug_depth.Value) == "number" then
					value = options.ug_depth.Value
				else
					local depth = phonk.underground and phonk.underground.depth
					value = 5.8

					if depth then
						value = phonk.underground.depth
					end
				end

				-- DESYNC: aggressive jitter every frame so server-side hit registration
				-- can never lock onto us. X/Z spread of ±0.6 studs + depth flicker of
				-- ±0.45 studs means the server hitbox is essentially a blur at our depth.
				local jitterX = (math.random() - 0.5) * 1.2
				local jitterZ = (math.random() - 0.5) * 1.2
				-- Randomise depth between value-0.4 and value+0.45 every frame
				local depthVariance = (math.random() - 0.5) * 0.9
				local depthFlicker = value + depthVariance
				fn11(
					phonkUnderground.saved_pos.X + jitterX,
					phonkUnderground.saved_pos.Y - depthFlicker,
					phonkUnderground.saved_pos.Z + jitterZ
				)
				fn8(fn7(character), false)
			elseif phonkUnderground.active and phonkUnderground.tp_override then
				fn8(fn7(character), false)
			end
		end))

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			phonkUnderground.active = false
			phonkUnderground.saved_pos = nil
			phonkUnderground.original_collide = {}
			phonkUnderground.last_key_state = false
		end))

		v2:Add(function()
			if phonkUnderground.active then
				fn12()
			end
		end)
	end

	do
		local mouse = localPlayer2:GetMouse()
		local localFighter = nil

		task.spawn(function()
			for i = 1, 40 do
				pcall(function()
					localFighter = require(localPlayer2.PlayerScripts.Controllers.FighterController).LocalFighter
				end)

				if not localFighter then
					task.wait(0.25)
					continue
				end
				break
			end
		end)

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			task.wait(1)

			pcall(function()
				localFighter = require(localPlayer2.PlayerScripts.Controllers.FighterController).LocalFighter
			end)
		end))

		local function fn7(arg)
			if not arg then
				return false
			end
			return not workspace:FindPartOnRayWithIgnoreList(Ray.new(currentCamera.CFrame.Position, arg.Position - currentCamera.CFrame.Position), { localPlayer2.Character, arg.Parent })
		end

		local function fn8(arg)
			arg = arg and arg.Character
			if not arg then
				return false
			end

			for _, descendant in ipairs(arg:GetDescendants()) do
				if descendant:IsA("BasePart") and string.find(string.lower(descendant.Name), "riot") then
					return true
				end
			end

			return false
		end

		local tbl3 = {}

		local function fn9(arg)
			if tbl3[arg] then
				return true
			end

			local ok, result = pcall(function()
				return arg:GetAttribute("Deflecting")
			end)

			return ok and result == true
		end

		local function fn10()
			local ok, result = pcall(function()
				return require(localPlayer2.PlayerScripts.Modules.Items.Katana)
			end)

			if not ok or type(result) ~= "table" or not result._StartDeflecting then
				return
			end

			if result._phonk_hooked then
				return
			end
			result._phonk_hooked = true
			local startDeflecting = result._StartDeflecting

			result._StartDeflecting = function(...)
				local tbl4 = { ... }

				pcall(function()
					local v8 = tbl4[1]
					if type(v8) ~= "table" then
						return
					end
					local clientFighter = v8.ClientFighter
					clientFighter = clientFighter and clientFighter.Player

					if clientFighter then
						tbl3[clientFighter] = true
						local deflectDuration = v8.Info and v8.Info.DeflectDuration
						local n = 0.1

						if deflectDuration then
							n = v8.Info.DeflectDuration
						end

						task.delay(n, function()
							tbl3[clientFighter] = false
						end)
					end
				end)

				return startDeflecting(table.unpack(tbl4))
			end

			v2:Add(function()
				pcall(function()
					result._StartDeflecting = startDeflecting
				end)
			end)
		end

		task.spawn(function()
			for i = 1, 30 do
				fn10()

				if next then
					local ok, result = pcall(function()
						return require(localPlayer2.PlayerScripts.Modules.Items.Katana)
					end)

					if not (ok and result and result._phonk_hooked) then
						task.wait(0.5)
						continue
					end
				else
					task.wait(0.5)
					continue
				end

				break
			end
		end)

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			task.wait(1)
			fn10()
		end))

		local function fn11(arg)
			local vector2 = Vector2.new(mouse.X, mouse.Y)
			if not arg.Character then
				return nil
			end
			local huge = math.huge
			local v8 = nil

			for _, child in ipairs(arg.Character:GetChildren()) do
				if child:IsA("BasePart") then
					local v9, v10 = currentCamera:WorldToViewportPoint(child.Position)

					if v10 then
						local magnitude = (vector2 - Vector2.new(v9.X, v9.Y)).Magnitude

						if magnitude <= huge then
							huge = magnitude
							v8 = child
						end
					end
				end
			end

			return v8
		end

		local function fn12()
			local maxDistance = phonk.targeting.max_distance
			local vector2 = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
			local part = phonk.targeting.part or "Head"
			local fovRadius = phonk.aimbot.fov_radius or 180
			local v8 = nil

			for _, player in ipairs(v4:GetPlayers()) do
				if player ~= localPlayer2 and player.Character and player.Character:FindFirstChild(part) and player.Character:FindFirstChildOfClass("Humanoid") and player.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
					local flag = false

					if player:GetAttribute("TeamID") == localPlayer2:GetAttribute("TeamID") then
						flag = true
					end

					if not flag and phonk.targeting.anti_katana and fn9(player) then
						flag = true
					end

					if not flag and phonk.targeting.visible_only and not fn7(player.Character[part]) then
						flag = true
					end

					if not flag and phonk.targeting.riot_shield and fn8(player) then
						flag = true
					end

					if not flag then
						local v9, v10 = currentCamera:WorldToViewportPoint(player.Character[part].Position)

						if v10 then
							local magnitude = (vector2 - Vector2.new(v9.X, v9.Y)).Magnitude

							if magnitude < maxDistance and magnitude < fovRadius then
								maxDistance = magnitude
								v8 = player
							end
						end
					end
				end
			end

			return v8
		end

		local circle = nil

		if Drawing then
			circle = Drawing.new("Circle")
			circle.Thickness = 1
			circle.NumSides = 64
			circle.Filled = false
			circle.Visible = false

			v2:Add(function()
				pcall(function()
					circle:Remove()
				end)
			end)
		end

		local function fn13(arg)
			local v8 = options[arg]
			if not v8 then
				return false
			end

			if type(v8.GetState) == "function" then
				local ok, result = pcall(function()
					return v8:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if v8.Mode == "Always" then
				return true
			end

			if v8.Mode == "Toggle" then
				return v8.Toggled == true
			end

			if v8.Mode == "Hold" and v8.Value and v8.Value ~= "None" then
				local ok, result = pcall(function()
					return v6:IsKeyDown(Enum.KeyCode[v8.Value])
				end)

				return ok and result == true
			end

			return false
		end

		v2:Add(v5.Heartbeat:Connect(function()
		if getgenv().PhonkWare_Unloaded then return end
		
		if circle then
			if phonk.aimbot.enable and phonk.aimbot.show_fov then
					circle.Visible = true
					circle.Radius = phonk.aimbot.fov_radius or 180
					circle.Color = phonk.aimbot.fov_color or Color3.fromRGB(196, 30, 58)
					circle.Position = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
				else
					circle.Visible = false
				end
			end

			if not phonk.aimbot.enable then
				return
			end
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			if not (fn13("aim_key") or phonkMobileBtns and phonkMobileBtns.aimbot == true) then
				return
			end
			local v8 = fn12()
			if not (v8 and v8.Character) then
				return
			end
			local part = phonk.targeting and phonk.targeting.part or "Head"
			local position

			if phonk.aimbot.closest_part then
				local v9 = fn11(v8)

				if v9 then
					position = v9.Position
				else
					local character = v8.Character
					position = nil

					if character:FindFirstChild(part) then
						position = v8.Character[part].Position
					end
				end
			else
				local v9 = v8.Character:FindFirstChild(part)
				position = nil

				if v9 then
					position = v9.Position
				end
			end

			if not position then
				return
			end
			local n = (101 - math.clamp(tonumber(phonk.aimbot.smoothing) or 1, 1, 100)) / 100
			local position2 = currentCamera.CFrame.Position
			local n2 = position - position2
			if n2.Magnitude < 0.001 then
				return
			end
			local unit = n2.Unit
			local v9 = currentCamera.CFrame.LookVector:Lerp(unit, n)

			if not (v9.Magnitude < 0.001) then
				unit = v9.Unit
			end

			local cframe = CFrame.lookAt(position2, position2 + unit)

			pcall(function()
				if CameraController and type(CameraController.MimicRotation) == "function" then
					CameraController:MimicRotation(cframe)
				end

				currentCamera.CFrame = cframe
			end)
		end))

		local tbl4 = { is_shooting = false }

		v2:Add(task.spawn(function()
			while true do
				task.wait(0.05)
				local phonkMobileBtns = getgenv().phonk_mobile_btns

				if phonk.triggerbot.enable or phonkMobileBtns and phonkMobileBtns.triggerbot then
					local v8 = workspace:FindPartOnRayWithIgnoreList(Ray.new(currentCamera.CFrame.Position, currentCamera.CFrame.LookVector * (phonk.triggerbot.max_distance or 2500)), { localPlayer2.Character })

					if v8 and v8.Parent and v8.Parent:FindFirstChildWhichIsA("Humanoid") and v8.Parent:FindFirstChildWhichIsA("Humanoid").Health > 0 then
						local playerFromCharacter = v4:GetPlayerFromCharacter(v8.Parent)
						if phonk.triggerbot.team_check and playerFromCharacter and playerFromCharacter:GetAttribute("TeamID") == localPlayer2:GetAttribute("TeamID") then
							tbl4.is_shooting = false
							continue
						end

						if not tbl4.is_shooting then
							task.wait(phonk.triggerbot.reaction_time)
							tbl4.is_shooting = true
						end

						if localFighter then
							pcall(function()
								if setthreadidentity then
									setthreadidentity(2)
								end

								localFighter:Input("StartShooting")

								if setthreadidentity then
									setthreadidentity(7)
								end
							end)

							task.wait(phonk.triggerbot.shoot_delay)
							continue
						end

						continue
					end

					tbl4.is_shooting = false
					continue
				end

				tbl4.is_shooting = false
			end
		end))
	end

	do
		local tbl3 = {}
		local tbl4 = {}
		local tbl5 = {}

		local tbl6 = {
			Neon = Enum.Material.Neon,
			ForceField = Enum.Material.ForceField,
			Glass = Enum.Material.Glass,
			Metal = Enum.Material.Metal,
			Ice = Enum.Material.Ice,
			Plastic = Enum.Material.Plastic,
		}

		local function fn7(player)
			if tbl3[player] then
				pcall(function()
					tbl3[player]:Destroy()
				end)

				tbl3[player] = nil
			end

			local v8 = tbl4[player]

			if v8 then
				for k, v9 in pairs(v8) do
					if k.Parent then
						local c = v9.c
						local t = v9.t
						local r = v9.r
						k.Material = v9.m
						k.Color = c
						k.Transparency = t
						k.Reflectance = r
					end
				end

				tbl4[player] = nil
			end

			local v9 = tbl5[player]

			if v9 then
				for _, v10 in pairs(v9) do
					pcall(function()
						if v10.Remove then
							v10:Remove()
						else
							v10:Destroy()
						end
					end)
				end

				tbl5[player] = nil
			end
		end

		local function phonkClearEsp()
			for k in pairs(tbl3) do
				fn7(k)
			end

			for k in pairs(tbl4) do
				fn7(k)
			end

			for k in pairs(tbl5) do
				fn7(k)
			end
		end

		local function fn8(arg)
			if tbl5[arg] then
				return tbl5[arg]
			end

			if not Drawing then
				return nil
			end

			local tbl7 = {
				box = Drawing.new("Square"),
				name = Drawing.new("Text"),
				health = Drawing.new("Text"),
				distance = Drawing.new("Text"),
				weapon = Drawing.new("Text"),
				tracer = Drawing.new("Line"),
				head_circle = Drawing.new("Circle"),
				offscreen = Drawing.new("Triangle"),
				movement_pred = Drawing.new("Line"),
			}

			-- skeleton: 6 lines for torso+arms+legs approximation
			tbl7.skeleton_lines = {}
			for i = 1, 8 do
				local ln = Drawing.new("Line")
				ln.Thickness = 1
				ln.Visible = false
				tbl7.skeleton_lines[i] = ln
			end

			-- movement trail: up to 10 dots
			tbl7.trail_dots = {}
			for i = 1, 10 do
				local d = Drawing.new("Circle")
				d.Filled = true
				d.Radius = 2
				d.Visible = false
				tbl7.trail_dots[i] = d
			end
			tbl7._trail_positions = {}

			tbl7.box.Filled = false
			tbl7.box.Thickness = 1
			tbl7.name.Size = 14
			tbl7.name.Center = true
			tbl7.name.Outline = true
			tbl7.health.Size = 12
			tbl7.health.Center = true
			tbl7.health.Outline = true
			tbl7.distance.Size = 12
			tbl7.distance.Center = true
			tbl7.distance.Outline = true
			tbl7.weapon.Size = 11
			tbl7.weapon.Center = true
			tbl7.weapon.Outline = true
			tbl7.tracer.Thickness = 1
			tbl7.head_circle.Thickness = 1
			tbl7.head_circle.Filled = false
			tbl7.head_circle.NumSides = 32
			tbl7.offscreen.Filled = true
			tbl7.movement_pred.Thickness = 1

			for k, v8 in pairs(tbl7) do
				if type(v8) == "userdata" and v8.Visible ~= nil then
					v8.Visible = false
				end
			end

			tbl5[arg] = tbl7
			return tbl7
		end

		local function fn9(arg)
			local character = arg and arg.Character
			if not character then
				return false
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			return humanoid and humanoid.Health > 0 and humanoidRootPart ~= nil
		end

		local function fn10(arg)
			if arg == localPlayer2 or not fn9(arg) then
				fn7(arg)
				return
			end

			if phonk.esp.team_check then
				if arg:GetAttribute("TeamID") == localPlayer2:GetAttribute("TeamID") then
					fn7(arg)
					return
				end
			end

			local character = arg.Character
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local head = character:FindFirstChild("Head")

			if phonk.esp.highlight.enable then
				local v8 = tbl3[arg]

				if not v8 or not v8.Parent then
					local highlight = Instance.new("Highlight")
					highlight.Name = "phonk_esp"
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.Parent = character
					tbl3[arg] = highlight
					v8 = highlight
				end

				v8.Adornee = character
				v8.FillColor = phonk.esp.highlight.fill_color
				v8.FillTransparency = phonk.esp.highlight.fill_transparency
				v8.OutlineColor = phonk.esp.highlight.outline_color
				v8.OutlineTransparency = phonk.esp.highlight.outline_transparency
			elseif tbl3[arg] then
				pcall(function()
					tbl3[arg]:Destroy()
				end)

				tbl3[arg] = nil
			end

			if phonk.esp.chams.enable then
				local tbl7 = tbl4[arg] or {}
				tbl4[arg] = tbl7
				local neon = tbl6[phonk.esp.chams.material] or Enum.Material.Neon
				local transparency = phonk.esp.chams.ghost and 0.55 or phonk.esp.chams.transparency or 0

				for _, descendant in ipairs(character:GetDescendants()) do
					if descendant:IsA("BasePart") and descendant.Transparency < 1 then
						if not tbl7[descendant] then
							tbl7[descendant] = { m = descendant.Material, c = descendant.Color, t = descendant.Transparency, r = descendant.Reflectance }
						end

						descendant.Material = neon
						descendant.Color = phonk.esp.chams.color
						descendant.Transparency = transparency
						descendant.Reflectance = 0

						if phonk.esp.chams.strip_textures then
							for _, child in ipairs(descendant:GetChildren()) do
								if child:IsA("Decal") or child:IsA("Texture") then
									child.Transparency = 1
								end
							end
						end
					end
				end
			elseif tbl4[arg] then
				for k, v8 in pairs(tbl4[arg]) do
					if k.Parent then
						local c = v8.c
						local t = v8.t
						local r = v8.r
						k.Material = v8.m
						k.Color = c
						k.Transparency = t
						k.Reflectance = r
					end
				end

				tbl4[arg] = nil
			end

			local v8 = fn8(arg)
			if not v8 then
				return
			end
			local v9, v10 = currentCamera:WorldToViewportPoint(humanoidRootPart.Position)

			if not v10 or v9.Z < 0 then
				for _, v11 in pairs(v8) do
					v11.Visible = false
				end

				return
			end

			local value = head and select(1, currentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))) or v9
			local n = math.max(math.abs(value.Y - select(1, currentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, 3, 0))).Y), 8)
			local n2 = n * 0.55
			local n3 = v9.X - n2 / 2
			local y = value.Y

			if phonk.esp.box.enable then
				v8.box.Size = Vector2.new(n2, n)
				v8.box.Position = Vector2.new(n3, y)
				v8.box.Color = phonk.esp.box.color
				v8.box.Thickness = phonk.esp.box.thickness or 1
				v8.box.Visible = true
			else
				v8.box.Visible = false
			end

			if phonk.esp.name.enable then
				v8.name.Text = arg.DisplayName or arg.Name
				v8.name.Position = Vector2.new(v9.X, y - 15)
				v8.name.Color = phonk.esp.name.color
				v8.name.Visible = true
			else
				v8.name.Visible = false
			end

			if phonk.esp.health.enable then
				v8.health.Text = tostring(math.floor(humanoid.Health + 0.5))
				v8.health.Position = Vector2.new(n3 - 12, y + n * (1 - humanoid.Health / math.max(humanoid.MaxHealth, 1)))
				v8.health.Color = phonk.esp.health.color
				v8.health.Visible = true
			else
				v8.health.Visible = false
			end

			if phonk.esp.distance.enable then
				local humanoidRootPart2 = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
				v8.distance.Text = string.format("%dst", math.floor((humanoidRootPart2 and (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude or 0) + 0.5))
				v8.distance.Position = Vector2.new(v9.X, y + n + 2)
				v8.distance.Color = phonk.esp.distance.color
				v8.distance.Visible = true
			else
				v8.distance.Visible = false
			end

			if phonk.esp.tracer.enable then
				local viewportSize = currentCamera.ViewportSize
				local vector2

				if phonk.esp.tracer.origin == "center" then
					vector2 = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
				elseif phonk.esp.tracer.origin == "mouse" then
					local mouseLocation = v6:GetMouseLocation()
					vector2 = Vector2.new(mouseLocation.X, mouseLocation.Y)
				else
					vector2 = Vector2.new(viewportSize.X / 2, viewportSize.Y)
				end

				v8.tracer.From = vector2
				v8.tracer.To = Vector2.new(v9.X, y + n)
				v8.tracer.Color = phonk.esp.tracer.color
				v8.tracer.Visible = true
			else
				v8.tracer.Visible = false
			end

			-- ── WEAPON LABEL ──────────────────────────────────────
			if phonk.esp.weapon and phonk.esp.weapon.enable then
				local weaponName = ""
				pcall(function()
					local viewModels = workspace:FindFirstChild("ViewModels")
					if viewModels then
						for _, child in ipairs(viewModels:GetChildren()) do
							if string.find(child.Name, arg.Name, 1, true) or string.find(child.Name, arg.DisplayName or "", 1, true) then
								local match = string.match(child.Name, "^.-%s%-%s(.-)%s%-")
								if match then weaponName = match end
								break
							end
						end
					end
				end)
				if weaponName ~= "" and v8.weapon then
					v8.weapon.Text = weaponName
					v8.weapon.Position = Vector2.new(v9.X, y + n + 14)
					v8.weapon.Color = phonk.esp.weapon.color
					v8.weapon.Visible = true
				elseif v8.weapon then
					v8.weapon.Visible = false
				end
			elseif v8.weapon then
				v8.weapon.Visible = false
			end

			-- ── HEAD CIRCLE ────────────────────────────────────────
			if phonk.esp.head_circle and phonk.esp.head_circle.enable and head then
				local headScreenPos, headOnScreen = currentCamera:WorldToViewportPoint(head.Position)
				if headOnScreen and v8.head_circle then
					local headTop, _ = currentCamera:WorldToViewportPoint(head.Position + Vector3.new(0, head.Size.Y / 2, 0))
					local headRadius = math.max(math.abs(headTop.Y - headScreenPos.Y), 4)
					v8.head_circle.Position = Vector2.new(headScreenPos.X, headScreenPos.Y)
					v8.head_circle.Radius = headRadius
					v8.head_circle.Color = phonk.esp.head_circle.color
					v8.head_circle.Visible = true
				elseif v8.head_circle then
					v8.head_circle.Visible = false
				end
			elseif v8.head_circle then
				v8.head_circle.Visible = false
			end

			-- ── SKELETON ──────────────────────────────────────────
			if phonk.esp.skeleton and phonk.esp.skeleton.enable and v8.skeleton_lines then
				-- bone pairs: [part1, part2]
				local bonePairs = {
					{"Head", "UpperTorso"},
					{"UpperTorso", "LowerTorso"},
					{"LowerTorso", "LeftUpperLeg"},
					{"LowerTorso", "RightUpperLeg"},
					{"UpperTorso", "LeftUpperArm"},
					{"UpperTorso", "RightUpperArm"},
					{"LeftUpperArm", "LeftLowerArm"},
					{"RightUpperArm", "RightLowerArm"},
				}
				for i, pair in ipairs(bonePairs) do
					local ln = v8.skeleton_lines[i]
					if ln then
						local p1 = character:FindFirstChild(pair[1])
						local p2 = character:FindFirstChild(pair[2])
						if p1 and p2 then
							local s1, on1 = currentCamera:WorldToViewportPoint(p1.Position)
							local s2, on2 = currentCamera:WorldToViewportPoint(p2.Position)
							if on1 and on2 then
								ln.From = Vector2.new(s1.X, s1.Y)
								ln.To = Vector2.new(s2.X, s2.Y)
								ln.Color = phonk.esp.skeleton.color
								ln.Visible = true
							else
								ln.Visible = false
							end
						else
							ln.Visible = false
						end
					end
				end
			elseif v8.skeleton_lines then
				for _, ln in ipairs(v8.skeleton_lines) do ln.Visible = false end
			end

			-- ── MOVEMENT TRAIL ────────────────────────────────────
			if phonk.esp.movement_trail and phonk.esp.movement_trail.enable and v8.trail_dots then
				local trailPos = v8._trail_positions or {}
				local curScreenPos = Vector2.new(v9.X, v9.Y)
				local lastPos = trailPos[#trailPos]
				if not lastPos or (curScreenPos - lastPos).Magnitude > 3 then
					table.insert(trailPos, curScreenPos)
					if #trailPos > 10 then table.remove(trailPos, 1) end
				end
				v8._trail_positions = trailPos
				for i, dot in ipairs(v8.trail_dots) do
					local tp = trailPos[i]
					if tp then
						dot.Position = tp
						dot.Color = phonk.esp.movement_trail.color
						dot.Transparency = 1 - (i / 10)
						dot.Visible = true
					else
						dot.Visible = false
					end
				end
			elseif v8.trail_dots then
				for _, dot in ipairs(v8.trail_dots) do dot.Visible = false end
				v8._trail_positions = {}
			end

			-- ── MOVEMENT PREDICTION ────────────────────────────────
			if phonk.esp.movement_prediction and phonk.esp.movement_prediction.enable and v8.movement_pred then
				local vel = humanoidRootPart.AssemblyLinearVelocity
				if vel.Magnitude > 1 then
					local predPos = humanoidRootPart.Position + vel * 0.2
					local predScreen, predOn = currentCamera:WorldToViewportPoint(predPos)
					if predOn then
						v8.movement_pred.From = Vector2.new(v9.X, v9.Y)
						v8.movement_pred.To = Vector2.new(predScreen.X, predScreen.Y)
						v8.movement_pred.Color = phonk.esp.movement_prediction.color
						v8.movement_pred.Visible = true
					else
						v8.movement_pred.Visible = false
					end
				else
					v8.movement_pred.Visible = false
				end
			elseif v8.movement_pred then
				v8.movement_pred.Visible = false
			end

			-- ── OFF-SCREEN ARROWS ─────────────────────────────────
			if phonk.esp.offscreen_arrows and phonk.esp.offscreen_arrows.enable and v8.offscreen then
				if not v10 then -- v10 is the onscreen boolean from WorldToViewportPoint
					-- player is off-screen: draw arrow pointing toward them
					local viewCenter = currentCamera.ViewportSize / 2
					local dir = (Vector2.new(v9.X, v9.Y) - viewCenter)
					if dir.Magnitude > 0 then
						dir = dir.Unit
						local arrowPos = viewCenter + dir * (phonk.esp.offscreen_arrows.radius or 100)
						local angle = math.atan2(dir.Y, dir.X)
						local arrowSize = 10
						local tip = arrowPos
						local left = arrowPos + Vector2.new(math.cos(angle + math.pi * 0.75), math.sin(angle + math.pi * 0.75)) * arrowSize
						local right = arrowPos + Vector2.new(math.cos(angle - math.pi * 0.75), math.sin(angle - math.pi * 0.75)) * arrowSize
						v8.offscreen.PointA = tip
						v8.offscreen.PointB = left
						v8.offscreen.PointC = right
						v8.offscreen.Color = phonk.esp.offscreen_arrows.color
						v8.offscreen.Visible = true
					else
						v8.offscreen.Visible = false
					end
				else
					v8.offscreen.Visible = false
				end
			elseif v8.offscreen then
				v8.offscreen.Visible = false
			end
		end

		v2:Add(v5.RenderStepped:Connect(function()
			if not phonk.esp.enable then
				phonkClearEsp()
				return
			end

			for _, player in ipairs(v4:GetPlayers()) do
				fn10(player)
			end

			for k in pairs(tbl5) do
				if not k.Parent then
					fn7(k)
				end
			end
		end))

		v2:Add(v4.PlayerRemoving:Connect(fn7))
		v2:Add(phonkClearEsp)
		getgenv().phonk_clear_esp = phonkClearEsp
	end

	do
		local atmosphere = v7:FindFirstChildOfClass("Atmosphere")

		if not atmosphere then
			atmosphere = Instance.new("Atmosphere")
			atmosphere.Parent = v7
		end

		local tbl3 = {
			Density = atmosphere.Density,
			Offset = atmosphere.Offset,
			Color = atmosphere.Color,
			Decay = atmosphere.Decay,
			Glare = atmosphere.Glare,
			Haze = atmosphere.Haze,
		}

		local phonkColorCorrection = v7:FindFirstChild("PhonkColorCorrection")

		if not phonkColorCorrection then
			phonkColorCorrection = Instance.new("ColorCorrectionEffect")
			phonkColorCorrection.Name = "PhonkColorCorrection"
			phonkColorCorrection.Enabled = false
			phonkColorCorrection.Parent = v7
		end

		local function phonkUpdateWorldFx()
			local atmosphere2 = phonk.world.atmosphere

			if atmosphere2 and atmosphere2.enable then
				local v8 = atmosphere
				local v9 = atmosphere
				local offset = atmosphere2.offset
				local color = atmosphere2.color
				atmosphere.Density = atmosphere2.density
				v8.Offset = offset
				v9.Color = color
				local v10 = atmosphere
				local v11 = atmosphere
				local decay = atmosphere2.decay
				local glare = atmosphere2.glare
				local haze = atmosphere2.haze
				atmosphere.Decay = decay
				v10.Glare = glare
				v11.Haze = haze
			else
				local v8 = atmosphere
				local v9 = atmosphere
				local offset = tbl3.Offset
				local color = tbl3.Color
				atmosphere.Density = tbl3.Density
				v8.Offset = offset
				v9.Color = color
				local v10 = atmosphere
				local v11 = atmosphere
				local glare = tbl3.Glare
				local haze = tbl3.Haze
				atmosphere.Decay = tbl3.Decay
				v10.Glare = glare
				v11.Haze = haze
			end

			local colorCorrection = phonk.world.color_correction

			if colorCorrection then
				phonkColorCorrection.Enabled = colorCorrection.enable == true

				if colorCorrection.enable then
					local v8 = phonkColorCorrection
					local v9 = phonkColorCorrection
					local v10 = phonkColorCorrection
					local brightness = colorCorrection.brightness
					local contrast = colorCorrection.contrast
					local saturation = colorCorrection.saturation
					local tint = colorCorrection.tint
					phonkColorCorrection.Brightness = brightness
					v8.Contrast = contrast
					v9.Saturation = saturation
					v10.TintColor = tint
				end
			end
		end

		getgenv().phonk_update_world_fx = phonkUpdateWorldFx

		v2:Add(v5.Heartbeat:Connect(function()
			local enable = phonk.world.atmosphere and phonk.world.atmosphere.enable
			local enable2

			if enable then
				enable2 = enable
			else
				enable2 = phonk.world.color_correction and phonk.world.color_correction.enable
			end

			if enable2 then
				phonkUpdateWorldFx()
			end
		end))
	end

	task.spawn(function()
		local ok, result = pcall(function()
			local request_ = syn and syn.request or http and http.request or request or http_request
			local body = nil

			if type(request_) == "function" then
				local v8 = request_({
					Url = "https://raw.githubusercontent.com/Username22477/Keys/refs/heads/main/Keys.txt",
					Method = "GET",
				})

				body = nil

				if type(v8) == "table" then
					body = v8.Body or v8.body
				end
			end

			if type(body) ~= "string" or body == "" then
				local ok, result = pcall(function()
					return game:HttpGet("https://raw.githubusercontent.com/Username22477/Keys/refs/heads/main/Keys.txt")
				end)

				if ok and type(result) == "string" then
					body = result
				end
			end

			if type(body) ~= "string" or body == "" then
				error("keys download failed (not a string)")
			end

			local chunk, v8 = loadstring(body)

			if type(chunk) ~= "function" then
				error("keys compile failed: " .. tostring(v8))
			end

			chunk()
		end)

		if not ok then
			warn("[PhonkWare] Unlock all skipped: " .. tostring(result))
		end
	end)

	task.spawn(function()
		pcall(function()
			local modules = v3:WaitForChild("Modules", 10)
			local controllers = localPlayer2:WaitForChild("PlayerScripts"):WaitForChild("Controllers", 10)
			if not modules or not controllers then
				return
			end
			local CosmeticLibrary = require(modules:WaitForChild("CosmeticLibrary"))
			local EmoteController = require(controllers:WaitForChild("EmoteController"))
			local FighterController = require(controllers:WaitForChild("FighterController"))
			local PlayerDataController = require(controllers:WaitForChild("PlayerDataController"))
			local flag = false
			local v8 = nil
			local v9 = nil
			local connection = nil
			local cameraMode = nil
			local cameraMinZoomDistance = nil

			local function fn7(arg)
				if not arg then
					return
				end

				if type(arg) == "table" then
					if type(arg.Fire) == "function" then
						pcall(function()
							arg:Fire()
						end)
					elseif type(arg.fire) == "function" then
						pcall(function()
							arg:fire()
						end)
					end
				elseif typeof(arg) == "Instance" and arg:IsA("BindableEvent") then
					pcall(function()
						arg:Fire()
					end)
				end
			end

			local function fn8()
				if not flag then
					return
				end
				flag = false
				v8 = nil

				pcall(function()
					if cameraMode ~= nil then
						localPlayer2.CameraMode = cameraMode
						cameraMode = nil
					end

					if cameraMinZoomDistance ~= nil then
						localPlayer2.CameraMinZoomDistance = cameraMinZoomDistance
						cameraMinZoomDistance = nil
					end
				end)

				local fighter = FighterController:GetFighter(localPlayer2)
				local entity = fighter and fighter.Entity

				if entity and entity.EmoteStatusChanged then
					fn7(entity.EmoteStatusChanged)
				end

				if v9 then
					pcall(function()
						v9:Destroy()
					end)

					v9 = nil
				end
			end

			local function fn9(arg)
				if not arg then
					return
				end
				local humanoid = arg:WaitForChild("Humanoid", 10)
				if not humanoid then
					return
				end

				if connection then
					connection:Disconnect()
					connection = nil
				end

				connection = humanoid.Running:Connect(function(arg2)
					if arg2 > 0.1 and flag then
						fn8()
					end
				end)

				v2:Add(connection)
			end

			if localPlayer2.Character then
				fn9(localPlayer2.Character)
			end

			v2:Add(localPlayer2.CharacterAdded:Connect(function(character)
				fn8()
				fn9(character)
			end))

			local ownsCosmetic = CosmeticLibrary.OwnsCosmetic

			CosmeticLibrary.OwnsCosmetic = function(arg, arg2, arg3)
				local v10 = CosmeticLibrary.Cosmetics[arg3]
				if v10 and v10.Type == "Emote" then
					return true
				end
				return ownsCosmetic(arg, arg2, arg3)
			end

			local canEmote = EmoteController.CanEmote

			EmoteController.CanEmote = function(arg, arg2)
				local ok, result = pcall(canEmote, arg, arg2)
				if ok and result then
					return true
				end
				local fighter = FighterController:GetFighter(localPlayer2)

				if fighter and fighter.IsLocalPlayer and fighter:IsAlive() then
					local entity = fighter.Entity
					if entity and not entity:Get("IsFrozen") then
						return true
					end
				end

				return false
			end

			local function fn10()
				local fighter = FighterController:GetFighter(localPlayer2)
				if fighter and fighter.IsLocalPlayer then
					return fighter.Entity
				end
				return nil
			end

			local isEmoting = nil
			local getCurrentEmote = nil
			local v10 = nil

			local function fn11()
				if v10 and isEmoting then
					pcall(function()
						v10.IsEmoting = isEmoting
					end)
				end

				if v10 and getCurrentEmote then
					pcall(function()
						v10.GetCurrentEmote = getCurrentEmote
					end)
				end

				v10 = nil
				isEmoting = nil
				getCurrentEmote = nil
			end

			local function fn12(arg)
				if not arg or v10 == arg then
					return
				end

				if v10 then
					fn11()
				end

				v10 = arg
				isEmoting = arg.IsEmoting
				getCurrentEmote = arg.GetCurrentEmote

				arg.IsEmoting = function(arg2, ...)
					if flag then
						return true
					end
					local v11 = table.pack(...)
					return isEmoting(arg2, table.unpack(v11, 1, v11.n))
				end

				arg.GetCurrentEmote = function(arg2, ...)
					if flag and v8 then
						return v8
					end
					return getCurrentEmote(arg2, ...)
				end
			end

			local useEmoteByName = EmoteController.UseEmoteByName

			EmoteController.UseEmoteByName = function(arg, arg2)
				fn8()
				local v11 = ownsCosmetic(CosmeticLibrary, PlayerDataController:Get("CosmeticInventory"), arg2)

				pcall(function()
					useEmoteByName(arg, arg2)
				end)

				if not v11 then
					task.spawn(function()
						local emotes = modules:FindFirstChild("Emotes")
						local v12 = emotes and emotes:FindFirstChild(arg2)
						local character = localPlayer2.Character
						local humanoid = character and character:FindFirstChildOfClass("Humanoid")

						if v12 and humanoid then
							task.wait(0.1)

							pcall(function()
								v9 = require(v12).new(humanoid)
								cameraMode = localPlayer2.CameraMode
								cameraMinZoomDistance = localPlayer2.CameraMinZoomDistance
								localPlayer2.CameraMode = Enum.CameraMode.Classic
								localPlayer2.CameraMinZoomDistance = 8
								flag = true
								v8 = v9
								local v13 = fn10()

								if v13 then
									fn12(v13)

									if v13.EmoteStatusChanged then
										fn7(v13.EmoteStatusChanged)
									end
								end

								task.defer(v9.Simulate, v9)
								v9.Destroying:Wait()

								if flag then
									fn8()
								end

								fn11()
							end)
						end
					end)
				end
			end

			print("[PhonkWare] Emote unlock ready")
		end)
	end)

	do
		local tbl3 = {
			hitmarker = "rbxassetid://133749572213659",
			fatality = "rbxassetid://6534947869",
			csgo = "rbxassetid://5764885315",
			rust = "rbxassetid://1255040462",
			bonk = "rbxassetid://5766898159",
		}

		local sound = Instance.new("Sound")
		sound.Volume = 1
		sound.Parent = game:GetService("SoundService")
		v2:Add(sound)
		local playHitmarkerSound = nil

		pcall(function()
			local ClientViewModel = require(localPlayer2.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel)
			playHitmarkerSound = ClientViewModel.PlayHitmarkerSound

			ClientViewModel.PlayHitmarkerSound = function(arg, arg2, arg3)
				if phonk.hitsounds.enable then
					local customId = phonk.hitsounds.custom_id

					if customId == "" then
						customId = tbl3[phonk.hitsounds.selected]
					end

					if customId and customId ~= "" then
						if not customId:find("rbxassetid://") and not customId:find("rbxasset://") then
							customId = "rbxassetid://" .. customId
						end

						sound.SoundId = customId
						sound.Volume = phonk.hitsounds.volume
						sound.PlaybackSpeed = phonk.hitsounds.pitch

						if sound.IsPlaying then
							sound:Stop()
						end

						sound.TimePosition = 0
						sound:Play()
					end

					return
				end

				if playHitmarkerSound then
					return playHitmarkerSound(arg, arg2, arg3)
				end
			end
		end)

		pcall(function()
			local Utility = require(v3.Modules.Utility)
			local playParticles = Utility.PlayParticles

			Utility.PlayParticles = function(arg, arg2)
				if phonk.remove_muzzle.enable and arg2 and arg2.Name == "_muzzle" then
					return
				end
				return playParticles(arg, arg2)
			end
		end)

		v2:Add(v5.Heartbeat:Connect(function()
			if not phonk.remove_gun_sounds.enable then
				return
			end
			local v8 = ipairs
			local SoundService = game:GetService("SoundService")

			for _, descendant in v8(SoundService:GetDescendants()) do
				if descendant:IsA("Sound") and descendant ~= sound then
					local v9 = string.lower(descendant.Name)

					if v9:find("shoot") or v9:find("gun") or v9:find("fire") or v9:find("muzzle") or v9:find("reload") then
						descendant.Volume = 0
					end
				end
			end

			local viewModels = workspace:FindFirstChild("ViewModels")

			if viewModels then
				for _, descendant in ipairs(viewModels:GetDescendants()) do
					if descendant:IsA("Sound") then
						local v9 = string.lower(descendant.Name)

						if v9:find("shoot") or v9:find("fire") or v9:find("reload") then
							descendant.Volume = 0
						end
					end
				end
			end
		end))
	end

	do
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "PhonkWareDamageNumbers"
		screenGui.ResetOnSpawn = false
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 500

		pcall(function()
			screenGui.Parent = gethui and gethui() or game:GetService("CoreGui")
		end)

		if not screenGui.Parent then
			pcall(function()
				screenGui.Parent = localPlayer2:FindFirstChildOfClass("PlayerGui")
			end)
		end

		v2:Add(function()
			pcall(function()
				screenGui:Destroy()
			end)
		end)

		local function fn7(arg)
			local ok, result = pcall(function()
				return Enum.Font[arg]
			end)

			return ok and result or Enum.Font.GothamBold
		end

		local function fn8(arg, arg2, arg3)
			local damageNumbers = phonk.damage_numbers
			if not damageNumbers or not damageNumbers.enable or not arg3 then
				return
			end
			local currentCamera2 = workspace.CurrentCamera
			if not currentCamera2 then
				return
			end
			local v8, v9 = currentCamera2:WorldToViewportPoint(arg3)
			if not v9 then
				return
			end
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.Size = UDim2.fromOffset(140, 26)
			textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			textLabel.Position = UDim2.fromOffset(v8.X, v8.Y)
			textLabel.Font = fn7(damageNumbers.font or "GothamBold")
			textLabel.TextSize = damageNumbers.text_size or 18
			textLabel.Text = "-" .. tostring(math.floor(arg2 + 0.5))
			textLabel.TextStrokeTransparency = 1
			textLabel.TextColor3 = damageNumbers.color1 or damageNumbers.color or Color3.fromRGB(255, 80, 80)
			textLabel.ZIndex = 10
			textLabel.Parent = screenGui
			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 1.5
			uiStroke.Color = Color3.new(0, 0, 0)
			uiStroke.Transparency = 0.15
			uiStroke.LineJoinMode = Enum.LineJoinMode.Round
			uiStroke.Parent = textLabel
			local uiScale = Instance.new("UIScale")
			uiScale.Scale = 0.5
			uiScale.Parent = textLabel

			if damageNumbers.color_type == "Gradient" then
				local uiGradient = Instance.new("UIGradient")
				local colorSequence = ColorSequence.new
				local tbl3 = {}
				local v10 = ColorSequenceKeypoint.new(0, damageNumbers.color1 or Color3.fromRGB(255, 80, 80))
				local new = ColorSequenceKeypoint.new
				local color2 = damageNumbers.color2 or Color3.fromRGB(255, 200, 80)
				local v11 = table.pack(new(1, color2))
				tbl3[1] = v10

				do
					local values = table.pack(table.unpack(v11, 1, v11.n))
					table.move(values, 1, values.n, 2, tbl3)
				end

				uiGradient.Color = colorSequence(tbl3)
				uiGradient.Rotation = 90
				uiGradient.Parent = textLabel
				textLabel.TextColor3 = Color3.new(1, 1, 1)
			end

			local x = v8.X
			local y = v8.Y
			local n = math.random(-14, 14)
			local now2 = tick()
			local duration = damageNumbers.duration or 0.8
			local rise = damageNumbers.rise or 42
			local connection = nil

			connection = v5.RenderStepped:Connect(function()
				local n2 = (tick() - now2) / duration

				if n2 >= 1 then
					connection:Disconnect()

					pcall(function()
						textLabel:Destroy()
					end)

					return
				end

				local n3 = 1 - (1 - n2) * (1 - n2)
				textLabel.Position = UDim2.fromOffset(x + n * n3, y - rise * n3)
				uiScale.Scale = 0.5 + 0.6 * math.min(n2 * 3, 1)
				local textTransparency = n2 > 0.55 and (n2 - 0.55) / 0.45 or 0
				textLabel.TextTransparency = textTransparency
				uiStroke.Transparency = 0.15 + textTransparency * 0.85
			end)
		end

		local function fn9()
			return (pcall(function()
				local localFighter = require(localPlayer2.PlayerScripts.Controllers.FighterController).LocalFighter
				if not localFighter or not localFighter.ReplicateFromServer then
					return
				end

				if localFighter._phonk_dmg_hooked then
					return
				end
				localFighter._phonk_dmg_hooked = true
				local replicateFromServer = localFighter.ReplicateFromServer

				localFighter.ReplicateFromServer = function(arg, arg2, ...)
					local v8 = table.pack(...)

					if arg2 ~= "DamageNumberEffect" then
						local v9 = table.pack(...)
						local v10 = replicateFromServer
						v9.n = 3 + v9.n - 1
						table.move(v9, 1, v9.n, 3, v9)
						v9[1] = arg
						v9[2] = arg2
						return v10(table.unpack(v9, 1, v9.n))
					end

					local tbl3 = { ... }
					local v9 = tbl3[1]
					local v10 = tbl3[2]
					local v11 = tbl3[3]

					if v9 and v10 then
						local parent = typeof(v9) == "Instance" and v9.Parent

						if parent and parent:FindFirstChildOfClass("Humanoid") then
							if phonk.damage_numbers.enable then
								local n = nil

								pcall(function()
									n = v9.Position + Vector3.new(0, v11 and 2.6 or 2.1, 0)
								end)

								if n then
									fn8(v4:GetPlayerFromCharacter(parent), v10, n)
								end
							end

							if phonk.damage_numbers.enable or phonk.damage_numbers.remove_ingame then
								return
							end
						end
					end

					return replicateFromServer(arg, arg2, table.unpack(v8, 1, v8.n))
				end
			end))
		end

		task.spawn(function()
			for i = 1, 60 do
				if not fn9() then
					task.wait(0.25)
					continue
				end
				break
			end
		end)

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			task.wait(0.8)

			pcall(function()
				local FighterController = require(localPlayer2.PlayerScripts.Controllers.FighterController)

				if FighterController.LocalFighter then
					FighterController.LocalFighter._phonk_dmg_hooked = nil
				end
			end)

			fn9()
		end))
	end

	do
		local tbl3 = {}

		local function fn7(arg)
			local value = rawget(arg, "Animator")
			if not value or tbl3[value] then
				return
			end
			tbl3[value] = true
			local v8 = getmetatable(value)
			local value2 = rawget(value, "PlayAnimation") or v8 and rawget(v8, "PlayAnimation")
			if not value2 then
				return
			end

			value.PlayAnimation = function(arg2, arg3, ...)
				local disableAnims = phonk.disable_anims

				if disableAnims.enable then
					local str = tostring(arg3):lower()
					local v9 = table.find(disableAnims.select, "shoot")
					local pos

					if v9 then
						pos = str:find("shoot") or str:find("fire")
					else
						pos = v9
					end

					if pos then
						return
					end

					if table.find(disableAnims.select, "reload") and str:find("reload") then
						return
					end

					if table.find(disableAnims.select, "equip") and str:find("equip") then
						return
					end

					if table.find(disableAnims.select, "attack") and str:find("attack") then
						return
					end

					if table.find(disableAnims.select, "charge") and str:find("charge") then
						return
					end

					if table.find(disableAnims.select, "throw") and str:find("throw") then
						return
					end
				end

				local v9 = table.pack(...)
				local v10 = value2
				v9.n = 3 + v9.n - 1
				table.move(v9, 1, v9.n, 3, v9)
				v9[1] = arg2
				v9[2] = arg3
				return v10(table.unpack(v9, 1, v9.n))
			end
		end

		local ClientViewModel = require(localPlayer2.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem.ClientViewModel)
		local update = ClientViewModel.Update

		ClientViewModel.Update = function(arg, arg2, arg3, arg4)
			if arg.ClientItem.ClientFighter.IsLocalPlayer then
				fn7(arg)
				local disableAnims = phonk.disable_anims

				if disableAnims.enable then
					if table.find(disableAnims.select, "bobbing") then
						arg._bobbing_value_spring.Value = Vector2.new(0, 0)
						arg._bobbing_value_spring.Target = Vector2.new(0, 0)
						arg._bobbing_speed_spring.Value = 0
						arg._bobbing_speed_spring.Target = 0
						arg._bobbing_tick = 0
					end

					if table.find(disableAnims.select, "landing") then
						arg._landing_spring.Value = 0
						arg._landing_spring.Target = 0
						arg._jump_spring.Value = 0
						arg._jump_spring.Target = 0
					end

					if table.find(disableAnims.select, "sway") then
						arg._sway_spring.Value = Vector2.new(0, 0)
						arg._sway_spring.Target = Vector2.new(0, 0)
						arg._tilt_spring.Value = Vector2.new(0, 0)
						arg._tilt_spring.Target = Vector2.new(0, 0)
					end

					if table.find(disableAnims.select, "equip") then
						arg._equip_spring.Position = arg._equip_spring.Target
						arg._equip_spring.Velocity = 0
					end

					if table.find(disableAnims.select, "inspect") then
						arg._inspect_spring.Position = arg._inspect_spring.Target
						arg._inspect_spring.Velocity = 0
					end

					if table.find(disableAnims.select, "sliding") and arg3 then
						arg3.IsSliding = false
					end

					if table.find(disableAnims.select, "shoot") then
						arg._recoil_spring.Value = Vector3.zero
						arg._recoil_spring.Target = Vector3.zero
						arg._unrecoil_spring.Value = Vector3.zero
						arg._unrecoil_spring.Target = Vector3.zero
					end

					if table.find(disableAnims.select, "impulse") then
						arg._impulse_position_spring.Value = Vector3.zero
						arg._impulse_position_spring.Target = Vector3.zero
					end

					if table.find(disableAnims.select, "aim") then
						arg._aim_spring.Position = arg._aim_spring.Target
						arg._aim_spring.Velocity = 0
					end

					if table.find(disableAnims.select, "sprint") and arg3 then
						arg3.IsActuallySprinting = false
					end
				end
			end

			return update(arg, arg2, arg3, arg4)
		end

		v2:Add(function()
			ClientViewModel.Update = update
		end)
	end

	do
		local tbl3 = { ParticleEmitter = true, Trail = true, Smoke = true, Fire = true, Sparkles = true }

		local tbl4 = {
			BloomEffect = true,
			BlurEffect = true,
			ColorCorrectionEffect = true,
			SunRaysEffect = true,
			DepthOfFieldEffect = true,
		}

		local obj = setmetatable({}, { __mode = "k" })
		local obj2 = setmetatable({}, { __mode = "k" })
		local obj3 = setmetatable({}, { __mode = "k" })

		local function fn7(arg, arg2)
			if not tbl3[arg.ClassName] then
				return
			end

			if arg2 then
				if obj[arg] == nil then
					obj[arg] = arg.Enabled
				end

				pcall(function()
					arg.Enabled = false
				end)
			elseif obj[arg] ~= nil then
				pcall(function()
					arg.Enabled = obj[arg]
				end)

				obj[arg] = nil
			end
		end

		local function fn8(arg, arg2)
			if not (arg:IsA("Decal") or arg:IsA("Texture")) then
				return
			end

			if arg2 then
				if obj2[arg] == nil then
					obj2[arg] = arg.Transparency
				end

				pcall(function()
					arg.Transparency = 1
				end)
			elseif obj2[arg] ~= nil then
				pcall(function()
					arg.Transparency = obj2[arg]
				end)

				obj2[arg] = nil
			end
		end

		local function fn9(arg, arg2)
			if not tbl4[arg.ClassName] then
				return
			end

			if arg2 then
				if obj3[arg] == nil then
					obj3[arg] = arg.Enabled
				end

				pcall(function()
					arg.Enabled = false
				end)
			elseif obj3[arg] ~= nil then
				pcall(function()
					arg.Enabled = obj3[arg]
				end)

				obj3[arg] = nil
			end
		end

		v2:Add(workspace.DescendantAdded:Connect(function(descendant)
			if phonk.optimizations.no_particles then
				fn7(descendant, true)
			end

			if phonk.optimizations.no_textures then
				fn8(descendant, true)
			end
		end))

		v2:Add(v7.DescendantAdded:Connect(function(descendant)
			if phonk.optimizations.no_postfx then
				fn9(descendant, true)
			end
		end))

		getgenv().phonk_apply_opt = function()
			local optimizations = phonk.optimizations

			if optimizations.no_shadows then
				pcall(function()
					v7.GlobalShadows = false
				end)
			end

			if optimizations.no_atmosphere then
				local atmosphere = v7:FindFirstChildOfClass("Atmosphere")

				if atmosphere then
					pcall(function()
						atmosphere.Density = 0
					end)
				end
			end

			if setfpscap then
				if optimizations.fps_cap_enable then
					pcall(setfpscap, optimizations.fps_cap)
				else
					pcall(setfpscap, 1000)
				end
			end

			task.spawn(function()
				if optimizations.no_particles or optimizations.no_textures then
					local descendants = workspace:GetDescendants()

					for i = 1, #descendants do
						if optimizations.no_particles then
							fn7(descendants[i], true)
						end

						if optimizations.no_textures then
							fn8(descendants[i], true)
						end

						if i % 800 == 0 then
							task.wait()
						end
					end
				end

				if optimizations.no_postfx then
					for _, descendant in ipairs(v7:GetDescendants()) do
						fn9(descendant, true)
					end
				end
			end)
		end
	end

	do
		local tbl3 = {}
		local connection = nil
		local flag = false

		local function fn7(arg)
			if tbl3[arg] then
				return
			end
			tbl3[arg] = { Material = arg.Material, Color = arg.Color }
		end

		local function fn8(arg)
			local v8 = tbl3[arg]

			if v8 and arg.Parent then
				arg.Material = v8.Material
				arg.Color = v8.Color
			end

			tbl3[arg] = nil
		end

		local function fn9(arg)
			if not arg:IsA("BasePart") then
				return
			end

			if arg:FindFirstChildOfClass("Humanoid") then
				return
			end

			if arg:IsDescendantOf(localPlayer2.Character) then
				return
			end
			fn7(arg)
			local v8 = Enum.Material[phonk.map_textures.material]

			if v8 then
				arg.Material = v8
			end

			arg.Color = phonk.map_textures.color
		end

		local function fn10()
			if flag then
				return
			end
			flag = true

			task.spawn(function()
				local descendants = workspace:GetDescendants()

				for i = 1, #descendants do
					fn9(descendants[i])

					if i % 500 == 0 then
						task.wait()
					end
				end

				flag = false
			end)
		end

		local function fn11()
			for k in pairs(tbl3) do
				fn8(k)
			end
		end

		v2:Add(function()
			if connection then
				connection:Disconnect()
			end

			fn11()
		end)

		getgenv().phonk_update_textures = function()
			if phonk.map_textures.enable then
				fn10()

				if not connection then
					connection = workspace.DescendantAdded:Connect(function(descendant)
						if phonk.map_textures.enable then
							fn9(descendant)
						end
					end)
				end
			else
				if connection then
					connection:Disconnect()
					connection = nil
				end

				fn11()
			end
		end
	end

	do
		local tbl3 = {
			["Deep Space"] = {
				Bk = "http://www.roblox.com/asset/?id=159248188",
				Dn = "http://www.roblox.com/asset/?id=159248183",
				Ft = "http://www.roblox.com/asset/?id=159248187",
				Lf = "http://www.roblox.com/asset/?id=159248173",
				Rt = "http://www.roblox.com/asset/?id=159248192",
				Up = "http://www.roblox.com/asset/?id=159248176",
			},
			["Purple Nebula"] = {
				Bk = "http://www.roblox.com/asset/?id=159454299",
				Dn = "http://www.roblox.com/asset/?id=159454296",
				Ft = "http://www.roblox.com/asset/?id=159454293",
				Lf = "http://www.roblox.com/asset/?id=159454286",
				Rt = "http://www.roblox.com/asset/?id=159454300",
				Up = "http://www.roblox.com/asset/?id=159454288",
			},
			Vaporwave = {
				Bk = "http://www.roblox.com/asset/?id=1417494030",
				Dn = "http://www.roblox.com/asset/?id=1417494146",
				Ft = "http://www.roblox.com/asset/?id=1417494030",
				Lf = "http://www.roblox.com/asset/?id=1417494030",
				Rt = "http://www.roblox.com/asset/?id=1417494030",
				Up = "http://www.roblox.com/asset/?id=1417494643",
			},
			Night = {
				Bk = "rbxassetid://48020371",
				Dn = "rbxassetid://48020144",
				Ft = "rbxassetid://48020234",
				Lf = "rbxassetid://48020211",
				Rt = "rbxassetid://48020254",
				Up = "rbxassetid://48020383",
			},
			Space = {
				Bk = "rbxassetid://149397692",
				Dn = "rbxassetid://149397686",
				Ft = "rbxassetid://149397697",
				Lf = "rbxassetid://149397684",
				Rt = "rbxassetid://149397688",
				Up = "rbxassetid://149397702",
			},
			Minecraft = {
				Bk = "rbxassetid://1876545003",
				Dn = "rbxassetid://1876544331",
				Ft = "rbxassetid://1876542941",
				Lf = "rbxassetid://1876543392",
				Rt = "rbxassetid://1876543764",
				Up = "rbxassetid://1876544642",
			},
			Sunset = {
				Bk = "rbxassetid://150939022",
				Dn = "rbxassetid://150939038",
				Ft = "rbxassetid://150939047",
				Lf = "rbxassetid://150939056",
				Rt = "rbxassetid://150939063",
				Up = "rbxassetid://150939082",
			},
			Default = {
				Bk = "rbxassetid://6444884337",
				Dn = "rbxassetid://6444884785",
				Ft = "rbxassetid://6444884337",
				Lf = "rbxassetid://6444884337",
				Rt = "rbxassetid://6444884337",
				Up = "rbxassetid://6412503613",
			},
		}

		local clone = nil

		pcall(function()
			local sky = v7:FindFirstChildOfClass("Sky")

			if sky then
				clone = sky:Clone()
			end
		end)

		getgenv().phonk_update_sky = function()
			for _, child in ipairs(v7:GetChildren()) do
				if child:IsA("Sky") then
					child:Destroy()
				end
			end

			local clone2

			if not phonk.world.skybox.enable then
				clone2 = nil

				if clone then
					clone2 = clone:Clone()
					clone2.Parent = v7
				end
			else
				local v8 = tbl3[phonk.world.skybox.selected]
				clone2 = nil

				if v8 then
					clone2 = Instance.new("Sky")
					clone2.SkyboxBk = v8.Bk
					clone2.SkyboxDn = v8.Dn
					clone2.SkyboxFt = v8.Ft
					clone2.SkyboxLf = v8.Lf
					clone2.SkyboxRt = v8.Rt
					clone2.SkyboxUp = v8.Up
					clone2.Parent = v7
				end
			end

			if clone2 then
				if phonk.world.skybox.remove_sun then
					clone2.SunTextureId = ""
				end

				if phonk.world.skybox.remove_moon then
					clone2.MoonTextureId = ""
				end

				if phonk.world.skybox.remove_stars then
					clone2.StarCount = 0
				end
			end
		end
	end

	local n = 0

	v2:Add(v5.Heartbeat:Connect(function(deltaTime)
		local sky = v7:FindFirstChildOfClass("Sky")

		if phonk.world.skybox.rotate and sky then
			n += deltaTime * phonk.world.skybox.rotate_speed * 0.5
			local n2

			if phonk.world.skybox.rotate_method == "Spin" then
				n2 = n * 20 % 360
			elseif phonk.world.skybox.rotate_method == "Wave" then
				n2 = math.sin(n) * 180
			else
				n2 = 0

				if phonk.world.skybox.rotate_method == "Alternate" then
					n2 = math.abs(n * 40 % 720 - 360) - 180
				end
			end

			local vector = Vector3.zero

			if phonk.world.skybox.rotate_direction == "Horizontal" then
				vector = Vector3.new(0, n2, 0)
			elseif phonk.world.skybox.rotate_direction == "Vertical" then
				vector = Vector3.new(n2, 0, 0)
			elseif phonk.world.skybox.rotate_direction == "Diagonal" then
				vector = Vector3.new(n2, n2, n2)
			end

			pcall(function()
				sky.SkyboxOrientation = vector
			end)
		end
	end))

	local tbl3
	tbl3 = {}

	do
		local snow = {}
		local numberSequence = NumberSequence.new
		local tbl4 = {}
		local v8 = NumberSequenceKeypoint.new(0, 0.7375)
		local v9 = NumberSequenceKeypoint.new(0.973, 0.76875)
		local new = NumberSequenceKeypoint.new
		tbl4[1] = v8
		tbl4[2] = v9

		do
			local values = table.pack(new(1, 1))
			table.move(values, 1, values.n, 3, tbl4)
		end

		snow.Transparency = numberSequence(tbl4)
		snow.Texture = "http://www.roblox.com/asset/?id=99851851"
		snow.SpreadAngle = Vector2.new(50, 50)
		snow.Speed = NumberRange.new(30, 30)
		snow.LightEmission = 10
		snow.Rate = 1000
		snow.EmissionDirection = Enum.NormalId.Bottom
		local numberSequence2 = NumberSequence.new
		local tbl5 = {}
		local v10 = NumberSequenceKeypoint.new(0, 0.331)
		local v11 = NumberSequenceKeypoint.new(0.551, 0.402)
		local new2 = NumberSequenceKeypoint.new
		tbl5[1] = v10
		tbl5[2] = v11

		do
			local values = table.pack(new2(1, 0.331))
			table.move(values, 1, values.n, 3, tbl5)
		end

		snow.Size = numberSequence2(tbl5)
		tbl3.snow = snow
	end

	do
		local rain = {
			Speed = NumberRange.new(60, 60),
			LockedToPart = true,
			Rate = 600,
			Texture = "rbxassetid://1822883048",
			EmissionDirection = Enum.NormalId.Bottom,
		}

		local numberSequence = NumberSequence.new
		local tbl4 = {}
		local v8 = NumberSequenceKeypoint.new(0, 1)
		local v9 = NumberSequenceKeypoint.new(0.25, 0.784)
		local v10 = NumberSequenceKeypoint.new(0.75, 0.784)
		local new = NumberSequenceKeypoint.new
		tbl4[1] = v8
		tbl4[2] = v9
		tbl4[3] = v10

		do
			local values = table.pack(new(1, 1))
			table.move(values, 1, values.n, 4, tbl4)
		end

		rain.Transparency = numberSequence(tbl4)
		rain.Lifetime = NumberRange.new(0.8, 0.8)
		rain.LightEmission = 0.05
		rain.LightInfluence = 0.9
		rain.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
		local new2 = NumberSequenceKeypoint.new
		rain.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 10), new2(1, 10) })
		tbl3.rain = rain
	end

	do
		local new = NumberSequenceKeypoint.new

		local tbl4 = {
			LockedToPart = true,
			Rate = 500,
			Squash = NumberSequence.new({ NumberSequenceKeypoint.new(0, 3), new(1, 3) }),
			LightInfluence = 0.3,
		}

		local numberSequence = NumberSequence.new
		local tbl5 = {}
		local v8 = NumberSequenceKeypoint.new(0, 0)
		local v9 = NumberSequenceKeypoint.new(0.435, 0)
		local new2 = NumberSequenceKeypoint.new
		tbl5[1] = v8
		tbl5[2] = v9

		do
			local values = table.pack(new2(1, 0))
			table.move(values, 1, values.n, 3, tbl5)
		end

		tbl4.Transparency = numberSequence(tbl5)
		tbl4.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		tbl4.Speed = NumberRange.new(30, 50)
		tbl4.Lifetime = NumberRange.new(9, 9)
		tbl4.LightEmission = 0.5
		tbl4.Brightness = 2
		tbl4.EmissionDirection = Enum.NormalId.Bottom
		tbl4.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp
		local new3 = NumberSequenceKeypoint.new
		tbl4.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), new3(1, 0.2) })
		tbl3["light rain"] = tbl4
	end

	do
		local tbl4 = {}
		local type_ = phonk.world.weather and phonk.world.weather.type or "snow"

		if not tbl3[type_] then
			type_ = "snow"
		end

		local part = Instance.new("Part")
		part.Size = Vector3.new(40, 40, 85)
		part.CanCollide = false
		part.Massless = true
		part.Transparency = 1
		part.Anchored = true
		part.Name = "PhonkWareWeather"
		part.Parent = workspace
		local particleEmitter = Instance.new("ParticleEmitter")

		for k, v8 in pairs(tbl3[type_]) do
			pcall(function()
				particleEmitter[k] = v8
			end)
		end

		particleEmitter.Color = ColorSequence.new(phonk.world.weather and phonk.world.weather.color or Color3.new(1, 1, 1))
		particleEmitter.Enabled = false
		particleEmitter.Parent = part
		tbl4.part = part
		tbl4.emitter = particleEmitter
		tbl4.last_type = type_
		v2:Add(part)

		local function fn7()
			if tbl4.emitter then
				pcall(function()
					tbl4.emitter:Destroy()
				end)
			end

			local type_2 = phonk.world.weather and phonk.world.weather.type or "snow"

			if not tbl3[type_2] then
				type_2 = "snow"
			end

			local particleEmitter2 = Instance.new("ParticleEmitter")

			for k, v8 in pairs(tbl3[type_2]) do
				pcall(function()
					particleEmitter2[k] = v8
				end)
			end

			particleEmitter2.Color = ColorSequence.new(phonk.world.weather and phonk.world.weather.color or Color3.new(1, 1, 1))
			particleEmitter2.Enabled = true
			particleEmitter2.Parent = tbl4.part
			tbl4.emitter = particleEmitter2
			tbl4.last_type = type_2
		end

		getgenv().phonk_update_weather = function()
			if not phonk.world.weather or not phonk.world.weather.enable then
				if tbl4.emitter then
					tbl4.emitter.Enabled = false
				end

				return
			end

			if tbl4.last_type ~= phonk.world.weather.type then
				fn7()
			end

			if tbl4.emitter then
				tbl4.emitter.Enabled = true
				tbl4.emitter.Rate = phonk.world.weather.rate or 100
				tbl4.emitter.Color = ColorSequence.new(phonk.world.weather.color or Color3.new(1, 1, 1))
			end
		end

		v2:Add(v5.RenderStepped:Connect(function()
			if not phonk.world.weather or not phonk.world.weather.enable then
				if tbl4.emitter then
					tbl4.emitter.Enabled = false
				end

				return
			end

			if tbl4.last_type ~= phonk.world.weather.type then
				fn7()
			end

			tbl4.emitter.Enabled = true
			tbl4.emitter.Rate = phonk.world.weather.rate or 100
			tbl4.emitter.Color = ColorSequence.new(phonk.world.weather.color or Color3.new(1, 1, 1))

			if tbl4.part and currentCamera then
				tbl4.part.CFrame = CFrame.new(currentCamera.CFrame.Position + Vector3.new(0, 20, 0))
			end
		end))
	end

	do
		local function fn7(arg, displayName)
			if not arg or not displayName or displayName == "" then
				return
			end

			pcall(function()
				arg.DisplayName = displayName
			end)

			pcall(function()
				local character = arg.Character

				if character then
					local humanoid = character:FindFirstChildOfClass("Humanoid")

					if humanoid then
						humanoid.DisplayName = displayName
					end
				end
			end)
		end

		local function fn8()
			pcall(function()
				if phonk.spoof.level.enable then
					localPlayer2:SetAttribute("Level", phonk.spoof.level.value)
				end

				if phonk.spoof.streak.enable then
					localPlayer2:SetAttribute("StatisticDuelsWinStreak", phonk.spoof.streak.value)
				end
			end)
		end

		local function fn9()
			if phonk.profile.spoof_local and phonk.profile.spoof_local_name ~= "" then
				fn7(localPlayer2, phonk.profile.spoof_local_name)
			end

			if phonk.profile.spoof_other and phonk.profile.spoof_other_name ~= "" then
				for _, player in ipairs(v4:GetPlayers()) do
					if player ~= localPlayer2 then
						fn7(player, phonk.profile.spoof_other_name)
					end
				end
			end
		end

		v2:Add(v5.Heartbeat:Connect(function()
			fn8()
			fn9()
		end))

		v2:Add(v4.PlayerAdded:Connect(function(player)
			task.wait(0.5)

			if phonk.profile.spoof_other and phonk.profile.spoof_other_name ~= "" and player ~= localPlayer2 then
				fn7(player, phonk.profile.spoof_other_name)
			end
		end))

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			task.wait(0.3)
			fn9()
			fn8()
		end))
	end

	v2:Add(v5.Heartbeat:Connect(function()
		if phonk.infinite_double_jump.enable then
			pcall(function()
				MechanicsController._double_jumps_used = {}
			end)
		end

		if phonk.viewmodel_offsets.enable then
			for k, v8 in next, ItemLibrary.ViewModels, nil do
				if oldoffsets[k] then
					v8.RootPartOffset = CFrame.new(oldoffsets[k].X + phonk.viewmodel_offsets.x, oldoffsets[k].Y + phonk.viewmodel_offsets.y, oldoffsets[k].Z + phonk.viewmodel_offsets.z)
				end
			end
		end
	end))

	do
		local walkSpeed = 16
		local flag = false

		local function fn7(arg)
			if not phonk.walkspeed.enable then
				return
			end
			flag = true
			arg.WalkSpeed = walkSpeed * phonk.walkspeed.multiplier
			flag = false
		end

		local function fn8(arg)
			walkSpeed = arg.WalkSpeed

			v2:Add(arg:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				if flag then
					return
				end
				walkSpeed = arg.WalkSpeed
				fn7(arg)
			end))

			fn7(arg)
		end

		local function fn9(character)
			local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)

			if humanoid then
				fn8(humanoid)
			end
		end

		if localPlayer2.Character then
			fn9(localPlayer2.Character)
		end

		v2:Add(localPlayer2.CharacterAdded:Connect(fn9))
		local flag2 = false

		v2:Add(v5.Heartbeat:Connect(function()
			local character = localPlayer2.Character
			character = character and character:FindFirstChildOfClass("Humanoid")
			if not character then
				return
			end

			if phonk.walkspeed.enable then
				flag2 = true
				local walkSpeed2 = walkSpeed * phonk.walkspeed.multiplier

				if math.abs(character.WalkSpeed - walkSpeed2) > 0.05 then
					flag = true
					character.WalkSpeed = walkSpeed2
					flag = false
				end
			elseif flag2 then
				flag2 = false
				flag = true
				character.WalkSpeed = walkSpeed
				flag = false
			end
		end))
	end

	v2:Add(v5.RenderStepped:Connect(function()
		if phonk.slide_boost.enable and MechanicsController.IsSliding then
			pcall(function()
				MechanicsController._sliding_velocity.Velocity = MechanicsController._sliding_velocity.Velocity.Unit * phonk.slide_boost.speed
			end)
		end
	end))

	do
		local flag = false
		local bodyVelocity = nil
		local bodyGyro = nil

		local function fn7()
			flag = false

			if bodyVelocity then
				pcall(function()
					bodyVelocity:Destroy()
				end)

				bodyVelocity = nil
			end

			if bodyGyro then
				pcall(function()
					bodyGyro:Destroy()
				end)

				bodyGyro = nil
			end

			local character = localPlayer2.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				pcall(function()
					humanoid.PlatformStand = false
				end)
			end

			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				pcall(function()
					humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
				end)
			end
		end

		local function fn8(arg)
			local v8 = options[arg]
			if not v8 then
				return false
			end

			if type(v8.GetState) == "function" then
				local ok, result = pcall(function()
					return v8:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if v8.Mode == "Hold" and v8.Value and v8.Value ~= "None" then
				local ok, result = pcall(function()
					return v6:IsKeyDown(Enum.KeyCode[v8.Value])
				end)

				return ok and result == true
			end

			if v8.Mode == "Always" then
				return true
			end

			if v8.Mode == "Toggle" then
				return v8.Toggled == true
			end
			return false
		end

		local function fn9()
			if not phonk.fly.enable then
				return false
			end
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			if phonkMobileBtns and phonkMobileBtns.fly then
				return true
			end
			return fn8("fly_key")
		end

		v2:Add(v5.Heartbeat:Connect(function()
			local v8 = fn9()
			local character = localPlayer2.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if v8 and humanoidRootPart and humanoid then
				if not flag or not bodyVelocity or not bodyVelocity.Parent or not bodyGyro or not bodyGyro.Parent then
					fn7()
					flag = true
					bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Name = "PhonkWareFlyBV"
					bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
					bodyVelocity.Velocity = Vector3.zero
					bodyVelocity.Parent = humanoidRootPart
					bodyGyro = Instance.new("BodyGyro")
					bodyGyro.Name = "PhonkWareFlyBG"
					bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
					bodyGyro.P = 10000
					bodyGyro.Parent = humanoidRootPart

					pcall(function()
						humanoid.PlatformStand = true
					end)
				end

				local phonkMobileBtns = getgenv().phonk_mobile_btns
				phonkMobileBtns = phonkMobileBtns and phonkMobileBtns.fly
				local vector = Vector3.zero

				if v6:IsKeyDown(Enum.KeyCode.W) then
					vector = Vector3.zero + currentCamera.CFrame.LookVector
				end

				if v6:IsKeyDown(Enum.KeyCode.S) then
					vector -= currentCamera.CFrame.LookVector
				end

				if v6:IsKeyDown(Enum.KeyCode.A) then
					vector -= currentCamera.CFrame.RightVector
				end

				if v6:IsKeyDown(Enum.KeyCode.D) then
					vector += currentCamera.CFrame.RightVector
				end

				if v6:IsKeyDown(Enum.KeyCode.Space) then
					vector += Vector3.new(0, 1, 0)
				end

				if v6:IsKeyDown(Enum.KeyCode.LeftControl) or v6:IsKeyDown(Enum.KeyCode.LeftShift) then
					vector -= Vector3.new(0, 1, 0)
				end

				if phonkMobileBtns and vector.Magnitude < 0.05 then
					vector = humanoid.MoveDirection

					if not (vector.Magnitude > 0.05) then
						vector = Vector3.zero
					end
				end

				if vector.Magnitude > 0 then
					vector = vector.Unit * (phonk.fly.speed or 50)
				end

				if bodyVelocity and bodyVelocity.Parent then
					bodyVelocity.Velocity = vector
				end

				if bodyGyro and bodyGyro.Parent then
					pcall(function()
						bodyGyro.CFrame = currentCamera.CFrame
					end)
				end

				if bodyGyro and bodyGyro.Parent then
					bodyGyro.CFrame = currentCamera.CFrame
				end
			elseif flag then
				fn7()
			end
		end))

		v2:Add(v5.Heartbeat:Connect(function()
			if not phonk.fly.enable and flag then
				fn7()
			end
		end))

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			fn7()
		end))

		v2:Add(fn7)
	end

	do
		local flag = false
		local custom = Enum.CameraType.Custom
		local cameraSubject = nil
		local cFrame = nil
		local n2 = 0
		local n3 = 0

		local function fn7(arg)
			local v8 = options[arg]
			if not v8 then
				return false
			end

			if type(v8.GetState) == "function" then
				local ok, result = pcall(function()
					return v8:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if v8.Mode == "Always" then
				return true
			end

			if v8.Mode == "Toggle" then
				return v8.Toggled == true
			end

			if v8.Mode == "Hold" and v8.Value and v8.Value ~= "None" then
				local ok, result = pcall(function()
					return v6:IsKeyDown(Enum.KeyCode[v8.Value])
				end)

				return ok and result == true
			end

			return false
		end

		local function fn8(arg)
			local y = arg.LookVector.Y
			return math.atan2(-arg.LookVector.X, -arg.LookVector.Z), (math.asin(math.clamp(y, -1, 1)))
		end

		local function fn9()
			if not flag then
				return
			end
			flag = false
			cFrame = nil

			pcall(function()
				v6.MouseBehavior = Enum.MouseBehavior.Default
				currentCamera.CameraType = custom or Enum.CameraType.Custom
				local character = localPlayer2.Character
				character = character and character:FindFirstChildOfClass("Humanoid")

				if character then
					currentCamera.CameraSubject = character
				elseif cameraSubject then
					currentCamera.CameraSubject = cameraSubject
				end
			end)
		end

		local function fn10()
			if flag then
				return
			end
			flag = true
			custom = currentCamera.CameraType
			cameraSubject = currentCamera.CameraSubject
			cFrame = currentCamera.CFrame
			local v8, v9 = fn8(cFrame)
			n2 = v8
			n3 = v9

			pcall(function()
				currentCamera.CameraType = Enum.CameraType.Scriptable
				currentCamera.CameraSubject = nil
				v6.MouseBehavior = Enum.MouseBehavior.LockCenter
			end)
		end

		v2:Add(v5.RenderStepped:Connect(function(deltaTime)
			local phonkMobileBtns = getgenv().phonk_mobile_btns

			if not (phonk.freecam.enable and (phonkMobileBtns and phonkMobileBtns.freecam or fn7("freecam_key"))) then
				if flag then
					fn9()
				end

				return
			end

			if not flag then
				fn10()
			end

			deltaTime = deltaTime or 0.016

			pcall(function()
				currentCamera.CameraType = Enum.CameraType.Scriptable
				currentCamera.CameraSubject = nil
			end)

			if not cFrame then
				cFrame = currentCamera.CFrame
				local v8, v9 = fn8(cFrame)
				n2 = v8
				n3 = v9
			end

			local mouseDelta = v6:GetMouseDelta()
			n2 -= math.rad(mouseDelta.X * 0.35)
			n3 = math.clamp(n3 - math.rad(mouseDelta.Y * 0.35), -1.5533430342749532, 1.5533430342749532)
			local n4 = CFrame.Angles(0, n2, 0) * CFrame.Angles(n3, 0, 0)
			local position = cFrame.Position
			local n5 = (phonk.freecam.speed or 50) * 0.15 * deltaTime * 60
			local lookVector = n4.LookVector
			local rightVector = n4.RightVector
			local vector = Vector3.zero

			if v6:IsKeyDown(Enum.KeyCode.W) then
				vector = Vector3.zero + lookVector
			end

			if v6:IsKeyDown(Enum.KeyCode.S) then
				vector -= lookVector
			end

			if v6:IsKeyDown(Enum.KeyCode.A) then
				vector -= rightVector
			end

			if v6:IsKeyDown(Enum.KeyCode.D) then
				vector += rightVector
			end

			if v6:IsKeyDown(Enum.KeyCode.Space) then
				vector += Vector3.new(0, 1, 0)
			end

			if v6:IsKeyDown(Enum.KeyCode.LeftControl) or v6:IsKeyDown(Enum.KeyCode.LeftShift) then
				vector -= Vector3.new(0, 1, 0)
			end

			if vector.Magnitude > 0 then
				position += vector.Unit * n5
			end

			cFrame = CFrame.new(position) * n4
			currentCamera.CFrame = cFrame
		end))

		pcall(function()
			v5:BindToRenderStep("PhonkWare_Freecam", Enum.RenderPriority.Camera.Value + 1, function()
				if flag and cFrame then
					pcall(function()
						currentCamera.CameraType = Enum.CameraType.Scriptable
						currentCamera.CameraSubject = nil
						currentCamera.CFrame = cFrame
					end)
				end
			end)
		end)

		v2:Add(localPlayer2.CharacterAdded:Connect(function()
			fn9()
		end))

		v2:Add(function()
			fn9()

			pcall(function()
				v5:UnbindFromRenderStep("PhonkWare_Freecam")
			end)
		end)
	end

	do
		local tbl4 = {
			"arm",
			"hand",
			"sleeve",
			"elbow",
			"wrist",
			"shoulder",
			"finger",
			"thumb",
			"glove",
			"leftarm",
			"rightarm",
		}

		local tbl5 = {}

		local function fn7(arg)
			local v8 = string.lower(arg.Name)

			for i = 1, #tbl4 do
				if string.find(v8, tbl4[i], 1, true) then
					return true
				end
			end

			return false
		end

		local function fn8()
			local firstPerson = workspace:FindFirstChild("ViewModels") and workspace.ViewModels:FindFirstChild("FirstPerson")
			if not firstPerson then
				return
			end

			for _, descendant in ipairs(firstPerson:GetDescendants()) do
				if descendant:IsA("BasePart") then
					if fn7(descendant) then
						if not tbl5[descendant] then
							tbl5[descendant] = { t = descendant.Transparency, ltm = descendant.LocalTransparencyModifier }
						end

						if phonk.no_arm.enable then
							descendant.Transparency = 1
							descendant.LocalTransparencyModifier = 1
						else
							local v8 = tbl5[descendant]

							if v8 then
								descendant.Transparency = v8.t
								descendant.LocalTransparencyModifier = v8.ltm
								tbl5[descendant] = nil
							end
						end
					end
				elseif descendant:IsA("Decal") or descendant:IsA("Texture") then
					if fn7(descendant.Parent) then
						if phonk.no_arm.enable then
							descendant.Transparency = 1
						end
					end
				end
			end
		end

		v2:Add(v5.RenderStepped:Connect(function()
			fn8()
		end))

		v2:Add(function()
			for k, v8 in pairs(tbl5) do
				if k and k.Parent then
					pcall(function()
						k.Transparency = v8.t
						k.LocalTransparencyModifier = v8.ltm
					end)
				end
			end
		end)
	end

	do
		local function fn7(arg)
			if not arg or arg == localPlayer2 then
				return false
			end
			local character = arg.Character
			if not character then
				return false
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
				return false
			end

			if phonk.tp_player.team_check then
				local ok, result = pcall(function()
					return arg:GetAttribute("TeamID") == localPlayer2:GetAttribute("TeamID")
				end)

				if ok and result then
					return false
				end
			end

			return true
		end

		local function fn8()
			local method = phonk.tp_player.method or "closest"
			local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
			local vector2 = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
			local huge = math.huge
			local v8 = nil

			for _, player in ipairs(v4:GetPlayers()) do
				if fn7(player) then
					local humanoidRootPart2 = player.Character:FindFirstChild("HumanoidRootPart")

					if method == "crosshair" then
						local v9, v10 = currentCamera:WorldToViewportPoint(humanoidRootPart2.Position)

						if v10 and v9.Z > 0 then
							local magnitude = (Vector2.new(v9.X, v9.Y) - vector2).Magnitude

							if magnitude < huge then
								huge = magnitude
								v8 = player
							end
						end
					elseif humanoidRootPart then
						local magnitude = (humanoidRootPart2.Position - humanoidRootPart.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v8 = player
						end
					end
				end
			end

			return v8
		end

		local function fn9(arg)
			if not arg or not arg.Character then
				return false
			end
			local humanoidRootPart = arg.Character:FindFirstChild("HumanoidRootPart")
			local humanoidRootPart2 = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart or not humanoidRootPart2 then
				return false
			end
			local yOffset = phonk.tp_player.y_offset or 0

			if options and options.tp_y_offset and options.tp_y_offset.Value ~= nil then
				local yOffset2 = options.tp_y_offset.Value
				phonk.tp_player.y_offset = yOffset2
				yOffset = yOffset2
			end

			local n2 = tonumber(yOffset) or 0
			local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
			local lookVector = humanoidRootPart2.CFrame.LookVector
			local vector

			if phonk.tp_player.prediction then
				local magnitude = assemblyLinearVelocity.Magnitude
				local n3 = 0

				if magnitude > 0.5 then
					n3 = math.clamp(0.06 + magnitude * 0.004, 0.05, 0.28)
				end

				local n4 = humanoidRootPart.Position + assemblyLinearVelocity * n3
				vector = Vector3.new(n4.X, n4.Y + n2, n4.Z)
				local vector2 = Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z)

				if vector2.Magnitude > 1 then
					lookVector = vector2.Unit
				end
			else
				local position = humanoidRootPart.Position
				vector = Vector3.new(position.X, position.Y + n2, position.Z)
			end

			pcall(function()
				if phonk.tp_player.prediction then
					humanoidRootPart2.AssemblyLinearVelocity = assemblyLinearVelocity
				else
					humanoidRootPart2.AssemblyLinearVelocity = Vector3.zero
				end

				humanoidRootPart2.AssemblyAngularVelocity = Vector3.zero
				humanoidRootPart2.CFrame = CFrame.new(vector, vector + lookVector)
				humanoidRootPart2.Position = vector
			end)

			pcall(function()
				local character = localPlayer2.Character

				if character and character.PivotTo then
					character:PivotTo(CFrame.new(vector, vector + lookVector))
				end
			end)

			return true
		end

		getgenv().phonk_tp_to_player = function(arg)
			if arg and arg ~= "" then
				for _, player in ipairs(v4:GetPlayers()) do
					if (player.Name == arg or player.DisplayName == arg) and fn7(player) then
						return fn9(player)
					end
				end

				return false
			end

			local v8 = fn8()
			if not v8 then
				return false
			end
			return fn9(v8)
		end
	end

	local flag = false

	v2:Add(v5.Heartbeat:Connect(function()
		local tpKey = options.tp_key
		local phonkMobileBtns = getgenv().phonk_mobile_btns
		local flag2

		if phonkMobileBtns and phonkMobileBtns.tp then
			flag2 = true
		else
			local getState = tpKey and tpKey.GetState
			flag2 = false

			if getState then
				local ok, result = pcall(function()
					return tpKey:GetState()
				end)

				flag2 = ok and result == true
			end
		end

		local phonkUnderground = getgenv().phonk_underground

		if flag2 then
			if phonkUnderground and phonkUnderground.active then
				phonkUnderground.tp_override = true
			end

			getgenv().phonk_tp_to_player()
		elseif flag and not flag2 then
			if phonkUnderground and phonkUnderground.active and phonkUnderground.saved_pos then
				phonkUnderground.tp_override = false
				local value

				if options and options.ug_depth and type(options.ug_depth.Value) == "number" then
					value = options.ug_depth.Value
				else
					local depth = phonk.underground and phonk.underground.depth
					value = 5.8

					if depth then
						value = phonk.underground.depth
					end
				end

				local humanoidRootPart = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					local n2 = phonkUnderground.saved_pos.Y - value

					pcall(function()
						humanoidRootPart.CFrame = CFrame.new(phonkUnderground.saved_pos.X, n2, phonkUnderground.saved_pos.Z)
						humanoidRootPart.AssemblyLinearVelocity = Vector3.zero
					end)
				end
			end
		end

		flag = flag2
	end))

	do
		local tbl4 = {
			active = false,
			stored_pos = nil,
			sky_base = nil,
			yaw_locked = false,
			locked_look = nil,
			weapon_cache = {},
			mode = "none",
			fc_active = false,
			fc_cf = nil,
		}

		local function fn7(arg)
			local v8 = options[arg]
			if not v8 then
				return false
			end

			if type(v8.GetState) == "function" then
				local ok, result = pcall(function()
					return v8:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if v8.Mode == "Always" then
				return true
			end

			if v8.Mode == "Toggle" then
				return v8.Toggled == true
			end
			return false
		end

		local function fn8()
			local phonkMobileBtns = getgenv().phonk_mobile_btns

			if phonkMobileBtns and phonkMobileBtns.eu then
				if not phonk.eu_counter.enable then
					phonk.eu_counter.enable = true
				end

				return true
			end

			if not (phonk.eu_counter and phonk.eu_counter.enable) then
				return false
			end

			if not options.eu_counter_key then
				return false
			end
			return fn7("eu_counter_key") == true
		end

		local function fn9()
			local character = localPlayer2.Character
			return character and character:FindFirstChild("HumanoidRootPart")
		end

		local function fn10(arg, arg2, arg3)
			local v8 = fn9()
			if not v8 then
				return
			end

			pcall(function()
				v8.CFrame = CFrame.new(arg, arg2, arg3)
				v8.AssemblyLinearVelocity = Vector3.zero
				v8.AssemblyAngularVelocity = Vector3.zero
			end)
		end

		local function fn11()
			local viewModels = workspace:FindFirstChild("ViewModels")
			if not viewModels then
				return
			end
			local weaponCache = {}

			for _, child in ipairs(viewModels:GetChildren()) do
				local v8, v9 = string.match(child.Name, "^(.-) %- (.-) %-")

				if v8 and v9 then
					weaponCache[v8] = v9
				end
			end

			tbl4.weapon_cache = weaponCache
		end

		local function fn12(arg)
			if not arg then
				return nil
			end
			local v8 = tbl4.weapon_cache[arg.Name] or tbl4.weapon_cache[arg.DisplayName]
			if v8 then
				return v8
			end

			if arg.Character then
				for _, child in ipairs(arg.Character:GetChildren()) do
					if child:IsA("Tool") then
						return child.Name
					end
				end
			end

			return nil
		end

		local function fn13(arg)
			if not arg then
				return false
			end
			return string.lower(tostring(arg)) == "knife"
		end

		local function fn14(arg)
			if not arg or arg == localPlayer2 then
				return false
			end
			local character = arg.Character
			if not character then
				return false
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if not humanoid or humanoid.Health <= 0 then
				return false
			end

			local ok, result = pcall(function()
				return arg:GetAttribute("TeamID") == localPlayer2:GetAttribute("TeamID")
			end)

			if ok and result then
				return false
			end
			return true
		end

		local function fn15()
			local v8 = fn9()
			if not v8 then
				return nil
			end
			local huge = math.huge
			local v9 = nil

			for _, player in ipairs(v4:GetPlayers()) do
				if fn14(player) then
					local humanoidRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						local magnitude = (humanoidRootPart.Position - v8.Position).Magnitude

						if magnitude < huge then
							huge = magnitude
							v9 = player
						end
					end
				end
			end

			return v9
		end

		local function fn16()
			if options and options.ug_depth and type(options.ug_depth.Value) == "number" then
				return options.ug_depth.Value
			end
			return phonk.underground and phonk.underground.depth or 5.8
		end

		local function fn17()
			local v8 = fn9()
			if not v8 then
				return
			end

			if not tbl4.stored_pos then
				tbl4.stored_pos = v8.Position
			end

			local storedPos = tbl4.stored_pos
			fn10(storedPos.X, storedPos.Y - fn16(), storedPos.Z)
			tbl4.mode = "underground"
		end

		local function fn18()
			-- VOIDSPAM: rapid-fire extreme-distance teleport spam
			local v8 = fn9()
			if not v8 then
				return
			end

			if not tbl4.stored_pos then
				tbl4.stored_pos = v8.Position
			end

			local storedPos = tbl4.stored_pos

			-- Void distances: 50k-150k studs in random directions each spam tick
			local dirs = {
				Vector3.new(1, 0.5, 0),
				Vector3.new(-1, 0.5, 0),
				Vector3.new(0, 0.5, 1),
				Vector3.new(0, 0.5, -1),
				Vector3.new(1, 1, 1),
				Vector3.new(-1, 1, -1),
			}
			local dir = dirs[math.random(1, #dirs)].Unit
			local voidDist = 50000 + math.random() * 100000

			local voidTarget = Vector3.new(
				storedPos.X + dir.X * voidDist,
				storedPos.Y + math.abs(dir.Y) * (voidDist * 0.4 + math.random() * 8000),
				storedPos.Z + dir.Z * voidDist
			)

			-- Spam multiple tps per call for true voidspam effect
			for _ = 1, 3 do
				pcall(function()
					fn10(voidTarget.X + (math.random() - 0.5) * 200, voidTarget.Y, voidTarget.Z + (math.random() - 0.5) * 200)
				end)
				task.wait()
			end

			fn10(voidTarget.X, voidTarget.Y, voidTarget.Z)
			tbl4.mode = "sky"
		end

		local function fn19()
			if tbl4.yaw_locked then
				return
			end
			tbl4.yaw_locked = true

			pcall(function()
				local position = currentCamera.CFrame.Position
				tbl4.locked_look = CFrame.lookAt(position, position + Vector3.new(0, 1, 0))

				if CameraController and CameraController.MimicRotation then
					CameraController:MimicRotation(tbl4.locked_look)
				end

				currentCamera.CFrame = tbl4.locked_look
			end)
		end

		local function fn20()
			if tbl4.fc_active then
				return
			end
			tbl4.fc_active = true
			tbl4.fc_cf = currentCamera.CFrame

			pcall(function()
				currentCamera.CameraType = Enum.CameraType.Scriptable
				currentCamera.CameraSubject = nil
			end)
		end

		local function fn21()
			if not tbl4.fc_active then
				return
			end
			tbl4.fc_active = false
			tbl4.fc_cf = nil

			pcall(function()
				currentCamera.CameraType = Enum.CameraType.Custom
				local character = localPlayer2.Character
				character = character and character:FindFirstChildOfClass("Humanoid")

				if character then
					currentCamera.CameraSubject = character
				end
			end)
		end

		local function fn22()
			tbl4.active = false
			tbl4.mode = "none"
			tbl4.yaw_locked = false
			tbl4.locked_look = nil
			tbl4.sky_base = nil
			fn21()

			if tbl4.stored_pos then
				local storedPos = tbl4.stored_pos
				fn10(storedPos.X, storedPos.Y, storedPos.Z)
			end

			tbl4.stored_pos = nil
		end

		local screenGui = nil
		local frame = nil

		pcall(function()
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "PhonkWareEUCounter"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 50

			if gethui then
				screenGui.Parent = gethui()
			else
				screenGui.Parent = game:GetService("CoreGui")
			end

			local phonkUiScale = getgenv().phonk_ui_scale or 1
			local uiScale = Instance.new("UIScale")
			uiScale.Name = "PhonkUIScale"
			uiScale.Scale = phonkUiScale
			uiScale.Parent = screenGui
			frame = Instance.new("Frame")
			frame.AnchorPoint = Vector2.new(0.5, 0)
			frame.Position = UDim2.new(0.5, 0, 0, 72)
			frame.Size = UDim2.new(0, 0, 0, 40)
			frame.BackgroundTransparency = 1
			frame.Parent = screenGui
			v2:Add(screenGui)
		end)

		local str = "PHONKWARE UE COUNTER"
		local tbl5 = {}
		local textSize = 32
		local n2 = 20

		local function fn23()
			if not frame then
				return
			end

			if #tbl5 > 0 then
				return
			end
			local n3 = #str * n2
			frame.AnchorPoint = Vector2.new(0.5, 0)
			frame.Position = UDim2.new(0.5, 0, 0, 68)
			frame.Size = UDim2.new(0, n3, 0, textSize + 16)

			for i = 1, #str do
				local text = ("PHONKWARE UE COUNTER"):sub(i, i)
				local textLabel = Instance.new("TextLabel")
				textLabel.BackgroundTransparency = 1
				textLabel.Size = UDim2.new(0, 20, 1, 0)
				textLabel.Position = UDim2.new(0, (i - 1) * n2, 0, 0)
				textLabel.Font = Enum.Font.GothamBold
				textLabel.TextSize = textSize
				textLabel.Text = text
				textLabel.TextXAlignment = Enum.TextXAlignment.Center
				textLabel.TextYAlignment = Enum.TextYAlignment.Center
				textLabel.TextColor3 = library.AccentColor or Color3.fromRGB(196, 30, 58)
				textLabel.TextStrokeTransparency = 0.5
				textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
				textLabel.Parent = frame
				tbl5[i] = textLabel
			end
		end

		v2:Add(v5.RenderStepped:Connect(function()
			local v8 = fn8()

			if frame then
				frame.Visible = v8
			end

			if not v8 then
				return
			end
			fn23()
			local now2 = os.clock()
			local accentColor = library.AccentColor or Color3.fromRGB(196, 30, 58)

			for i, v9 in ipairs(tbl5) do
				v9.Position = UDim2.new(0, (i - 1) * n2, 0, math.sin(now2 * 4 + i * 0.4) * 8)
				v9.TextColor3 = accentColor
			end

			if tbl4.yaw_locked and tbl4.locked_look then
				pcall(function()
					local position = currentCamera.CFrame.Position
					local cframe = CFrame.lookAt(position, position + Vector3.new(0, 1, 0))
					tbl4.locked_look = cframe

					if CameraController and CameraController.MimicRotation then
						CameraController:MimicRotation(cframe)
					end
				end)
			end

			if tbl4.fc_active and tbl4.fc_cf then
				pcall(function()
					currentCamera.CameraType = Enum.CameraType.Scriptable
					currentCamera.CFrame = tbl4.fc_cf
				end)
			end
		end))

		v2:Add(v5.Heartbeat:Connect(function()
			if not fn8() then
				if tbl4.active then
					fn22()
				end

				return
			end

			if not tbl4.active then
				tbl4.active = true
				local v8 = fn9()

				if v8 then
					tbl4.stored_pos = v8.Position
				end

				fn19()
				fn20()

				if tbl4.fc_cf == nil then
					tbl4.fc_cf = currentCamera.CFrame
				end

				pcall(function()
					tbl4.fc_cf = tbl4.fc_cf * CFrame.new(0, 0.5, 0)
				end)
			end

			fn11()
			local v8 = fn15()
			if not v8 then
				fn17()
				return
			end
			local v9 = fn12(v8)

			if fn13(v9) then
				fn18()
			else
				fn17()
			end
		end))
	end

	do
		local tbl4 = {
			Meditate = "96579993895076",
			Orbit = "133811691098518",
			Floss = "72174079036035",
			OJ = "110064349530772",
			["Kicking Feet"] = "131879764029003",
			["Take the L"] = "112884830175040",
			Hype = "80055417516516",
		}

		phonk.animation = phonk.animation or { enable = false, select_animation = "Meditate", speed = 2, custom_id = "" }

		if not phonk.animation.select_animation or phonk.animation.select_animation == "" then
			phonk.animation.select_animation = "Meditate"
		end

		local v8 = nil
		local str = ""
		local n2 = 0

		local function fn7()
			if v8 then
				pcall(function()
					v8:Stop()
				end)

				v8 = nil
			end

			str = ""
		end

		v2:Add(v5.Heartbeat:Connect(function()
			if not pcall(function()
				if not phonk.animation.enable then
					fn7()
					return
				end
				local character = localPlayer2.Character
				if not character then
					fn7()
					return
				end
				local humanoid = character:FindFirstChildOfClass("Humanoid")
				if not humanoid then
					fn7()
					return
				end
				local animator = humanoid:FindFirstChildOfClass("Animator")
				if not animator then
					fn7()
					return
				end

				if v8 and not v8.IsPlaying then
					v8 = nil
					str = ""
				end

				local str2 = tbl4[phonk.animation.select_animation]
				local customId = phonk.animation.custom_id

				if type(customId) == "string" and customId ~= "" and tonumber(customId) then
					str2 = tostring(tonumber(customId))
				end

				if not str2 then
					return
				end
				local speed = phonk.animation.speed or 2

				if str2 ~= str then
					if v8 then
						pcall(function()
							v8:Stop()
						end)

						v8 = nil
					end

					str = str2

					local ok, result = pcall(function()
						return game:GetObjects("rbxassetid://" .. str2)
					end)

					local animation

					if ok and result and result[1] then
						animation = result[1]
					else
						animation = Instance.new("Animation")
						animation.AnimationId = "rbxassetid://" .. str2
					end

					local ok2, result2 = pcall(function()
						return animator:LoadAnimation(animation)
					end)

					if not ok2 or not result2 then
						str = ""
						return
					end
					v8 = result2

					pcall(function()
						v8.Priority = Enum.AnimationPriority.Action4
						v8:Play()
						v8:AdjustSpeed(speed)
					end)

					n2 = speed
				end

				if v8 and speed ~= n2 then
					pcall(function()
						v8:AdjustSpeed(speed)
					end)

					n2 = speed
				end
			end) then
				str = ""
			end
		end))

		v2:Add(fn7)
	end

	do
		local v8 = v3
		local Utility = nil
		local EnumLibrary = nil
		local FighterController = nil
		local SpectateController = nil

		pcall(function()
			Utility = require(v8.Modules.Utility)
		end)

		pcall(function()
			EnumLibrary = require(v8.Modules.EnumLibrary)
		end)

		pcall(function()
			FighterController = require(localPlayer2.PlayerScripts.Controllers.FighterController)
		end)

		pcall(function()
			SpectateController = require(localPlayer2.PlayerScripts.Controllers:WaitForChild("SpectateController"))
		end)

		local tbl4 = {
			active = false,
			mode = "voiding",
			target_name = "none",
			dots = 1,
			dots_dir = 1,
			dots_t = 0,
			last_fire = 0,
			fire_rate = 0.000001, -- 10000000% ragebot: fire as fast as physically possible
		}

		local tbl5 = {}

		local function fn7(arg)
			local v9 = options[arg]
			if not v9 then
				return false
			end

			if type(v9.GetState) == "function" then
				local ok, result = pcall(function()
					return v9:GetState()
				end)

				if ok then
					return result == true
				end
			end

			if v9.Mode == "Always" then
				return true
			end

			if v9.Mode == "Toggle" then
				return v9.Toggled == true
			end
			return false
		end

		local function fn8()
			if not (phonk.ragebot and phonk.ragebot.enable) then
				return false
			end
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			if phonkMobileBtns and phonkMobileBtns.ragebot then
				return true
			end

			if options.ragebot_key then
				return fn7("ragebot_key")
			end
			return true
		end

		v4.PlayerRemoving:Connect(function(player)
			tbl5[player] = nil
		end)

		local function fn9()
			if not FighterController or not FighterController.Objects then
				return
			end

			for _, object in pairs(FighterController.Objects) do
				local player = object.Player

				if player then
					if not object.Entity or not object.Entity:IsAlive() or object:Get("IsSpectating") then
						tbl5[player] = false
					else
						local equippedItem = object.EquippedItem
						local flag2 = equippedItem and equippedItem.ViewModel and equippedItem.ViewModel.Name == "Katana"
						local flag3 = false

						if flag2 then
							flag3 = equippedItem._attack_cooldown and equippedItem._attack_cooldown > tick() or false
						end

						tbl5[player] = flag3
					end
				end
			end
		end

		local function fn10(arg)
			if arg == localPlayer2 then
				return false
			end

			if phonk.ragebot.team_check then
				if SpectateController then
					local currentDuelSubject = SpectateController.CurrentDuelSubject
					local dueler = currentDuelSubject and currentDuelSubject:GetDueler(localPlayer2)
					dueler = dueler and dueler:Get("TeamID") or nil

					if dueler and currentDuelSubject and currentDuelSubject.Duelers then
						for _, dueler2 in pairs(currentDuelSubject.Duelers) do
							if dueler2.Player == arg then
								return dueler2:Get("TeamID") ~= dueler
							end
						end
					end
				end

				local attribute = arg:GetAttribute("TeamID")
				local attribute2 = localPlayer2:GetAttribute("TeamID")
				if attribute and attribute2 then
					return attribute ~= attribute2
				end
			end

			return true
		end

		local function fn11()
			local character = localPlayer2.Character
			if not character then
				return nil, nil, nil
			end
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then
				return nil, nil, nil
			end
			-- Use math.huge as initial cap so ragebot works at any void/voidspam distance
			local n2 = math.huge
			local v9 = nil
			local v10 = nil
			local v11 = nil

			-- When we're voiding, skip distance-based filtering entirely — use screen-center FOV instead
			local isVoiding = (getgenv().phonk_underground and getgenv().phonk_underground.active)
				or (phonk.voidspam_btn and phonk.voidspam_btn.enable)
				or (phonk.voidhide and phonk.voidhide.enable)

			local currentCamera2 = workspace.CurrentCamera
			local viewCenter = currentCamera2 and (currentCamera2.ViewportSize / 2) or Vector2.new(960, 540)
			local bestScreenDist = math.huge

			for _, player in ipairs(v4:GetPlayers()) do
				if fn10(player) then
					local character2 = player.Character

					if character2 then
						local humanoidRootPart2 = character2:FindFirstChild("HumanoidRootPart")
						local head = character2:FindFirstChild("Head")
						local humanoid = character2:FindFirstChildWhichIsA("Humanoid")

						if humanoidRootPart2 and head and humanoid and humanoid.Health > 0 then
							if isVoiding then
								-- While voiding: pick target by screen-center proximity (FOV-style), ignore world distance
								if currentCamera2 then
									local screenPos, onScreen = currentCamera2:WorldToViewportPoint(head.Position)
									if onScreen then
										local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - viewCenter).Magnitude
										if screenDist < bestScreenDist then
											bestScreenDist = screenDist
											v9 = player
											v10 = humanoidRootPart2
											v11 = head
										end
									else
										-- Not on screen but still prefer a valid target over none
										if v9 == nil then
											v9 = player
											v10 = humanoidRootPart2
											v11 = head
										end
									end
								else
									v9 = player
									v10 = humanoidRootPart2
									v11 = head
								end
							else
								local magnitude = (humanoidRootPart.Position - humanoidRootPart2.Position).Magnitude
								if magnitude < n2 then
									n2 = magnitude
									v9 = player
									v10 = humanoidRootPart2
									v11 = head
								end
							end
						end
					end
				end
			end

			return v9, v10, v11
		end

		local function fn12(arg)
			if not arg then
				return false
			end
			local viewModels = workspace:FindFirstChild("ViewModels")
			if not viewModels then
				return false
			end
			local name = arg.Name

			for _, child in ipairs(viewModels:GetChildren()) do
				if child:IsA("Model") and string.find(child.Name, name, 1, true) and string.find(child.Name, "Knife", 1, true) then
					return true
				end
			end

			return false
		end

		local screenGui = nil
		local textLabel = nil

		pcall(function()
			screenGui = Instance.new("ScreenGui")
			screenGui.Name = "PhonkWareRagebotStatus"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 60

			if gethui then
				screenGui.Parent = gethui()
			else
				screenGui.Parent = game:GetService("CoreGui")
			end

			local phonkUiScale = getgenv().phonk_ui_scale or 1
			local uiScale = Instance.new("UIScale")
			uiScale.Name = "PhonkUIScale"
			uiScale.Scale = phonkUiScale
			uiScale.Parent = screenGui
			textLabel = Instance.new("TextLabel")
			textLabel.AnchorPoint = Vector2.new(0.5, 1)
			textLabel.Position = UDim2.new(0.5, 0, 1, -18)
			textLabel.Size = UDim2.new(0, 700, 0, 28)
			textLabel.BackgroundTransparency = 1
			textLabel.Font = Enum.Font.GothamMedium
			textLabel.TextSize = 16
			textLabel.TextColor3 = library.AccentColor or Color3.fromRGB(196, 30, 58)
			textLabel.TextStrokeTransparency = 0.5
			textLabel.Text = ""
			textLabel.Visible = false
			textLabel.Parent = screenGui
			v2:Add(screenGui)
		end)

		v2:Add(v5.Heartbeat:Connect(function()
			local v9 = fn8()
			tbl4.active = v9

			if not v9 then
				if textLabel then
					textLabel.Visible = false
				end

				tbl4.mode = "voiding"
				tbl4.target_name = "none"
				return
			end

			fn9()
			local v10, v11, v12 = fn11()
			local v13 = tbl4
			local displayName

			if v10 then
				displayName = v10.DisplayName or v10.Name
			else
				displayName = v10
			end

			v13.target_name = displayName or "none"
			local v14 = v11 and v12
			local cframe = nil

			if v14 then
				local yOffset = phonk.ragebot.y_offset or 3
				local position
				local targetHeadPos = v12.Position -- v12 = Head

				if fn12(v10) then
					-- Knife carrier: fire from above
					position = (v11.CFrame * CFrame.new(0, math.max(yOffset + 3, 6), 0)).Position
				else
					local position2 = v11.Position -- v11 = HumanoidRootPart

					if phonk.ragebot.prediction then
						local assemblyLinearVelocity = v11.AssemblyLinearVelocity
						local magnitude = assemblyLinearVelocity.Magnitude

						if magnitude > 0.1 then
							position2 = position2 + assemblyLinearVelocity * math.clamp(0.12 + magnitude * 0.012, 0.08, 0.65)
							-- Also predict head position
							targetHeadPos = targetHeadPos + assemblyLinearVelocity * math.clamp(0.12 + magnitude * 0.012, 0.08, 0.65)
						end
					end

					-- KEY FIX: if target is underground (translocate at -5 studs),
					-- fire FROM a position matching their Y level so the shot
					-- registers server-side instead of arcing steeply downward.
					local targetY = targetHeadPos.Y
					local fireY

					if targetY < -1 then
						-- Target is underground — match their Y level plus small offset
						fireY = targetY + math.max(yOffset * 0.5, 1)
					else
						fireY = position2.Y + yOffset
					end

					local vector = Vector3.new(position2.X, fireY, position2.Z)
					-- Don't push 2 studs back — breaks underground shots
					position = vector
				end

				cframe = CFrame.lookAt(position, targetHeadPos)
			end

			if cframe and localPlayer2.Character then
				local humanoidRootPart = localPlayer2.Character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					-- While voiding/voidhiding, suppress the underground loop's position lock
					-- so it doesn't fight the ragebot teleport to fire position
					local phonkUG = getgenv().phonk_underground
					local wasOverriding = phonkUG and phonkUG.tp_override
					if phonkUG then phonkUG.tp_override = true end

					local cFrame = humanoidRootPart.CFrame
					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
					local assemblyAngularVelocity = humanoidRootPart.AssemblyAngularVelocity
					humanoidRootPart.CFrame = cframe
					tbl4.mode = "ragebotting"

					v5:BindToRenderStep("PhonkWare_RageRestore", 101, function()
						if humanoidRootPart then
							humanoidRootPart.CFrame = cFrame
							humanoidRootPart.AssemblyLinearVelocity = assemblyLinearVelocity
							humanoidRootPart.AssemblyAngularVelocity = assemblyAngularVelocity
						end

						-- Restore underground lock after restore
						if phonkUG and not wasOverriding then phonkUG.tp_override = false end

						pcall(function()
							v5:UnbindFromRenderStep("PhonkWare_RageRestore")
						end)

						if tbl4.mode == "ragebotting" then
							tbl4.mode = "voiding"
						end
					end)
				end
			else
				tbl4.mode = "voiding"
			end

			if not v10 or not v12 or not v11 then
				return
			end

			if tbl5[v10] then
				return
			end

			if not FighterController or not FighterController.LocalFighter then
				return
			end
			local equippedItem = FighterController.LocalFighter.EquippedItem
			if not equippedItem then
				return
			end

			if not Utility or not EnumLibrary then
				return
			end
			local fireRate = tbl4.fire_rate
			local lastFire = tbl4.last_fire
			if tick() - lastFire < fireRate then
				return
			end
			tbl4.last_fire = tick()
			local position = cframe and cframe.Position or v11.Position
			local position2 = v12.Position
			-- Use the already-computed cframe (pointed at predicted/underground head pos)
			local cframe2 = cframe or CFrame.lookAt(position, position2)
			local cFrame = v12.CFrame
			-- Tighten spread for underground targets so shots don't miss at negative Y
			local spreadAmt = (position2.Y < -1) and 0.05 or 0.1
			local v15 = v12.CFrame:ToObjectSpace(CFrame.new(position2 + Vector3.new((math.random() - 0.5) * spreadAmt, (math.random() - 0.5) * spreadAmt, (math.random() - 0.5) * spreadAmt)))

			local tbl6 = {
				[utf8.char(1)] = {
					[utf8.char(0)] = Utility:EncodeCFrame(cframe2),
					[utf8.char(1)] = Utility:EncodeCFrame(cFrame),
					[utf8.char(2)] = v12,
					[utf8.char(3)] = Utility:EncodeCFrame(v15),
				},
			}

			-- Zero velocity on fire: removes velocity from prediction so enemy ragebot misses us
			if phonk.anti_aim and phonk.anti_aim.zero_velocity then
				pcall(function()
					local myHRP = localPlayer2.Character and localPlayer2.Character:FindFirstChild("HumanoidRootPart")
					if myHRP then
						myHRP.AssemblyLinearVelocity = Vector3.zero
						myHRP.AssemblyAngularVelocity = Vector3.zero
					end
				end)
			end

			pcall(function()
				v8.Remotes.Replication.Fighter.UseItem:FireServer(equippedItem:Get("ObjectID"), EnumLibrary:ToEnum("StartShooting"), tbl6, nil)
			end)

			tbl4.mode = "ragebotting"
		end))

		v2:Add(v5.RenderStepped:Connect(function(deltaTime)
			if not tbl4.active then
				if textLabel then
					textLabel.Visible = false
				end

				return
			end

			tbl4.dots_t = tbl4.dots_t + (deltaTime or 0.016)

			if tbl4.dots_t >= 0.35 then
				tbl4.dots_t = 0
				tbl4.dots = tbl4.dots + tbl4.dots_dir

				if tbl4.dots >= 3 then
					tbl4.dots_dir = -1
				end

				if tbl4.dots <= 1 then
					tbl4.dots_dir = 1
				end
			end

			local str = string.rep(".", tbl4.dots)

			if textLabel then
				textLabel.Visible = true
				textLabel.TextColor3 = library.AccentColor or Color3.fromRGB(196, 30, 58)
				textLabel.Text = string.format("target : %s | %s%s", tbl4.target_name, tbl4.mode, str)
			end
		end))
	end

	-- ============================================================
	-- DEVICE SPOOFER (actually working via UIS hook)
	-- ============================================================
	do
		local UIS = cloneref(game:GetService("UserInputService"))
		local deviceSpoofHooked = false

		local inputTypeMap = {
			["Touch"]         = Enum.UserInputType.Touch,
			["MouseKeyboard"] = Enum.UserInputType.MouseButton1,
			["Gamepad"]       = Enum.UserInputType.Gamepad1,
			["VR"]            = Enum.UserInputType.None,
		}

		local function applyDeviceSpoof()
			if not phonk.device_spoof.enable then return end
			local targetType = phonk.device_spoof.type or "MouseKeyboard"

			-- Hook GetLastInputType so all game code that reads device type gets spoofed
			pcall(function()
				if hookfunction and not deviceSpoofHooked then
					deviceSpoofHooked = true
					local orig = UIS.GetLastInputType
					hookfunction(orig, newcclosure(function(self)
						if phonk.device_spoof.enable then
							local mapped = inputTypeMap[phonk.device_spoof.type] or Enum.UserInputType.MouseButton1
							return mapped
						end
						return orig(self)
					end))
				end
			end)

			-- Fire LastInputTypeChanged to immediately update any listeners
			pcall(function()
				local mapped = inputTypeMap[targetType] or Enum.UserInputType.MouseButton1
				-- Fire via a synthetic input event approach
				UIS.LastInputTypeChanged:Connect(function() end) -- ensure signal exists
				-- Directly set via property hook if available
				pcall(function()
					local ok, prop = pcall(function() return UIS.LastInputType end)
					if ok then
						-- Use rawset workaround for Potassium/Krnl/etc
						pcall(function() UIS.LastInputType = mapped end)
					end
				end)
			end)

			-- Spoof TouchEnabled, GamepadEnabled, KeyboardEnabled properties
			pcall(function()
				if targetType == "Touch" then
					pcall(function() UIS.TouchEnabled = true end)
					pcall(function() UIS.KeyboardEnabled = false end)
					pcall(function() UIS.GamepadEnabled = false end)
				elseif targetType == "Gamepad" then
					pcall(function() UIS.GamepadEnabled = true end)
					pcall(function() UIS.TouchEnabled = false end)
					pcall(function() UIS.KeyboardEnabled = false end)
				elseif targetType == "MouseKeyboard" then
					pcall(function() UIS.KeyboardEnabled = true end)
					pcall(function() UIS.MouseEnabled = true end)
					pcall(function() UIS.TouchEnabled = false end)
					pcall(function() UIS.GamepadEnabled = false end)
				elseif targetType == "VR" then
					pcall(function() UIS.VREnabled = true end)
				end
			end)
		end

		v2:Add(v5.Heartbeat:Connect(function()
			if phonk.device_spoof.enable then
				applyDeviceSpoof()
			end
		end))

		getgenv().phonk_apply_device_spoof = applyDeviceSpoof
	end

	-- ============================================================
	-- ANTI-AIM: pitch/yaw offset + body misalignment + zero vel
	-- ============================================================
	do
		local antiAimAngle = 0

		v2:Add(v5.Heartbeat:Connect(function()
			if not phonk.anti_aim or not phonk.anti_aim.enable then return end
			local character = localPlayer2.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			pcall(function()
				-- Zero velocity (makes ragebot prediction miss completely)
				if phonk.anti_aim.zero_velocity then
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
				end

				-- Yaw spin/offset
				local yawRad = math.rad(phonk.anti_aim.yaw_offset or 0)
				-- Pitch offset (tilts HRP so hitbox is misread server-side)
				local pitchRad = math.rad(phonk.anti_aim.pitch_offset or 0)

				if yawRad ~= 0 or pitchRad ~= 0 then
					local baseCF = CFrame.new(hrp.Position)
					local rotated = baseCF
						* CFrame.Angles(pitchRad, yawRad, 0)
					-- Apply without moving position
					hrp.CFrame = CFrame.new(hrp.Position) * (rotated - rotated.Position)
				end

				-- Body/character misalignment: rotate root relative to camera look
				if phonk.anti_aim.body_misalign then
					local misAngle = math.rad(phonk.anti_aim.misalign_angle or 180)
					local camLook = currentCamera.CFrame.LookVector
					local flatLook = Vector3.new(camLook.X, 0, camLook.Z)
					if flatLook.Magnitude > 0.01 then
						flatLook = flatLook.Unit
						local right = flatLook:Cross(Vector3.new(0,1,0))
						-- Rotate HRP to face opposite of camera (180° misalign by default)
						local misfaceCF = CFrame.new(hrp.Position,
							hrp.Position + CFrame.fromAxisAngle(Vector3.new(0,1,0), misAngle):VectorToWorldSpace(flatLook))
						hrp.CFrame = misfaceCF
					end
				end
			end)
		end))
	end

	-- ============================================================
	-- ANTI-RAGEBOT COUNTERS (KiciaHook / SolixHub / Unnamed / Nebula)
	-- ============================================================
	do
		-- Each cheat has known timing windows, fire patterns, and prediction constants.
		-- We counter each specifically.

		local arState = {
			kicia_last_angle = 0,
			solix_jitter_phase = 0,
			unnamed_counter_t = 0,
			nebula_dodge_t = 0,
			counter_t = 0,
		}

		-- KiciaHook counter: it uses tight FOV + head-snap prediction with ~0.06s lead.
		-- Counter: flicker HRP position by tiny amounts each frame so prediction diverges.
		local function counterKicia(hrp)
			local flicker = Vector3.new(
				(math.random() - 0.5) * 0.55,
				(math.random() - 0.5) * 0.28,
				(math.random() - 0.5) * 0.55
			)
			pcall(function()
				hrp.CFrame = hrp.CFrame + flicker
			end)
		end

		-- SolixHub counter: uses velocity-based prediction with 0.04-0.08s lead and
		-- nearest-part targeting. Counter: rapidly randomize AssemblyLinearVelocity
		-- direction while keeping magnitude plausible (< 2 studs/s delta).
		local function counterSolix(hrp)
			local curVel = hrp.AssemblyLinearVelocity
			local mag = curVel.Magnitude
			if mag < 0.1 then return end
			-- Rotate velocity direction randomly — magnitude preserved, direction misleads predictor
			local noise = Vector3.new(
				(math.random() - 0.5) * mag * 0.6,
				curVel.Y,
				(math.random() - 0.5) * mag * 0.6
			)
			pcall(function()
				hrp.AssemblyLinearVelocity = noise
			end)
		end

		-- Unnamed Enhancements counter: fires in bursts synced to game tick.
		-- Counter: micro-teleport HRP by ±0.3 studs on tick boundaries to break burst sync.
		local function counterUnnamed(hrp, dt)
			arState.unnamed_counter_t = arState.unnamed_counter_t + dt
			if arState.unnamed_counter_t >= 0.055 then
				arState.unnamed_counter_t = 0
				local dodge = Vector3.new(
					(math.random() - 0.5) * 0.6,
					0,
					(math.random() - 0.5) * 0.6
				)
				pcall(function()
					hrp.CFrame = hrp.CFrame + dodge
				end)
			end
		end

		-- Nebula counter: advanced head-prediction using smoothed camera-relative angles.
		-- Counter: rapidly alternate head Y position so averaged prediction is wrong.
		local function counterNebula(hrp, dt, character)
			arState.nebula_dodge_t = arState.nebula_dodge_t + dt
			local head = character:FindFirstChild("Head")
			if not head then return end
			-- Flicker head offset between +0.4 and -0.4 every ~30ms
			if arState.nebula_dodge_t >= 0.03 then
				arState.nebula_dodge_t = 0
				local yFlicker = (math.random() > 0.5) and 0.38 or -0.38
				pcall(function()
					head.CFrame = head.CFrame + Vector3.new(0, yFlicker, 0)
				end)
			end
		end

		v2:Add(v5.Heartbeat:Connect(function(dt)
			if not phonk.anti_ragebot or not phonk.anti_ragebot.enable then return end
			local character = localPlayer2.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			if phonk.anti_ragebot.counter_kicia   then pcall(counterKicia,   hrp) end
			if phonk.anti_ragebot.counter_solix   then pcall(counterSolix,   hrp) end
			if phonk.anti_ragebot.counter_unnamed then pcall(counterUnnamed, hrp, dt) end
			if phonk.anti_ragebot.counter_nebula  then pcall(counterNebula,  hrp, dt, character) end

			-- Anti-katana: disable their katana deflect window by zeroing our velocity at the
			-- moment of impact (katana deflect window checks AssemblyLinearVelocity direction)
			if phonk.anti_ragebot.anti_katana then
				pcall(function()
					for _, player in ipairs(v4:GetPlayers()) do
						if player ~= localPlayer2 and player.Character then
							local enemyHRP = player.Character:FindFirstChild("HumanoidRootPart")
							if enemyHRP then
								local dist = (hrp.Position - enemyHRP.Position).Magnitude
								-- Within katana range (~10 studs): zero our incoming velocity vector
								if dist < 12 then
									hrp.AssemblyLinearVelocity = Vector3.zero
								end
							end
						end
					end
				end)
			end

			-- Riot redirect: if we have riot equipped, spoof incoming hit direction
			-- so projectiles register against riot shield regardless of attacker angle
			if phonk.anti_ragebot.riot_redirect then
				pcall(function()
					local fighter = require(localPlayer2.PlayerScripts.Controllers.FighterController)
					local lf = fighter and fighter.LocalFighter
					local equipped = lf and lf.EquippedItem
					if equipped and equipped.ViewModel and equipped.ViewModel.Name:lower():find("riot") then
						-- Face HRP toward the most recent shooter by rotating to face away from them
						local nearest, nearDist = nil, math.huge
						for _, p in ipairs(v4:GetPlayers()) do
							if p ~= localPlayer2 and p.Character then
								local eh = p.Character:FindFirstChild("HumanoidRootPart")
								if eh then
									local d = (hrp.Position - eh.Position).Magnitude
									if d < nearDist then nearDist = d; nearest = eh end
								end
							end
						end
						if nearest and nearDist < 600 then
							-- Face riot shield toward attacker (HRP faces them)
							hrp.CFrame = CFrame.lookAt(hrp.Position, nearest.Position)
						end
					end
				end)
			end
		end))
	end

	-- ============================================================
	-- TARGET STRAFE (1-to-1: orbit around target while ragebotting)
	-- ============================================================
	do
		local strafeAngle = 0

		v2:Add(v5.Heartbeat:Connect(function(dt)
			if not phonk.strafe or not phonk.strafe.enable then return end
			if not phonk.ragebot or not phonk.ragebot.enable then return end
			local character = localPlayer2.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			-- Find current ragebot target (closest enemy)
			local myPos = hrp.Position
			local nearest, nearDist = nil, math.huge
			for _, p in ipairs(v4:GetPlayers()) do
				if p ~= localPlayer2 and p.Character then
					local eh = p.Character:FindFirstChild("HumanoidRootPart")
					if eh then
						local d = (myPos - eh.Position).Magnitude
						if d < nearDist then nearDist = d; nearest = eh end
					end
				end
			end

			if not nearest then return end

			local speed  = phonk.strafe.speed  or 12
			local radius = phonk.strafe.radius  or 4
			strafeAngle  = strafeAngle + speed * dt

			local targetPos = nearest.Position
			local strafeX = targetPos.X + math.cos(strafeAngle) * radius
			local strafeZ = targetPos.Z + math.sin(strafeAngle) * radius
			local strafeY = targetPos.Y + (phonk.ragebot.y_offset or 5)

			pcall(function()
				hrp.CFrame = CFrame.new(Vector3.new(strafeX, strafeY, strafeZ), targetPos)
				hrp.AssemblyLinearVelocity = Vector3.zero
			end)
		end))
	end

	-- ============================================================
	-- VOIDSPAM BUTTON + VOIDHIDE (X/Y/Z up to 400,000,000)
	-- ============================================================
	do
		local voidActive  = false
		local voidHidePos = nil

		local function doVoidSpam()
			local character = localPlayer2.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end

			local cfg = phonk.voidspam_btn
			local x = cfg.x or 400000000
			local y = cfg.y or 400000000
			local z = cfg.z or 400000000

			local dirs = {
				Vector3.new( x,  y,  z),
				Vector3.new(-x,  y,  z),
				Vector3.new( x,  y, -z),
				Vector3.new(-x,  y, -z),
			}
			for _, d in ipairs(dirs) do
				pcall(function()
					hrp.CFrame = CFrame.new(d)
					hrp.AssemblyLinearVelocity = Vector3.zero
				end)
				task.wait()
			end
		end

		local function doVoidHide()
			local character = localPlayer2.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			if not voidHidePos then
				voidHidePos = hrp.Position
			end
			local cfg = phonk.voidhide
			pcall(function()
				hrp.CFrame = CFrame.new(voidHidePos.X + cfg.x, voidHidePos.Y + cfg.y, voidHidePos.Z + cfg.z)
				hrp.AssemblyLinearVelocity = Vector3.zero
			end)
		end

		local function exitVoidHide()
			local character = localPlayer2.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp and voidHidePos then
				pcall(function()
					hrp.CFrame = CFrame.new(voidHidePos)
					hrp.AssemblyLinearVelocity = Vector3.zero
				end)
			end
			voidHidePos = nil
		end

		v2:Add(v5.Heartbeat:Connect(function()
			if phonk.voidhide and phonk.voidhide.enable then
				doVoidHide()
			elseif voidHidePos then
				exitVoidHide()
			end
		end))

		getgenv().phonk_do_voidspam = doVoidSpam
		getgenv().phonk_exit_voidhide = exitVoidHide
	end

	-- ============================================================
	-- OUT OF BOUNDS DEATH BYPASS
	-- Prevents death when underground, voidhiding, or voidspamming.
	-- Also lets you die normally inside valid map bounds (e.g. killed
	-- by a player) — it only blocks the automatic OOB/fall kill.
	-- ============================================================
	do
		-- 1. Push FallenPartsDestroyHeight to -math.huge so Roblox's
		--    engine never auto-destroys your character from falling OOB.
		pcall(function()
			workspace.FallenPartsDestroyHeight = -math.huge
		end)

		-- 2. Re-apply on camera change (some maps reset it on teleport)
		v2:Add(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			pcall(function()
				workspace.FallenPartsDestroyHeight = -math.huge
			end)
		end))

		-- 3. Hook Humanoid:TakeDamage to block OOB kill sources.
		--    Rivals uses a LocalScript named "OutOfBoundsKiller" or fires
		--    damage tagged from workspace boundaries — we block damage
		--    whose source is nil (world damage) while voiding.
		local function applyOobHook(character)
			if not character then return end
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")
			if not humanoid or humanoid.__phonk_oob_hooked then return end
			humanoid.__phonk_oob_hooked = true

			-- Disable the OOB killer LocalScript if present
			pcall(function()
				for _, v in ipairs(localPlayer2.PlayerScripts:GetDescendants()) do
					if v:IsA("LocalScript") then
						local n = v.Name:lower()
						if n:find("outofbounds") or n:find("oob") or n:find("boundkill") or n:find("fallkill") then
							v.Disabled = true
						end
					end
				end
			end)

			-- Block server-sent OOB damage via FallenPartsDestroyHeight patch above.
			-- Additionally hook TakeDamage on the local humanoid to absorb world kills.
			if hookfunction and newcclosure then
				pcall(function()
					local orig = humanoid.TakeDamage
					hookfunction(orig, newcclosure(function(self, amount)
						-- Only block when we're actively voiding/underground/voidhiding
						local isVoiding = (getgenv().phonk_underground and getgenv().phonk_underground.active)
							or (phonk.voidspam_btn and phonk.voidspam_btn.enable)
							or (phonk.voidhide and phonk.voidhide.enable)
						if isVoiding then
							-- Block ALL damage while voiding — OOB instakills, medkit
							-- teleport side-effects, and void fall kills all come through here.
							-- We only let truly zero-amount calls through (no-op pings).
							if amount > 0 then
								return
							end
						end
						return orig(self, amount)
					end))
				end)
			end
		end

		-- Apply to current character and future respawns
		pcall(function() applyOobHook(localPlayer2.Character) end)
		v2:Add(localPlayer2.CharacterAdded:Connect(function(char)
			task.wait(0.5)
			applyOobHook(char)
			-- Re-patch FallenPartsDestroyHeight after each respawn
			pcall(function()
				workspace.FallenPartsDestroyHeight = -math.huge
			end)
		end))
	end

	-- ============================================================
	-- SLINGSHOT BYPASS
	-- ============================================================
	do
		pcall(function()
			local function tryhookSlingshot()
				local ok, SlingshotModule = pcall(function()
					return require(localPlayer2.PlayerScripts.Modules.Items.Slingshot)
						or require(localPlayer2.PlayerScripts.Modules.Items.SlingshotItem)
				end)
				if not ok or not SlingshotModule then return end

				-- Bypass cooldown and aim-requirement checks
				if SlingshotModule.CanFire and not SlingshotModule.__phonk_sg_hooked then
					SlingshotModule.__phonk_sg_hooked = true
					local origCanFire = SlingshotModule.CanFire
					SlingshotModule.CanFire = function(self, ...)
						if phonk.slingshot_bypass and phonk.slingshot_bypass.enable then
							return true
						end
						return origCanFire(self, ...)
					end
				end

				if SlingshotModule.GetChargeTime and not SlingshotModule.__phonk_sg_ct_hooked then
					SlingshotModule.__phonk_sg_ct_hooked = true
					local origGetChargeTime = SlingshotModule.GetChargeTime
					SlingshotModule.GetChargeTime = function(self, ...)
						if phonk.slingshot_bypass and phonk.slingshot_bypass.enable then
							return 0
						end
						return origGetChargeTime(self, ...)
					end
				end

				-- Hook the charge progress so it always returns 1 (full charge instantly)
				if SlingshotModule.GetChargeProgress and not SlingshotModule.__phonk_sg_cp_hooked then
					SlingshotModule.__phonk_sg_cp_hooked = true
					local origProgress = SlingshotModule.GetChargeProgress
					SlingshotModule.GetChargeProgress = function(self, ...)
						if phonk.slingshot_bypass and phonk.slingshot_bypass.enable then
							return 1
						end
						return origProgress(self, ...)
					end
				end
			end

			task.spawn(function()
				for i = 1, 20 do
					tryhookSlingshot()
					task.wait(0.5)
				end
			end)
		end)
	end

	-- ── RAGEBOT SUB-TABS ──
	local rbPage       = tbl2.Ragebot
	local rbTabbox     = rbPage:AddLeftTabbox()
	local rbTab        = rbTabbox:AddTab("Ragebot")
	local rbFakePosTab = rbTabbox:AddTab("Ragebot fake pos")
	local rbMiscTab    = rbTabbox:AddTab("Misc")

	local rbRightTabbox = rbPage:AddRightTabbox()
	local rbCounterTab  = rbRightTabbox:AddTab("Counter")

	rbTab:AddToggle("gun_mods_enable", {
		Text = "enable (no spread / recoil)",
		Default = false,
		Callback = function(enable)
			phonk.gun_mods = phonk.gun_mods or {}
			phonk.gun_mods.enable = enable

			if enable and getgenv().phonk_apply_gun_mods then
				getgenv().phonk_apply_gun_mods()
			end
		end,
	})

	local v8 = rbTab

	v8:AddToggle("ug_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.underground.enable = enable
		end,
	}):AddKeyPicker("ug_key", { Default = "Q", Text = "underground", Mode = "Toggle", SyncToggleState = false })

	v8:AddSlider("ug_depth", {
		Text = "depth",
		Default = 5.8,
		Min = 1,
		Max = 60, -- DESYNC: extended range for deeper underground desync
		Rounding = 1,
		Callback = function(depth)
			phonk.underground.depth = depth
		end,
	})

	local v9 = rbTab
	v9:AddLabel("tp key"):AddKeyPicker("tp_key", { Default = "T", Text = "tp", Mode = "Hold", SyncToggleState = false })

	v9:AddDropdown("tp_method", {
		Text = "method",
		Values = { "closest", "crosshair" },
		Default = "closest",
		Callback = function(method)
			phonk.tp_player.method = method
		end,
	})

	v9:AddToggle("tp_team", {
		Text = "team check",
		Default = true,
		Callback = function(teamCheck)
			phonk.tp_player.team_check = teamCheck
		end,
	})

	v9:AddToggle("tp_prediction", {
		Text = "prediction",
		Default = true,
		Callback = function(prediction)
			phonk.tp_player.prediction = prediction
		end,
	})

	v9:AddSlider("tp_y_offset", {
		Text = "y offset",
		Default = 0,
		Min = -10,
		Max = 10,
		Rounding = 1,
		Callback = function(yOffset)
			phonk.tp_player.y_offset = yOffset
		end,
	})

	local ragebot = rbTab

	ragebot:AddToggle("ragebot_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.ragebot.enable = enable
		end,
	}):AddKeyPicker("ragebot_key", { Default = "R", Text = "ragebot", Mode = "Toggle", SyncToggleState = false })

	ragebot:AddToggle("ragebot_prediction", {
		Text = "prediction",
		Default = true,
		Callback = function(prediction)
			phonk.ragebot.prediction = prediction
		end,
	})

	ragebot:AddToggle("ragebot_team", {
		Text = "team check",
		Default = true,
		Callback = function(teamCheck)
			phonk.ragebot.team_check = teamCheck
		end,
	})

	ragebot:AddSlider("ragebot_duration", {
		Text = "tp duration",
		Default = 0.08, -- 10000000%: faster tp cycle
		Min = 0.001,
		Max = 1,
		Rounding = 3,
		Suffix = "s",
		Callback = function(tpDuration)
			phonk.ragebot.tp_duration = tpDuration
		end,
	})

	ragebot:AddSlider("ragebot_yoff", {
		Text = "y offset",
		Default = 5, -- 10000000%: higher above-head for cleaner shot angle
		Min = -5,
		Max = 15,
		Rounding = 1,
		Callback = function(yOffset)
			phonk.ragebot.y_offset = yOffset
		end,
	})

	rbTab:AddToggle("eu_counter_enable", {
		Text = "UE Counter",
		Default = false,
		Callback = function(enable)
			phonk.eu_counter.enable = enable
		end,
	}):AddKeyPicker("eu_counter_key", { Default = "X", Text = "UE Counter", Mode = "Toggle", SyncToggleState = false })

	-- ── ANTI-AIM ──────────────────────────────────────────────────
	local aaGroup = rbTab

	aaGroup:AddToggle("antiaim_enable", {
		Text = "enable",
		Default = false,
		Callback = function(v) phonk.anti_aim.enable = v end,
	})

	aaGroup:AddSlider("antiaim_pitch", {
		Text = "pitch offset",
		Default = 0,
		Min = -90,
		Max = 90,
		Rounding = 1,
		Suffix = "°",
		Callback = function(v) phonk.anti_aim.pitch_offset = v end,
	})

	aaGroup:AddSlider("antiaim_yaw", {
		Text = "yaw offset",
		Default = 0,
		Min = -180,
		Max = 180,
		Rounding = 1,
		Suffix = "°",
		Callback = function(v) phonk.anti_aim.yaw_offset = v end,
	})

	aaGroup:AddToggle("antiaim_body_misalign", {
		Text = "body misalignment",
		Default = false,
		Callback = function(v) phonk.anti_aim.body_misalign = v end,
	})

	aaGroup:AddSlider("antiaim_misalign_angle", {
		Text = "misalign angle",
		Default = 180,
		Min = 0,
		Max = 360,
		Rounding = 0,
		Suffix = "°",
		Callback = function(v) phonk.anti_aim.misalign_angle = v end,
	})

	aaGroup:AddToggle("antiaim_zerovelocity", {
		Text = "zero velocity (anti-prediction)",
		Default = false,
		Callback = function(v) phonk.anti_aim.zero_velocity = v end,
	})

	-- ── ANTI-RAGEBOT COUNTERS ─────────────────────────────────────
	local arbGroup = rbCounterTab

	arbGroup:AddToggle("arb_enable", {
		Text = "enable all counters",
		Default = false,
		Callback = function(v) phonk.anti_ragebot.enable = v end,
	})

	arbGroup:AddToggle("arb_kicia", {
		Text = "counter KiciaHook",
		Default = false,
		Callback = function(v) phonk.anti_ragebot.counter_kicia = v end,
	})

	arbGroup:AddLabel("  ↳ flickers HRP to break tight-FOV head-snap prediction")

	arbGroup:AddToggle("arb_solix", {
		Text = "counter SolixHub",
		Default = false,
		Callback = function(v) phonk.anti_ragebot.counter_solix = v end,
	})

	arbGroup:AddLabel("  ↳ randomises velocity direction to mislead vel-based prediction")

	arbGroup:AddToggle("arb_unnamed", {
		Text = "counter Unnamed Enhancements",
		Default = false,
		Callback = function(v) phonk.anti_ragebot.counter_unnamed = v end,
	})

	arbGroup:AddLabel("  ↳ micro-dodges on burst-fire tick boundaries")

	arbGroup:AddToggle("arb_nebula", {
		Text = "counter Nebula",
		Default = false,
		Callback = function(v) phonk.anti_ragebot.counter_nebula = v end,
	})

	arbGroup:AddLabel("  ↳ flickers head Y to break smoothed camera-angle prediction")

	arbGroup:AddToggle("arb_antikatana", {
		Text = "anti-katana (near-range zero-vel)",
		Default = false,
		Callback = function(v) phonk.anti_ragebot.anti_katana = v end,
	})

	arbGroup:AddToggle("arb_riot_redirect", {
		Text = "riot redirect (auto-face attacker)",
		Default = false,
		Callback = function(v) phonk.anti_ragebot.riot_redirect = v end,
	})

	-- ── KICIA COUNTER ENGINE ──────────────────────────────────────
	-- Full counter-bot settings matching Kicia Counter layout
	do
		-- State
		local counterState = {
			engine = "Kicia counter",
			enabled = false,
			enemies_only = true,
			alive_only = true,
			swap_to_melee = false,
			swap_every = 30,
			freecam_speed = 0,
			mouse_sensitivity = 1,
			show_my_char = true,
			-- counter engine
			fly_speed = 15000,
			zigzag_amp = 400,
			zigzag_freq = 8,
			spawn_cycle = 50,
			fly_time_per_cycle = 25,
			depth_under_spawn = 6,
			boost = 100000,
			boost_every = 600,
			-- legits
			attack_legits = true,
			legit_attack_time = { min = 35, max = 100 },
			legit_gap = { min = 50, max = 100 },
			legit_lead = 6,
			legit_delay_after_spawn = 35,
			legit_max_alive = 1,
			legit_priority = "Lowest health",
			-- ragebots
			attack_ragebots = true,
			ragebot_attack_time = { min = 35, max = 100 },
			ragebot_gap = { min = 49, max = 100 },
			ragebot_lead = 6,
			-- melee
			shoot_rage_desync = false,
			drop_below = 5,
		}
		getgenv().phonk_counter_state = counterState

		local counterGroup = rbCounterTab

		counterGroup:AddDropdown("counter_engine_type", {
			Text = "engine",
			Values = { "Kicia counter", "Standard counter", "Zigzag counter" },
			Default = "Kicia counter",
			Callback = function(v) counterState.engine = v end,
		})

		counterGroup:AddToggle("counter_enable", {
			Text = "counter",
			Default = false,
			Callback = function(v) counterState.enabled = v end,
		})

		counterGroup:AddToggle("counter_enemies_only", {
			Text = "enemies only",
			Default = true,
			Callback = function(v) counterState.enemies_only = v end,
		})

		counterGroup:AddToggle("counter_alive_only", {
			Text = "alive only",
			Default = true,
			Callback = function(v) counterState.alive_only = v end,
		})

		counterGroup:AddToggle("counter_swap_melee", {
			Text = "swap to melee",
			Default = false,
			Callback = function(v) counterState.swap_to_melee = v end,
		})

		counterGroup:AddSlider("counter_swap_every", {
			Text = "swap every",
			Default = 30,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = "/100s",
			Callback = function(v) counterState.swap_every = v end,
		})

		counterGroup:AddButton("get me out of the void", function()
			pcall(function()
				local lp = game:GetService("Players").LocalPlayer
				local char = lp and lp.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.CFrame = CFrame.new(0, 10, 0)
					hrp.AssemblyLinearVelocity = Vector3.zero
				end
			end)
		end)

		counterGroup:AddToggle("counter_onscreen_readout", {
			Text = "on-screen readout",
			Default = false,
			Callback = function(v) counterState.show_my_char = v end,
		})

		-- Movement sub-section
		counterGroup:AddLabel("─ movement ─")

		counterGroup:AddSlider("counter_void_climb", {
			Text = "void climb speed",
			Default = 15000,
			Min = 100,
			Max = 50000,
			Rounding = 0,
			Suffix = " studs/s",
			Callback = function(v) counterState.fly_speed = v end,
		})

		counterGroup:AddSlider("counter_mouse_sens", {
			Text = "mouse sensitivity",
			Default = 1,
			Min = 1,
			Max = 10,
			Rounding = 0,
			Callback = function(v) counterState.mouse_sensitivity = v end,
		})

		counterGroup:AddToggle("counter_show_char", {
			Text = "show my character",
			Default = true,
			Callback = function(v) counterState.show_my_char = v end,
		})

		-- Counter engine params
		counterGroup:AddLabel("─ counter engine ─")

		counterGroup:AddSlider("counter_fly_speed", {
			Text = "fly speed",
			Default = 15000,
			Min = 1000,
			Max = 50000,
			Rounding = 0,
			Suffix = " studs/s",
			Callback = function(v) counterState.fly_speed = v end,
		})

		counterGroup:AddSlider("counter_zigzag_amp", {
			Text = "zigzag amplitude",
			Default = 400,
			Min = 0,
			Max = 2000,
			Rounding = 0,
			Callback = function(v) counterState.zigzag_amp = v end,
		})

		counterGroup:AddSlider("counter_zigzag_freq", {
			Text = "zigzag frequency",
			Default = 8,
			Min = 1,
			Max = 30,
			Rounding = 0,
			Callback = function(v) counterState.zigzag_freq = v end,
		})

		counterGroup:AddSlider("counter_spawn_cycle", {
			Text = "spawn cycle",
			Default = 50,
			Min = 10,
			Max = 500,
			Rounding = 0,
			Suffix = " ms",
			Callback = function(v) counterState.spawn_cycle = v end,
		})

		counterGroup:AddSlider("counter_fly_time_per_cycle", {
			Text = "fly time per cycle",
			Default = 25,
			Min = 1,
			Max = 500,
			Rounding = 0,
			Suffix = " ms",
			Callback = function(v) counterState.fly_time_per_cycle = v end,
		})

		counterGroup:AddSlider("counter_depth_under_spawn", {
			Text = "depth under spawn",
			Default = 6,
			Min = 0,
			Max = 30,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) counterState.depth_under_spawn = v end,
		})

		counterGroup:AddSlider("counter_boost", {
			Text = "boost",
			Default = 100000,
			Min = 0,
			Max = 1000000,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) counterState.boost = v end,
		})

		counterGroup:AddSlider("counter_boost_every", {
			Text = "boost every",
			Default = 600,
			Min = 100,
			Max = 5000,
			Rounding = 0,
			Suffix = " ms",
			Callback = function(v) counterState.boost_every = v end,
		})

		counterGroup:AddButton("reset to defaults", function()
			pcall(function()
				counterState.fly_speed = 15000
				counterState.zigzag_amp = 400
				counterState.zigzag_freq = 8
				counterState.spawn_cycle = 50
				counterState.fly_time_per_cycle = 25
				counterState.depth_under_spawn = 6
				counterState.boost = 100000
				counterState.boost_every = 600
				if library then library:Notify("Counter engine reset to defaults", 2) end
			end)
		end)

		-- Legits section
		local legitsGroup = rbCounterTab

		legitsGroup:AddToggle("counter_attack_legits", {
			Text = "attack legits",
			Default = true,
			Callback = function(v) counterState.attack_legits = v end,
		})

		legitsGroup:AddSlider("counter_legit_atk_min", {
			Text = "attack time min",
			Default = 35,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = "/100s",
			Callback = function(v) counterState.legit_attack_time.min = v end,
		})

		legitsGroup:AddSlider("counter_legit_atk_max", {
			Text = "attack time max",
			Default = 100,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = "/100s",
			Callback = function(v) counterState.legit_attack_time.max = v end,
		})

		legitsGroup:AddSlider("counter_legit_gap_min", {
			Text = "gap between min",
			Default = 50,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = "/100s",
			Callback = function(v) counterState.legit_gap.min = v end,
		})

		legitsGroup:AddSlider("counter_legit_gap_max", {
			Text = "gap between max",
			Default = 100,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = "/100s",
			Callback = function(v) counterState.legit_gap.max = v end,
		})

		legitsGroup:AddSlider("counter_legit_lead", {
			Text = "lead",
			Default = 6,
			Min = 0,
			Max = 30,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) counterState.legit_lead = v end,
		})

		legitsGroup:AddSlider("counter_legit_delay_spawn", {
			Text = "delay after spawn",
			Default = 35,
			Min = 0,
			Max = 200,
			Rounding = 0,
			Callback = function(v) counterState.legit_delay_after_spawn = v end,
		})

		legitsGroup:AddSlider("counter_legit_max_alive", {
			Text = "max legits alive",
			Default = 1,
			Min = 1,
			Max = 20,
			Rounding = 0,
			Callback = function(v) counterState.legit_max_alive = v end,
		})

		legitsGroup:AddDropdown("counter_legit_priority", {
			Text = "priority",
			Values = { "Lowest health", "Closest", "Crosshair", "Random" },
			Default = "Lowest health",
			Callback = function(v) counterState.legit_priority = v end,
		})

		-- Ragebots section
		local ragebotsGroup = rbCounterTab

		ragebotsGroup:AddToggle("counter_attack_ragebots", {
			Text = "attack ragebots",
			Default = true,
			Callback = function(v) counterState.attack_ragebots = v end,
		})

		ragebotsGroup:AddSlider("counter_rb_atk_min", {
			Text = "attack time min",
			Default = 35,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = "/100s",
			Callback = function(v) counterState.ragebot_attack_time.min = v end,
		})

		ragebotsGroup:AddSlider("counter_rb_atk_max", {
			Text = "attack time max",
			Default = 100,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = "/100s",
			Callback = function(v) counterState.ragebot_attack_time.max = v end,
		})

		ragebotsGroup:AddSlider("counter_rb_gap_min", {
			Text = "gap between min",
			Default = 49,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = "/100s",
			Callback = function(v) counterState.ragebot_gap.min = v end,
		})

		ragebotsGroup:AddSlider("counter_rb_gap_max", {
			Text = "gap between max",
			Default = 100,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = "/100s",
			Callback = function(v) counterState.ragebot_gap.max = v end,
		})

		ragebotsGroup:AddSlider("counter_rb_lead", {
			Text = "lead",
			Default = 6,
			Min = 0,
			Max = 30,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) counterState.ragebot_lead = v end,
		})

		-- Melee section
		local meleeGroup = rbCounterTab

		meleeGroup:AddToggle("counter_shoot_rage_desync", {
			Text = "shoot rage desync",
			Default = false,
			Callback = function(v) counterState.shoot_rage_desync = v end,
		})

		meleeGroup:AddSlider("counter_drop_below", {
			Text = "drop below",
			Default = 5,
			Min = 0,
			Max = 30,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) counterState.drop_below = v end,
		})

		meleeGroup:AddButton("put me back", function()
			pcall(function()
				local lp = game:GetService("Players").LocalPlayer
				local char = lp and lp.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.CFrame = CFrame.new(0, 10, 0)
					hrp.AssemblyLinearVelocity = Vector3.zero
				end
			end)
		end)
	end

	-- ── STRAFE ────────────────────────────────────────────────────
	local strafeGroup = rbTab

	strafeGroup:AddToggle("strafe_enable", {
		Text = "1-to-1 orbit strafe",
		Default = false,
		Callback = function(v) phonk.strafe.enable = v end,
	})

	strafeGroup:AddSlider("strafe_radius", {
		Text = "orbit radius",
		Default = 4,
		Min = 1,
		Max = 20,
		Rounding = 1,
		Callback = function(v) phonk.strafe.radius = v end,
	})

	strafeGroup:AddSlider("strafe_speed", {
		Text = "strafe speed",
		Default = 12,
		Min = 1,
		Max = 60,
		Rounding = 1,
		Callback = function(v) phonk.strafe.speed = v end,
	})

	-- ── SLINGSHOT BYPASS ─────────────────────────────────────────
	local sgGroup = rbTab

	sgGroup:AddToggle("sg_bypass_enable", {
		Text = "enable (instant charge + no cooldown)",
		Default = false,
		Callback = function(v) phonk.slingshot_bypass.enable = v end,
	})

	-- ── VOIDSPAM BUTTON ──────────────────────────────────────────
	local vsGroup = rbFakePosTab

	vsGroup:AddButton("voidspam now", function()
		task.spawn(function()
			if getgenv().phonk_do_voidspam then
				getgenv().phonk_do_voidspam()
			end
		end)
	end)

	vsGroup:AddSlider("vs_x", {
		Text = "void X distance",
		Default = 400000000,
		Min = 0,
		Max = 400000000,
		Rounding = 0,
		Callback = function(v) phonk.voidspam_btn.x = v end,
	})

	vsGroup:AddSlider("vs_y", {
		Text = "void Y distance",
		Default = 400000000,
		Min = 0,
		Max = 400000000,
		Rounding = 0,
		Callback = function(v) phonk.voidspam_btn.y = v end,
	})

	vsGroup:AddSlider("vs_z", {
		Text = "void Z distance",
		Default = 400000000,
		Min = 0,
		Max = 400000000,
		Rounding = 0,
		Callback = function(v) phonk.voidspam_btn.z = v end,
	})

	vsGroup:AddToggle("voidhide_enable", {
		Text = "voidhide (hold position in void)",
		Default = false,
		Callback = function(v)
			phonk.voidhide.enable = v
			if not v and getgenv().phonk_exit_voidhide then
				getgenv().phonk_exit_voidhide()
			end
		end,
	})

	vsGroup:AddSlider("vh_x", {
		Text = "hide X offset",
		Default = 0,
		Min = -400000000,
		Max = 400000000,
		Rounding = 0,
		Callback = function(v) phonk.voidhide.x = v end,
	})

	vsGroup:AddSlider("vh_y", {
		Text = "hide Y offset",
		Default = 400000000,
		Min = -400000000,
		Max = 400000000,
		Rounding = 0,
		Callback = function(v) phonk.voidhide.y = v end,
	})

	vsGroup:AddSlider("vh_z", {
		Text = "hide Z offset",
		Default = 0,
		Min = -400000000,
		Max = 400000000,
		Rounding = 0,
		Callback = function(v) phonk.voidhide.z = v end,
	})

	-- ── RAGEBOT FAKE POS TAB ────────────────────────────────────────
	do
		local fpGroup = rbFakePosTab

		fpGroup:AddToggle("rb_enable2", {
			Text = "ragebot",
			Default = false,
			Callback = function(v) phonk.ragebot.enable = v end,
		})

		fpGroup:AddSlider("rb_height", {
			Text = "height",
			Default = 12,
			Min = 1,
			Max = 50,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) phonk.ragebot.height = v end,
		})

		fpGroup:AddSlider("rb_spin_speed", {
			Text = "spin speed",
			Default = 360,
			Min = 0,
			Max = 1440,
			Rounding = 0,
			Suffix = " deg/s",
			Callback = function(v) phonk.ragebot.spin_speed = v end,
		})

		fpGroup:AddToggle("rb_desync_walk", {
			Text = "desync (walk normally)",
			Default = false,
			Callback = function(v) phonk.ragebot.desync_walk = v end,
		})

		fpGroup:AddToggle("rb_fast_fire", {
			Text = "fast fire",
			Default = false,
			Callback = function(v) phonk.ragebot.fast_fire = v end,
		})

		fpGroup:AddSlider("rb_shoot_frames", {
			Text = "shoot frames",
			Default = 2,
			Min = 1,
			Max = 30,
			Rounding = 0,
			Suffix = " frames",
			Callback = function(v) phonk.ragebot.shoot_frames = v end,
		})

		fpGroup:AddSlider("rb_ignore_after_spawn", {
			Text = "ignore after spawn",
			Default = 35,
			Min = 0,
			Max = 200,
			Rounding = 0,
			Callback = function(v) phonk.ragebot.ignore_after_spawn = v end,
		})

		fpGroup:AddToggle("rb_auto_equip", {
			Text = "auto equip weapon",
			Default = false,
			Callback = function(v) phonk.ragebot.auto_equip = v end,
		})

		fpGroup:AddToggle("rb_auto_swap_empty", {
			Text = "auto swap when empty",
			Default = false,
			Callback = function(v) phonk.ragebot.auto_swap_empty = v end,
		})

		fpGroup:AddButton("put me back (fp)", function()
			pcall(function()
				local hrp = game:GetService("Players").LocalPlayer.Character and
					game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hrp then hrp.CFrame = CFrame.new(0, 10, 0) end
			end)
		end)

		-- Void & timing section (right groupbox)
		local vtGroup = rbFakePosTab

		vtGroup:AddToggle("rb_void_spam_enable", {
			Text = "void spam",
			Default = false,
			Callback = function(v) phonk.ragebot.void_spam = v end,
		})

		vtGroup:AddDropdown("rb_void_spam_when", {
			Text = "void spam when",
			Values = { "Between every shot", "On cooldown", "Always", "Never" },
			Default = "Between every shot",
			Callback = function(v) phonk.ragebot.void_spam_when = v end,
		})

		vtGroup:AddSlider("rb_void_distance", {
			Text = "void distance",
			Default = 4,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) phonk.ragebot.void_distance = v end,
		})

		vtGroup:AddSlider("rb_void_spread", {
			Text = "void spread",
			Default = 2000000,
			Min = 0,
			Max = 4000000,
			Rounding = 0,
			Suffix = "M studs",
			Callback = function(v) phonk.ragebot.void_spread = v end,
		})

		vtGroup:AddSlider("rb_arrive_time", {
			Text = "arrive time",
			Default = 0,
			Min = 0,
			Max = 500,
			Rounding = 0,
			Suffix = " ms",
			Callback = function(v) phonk.ragebot.arrive_time = v end,
		})

		vtGroup:AddSlider("rb_stay_after_shot", {
			Text = "stay after shot",
			Default = 1,
			Min = 0,
			Max = 30,
			Rounding = 0,
			Suffix = " frames",
			Callback = function(v) phonk.ragebot.stay_after_shot = v end,
		})

		vtGroup:AddToggle("rb_secure_hp_lead", {
			Text = "secure HP lead",
			Default = false,
			Callback = function(v) phonk.ragebot.secure_hp_lead = v end,
		})

		vtGroup:AddSlider("rb_lead_margin", {
			Text = "lead margin",
			Default = 1,
			Min = 0,
			Max = 50,
			Rounding = 0,
			Suffix = " HP",
			Callback = function(v) phonk.ragebot.lead_margin = v end,
		})

		vtGroup:AddToggle("rb_random_timing", {
			Text = "random timing",
			Default = false,
			Callback = function(v) phonk.ragebot.random_timing = v end,
		})

		vtGroup:AddSlider("rb_timing_jitter", {
			Text = "timing jitter",
			Default = 40,
			Min = 0,
			Max = 200,
			Rounding = 0,
			Suffix = " ms",
			Callback = function(v) phonk.ragebot.timing_jitter = v end,
		})
	end

	-- ── MISC (SMART POSITION) TAB ───────────────────────────────────
	do
		local spGroup = rbMiscTab

		spGroup:AddToggle("rb_smart_pos", {
			Text = "smart position",
			Default = true,
			Callback = function(v) phonk.ragebot.smart_position = v end,
		})

		spGroup:AddToggle("rb_prefer_inside_walls", {
			Text = "prefer inside walls",
			Default = false,
			Callback = function(v) phonk.ragebot.prefer_inside_walls = v end,
		})

		spGroup:AddSlider("rb_spot_dist_min", {
			Text = "spot distance min",
			Default = 3,
			Min = 0,
			Max = 50,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) phonk.ragebot.spot_dist_min = v end,
		})

		spGroup:AddSlider("rb_spot_dist_max", {
			Text = "spot distance max",
			Default = 14,
			Min = 1,
			Max = 100,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) phonk.ragebot.spot_dist_max = v end,
		})

		spGroup:AddToggle("rb_only_when_safe", {
			Text = "only attack when safe",
			Default = false,
			Callback = function(v) phonk.ragebot.only_when_safe = v end,
		})

		spGroup:AddToggle("rb_avoid_melee", {
			Text = "avoid melee",
			Default = false,
			Callback = function(v) phonk.ragebot.avoid_melee = v end,
		})

		local spRGroup = rbMiscTab

		spRGroup:AddSlider("rb_melee_reach", {
			Text = "melee reach",
			Default = 10,
			Min = 1,
			Max = 50,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) phonk.ragebot.melee_reach = v end,
		})

		spRGroup:AddToggle("rb_vary_position", {
			Text = "vary position",
			Default = true,
			Callback = function(v) phonk.ragebot.vary_position = v end,
		})

		spRGroup:AddSlider("rb_vary_amount", {
			Text = "vary amount",
			Default = 6,
			Min = 0,
			Max = 30,
			Rounding = 0,
			Suffix = " studs",
			Callback = function(v) phonk.ragebot.vary_amount = v end,
		})

		spRGroup:AddSlider("rb_move_spot_every", {
			Text = "move spot every",
			Default = 600,
			Min = 100,
			Max = 5000,
			Rounding = 0,
			Suffix = " ms",
			Callback = function(v) phonk.ragebot.move_spot_every = v end,
		})

		spRGroup:AddToggle("rb_avoid_riot_shields", {
			Text = "avoid riot shields",
			Default = false,
			Callback = function(v) phonk.ragebot.avoid_riot_shields = v end,
		})

		spRGroup:AddSlider("rb_shield_cone", {
			Text = "shield cone",
			Default = 80,
			Min = 0,
			Max = 180,
			Rounding = 0,
			Suffix = " deg",
			Callback = function(v) phonk.ragebot.shield_cone = v end,
		})

		spRGroup:AddSlider("rb_back_shield_cone", {
			Text = "back shield cone",
			Default = 60,
			Min = 0,
			Max = 180,
			Rounding = 0,
			Suffix = " deg",
			Callback = function(v) phonk.ragebot.back_shield_cone = v end,
		})
	end

	local targeting = tbl2.Combat:AddLeftGroupbox("targeting")

	targeting:AddDropdown("tgt_part", {
		Text = "target part",
		Values = { "Head", "HumanoidRootPart", "UpperTorso" },
		Default = "Head",
		Callback = function(part)
			phonk.targeting.part = part
		end,
	})

	targeting:AddSlider("tgt_maxdist", {
		Text = "max distance",
		Default = 800,
		Min = 50,
		Max = 3000,
		Rounding = 0,
		Callback = function(maxDistance)
			phonk.targeting.max_distance = maxDistance
		end,
	})

	targeting:AddToggle("tgt_visible", {
		Text = "visible only",
		Default = false,
		Callback = function(visibleOnly)
			phonk.targeting.visible_only = visibleOnly
		end,
	})

	targeting:AddToggle("tgt_riot", {
		Text = "ignore riot shield",
		Default = false,
		Callback = function(riotShield)
			phonk.targeting.riot_shield = riotShield
		end,
	})

	targeting:AddToggle("tgt_anti_katana", {
		Text = "anti katana",
		Default = false,
		Callback = function(antiKatana)
			phonk.targeting.anti_katana = antiKatana
		end,
	})

	s32_2 = tbl2.Combat:AddRightGroupbox("silent aim")

	s32_2:AddToggle("silent_aim_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.silent_aim.enable = enable
		end,
	}):AddKeyPicker("silent_aim_key", { Default = "C", Text = "silent aim", Mode = "Toggle", SyncToggleState = false })

	s32_2:AddDropdown("silent_aim_part", {
		Text = "hit part",
		Values = { "Head", "HumanoidRootPart", "UpperTorso" },
		Default = "Head",
		Callback = function(hitPart)
			phonk.silent_aim.hit_part = hitPart
		end,
	})

	s32_2:AddToggle("silent_aim_fov_show", {
		Text = "show fov",
		Default = true,
		Callback = function(showFov)
			phonk.silent_aim.show_fov = showFov
		end,
	}):AddColorPicker("silent_aim_fov_color", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(fovColor)
			phonk.silent_aim.fov_color = fovColor
		end,
	})

	s32_2:AddSlider("silent_aim_fov", {
		Text = "fov radius",
		Default = 300,
		Min = 20,
		Max = 800,
		Rounding = 0,
		Callback = function(fovRadius)
			phonk.silent_aim.fov_radius = fovRadius
		end,
	})

	s32_3 = tbl2.Combat:AddLeftGroupbox("aimbot")

	s32_3:AddToggle("aim_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.aimbot.enable = enable
		end,
	}):AddKeyPicker("aim_key", { Default = "E", Text = "aimbot", Mode = "Hold", SyncToggleState = false })

	s32_3:AddToggle("aim_show_fov", {
		Text = "show fov",
		Default = true,
		Callback = function(showFov)
			phonk.aimbot.show_fov = showFov
		end,
	}):AddColorPicker("aim_fov_color", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(fovColor)
			phonk.aimbot.fov_color = fovColor
		end,
	})

	s32_3:AddSlider("aim_fov", {
		Text = "fov radius",
		Default = 180,
		Min = 20,
		Max = 800,
		Rounding = 0,
		Callback = function(fovRadius)
			phonk.aimbot.fov_radius = fovRadius
		end,
	})

	s32_3:AddSlider("aim_smooth", {
		Text = "smoothing",
		Default = 1,
		Min = 1,
		Max = 100,
		Rounding = 0,
		Callback = function(smoothing)
			phonk.aimbot.smoothing = smoothing
		end,
	})

	s32_3:AddToggle("aim_closest_part", {
		Text = "closest part",
		Default = false,
		Callback = function(closestPart)
			phonk.aimbot.closest_part = closestPart
		end,
	})

	s1_14 = tbl2.Combat:AddRightGroupbox("triggerbot")

	s1_14:AddToggle("trg_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.triggerbot.enable = enable
		end,
	})

	s1_14:AddToggle("trg_team", {
		Text = "team check",
		Default = true,
		Callback = function(teamCheck)
			phonk.triggerbot.team_check = teamCheck
		end,
	})

	s1_14:AddSlider("trg_react", {
		Text = "reaction time",
		Default = 0.05,
		Min = 0,
		Max = 0.5,
		Rounding = 2,
		Callback = function(reactionTime)
			phonk.triggerbot.reaction_time = reactionTime
		end,
	})

	s1_14:AddSlider("trg_delay", {
		Text = "shoot delay",
		Default = 0.1,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(shootDelay)
			phonk.triggerbot.shoot_delay = shootDelay
		end,
	})

	s1_14:AddSlider("trg_dist", {
		Text = "max distance",
		Default = 500,
		Min = 50,
		Max = 2500,
		Rounding = 0,
		Callback = function(maxDistance)
			phonk.triggerbot.max_distance = maxDistance
		end,
	})

	s32_4 = tbl2.Combat:AddRightGroupbox("esp")

	s32_4:AddToggle("esp_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.esp.enable = enable

			if not enable and getgenv().phonk_clear_esp then
				getgenv().phonk_clear_esp()
			end
		end,
	})

	s32_4:AddToggle("esp_team", {
		Text = "team check",
		Default = true,
		Callback = function(teamCheck)
			phonk.esp.team_check = teamCheck
		end,
	})

	s32_4:AddToggle("esp_hl", {
		Text = "highlight",
		Default = true,
		Callback = function(enable)
			phonk.esp.highlight.enable = enable
		end,
	}):AddColorPicker("esp_hl_fill", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(fillColor)
			phonk.esp.highlight.fill_color = fillColor
		end,
	})

	s32_4:AddSlider("esp_hl_ft", {
		Text = "fill transparency",
		Default = 0.45,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(fillTransparency)
			phonk.esp.highlight.fill_transparency = fillTransparency
		end,
	})

	s32_4:AddLabel("outline"):AddColorPicker("esp_hl_out", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(outlineColor)
			phonk.esp.highlight.outline_color = outlineColor
		end,
	})

	s32_4:AddToggle("esp_box", {
		Text = "box",
		Default = true,
		Callback = function(enable)
			phonk.esp.box.enable = enable
		end,
	}):AddColorPicker("esp_box_c", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(color)
			phonk.esp.box.color = color
		end,
	})

	s32_4:AddToggle("esp_name", {
		Text = "name",
		Default = true,
		Callback = function(enable)
			phonk.esp.name.enable = enable
		end,
	}):AddColorPicker("esp_name_c", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			phonk.esp.name.color = color
		end,
	})

	s32_4:AddToggle("esp_hp", {
		Text = "health",
		Default = true,
		Callback = function(enable)
			phonk.esp.health.enable = enable
		end,
	}):AddColorPicker("esp_hp_c", {
		Default = Color3.fromRGB(80, 220, 80),
		Callback = function(color)
			phonk.esp.health.color = color
		end,
	})

	s32_4:AddToggle("esp_dist", {
		Text = "distance",
		Default = true,
		Callback = function(enable)
			phonk.esp.distance.enable = enable
		end,
	}):AddColorPicker("esp_dist_c", {
		Default = Color3.fromRGB(200, 200, 200),
		Callback = function(color)
			phonk.esp.distance.color = color
		end,
	})

	s32_4:AddToggle("esp_tracer", {
		Text = "tracer",
		Default = false,
		Callback = function(enable)
			phonk.esp.tracer.enable = enable
		end,
	}):AddColorPicker("esp_tracer_c", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(color)
			phonk.esp.tracer.color = color
		end,
	})

	s32_4:AddDropdown("esp_tracer_o", {
		Text = "tracer origin",
		Values = { "bottom", "center", "mouse" },
		Default = "bottom",
		Callback = function(origin)
			phonk.esp.tracer.origin = origin
		end,
	})

	s32_4:AddToggle("esp_chams", {
		Text = "chams",
		Default = false,
		Callback = function(enable)
			phonk.esp.chams.enable = enable
		end,
	}):AddColorPicker("esp_chams_c", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(color)
			phonk.esp.chams.color = color
		end,
	})

	s32_4:AddDropdown("esp_chams_mat", {
		Text = "chams material",
		Values = { "Neon", "ForceField", "Glass", "Metal", "Ice", "Plastic" },
		Default = "Neon",
		Callback = function(material)
			phonk.esp.chams.material = material
		end,
	})

	s32_4:AddToggle("esp_chams_ghost", {
		Text = "ghost chams",
		Default = false,
		Callback = function(ghost)
			phonk.esp.chams.ghost = ghost
		end,
	})

	s32_4:AddToggle("esp_chams_strip", {
		Text = "strip textures",
		Default = false,
		Callback = function(stripTextures)
			phonk.esp.chams.strip_textures = stripTextures
		end,
	})

	s32_4:AddToggle("esp_skeleton", {
		Text = "skeleton",
		Default = false,
		Callback = function(enable)
			phonk.esp.skeleton.enable = enable
		end,
	}):AddColorPicker("esp_skeleton_c", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			phonk.esp.skeleton.color = color
		end,
	})

	s32_4:AddToggle("esp_head_circle", {
		Text = "head circle",
		Default = false,
		Callback = function(enable)
			phonk.esp.head_circle.enable = enable
		end,
	}):AddColorPicker("esp_head_circle_c", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			phonk.esp.head_circle.color = color
		end,
	})

	s32_4:AddToggle("esp_weapon_label", {
		Text = "weapon label",
		Default = false,
		Callback = function(enable)
			phonk.esp.weapon.enable = enable
		end,
	}):AddColorPicker("esp_weapon_c", {
		Default = Color3.fromRGB(200, 200, 200),
		Callback = function(color)
			phonk.esp.weapon.color = color
		end,
	})

	s32_4:AddToggle("esp_offscreen", {
		Text = "off-screen arrows",
		Default = false,
		Callback = function(enable)
			phonk.esp.offscreen_arrows.enable = enable
		end,
	}):AddColorPicker("esp_offscreen_c", {
		Default = Color3.fromRGB(196, 30, 58),
		Callback = function(color)
			phonk.esp.offscreen_arrows.color = color
		end,
	})

	s32_4:AddSlider("esp_offscreen_radius", {
		Text = "arrow screen radius",
		Default = 100,
		Min = 50,
		Max = 400,
		Rounding = 0,
		Callback = function(r)
			phonk.esp.offscreen_arrows.radius = r
		end,
	})

	s32_4:AddToggle("esp_movement_trail", {
		Text = "movement trail",
		Default = false,
		Callback = function(enable)
			phonk.esp.movement_trail.enable = enable
		end,
	}):AddColorPicker("esp_trail_c", {
		Default = Color3.fromRGB(100, 200, 255),
		Callback = function(color)
			phonk.esp.movement_trail.color = color
		end,
	})

	s32_4:AddToggle("esp_movement_pred", {
		Text = "movement prediction",
		Default = false,
		Callback = function(enable)
			phonk.esp.movement_prediction.enable = enable
		end,
	}):AddColorPicker("esp_pred_c", {
		Default = Color3.fromRGB(255, 200, 0),
		Callback = function(color)
			phonk.esp.movement_prediction.color = color
		end,
	})

	-- ── ESP PREVIEW ──────────────────────────────────────────────
	do
		local espPreviewGui = nil
		local espPreviewVisible = false
		local espPreviewConn = nil

		-- Helper: add a fake ESP overlay BillboardGui on a character clone inside the viewport
		local function addFakeEspOverlays(viewportFrame, charClone)
			pcall(function()
				local hrp = charClone:FindFirstChild("HumanoidRootPart")
				local head = charClone:FindFirstChild("Head")
				if not hrp then return end
				local esp = phonk and phonk.esp

				-- Name label over head
				if esp and esp.name and esp.name.enable and head then
					local bb = Instance.new("BillboardGui")
					bb.Name = "ESPName"
					bb.Size = UDim2.new(0, 80, 0, 20)
					bb.StudsOffset = Vector3.new(0, 2.5, 0)
					bb.AlwaysOnTop = true
					bb.Adornee = head
					bb.Parent = charClone
					local lbl = Instance.new("TextLabel", bb)
					lbl.Size = UDim2.new(1,0,1,0)
					lbl.BackgroundTransparency = 1
					lbl.Text = "XEVXCVXCVXCV"
					lbl.TextColor3 = esp.name.color or Color3.fromRGB(255,255,255)
					lbl.Font = Enum.Font.GothamBold
					lbl.TextSize = 10
					lbl.TextStrokeTransparency = 0
					lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
				end

				-- Distance label under feet
				if esp and esp.distance and esp.distance.enable then
					local lowerTorso = charClone:FindFirstChild("LowerTorso") or hrp
					local bb2 = Instance.new("BillboardGui")
					bb2.Name = "ESPDist"
					bb2.Size = UDim2.new(0, 60, 0, 16)
					bb2.StudsOffset = Vector3.new(0, -3.5, 0)
					bb2.AlwaysOnTop = true
					bb2.Adornee = lowerTorso
					bb2.Parent = charClone
					local lbl2 = Instance.new("TextLabel", bb2)
					lbl2.Size = UDim2.new(1,0,1,0)
					lbl2.BackgroundTransparency = 1
					lbl2.Text = "0m"
					lbl2.TextColor3 = esp.distance.color or Color3.fromRGB(255,255,255)
					lbl2.Font = Enum.Font.GothamMedium
					lbl2.TextSize = 9
					lbl2.TextStrokeTransparency = 0
					lbl2.TextStrokeColor3 = Color3.fromRGB(0,0,0)
				end

				-- Weapon label
				if esp and esp.weapon and esp.weapon.enable then
					local bb3 = Instance.new("BillboardGui")
					bb3.Name = "ESPWeapon"
					bb3.Size = UDim2.new(0, 80, 0, 14)
					bb3.StudsOffset = Vector3.new(0, -4.5, 0)
					bb3.AlwaysOnTop = true
					bb3.Adornee = hrp
					bb3.Parent = charClone
					local lbl3 = Instance.new("TextLabel", bb3)
					lbl3.Size = UDim2.new(1,0,1,0)
					lbl3.BackgroundTransparency = 1
					lbl3.Text = "Weapon"
					lbl3.TextColor3 = esp.weapon.color or Color3.fromRGB(255,255,255)
					lbl3.Font = Enum.Font.GothamMedium
					lbl3.TextSize = 9
					lbl3.TextStrokeTransparency = 0
					lbl3.TextStrokeColor3 = Color3.fromRGB(0,0,0)
				end

				-- Box (drawn as a SelectionBox inside viewport)
				if esp and esp.box and esp.box.enable then
					local sb = Instance.new("SelectionBox")
					sb.Adornee = charClone
					sb.SurfaceTransparency = 1
					sb.Color3 = esp.box.color or Color3.fromRGB(255,255,255)
					sb.LineThickness = 0.03
					sb.Parent = viewportFrame
				end

				-- Health bar (green bar Frame at the side)
				if esp and esp.health and esp.health.enable and head then
					local bb4 = Instance.new("BillboardGui")
					bb4.Name = "ESPHealth"
					bb4.Size = UDim2.new(0, 6, 0, 55)
					bb4.StudsOffset = Vector3.new(-1.3, -0.5, 0)
					bb4.AlwaysOnTop = true
					bb4.Adornee = hrp
					bb4.Parent = charClone
					local bg = Instance.new("Frame", bb4)
					bg.Size = UDim2.new(1,0,1,0)
					bg.BackgroundColor3 = Color3.fromRGB(20,20,20)
					bg.BorderSizePixel = 0
					local bar = Instance.new("Frame", bg)
					bar.Size = UDim2.new(1,0,0.75,0)
					bar.AnchorPoint = Vector2.new(0,1)
					bar.Position = UDim2.new(0,0,1,0)
					bar.BackgroundColor3 = esp.health.color or Color3.fromRGB(0,200,80)
					bar.BorderSizePixel = 0
				end

				-- Chams: make the clone's parts colored/neon
				if esp and esp.chams and esp.chams.enable then
					for _, part in ipairs(charClone:GetDescendants()) do
						if part:IsA("BasePart") then
							pcall(function()
								part.Color = esp.chams.color or Color3.fromRGB(196,30,58)
								part.Material = Enum.Material.Neon
								if esp.chams.ghost then part.Transparency = 0.55 end
							end)
						end
					end
				end

				-- Highlight
				if esp and esp.highlight and esp.highlight.enable then
					local hl = Instance.new("SelectionHighlight") or Instance.new("Highlight")
					if hl then
						pcall(function()
							hl.Adornee = charClone
							hl.FillColor = esp.highlight.fill_color or Color3.fromRGB(255,255,255)
							hl.FillTransparency = esp.highlight.fill_transparency or 0.5
							hl.OutlineColor = esp.highlight.outline_color or Color3.fromRGB(255,255,255)
							hl.OutlineTransparency = esp.highlight.outline_transparency or 0
							hl.Parent = viewportFrame
						end)
					end
				end
			end)
		end

		local function buildEspPreview()
			if espPreviewGui then pcall(function() espPreviewGui:Destroy() end) end
			if espPreviewConn then pcall(function() espPreviewConn:Disconnect() end) end

			local gui = Instance.new("ScreenGui")
			gui.Name = "PhonkWareEspPreview"
			gui.ResetOnSpawn = false
			gui.IgnoreGuiInset = true
			gui.DisplayOrder = 200
			pcall(function()
				gui.Parent = gethui and gethui() or game:GetService("CoreGui")
			end)
			if not gui.Parent then
				pcall(function() gui.Parent = game:GetService("Players").LocalPlayer:FindFirstChildOfClass("PlayerGui") end)
			end

			local frame = Instance.new("Frame")
			frame.Name = "ESPPreview"
			frame.Size = UDim2.fromOffset(190, 270)
			frame.Position = UDim2.new(0, 8, 0.5, -135)
			frame.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
			frame.BackgroundTransparency = 0.1
			frame.BorderSizePixel = 0
			frame.Active = true
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(196, 30, 58)
			stroke.Thickness = 1.5
			stroke.Parent = frame
			frame.Parent = gui

			local titleLabel = Instance.new("TextLabel")
			titleLabel.Size = UDim2.new(1, 0, 0, 20)
			titleLabel.BackgroundTransparency = 1
			titleLabel.Font = Enum.Font.GothamBold
			titleLabel.TextSize = 12
			titleLabel.Text = "ESP Preview"
			titleLabel.TextColor3 = Color3.fromRGB(196, 30, 58)
			titleLabel.Parent = frame

			-- Viewport
			local viewportFrame = Instance.new("ViewportFrame")
			viewportFrame.Size = UDim2.new(1, -10, 1, -50)
			viewportFrame.Position = UDim2.fromOffset(5, 22)
			viewportFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
			viewportFrame.BackgroundTransparency = 0.2
			viewportFrame.BorderSizePixel = 0
			viewportFrame.LightDirection = Vector3.new(-1, -1, -1)
			viewportFrame.Ambient = Color3.fromRGB(180, 180, 180)
			Instance.new("UICorner", viewportFrame).CornerRadius = UDim.new(0, 6)
			viewportFrame.Parent = frame

			local charCloneRef = nil
			local vpCam = nil

			local function refreshCharacter()
				-- Remove old clone
				pcall(function()
					for _, c in ipairs(viewportFrame:GetChildren()) do
						if not c:IsA("Camera") then c:Destroy() end
					end
				end)

				pcall(function()
					local lp = game:GetService("Players").LocalPlayer
					local char = lp and lp.Character
					if not char then return end
					local hrp = char:FindFirstChild("HumanoidRootPart")
					if not hrp then return end

					local clone = char:Clone()
					-- Strip animation and scripts
					for _, d in ipairs(clone:GetDescendants()) do
						if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Animator") then
							d:Destroy()
						end
					end
					-- Pose the clone upright at origin
					local cloneHrp = clone:FindFirstChild("HumanoidRootPart")
					if cloneHrp then
						cloneHrp.CFrame = CFrame.new(0, 0, 0)
						cloneHrp.AssemblyLinearVelocity = Vector3.zero
						cloneHrp.AssemblyAngularVelocity = Vector3.zero
						cloneHrp.Anchored = true
					end
					for _, part in ipairs(clone:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Anchored = true
						end
					end
					clone.Parent = viewportFrame
					charCloneRef = clone

					-- Camera positioned to show full character
					if not vpCam then
						vpCam = Instance.new("Camera")
						vpCam.Parent = viewportFrame
						viewportFrame.CurrentCamera = vpCam
					end
					local camTarget = Vector3.new(0, 1, 0)
					vpCam.CFrame = CFrame.new(Vector3.new(0, 1, 6), camTarget)
					vpCam.FieldOfView = 35

					-- Add ESP overlays based on current settings
					addFakeEspOverlays(viewportFrame, clone)
				end)
			end

			-- Refresh on respawn
			espPreviewConn = game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
				task.wait(0.5)
				if espPreviewVisible then
					refreshCharacter()
				end
			end)

			-- Initial load
			refreshCharacter()

			-- Live update loop: re-apply overlays every 2s so toggling ESP features reflects
			task.spawn(function()
				while espPreviewGui and espPreviewGui.Parent do
					task.wait(2)
					if espPreviewVisible and charCloneRef and charCloneRef.Parent then
						pcall(function()
							-- Remove old overlays and re-apply
							for _, d in ipairs(charCloneRef:GetDescendants()) do
								if d:IsA("BillboardGui") then d:Destroy() end
							end
							for _, d in ipairs(viewportFrame:GetDescendants()) do
								if d:IsA("SelectionBox") or d:IsA("Highlight") then d:Destroy() end
							end
							addFakeEspOverlays(viewportFrame, charCloneRef)
						end)
					end
				end
			end)

			-- Positioning helper toggle
			local posHelperOn = true
			local posHelper = Instance.new("TextButton")
			posHelper.Size = UDim2.new(1, -55, 0, 18)
			posHelper.Position = UDim2.new(0, 5, 1, -22)
			posHelper.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			posHelper.BorderSizePixel = 0
			posHelper.Font = Enum.Font.GothamMedium
			posHelper.TextSize = 11
			posHelper.Text = "[x] Positioning helper"
			posHelper.TextColor3 = Color3.fromRGB(196, 30, 58)
			posHelper.TextXAlignment = Enum.TextXAlignment.Left
			Instance.new("UICorner", posHelper).CornerRadius = UDim.new(0, 4)
			posHelper.Parent = frame

			posHelper.MouseButton1Click:Connect(function()
				posHelperOn = not posHelperOn
				posHelper.Text = (posHelperOn and "[x]" or "[ ]") .. " Positioning helper"
				-- Toggle drag affordance visibility
				frame.Active = posHelperOn
			end)

			local resetBtn = Instance.new("TextButton")
			resetBtn.Size = UDim2.fromOffset(44, 18)
			resetBtn.Position = UDim2.new(1, -49, 1, -22)
			resetBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			resetBtn.BorderSizePixel = 0
			resetBtn.Font = Enum.Font.GothamMedium
			resetBtn.TextSize = 11
			resetBtn.Text = "Reset"
			resetBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
			Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 4)
			resetBtn.Parent = frame

			resetBtn.MouseButton1Click:Connect(function()
				frame.Position = UDim2.new(0, 8, 0.5, -135)
			end)

			-- Make draggable by title bar
			local dragging, dragStart, startPos = false, nil, nil
			titleLabel.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					dragStart = input.Position
					startPos = frame.Position
				end
			end)
			game:GetService("UserInputService").InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = input.Position - dragStart
					frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end)
			game:GetService("UserInputService").InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
			end)

			espPreviewGui = gui
			v2:Add(gui)
		end

		local espPreviewGroup = tbl2.Combat:AddLeftGroupbox("esp preview")
		espPreviewGroup:AddToggle("esp_preview_enable", {
			Text = "show esp preview",
			Default = false,
			Callback = function(enable)
				espPreviewVisible = enable
				if enable then
					buildEspPreview()
				else
					if espPreviewConn then pcall(function() espPreviewConn:Disconnect() end) espPreviewConn = nil end
					if espPreviewGui then
						pcall(function() espPreviewGui:Destroy() end)
						espPreviewGui = nil
					end
				end
			end,
		})

		espPreviewGroup:AddButton("refresh preview", function()
			if espPreviewVisible then
				buildEspPreview()
			end
		end)
	end

	s1_15 = tbl2.World
	s32_5 = s1_15:AddLeftGroupbox("viewmodel")

	s32_5:AddToggle("no_arm_enable", {
		Text = "no arm",
		Default = false,
		Callback = function(enable)
			phonk.no_arm.enable = enable
		end,
	})

	s32_5:AddLabel("hides viewmodel arms")
	s31_2 = s1_15:AddRightGroupbox("atmosphere")

	s12_17 = function()
		if getgenv().phonk_update_world_fx then
			getgenv().phonk_update_world_fx()
		end
	end

	s31_2:AddToggle("atm_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.world.atmosphere.enable = enable
			s12_17()
		end,
	})

	s31_2:AddSlider("atm_density", {
		Text = "density",
		Default = 0.3,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(density)
			phonk.world.atmosphere.density = density
			s12_17()
		end,
	})

	s31_2:AddSlider("atm_offset", {
		Text = "offset",
		Default = 0.25,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(offset)
			phonk.world.atmosphere.offset = offset
			s12_17()
		end,
	})

	s31_2:AddSlider("atm_glare", {
		Text = "glare",
		Default = 0.2,
		Min = 0,
		Max = 1,
		Rounding = 2,
		Callback = function(glare)
			phonk.world.atmosphere.glare = glare
			s12_17()
		end,
	})

	s31_2:AddSlider("atm_haze", {
		Text = "haze",
		Default = 1.5,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Callback = function(haze)
			phonk.world.atmosphere.haze = haze
			s12_17()
		end,
	})

	s31_2:AddLabel("color"):AddColorPicker("atm_color", {
		Default = Color3.fromRGB(140, 40, 40),
		Callback = function(color)
			phonk.world.atmosphere.color = color
			s12_17()
		end,
	})

	s31_2:AddLabel("decay"):AddColorPicker("atm_decay", {
		Default = Color3.fromRGB(80, 20, 20),
		Callback = function(decay)
			phonk.world.atmosphere.decay = decay
			s12_17()
		end,
	})

	s1_16 = s1_15:AddRightGroupbox("color correction")

	s1_16:AddToggle("cc_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.world.color_correction.enable = enable
			s12_17()
		end,
	})

	s1_16:AddSlider("cc_bright", {
		Text = "brightness",
		Default = 0.05,
		Min = -1,
		Max = 1,
		Rounding = 2,
		Callback = function(brightness)
			phonk.world.color_correction.brightness = brightness
			s12_17()
		end,
	})

	s1_16:AddSlider("cc_contrast", {
		Text = "contrast",
		Default = 0.15,
		Min = -1,
		Max = 1,
		Rounding = 2,
		Callback = function(contrast)
			phonk.world.color_correction.contrast = contrast
			s12_17()
		end,
	})

	s1_16:AddSlider("cc_sat", {
		Text = "saturation",
		Default = 0.1,
		Min = -1,
		Max = 1,
		Rounding = 2,
		Callback = function(saturation)
			phonk.world.color_correction.saturation = saturation
			s12_17()
		end,
	})

	s1_16:AddLabel("tint"):AddColorPicker("cc_tint", {
		Default = Color3.fromRGB(255, 180, 180),
		Callback = function(tint)
			phonk.world.color_correction.tint = tint
			s12_17()
		end,
	})

	s1_17 = tbl2.Optimizations
	s34 = s1_17:AddLeftGroupbox("fps boost")

	s34:AddToggle("opt_no_particles", {
		Text = "remove particles & effects",
		Default = false,
		Callback = function(noParticles)
			phonk.optimizations.no_particles = noParticles
			getgenv().phonk_apply_opt()
		end,
	})

	s34:AddToggle("opt_no_shadows", {
		Text = "disable shadows",
		Default = false,
		Callback = function(noShadows)
			phonk.optimizations.no_shadows = noShadows
			getgenv().phonk_apply_opt()
		end,
	})

	s34:AddToggle("opt_no_postfx", {
		Text = "disable post processing",
		Default = false,
		Callback = function(noPostfx)
			phonk.optimizations.no_postfx = noPostfx
			getgenv().phonk_apply_opt()
		end,
	})

	s34:AddToggle("opt_no_atmosphere", {
		Text = "disable atmosphere & clouds",
		Default = false,
		Callback = function(noAtmosphere)
			phonk.optimizations.no_atmosphere = noAtmosphere
			getgenv().phonk_apply_opt()
		end,
	})

	s34:AddToggle("opt_no_textures", {
		Text = "remove textures",
		Default = false,
		Callback = function(noTextures)
			phonk.optimizations.no_textures = noTextures
			getgenv().phonk_apply_opt()
		end,
	})

	s34:AddButton("quick boost (all)", function()
		toggles.opt_no_particles:SetValue(true)
		toggles.opt_no_shadows:SetValue(true)
		toggles.opt_no_postfx:SetValue(true)
		toggles.opt_no_atmosphere:SetValue(true)
		toggles.opt_no_textures:SetValue(true)
		library:Notify("Applied fps boost", 3)
	end)

	s1_18 = s1_17:AddRightGroupbox("frame rate")

	s1_18:AddToggle("opt_fps_cap_enable", {
		Text = "limit fps",
		Default = false,
		Callback = function(fpsCapEnable)
			phonk.optimizations.fps_cap_enable = fpsCapEnable
			getgenv().phonk_apply_opt()
		end,
	})

	s1_18:AddSlider("opt_fps_cap", {
		Text = "fps limit",
		Default = 60,
		Min = 30,
		Max = 240,
		Rounding = 0,
		Callback = function(fpsCap)
			phonk.optimizations.fps_cap = fpsCap
			getgenv().phonk_apply_opt()
		end,
	})

	s1_19 = tbl2.Character
	s35 = s1_19:AddRightGroupbox("movement")

	s35:AddToggle("walkspeed_enable", {
		Text = "walkspeed",
		Default = false,
		Callback = function(enable)
			phonk.walkspeed.enable = enable
		end,
	})

	s35:AddSlider("walkspeed_multiplier", {
		Text = "multiplier",
		Default = 1.5,
		Min = 1,
		Max = 10,
		Rounding = 2,
		Suffix = "x",
		Callback = function(multiplier)
			phonk.walkspeed.multiplier = multiplier
		end,
	})

	s35:AddToggle("slide_boost_enable", {
		Text = "slide boost",
		Default = false,
		Callback = function(enable)
			phonk.slide_boost.enable = enable
		end,
	})

	s35:AddSlider("slide_boost_speed", {
		Text = "slide speed",
		Default = 60,
		Min = 1,
		Max = 200,
		Rounding = 0,
		Callback = function(speed)
			phonk.slide_boost.speed = speed
		end,
	})

	s35:AddToggle("infinite_double_jump_enable", {
		Text = "infinite double jump",
		Default = false,
		Callback = function(enable)
			phonk.infinite_double_jump.enable = enable
		end,
	})

	s35:AddToggle("fly_enable", {
		Text = "fly",
		Default = false,
		Callback = function(enable)
			phonk.fly.enable = enable
		end,
	}):AddKeyPicker("fly_key", { Default = "V", Text = "fly", Mode = "Hold", SyncToggleState = false })

	s35:AddSlider("fly_speed", {
		Text = "fly speed",
		Default = 50,
		Min = 5,
		Max = 250,
		Rounding = 0,
		Callback = function(speed)
			phonk.fly.speed = speed
		end,
	})

	s35:AddToggle("freecam_enable", {
		Text = "freecam",
		Default = false,
		Callback = function(enable)
			phonk.freecam.enable = enable
		end,
	}):AddKeyPicker("freecam_key", { Default = "B", Text = "freecam", Mode = "Toggle", SyncToggleState = false })

	s35:AddSlider("freecam_speed", {
		Text = "freecam speed",
		Default = 20,
		Min = 1,
		Max = 100,
		Rounding = 0,
		Callback = function(speed)
			phonk.freecam.speed = speed
		end,
	})

	s34_1 = s1_19:AddLeftGroupbox("viewmodel")

	s34_1:AddToggle("viewmodel_offsets_enable", {
		Text = "override viewmodel",
		Default = false,
		Callback = function(enable)
			phonk.viewmodel_offsets.enable = enable
			options.viewmodel_offset_x:SetVisible(enable)
			options.viewmodel_offset_y:SetVisible(enable)
			options.viewmodel_offset_z:SetVisible(enable)

			if enable then
				for k, v10 in next, ItemLibrary.ViewModels, nil do
					if v10.RootPartOffset then
						oldoffsets[k] = v10.RootPartOffset
					end
				end
			else
				for k, v10 in next, ItemLibrary.ViewModels, nil do
					if oldoffsets[k] then
						v10.RootPartOffset = oldoffsets[k]
					end
				end

				oldoffsets = {}
			end
		end,
	})

	s34_1:AddSlider("viewmodel_offset_x", {
		Text = "x",
		Default = 0,
		Min = -5,
		Max = 5,
		Rounding = 2,
		Visible = false,
		Callback = function(x)
			phonk.viewmodel_offsets.x = x
		end,
	})

	s34_1:AddSlider("viewmodel_offset_y", {
		Text = "y",
		Default = 0,
		Min = -5,
		Max = 5,
		Rounding = 2,
		Visible = false,
		Callback = function(y)
			phonk.viewmodel_offsets.y = y
		end,
	})

	s34_1:AddSlider("viewmodel_offset_z", {
		Text = "z",
		Default = 0,
		Min = -5,
		Max = 5,
		Rounding = 2,
		Visible = false,
		Callback = function(z)
			phonk.viewmodel_offsets.z = z
		end,
	})

	s1_20 = s1_19:AddLeftGroupbox("emote player")

	s1_20:AddToggle("animation_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.animation.enable = enable
		end,
	})

	s1_20:AddDropdown("animation_select", {
		Text = "emote",
		Values = { "Meditate", "Orbit", "Floss", "OJ", "Kicking Feet", "Take the L", "Hype" },
		Default = "Meditate",
		Callback = function(selectAnimation)
			phonk.animation.select_animation = selectAnimation
		end,
	})

	s1_20:AddInput("animation_custom_id", {
		Text = "custom id",
		Default = "",
		Placeholder = "id..",
		Callback = function(customId)
			phonk.animation.custom_id = customId or ""
		end,
	})

	s1_20:AddSlider("animation_speed", {
		Text = "speed",
		Default = 2,
		Min = 0.1,
		Max = 10,
		Rounding = 1,
		Callback = function(speed)
			phonk.animation.speed = speed
		end,
	})

	s3_28 = tbl2.Visuals
	s2_39 = s3_28:AddLeftTabbox()
	s1_21 = s2_39:AddTab("weapon")
	s2_40 = s2_39:AddTab("arms")

	s28_5 = function(arg, arg2, arg3, text)
		local str = "vm_" .. arg2
		local viewmodelChams = phonk.viewmodel_chams

		arg:AddToggle(str .. "_chams_enable", {
			Text = arg3,
			Default = false,
			Callback = function(enable)
				viewmodelChams[arg2 .. "_chams"].enable = enable
				options[str .. "_chams_material"]:SetVisible(enable)
				options[str .. "_chams_transparency"]:SetVisible(enable)

				if text then
					options[str .. "_chams_invisible"]:SetVisible(enable)
				end
			end,
		}):AddColorPicker(str .. "_chams_color", {
			Title = "color",
			Default = Color3.fromRGB(255, 255, 255),
			Callback = function(color)
				viewmodelChams[arg2 .. "_chams"].color = color
			end,
		})

		arg:AddDropdown(str .. "_chams_material", {
			Text = "material",
			Values = { "Neon", "ForceField", "Glass", "Metal", "Ice", "Glacier", "Foil", "Plastic" },
			Default = "Neon",
			Visible = false,
			Callback = function(material)
				viewmodelChams[arg2 .. "_chams"].material = material
			end,
		})

		arg:AddSlider(str .. "_chams_transparency", {
			Text = "transparency",
			Default = 0,
			Min = 0,
			Max = 1,
			Rounding = 2,
			Visible = false,
			Callback = function(transparency)
				viewmodelChams[arg2 .. "_chams"].transparency = transparency
			end,
		})

		if text then
			arg:AddToggle(str .. "_chams_invisible", {
				Text = "invisible arms",
				Default = false,
				Visible = false,
				Callback = function(invisible)
					viewmodelChams.arm_chams.invisible = invisible
				end,
			})
		end

		local v10 = arg
		local addToggle = v10.AddToggle
		local str2 = str .. "_highlight_enable"
		local tbl4 = {}
		text = text and "arm highlight" or "weapon highlight"
		tbl4.Text = text
		tbl4.Default = false

		tbl4.Callback = function(enable)
			viewmodelChams[arg2 .. "_highlight"].enable = enable
			options[str .. "_highlight_fill"]:SetVisible(enable)
			options[str .. "_highlight_outline"]:SetVisible(enable)
		end

		addToggle(v10, str2, tbl4):AddColorPicker(str .. "_highlight_color", {
			Title = "fill color",
			Default = Color3.fromRGB(255, 255, 255),
			Callback = function(color)
				viewmodelChams[arg2 .. "_highlight"].color = color
			end,
		})

		arg:AddSlider(str .. "_highlight_fill", {
			Text = "fill transparency",
			Default = 0.5,
			Min = 0,
			Max = 1,
			Rounding = 2,
			Visible = false,
			Callback = function(transparency)
				viewmodelChams[arg2 .. "_highlight"].transparency = transparency
			end,
		})
	end

	s28_5(s1_21, "weapon", "weapon chams", false)
	s28_5(s2_40, "arm", "arm chams", true)
	s36 = s3_28:AddLeftGroupbox("disable animation")

	s36:AddToggle("disable_anims_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.disable_anims.enable = enable
		end,
	})

	s36:AddDropdown("disable_anims_select", {
		Values = {
			"bobbing",
			"landing",
			"sway",
			"equip",
			"inspect",
			"sliding",
			"shoot",
			"impulse",
			"aim",
			"sprint",
			"reload",
			"attack",
			"charge",
			"throw",
		},
		Default = {},
		Multi = true,
		Text = "types",
		Callback = function(arg)
			local select_ = {}

			for k, v10 in next, arg, nil do
				local n2 = #select_ + 1
				v10 = type(k) == "number" and v10 or k
				select_[n2] = v10
			end

			phonk.disable_anims.select = select_
		end,
	})

	s37 = s3_28:AddLeftGroupbox("sounds")

	s37:AddToggle("hitsounds_enable", {
		Text = "custom hitsound",
		Default = false,
		Callback = function(enable)
			phonk.hitsounds.enable = enable
		end,
	})

	s37:AddDropdown("hitsounds_select", {
		Text = "preset",
		Values = { "hitmarker", "fatality", "csgo", "rust", "bonk" },
		Default = "hitmarker",
		Callback = function(selected)
			phonk.hitsounds.selected = selected
		end,
	})

	s37:AddInput("hitsounds_custom_id", {
		Text = "custom ID (empty = use preset)",
		Default = "",
		Placeholder = "rbxassetid://...",
		Callback = function(customId)
			phonk.hitsounds.custom_id = customId or ""
		end,
	})

	s37:AddSlider("hitsounds_volume", {
		Text = "volume",
		Default = 1,
		Min = 0,
		Max = 5,
		Rounding = 1,
		Callback = function(volume)
			phonk.hitsounds.volume = volume
		end,
	})

	s37:AddSlider("hitsounds_pitch", {
		Text = "pitch",
		Default = 1,
		Min = 0.5,
		Max = 2,
		Rounding = 1,
		Callback = function(pitch)
			phonk.hitsounds.pitch = pitch
		end,
	})

	s38 = s3_28:AddRightGroupbox("remove")

	s38:AddToggle("remove_muzzle_enable", {
		Text = "remove muzzle flash",
		Default = false,
		Callback = function(enable)
			phonk.remove_muzzle.enable = enable
		end,
	})

	s38:AddToggle("remove_gun_sounds_enable", {
		Text = "remove gun sounds",
		Default = false,
		Callback = function(enable)
			phonk.remove_gun_sounds.enable = enable
		end,
	})

	s39 = s3_28:AddRightGroupbox("damage numbers")

	s39:AddToggle("damage_numbers_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.damage_numbers.enable = enable
		end,
	}):AddColorPicker("damage_numbers_color1", {
		Default = Color3.fromRGB(255, 80, 80),
		Callback = function(color1)
			phonk.damage_numbers.color1 = color1
		end,
	}):AddColorPicker("damage_numbers_color2", {
		Default = Color3.fromRGB(255, 200, 80),
		Callback = function(color2)
			phonk.damage_numbers.color2 = color2
		end,
	})

	s39:AddToggle("damage_numbers_remove_ingame", {
		Text = "remove vanilla",
		Default = true,
		Callback = function(removeIngame)
			phonk.damage_numbers.remove_ingame = removeIngame
		end,
	})

	s39:AddDropdown("damage_numbers_color_type", {
		Text = "color type",
		Values = { "Static", "Gradient" },
		Default = "Static",
		Callback = function(colorType)
			phonk.damage_numbers.color_type = colorType
		end,
	})

	s39:AddSlider("damage_numbers_text_size", {
		Text = "text size",
		Default = 18,
		Min = 8,
		Max = 40,
		Rounding = 0,
		Callback = function(textSize)
			phonk.damage_numbers.text_size = textSize
		end,
	})

	s39:AddSlider("damage_numbers_duration", {
		Text = "duration",
		Default = 0.8,
		Min = 0.2,
		Max = 3,
		Rounding = 1,
		Callback = function(duration)
			phonk.damage_numbers.duration = duration
		end,
	})

	s39:AddSlider("damage_numbers_rise", {
		Text = "rise",
		Default = 42,
		Min = 0,
		Max = 120,
		Rounding = 0,
		Callback = function(rise)
			phonk.damage_numbers.rise = rise
		end,
	})

	s1_22 = s3_28:AddLeftTabbox()
	s41 = s1_22:AddTab("crosshair")

	s41:AddToggle("CrosshairEnable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.crosshair.enable = enable
		end,
	}):AddColorPicker("CrosshairColor", {
		Default = Color3.fromRGB(0, 255, 170),
		Callback = function(color)
			phonk.crosshair.color = color
		end,
	})

	s41:AddDropdown("CrosshairStyle", {
		Text = "style",
		Default = "cross",
		Values = { "cross", "x", "t", "circle", "dot" },
		Callback = function(style)
			phonk.crosshair.style = style
		end,
	})

	s41:AddToggle("CrosshairLines", {
		Text = "lines",
		Default = true,
		Callback = function(lines)
			phonk.crosshair.lines = lines
		end,
	})

	s41:AddSlider("CrosshairRotation", {
		Text = "rotation",
		Default = 0,
		Min = 0,
		Max = 360,
		Rounding = 0,
		Callback = function(rotation)
			phonk.crosshair.rotation = rotation
		end,
	})

	s41:AddSlider("CrosshairLength", {
		Text = "length",
		Default = 6,
		Min = 1,
		Max = 40,
		Rounding = 0,
		Callback = function(length)
			phonk.crosshair.length = length
		end,
	})

	s41:AddSlider("CrosshairThickness", {
		Text = "thickness",
		Default = 1,
		Min = 1,
		Max = 8,
		Rounding = 0,
		Callback = function(thickness)
			phonk.crosshair.thickness = thickness
		end,
	})

	s41:AddSlider("CrosshairGap", {
		Text = "gap",
		Default = 3,
		Min = 0,
		Max = 30,
		Rounding = 0,
		Callback = function(gap)
			phonk.crosshair.gap = gap
		end,
	})

	s41:AddToggle("CrosshairOutline", {
		Text = "outline",
		Default = false,
		Callback = function(outline)
			phonk.crosshair.outline = outline
		end,
	}):AddColorPicker("CrosshairOutlineColor", {
		Default = Color3.fromRGB(0, 0, 0),
		Callback = function(outlineColor)
			phonk.crosshair.outline_color = outlineColor
		end,
	})

	s41:AddToggle("CrosshairTopLine", {
		Text = "top line",
		Default = true,
		Callback = function(topLine)
			phonk.crosshair.top_line = topLine
		end,
	})

	s41:AddToggle("CrosshairBottomLine", {
		Text = "bottom line",
		Default = true,
		Callback = function(bottomLine)
			phonk.crosshair.bottom_line = bottomLine
		end,
	})

	s40 = s1_22:AddTab("lines")

	s40:AddToggle("CrosshairDot", {
		Text = "dot",
		Default = false,
		Callback = function(dot)
			phonk.crosshair.dot = dot
		end,
	})

	s40:AddToggle("CrosshairLeft", {
		Text = "left line",
		Default = true,
		Callback = function(leftLine)
			phonk.crosshair.left_line = leftLine
		end,
	})

	s40:AddToggle("CrosshairRight", {
		Text = "right line",
		Default = true,
		Callback = function(rightLine)
			phonk.crosshair.right_line = rightLine
		end,
	})

	s39_1 = s1_22:AddTab("effects")

	s39_1:AddToggle("CrosshairRotating", {
		Text = "rotating",
		Default = false,
		Callback = function(rotating)
			phonk.crosshair.rotating = rotating
		end,
	})

	s39_1:AddSlider("CrosshairRotatingSpeed", {
		Text = "speed",
		Default = 120,
		Min = 0,
		Max = 720,
		Rounding = 0,
		Suffix = "°/s",
		Callback = function(rotatingSpeed)
			phonk.crosshair.rotating_speed = rotatingSpeed
		end,
	})

	s39_1:AddToggle("CrosshairSpread", {
		Text = "spread",
		Default = false,
		Callback = function(spread)
			phonk.crosshair.spread = spread
		end,
	})

	s39_1:AddSlider("CrosshairSpreadScale", {
		Text = "spread scale",
		Default = 1,
		Min = 0,
		Max = 4,
		Rounding = 2,
		Callback = function(spreadScale)
			phonk.crosshair.spread_scale = spreadScale
		end,
	})

	s39_1:AddToggle("CrosshairAnimation", {
		Text = "animation",
		Default = false,
		Callback = function(animation)
			phonk.crosshair.animation = animation
		end,
	})

	s39_1:AddDropdown("CrosshairAnimationMode", {
		Text = "mode",
		Default = "pulse",
		Values = { "pulse", "breathe" },
		Callback = function(animationMode)
			phonk.crosshair.animation_mode = animationMode
		end,
	})

	s39_1:AddSlider("CrosshairAnimationSpeed", {
		Text = "speed",
		Default = 3,
		Min = 0.1,
		Max = 12,
		Rounding = 1,
		Callback = function(animationSpeed)
			phonk.crosshair.animation_speed = animationSpeed
		end,
	})

	s39_1:AddToggle("CrosshairFade", {
		Text = "fade color",
		Default = false,
		Callback = function(fade)
			phonk.crosshair.fade = fade
		end,
	}):AddColorPicker("CrosshairFadeColor", {
		Default = Color3.fromRGB(255, 0, 170),
		Callback = function(fadeColor)
			phonk.crosshair.fade_color = fadeColor
		end,
	})

	s39_1:AddToggle("CrosshairFollowTarget", {
		Text = "follow target",
		Default = false,
		Callback = function(followTarget)
			phonk.crosshair.follow_target = followTarget
		end,
	})

	s39_1:AddDropdown("CrosshairFollowSource", {
		Text = "follow source",
		Default = "target",
		Values = { "target", "gunpoint" },
		Callback = function(followSource)
			phonk.crosshair.follow_source = followSource
		end,
	})

	s39_1:AddToggle("CrosshairShimmer", {
		Text = "shimmer",
		Default = false,
		Callback = function(shimmer)
			phonk.crosshair.shimmer = shimmer
		end,
	})

	s39_1:AddSlider("CrosshairShimmerSpeed", {
		Text = "shimmer speed",
		Default = 4,
		Min = 0.1,
		Max = 12,
		Rounding = 1,
		Callback = function(shimmerSpeed)
			phonk.crosshair.shimmer_speed = shimmerSpeed
		end,
	})

	s1_23 = s1_22:AddTab("text")

	s1_23:AddToggle("CrosshairTextEnable", {
		Text = "enabled",
		Default = false,
		Callback = function(textEnable)
			phonk.crosshair.text_enable = textEnable
		end,
	}):AddColorPicker("CrosshairTextColor", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(textColor)
			phonk.crosshair.text_color = textColor
		end,
	})

	s1_23:AddInput("CrosshairTextContent", {
		Text = "content",
		Default = "PhonkWare",
		ClearTextOnFocus = false,
		Callback = function(textContent)
			phonk.crosshair.text_content = textContent
		end,
	})

	pcall(function()
		local crosshairTextContent = options.CrosshairTextContent

		if crosshairTextContent then
			if crosshairTextContent.SetValue then
				crosshairTextContent:SetValue("PhonkWare")
			end

			if crosshairTextContent.Value ~= nil then
				crosshairTextContent.Value = "PhonkWare"
			end
		end

		phonk.crosshair.text_content = "PhonkWare"
	end)

	s1_23:AddDropdown("CrosshairTextFont", {
		Text = "font",
		Default = "Plex",
		Values = { "UI", "System", "Plex", "Monospace", "Inconsolata" },
		Callback = function(textFont)
			phonk.crosshair.text_font = textFont
		end,
	})

	s1_23:AddSlider("CrosshairTextSize", {
		Text = "size",
		Default = 16,
		Min = 8,
		Max = 48,
		Rounding = 0,
		Callback = function(textSize)
			phonk.crosshair.text_size = textSize
		end,
	})

	s1_23:AddSlider("CrosshairTextOffset", {
		Text = "offset",
		Default = 18,
		Min = 0,
		Max = 120,
		Rounding = 0,
		Callback = function(textOffset)
			phonk.crosshair.text_offset = textOffset
		end,
	})

	s1_23:AddToggle("CrosshairTextOutline", {
		Text = "outline",
		Default = true,
		Callback = function(textOutline)
			phonk.crosshair.text_outline = textOutline
		end,
	})

	s1_23:AddToggle("CrosshairTextAnimation", {
		Text = "animation",
		Default = false,
		Callback = function(textAnimation)
			phonk.crosshair.text_animation = textAnimation
		end,
	})

	s1_24 = tbl2.World
	s45 = s1_24:AddRightGroupbox("map textures")

	s45:AddToggle("map_textures_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.map_textures.enable = enable
			getgenv().phonk_update_textures()
		end,
	}):AddColorPicker("map_textures_color", {
		Title = "color",
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			phonk.map_textures.color = color

			if phonk.map_textures.enable then
				getgenv().phonk_update_textures()
			end
		end,
	})

	s45:AddDropdown("map_textures_material", {
		Text = "material",
		Values = {
			"Neon",
			"ForceField",
			"Glass",
			"Metal",
			"Ice",
			"Glacier",
			"Foil",
			"Plastic",
			"Marble",
			"Granite",
			"Slate",
		},
		Default = "Neon",
		Callback = function(material)
			phonk.map_textures.material = material

			if phonk.map_textures.enable then
				getgenv().phonk_update_textures()
			end
		end,
	})

	s44 = s1_24:AddLeftGroupbox("camera")

	s44:AddToggle("third_person_enable", {
		Text = "third person",
		Default = false,
		Callback = function(enable)
			phonk.world.third_person.enable = enable

			pcall(function()
				if CameraController.SetThirdPersonOverride then
					CameraController:SetThirdPersonOverride(enable)
				end
			end)
		end,
	})

	s44:AddToggle("stretched_res_enable", {
		Text = "stretched res",
		Default = false,
		Callback = function(enable)
			phonk.world.stretched_res.enable = enable
		end,
	})

	s44:AddSlider("stretched_res_amount", {
		Text = "amount",
		Default = 0.2,
		Min = 0.1,
		Max = 1,
		Rounding = 2,
		Callback = function(amount)
			phonk.world.stretched_res.amount = amount
		end,
	})

	s44:AddToggle("fov_changer_enable", {
		Text = "fov changer",
		Default = false,
		Callback = function(enable)
			phonk.world.fov_changer.enable = enable
		end,
	})

	s44:AddSlider("fov_changer_fov", {
		Text = "fov",
		Default = 80,
		Min = 10,
		Max = 140,
		Rounding = 2,
		Callback = function(fov)
			phonk.world.fov_changer.fov = fov
		end,
	})

s43 = s1_24:AddLeftGroupbox("weather")

	s43:AddToggle("weather_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.world.weather.enable = enable

			if getgenv().phonk_update_weather then
				getgenv().phonk_update_weather()
			end
		end,
	}):AddColorPicker("weather_color", {
		Default = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			phonk.world.weather.color = color

			if getgenv().phonk_update_weather then
				getgenv().phonk_update_weather()
			end
		end,
	})

	s43:AddDropdown("weather_type", {
		Text = "type",
		Values = { "snow", "rain", "light rain" },
		Default = "snow",
		Callback = function(type_)
			phonk.world.weather.type = type_

			if getgenv().phonk_update_weather then
				getgenv().phonk_update_weather()
			end
		end,
	})

	s43:AddSlider("weather_rate", {
		Text = "rate",
		Default = 100,
		Min = 1,
		Max = 400,
		Rounding = 0,
		Callback = function(rate)
			phonk.world.weather.rate = rate

			if getgenv().phonk_update_weather then
				getgenv().phonk_update_weather()
			end
		end,
	})

	s1_25 = s1_24:AddLeftGroupbox("skybox")

	s1_25:AddToggle("skybox_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.world.skybox.enable = enable
			getgenv().phonk_update_sky()
		end,
	})

	s1_25:AddDropdown("skybox_selected", {
		Values = {
			"Deep Space",
			"Purple Nebula",
			"Vaporwave",
			"Night",
			"Space",
			"Minecraft",
			"Sunset",
			"Default",
		},
		Default = "Deep Space",
		Text = "skybox",
		Callback = function(selected)
			phonk.world.skybox.selected = selected
			getgenv().phonk_update_sky()
		end,
	})

	s1_25:AddToggle("skybox_rotate", {
		Text = "rotate",
		Default = false,
		Callback = function(rotate)
			phonk.world.skybox.rotate = rotate
		end,
	})

	s1_25:AddSlider("skybox_rotate_speed", {
		Text = "rotate speed",
		Default = 1,
		Min = 0,
		Max = 100,
		Rounding = 1,
		Callback = function(rotateSpeed)
			phonk.world.skybox.rotate_speed = rotateSpeed
		end,
	})

	s1_25:AddDropdown("skybox_rotate_direction", {
		Text = "direction",
		Values = { "Horizontal", "Vertical", "Diagonal" },
		Default = "Horizontal",
		Callback = function(rotateDirection)
			phonk.world.skybox.rotate_direction = rotateDirection
		end,
	})

	s1_25:AddDropdown("skybox_rotate_method", {
		Text = "method",
		Values = { "Spin", "Wave", "Alternate" },
		Default = "Spin",
		Callback = function(rotateMethod)
			phonk.world.skybox.rotate_method = rotateMethod
		end,
	})

	s1_25:AddToggle("skybox_remove_sun", {
		Text = "remove sun",
		Default = false,
		Callback = function(removeSun)
			phonk.world.skybox.remove_sun = removeSun
			getgenv().phonk_update_sky()
		end,
	})

	s1_25:AddToggle("skybox_remove_moon", {
		Text = "remove moon",
		Default = false,
		Callback = function(removeMoon)
			phonk.world.skybox.remove_moon = removeMoon
			getgenv().phonk_update_sky()
		end,
	})

	s1_25:AddToggle("skybox_remove_stars", {
		Text = "remove stars",
		Default = false,
		Callback = function(removeStars)
			phonk.world.skybox.remove_stars = removeStars
			getgenv().phonk_update_sky()
		end,
	})

	s2_41 = v4
	s3_29 = {}

	s41_1 = {
		"LeftArm",
		"RightArm",
		"LeftUpperArm",
		"RightUpperArm",
		"LeftLowerArm",
		"RightLowerArm",
		"LeftHand",
		"RightHand",
	}

	s1_26 = function()
		phonk.char_spoof = phonk.char_spoof or { enable = false, selected = "", saved = {}, last_id = nil }

		if isfile and isfile("phonkware/char_spoof.json") then
			pcall(function()
				local json = readfile("phonkware/char_spoof.json")
				local data = game:GetService("HttpService"):JSONDecode(json)

				if type(data) == "table" then
					phonk.char_spoof.saved = data.saved or data or {}
				end
			end)
		end

		if type(phonk.char_spoof.saved) ~= "table" then
			phonk.char_spoof.saved = {}
		end
	end

	s456 = function()
		pcall(function()
			if not isfolder then
				return
			end

			if isfolder and not isfolder("phonkware") then
				makefolder("phonkware")
			end

			if writefile then
				writefile("phonkware/char_spoof.json", game:GetService("HttpService"):JSONEncode({ saved = phonk.char_spoof.saved }))
			end
		end)
	end

	s457 = function()
		local tbl4 = {}
		local v10 = ipairs
		local saved = phonk.char_spoof.saved or {}

		for _, v11 in v10(saved) do
			if v11 and v11.name then
				table.insert(tbl4, tostring(v11.name))
			end
		end

		return tbl4
	end

	s458 = function(arg)
		local v10 = ipairs
		local saved = phonk.char_spoof.saved or {}

		for _, v11 in v10(saved) do
			if v11 and tostring(v11.name) == tostring(arg) then
				return v11
			end
		end

		return nil
	end

	s459 = function(arg)
		local num = tonumber(arg)
		local v10 = ipairs
		local saved = phonk.char_spoof.saved or {}

		for _, v11 in v10(saved) do
			if v11 and tonumber(v11.id) == num then
				return v11
			end
		end

		return nil
	end

	s460 = function(arg)
		local num = tonumber(arg)
		if not num then
			return nil
		end
		local nameFromUserIdAsync = nil

		pcall(function()
			nameFromUserIdAsync = s2_41:GetNameFromUserIdAsync(num)
		end)

		return nameFromUserIdAsync
	end

	s461 = function(arg)
		local num = tonumber(arg)
		if not num then
			return nil
		end

		if s3_29[num] then
			return s3_29[num]
		end

		local ok, result = pcall(function()
			return s2_41:GetCharacterAppearanceAsync(num)
		end)

		if ok and result then
			s3_29[num] = result
			return result
		end
		return nil
	end

	s462 = function(arg)
		if not arg then
			return
		end

		for _, child in ipairs(arg:GetChildren()) do
			if child:IsA("Accessory") then
				local handle = child:FindFirstChild("Handle")

				if handle then
					local attachment = handle:FindFirstChildOfClass("Attachment")

					if attachment then
						local name = attachment.Name

						if string.find(name, "Hair") or string.find(name, "hair") then
							handle.Transparency = 1

							for _, descendant in ipairs(handle:GetDescendants()) do
								if descendant:IsA("BasePart") or descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("MeshPart") then
									pcall(function()
										descendant.Transparency = 1
									end)
								end
							end

							local specialMesh = handle:FindFirstChildOfClass("SpecialMesh")

							if specialMesh then
								pcall(function()
									specialMesh.Scale = Vector3.zero
								end)
							end
						end
					end
				end
			end
		end
	end

	s463 = function(arg, arg2)
		for _, v10 in ipairs(s41_1) do
			local v11 = arg2:FindFirstChild(v10)
			local v12 = arg:FindFirstChild(v10)

			if v11 and v12 and v11:IsA("BasePart") and v12:IsA("BasePart") then
				pcall(function()
					if v12:IsA("MeshPart") and v11:IsA("MeshPart") then
						v12.MeshId = v11.MeshId
						v12.TextureID = v11.TextureID
					end

					local specialMesh = v11:FindFirstChildOfClass("SpecialMesh")

					if specialMesh then
						for _, child in ipairs(v12:GetChildren()) do
							if child:IsA("SpecialMesh") then
								child:Destroy()
							end
						end

						specialMesh:Clone().Parent = v12
					end

					v12.Color = v11.Color
					v12.Material = v11.Material
					v12.Transparency = v11.Transparency
				end)
			end
		end
	end

	s464 = function(parent, arg)
		if not parent or not arg then
			return false
		end
		local num = tonumber(arg)
		local v10 = s461(num)

		if not v10 then
			pcall(function()
				library:Notify("char spoof: invalid id / failed load", 3)
			end)

			return false
		end

		task.spawn(function()
			pcall(function()
				local clone = v10:Clone()
				local tbl4 = {}

				for _, child in ipairs(clone:GetChildren()) do
					tbl4[child.Name] = true
				end

				for _, child in pairs(parent:GetChildren()) do
					if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
						child:Destroy()
					end
				end

				for _, child in pairs(parent:GetChildren()) do
					if child:IsA("Accessory") and tbl4[child.Name] then
						child:Destroy()
					end
				end

				s462(parent)

				for _, child in pairs(clone:GetChildren()) do
					pcall(function()
						if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") or child:IsA("BodyColors") or child:IsA("CharacterMesh") then
							child.Parent = parent
						elseif child:IsA("Accessory") then
							local handle = child:FindFirstChild("Handle")

							if handle then
								handle.CanCollide = false
								handle.Transparency = 0
								local attachment = handle:FindFirstChildOfClass("Attachment")

								if attachment then
									local v11 = parent:FindFirstChild(attachment.Name, true)

									if v11 then
										local weld = Instance.new("Weld")
										weld.Part0 = handle
										weld.Part1 = v11.Parent
										weld.C0 = attachment.CFrame
										weld.C1 = v11.CFrame
										weld.Parent = handle
									end
								end

								child.Parent = parent
							end
						end
					end)
				end

				s463(parent, clone)
				task.wait(0.5)

				if parent and parent.Parent then
					s462(parent)
				end

				task.wait(0.8)

				if parent and parent.Parent then
					s462(parent)
				end
			end)
		end)

		return true
	end

	getgenv().phonk_char_spoof_apply = function(arg)
		local lastId = tonumber(arg)

		if not lastId then
			pcall(function()
				library:Notify("char spoof: enter a valid user id", 2)
			end)

			return false
		end

		local charSpoof = s460(lastId)

		if not charSpoof then
			pcall(function()
				library:Notify("char spoof: could not resolve user id", 2)
			end)

			return false
		end

		if not s461(lastId) then
			pcall(function()
				library:Notify("char spoof: failed to load appearance", 2)
			end)

			return false
		end

		if not s459(lastId) then
			table.insert(phonk.char_spoof.saved, { id = lastId, name = charSpoof })
			s456()
		end

		phonk.char_spoof.selected = charSpoof
		phonk.char_spoof.last_id = lastId
		phonk.char_spoof.enable = true

		if localPlayer2.Character then
			s464(localPlayer2.Character, lastId)
		end

		pcall(function()
			library:Notify("char spoof: " .. charSpoof, 2)
		end)

		return true, charSpoof
	end

	getgenv().phonk_char_spoof_names = s457

	getgenv().phonk_char_spoof_refresh = function()
	end

	s1_26()

	v2:Add(localPlayer2.CharacterAdded:Connect(function(character)
		task.wait(0.6)
		if not phonk.char_spoof or not phonk.char_spoof.enable then
			return
		end
		local lastId = phonk.char_spoof.last_id
		local id

		if not lastId and phonk.char_spoof.selected then
			local v10 = s458(phonk.char_spoof.selected)

			if v10 then
				id = v10.id
			else
				id = lastId
			end
		else
			id = lastId
		end

		if id then
			s464(character, id)
		end
	end))

	task.spawn(function()
		task.wait(1)

		if phonk.char_spoof and phonk.char_spoof.enable and phonk.char_spoof.last_id and localPlayer2.Character then
			s464(localPlayer2.Character, phonk.char_spoof.last_id)
		end
	end)

	s3_30 = tbl2.Misc
	s2_42 = s3_30:AddLeftTabbox()
	s1_27 = s2_42:AddTab("device spoof")

	s1_27:AddToggle("device_spoof_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.device_spoof.enable = enable
			if enable and getgenv().phonk_apply_device_spoof then
				getgenv().phonk_apply_device_spoof()
			end
		end,
	})

	s1_27:AddDropdown("device_spoof_type", {
		Text = "device type",
		Values = { "Touch", "MouseKeyboard", "Gamepad", "VR" },
		Default = 2,
		Callback = function(type_)
			phonk.device_spoof.type = type_
			if phonk.device_spoof.enable and getgenv().phonk_apply_device_spoof then
				getgenv().phonk_apply_device_spoof()
			end
		end,
	})

	s1_27:AddButton("apply spoof now", function()
		if getgenv().phonk_apply_device_spoof then
			getgenv().phonk_apply_device_spoof()
			library:Notify("device spoof applied: " .. tostring(phonk.device_spoof.type), 2)
		end
	end)

	s1_27:AddLabel("spoof: hooks GetLastInputType + sets Touch/Gamepad/VR flags")
	s1_27:AddLabel("phone = Touch | controller = Gamepad | pc = MouseKeyboard")

	s1_28 = s2_42:AddTab("sound spammer")

	s1_28:AddToggle("sound_spammer_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.sound_spammer.enable = enable
		end,
	})

	s1_28:AddDropdown("sound_spammer_type", {
		Text = "sound type",
		Values = { "DoubleJump", "Slide" },
		Default = 1,
		Callback = function(type_)
			phonk.sound_spammer.type = type_
		end,
	})

	s1_29 = s3_30:AddRightTabbox()
	s48 = s1_29:AddTab("streak")

	s48:AddToggle("streak_spoof_enable", {
		Text = "spoof",
		Default = false,
		Callback = function(enable)
			phonk.spoof.streak.enable = enable
		end,
	})

	s48:AddInput("streak_spoof_text", {
		Default = "9",
		Numeric = true,
		Text = "value",
		Callback = function(arg)
			local value = tonumber(arg)

			if value then
				phonk.spoof.streak.value = value
			end
		end,
	})

	s47 = s1_29:AddTab("level")

	s47:AddToggle("level_spoof_enable", {
		Text = "spoof",
		Default = false,
		Callback = function(enable)
			phonk.spoof.level.enable = enable
		end,
	})

	s47:AddInput("level_spoof_text", {
		Default = "9",
		Numeric = true,
		Text = "value",
		Callback = function(arg)
			local value = tonumber(arg)

			if value then
				phonk.spoof.level.value = value
			end
		end,
	})

	s46 = s1_29:AddTab("local")

	s46:AddToggle("name_spoof_local", {
		Text = "enable",
		Default = false,
		Callback = function(spoofLocal)
			phonk.profile.spoof_local = spoofLocal
		end,
	})

	s46:AddInput("name_spoof_local_value", {
		Default = "",
		Text = "username",
		Callback = function(spoofLocalName)
			phonk.profile.spoof_local_name = spoofLocalName or ""
		end,
	})

	s48_1 = s1_29:AddTab("other")

	s48_1:AddToggle("name_spoof_other", {
		Text = "enable",
		Default = false,
		Callback = function(spoofOther)
			phonk.profile.spoof_other = spoofOther
		end,
	})

	s48_1:AddInput("name_spoof_other_value", {
		Text = "username",
		Callback = function(spoofOtherName)
			phonk.profile.spoof_other_name = spoofOtherName or ""
		end,
	})

	s1_30 = s3_30:AddLeftGroupbox("character spoof")

	s1_30:AddToggle("char_spoof_enable", {
		Text = "enable",
		Default = false,
		Callback = function(enable)
			phonk.char_spoof.enable = enable
			if not enable then
				return
			end
			local selected = phonk.char_spoof.selected

			if (not selected or selected == "" or selected == "(none saved)") and options.char_spoof_saved then
				selected = options.char_spoof_saved.Value
			end

			local lastId = phonk.char_spoof.last_id

			if selected and selected ~= "" and selected ~= "(none saved)" then
				local v10 = ipairs
				local saved = phonk.char_spoof.saved or {}

				for _, v11 in v10(saved) do
					if v11 and tostring(v11.name) == tostring(selected) then
						lastId = v11.id
						phonk.char_spoof.selected = selected
						phonk.char_spoof.last_id = lastId
						break
					end
				end
			end

			if lastId then
				pcall(function()
					getgenv().phonk_char_spoof_apply(lastId)
				end)
			else
				library:Notify("select a saved player first", 2)
			end
		end,
	})

	s2_43 = function()
		local phonkCharSpoofNames = getgenv().phonk_char_spoof_names and getgenv().phonk_char_spoof_names() or {}
		if #phonkCharSpoofNames == 0 then
			return { "(none saved)" }
		end
		return phonkCharSpoofNames
	end

	s1_30:AddDropdown("char_spoof_saved", {
		Text = "saved players",
		Values = s2_43(),
		Default = 1,
		Callback = function(selected)
			if not selected or selected == "(none saved)" then
				return
			end
			phonk.char_spoof.selected = selected
			local v10 = ipairs
			local saved = phonk.char_spoof.saved or {}

			for _, v11 in v10(saved) do
				if v11 and tostring(v11.name) == tostring(selected) then
					phonk.char_spoof.last_id = v11.id
					phonk.char_spoof.enable = true

					if toggles.char_spoof_enable then
						pcall(function()
							toggles.char_spoof_enable:SetValue(true)
						end)
					end

					pcall(function()
						local id = v11.id
						getgenv().phonk_char_spoof_apply(id)
					end)

					break
				end
			end
		end,
	})

	s1_30:AddInput("char_spoof_id", {
		Text = "user id",
		Default = "",
		Numeric = true,
		Placeholder = "roblox user id",
		Callback = function()
		end,
	})

	s1_30:AddButton("add / apply", function()
		local charSpoofId = options.char_spoof_id
		local num = tonumber(charSpoofId and (charSpoofId.Value or "") or "")

		if not num then
			local selected = phonk.char_spoof.selected

			if (not selected or selected == "" or selected == "(none saved)") and options.char_spoof_saved then
				selected = options.char_spoof_saved.Value
			end

			if selected and selected ~= "" and selected ~= "(none saved)" then
				local v10 = ipairs
				local saved = phonk.char_spoof.saved or {}

				for _, v11 in v10(saved) do
					if v11 and tostring(v11.name) == tostring(selected) then
						num = tonumber(v11.id)
						break
					end
				end
			end
		end

		if not num then
			library:Notify("select a saved player or enter a user id", 2)
			return
		end
		local v10, v11 = getgenv().phonk_char_spoof_apply(num)

		if v10 and options.char_spoof_saved then
			pcall(function()
				local v12 = getgenv().phonk_char_spoof_names()

				if options.char_spoof_saved.SetValues then
					options.char_spoof_saved:SetValues(v12)
				elseif options.char_spoof_saved.Values then
					options.char_spoof_saved.Values = v12
				end

				if v11 and options.char_spoof_saved.SetValue then
					options.char_spoof_saved:SetValue(v11)
				end
			end)

			if toggles.char_spoof_enable then
				pcall(function()
					toggles.char_spoof_enable:SetValue(true)
				end)
			end
		end
	end)

	s1_30:AddButton("remove selected", function()
		local selected = phonk.char_spoof.selected
		if not selected or selected == "" then
			return
		end
		local saved = {}
		local v10 = ipairs
		local saved2 = phonk.char_spoof.saved or {}

		for _, v11 in v10(saved2) do
			if v11 and tostring(v11.name) ~= tostring(selected) then
				table.insert(saved, v11)
			end
		end

		phonk.char_spoof.saved = saved

		pcall(function()
			if writefile then
				if isfolder and not isfolder("phonkware") then
					makefolder("phonkware")
				end

				writefile("phonkware/char_spoof.json", game:GetService("HttpService"):JSONEncode({ saved = saved }))
			end
		end)

		pcall(function()
			local tbl4 = getgenv().phonk_char_spoof_names()

			if #tbl4 == 0 then
				tbl4 = { "(none saved)" }
			end

			if options.char_spoof_saved and options.char_spoof_saved.SetValues then
				options.char_spoof_saved:SetValues(tbl4)
			end
		end)

		library:Notify("removed " .. tostring(selected), 2)
	end)

	s1_30:AddLabel("id empty = apply selected from dropdown")

	-- ── AUTO COLLECT (FFA drops) ─────────────────────────────────
	do
		local acGroup = s3_30:AddRightGroupbox("auto collect (ffa)")

		phonk.auto_collect = phonk.auto_collect or {
			enable      = false,
			ammo        = true,
			health      = true,
			radius      = 20,
			only_low_hp = false,
			hp_thresh   = 60,
		}

		acGroup:AddToggle("auto_collect_enable", {
			Text = "enable",
			Default = false,
			Callback = function(v) phonk.auto_collect.enable = v end,
		})

		acGroup:AddToggle("auto_collect_ammo", {
			Text = "collect ammo drops",
			Default = true,
			Callback = function(v) phonk.auto_collect.ammo = v end,
		})

		acGroup:AddToggle("auto_collect_health", {
			Text = "collect health drops",
			Default = true,
			Callback = function(v) phonk.auto_collect.health = v end,
		})

		acGroup:AddSlider("auto_collect_radius", {
			Text    = "collect radius",
			Default = 20,
			Min     = 5,
			Max     = 100,
			Rounding = 0,
			Suffix  = " studs",
			Callback = function(v) phonk.auto_collect.radius = v end,
		})

		acGroup:AddToggle("auto_collect_only_low_hp", {
			Text = "health only when low HP",
			Default = false,
			Callback = function(v) phonk.auto_collect.only_low_hp = v end,
		})

		acGroup:AddSlider("auto_collect_hp_thresh", {
			Text    = "HP threshold",
			Default = 60,
			Min     = 1,
			Max     = 100,
			Rounding = 0,
			Suffix  = " %",
			Callback = function(v) phonk.auto_collect.hp_thresh = v end,
		})

		-- ── Logic ────────────────────────────────────────────────
		-- Rivals FFA drops live in workspace as parts/models whose
		-- name contains "Ammo" or "Health".  We teleport the
		-- character's HRP on top of them (same trick ragebot uses)
		-- which triggers the server-side touch/proximity pickup.
		v2:Add(v5.Heartbeat:Connect(function()
			local ac = phonk.auto_collect
			if not ac.enable then return end

			local lp = localPlayer2
			if not lp then return end
			local char = lp.Character
			if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then return end

			local myPos  = hrp.Position
			local radius = ac.radius

			-- figure out current HP %
			local hpPct  = hum.MaxHealth > 0
				and (hum.Health / hum.MaxHealth * 100) or 100

			for _, obj in ipairs(workspace:GetDescendants()) do
				pcall(function()
					local n = obj.Name:lower()
					local isAmmo   = n:find("ammo") or n:find("ammunition")
					local isHealth = n:find("health") or n:find("medkit") or n:find("healthpack")

					if not isAmmo and not isHealth then return end
					if isAmmo   and not ac.ammo   then return end
					if isHealth and not ac.health  then return end

					-- health threshold check
					if isHealth and ac.only_low_hp and hpPct > ac.hp_thresh then return end

					-- get a position to test distance
					local pos
					if obj:IsA("BasePart") then
						pos = obj.Position
					elseif obj:IsA("Model") and obj.PrimaryPart then
						pos = obj.PrimaryPart.Position
					elseif obj:IsA("Model") then
						local p = obj:FindFirstChildOfClass("BasePart")
						if p then pos = p.Position end
					end

					if not pos then return end
					if (pos - myPos).Magnitude > radius then return end

					-- Teleport HRP to the drop to trigger pickup
					hrp.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
				end)
			end
		end))
	end

--- Left Side: Menu Groupbox
    -- Left Side: Menu Groupbox
    s51 = tbl2["UI Settings"]:AddLeftGroupbox("menu")
    s51:AddLabel("menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "menu keybind" })

    if options.MenuKeybind then
        library.ToggleKeybind = options.MenuKeybind
        library.MenuBindPickers = library.MenuBindPickers or {}
        table.insert(library.MenuBindPickers, options.MenuKeybind)
    end

    s51:AddToggle("silent_load_toggle", {
        Text = "silent load",
        Default = false,
        Callback = function(arg)
            getgenv().silent_load = arg and true or false
            pcall(function()
                if isfolder and not isfolder("phonkware") then makefolder("phonkware") end
                if writefile then writefile("phonkware/silent_load.txt", arg and "1" or "0") end
            end)
        end,
    })

    s51:AddButton("unload script", function()
        getgenv().PhonkWare_Unloaded = true
        
        pcall(function()
            local uis = game:GetService("UserInputService")
            local cam = workspace.CurrentCamera
            local plr = game:GetService("Players").LocalPlayer
            
            uis.MouseBehavior = Enum.MouseBehavior.Default
            uis.MouseIconEnabled = true
            
            if cam then
                cam.CameraType = Enum.CameraType.Custom
                if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                    cam.CameraSubject = plr.Character:FindFirstChildOfClass("Humanoid")
                end
            end
        end)
        
        pcall(function()
            game:GetService("RunService"):UnbindFromRenderStep("PhonkWare_Freecam")
            game:GetService("RunService"):UnbindFromRenderStep("PhonkWare_RageRestore")
        end)
        
        pcall(function() if GLOBAL_TROVE then GLOBAL_TROVE:Destroy() end end)
        
        pcall(function()
            if library and library.Unload then 
                library:Unload()
            elseif library and library.ScreenGui then 
                library.ScreenGui:Destroy() 
            end
        end)
    end)

    -- Left Side: Draggable Overlays & Menus Groupbox
    local draggableBox = tbl2["UI Settings"]:AddLeftGroupbox("draggable overlays & menus")
    draggableBox:AddToggle("show_keybinds_window", {
        Text = "show draggable keybinds window",
        Default = false,
        Callback = function(val)
            if library.KeybindFrame then library.KeybindFrame.Visible = val end
        end,
    })
    draggableBox:AddToggle("show_stats_window", {
        Text = "show draggable stats window",
        Default = false,
        Callback = function(val)
            if library.Watermark then library.Watermark.Visible = val end
        end,
    })
 -- Cleanly fix watermark text to SussyWarev2 without overflowing
-- Cleanly remove .lol and format the watermark to SussyWarev2
        pcall(function()
    task.spawn(function()
        while true do
            task.wait(0.05)
            pcall(function()
                local screenGui = library and library.ScreenGui
                if screenGui then
                    for _, descendant in ipairs(screenGui:GetDescendants()) do
                        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                            local txt = descendant.Text
                            if txt and (txt:find("Elisium") or txt:find("SussyWarev2")) then
                                -- Replace Elisium or SussyWarev2.lol entirely with just SussyWarev2
                                local cleanText = txt:gsub("Elisium%.lol", "SussyWarev2")
                                                     :gsub("Elisium", "SussyWarev2")
                                                     :gsub("SussyWarev2%.lol", "SussyWarev2")
                                descendant.Text = cleanText
                            end
                        end
                    end
                end
            end)
        end
    end)
end)

    if ThemeManager and SaveManager then
        ThemeManager:SetLibrary(library)
        SaveManager:SetLibrary(library)
        
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({ "MenuKeybind", "silent_load_toggle", "show_keybinds_window", "show_stats_window", "WindowSize", "WindowPosition" })
        
        -- Point both managers to your new folder name
        SaveManager:SetFolder("sussywarev_2")
        ThemeManager:SetFolder("sussywarev_2")
        
        local appearanceGroup = tbl2["UI Settings"]:AddRightGroupbox("appearance & fonts")

        -- Check if ThemeManager is the real one (has BuildConfigSection that actually works)
        -- by testing whether it has meaningful methods beyond the stub
        local tmReal = ThemeManager and type(ThemeManager.BuildConfigSection) == "function"
            and ThemeManager.Themes ~= nil

        if tmReal then
            ThemeManager:BuildConfigSection(appearanceGroup)
        else
            -- Fallback: manually build a useful appearance section
            pcall(function()
                appearanceGroup:AddLabel("accent color"):AddColorPicker("theme_accent_color", {
                    Default = Color3.fromRGB(196, 30, 58),
                    Callback = function(color)
                        -- Apply accent to library if possible
                        pcall(function()
                            if library and library.AccentColor then
                                library.AccentColor = color
                            end
                        end)
                    end,
                })

                appearanceGroup:AddLabel("main / boxes color"):AddColorPicker("theme_main_color", {
                    Default = Color3.fromRGB(25, 25, 25),
                    Callback = function(color)
                        pcall(function()
                            if library and library.MainColor then library.MainColor = color end
                        end)
                    end,
                })

                appearanceGroup:AddLabel("font color"):AddColorPicker("theme_font_color", {
                    Default = Color3.fromRGB(240, 240, 240),
                    Callback = function(color) end,
                })

                appearanceGroup:AddLabel("background color"):AddColorPicker("theme_bg_color", {
                    Default = Color3.fromRGB(15, 15, 15),
                    Callback = function(color) end,
                })

                appearanceGroup:AddLabel("outline color"):AddColorPicker("theme_outline_color", {
                    Default = Color3.fromRGB(50, 50, 50),
                    Callback = function(color) end,
                })

                appearanceGroup:AddDropdown("theme_font", {
                    Text = "font",
                    Values = { "Builder Sans ExtraBold", "GothamBold", "GothamMedium", "Gotham", "SourceSans", "Fredoka", "Ubuntu" },
                    Default = "Builder Sans ExtraBold",
                    Callback = function(font)
                        pcall(function()
                            if library then
                                local ok, enumFont = pcall(function() return Enum.Font[font] end)
                                if ok and enumFont then
                                    -- Apply to main container if possible
                                end
                            end
                        end)
                    end,
                })

                appearanceGroup:AddDropdown("theme_preset", {
                    Text = "theme preset",
                    Values = { "Default Dark", "Blood Red", "Pure Black", "Midnight Blue", "Forest Green" },
                    Default = "Default Dark",
                    Callback = function(preset)
                        local themes = {
                            ["Default Dark"] = { accent = Color3.fromRGB(196,30,58), bg = Color3.fromRGB(15,15,15) },
                            ["Blood Red"]    = { accent = Color3.fromRGB(220,20,20), bg = Color3.fromRGB(10,10,10) },
                            ["Pure Black"]   = { accent = Color3.fromRGB(150,150,150), bg = Color3.fromRGB(5,5,5) },
                            ["Midnight Blue"]= { accent = Color3.fromRGB(30,100,220), bg = Color3.fromRGB(10,10,18) },
                            ["Forest Green"] = { accent = Color3.fromRGB(30,180,80), bg = Color3.fromRGB(8,12,8) },
                        }
                        local t = themes[preset]
                        if t then
                            pcall(function()
                                options.theme_accent_color:SetValue(t.accent)
                                options.theme_bg_color:SetValue(t.bg)
                            end)
                        end
                    end,
                })
            end)
        end
        
        local configGroup = tbl2["UI Settings"]:AddRightGroupbox("configuration")

        pcall(function()
            local HttpService = game:GetService("HttpService")
            local ConfigFolder = "sussywarev_2"

            if not isfolder(ConfigFolder) then
                makefolder(ConfigFolder)
            end

            local selectedConfig = ""
            local currentConfigInput = ""
            local autoloadFileName = ConfigFolder .. "/autoload.txt"

            local function GetConfigs()
                local list = {}
                pcall(function()
                    for _, file in ipairs(listfiles(ConfigFolder)) do
                        if file:match("%.json$") then
                            local name = file:match("([^/\\]+)%.json$")
                            table.insert(list, name)
                        end
                    end
                end)
                if #list == 0 then table.insert(list, "...") end
                return list
            end

            -- Serialize a value to something JSON-safe
            local function serializeValue(val)
                local t = typeof(val)
                if t == "Color3" then
                    return { __type = "Color3", r = val.R, g = val.G, b = val.B }
                elseif t == "boolean" or t == "number" or t == "string" then
                    return val
                elseif t == "table" then
                    local out = {}
                    for k, v in pairs(val) do
                        if type(k) == "string" or type(k) == "number" then
                            local sv = serializeValue(v)
                            if sv ~= nil then out[k] = sv end
                        end
                    end
                    return out
                end
                return nil
            end

            local function deserializeValue(val)
                if type(val) == "table" and val.__type == "Color3" then
                    return Color3.new(val.r or 0, val.g or 0, val.b or 0)
                end
                return val
            end

            local function SaveConfig(name)
                if not name or name == "" or name == "..." then return end
                local path = ConfigFolder .. "/" .. name .. ".json"

                pcall(function()
                    if isfolder and not isfolder(ConfigFolder) then
                        makefolder(ConfigFolder)
                    end
                end)

                local saveData = { _ui = {}, _phonk = {} }

                -- Save toggles — use raw `toggles` upvalue (library.Toggles has metamethods)
                if toggles then
                    for idx, tog in pairs(toggles) do
                        if type(idx) == "string" then
                            pcall(function()
                                local val = tog.Value
                                if val ~= nil then
                                    saveData._ui[idx] = val == true
                                end
                            end)
                        end
                    end
                end

                -- Save UI option values — use raw `options` upvalue
                if options then
                    for idx, opt in pairs(options) do
                        if type(idx) == "string" then
                            pcall(function()
                                local val = opt.Value
                                if val ~= nil then
                                    saveData._ui[idx] = serializeValue(val)
                                end
                            end)
                        end
                    end
                end

                -- Grab library.Flags as backup for anything not in options/toggles
                if library and library.Flags then
                    for idx, val in pairs(library.Flags) do
                        if type(idx) == "string" and saveData._ui[idx] == nil then
                            pcall(function()
                                saveData._ui[idx] = serializeValue(val)
                            end)
                        end
                    end
                end

                -- Save raw phonk state so loading actually restores everything
                if getgenv().phonk then
                    pcall(function()
                        saveData._phonk = serializeValue(getgenv().phonk)
                    end)
                end

                pcall(function()
                    writefile(path, HttpService:JSONEncode(saveData))
                end)

                if library then
                    pcall(function() library:Notify("Saved: " .. name, 2) end)
                end
            end

            local function LoadConfig(name)
                if not name or name == "" or name == "..." then return end
                local path = ConfigFolder .. "/" .. name .. ".json"

                if not isfile(path) then
                    if library then pcall(function() library:Notify("Config not found: " .. name, 2) end) end
                    return
                end

                local success, decoded = pcall(function()
                    return HttpService:JSONDecode(readfile(path))
                end)

                if not success or type(decoded) ~= "table" then
                    if library then pcall(function() library:Notify("Failed to parse config", 2) end) end
                    return
                end

                -- Apply UI values and force visual update
                local uiData = decoded._ui or decoded -- fallback: old format was flat

                -- Helper: force a UI object to show the new value visually
                local function applyUIValue(obj, raw)
                    if not obj then return end
                    local val = deserializeValue(raw)

                    -- 1. Try the library's own SetValue (handles visuals + callback)
                    if obj.SetValue then
                        local ok = pcall(function() obj:SetValue(val) end)
                        if ok then return end
                    end

                    -- 2. Fallback: set .Value directly, then fire OnChanged / Callback
                    pcall(function()
                        obj.Value = val
                    end)
                    -- Try every known callback/event name this Linoria fork might use
                    pcall(function()
                        if obj.OnChanged then obj:OnChanged(val) end
                    end)
                    pcall(function()
                        if type(obj.Callback) == "function" then obj.Callback(val) end
                    end)
                    pcall(function()
                        if obj.Changed and type(obj.Changed.Fire) == "function" then
                            obj.Changed:Fire(val)
                        end
                    end)
                end

                if type(uiData) == "table" then
                    -- TOGGLES: use the raw `toggles` upvalue (= library.Toggles before
                    -- metamethods were applied). Direct library.Toggles[key] lookup
                    -- silently returns nil in this Linoria fork due to __index metamethods.
                    if toggles then
                        for idx, tog in pairs(toggles) do
                            if type(idx) == "string" and uiData[idx] ~= nil then
                                pcall(function()
                                    local boolVal = (deserializeValue(uiData[idx]) == true
                                                     or deserializeValue(uiData[idx]) == 1)
                                    applyUIValue(tog, boolVal)
                                end)
                            end
                        end
                    end
                    -- OPTIONS: same — use the raw `options` upvalue
                    if options then
                        for idx, opt in pairs(options) do
                            if type(idx) == "string" and uiData[idx] ~= nil then
                                pcall(function()
                                    applyUIValue(opt, uiData[idx])
                                end)
                            end
                        end
                    end
                end

                -- Deep-merge _phonk directly as fallback in case callbacks didn't fire
                if getgenv().phonk and type(decoded._phonk) == "table" then
                    local function deepMerge(target, source)
                        for k, v in pairs(source) do
                            if type(v) == "table" and v.__type == "Color3" then
                                target[k] = Color3.new(v.r or 0, v.g or 0, v.b or 0)
                            elseif type(v) == "table" and type(target[k]) == "table" then
                                deepMerge(target[k], v)
                            elseif type(v) ~= "table" then
                                target[k] = v
                            end
                        end
                    end
                    pcall(function() deepMerge(getgenv().phonk, decoded._phonk) end)
                end

                if library then
                    pcall(function() library:Notify("Loaded: " .. name, 2) end)
                end
            end

            local function DeleteConfig(name)
                if not name or name == "" or name == "..." then return end
                local path = ConfigFolder .. "/" .. name .. ".json"
                pcall(function()
                    if isfile(path) then delfile(path) end
                end)
            end

            configGroup:AddInput("ConfigNameInput", {
                Text = "Config name",
                Default = "",
                Placeholder = "Enter config name...",
                Callback = function(value)
                    currentConfigInput = value
                end
            })

            local ConfigDropdown = configGroup:AddDropdown("ConfigListDropdown", {
                Text = "Config list",
                Values = GetConfigs(),
                Default = 1,
                Callback = function(value)
                    selectedConfig = value
                end
            })

            configGroup:AddButton("Create config", function()
                SaveConfig(currentConfigInput)
                ConfigDropdown:SetValues(GetConfigs())
            end)

            configGroup:AddButton("Load config", function()
                -- Run on next frame so UI is fully idle before we set values
                task.spawn(function()
                    task.wait()
                    LoadConfig(selectedConfig)
                end)
            end)

            configGroup:AddButton("Overwrite config", function()
                SaveConfig(selectedConfig)
            end)

            configGroup:AddButton("Delete config", function()
                DeleteConfig(selectedConfig)
                ConfigDropdown:SetValues(GetConfigs())
            end)

            configGroup:AddButton("Refresh list", function()
                ConfigDropdown:SetValues(GetConfigs())
            end)

            local AutoloadLabel = configGroup:AddLabel("Current autoload config: none")

            local function UpdateAutoloadLabel()
                pcall(function()
                    if isfile(autoloadFileName) then
                        local autoName = readfile(autoloadFileName)
                        if autoName and autoName ~= "" then
                            AutoloadLabel:SetText("Current autoload config: " .. autoName)
                            return
                        end
                    end
                    AutoloadLabel:SetText("Current autoload config: none")
                end)
            end
            UpdateAutoloadLabel()

            configGroup:AddButton("Set as autoload", function()
                if selectedConfig and selectedConfig ~= "" and selectedConfig ~= "..." then
                    pcall(function()
                        -- Potassium: re-check folder exists before writing autoload
                        if isfolder and not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
                        writefile(autoloadFileName, selectedConfig)
                        UpdateAutoloadLabel()
                    end)
                end
            end)

            configGroup:AddButton("Clear autoload", function()
                pcall(function()
                    if isfile(autoloadFileName) then
                        delfile(autoloadFileName)
                        UpdateAutoloadLabel()
                    end
                end)
            end)

            -- Startup Autoload Check
            pcall(function()
                if isfile(autoloadFileName) then
                    local autoName = readfile(autoloadFileName)
                    if autoName and autoName ~= "" then
                        LoadConfig(autoName)
                    end
                end
            end)
        end)

    end
    

	s23 = function()
		return {
			accent = library.AccentColor or Color3.fromRGB(196, 30, 58),
			main = library.MainColor or Color3.fromRGB(18, 18, 18),
			bg = library.BackgroundColor or Color3.fromRGB(10, 10, 10),
			outline = library.OutlineColor or Color3.fromRGB(45, 40, 42),
			font = library.FontColor or Color3.fromRGB(235, 230, 230),
		}
	end

	s470 = function(arg)
		local flag2 = false
		local position = nil
		local position2 = nil

		arg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				flag2 = true
				position = input.Position
				position2 = arg.Position
				local connection = nil

				connection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						flag2 = false

						if connection then
							connection:Disconnect()
						end
					end
				end)
			end
		end)

		v6.InputChanged:Connect(function(input)
			if not flag2 or not position or not position2 then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local n2 = input.Position - position
				arg.Position = UDim2.new(position2.X.Scale, position2.X.Offset + n2.X, position2.Y.Scale, position2.Y.Offset + n2.Y)
			end
		end)
	end

	s471 = function(parent, name, text, text2, arg, position)
		local v10 = s23()
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.Size = UDim2.fromOffset(112, 52)
		frame.Position = position
		frame.BackgroundColor3 = v10.bg
		frame.BorderSizePixel = 0
		frame.Active = true
		frame.Parent = parent
		Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = v10.outline
		uiStroke.Thickness = 1.2
		uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uiStroke.Parent = frame
		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 10)
		uiPadding.PaddingRight = UDim.new(0, 10)
		uiPadding.PaddingTop = UDim.new(0, 8)
		uiPadding.PaddingBottom = UDim.new(0, 8)
		uiPadding.Parent = frame
		local frame2 = Instance.new("Frame")
		frame2.Name = "Strip"
		frame2.Size = UDim2.new(0, 3, 1, 0)
		frame2.Position = UDim2.fromOffset(-10, -8)
		frame2.BackgroundColor3 = v10.accent
		frame2.BorderSizePixel = 0
		frame2.Parent = frame
		Instance.new("UICorner", frame2).CornerRadius = UDim.new(0, 2)
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.new(1, 0, 0, 18)
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 14
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.TextColor3 = v10.font
		textLabel.Text = text
		textLabel.Parent = frame
		local textLabel2 = Instance.new("TextLabel")
		textLabel2.Name = "Sub"
		textLabel2.BackgroundTransparency = 1
		textLabel2.Position = UDim2.fromOffset(0, 20)
		textLabel2.Size = UDim2.new(1, 0, 0, 14)
		textLabel2.Font = Enum.Font.GothamMedium
		textLabel2.TextSize = 11
		textLabel2.TextXAlignment = Enum.TextXAlignment.Left
		textLabel2.TextColor3 = Color3.fromRGB(130, 125, 128)
		textLabel2.Text = text2
		textLabel2.Parent = frame
		local frame3 = Instance.new("Frame")
		frame3.Name = "Dot"
		frame3.AnchorPoint = Vector2.new(1, 0.5)
		frame3.Position = UDim2.new(1, 0, 0.5, 0)
		frame3.Size = UDim2.fromOffset(8, 8)
		frame3.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		frame3.BorderSizePixel = 0
		frame3.Parent = frame
		Instance.new("UICorner", frame3).CornerRadius = UDim.new(1, 0)
		local textButton = Instance.new("TextButton")
		textButton.Size = UDim2.fromScale(1, 1)
		textButton.Position = UDim2.fromOffset(-10, -8)
		textButton.Size = UDim2.new(1, 20, 1, 16)
		textButton.BackgroundTransparency = 1
		textButton.Text = ""
		textButton.ZIndex = 5
		textButton.Parent = frame

		local function fn7()
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			phonkMobileBtns = phonkMobileBtns and phonkMobileBtns[arg]
			local v11 = s23()

			if phonkMobileBtns then
				frame.BackgroundColor3 = Color3.new(v11.bg.R * 0.7 + v11.accent.R * 0.15, v11.bg.G * 0.7 + v11.accent.G * 0.15, v11.bg.B * 0.7 + v11.accent.B * 0.15)
				uiStroke.Color = v11.accent
				frame2.BackgroundColor3 = v11.accent
				textLabel.TextColor3 = v11.accent
				textLabel2.Text = "ACTIVE"
				textLabel2.TextColor3 = v11.accent
				frame3.BackgroundColor3 = v11.accent
			else
				frame.BackgroundColor3 = v11.bg
				uiStroke.Color = v11.outline
				frame2.BackgroundColor3 = v11.outline
				textLabel.TextColor3 = v11.font
				textLabel2.Text = text2
				textLabel2.TextColor3 = Color3.fromRGB(130, 125, 128)
				frame3.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
			end
		end

		fn7()

		textButton.MouseButton1Click:Connect(function()
			local phonkMobileBtns = getgenv().phonk_mobile_btns
			if not phonkMobileBtns then
				return
			end
			phonkMobileBtns[arg] = not phonkMobileBtns[arg]
			fn7()
		end)
	end
end)()
-- Force UI Window to expand and lock scale to 1 instantly
pcall(function()
    getgenv().phonk_ui_scale = 1
    if Library and Library.ScreenGui then
        local s = Library.ScreenGui:FindFirstChild("PhonkUIScale")
        if s then s.Scale = 1 end
    end
end)
-- Force cursor to stay visible whenever the UI menu is open
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            if library and library.MenuOpen then
                game:GetService("UserInputService").MouseIconEnabled = true
                game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
            end
        end)
    end
end)
