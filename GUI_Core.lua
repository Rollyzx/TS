	-- [[ // Libraries // ]]
	local library = {
		Renders = {},
		Connections = {},
		Folder = "ScriptHere", -- Change if wanted
		Assets = "Assets", -- Change if wanted
		Configs = "Configs", -- Change if wanted
		Binding = false

	}
	local utility = {}

	local justBound = false -- evita que la primera pulsación tras reasignar cierre/alterne la GUI

	-- Config de apariencia (colócalo cerca del inicio)
	local Config = {
		ThemeName = "Dark", -- nombre del tema activo por defecto; puede ser "Dark","Light","Aqua","Sunset","Forest" o "Custom"

		-- temas predefinidos (puedes editar o añadir otros)
		Themes = {
			Dark = {
				Background = Color3.fromRGB(20,20,25),
				Main      = Color3.fromRGB(30,30,36),
				Accent    = Color3.fromRGB(0,170,255),
				Text      = Color3.fromRGB(230,230,230),
				Secondary = Color3.fromRGB(45,45,50),
				Border    = Color3.fromRGB(70,70,80)
			},
			Light = {
				Background = Color3.fromRGB(245,245,250),
				Main      = Color3.fromRGB(255,255,255),
				Accent    = Color3.fromRGB(0,120,255),
				Text      = Color3.fromRGB(20,20,25),
				Secondary = Color3.fromRGB(230,230,235),
				Border    = Color3.fromRGB(200,200,210)
			},
			Aqua = {
				Background = Color3.fromRGB(8,30,40),
				Main      = Color3.fromRGB(10,50,65),
				Accent    = Color3.fromRGB(0,255,200),
				Text      = Color3.fromRGB(230,245,250),
				Secondary = Color3.fromRGB(12,60,80),
				Border    = Color3.fromRGB(20,80,100)
			},
			Sunset = {
				Background = Color3.fromRGB(35,12,20),
				Main      = Color3.fromRGB(50,20,30),
				Accent    = Color3.fromRGB(255,115,85),
				Text      = Color3.fromRGB(250,240,230),
				Secondary = Color3.fromRGB(60,30,40),
				Border    = Color3.fromRGB(90,45,55)
			},
			Forest = {
				Background = Color3.fromRGB(8,25,10),
				Main      = Color3.fromRGB(12,50,20),
				Accent    = Color3.fromRGB(120,255,120),
				Text      = Color3.fromRGB(230,245,235),
				Secondary = Color3.fromRGB(16,70,30),
				Border    = Color3.fromRGB(30,90,45)
			}
		},

		-- Si el usuario quiere personalizar manualmente, pon los colores en Custom (se usa si ThemeName == "Custom")
		Custom = {
			Background = Color3.fromRGB(25,25,25),
			Main       = Color3.fromRGB(32,32,36),
			Accent     = Color3.fromRGB(255,100,100),
			Text       = Color3.fromRGB(240,240,240),
			Secondary  = Color3.fromRGB(45,45,50),
			Border     = Color3.fromRGB(70,70,80)
		},

		-- otras opciones visibles: transparencia y si aplicar bordes sutiles
		Transparency = 0.00, -- 0..1 aplicado a Background/Main
		UseBorders = true
	}

	-- [[ // Tables // ]]
	local pages = {}
	local sections = {}
	-- [[ // Indexes // ]]
	do
		library.__index = library
		pages.__index = pages
		sections.__index = sections
	end
	-- [[ // Variables // ]] 
	local tws = game:GetService("TweenService")
	local uis = game:GetService("UserInputService")
	local cre = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")  -- ✅ AGREGAR ESTA LÍNEA
    local Players = game:GetService("Players")         -- ✅ AGREGAR ESTA LÍNEA
    local Workspace = game:GetService("Workspace")     -- ✅ AGREGAR ESTA LÍNEA
	-- [[ // Functions // ]]
	function utility:RenderObject(RenderType, RenderProperties, RenderHidden)
		local Render = Instance.new(RenderType)
		--
		if RenderProperties and typeof(RenderProperties) == "table" then
			for Property, Value in pairs(RenderProperties) do
				if Property ~= "RenderTime" then
					Render[Property] = Value
				end
			end
		end
		--
		library.Renders[#library.Renders + 1] = {Render, RenderProperties, RenderHidden, RenderProperties["RenderTime"] or nil}
		--
		return Render
	end
	--
	function utility:CreateConnection(ConnectionType, ConnectionCallback)
		local Connection = ConnectionType:Connect(ConnectionCallback)
		--
		library.Connections[#library.Connections + 1] = Connection
		--
		return Connection
	end
	--
	function utility:MouseLocation()
		return uis:GetMouseLocation()
	end
	--
	function utility:Serialise(Table)
		local Serialised = ""
		--
		for Index, Value in pairs(Table) do
			Serialised = Serialised .. Value .. ", "
		end
		--
		return Serialised:sub(0, #Serialised - 2)
	end
	--
	function utility:Sort(Table1, Table2)
		local Table3 = {}
		--
		for Index, Value in pairs(Table2) do
			if table.find(Table1, Index) then
				Table3[#Table3 + 1] = Value
			end
		end
		--
		return Table3
	end

-- 🎨 NUEVA FUNCIÓN: Convertir Color3 a Hex
local function Color3ToHex(color)
    return string.format("#%02x%02x%02x", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

-- 🎨 NUEVA FUNCIÓN: Convertir Hex a Color3
local function HexToColor3(hex)
    hex = hex:gsub("#", "")
    if #hex ~= 6 then return Color3.fromRGB(255, 255, 255) end
    
    local r = tonumber(hex:sub(1,2), 16) or 255
    local g = tonumber(hex:sub(3,4), 16) or 255
    local b = tonumber(hex:sub(5,6), 16) or 255
    
    return Color3.fromRGB(r, g, b)
end

-- Aplicar theme
local function applyTheme(window, theme)
    if not window or not theme then return end
    
    local colors = theme
    if type(theme) == "string" then
        colors = Config.Themes[theme] or Config.Custom
    end
    
    colors = colors or {}
    colors.Main   = colors.Main   or Color3.fromRGB(20,20,20)
    colors.Background = colors.Background or Color3.fromRGB(10,10,10)
    colors.Accent = colors.Accent or Color3.fromRGB(200,50,50)
    colors.Text   = colors.Text   or Color3.fromRGB(230,230,230)
    colors.Border = colors.Border or Color3.fromRGB(30,30,30)
    
    if type(colors.Main) == "table" then colors.Main = colors.Main[1] end
    if type(colors.Background) == "table" then colors.Background = colors.Background[1] end
    if type(colors.Accent) == "table" then colors.Accent = colors.Accent[1] end
    if type(colors.Text) == "table" then colors.Text = colors.Text[1] end
    if type(colors.Secondary) == "table" then colors.Secondary = colors.Secondary[1] end
    if type(colors.Border) == "table" then colors.Border = colors.Border[1] end
    
    local bg = colors.Background
    local main = colors.Main
    local tr = Config.Transparency or 0
    bg = Color3.new(bg.R + (1 - bg.R)*tr, bg.G + (1 - bg.G)*tr, bg.B + (1 - bg.B)*tr)
    main = Color3.new(main.R + (1 - main.R)*tr, main.G + (1 - main.G)*tr, main.B + (1 - main.B)*tr)
    
    pcall(function()
        if type(window) == "table" then
            window.Accent = colors.Accent or window.Accent
            window.Text   = colors.Text   or window.Text
            window.Border = colors.Border or window.Border
        end
    end)
    
    if window.Background then
        pcall(function() window.Background.BackgroundColor3 = bg end)
    end
    
    if window.Main then
        pcall(function() window.Main.BackgroundColor3 = main end)
    end
    
    if window.Header then
        pcall(function()
            window.Header.BackgroundColor3 = colors.Secondary or main
            if window.Header.Title and window.Header.Title:IsA("TextLabel") then
                window.Header.Title.TextColor3 = colors.Text
            end
        end)
    end
    
    if window.CloseButton then
        pcall(function()
            window.CloseButton.BackgroundColor3 = colors.Secondary
            if window.CloseButton.TextLabel then
                window.CloseButton.TextLabel.TextColor3 = colors.Text
            end
        end)
    end
    
    if window.Buttons and typeof(window.Buttons) == "table" then
        for _, btn in ipairs(window.Buttons) do
            pcall(function()
                if btn:IsA("GuiButton") or btn:IsA("TextButton") then
                    btn.BackgroundColor3 = colors.Main
                    btn.BorderColor3 = Config.UseBorders and (colors.Border or Color3.new(0,0,0)) or Color3.new(0,0,0)
                    if btn.TextColor3 ~= nil then btn.TextColor3 = colors.Text end
                end
            end)
        end
    end
    
    if window.Labels and typeof(window.Labels) == "table" then
        for _, lbl in ipairs(window.Labels) do
            pcall(function()
                if lbl:IsA("TextLabel") or lbl:IsA("TextBox") then
                    lbl.TextColor3 = colors.Text
                    if lbl.BackgroundColor3 then lbl.BackgroundColor3 = main end
                end
            end)
        end
    end
    
    if window.Accents and typeof(window.Accents) == "table" then
        for _, acc in ipairs(window.Accents) do
            pcall(function()
                if acc:IsA("Frame") or acc:IsA("ImageLabel") then
                    acc.BackgroundColor3 = colors.Accent
                end
            end)
        end
    end
end

	-- [[ // UI Functions // ]]
	function library:CreateWindow(Properties)
		Properties = Properties or {}
		--
		Window = {
			Pages = {},
			Accent = Color3.fromRGB(255, 120, 30), -- Color3.fromRGB(136, 180, 57) -- Change if wanted
			Enabled = true,
			Key = Enum.KeyCode.Z,
			CloseKey = Enum.KeyCode.X, -- Change if wanted
			Sliders = {} -- Nueva tabla para sliders
		}
		--
		do
			local ScreenGui = utility:RenderObject("ScreenGui", {
				DisplayOrder = 9999,
				Enabled = true,
				IgnoreGuiInset = true,
				Parent = cre,
				ResetOnSpawn = false,
				ZIndexBehavior = "Global"
			})
			Window.ScreenGui = ScreenGui

			-- //
			local ScreenGui_MainFrame = utility:RenderObject("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(25, 25, 25),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Parent = ScreenGui,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0, 660, 0, 560)
			})
			-- //
			local ScreenGui_MainFrame_InnerBorder = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(40, 40, 40),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = ScreenGui_MainFrame,
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2)
			})
			-- //
			local MainFrame_InnerBorder_InnerFrame = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(12, 12, 12),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(60, 60, 60),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Parent = ScreenGui_MainFrame,
				Position = UDim2.new(0, 3, 0, 3),
				Size = UDim2.new(1, -6, 1, -6)
			})
			-- //
			local InnerBorder_InnerFrame_Tabs = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(12, 12, 12),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = MainFrame_InnerBorder_InnerFrame,
				Position = UDim2.new(0, 0, 0, 4),
				Size = UDim2.new(0, 74, 1, -4)
			})
			--
			local InnerBorder_InnerFrame_Pages = utility:RenderObject("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = MainFrame_InnerBorder_InnerFrame,
				Position = UDim2.new(1, 0, 0, 4),
				Size = UDim2.new(1, -73, 1, -4)
			})
			--
			local InnerBorder_InnerFrame_TopGradient = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(12, 12, 12),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = MainFrame_InnerBorder_InnerFrame,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 0, 4)
			})
			-- //
			local InnerFrame_Tabs_List = utility:RenderObject("UIListLayout", {
				Padding = UDim.new(0, 4),
				Parent = InnerBorder_InnerFrame_Tabs,
				FillDirection = "Vertical",
				HorizontalAlignment = "Left",
				VerticalAlignment = "Top"
			})
			--
			local InnerFrame_Tabs_Padding = utility:RenderObject("UIPadding", {
				Parent = InnerBorder_InnerFrame_Tabs,
				PaddingTop = UDim.new(0, 9)
			})
			--
			local InnerFrame_Pages_InnerBorder = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(45, 45, 45),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = InnerBorder_InnerFrame_Pages,
				Position = UDim2.new(0, 1, 0, 0),
				Size = UDim2.new(1, -1, 1, 0)
			})
			--
			local InnerFrame_TopGradient_Gradient = utility:RenderObject("ImageLabel", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = InnerBorder_InnerFrame_TopGradient,
				Position = UDim2.new(0, 1, 0, 1),
				Size = UDim2.new(1, -2, 1, -2),
				Image = "rbxassetid://8508019876",
				ImageColor3 = Color3.fromRGB(255, 255, 255)
			})
			-- //
			local Pages_InnerBorder_InnerFrame = utility:RenderObject("Frame", {
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
				BackgroundTransparency = 0,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = InnerFrame_Pages_InnerBorder,
				Position = UDim2.new(0, 1, 0, 0),
				Size = UDim2.new(1, -1, 1, 0)
			})
			-- //
			local InnerBorder_InnerFrame_Folder = utility:RenderObject("Folder", {
				Parent = Pages_InnerBorder_InnerFrame
			})
			--
			local InnerBorder_InnerFrame_Pattern = utility:RenderObject("ImageLabel", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Parent = Pages_InnerBorder_InnerFrame,
				Position = UDim2.new(0, 0, 0, 0),
				Size = UDim2.new(1, 0, 1, 0),
				Image = "rbxassetid://8547666218",
				ImageColor3 = Color3.fromRGB(12, 12, 12),
				ScaleType = "Tile",
				TileSize = UDim2.new(0, 8, 0, 8)
			})
			--
			do -- // Functions
				function Window:SetPage(Page)
					for index, page in pairs(Window.Pages) do
						if page.Open and page ~= Page then
							page:Set(false)
						end
					end
				end
				--
function Window:Fade(state)
    local fadeTime = 0

    -- 🎨 Fade de todos los elementos registrados
    for index, render in pairs(library.Renders) do
        if not render[3] then
            local time = render[4] or 0.25
            fadeTime = math.max(fadeTime, time)

            if render[1].ClassName == "Frame" and (render[2]["BackgroundTransparency"] or 0) ~= 1 then
                tws:Create(
                    render[1],
                    TweenInfo.new(time, Enum.EasingStyle.Linear, state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                    { BackgroundTransparency = state and (render[2]["BackgroundTransparency"] or 0) or 1 }
                ):Play()

            elseif render[1].ClassName == "ImageLabel" then
                if (render[2]["BackgroundTransparency"] or 0) ~= 1 then
                    tws:Create(render[1], TweenInfo.new(time, Enum.EasingStyle.Linear,
                        state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                        { BackgroundTransparency = state and (render[2]["BackgroundTransparency"] or 0) or 1 }
                    ):Play()
                end

                if (render[2]["ImageTransparency"] or 0) ~= 1 then
                    tws:Create(render[1], TweenInfo.new(time, Enum.EasingStyle.Linear,
                        state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                        { ImageTransparency = state and (render[2]["ImageTransparency"] or 0) or 1 }
                    ):Play()
                end

            elseif render[1].ClassName == "TextLabel" then
                if (render[2]["BackgroundTransparency"] or 0) ~= 1 then
                    tws:Create(render[1], TweenInfo.new(time, Enum.EasingStyle.Linear,
                        state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                        { BackgroundTransparency = state and (render[2]["BackgroundTransparency"] or 0) or 1 }
                    ):Play()
                end

                if (render[2]["TextTransparency"] or 0) ~= 1 then
                    tws:Create(render[1], TweenInfo.new(time, Enum.EasingStyle.Linear,
                        state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                        { TextTransparency = state and (render[2]["TextTransparency"] or 0) or 1 }
                    ):Play()
                end

            elseif render[1].ClassName == "TextButton" then
                if (render[2]["BackgroundTransparency"] or 0) ~= 1 then
                    tws:Create(render[1], TweenInfo.new(time, Enum.EasingStyle.Linear,
                        state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                        { BackgroundTransparency = state and (render[2]["BackgroundTransparency"] or 0) or 1 }
                    ):Play()
                end

                if (render[2]["TextTransparency"] or 0) ~= 1 then
                    tws:Create(render[1], TweenInfo.new(time, Enum.EasingStyle.Linear,
                        state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                        { TextTransparency = state and (render[2]["TextTransparency"] or 0) or 1 }
                    ):Play()
                end

            elseif render[1].ClassName == "ScrollingFrame" then
                if (render[2]["BackgroundTransparency"] or 0) ~= 1 then
                    tws:Create(render[1], TweenInfo.new(time, Enum.EasingStyle.Linear,
                        state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                        { BackgroundTransparency = state and (render[2]["BackgroundTransparency"] or 0) or 1 }
                    ):Play()
                end

                if (render[2]["ScrollBarImageTransparency"] or 0) ~= 1 then
                    tws:Create(render[1], TweenInfo.new(time, Enum.EasingStyle.Linear,
                        state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                        { ScrollBarImageTransparency = state and (render[2]["ScrollBarImageTransparency"] or 0) or 1 }
                    ):Play()
                end
            end
        end
    end

    -- 🎨 NUEVO: Fade específico para indicadores de subtabs
    for _, page in pairs(self.Pages) do
        for _, section in pairs({page.Left, page.Right}) do
            if section then
                for _, child in ipairs(section:GetChildren()) do
                    if child:IsA("Frame") then
                        -- Buscar subtabs holders
                        local subtabsHolder = child:FindFirstChild("SubtabsHolder", true)
                        if subtabsHolder then
                            -- Fade de los botones de subtab
                            for _, btn in ipairs(subtabsHolder:GetChildren()) do
                                if btn:IsA("TextButton") then
                                    -- Fade del botón
                                    tws:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Linear,
                                        state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                                        { 
                                            BackgroundTransparency = state and 0 or 1,
                                            TextTransparency = state and 0 or 1
                                        }
                                    ):Play()
                                    
                                    -- ✅ Fade del indicador SOLO si está visible
                                    local indicator = btn:FindFirstChild("Frame")
                                    if indicator and indicator.Visible then
                                        local indicatorTween = tws:Create(indicator, 
                                            TweenInfo.new(0.15, Enum.EasingStyle.Linear,
                                                state and Enum.EasingDirection.Out or Enum.EasingDirection.In),
                                            { BackgroundTransparency = state and 0 or 1 }
                                        )
                                        indicatorTween:Play()
                                        
                                        -- Ocultar después del fade out
                                        if not state then
                                            indicatorTween.Completed:Connect(function()
                                                indicator.Visible = false
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- 🔒 Control de interacción
    if self.ScreenGui then
        if state then
            self.ScreenGui.Enabled = true
        else
            task.delay(fadeTime, function()
                if self.ScreenGui then
                    self.ScreenGui.Enabled = false
                end
            end)
        end
    end
end

				--
				function Window:Unload()
					ScreenGui:Remove()
					--
					for index, connection in pairs(library.Connections) do
						connection:Disconnect()
					end
					--
					library = nil
					utility = nil
				end
			end
			--
			do -- // Index Setting
				Window["TabsHolder"] = InnerBorder_InnerFrame_Tabs
				Window["PagesHolder"] = InnerBorder_InnerFrame_Folder
			end
			--
			do -- // Connections
				utility:CreateConnection(uis.InputBegan, function(input)
					if library.Binding or justBound then return end -- ignorar mientras reasignamos o durante el rebote
					if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
					local k = input.KeyCode
					if k == Window.Key then
						Window.Enabled = not Window.Enabled
						if Window.Fade then pcall(Window.Fade, Window, Window.Enabled) end
					elseif k == Window.CloseKey then
						Window:Unload()
					end
				end)

			end
		end

-- === asignaciones que usa applyTheme ===
			-- usa los nombres reales de tus variables de frames creados en CreateWindow
			Window.Background = ScreenGui_MainFrame                      -- cambia por tu frame principal
			Window.Main       = MainFrame_InnerBorder_InnerFrame        -- panel principal
			Window.Header     = InnerBorder_InnerFrame_TopGradient      -- header / barra superior

			-- tablas para que applyTheme pueda iterar y recolorear controles
			Window.Buttons = Window.Buttons or {}
			Window.Labels  = Window.Labels  or {}
			Window.Accents = Window.Accents or {}
			Window.ToggleAccents = Window.ToggleAccents or {}
			

			-- inicializar valores visuales desde el theme actual
			local currentTheme = (Config.ThemeName == "Custom") and Config.Custom or (Config.Themes and Config.Themes[Config.ThemeName]) or Config.Custom
			Window.Accent = currentTheme.Accent or Window.Accent
			Window.Text   = currentTheme.Text   or Window.Text
			Window.Border = currentTheme.Border or Window.Border

			-- aplicar theme ahora que Window tiene referencias
			pcall(function()
				applyTheme(Window, currentTheme)
			end)


		--
		return setmetatable(Window, library)
	end

function applyTheme(window, colors)
    local inactiveColor = Color3.fromRGB(77, 77, 77)

    colors = colors or {}
    colors.Main   = colors.Main   or Color3.fromRGB(20,20,20)
    colors.Background = colors.Background or Color3.fromRGB(10,10,10)
    colors.Accent = colors.Accent or Color3.fromRGB(200,50,50)
    colors.Text   = colors.Text   or Color3.fromRGB(230,230,230)
    colors.Border = colors.Border or Color3.fromRGB(30,30,30)

    -- Actualizar referencias del window
    pcall(function()
        if type(window) == "table" then
            window.Accent = colors.Accent or window.Accent
            window.Text   = colors.Text   or window.Text
            window.Border = colors.Border or window.Border
        end
    end)

    -- Aplicar a elementos generales
    if window and window.Main then
        pcall(function() window.Main.BackgroundColor3 = colors.Main end)
    end

    if window and window.Background then
        pcall(function() window.Background.BackgroundColor3 = colors.Background end)
    end

    -- Recolorear botones
    if window and window.Buttons then
        for _, btn in ipairs(window.Buttons) do
            pcall(function() 
                btn.BackgroundColor3 = colors.Main
                btn.TextColor3 = colors.Text 
            end)
        end
    end

    -- Recolorear labels
    if window and window.Labels then
        for _, lbl in ipairs(window.Labels) do
            pcall(function() lbl.TextColor3 = colors.Text end)
        end
    end

    -- Recolorear accents (sliders, etc.)
    if window and window.Accents then
        for _, acc in ipairs(window.Accents) do
            pcall(function() acc.BackgroundColor3 = colors.Accent end)
        end
    end

    -- ✅ ACTUALIZAR INDICADORES DE SUBTABS ACTIVOS
    if window and window.Pages then
        for _, page in pairs(window.Pages) do
            -- Recorrer secciones del Left y Right
            for _, section in pairs({page.Left, page.Right}) do
                if section then
                    -- Buscar secciones con subtabs
                    for _, sectionObj in ipairs(section:GetChildren()) do
                        if sectionObj:IsA("Frame") then
                            local subtabsHolder = sectionObj:FindFirstChild("SubtabsHolder", true)
                            if subtabsHolder then
                                -- Actualizar cada botón de subtab
                                for _, btn in ipairs(subtabsHolder:GetChildren()) do
                                    if btn:IsA("TextButton") then
                                        local indicator = btn:FindFirstChild("Frame")
                                        if indicator then
                                            -- Solo actualizar el color si el indicador está visible (subtab activo)
                                            if indicator.Visible then
                                                indicator.BackgroundColor3 = colors.Accent
                                            end
                                            
                                            -- También actualizar el texto del botón si está activo
                                            if indicator.Visible then
                                                btn.TextColor3 = colors.Accent
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Actualizar toggles con estados
    if window and window.ToggleAccents then
        for _, t in ipairs(window.ToggleAccents) do
            pcall(function()
                if t.ContentRef and type(t.ContentRef.Set) == "function" then
                    t.ContentRef:Set(t.ContentRef.State)
                else
                    local isActive = (type(t.GetState) == "function" and t.GetState()) or false
                    if t.Frame then
                        t.Frame.BackgroundColor3 = isActive and colors.Accent or inactiveColor
                    end
                end
            end)
        end
    end
end

function library:CreatePage(Properties)
    Properties = Properties or {}
    --
    local Page = {
        Image = (Properties.image or Properties.Image or Properties.icon or Properties.Icon),
        Size = (Properties.size or Properties.Size or UDim2.new(0, 50, 0, 50)),
        Open = false,
        Window = self
    }
    --
    do
        local Page_Tab = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page.Window["TabsHolder"],
            Size = UDim2.new(1, 0, 0, 72)
        })
        -- //
        local Page_Tab_Border = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Tab,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 2,
            RenderTime = 0.15
        })
        --
        local Page_Tab_Image = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Tab,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = Page.Size,
            ZIndex = 2,
            Image = Page.Image,
            ImageColor3 = Color3.fromRGB(100, 100, 100)
        })
        --
        local Page_Tab_Button = utility:RenderObject("TextButton", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Tab,
            Size = UDim2.new(1, 0, 1, 0),
            Text = ""
        })
        -- //
        local Tab_Border_Inner = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Tab_Border,
            Position = UDim2.new(0, 0, 0, 1),
            Size = UDim2.new(1, 1, 1, -2),
            ZIndex = 2,
            RenderTime = 0.15
        })
        -- //
        local Border_Inner_Inner = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Tab_Border_Inner,
            Position = UDim2.new(0, 0, 0, 1),
            Size = UDim2.new(1, 0, 1, -2),
            ZIndex = 2,
            RenderTime = 0.15
        })
        --
        local Inner_Inner_Pattern = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Border_Inner_Inner,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Image = "rbxassetid://8509210785",
            ImageColor3 = Color3.fromRGB(12, 12, 12),
            ScaleType = "Tile",
            TileSize = UDim2.new(0, 8, 0, 8),
            ZIndex = 2
        })
        -- //
        local Page_Page = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page.Window["PagesHolder"],
            Position = UDim2.new(0, 20, 0, 20),
            Size = UDim2.new(1, -40, 1, -40),
            Visible = false
        })
        
        -- ========== 🔥 CONTENEDOR CON SCROLL UNIFICADO ==========
        local Page_Scroll_Container = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Page,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0)
        })
        
        -- ========== 🎯 UN SOLO SCROLLING FRAME PARA TODA LA PÁGINA ==========
        local Page_Unified_Scroll = utility:RenderObject("ScrollingFrame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Scroll_Container,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 2,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 6, -- ✅ Un poco más grueso para mejor visibilidad
            ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85), -- ✅ Color más visible
            ScrollBarImageTransparency = 0,
            BottomImage = "rbxassetid://7783554086",
            MidImage = "rbxassetid://7783554086",
            TopImage = "rbxassetid://7783554086",
            VerticalScrollBarInset = "ScrollBar", -- ✅ Scrollbar visible en el borde derecho
            ScrollingEnabled = true,
            Active = true,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ElasticBehavior = Enum.ElasticBehavior.Never -- ✅ Sin rebote elástico
        })
        
        -- ========== 📦 CONTENEDOR DE COLUMNAS (NO SCROLLING) ==========
        local Columns_Container = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Unified_Scroll,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        -- ========== COLUMNA IZQUIERDA (FRAME NORMAL, NO SCROLLING) ==========
        local Page_Page_Left = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Columns_Container,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.5, -10, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        -- ========== COLUMNA DERECHA (FRAME NORMAL, NO SCROLLING) ==========
        local Page_Page_Right = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Columns_Container,
            Position = UDim2.new(0.5, 10, 0, 0),
            Size = UDim2.new(0.5, -10, 1, 0),
            AutomaticSize = Enum.AutomaticSize.Y
        })
        
        -- ========== 🎨 GRADIENTES Y FLECHAS UNIFICADOS ==========
        local Unified_Gradient1 = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Scroll_Container,
            Position = UDim2.new(0, 0, 0, 0),
            Rotation = 180,
            Size = UDim2.new(1, -10, 0, 25), -- ✅ Más ancho (excluye el scrollbar)
            Visible = false,
            ZIndex = 5,
            Image = "rbxassetid://7783533907",
            ImageColor3 = Color3.fromRGB(20, 20, 20)
        })
        
        local Unified_Gradient2 = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Scroll_Container,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, -10, 0, 25), -- ✅ Más ancho (excluye el scrollbar)
            Visible = false,
            ZIndex = 5,
            Image = "rbxassetid://7783533907",
            ImageColor3 = Color3.fromRGB(20, 20, 20)
        })
        
        local Unified_ArrowUp = utility:RenderObject("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Scroll_Container,
            Position = UDim2.new(1, -25, 0, 2), -- ✅ Posicionado justo sobre el scrollbar
            Size = UDim2.new(0, 20, 0, 18),
            Text = "",
            Visible = false,
            ZIndex = 6
        })
        
        local Unified_ArrowUp_Image = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Unified_ArrowUp,
            Position = UDim2.new(0, 6, 0, 6),
            Size = UDim2.new(0, 8, 0, 7),
            ZIndex = 6,
            Image = "rbxassetid://8548757311",
            ImageColor3 = Color3.fromRGB(220, 220, 220)
        })
        
        local Unified_ArrowDown = utility:RenderObject("TextButton", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Page_Scroll_Container,
            Position = UDim2.new(1, -25, 1, -20), -- ✅ Posicionado justo debajo del scrollbar
            Size = UDim2.new(0, 20, 0, 18),
            Text = "",
            Visible = false,
            ZIndex = 6
        })
        
        local Unified_ArrowDown_Image = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Unified_ArrowDown,
            Position = UDim2.new(0, 6, 0, 6),
            Size = UDim2.new(0, 8, 0, 7),
            ZIndex = 6,
            Image = "rbxassetid://8548723563",
            ImageColor3 = Color3.fromRGB(220, 220, 220)
        })
        
        -- ========== UI LAYOUTS ==========
        local Page_Left_List = utility:RenderObject("UIListLayout", {
            Padding = UDim.new(0, 18),
            Parent = Page_Page_Left,
            FillDirection = "Vertical",
            HorizontalAlignment = "Left",
            VerticalAlignment = "Top"
        })
        
        local Page_Left_Padding = utility:RenderObject("UIPadding", {
            Parent = Page_Page_Left,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 8)
        })
        
        local Page_Right_List = utility:RenderObject("UIListLayout", {
            Padding = UDim.new(0, 18),
            Parent = Page_Page_Right,
            FillDirection = "Vertical",
            HorizontalAlignment = "Left",
            VerticalAlignment = "Top"
        })
        
        local Page_Right_Padding = utility:RenderObject("UIPadding", {
            Parent = Page_Page_Right,
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 0),
            PaddingRight = UDim.new(0, 8)
        })
        
        --
        do -- // Index Setting
            Page["Page"] = Page_Page
            Page["Left"] = Page_Page_Left
            Page["Right"] = Page_Page_Right
            Page["UnifiedScroll"] = Page_Unified_Scroll -- ✅ Referencia al scroll unificado
        end
        --
        do -- // Functions
            function Page:Set(state)
                Page.Open = state
                --
                Page_Page.Visible = Page.Open
                Page_Tab_Border.Visible = Page.Open
                Page_Tab_Image.ImageColor3 = Page.Open and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(90, 90, 90)
                --
                if Page.Open then
                    Page.Window:SetPage(Page)
                end
            end
        end
        --
        do -- // Connections
            utility:CreateConnection(Page_Tab_Button.MouseButton1Click, function(Input)
                if not Page.Open then
                    Page:Set(true)
                end
            end)
            --
            utility:CreateConnection(Page_Tab_Button.MouseEnter, function(Input)
                Page_Tab_Image.ImageColor3 = Color3.fromRGB(172, 172, 172)
            end)
            --
            utility:CreateConnection(Page_Tab_Button.MouseLeave, function(Input)
                Page_Tab_Image.ImageColor3 = Page.Open and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(90, 90, 90)
            end)
            
            -- ========== 🎯 CONEXIONES DEL SCROLL UNIFICADO ==========
            utility:CreateConnection(Page_Unified_Scroll:GetPropertyChangedSignal("AbsoluteCanvasSize"), function()
                local needsScroll = Page_Unified_Scroll.AbsoluteCanvasSize.Y > Page_Unified_Scroll.AbsoluteWindowSize.Y
                
                Unified_Gradient1.Visible = needsScroll
                Unified_Gradient2.Visible = needsScroll
                
                if needsScroll then
                    Unified_ArrowUp.Visible = (Page_Unified_Scroll.CanvasPosition.Y > 5)
                    Unified_ArrowDown.Visible = (Page_Unified_Scroll.CanvasPosition.Y + 5 < (Page_Unified_Scroll.AbsoluteCanvasSize.Y - Page_Unified_Scroll.AbsoluteSize.Y))
                else
                    Unified_ArrowUp.Visible = false
                    Unified_ArrowDown.Visible = false
                end
            end)
            
            utility:CreateConnection(Page_Unified_Scroll:GetPropertyChangedSignal("CanvasPosition"), function()
                if Page_Unified_Scroll.AbsoluteCanvasSize.Y > Page_Unified_Scroll.AbsoluteWindowSize.Y then
                    Unified_ArrowUp.Visible = (Page_Unified_Scroll.CanvasPosition.Y > 1)
                    Unified_ArrowDown.Visible = (Page_Unified_Scroll.CanvasPosition.Y + 1 < (Page_Unified_Scroll.AbsoluteCanvasSize.Y - Page_Unified_Scroll.AbsoluteSize.Y))
                end
            end)
            
            -- ✅ Scroll suave con las flechas (30 pixels por click)
            utility:CreateConnection(Unified_ArrowUp.MouseButton1Click, function()
                Page_Unified_Scroll.CanvasPosition = Vector2.new(0, math.clamp(Page_Unified_Scroll.CanvasPosition.Y - 30, 0, Page_Unified_Scroll.AbsoluteCanvasSize.Y - Page_Unified_Scroll.AbsoluteSize.Y))
            end)
            
            utility:CreateConnection(Unified_ArrowDown.MouseButton1Click, function()
                Page_Unified_Scroll.CanvasPosition = Vector2.new(0, math.clamp(Page_Unified_Scroll.CanvasPosition.Y + 30, 0, Page_Unified_Scroll.AbsoluteCanvasSize.Y - Page_Unified_Scroll.AbsoluteSize.Y))
            end)
            
            -- ✅ Scroll con la rueda del mouse (cuando está sobre la página)
            utility:CreateConnection(Page_Unified_Scroll.InputChanged, function(input)
                if input.UserInputType == Enum.UserInputType.MouseWheel then
                    local scrollDelta = -input.Position.Z * 40 -- 40 pixels por "tick" de la rueda
                    Page_Unified_Scroll.CanvasPosition = Vector2.new(
                        0, 
                        math.clamp(
                            Page_Unified_Scroll.CanvasPosition.Y + scrollDelta, 
                            0, 
                            Page_Unified_Scroll.AbsoluteCanvasSize.Y - Page_Unified_Scroll.AbsoluteSize.Y
                        )
                    )
                end
            end)
        end
    end
    --
    if #Page.Window.Pages == 0 then Page:Set(true) end
    Page.Window.Pages[#Page.Window.Pages + 1] = Page
    return setmetatable(Page, pages)
end
	--
-- ============================================================================
-- SISTEMA DE SUBTABS - AÑADIR DESPUÉS DE CreateSection
-- ============================================================================

-- Modificar la función CreateSection para soportar subtabs
function pages:CreateSection(Properties)
    Properties = Properties or {}
    
    local Section = {
        Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Section"),
        Size = (Properties.size or Properties.Size or 150),
        Side = (Properties.side or Properties.Side or "Left"),
        Content = {},
        Window = self.Window,
        Page = self,
        Subtabs = {}, -- NUEVO: almacenar subtabs
        CurrentSubtab = nil, -- NUEVO: subtab actual
        HasSubtabs = false -- NUEVO: flag para saber si tiene subtabs
    }
    
    do
        local Section_Holder = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(12, 12, 12),
            BorderMode = "Inset",
            BorderSizePixel = 1,
            Parent = Section.Page[Section.Side],
            Size = UDim2.new(1, 0, 0, Section.Size),
            ZIndex = 2
        })
        
        -- [... código existente de Section_Holder_Extra, Section_Holder_Frame, etc ...]
        local Section_Holder_Extra = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder,
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            ZIndex = 2
        })
        
        local Section_Holder_Frame = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(23, 23, 23),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder,
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            ZIndex = 2
        })
        
        local Section_Holder_TitleInline = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(23, 23, 23),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder,
            Position = UDim2.new(0, 9, 0, -1),
            Size = UDim2.new(0, 0, 0, 2),
            ZIndex = 5
        })
        
        local Section_Holder_Title = utility:RenderObject("TextLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(1, -26, 0, 15),
            ZIndex = 5,
            Font = "Code",
            RichText = true,
            Text = "<b>" .. Section.Name .. "</b>",
            TextColor3 = Color3.fromRGB(205, 205, 205),
            TextSize = 11,
            TextStrokeTransparency = 1,
            TextXAlignment = "Left"
        })
        
        -- NUEVO: Contenedor para botones de subtabs
        local Subtabs_Holder = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder_Frame,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 0), -- Altura 0 por defecto, se ajustará si hay subtabs
            Visible = false, -- Oculto hasta que se creen subtabs
            ZIndex = 4
        })
        
        local Subtabs_List = utility:RenderObject("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = Subtabs_Holder,
            FillDirection = "Horizontal",
            HorizontalAlignment = "Left",
            VerticalAlignment = "Center"
        })
        
        local Subtabs_Padding = utility:RenderObject("UIPadding", {
            Parent = Subtabs_Holder,
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4)
        })
        
        -- Línea separadora para subtabs
        local Subtabs_Separator = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder_Frame,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            Visible = false,
            ZIndex = 4
        })
        
        -- ScrollingFrame (ajustar posición para subtabs)
        local Holder_Frame_ContentHolder = utility:RenderObject("ScrollingFrame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder_Frame,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 4,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            BottomImage = "rbxassetid://7783554086",
            CanvasSize = UDim2.new(0, 0, 0, 0),
            MidImage = "rbxassetid://7783554086",
            ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
            ScrollBarImageTransparency = 0,
            ScrollBarThickness = 5,
            TopImage = "rbxassetid://7783554086",
            VerticalScrollBarInset = "None"
        })
        
        -- [... código existente de gradientes, flechas, etc ...]
        local Holder_Extra_Gradient1 = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(0, 1, 0, 1),
            Rotation = 180,
            Size = UDim2.new(1, -2, 0, 20),
            Visible = false,
            ZIndex = 4,
            Image = "rbxassetid://7783533907",
            ImageColor3 = Color3.fromRGB(23, 23, 23)
        })
        
        local Holder_Extra_Gradient2 = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, -2, 0, 20),
            Visible = false,
            ZIndex = 4,
            Image = "rbxassetid://7783533907",
            ImageColor3 = Color3.fromRGB(23, 23, 23)
        })
        
        local Holder_Extra_ArrowUp = utility:RenderObject("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(1, -21, 0, 0),
            Size = UDim2.new(0, 7 + 8, 0, 6 + 8),
            Text = "",
            Visible = false,
            ZIndex = 4
        })
        
        local Holder_Extra_ArrowDown = utility:RenderObject("TextButton", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(1, -21, 1, -(6 + 8)),
            Size = UDim2.new(0, 7 + 8, 0, 6 + 8),
            Text = "",
            Visible = false,
            ZIndex = 4
        })
        
        local Extra_ArrowUp_Image = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Holder_Extra_ArrowUp,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(0, 7, 0, 6),
            Visible = true,
            ZIndex = 4,
            Image = "rbxassetid://8548757311",
            ImageColor3 = Color3.fromRGB(205, 205, 205)
        })
        
        local Extra_ArrowDown_Image = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Holder_Extra_ArrowDown,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(0, 7, 0, 6),
            Visible = true,
            ZIndex = 4,
            Image = "rbxassetid://8548723563",
            ImageColor3 = Color3.fromRGB(205, 205, 205)
        })
        
        local Holder_Extra_Bar = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 6, 1, 0),
            Visible = false,
            ZIndex = 4
        })
        
        local Holder_Extra_Line = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Section_Holder_Extra,
            Position = UDim2.new(0, 0, 0, -1),
            Size = UDim2.new(1, 0, 0, 1),
            ZIndex = 4
        })
        
        local Frame_ContentHolder_List = utility:RenderObject("UIListLayout", {
            Padding = UDim.new(0, 0),
            Parent = Holder_Frame_ContentHolder,
            FillDirection = "Vertical",
            HorizontalAlignment = "Center",
            VerticalAlignment = "Top"
        })
        
        local Frame_ContentHolder_Padding = utility:RenderObject("UIPadding", {
            Parent = Holder_Frame_ContentHolder,
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        do -- Section Init
            Section_Holder_TitleInline.Size = UDim2.new(0, Section_Holder_Title.TextBounds.X + 6, 0, 2)
        end
        
        do -- Index Setting
            Section["Holder"] = Holder_Frame_ContentHolder
            Section["Extra"] = Section_Holder_Extra
            Section["SubtabsHolder"] = Subtabs_Holder
            Section["SubtabsSeparator"] = Subtabs_Separator
            Section["MainFrame"] = Section_Holder_Frame
        end
        
        do -- Functions
            function Section:CloseContent()
                if Section.Content.Open then
                    Section.Content:Close()
                    Section.Content = {}
                end
            end
            
            -- NUEVA FUNCIÓN: Ajustar posición del contenido cuando hay subtabs
			function Section:AdjustContentPosition()
				if not self.HasSubtabs then
					-- Sin subtabs: contenido ocupa todo el espacio
					self.Holder.Position = UDim2.new(0, 0, 0, 0)
					self.Holder.Size = UDim2.new(1, 0, 1, 0)
					self.SubtabsHolder.Visible = false
					self.SubtabsSeparator.Visible = false
					return
				end
				
				-- Con subtabs: dejar espacio arriba
				self.SubtabsHolder.Visible = true
				self.SubtabsSeparator.Visible = true
				
				-- 🔥 CORRECCIÓN: Calcular altura real del SubtabsHolder
				local subtabHeight = self.SubtabsHolder.AbsoluteSize.Y
				
				-- Si AbsoluteSize aún no está disponible, usar el valor calculado
				if subtabHeight == 0 then
					subtabHeight = 32 -- fallback: 20 (button) + 12 (padding)
				end
				
				-- Ajustar posición del contenido
				self.Holder.Position = UDim2.new(0, 0, 0, subtabHeight + 1)
				self.Holder.Size = UDim2.new(1, 0, 1, -(subtabHeight + 1))
				
				-- Posicionar el separador justo debajo de los botones
				self.SubtabsSeparator.Position = UDim2.new(0, 0, 0, subtabHeight)
				self.SubtabsSeparator.Size = UDim2.new(1, 0, 0, 1)
			end
        end
        
        do -- Connections
            utility:CreateConnection(Holder_Frame_ContentHolder:GetPropertyChangedSignal("AbsoluteCanvasSize"), function()
                Holder_Extra_Gradient1.Visible = Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y
                Holder_Extra_Gradient2.Visible = Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y
                Holder_Extra_Bar.Visible = Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y
                
                if (Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y > Holder_Frame_ContentHolder.AbsoluteWindowSize.Y) then
                    Holder_Extra_ArrowUp.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y > 5)
                    Holder_Extra_ArrowDown.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y + 5 < (Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
                end
            end)
            
            utility:CreateConnection(Holder_Frame_ContentHolder:GetPropertyChangedSignal("CanvasPosition"), function()
                if Section.Content.Open then
                    Section.Content:Close()
                    Section.Content = {}
                end
                
                Holder_Extra_ArrowUp.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y > 1)
                Holder_Extra_ArrowDown.Visible = (Holder_Frame_ContentHolder.CanvasPosition.Y + 1 < (Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
            end)
            
            utility:CreateConnection(Holder_Extra_ArrowUp.MouseButton1Click, function()
                Holder_Frame_ContentHolder.CanvasPosition = Vector2.new(0, math.clamp(Holder_Frame_ContentHolder.CanvasPosition.Y - 10, 0, Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
            end)
            
            utility:CreateConnection(Holder_Extra_ArrowDown.MouseButton1Click, function()
                Holder_Frame_ContentHolder.CanvasPosition = Vector2.new(0, math.clamp(Holder_Frame_ContentHolder.CanvasPosition.Y + 10, 0, Holder_Frame_ContentHolder.AbsoluteCanvasSize.Y - Holder_Frame_ContentHolder.AbsoluteSize.Y))
            end)
        end
    end
    
    return setmetatable(Section, sections)
end

-- ============================================================================
-- NUEVA FUNCIÓN: CreateSubtabs
-- ============================================================================

-- ============================================================================
-- NUEVA FUNCIÓN: CreateSubtabs (CORREGIDA)
-- ============================================================================
-- ============================================================================
-- FUNCIÓN CORREGIDA: CreateSubtabs con SCROLL COMPLETO
-- ============================================================================
-- ============================================================================
-- FUNCIÓN CORREGIDA: CreateSubtabs con SCROLL SIN CONFLICTOS
-- ============================================================================
-- ============================================================================
-- FUNCIÓN CORREGIDA: CreateSubtabs con SCROLL SIN CONFLICTOS
-- ============================================================================
-- ============================================================================
-- FUNCIÓN CORREGIDA: CreateSubtabs con SCROLL SIN CONFLICTOS
-- ============================================================================
function sections:CreateSubtabs(Properties)
    Properties = Properties or {}
    
    if not self.SubtabsHolder then
        warn("Esta sección no soporta subtabs")
        return
    end
    
    local Subtabs = Properties.tabs or Properties.Tabs or Properties.subtabs or Properties.Subtabs or {"Tab 1", "Tab 2"}
    
    self.HasSubtabs = true
    self.SubtabsHolder.Visible = true
    self.SubtabsSeparator.Visible = true
    
    local buttonHeight = 20
    local padding = 12
    local totalHeight = buttonHeight + padding
    
    self.SubtabsHolder.Size = UDim2.new(1, 0, 0, totalHeight)
    self.SubtabsHolder.ClipsDescendants = true
    
    -- 🔥 REFERENCIA AL SCROLL PADRE (Left o Right)
    local parentScrollFrame = self.Holder.Parent
    
    -- 🔥 OBTENER AMBOS SCROLLS DE LA PÁGINA (LEFT Y RIGHT)
    local pageLeftScroll = self.Page.Left
    local pageRightScroll = self.Page.Right
    
    for i, tabName in ipairs(Subtabs) do
        -- ========== CONTENEDOR PRINCIPAL ==========
        local SubtabMainContainer = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = self.Holder,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Visible = (i == 1),
            ZIndex = 4,
            RenderTime = 0.15
        })
        
        -- ========== SCROLLING FRAME (CONTENEDOR DEL CONTENIDO) ==========
        local SubtabScrollFrame = utility:RenderObject("ScrollingFrame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = SubtabMainContainer,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 4,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Color3.fromRGB(65, 65, 65),
            ScrollBarImageTransparency = 0,
            BottomImage = "rbxassetid://7783554086",
            MidImage = "rbxassetid://7783554086",
            TopImage = "rbxassetid://7783554086",
            VerticalScrollBarInset = "None",
            Active = true, -- ✅ IMPORTANTE: Permite capturar eventos
            ScrollingEnabled = true,
            RenderTime = 0.15
        })
        
        -- ========== 🔥 FIX: DESACTIVAR EL SCROLL UNIFICADO DE LA PÁGINA ==========
        local mouseOverSubtab = false
        
        SubtabScrollFrame.MouseEnter:Connect(function()
            mouseOverSubtab = true
            -- 🎯 Deshabilitar el scroll unificado de la página
            if pageUnifiedScroll and pageUnifiedScroll:IsA("ScrollingFrame") then
                pageUnifiedScroll.ScrollingEnabled = false
            end
        end)
        
        SubtabScrollFrame.MouseLeave:Connect(function()
            mouseOverSubtab = false
            -- Rehabilitar el scroll unificado con pequeño delay
            task.wait(0.05)
            if pageUnifiedScroll and pageUnifiedScroll:IsA("ScrollingFrame") then
                pageUnifiedScroll.ScrollingEnabled = true
            end
        end)
        
        -- ========== 🔥 FIX: DETECTAR CUANDO EL SUBTAB NECESITA SCROLL ==========
        SubtabScrollFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(function()
            local needsScroll = SubtabScrollFrame.AbsoluteCanvasSize.Y > SubtabScrollFrame.AbsoluteWindowSize.Y
            
            -- Si el subtab NO necesita scroll, no bloquear el scroll de la página
            if not needsScroll and mouseOverSubtab then
                if pageUnifiedScroll and pageUnifiedScroll:IsA("ScrollingFrame") then
                    pageUnifiedScroll.ScrollingEnabled = true
                end
            end
        end)
        
        -- ========== UI LIST LAYOUT ==========
        local SubtabList = utility:RenderObject("UIListLayout", {
            Padding = UDim.new(0, 0),
            Parent = SubtabScrollFrame,
            FillDirection = "Vertical",
            HorizontalAlignment = "Center",
            VerticalAlignment = "Top"
        })
        
        local SubtabPadding = utility:RenderObject("UIPadding", {
            Parent = SubtabScrollFrame,
            PaddingTop = UDim.new(0, 15),
            PaddingBottom = UDim.new(0, 15)
        })
        
        -- ========== GRADIENTES SUPERIOR E INFERIOR ==========
        local Gradient1 = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = SubtabMainContainer,
            Position = UDim2.new(0, 1, 0, 1),
            Rotation = 180,
            Size = UDim2.new(1, -2, 0, 20),
            Visible = false,
            ZIndex = 5,
            Image = "rbxassetid://7783533907",
            ImageColor3 = Color3.fromRGB(23, 23, 23),
            RenderTime = 0.15
        })
        
        local Gradient2 = utility:RenderObject("ImageLabel", {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = SubtabMainContainer,
            Position = UDim2.new(0, 0, 1, 0),
            Size = UDim2.new(1, -2, 0, 20),
            Visible = false,
            ZIndex = 5,
            Image = "rbxassetid://7783533907",
            ImageColor3 = Color3.fromRGB(23, 23, 23),
            RenderTime = 0.15
        })
        
        -- ========== FLECHA ARRIBA ==========
        local ArrowUp = utility:RenderObject("TextButton", {
            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = SubtabMainContainer,
            Position = UDim2.new(1, -21, 0, 0),
            Size = UDim2.new(0, 7 + 8, 0, 6 + 8),
            Text = "",
            Visible = false,
            ZIndex = 5,
            RenderTime = 0.15
        })
        
        local ArrowUpImage = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = ArrowUp,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(0, 7, 0, 6),
            Visible = true,
            ZIndex = 5,
            Image = "rbxassetid://8548757311",
            ImageColor3 = Color3.fromRGB(205, 205, 205),
            RenderTime = 0.15
        })
        
        -- ========== FLECHA ABAJO ==========
        local ArrowDown = utility:RenderObject("TextButton", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = SubtabMainContainer,
            Position = UDim2.new(1, -21, 1, -(6 + 8)),
            Size = UDim2.new(0, 7 + 8, 0, 6 + 8),
            Text = "",
            Visible = false,
            ZIndex = 5,
            RenderTime = 0.15
        })
        
        local ArrowDownImage = utility:RenderObject("ImageLabel", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = ArrowDown,
            Position = UDim2.new(0, 4, 0, 4),
            Size = UDim2.new(0, 7, 0, 6),
            Visible = true,
            ZIndex = 5,
            Image = "rbxassetid://8548723563",
            ImageColor3 = Color3.fromRGB(205, 205, 205),
            RenderTime = 0.15
        })
        
        -- ========== BARRA LATERAL ==========
        local ScrollBar = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Color3.fromRGB(45, 45, 45),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = SubtabMainContainer,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(0, 6, 1, 0),
            Visible = false,
            ZIndex = 5,
            RenderTime = 0.15
        })
        
        -- ========== CONEXIONES DE SCROLL ==========
        utility:CreateConnection(SubtabScrollFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"), function()
            local needsScroll = SubtabScrollFrame.AbsoluteCanvasSize.Y > SubtabScrollFrame.AbsoluteWindowSize.Y
            
            Gradient1.Visible = needsScroll
            Gradient2.Visible = needsScroll
            ScrollBar.Visible = needsScroll
            
            if needsScroll then
                ArrowUp.Visible = (SubtabScrollFrame.CanvasPosition.Y > 5)
                ArrowDown.Visible = (SubtabScrollFrame.CanvasPosition.Y + 5 < (SubtabScrollFrame.AbsoluteCanvasSize.Y - SubtabScrollFrame.AbsoluteSize.Y))
            end
        end)
        
        utility:CreateConnection(SubtabScrollFrame:GetPropertyChangedSignal("CanvasPosition"), function()
            ArrowUp.Visible = (SubtabScrollFrame.CanvasPosition.Y > 1)
            ArrowDown.Visible = (SubtabScrollFrame.CanvasPosition.Y + 1 < (SubtabScrollFrame.AbsoluteCanvasSize.Y - SubtabScrollFrame.AbsoluteSize.Y))
        end)
        
        utility:CreateConnection(ArrowUp.MouseButton1Click, function()
            SubtabScrollFrame.CanvasPosition = Vector2.new(0, math.clamp(SubtabScrollFrame.CanvasPosition.Y - 10, 0, SubtabScrollFrame.AbsoluteCanvasSize.Y - SubtabScrollFrame.AbsoluteSize.Y))
        end)
        
        utility:CreateConnection(ArrowDown.MouseButton1Click, function()
            SubtabScrollFrame.CanvasPosition = Vector2.new(0, math.clamp(SubtabScrollFrame.CanvasPosition.Y + 10, 0, SubtabScrollFrame.AbsoluteCanvasSize.Y - SubtabScrollFrame.AbsoluteSize.Y))
        end)
        
        -- ========== BOTÓN DE SUBTAB ==========
        local SubtabButton = utility:RenderObject("TextButton", {
            BackgroundColor3 = (i == 1) and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(25, 25, 25),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = self.SubtabsHolder,
            Size = UDim2.new(0, 0, 0, buttonHeight),
            AutomaticSize = Enum.AutomaticSize.X,
            Font = "Code",
            Text = "  " .. tabName .. "  ",
            TextColor3 = (i == 1) and self.Window.Accent or Color3.fromRGB(155, 155, 155),
            TextSize = 10,
            ZIndex = 5,
            RenderTime = 0.15
        })
        
        local ButtonCorner = utility:RenderObject("UICorner", {
            CornerRadius = UDim.new(0, 3),
            Parent = SubtabButton
        })
        
        local ButtonPadding = utility:RenderObject("UIPadding", {
            Parent = SubtabButton,
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8)
        })
        
        -- ========== INDICADOR ACTIVO ==========
        local ActiveIndicator = utility:RenderObject("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = self.Window.Accent,
            BackgroundTransparency = (i == 1) and 0 or 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = SubtabButton,
            Position = UDim2.new(0.5, 0, 1, -1),
            Size = UDim2.new(1, -6, 0, 2),
            ZIndex = 6,
            RenderTime = 0.15
        })
        
        local IndicatorCorner = utility:RenderObject("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = ActiveIndicator
        })
        
        -- ========== GUARDAR REFERENCIAS ==========
        self.Subtabs[i] = {
            Name = tabName,
            Container = SubtabScrollFrame,
            MainContainer = SubtabMainContainer,
            Button = SubtabButton,
            Indicator = ActiveIndicator,
            Active = (i == 1)
        }
        
        -- ========== INICIALIZAR ESTADO ==========
        if i == 1 then
            ActiveIndicator.Visible = true
            ActiveIndicator.BackgroundTransparency = 0
            SubtabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            SubtabButton.TextColor3 = self.Window.Accent
        else
            ActiveIndicator.Visible = false
            ActiveIndicator.BackgroundTransparency = 1
            SubtabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            SubtabButton.TextColor3 = Color3.fromRGB(155, 155, 155)
        end
        
        -- ========== CONEXIÓN DEL BOTÓN ==========
        utility:CreateConnection(SubtabButton.MouseButton1Click, function()
            self:SwitchSubtab(i)
        end)
        
        -- ========== EFECTOS HOVER ANIMADOS ==========
        utility:CreateConnection(SubtabButton.MouseEnter, function()
            if not self.Subtabs[i].Active then
                tws:Create(SubtabButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                }):Play()
                
                tws:Create(SubtabButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextColor3 = Color3.fromRGB(200, 200, 200)
                }):Play()
            end
        end)
        
        utility:CreateConnection(SubtabButton.MouseLeave, function()
            if not self.Subtabs[i].Active then
                tws:Create(SubtabButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                }):Play()
                
                tws:Create(SubtabButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    TextColor3 = Color3.fromRGB(155, 155, 155)
                }):Play()
            end
        end)
    end
    
    self.CurrentSubtab = 1
    self:AdjustContentPosition()
    
    return self.Subtabs
end

-- ============================================================================
-- FUNCIÓN CORREGIDA: SwitchSubtab
-- ============================================================================
function sections:SwitchSubtab(index)
    if not self.Subtabs[index] then return end
    
    local tweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- 🎨 Desactivar todos con animación
    for i, subtab in ipairs(self.Subtabs) do
        -- Ocultar contenedor principal inmediatamente
        subtab.MainContainer.Visible = false
        subtab.Active = false
        
        -- ✅ Animar botón inactivo
        tweenService:Create(subtab.Button, tweenInfo, {
            BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        }):Play()
        
        tweenService:Create(subtab.Button, tweenInfo, {
            TextColor3 = Color3.fromRGB(155, 155, 155)
        }):Play()
        
        -- ✅ Fade out del indicador
        if i ~= index and subtab.Indicator.BackgroundTransparency < 1 then
            local fadeTween = tweenService:Create(subtab.Indicator, tweenInfo, {
                BackgroundTransparency = 1
            })
            fadeTween:Play()
            
            fadeTween.Completed:Connect(function()
                subtab.Indicator.Visible = false
            end)
        end
    end
    
    -- 🎨 Activar el seleccionado con animación
    local selected = self.Subtabs[index]
    selected.MainContainer.Visible = true
    selected.Active = true
    
    -- Animar botón activo
    tweenService:Create(selected.Button, tweenInfo, {
        BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    }):Play()
    
    tweenService:Create(selected.Button, tweenInfo, {
        TextColor3 = self.Window.Accent
    }):Play()
    
    -- ✅ Fade in del indicador
    selected.Indicator.Visible = true
    selected.Indicator.BackgroundColor3 = self.Window.Accent
    
    tweenService:Create(selected.Indicator, tweenInfo, {
        BackgroundTransparency = 0
    }):Play()
    
    self.CurrentSubtab = index
    
    -- Reset scroll con animación
    if selected.Container and selected.Container.CanvasPosition then
        tweenService:Create(selected.Container, tweenInfo, {
            CanvasPosition = Vector2.new(0, 0)
        }):Play()
    end
end

-- ============================================================================
-- FUNCIÓN CORREGIDA: GetCurrentSubtabContainer
-- ============================================================================
function sections:GetCurrentSubtabContainer()
    if self.HasSubtabs and self.CurrentSubtab then
        -- ✅ Ahora devuelve el ScrollingFrame correcto
        return self.Subtabs[self.CurrentSubtab].Container
    end
    return self.Holder
end
-- ============================================================================
-- MODIFICAR FUNCIONES DE CREACIÓN DE CONTROLES
-- ============================================================================

-- Modificar CreateToggle, CreateSlider, etc. para usar GetCurrentSubtabContainer()
-- Ejemplo con CreateToggle (aplicar lo mismo a todos los demás):

local originalCreateToggle = sections.CreateToggle

sections.CreateToggle = function(self, Properties)
    Properties = Properties or {}
    
    local Content = {
        Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Toggle"),
        State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or false),
        Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
        Window = self.Window,
        Page = self.Page,
        Section = self
    }
    
    local colorpickers = Properties.colorpickers or Properties.Colorpickers or {}
    local numColorpickers = type(colorpickers) == "table" and #colorpickers or 0
    
    -- CAMBIO IMPORTANTE: Usar el contenedor correcto según si hay subtabs
    local parentContainer = self:GetCurrentSubtabContainer()
    
    do
        local Content_Holder = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = parentContainer, -- USAR parentContainer en lugar de Content.Section.Holder
            Size = UDim2.new(1, 0, 0, 8 + 10),
            ZIndex = 3
        })
        
        -- ... resto del código de CreateToggle sin cambios ...
    end
    
    return Content
end

-- HACER LO MISMO PARA:
-- - CreateSlider
-- - CreateDropdown
-- - CreateMultibox
-- - CreateKeybind
-- - CreateColorpicker
-- - CreateButton
-- - CreateTextbox
-- etc.
	--
	do -- // Content
-- ============================================================================
-- 🎨 COLORPICKER MEJORADO DENTRO DE TOGGLE
-- ============================================================================


function sections:CreateToggle(Properties)
    Properties = Properties or {}
    
    local Content = {
        Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Toggle"),
        State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or false),
        Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
        Window = self.Window,
        Page = self.Page,
        Section = self
    }
    local parentContainer = self:GetCurrentSubtabContainer()
    
    local colorpickers = Properties.colorpickers or Properties.Colorpickers or {}
    local numColorpickers = type(colorpickers) == "table" and #colorpickers or 0
    
    do
        local Content_Holder = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = parentContainer,
            Size = UDim2.new(1, 0, 0, 8 + 10),
            ZIndex = 3
        })
        
        local Content_Holder_Outline = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(12, 12, 12),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Content_Holder,
            Position = UDim2.new(0, 20, 0, 5),
            Size = UDim2.new(0, 8, 0, 8),
            ZIndex = 3
        })
        
        local textWidthReduction = numColorpickers > 0 and (numColorpickers * 24 + 8) or 0
        
        local Content_Holder_Title = utility:RenderObject("TextLabel", {
            AnchorPoint = Vector2.new(0, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Content_Holder,
            Position = UDim2.new(0, 41, 0, 0),
            Size = UDim2.new(1, -41 - textWidthReduction, 1, 0),
            ZIndex = 3,
            Font = "Code",
            RichText = true,
            Text = Content.Name,
            TextColor3 = Color3.fromRGB(205, 205, 205),
            TextSize = 9,
            TextStrokeTransparency = 1,
            TextXAlignment = "Left"
        })
        
        local Content_Holder_Title2 = utility:RenderObject("TextLabel", {
            AnchorPoint = Vector2.new(0, 0),
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Content_Holder,
            Position = UDim2.new(0, 41, 0, 0),
            Size = UDim2.new(1, -41 - textWidthReduction, 1, 0),
            ZIndex = 3,
            Font = "Code",
            RichText = true,
            Text = Content.Name,
            TextColor3 = Color3.fromRGB(205, 205, 205),
            TextSize = 9,
            TextStrokeTransparency = 1,
            TextTransparency = 0.5,
            TextXAlignment = "Left"
        })
        
        local buttonWidthReduction = numColorpickers > 0 and (numColorpickers * 24 + 8) or 0
        
        local Content_Holder_Button = utility:RenderObject("TextButton", {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 1,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Content_Holder,
            Size = UDim2.new(1, -buttonWidthReduction, 1, 0),
            Text = ""
        })
        
        local Holder_Outline_Frame = utility:RenderObject("Frame", {
            BackgroundColor3 = Color3.fromRGB(77, 77, 77),
            BackgroundTransparency = 0,
            BorderColor3 = Color3.fromRGB(0, 0, 0),
            BorderSizePixel = 0,
            Parent = Content_Holder_Outline,
            Position = UDim2.new(0, 1, 0, 1),
            Size = UDim2.new(1, -2, 1, -2),
            ZIndex = 3
        })
        
        local Outline_Frame_Gradient = utility:RenderObject("UIGradient", {
            Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(140, 140, 140)),
            Enabled = true,
            Rotation = 90,
            Parent = Holder_Outline_Frame
        })
        
        Content.Window.ToggleAccents = Content.Window.ToggleAccents or {}
        table.insert(Content.Window.ToggleAccents, {
            Frame = Holder_Outline_Frame,
            GetState = function() return Content.State end,
            ContentRef = Content
        })
        
        -- ========== 🎨 COLORPICKERS MEJORADOS ==========
        if numColorpickers > 0 then
            for i, cpData in ipairs(colorpickers) do
                if type(cpData) == "table" then
                    local cpXOffset = -((numColorpickers - i + 1) * 24 + 4)
                    
                    local cpState = (type(cpData.State) == "userdata" and cpData.State) or Color3.fromRGB(255, 255, 255)
                    local cpCallback = type(cpData.Callback) == "function" and cpData.Callback or function() end
                    local cpOpen = false
                    
                    local CP_Outline = utility:RenderObject("Frame", {
                        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
                        BackgroundTransparency = 0,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Parent = Content_Holder,
                        Position = UDim2.new(1, cpXOffset, 0, 4),
                        Size = UDim2.new(0, 17, 0, 9),
                        ZIndex = 4
                    })
                    
                    local CP_Frame = utility:RenderObject("Frame", {
                        BackgroundColor3 = cpState,
                        BackgroundTransparency = 0,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Parent = CP_Outline,
                        Position = UDim2.new(0, 1, 0, 1),
                        Size = UDim2.new(1, -2, 1, -2),
                        ZIndex = 4
                    })
                    
                    local CP_Gradient = utility:RenderObject("UIGradient", {
                        Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(140, 140, 140)),
                        Enabled = true,
                        Rotation = 90,
                        Parent = CP_Frame
                    })
                    
                    local CP_Button = utility:RenderObject("TextButton", {
                        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                        BackgroundTransparency = 1,
                        BorderColor3 = Color3.fromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        Parent = CP_Outline,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        ZIndex = 5
                    })
                    
                    -- ========== 🎨 FUNCIÓN PARA ABRIR COLOR PICKER MEJORADO ==========
                    local function OpenColorPicker()
                        if cpOpen then return end
                        cpOpen = true
                        
                        Content.Section:CloseContent()
                        
                        local Connections = {}
                        local InputCheck
                        
                        -- ========== CONTENEDOR PRINCIPAL ==========
                        local Content_Open_Holder = utility:RenderObject("Frame", {
                            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Parent = Content.Section.Extra,
                            Position = UDim2.new(0, CP_Outline.AbsolutePosition.X - Content.Section.Extra.AbsolutePosition.X - 80, 0, CP_Outline.AbsolutePosition.Y - Content.Section.Extra.AbsolutePosition.Y + 10),
                            Size = UDim2.new(0, 200, 0, 220),
                            ZIndex = 6
                        })
                        
                        -- ========== BORDE EXTERIOR ==========
                        local Open_Holder_Outline = utility:RenderObject("Frame", {
                            BackgroundColor3 = Color3.fromRGB(40, 42, 54),
                            BackgroundTransparency = 0,
                            BorderColor3 = Color3.fromRGB(68, 71, 90),
                            BorderMode = "Inset",
                            BorderSizePixel = 2,
                            Parent = Content_Open_Holder,
                            Size = UDim2.new(1, 0, 1, 0),
                            ZIndex = 6
                        })
                        
                        local Open_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(0, 8),
                            Parent = Open_Holder_Outline
                        })
                        
                        -- ========== FRAME INTERIOR ==========
                        local Open_Outline_Frame = utility:RenderObject("Frame", {
                            BackgroundColor3 = Color3.fromRGB(30, 32, 42),
                            BackgroundTransparency = 0,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Parent = Open_Holder_Outline,
                            Position = UDim2.new(0, 4, 0, 4),
                            Size = UDim2.new(1, -8, 1, -8),
                            ZIndex = 6
                        })
                        
                        local Inner_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(0, 6),
                            Parent = Open_Outline_Frame
                        })
                        
                        -- ========== SELECTOR 2D (SAT/VAL) ==========
                        local ValSat_Picker_Outline = utility:RenderObject("Frame", {
                            BackgroundColor3 = Color3.fromRGB(20, 22, 30),
                            BackgroundTransparency = 0,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Parent = Open_Outline_Frame,
                            Position = UDim2.new(0, 8, 0, 8),
                            Size = UDim2.new(0, 152, 0, 152),
                            ZIndex = 6
                        })
                        
                        local VSat_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = ValSat_Picker_Outline
                        })
                        
                        -- ========== BARRA DE HUE ==========
                        local Hue_Picker_Outline = utility:RenderObject("Frame", {
                            BackgroundColor3 = Color3.fromRGB(20, 22, 30),
                            BackgroundTransparency = 0,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Parent = Open_Outline_Frame,
                            Position = UDim2.new(1, -24, 0, 8),
                            Size = UDim2.new(0, 16, 0, 152),
                            ZIndex = 6
                        })
                        
                        local Hue_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = Hue_Picker_Outline
                        })
                        
                        -- ========== CAMPO DE TEXTO HEX ==========
                        local Hex_Container = utility:RenderObject("Frame", {
                            BackgroundColor3 = Color3.fromRGB(20, 22, 30),
                            BackgroundTransparency = 0,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Parent = Open_Outline_Frame,
                            Position = UDim2.new(0, 8, 1, -36),
                            Size = UDim2.new(1, -16, 0, 28),
                            ZIndex = 6
                        })
                        
                        local Hex_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(0, 4),
                            Parent = Hex_Container
                        })
                        
                        local Hex_Label = utility:RenderObject("TextLabel", {
                            BackgroundTransparency = 1,
                            Parent = Hex_Container,
                            Position = UDim2.new(0, 8, 0, 0),
                            Size = UDim2.new(0, 25, 1, 0),
                            Font = Enum.Font.Code,
                            Text = "HEX",
                            TextColor3 = Color3.fromRGB(150, 155, 175),
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 7
                        })
                        
                        local Hex_TextBox = utility:RenderObject("TextBox", {
                            BackgroundTransparency = 1,
                            Parent = Hex_Container,
                            Position = UDim2.new(0, 40, 0, 0),
                            Size = UDim2.new(1, -48, 1, 0),
                            Font = Enum.Font.Code,
                            PlaceholderText = "#ffffff",
                            Text = Color3ToHex(cpState),
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ClearTextOnFocus = false,
                            ZIndex = 7
                        })
                        
                        -- ========== GRADIENTE 2D ==========
                        local ValSat_Picker_Color = utility:RenderObject("Frame", {
                            BackgroundColor3 = Color3.fromHSV(0,1,1),
                            BackgroundTransparency = 0,
                            BorderColor3 = Color3.fromRGB(0, 0, 0),
                            BorderSizePixel = 0,
                            Parent = ValSat_Picker_Outline,
                            Position = UDim2.new(0, 2, 0, 2),
                            Size = UDim2.new(1, -4, 1, -4),
                            ZIndex = 6
                        })
                        
                        local VSat_Inner_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(0, 3),
                            Parent = ValSat_Picker_Color
                        })
                        
                        -- Gradiente horizontal (blanco a transparente)
                        local Sat_Gradient = utility:RenderObject("Frame", {
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            Parent = ValSat_Picker_Color,
                            Size = UDim2.new(1, 0, 1, 0),
                            ZIndex = 6
                        })
                        
                        local Sat_Grad = utility:RenderObject("UIGradient", {
                            Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)),
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(1, 1)
                            }),
                            Rotation = 0,
                            Parent = Sat_Gradient
                        })
                        
                        local Sat_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(0, 3),
                            Parent = Sat_Gradient
                        })
                        
                        -- Gradiente vertical (transparente a negro)
                        local Val_Gradient = utility:RenderObject("Frame", {
                            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            Parent = ValSat_Picker_Color,
                            Size = UDim2.new(1, 0, 1, 0),
                            ZIndex = 7
                        })
                        
                        local Val_Grad = utility:RenderObject("UIGradient", {
                            Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0)),
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(1, 0)
                            }),
                            Rotation = 90,
                            Parent = Val_Gradient
                        })
                        
                        local Val_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(0, 3),
                            Parent = Val_Gradient
                        })
                        
                        -- ========== CURSOR 2D ==========
                        local VS_Cursor = utility:RenderObject("Frame", {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundColor3 = Color3.fromRGB(255,255,255),
                            BackgroundTransparency = 1,
                            BorderColor3 = Color3.fromRGB(255,255,255),
                            BorderSizePixel = 3,
                            Size = UDim2.new(0,14,0,14),
                            ZIndex = 8,
                            Parent = ValSat_Picker_Color
                        })
                        
                        local VS_Cursor_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(1, 0),
                            Parent = VS_Cursor
                        })
                        
                        local VS_Cursor_Inner = utility:RenderObject("Frame", {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundColor3 = Color3.fromRGB(0,0,0),
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            Size = UDim2.new(0,4,0,4),
                            ZIndex = 9,
                            Parent = VS_Cursor
                        })
                        
                        local VS_Inner_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(1, 0),
                            Parent = VS_Cursor_Inner
                        })
                        
                        -- ========== GRADIENTE HUE ==========
                        local Hue_Gradient_Frame = utility:RenderObject("Frame", {
                            BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                            BackgroundTransparency = 0,
                            BorderSizePixel = 0,
                            Parent = Hue_Picker_Outline,
                            Position = UDim2.new(0, 2, 0, 2),
                            Size = UDim2.new(1, -4, 1, -4),
                            ZIndex = 6
                        })
                        
                        local Hue_Gradient_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(0, 3),
                            Parent = Hue_Gradient_Frame
                        })
                        
                        local Hue_Gradient = utility:RenderObject("UIGradient", {
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                            }),
                            Rotation = 90,
                            Parent = Hue_Gradient_Frame
                        })
                        
                        -- ========== CURSOR HUE ==========
                        local Hue_Cursor = utility:RenderObject("Frame", {
                            AnchorPoint = Vector2.new(0.5,0.5),
                            BackgroundColor3 = Color3.fromRGB(255,255,255),
                            BorderColor3 = Color3.fromRGB(0,0,0),
                            BorderSizePixel = 2,
                            Size = UDim2.new(1,4,0,4),
                            ZIndex = 7,
                            Parent = Hue_Picker_Outline
                        })
                        
                        local Hue_Cursor_Corner = utility:RenderObject("UICorner", {
                            CornerRadius = UDim.new(0, 2),
                            Parent = Hue_Cursor
                        })
                        
                        -- ========== LÓGICA DEL COLOR PICKER ==========
                        local hue, sat, val = 0, 1, 1
                        if typeof(cpState) == "Color3" then
                            local h,s,v = Color3.toHSV(cpState)
                            hue, sat, val = h or 0, s or 1, v or 1
                        end
                        
                        local function clamp(v) return math.clamp(v, 0, 1) end
                        
                        local function updatePreview()
                            local selected = Color3.fromHSV(hue, sat, val)
                            pcall(function()
                                ValSat_Picker_Color.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                                CP_Frame.BackgroundColor3 = selected
                                Hex_TextBox.Text = Color3ToHex(selected)
                            end)
                            
                            local yPos = 1 - val
                            pcall(function()
                                VS_Cursor.Position = UDim2.new(sat, 0, yPos, 0)
                                Hue_Cursor.Position = UDim2.new(0.5, 0, 1 - hue, 0)
                            end)
                        end
                        
                        local draggingVS = false
                        local draggingHue = false
                        
                        local function setFromValSatFromMouse()
                            local mouse = utility:MouseLocation()
                            local x = clamp((mouse.X - ValSat_Picker_Outline.AbsolutePosition.X) / math.max(1, ValSat_Picker_Outline.AbsoluteSize.X))
                            local y = clamp((mouse.Y - ValSat_Picker_Outline.AbsolutePosition.Y) / math.max(1, ValSat_Picker_Outline.AbsoluteSize.Y))
                            sat = x
                            val = 1 - y
                            updatePreview()
                            local col = Color3.fromHSV(hue, sat, val)
                            cpState = col
                            pcall(function() cpCallback(col) end)
                        end
                        
                        local function setFromHueFromMouse()
                            local mouse = utility:MouseLocation()
                            local y = clamp((mouse.Y - Hue_Picker_Outline.AbsolutePosition.Y) / math.max(1, Hue_Picker_Outline.AbsoluteSize.Y))
                            hue = 1 - y
                            updatePreview()
                            local col = Color3.fromHSV(hue, sat, val)
                            cpState = col
                            pcall(function() cpCallback(col) end)
                        end
                        
                        updatePreview()
                        
                        -- ========== EVENTOS ==========
                        table.insert(Connections, utility:CreateConnection(ValSat_Picker_Color.InputBegan, function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                draggingVS = true
                                setFromValSatFromMouse()
                            end
                        end))
                        
                        table.insert(Connections, utility:CreateConnection(Hue_Picker_Outline.InputBegan, function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                draggingHue = true
                                setFromHueFromMouse()
                            end
                        end))
                        
                        table.insert(Connections, utility:CreateConnection(uis.InputChanged, function(input)
                            if draggingVS and input.UserInputType == Enum.UserInputType.MouseMovement then
                                setFromValSatFromMouse()
                            elseif draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
                                setFromHueFromMouse()
                            end
                        end))
                        
                        table.insert(Connections, utility:CreateConnection(uis.InputEnded, function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                draggingVS = false
                                draggingHue = false
                            end
                        end))
                        
                        -- ========== TEXTBOX HEX ==========
                        Hex_TextBox.FocusLost:Connect(function(enterPressed)
                            local hexText = Hex_TextBox.Text
                            local newColor = HexToColor3(hexText)
                            
                            local h, s, v = Color3.toHSV(newColor)
                            hue, sat, val = h, s, v
                            cpState = newColor
                            
                            updatePreview()
                            CP_Frame.BackgroundColor3 = newColor
                            pcall(function() cpCallback(newColor) end)
                        end)
                        
                        -- ========== CERRAR AL HACER CLICK FUERA ==========
                        InputCheck = utility:CreateConnection(uis.InputBegan, function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                                local Mouse = utility:MouseLocation()
                                if not (Mouse.X > Content_Open_Holder.AbsolutePosition.X and Mouse.Y > (Content_Open_Holder.AbsolutePosition.Y + 36) and Mouse.X < (Content_Open_Holder.AbsolutePosition.X + Content_Open_Holder.AbsoluteSize.X) and Mouse.Y < (Content_Open_Holder.AbsolutePosition.Y + Content_Open_Holder.AbsoluteSize.Y + 36)) then
                                    if not (Mouse.X > CP_Outline.AbsolutePosition.X and Mouse.Y > CP_Outline.AbsolutePosition.Y and Mouse.X < (CP_Outline.AbsolutePosition.X + CP_Outline.AbsoluteSize.X) and Mouse.Y < (CP_Outline.AbsolutePosition.Y + CP_Outline.AbsoluteSize.Y)) then
                                        for _, conn in pairs(Connections) do
                                            pcall(function() conn:Disconnect() end)
                                        end
                                        pcall(function() InputCheck:Disconnect() end)
                                        pcall(function() Content_Open_Holder:Destroy() end)
                                        cpOpen = false
                                    end
                                end
                            end
                        end)
                    end
                    
                    utility:CreateConnection(CP_Button.MouseButton1Click, function()
                        OpenColorPicker()
                    end)
                    
                    utility:CreateConnection(CP_Button.MouseEnter, function()
                        CP_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(180, 180, 180))
                    end)
                    
                    utility:CreateConnection(CP_Button.MouseLeave, function()
                        CP_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(140, 140, 140))
                    end)
                end
            end
        end
        
        -- ========== FUNCIONES DEL TOGGLE ==========
        function Content:Set(state)
            Content.State = state
            Holder_Outline_Frame.BackgroundColor3 = Content.State and Content.Window.Accent or Color3.fromRGB(77, 77, 77)
            Content.Callback(Content:Get())
        end
        
        function Content:Get()
            return Content.State
        end
        
        -- ========== CONEXIONES ==========
        utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function(Input)
            Content:Set(not Content:Get())
        end)
        
        utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
            Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(180, 180, 180))
        end)
        
        utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
            Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(140, 140, 140))
        end)
        
        Content:Set(Content.State)
    end
    
    return Content
end

		function sections:CreateSlider(Properties)
		Properties = Properties or {}
			
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or nil),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or false),
				Min = (Properties.min or Properties.Min or Properties.minimum or Properties.Minimum or 0),
				Max = (Properties.max or Properties.Max or Properties.maxmimum or Properties.Maximum or 100),
				Ending = (Properties.ending or Properties.Ending or Properties.suffix or Properties.Suffix or ""),
				Decimals = (1 / (Properties.decimals or Properties.Decimals or Properties.tick or Properties.Tick or 1)),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Holding = false,
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			
			-- CAMBIO: Usar contenedor correcto
			local parentContainer = self:GetCurrentSubtabContainer()
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
           			Parent = parentContainer, 
					Size = UDim2.new(1, 0, 0, (Content.Name and 24 or 13) + 5),
					ZIndex = 3
				})
				-- //
				local Content_Holder_Outline = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(12, 12, 12),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 40, 0, Content.Name and 18 or 5),
					Size = UDim2.new(1, -99, 0, 7),
					ZIndex = 3
				})
				--
				if Content.Name then
					local Content_Holder_Title = utility:RenderObject("TextLabel", {
						AnchorPoint = Vector2.new(0, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Parent = Content_Holder,
						Position = UDim2.new(0, 41, 0, 4),
						Size = UDim2.new(1, -41, 0, 10),
						ZIndex = 3,
						Font = "Code",
						RichText = true,
						Text = Content.Name,
						TextColor3 = Color3.fromRGB(205, 205, 205),
						TextSize = 9,
						TextStrokeTransparency = 1,
						TextXAlignment = "Left"
					})
					--
					local Content_Holder_Title2 = utility:RenderObject("TextLabel", {
						AnchorPoint = Vector2.new(0, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Parent = Content_Holder,
						Position = UDim2.new(0, 41, 0, 4),
						Size = UDim2.new(1, -41, 0, 10),
						ZIndex = 3,
						Font = "Code",
						RichText = true,
						Text = Content.Name,
						TextColor3 = Color3.fromRGB(205, 205, 205),
						TextSize = 9,
						TextStrokeTransparency = 1,
						TextTransparency = 0.5,
						TextXAlignment = "Left"
					})
				end
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				-- //
				local Holder_Outline_Frame = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(71, 71, 71),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder_Outline,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					ZIndex = 3
				})
				-- //
				local Outline_Frame_Slider = utility:RenderObject("Frame", {
					BackgroundColor3 = Content.Window.Accent,
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(0, 0, 0, 0),
					Size = UDim2.new(0, 0, 1, 0),
					ZIndex = 3
				})
				--
				Content.Window.Sliders = Content.Window.Sliders or {}
				table.insert(Content.Window.Sliders, Outline_Frame_Slider)
				--
				local Outline_Frame_Gradient = utility:RenderObject("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(175, 175, 175)),
					Enabled = true,
					Rotation = 270,
					Parent = Holder_Outline_Frame
				})
                -- //
                local Frame_Slider_Gradient = utility:RenderObject("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(175, 175, 175)),
					Enabled = true,
					Rotation = 90,
					Parent = Outline_Frame_Slider
				})
				-- //
				local Frame_Slider_Title = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Outline_Frame_Slider,
					Position = UDim2.new(1, 0, 0.5, 1),
					Size = UDim2.new(0, 2, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = "",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 11,
					TextStrokeTransparency = 0.5,
					TextXAlignment = "Center",
					RenderTime = 0.15
				})
				--
				local Frame_Slider_Title2 = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Outline_Frame_Slider,
					Position = UDim2.new(1, 0, 0.5, 1),
					Size = UDim2.new(0, 2, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = "",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 11,
					TextStrokeTransparency = 0.5,
					TextTransparency = 0,
					TextXAlignment = "Center",
					RenderTime = 0.15
				})
				--
				do -- // Functions
					function Content:Set(state)
						Content.State = math.clamp(math.round(state * Content.Decimals) / Content.Decimals, Content.Min, Content.Max)
						--
						Frame_Slider_Title.Text = "<b>" .. Content.State .. Content.Ending .. "</b>"
						Outline_Frame_Slider.Size = UDim2.new((1 - ((Content.Max - Content.State) / (Content.Max - Content.Min))), 0, 1, 0)
						--
						Content.Callback(Content:Get())
					end
					--
					function Content:Refresh()
						local Mouse = utility:MouseLocation()
						--
						Content:Set(math.clamp(math.floor((Content.Min + (Content.Max - Content.Min) * math.clamp(Mouse.X - Outline_Frame_Slider.AbsolutePosition.X, 0, Holder_Outline_Frame.AbsoluteSize.X) / Holder_Outline_Frame.AbsoluteSize.X) * Content.Decimals) / Content.Decimals, Content.Min, Content.Max))
					end
					--
					function Content:Get()
						return Content.State
					end
				end

				Content.Window.Accents = Content.Window.Accents or {}
				Content.Window.Labels  = Content.Window.Labels  or {}

				-- registra la "barra rellena" del slider para que applyTheme la ponga en colors.Accent
				table.insert(Content.Window.Accents, Outline_Frame_Slider)

				-- registra los labels del slider para que applyTheme actualice su TextColor3
				-- (si Frame_Slider_Title2 existe, registrar también)
				if Frame_Slider_Title then
					table.insert(Content.Window.Labels, Frame_Slider_Title)
				end
				if Frame_Slider_Title2 then
					table.insert(Content.Window.Labels, Frame_Slider_Title2)
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Down, function(Input)
						Content:Refresh()
						--
						Content.Holding = true
                        --
                        Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 215))
                        Frame_Slider_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 215))
					end)
                    --
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
						Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 215))
                        Frame_Slider_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(215, 215, 215))
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
						Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Content.Holding and Color3.fromRGB(215, 215, 215) or Color3.fromRGB(175, 175, 175))
                        Frame_Slider_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Content.Holding and Color3.fromRGB(215, 215, 215) or Color3.fromRGB(175, 175, 175))
					end)
					--
					utility:CreateConnection(uis.InputChanged, function(Input)
						if Content.Holding then
							Content:Refresh()
						end
					end)
					--
					utility:CreateConnection(uis.InputEnded, function(Input)
						if Content.Holding and Input.UserInputType == Enum.UserInputType.MouseButton1 then
							Content.Holding = false
                            --
                            Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(175, 175, 175))
                        	Frame_Slider_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(175, 175, 175))
						end
					end)
				end
				--
				Content:Set(Content.State)
			end
			--
			return Content
		end
		--
		function sections:CreateDropdown(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Dropdown"),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or 1),
				Options = (Properties.options or Properties.Options or Properties.list or Properties.List or {1, 2, 3}),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Content = {
					Open = false
				},
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			local parentContainer = self:GetCurrentSubtabContainer()
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = parentContainer,
					Size = UDim2.new(1, 0, 0, 34 + 5),
					ZIndex = 3
				})
				-- //
				local Content_Holder_Outline = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(12, 12, 12),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 40, 0, 15),
					Size = UDim2.new(1, -98, 0, 20),
					ZIndex = 3
				})
				--
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 4),
					Size = UDim2.new(1, -41, 0, 10),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(205, 205, 205),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Title2 = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 4),
					Size = UDim2.new(1, -41, 0, 10),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(205, 205, 205),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextTransparency = 0.5,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				-- //
				local Holder_Outline_Frame = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(36, 36, 36),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder_Outline,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					ZIndex = 3
				})
				-- //
				local Outline_Frame_Gradient = utility:RenderObject("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 220, 220)),
					Enabled = true,
					Rotation = 270,
					Parent = Holder_Outline_Frame
				})
				--
				local Outline_Frame_Title = utility:RenderObject("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(0, 8, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = "",
					TextColor3 = Color3.fromRGB(155, 155, 155),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Outline_Frame_Title2 = utility:RenderObject("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(0, 8, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = "",
					TextColor3 = Color3.fromRGB(155, 155, 155),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextTransparency = 0,
					TextXAlignment = "Left"
				})
				--
				local Outline_Frame_Arrow = utility:RenderObject("ImageLabel", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(1, -11, 0.5, -4),
					Size = UDim2.new(0, 7, 0, 6),
					Image = "rbxassetid://8532000591",
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					ZIndex = 3
				})
				--
				do -- // Functions
					function Content:Set(state)
						Content.State = state
						--
						Outline_Frame_Title.Text = Content.Options[Content:Get()]
						Outline_Frame_Title2.Text = Content.Options[Content:Get()]
						--
						Content.Callback(Content:Get())
						--
						if Content.Content.Open then
							Content.Content:Refresh(Content:Get())
						end
					end
					--
					function Content:Get()
						return Content.State
					end
					--
					function Content:Open()
						Content.Section:CloseContent()
						--
						local Open = {}
						local Connections = {}
						--
						local InputCheck
						--
						local Content_Open_Holder = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(0, 0, 0),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Content.Section.Extra,
							Position = UDim2.new(0, Content_Holder_Outline.AbsolutePosition.X - Content.Section.Extra.AbsolutePosition.X, 0, Content_Holder_Outline.AbsolutePosition.Y - Content.Section.Extra.AbsolutePosition.Y + 21),
							Size = UDim2.new(1, -98, 0, (18 * #Content.Options) + 2),
							ZIndex = 6
						})
						-- //
						local Open_Holder_Outline = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(12, 12, 12),
							BackgroundTransparency = 0,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Content_Open_Holder,
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 6
						})
						-- //
						local Open_Holder_Outline_Frame = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(35, 35, 35),
							BackgroundTransparency = 0,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Open_Holder_Outline,
							Position = UDim2.new(0, 1, 0, 1),
							Size = UDim2.new(1, -2, 1, -2),
							ZIndex = 6
						})
						-- //
						for Index, Option in pairs(Content.Options) do
							local Outline_Frame_Option = utility:RenderObject("Frame", {
								BackgroundColor3 = Color3.fromRGB(35, 35, 35),
								BackgroundTransparency = 0,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Parent = Open_Holder_Outline_Frame,
								Position = UDim2.new(0, 0, 0, 18 * (Index - 1)),
								Size = UDim2.new(1, 0, 1 / #Content.Options, 0),
								ZIndex = 6
							})
							-- //
							local Frame_Option_Title = utility:RenderObject("TextLabel", {
								BackgroundColor3 = Color3.fromRGB(0, 0, 0),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Parent = Outline_Frame_Option,
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 6,
								Font = "Code",
								RichText = true,
								Text = tostring(Option),
								TextColor3 = Index == Content.State and Content.Window.Accent or Color3.fromRGB(205, 205, 205),
								TextSize = 9,
								TextStrokeTransparency = 1,
								TextXAlignment = "Left"
							})
							--
							local Frame_Option_Title2 = utility:RenderObject("TextLabel", {
								BackgroundColor3 = Color3.fromRGB(0, 0, 0),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Parent = Outline_Frame_Option,
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 6,
								Font = "Code",
								RichText = true,
								Text = tostring(Option),
								TextColor3 = Index == Content.State and Content.Window.Accent or Color3.fromRGB(205, 205, 205),
								TextSize = 9,
								TextStrokeTransparency = 1,
								TextTransparency = 0.5,
								TextXAlignment = "Left"
							})
							--
							local Frame_Option_Button = utility:RenderObject("TextButton", {
								BackgroundColor3 = Color3.fromRGB(0, 0, 0),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Parent = Outline_Frame_Option,
								Size = UDim2.new(1, 0, 1, 0),
								Text = "",
								ZIndex = 6
							})
							--
							do -- // Connections
								local Clicked = utility:CreateConnection(Frame_Option_Button.MouseButton1Click, function(Input)
									Content:Set(Index)
								end)
								--
								local Entered = utility:CreateConnection(Frame_Option_Button.MouseEnter, function(Input)
									Outline_Frame_Option.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
								end)
								--
								local Left = utility:CreateConnection(Frame_Option_Button.MouseLeave, function(Input)
									Outline_Frame_Option.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
								end)
								--
								Connections[#Connections + 1] = Clicked
								Connections[#Connections + 1] = Entered
								Connections[#Connections + 1] = Left
							end
							--
							Open[#Open + 1] = {Index, Frame_Option_Title, Frame_Option_Title2, Outline_Frame_Option, Frame_Option_Button}
						end
						--
						do -- // Functions
							function Content.Content:Close()
								Content.Content.Open = false
								--
								Holder_Outline_Frame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
								--
								for Index, Value in pairs(Connections) do
									Value:Disconnect()
								end
								--
								InputCheck:Disconnect()
								--
								for Index, Value in pairs(Open) do
									Value[2]:Remove()
									Value[3]:Remove()
									Value[4]:Remove()
									Value[5]:Remove()
								end
								--
								Content_Open_Holder:Remove()
								Open_Holder_Outline:Remove()
								Open_Holder_Outline_Frame:Remove()
								--
								function Content.Content:Refresh() end
								--
								InputCheck = nil
								Connections = nil
								Open = nil
							end
							--
							function Content.Content:Refresh(state)
								for Index, Value in pairs(Open) do
									Value[2].TextColor3 = Value[1] == Content.State and Content.Window.Accent or Color3.fromRGB(205, 205, 205)
									Value[3].TextColor3 = Value[1] == Content.State and Content.Window.Accent or Color3.fromRGB(205, 205, 205)
								end
							end
						end
						--
						Content.Content.Open = true
						Content.Section.Content = Content.Content
						--
						Holder_Outline_Frame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
						--
						do -- // Connections
							--
							InputCheck = utility:CreateConnection(uis.InputBegan, function(Input)
								if Content.Content.Open and Input.UserInputType == Enum.UserInputType.MouseButton1 then
									local Mouse = utility:MouseLocation()
									--
									if not (Mouse.X > Content_Open_Holder.AbsolutePosition.X  and Mouse.Y > (Content_Open_Holder.AbsolutePosition.Y + 36) and Mouse.X < (Content_Open_Holder.AbsolutePosition.X + Content_Open_Holder.AbsoluteSize.X) and Mouse.Y < (Content_Open_Holder.AbsolutePosition.Y + Content_Open_Holder.AbsoluteSize.Y + 36)) then
										Content.Section:CloseContent()
									end
								end
							end)
						end
					end
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Down, function(Input)
						if Content.Content.Open then
							Content.Section:CloseContent()
						else
							Content:Open()
						end
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
						Holder_Outline_Frame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
						Holder_Outline_Frame.BackgroundColor3 = Content.Content.Open and Color3.fromRGB(46, 46, 46) or Color3.fromRGB(36, 36, 36)
					end)
				end
				--
				Content:Set(Content.State)
			end
			--
			return Content
		end
		--
		function sections:CreateMultibox(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Dropdown"),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or {1}),
				Options = (Properties.options or Properties.Options or Properties.list or Properties.List or {1, 2, 3}),
				Minimum = (Properties.min or Properties.Min or Properties.minimum or Properties.Minimum or 0),
				Maximum = (Properties.max or Properties.Max or Properties.maximum or Properties.Maximum or 1000),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Content = {
					Open = false
				},
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			local parentContainer = self:GetCurrentSubtabContainer()
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = parentContainer,
					Size = UDim2.new(1, 0, 0, 34 + 5),
					ZIndex = 3
				})
				-- //
				local Content_Holder_Outline = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(12, 12, 12),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 40, 0, 15),
					Size = UDim2.new(1, -98, 0, 20),
					ZIndex = 3
				})
				--
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 4),
					Size = UDim2.new(1, -41, 0, 10),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(205, 205, 205),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Title2 = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 4),
					Size = UDim2.new(1, -41, 0, 10),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(205, 205, 205),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextTransparency = 0.5,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				-- //
				local Holder_Outline_Frame = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(36, 36, 36),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder_Outline,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					ZIndex = 3
				})
				-- //
				local Outline_Frame_Gradient = utility:RenderObject("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(220, 220, 220)),
					Enabled = true,
					Rotation = 270,
					Parent = Holder_Outline_Frame
				})
				--
				local Outline_Frame_Title = utility:RenderObject("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(0, 8, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = "",
					TextColor3 = Color3.fromRGB(155, 155, 155),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Outline_Frame_Title2 = utility:RenderObject("TextLabel", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(0, 8, 0, 0),
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = "",
					TextColor3 = Color3.fromRGB(155, 155, 155),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextTransparency = 0,
					TextXAlignment = "Left"
				})
				--
				local Outline_Frame_Arrow = utility:RenderObject("ImageLabel", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Holder_Outline_Frame,
					Position = UDim2.new(1, -11, 0.5, -4),
					Size = UDim2.new(0, 7, 0, 6),
					Image = "rbxassetid://8532000591",
					ImageColor3 = Color3.fromRGB(255, 255, 255),
					ZIndex = 3
				})
				--
				do -- // Functions
					function Content:Set(state)
						table.sort(state)
						Content.State = state
						--
						local Serialised = utility:Serialise(utility:Sort(Content:Get(), Content.Options))
						--
						Serialised = Serialised == "" and "-" or Serialised
						--
						Outline_Frame_Title.Text = Serialised
						Outline_Frame_Title2.Text = Serialised
						--
						Content.Callback(Content:Get())
						--
						if Content.Content.Open then
							Content.Content:Refresh(Content:Get())
						end
					end
					--
					function Content:Get()
						return Content.State
					end
					--
					function Content:Open()
						Content.Section:CloseContent()
						--
						local Open = {}
						local Connections = {}
						--
						local InputCheck
						--
						local Content_Open_Holder = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(0, 0, 0),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Content.Section.Extra,
							Position = UDim2.new(0, Content_Holder_Outline.AbsolutePosition.X - Content.Section.Extra.AbsolutePosition.X, 0, Content_Holder_Outline.AbsolutePosition.Y - Content.Section.Extra.AbsolutePosition.Y + 21),
							Size = UDim2.new(1, -98, 0, (18 * #Content.Options) + 2),
							ZIndex = 6
						})
						-- //
						local Open_Holder_Outline = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(12, 12, 12),
							BackgroundTransparency = 0,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Content_Open_Holder,
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 6
						})
						-- //
						local Open_Holder_Outline_Frame = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(21, 21, 21),
							BackgroundTransparency = 0,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Open_Holder_Outline,
							Position = UDim2.new(0, 1, 0, 1),
							Size = UDim2.new(1, -2, 1, -2),
							ZIndex = 6
						})
						-- //
						for Index, Option in pairs(Content.Options) do
							local Outline_Frame_Option = utility:RenderObject("Frame", {
								BackgroundColor3 = Color3.fromRGB(35, 35, 35),
								BackgroundTransparency = 0,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Parent = Open_Holder_Outline_Frame,
								Position = UDim2.new(0, 0, 0, 18 * (Index - 1)),
								Size = UDim2.new(1, 0, 1 / #Content.Options, 0),
								ZIndex = 6
							})
							-- //
							local Frame_Option_Title = utility:RenderObject("TextLabel", {
								BackgroundColor3 = Color3.fromRGB(0, 0, 0),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Parent = Outline_Frame_Option,
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 6,
								Font = "Code",
								RichText = true,
								Text = tostring(Option),
								TextColor3 = table.find(Content.State, Index) and Content.Window.Accent or Color3.fromRGB(205, 205, 205),
								TextSize = 9,
								TextStrokeTransparency = 1,
								TextXAlignment = "Left"
							})
							--
							local Frame_Option_Title2 = utility:RenderObject("TextLabel", {
								BackgroundColor3 = Color3.fromRGB(0, 0, 0),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Parent = Outline_Frame_Option,
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, 0, 1, 0),
								ZIndex = 6,
								Font = "Code",
								RichText = true,
								Text = tostring(Option),
								TextColor3 = table.find(Content.State, Index) and Content.Window.Accent or Color3.fromRGB(205, 205, 205),
								TextSize = 9,
								TextStrokeTransparency = 1,
								TextTransparency = 0.5,
								TextXAlignment = "Left"
							})
							--
							local Frame_Option_Button = utility:RenderObject("TextButton", {
								BackgroundColor3 = Color3.fromRGB(0, 0, 0),
								BackgroundTransparency = 1,
								BorderColor3 = Color3.fromRGB(0, 0, 0),
								BorderSizePixel = 0,
								Parent = Outline_Frame_Option,
								Size = UDim2.new(1, 0, 1, 0),
								Text = "",
								ZIndex = 6
							})
							--
							do -- // Connections
								local Clicked = utility:CreateConnection(Frame_Option_Button.MouseButton1Click, function(Input)
									local NewTable = Content:Get()
									--
									if table.find(NewTable, Index) then
										if (#NewTable - 1) >= Content.Minimum then
											table.remove(NewTable, table.find(NewTable, Index))
										end
									else
										if (#NewTable + 1) <= Content.Maximum then
											table.insert(NewTable, Index)
										end
									end
									--
									Content:Set(NewTable)
								end)
								--
								local Entered = utility:CreateConnection(Frame_Option_Button.MouseEnter, function(Input)
									Outline_Frame_Option.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
								end)
								--
								local Left = utility:CreateConnection(Frame_Option_Button.MouseLeave, function(Input)
									Outline_Frame_Option.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
								end)
								--
								Connections[#Connections + 1] = Clicked
								Connections[#Connections + 1] = Entered
								Connections[#Connections + 1] = Left
							end
							--
							Open[#Open + 1] = {Index, Frame_Option_Title, Frame_Option_Title2, Outline_Frame_Option, Frame_Option_Button}
						end
						--
						do -- // Functions
							function Content.Content:Close()
								Content.Content.Open = false
                                --
								Holder_Outline_Frame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
								--
								for Index, Value in pairs(Connections) do
									Value:Disconnect()
								end
								--
								InputCheck:Disconnect()
								--
								for Index, Value in pairs(Open) do
									Value[2]:Remove()
									Value[3]:Remove()
									Value[4]:Remove()
									Value[5]:Remove()
								end
								--
								Content_Open_Holder:Remove()
								Open_Holder_Outline:Remove()
								Open_Holder_Outline_Frame:Remove()
								--
								function Content.Content:Refresh() end
								--
								InputCheck = nil
								Connections = nil
								Open = nil
							end
							--
							function Content.Content:Refresh(state)
								for Index, Value in pairs(Open) do
									Value[2].TextColor3 = table.find(Content.State, Value[1]) and Content.Window.Accent or Color3.fromRGB(205, 205, 205)
									Value[3].TextColor3 = table.find(Content.State, Value[1]) and Content.Window.Accent or Color3.fromRGB(205, 205, 205)
								end
							end
						end
						--
						Content.Content.Open = true
						Content.Section.Content = Content.Content
                        --
						Holder_Outline_Frame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
						--
						do -- // Connections
							--
							InputCheck = utility:CreateConnection(uis.InputBegan, function(Input)
								if Content.Content.Open and Input.UserInputType == Enum.UserInputType.MouseButton1 then
									local Mouse = utility:MouseLocation()
									--
									if not (Mouse.X > Content_Open_Holder.AbsolutePosition.X and Mouse.Y > (Content_Open_Holder.AbsolutePosition.Y + 36) and Mouse.X < (Content_Open_Holder.AbsolutePosition.X + Content_Open_Holder.AbsoluteSize.X) and Mouse.Y < (Content_Open_Holder.AbsolutePosition.Y + Content_Open_Holder.AbsoluteSize.Y + 36)) then
										Content.Section:CloseContent()
									end
								end
							end)
						end
					end
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Down, function(Input)
						if Content.Content.Open then
							Content.Section:CloseContent()
						else
							Content:Open()
						end
					end)
                    --
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
						Holder_Outline_Frame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
						Holder_Outline_Frame.BackgroundColor3 = Content.Content.Open and Color3.fromRGB(46, 46, 46) or Color3.fromRGB(36, 36, 36)
					end)
				end
				--
				Content:Set(Content.State)
			end
			--
			return Content
		end
		--
		function sections:CreateKeybind(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Toggle"),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or nil),
                Mode = (Properties.mode or Properties.Mode or "Hold"),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
                Active = false,
                Holding = false,
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			local parentContainer = self:GetCurrentSubtabContainer()
            --
            local Keys = {
                KeyCodes = {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M", "One", "Two", "Three", "Four", "Five", "Six", "Seveen", "Eight", "Nine", "0", "Insert", "Tab", "Home", "End", "LeftAlt", "LeftControl", "LeftShift", "RightAlt", "RightControl", "RightShift", "CapsLock"},
                Inputs = {"MouseButton1", "MouseButton2", "MouseButton3"},
                Shortened = {["MouseButton1"] = "M1", ["MouseButton2"] = "M2", ["MouseButton3"] = "M3", ["Insert"] = "INS", ["LeftAlt"] = "LA", ["LeftControl"] = "LC", ["LeftShift"] = "LS", ["RightAlt"] = "RA", ["RightControl"] = "RC", ["RightShift"] = "RS", ["CapsLock"] = "CL"}
            }
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = parentContainer,
					Size = UDim2.new(1, 0, 0, 8 + 10),
					ZIndex = 3
				})
				-- //
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 0),
					Size = UDim2.new(1, -41, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(205, 205, 205),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Title2 = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 0),
					Size = UDim2.new(1, -41, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(205, 205, 205),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextTransparency = 0.5,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
                -- //
                local Content_Holder_Value = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 0),
					Size = UDim2.new(1, -61, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text =  "",
					TextColor3 = Color3.fromRGB(114, 114, 114),
                    TextStrokeColor3 = Color3.fromRGB(15, 15, 15),
					TextSize = 9,
					TextStrokeTransparency = 0,
					TextXAlignment = "Right"
				})
				--
				do -- // Functions
					function Content:Set(state)
						Content.State = state or {}
                        Content.Active = false
                        --
                        Content_Holder_Value.Text = "[" .. (#Content:Get() > 0 and Content:Shorten(Content:Get()[2]) or "-") .. "]"
						--
						Content.Callback(Content:Get())
					end
					--
					function Content:Get()
						return Content.State
					end
                    --
                    function Content:Shorten(Str)
                        for Index, Value in pairs(Keys.Shortened) do
                            Str = string.gsub(Str, Index, Value)
                        end
                        --
                        return Str
                    end
                    --
                    function Content:Change(Key)
                        if Key.EnumType then
                            if Key.EnumType == Enum.KeyCode or Key.EnumType == Enum.UserInputType then
                                if table.find(Keys.KeyCodes, Key.Name) or table.find(Keys.Inputs, Key.Name) then
                                    Content:Set({Key.EnumType == Enum.KeyCode and "KeyCode" or "UserInputType", Key.Name})
                                    return true
                                end
                            end
                        end
                    end
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function(Input)
						Content.Holding = true
                        --
                        Content_Holder_Value.TextColor3 = Color3.fromRGB(255, 0, 0)
					end)
                    --
                    utility:CreateConnection(Content_Holder_Button.MouseButton2Click, function(Input)
						Content:Set()
					end)
                    --
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
						Content_Holder_Value.TextColor3 = Color3.fromRGB(164, 164, 164)
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
						Content_Holder_Value.TextColor3 = Content.Holding and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(114, 114, 114)
					end)
                    --
                    utility:CreateConnection(uis.InputBegan, function(Input)
                        if Content.Holding then
                            local Success = Content:Change(Input.KeyCode.Name ~= "Unknown" and Input.KeyCode or Input.UserInputType)
                            --
                            if Success then
                                Content.Holding = false
                                --
                                Content_Holder_Value.TextColor3 = Color3.fromRGB(114, 114, 114)
                            end
                        end
                        --
                        if Content:Get()[1] and Content:Get()[2] then
                            if Input.KeyCode == Enum[Content:Get()[1]][Content:Get()[2]] or Input.UserInputType == Enum[Content:Get()[1]][Content:Get()[2]] then
                                if Content.Mode == "Hold" then
                                    Content.Active = true
                                elseif Content.Mode == "Toggle" then
                                    Content.Active = not Content.Active
                                end
                            end
                        end
                    end)
                    --
                    utility:CreateConnection(uis.InputEnded, function(Input)
                        if Content:Get()[1] and Content:Get()[2] then
                            if Input.KeyCode == Enum[Content:Get()[1]][Content:Get()[2]] or Input.UserInputType == Enum[Content:Get()[1]][Content:Get()[2]] then
                                if Content.Mode == "Hold" then
                                    Content.Active = false
                                end
                            end
                        end
                    end)
				end
				--
				Content:Set(Content.State)
			end
			--
			return Content
		end
		--
		function sections:CreateColorpicker(Properties)
			Properties = Properties or {}
			--
			local Content = {
				Name = (Properties.name or Properties.Name or Properties.title or Properties.Title or "New Toggle"),
				State = (Properties.state or Properties.State or Properties.def or Properties.Def or Properties.default or Properties.Default or Color3.fromRGB(255, 255, 255)),
				Callback = (Properties.callback or Properties.Callback or Properties.callBack or Properties.CallBack or function() end),
				Content = {
					Open = false
				},
				Window = self.Window,
				Page = self.Page,
				Section = self
			}
			local parentContainer = self:GetCurrentSubtabContainer()
			--
			do
				local Content_Holder = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = parentContainer,
					Size = UDim2.new(1, 0, 0, 8 + 10),
					ZIndex = 3
				})
				-- //
				local Content_Holder_Outline = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(12, 12, 12),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(1, -38, 0, 4),
					Size = UDim2.new(0, 17, 0, 9),
					ZIndex = 3
				})
				--
				local Content_Holder_Title = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 0),
					Size = UDim2.new(1, -41, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(205, 205, 205),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Title2 = utility:RenderObject("TextLabel", {
					AnchorPoint = Vector2.new(0, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Position = UDim2.new(0, 41, 0, 0),
					Size = UDim2.new(1, -41, 1, 0),
					ZIndex = 3,
					Font = "Code",
					RichText = true,
					Text = Content.Name,
					TextColor3 = Color3.fromRGB(205, 205, 205),
					TextSize = 9,
					TextStrokeTransparency = 1,
					TextTransparency = 0.5,
					TextXAlignment = "Left"
				})
				--
				local Content_Holder_Button = utility:RenderObject("TextButton", {
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder,
					Size = UDim2.new(1, 0, 1, 0),
					Text = ""
				})
				-- //
				local Holder_Outline_Frame = utility:RenderObject("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Parent = Content_Holder_Outline,
					Position = UDim2.new(0, 1, 0, 1),
					Size = UDim2.new(1, -2, 1, -2),
					ZIndex = 3
				})
				-- //
				local Outline_Frame_Gradient = utility:RenderObject("UIGradient", {
					Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(140, 140, 140)),
					Enabled = true,
					Rotation = 90,
					Parent = Holder_Outline_Frame
				})
				--
				do -- // Functions
					function Content:Set(state)
						Content.State = state
						--
						Holder_Outline_Frame.BackgroundColor3 = Content.State
						--
						Content.Callback(Content:Get())
					end
					--
					function Content:Get()
						return Content.State
					end
					--
					function Content:Open()
						Content.Section:CloseContent()
						--
						local Connections = {}
						--
						local InputCheck
						--
						local Content_Open_Holder = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(0, 0, 0),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Content.Section.Extra,
							Position = UDim2.new(0, Content_Holder_Outline.AbsolutePosition.X - Content.Section.Extra.AbsolutePosition.X, 0, Content_Holder_Outline.AbsolutePosition.Y - Content.Section.Extra.AbsolutePosition.Y + 10),
							Size = UDim2.new(0, 180, 0, 175),
							ZIndex = 6
						})
						-- //
						local Open_Holder_Button = utility:RenderObject("TextButton", {
							BackgroundColor3 = Color3.fromRGB(0, 0, 0),
							BackgroundTransparency = 1,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Content_Open_Holder,
							Position = UDim2.new(0, -1, 0, -1),
							Size = UDim2.new(1, 2, 1, 2),
							Text = ""
						})
						-- //
						local Open_Holder_Outline = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(60, 60, 60),
							BackgroundTransparency = 0,
							BorderColor3 = Color3.fromRGB(12, 12, 12),
							BorderMode = "Inset",
							BorderSizePixel = 1,
							Parent = Content_Open_Holder,
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(1, 0, 1, 0),
							ZIndex = 6
						})
						-- //
						local Open_Outline_Frame = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(40, 40, 40),
							BackgroundTransparency = 0,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Open_Holder_Outline,
							Position = UDim2.new(0, 1, 0, 1),
							Size = UDim2.new(1, -2, 1, -2),
							ZIndex = 6
						})
						-- //
						local ValSat_Picker_Outline = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(12, 12, 12),
							BackgroundTransparency = 0,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Open_Outline_Frame,
							Position = UDim2.new(0, 2, 0, 2),
							Size = UDim2.new(0, 152, 0, 152),
							ZIndex = 6
						})
						--
						local Hue_Picker_Outline = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(12, 12, 12),
							BackgroundTransparency = 0,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Open_Outline_Frame,
							Position = UDim2.new(1, -19, 0, 2),
							Size = UDim2.new(0, 17, 0, 152),
							ZIndex = 6
						})
						--
						local Transparency_Picker_Outline = utility:RenderObject("Frame", {
							BackgroundColor3 = Color3.fromRGB(12, 12, 12),
							BackgroundTransparency = 0,
							BorderColor3 = Color3.fromRGB(0, 0, 0),
							BorderSizePixel = 0,
							Parent = Open_Outline_Frame,
							Position = UDim2.new(0, 2, 1, -14),
							Size = UDim2.new(0, 152, 0, 12),
							ZIndex = 6
						})
						-- //
					-- === Color picker visual + lógica (reemplazar el bloque ValSat_Picker_Color existente) ===
local ValSat_Picker_Color = utility:RenderObject("Frame", {
    BackgroundColor3 = Color3.fromHSV(0,1,1),
    BackgroundTransparency = 0,
    BorderColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
    Parent = ValSat_Picker_Outline,
    Position = UDim2.new(0, 1, 0, 1),
    Size = UDim2.new(1, -2, 1, -2),
    ZIndex = 6
})
local ValSat_Gradient = utility:RenderObject("UIGradient", {
    Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0,0,0)),
    Rotation = 90,
    Parent = ValSat_Picker_Color
})
-- pequeño cursor que muestra la posición actual dentro del cuadro (sat/val)
					local VS_Cursor = utility:RenderObject("Frame", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255,255,255),
						BorderColor3 = Color3.fromRGB(0,0,0),
						BorderSizePixel = 1,
						Size = UDim2.new(0,10,0,10),
						ZIndex = 7,
						Parent = ValSat_Picker_Color
					})

					-- pequeño cursor para el deslizador de hue (posicion vertical)
					local Hue_Cursor = utility:RenderObject("Frame", {
						AnchorPoint = Vector2.new(0.5,0.5),
						BackgroundColor3 = Color3.fromRGB(255,255,255),
						BorderColor3 = Color3.fromRGB(0,0,0),
						BorderSizePixel = 1,
						Size = UDim2.new(0,16,0,6),
						ZIndex = 7,
						Parent = Hue_Picker_Outline
					})

					-- estado HSV local (inicializamos desde el state si es Color3)
					local hue, sat, val = 0, 1, 1
					if typeof(Content.State) == "Color3" then
						local h,s,v = Color3.toHSV(Content.State)
						hue, sat, val = h or 0, s or 1, v or 1
					end

					-- helpers
					local function clamp(v) return math.clamp(v, 0, 1) end

local function updatePreview()
    -- color seleccionado
    local selected = Color3.fromHSV(hue, sat, val)
    -- actualiza el cuadro grande para que muestre el color seleccionado
    pcall(function() ValSat_Picker_Color.BackgroundColor3 = Color3.fromHSV(hue, 1, 1) end)
    -- actualizar cursores (calculamos posiciones en escala)
    local yPos = 1 - val -- si val = 1 -> cursor arriba (y=0), si val=0 -> cursor abajo (y=1)
    pcall(function()
        VS_Cursor.Position = UDim2.new(sat, 0, yPos, 0)
        -- Hue cursor: queremos la posición vertical equivalente al hue
        -- recordemos que 'hue' calculamos como 0..1 (0 bottom, 1 top en nuestro manejo),
        -- así que la posición vertical real del cursor es (1 - hue)
        Hue_Cursor.Position = UDim2.new(0.5, 0, 1 - hue, 0)
    end)
end

					-- arrastrar / interacción
					local draggingVS = false
					local draggingHue = false

					-- helper para leer mouse y setear sat/val
					local function setFromValSatFromMouse()
						local mouse = utility:MouseLocation()
						local x = clamp((mouse.X - ValSat_Picker_Outline.AbsolutePosition.X) / math.max(1, ValSat_Picker_Outline.AbsoluteSize.X))
						local y = clamp((mouse.Y - ValSat_Picker_Outline.AbsolutePosition.Y) / math.max(1, ValSat_Picker_Outline.AbsoluteSize.Y))
						sat = x
						val = 1 - y
						updatePreview()
						-- actualizar estado y callback
						local col = Color3.fromHSV(hue, sat, val)
						Content.State = col
						pcall(function() Content.Callback(col) end)
					end

					local function setFromHueFromMouse()
						local mouse = utility:MouseLocation()
						local y = clamp((mouse.Y - Hue_Picker_Outline.AbsolutePosition.Y) / math.max(1, Hue_Picker_Outline.AbsoluteSize.Y))
						hue = 1 - y
						updatePreview()
						local col = Color3.fromHSV(hue, sat, val)
						Content.State = col
						pcall(function() Content.Callback(col) end)
					end

					-- iniciar posicion de visuales
					updatePreview()

					-- conexiones de input (usa el util que ya tienes en la librería)
					utility:CreateConnection(ValSat_Picker_Color.InputBegan, function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							draggingVS = true
							setFromValSatFromMouse()
						end
					end)

					utility:CreateConnection(Hue_Picker_Outline.InputBegan, function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							draggingHue = true
							setFromHueFromMouse()
						end
					end)

					utility:CreateConnection(uis.InputChanged, function(input)
						if draggingVS and input.UserInputType == Enum.UserInputType.MouseMovement then
							setFromValSatFromMouse()
						elseif draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
							setFromHueFromMouse()
						end
					end)

					utility:CreateConnection(uis.InputEnded, function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							draggingVS = false
							draggingHue = false
						end
					end)
-- === fin picker logic ===
						--
						do -- // Functions
							function Content.Content:Close()
								Content.Content.Open = false
								--
								for Index, Value in pairs(Connections) do
									Value:Disconnect()
								end
								--
								InputCheck:Disconnect()
								--
								Content_Open_Holder:Remove()
								--
								function Content.Content:Refresh() end
								--
								InputCheck = nil
								Connections = nil
							end
							--
							function Content.Content:Refresh(state)
							end
						end
						--
						Content.Content.Open = true
						Content.Section.Content = Content.Content
						--
						do -- // Connections
							InputCheck = utility:CreateConnection(uis.InputBegan, function(Input)
								if Content.Content.Open and Input.UserInputType == Enum.UserInputType.MouseButton1 then
									local Mouse = utility:MouseLocation()
									--
									if not (Mouse.X > Content_Open_Holder.AbsolutePosition.X and Mouse.Y > (Content_Open_Holder.AbsolutePosition.Y + 36) and Mouse.X < (Content_Open_Holder.AbsolutePosition.X + Content_Open_Holder.AbsoluteSize.X) and Mouse.Y < (Content_Open_Holder.AbsolutePosition.Y + Content_Open_Holder.AbsoluteSize.Y + 36)) then
										if not (Mouse.X > Content_Holder.AbsolutePosition.X and Mouse.Y > (Content_Holder.AbsolutePosition.Y) and Mouse.X < (Content_Holder.AbsolutePosition.X + Content_Holder.AbsoluteSize.X) and Mouse.Y < (Content_Holder.AbsolutePosition.Y + Content_Holder.AbsoluteSize.Y)) then
											if Content.Content.Open then
												Content.Section:CloseContent()
											end
										end
									end
								end
							end)
						end
					end
				end
				--
				do -- // Connections
					utility:CreateConnection(Content_Holder_Button.MouseButton1Click, function(Input)
						if Content.Content.Open then
							Content.Section:CloseContent()
						else
							Content:Open()
						end
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseEnter, function(Input)
						Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(180, 180, 180))
					end)
					--
					utility:CreateConnection(Content_Holder_Button.MouseLeave, function(Input)
						Outline_Frame_Gradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(140, 140, 140))
					end)
				end
				--
				Content:Set(Content.State)
			end
			--
			return Content
		end
	end

	-- [[ // ESP FUNCTIONS // ]]
-- [[ // ESP SYSTEM MEJORADO // ]]
do
	local RunService = game:GetService("RunService")
	local Workspace = game:GetService("Workspace")
	local Camera = Workspace.CurrentCamera
	local Players = game:GetService("Players")
	local localPlayer = Players.LocalPlayer

	print("=== INICIANDO ESP SYSTEM MEJORADO ===")

	-- ============================================================================
	-- CONFIGURACIÓN GLOBAL ESP
	-- ============================================================================
	
	_G.ESPSettings = {
		-- Box ESP
		BoxEnabled = false,
		BoxColor = Color3.fromRGB(255, 255, 255),
		BoxOutlineEnabled = true,
		BoxOutlineColor = Color3.fromRGB(0, 0, 0),
		BoxThickness = 1,
		
		-- Health Bar
		HealthBarEnabled = false,
		HealthBarGradient = true,
		
		-- Skeleton
		SkeletonEnabled = false,
		SkeletonColor = Color3.fromRGB(255, 255, 255),
		SkeletonThickness = 1,
		
		-- Glow/Chams
		GlowEnabled = false,
		GlowColor = Color3.fromRGB(0, 255, 0),
		GlowTransparency = 0.5,
		SoftESP = false,
		
		-- Name
		NameEnabled = false,
		NameColor = Color3.fromRGB(255, 255, 255),
		NameGradient = false,
		NameGradientColor1 = Color3.fromRGB(255, 100, 100),
		NameGradientColor2 = Color3.fromRGB(100, 100, 255),
		NameOutline = true,
		NameSize = 13,
		
		-- Distance
		DistanceEnabled = false,
		DistanceColor = Color3.fromRGB(200, 200, 200),
		DistanceOutline = true,
		
		-- Tracers
		TracersEnabled = false,
		TracersColor = Color3.fromRGB(255, 255, 255),
		TracersOrigin = "Bottom", -- "Bottom", "Middle", "Top"
		TracersThickness = 1,
		
		-- Checks
		TeamCheck = false,
		TeamColor = Color3.fromRGB(100, 255, 100),
		EnemyColor = Color3.fromRGB(255, 100, 100),
		UseTeamColors = false,
		VisibleCheck = false,
		VisibleColor = Color3.fromRGB(100, 255, 100),
		NotVisibleColor = Color3.fromRGB(255, 100, 100),
		
		-- Sizing & Distance
		RenderDistance = 10000,
		SizingType = "Dynamic", -- "Dynamic", "Fixed", "Scaled"
		FixedSize = Vector2.new(100, 150),
		ScaleFactor = 1.0,
		
		-- General
		TrackedPlayers = {},
		FOV_TanHalf = math.tan(math.rad(Camera.FieldOfView * 0.5)),
		RainbowMode = false,
		RainbowSpeed = 0.5
	}

	-- ============================================================================
	-- UTILIDADES
	-- ============================================================================
	
	local function IsTeammate(player)
		if not _G.ESPSettings.TeamCheck then return false end
		if not player or not localPlayer then return false end
		return player.Team == localPlayer.Team
	end

	local function IsVisible(fromPos, toPos, ignoreModel)
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist
		rayParams.FilterDescendantsInstances = {localPlayer.Character, ignoreModel}
		rayParams.IgnoreWater = true
		
		local ray = Workspace:Raycast(fromPos, (toPos - fromPos), rayParams)
		return ray == nil
	end

	local function FindHeadAndTorso(model)
		local head = model:FindFirstChild("Head")
		local torso = model:FindFirstChild("Torso") 
			or model:FindFirstChild("UpperTorso") 
			or model:FindFirstChild("LowerTorso")
		
		if head and torso then
			return head, torso
		end
		return nil, nil
	end

	local function GetCharacterParts(model)
		local parts = {
			Head = model:FindFirstChild("Head"),
			UpperTorso = model:FindFirstChild("UpperTorso"),
			LowerTorso = model:FindFirstChild("LowerTorso"),
			LeftUpperArm = model:FindFirstChild("LeftUpperArm"),
			LeftLowerArm = model:FindFirstChild("LeftLowerArm"),
			LeftHand = model:FindFirstChild("LeftHand"),
			RightUpperArm = model:FindFirstChild("RightUpperArm"),
			RightLowerArm = model:FindFirstChild("RightLowerArm"),
			RightHand = model:FindFirstChild("RightHand"),
			LeftUpperLeg = model:FindFirstChild("LeftUpperLeg"),
			LeftLowerLeg = model:FindFirstChild("LeftLowerLeg"),
			LeftFoot = model:FindFirstChild("LeftFoot"),
			RightUpperLeg = model:FindFirstChild("RightUpperLeg"),
			RightLowerLeg = model:FindFirstChild("RightLowerLeg"),
			RightFoot = model:FindFirstChild("RightFoot")
		}
		
		if not parts.UpperTorso then
			parts.Torso = model:FindFirstChild("Torso")
			parts.LeftArm = model:FindFirstChild("Left Arm")
			parts.RightArm = model:FindFirstChild("Right Arm")
			parts.LeftLeg = model:FindFirstChild("Left Leg")
			parts.RightLeg = model:FindFirstChild("Right Leg")
		end
		
		return parts
	end

	local function GetDynamicColor(isTeammate, isVisible)
		if _G.ESPSettings.UseTeamColors then
			return isTeammate and _G.ESPSettings.TeamColor or _G.ESPSettings.EnemyColor
		elseif _G.ESPSettings.VisibleCheck then
			return isVisible and _G.ESPSettings.VisibleColor or _G.ESPSettings.NotVisibleColor
		else
			return _G.ESPSettings.BoxColor
		end
	end

	-- Rainbow effect
	local rainbowHue = 0

	-- ============================================================================
	-- CREAR ESP PARA UN MODELO
	-- ============================================================================
	
	local function CreateESP(model)
		if _G.ESPSettings.TrackedPlayers[model] then
			return
		end
		
		local head, torso = FindHeadAndTorso(model)
		if not (head and torso) then
			return
		end

		local player = Players:GetPlayerFromCharacter(model)
		if player == localPlayer then return end
		
		print("Creando ESP para:", model.Name)
		
		-- ========== BOX ESP ==========
		local boxOutline = Drawing.new("Square")
		boxOutline.Thickness = 3
		boxOutline.Filled = false
		boxOutline.Color = _G.ESPSettings.BoxOutlineColor
		boxOutline.Visible = false
		boxOutline.ZIndex = 1
		
		local box = Drawing.new("Square")
		box.Thickness = _G.ESPSettings.BoxThickness
		box.Filled = false
		box.Color = _G.ESPSettings.BoxColor
		box.Visible = false
		box.ZIndex = 2
		
		-- ========== HEALTH BAR ==========
		local healthBarOutline = Drawing.new("Square")
		healthBarOutline.Thickness = 1
		healthBarOutline.Filled = true
		healthBarOutline.Color = Color3.fromRGB(0, 0, 0)
		healthBarOutline.Visible = false
		healthBarOutline.ZIndex = 1
		
		local healthBar = Drawing.new("Square")
		healthBar.Thickness = 1
		healthBar.Filled = true
		healthBar.Color = Color3.fromRGB(0, 255, 0)
		healthBar.Visible = false
		healthBar.ZIndex = 2
		
		-- ========== NAME ==========
		local nameLabel = Drawing.new("Text")
		nameLabel.Text = model.Name
		nameLabel.Size = _G.ESPSettings.NameSize
		nameLabel.Center = true
		nameLabel.Outline = _G.ESPSettings.NameOutline
		nameLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
		nameLabel.Color = _G.ESPSettings.NameColor
		nameLabel.Visible = false
		nameLabel.ZIndex = 3
		
		-- ========== DISTANCE ==========
		local distanceLabel = Drawing.new("Text")
		distanceLabel.Text = "0m"
		distanceLabel.Size = 12
		distanceLabel.Center = true
		distanceLabel.Outline = _G.ESPSettings.DistanceOutline
		distanceLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
		distanceLabel.Color = _G.ESPSettings.DistanceColor
		distanceLabel.Visible = false
		distanceLabel.ZIndex = 3
		
		-- ========== TRACER ==========
		local tracer = Drawing.new("Line")
		tracer.Thickness = _G.ESPSettings.TracersThickness
		tracer.Color = _G.ESPSettings.TracersColor
		tracer.Visible = false
		tracer.ZIndex = 1
		
		-- ========== SKELETON ==========
		local skeletonLines = {}
		for i = 1, 15 do
			local line = Drawing.new("Line")
			line.Thickness = _G.ESPSettings.SkeletonThickness
			line.Color = _G.ESPSettings.SkeletonColor
			line.Visible = false
			line.ZIndex = 2
			table.insert(skeletonLines, line)
		end
		
		-- ========== GLOW (HIGHLIGHT) ==========
		local highlight = Instance.new("Highlight")
		highlight.Name = "ESPGlow"
		highlight.Adornee = model
		highlight.FillColor = _G.ESPSettings.GlowColor
		highlight.OutlineColor = _G.ESPSettings.GlowColor
		highlight.FillTransparency = 1 - _G.ESPSettings.GlowTransparency  -- CORRECCIÓN AQUÍ
		highlight.OutlineTransparency = _G.ESPSettings.SoftESP and 0.8 or 0
		highlight.Enabled = false
		highlight.Parent = model

		
		-- ========== GUARDAR REFERENCIAS ==========
		_G.ESPSettings.TrackedPlayers[model] = {
			box = box,
			boxOutline = boxOutline,
			healthBar = healthBar,
			healthBarOutline = healthBarOutline,
			nameLabel = nameLabel,
			distanceLabel = distanceLabel,
			tracer = tracer,
			skeletonLines = skeletonLines,
			highlight = highlight,
			head = head,
			torso = torso,
			player = player,
			humanoid = model:FindFirstChildOfClass("Humanoid")
		}
		
		-- ========== CLEANUP ==========
		model.Destroying:Connect(function()
			pcall(function()
				box:Remove()
				boxOutline:Remove()
				healthBar:Remove()
				healthBarOutline:Remove()
				nameLabel:Remove()
				distanceLabel:Remove()
				tracer:Remove()
				for _, line in ipairs(skeletonLines) do
					line:Remove()
				end
				highlight:Destroy()
			end)
			_G.ESPSettings.TrackedPlayers[model] = nil
		end)
	end

	-- ============================================================================
	-- INICIALIZAR ESP
	-- ============================================================================
	
	_G.InitializeESP = function()
		local count = 0
		for _, model in ipairs(Workspace:GetChildren()) do
			if model:IsA("Model") and model ~= localPlayer.Character then
				CreateESP(model)
				count = count + 1
			end
		end
		print("ESP inicializado para", count, "modelos")
	end

	Workspace.ChildAdded:Connect(function(child)
		if child:IsA("Model") then
			task.wait(0.1)
			CreateESP(child)
		end
	end)

	-- ============================================================================
	-- ACTUALIZAR ESP CADA FRAME
	-- ============================================================================
	
	RunService.RenderStepped:Connect(function(dt)
		local cameraPos = Camera.CFrame.Position
		local viewportSize = Camera.ViewportSize
		
		-- Rainbow mode
		if _G.ESPSettings.RainbowMode then
			rainbowHue = (rainbowHue + dt * _G.ESPSettings.RainbowSpeed) % 1
		end
		
		for model, espData in pairs(_G.ESPSettings.TrackedPlayers) do
			local head = espData.head
			local torso = espData.torso
			
			-- Verificar que el modelo existe
			if not (model and model.Parent and head and head.Parent and torso and torso.Parent) then
				espData.box.Visible = false
				espData.boxOutline.Visible = false
				espData.healthBar.Visible = false
				espData.healthBarOutline.Visible = false
				espData.nameLabel.Visible = false
				espData.distanceLabel.Visible = false
				espData.tracer.Visible = false
				espData.highlight.Enabled = false
				for _, line in ipairs(espData.skeletonLines) do
					line.Visible = false
				end
				continue
			end

			-- Calcular distancia
			local centerPos = (head.Position + torso.Position) * 0.5
			local distance = (centerPos - cameraPos).Magnitude
			
			-- Render Distance Check
			if distance > _G.ESPSettings.RenderDistance then
				espData.box.Visible = false
				espData.boxOutline.Visible = false
				espData.healthBar.Visible = false
				espData.healthBarOutline.Visible = false
				espData.nameLabel.Visible = false
				espData.distanceLabel.Visible = false
				espData.tracer.Visible = false
				espData.highlight.Enabled = false
				for _, line in ipairs(espData.skeletonLines) do
					line.Visible = false
				end
				continue
			end

			-- Team check
			local isTeammate = espData.player and IsTeammate(espData.player)
			if isTeammate and _G.ESPSettings.TeamCheck then
				espData.box.Visible = false
				espData.boxOutline.Visible = false
				espData.healthBar.Visible = false
				espData.healthBarOutline.Visible = false
				espData.nameLabel.Visible = false
				espData.distanceLabel.Visible = false
				espData.tracer.Visible = false
				espData.highlight.Enabled = false
				for _, line in ipairs(espData.skeletonLines) do
					line.Visible = false
				end
				continue
			end
			
			-- Visible check
			local isVisible = true
			if _G.ESPSettings.VisibleCheck then
				isVisible = IsVisible(cameraPos, centerPos, model)
			end
			
			local screenPos, onScreen = Camera:WorldToViewportPoint(centerPos)
			
			if onScreen and screenPos.Z > 0 then
				-- Determinar color dinámico
				local dynamicColor = GetDynamicColor(isTeammate, isVisible)
				if _G.ESPSettings.RainbowMode then
					dynamicColor = Color3.fromHSV(rainbowHue, 1, 1)
				end
				
				-- ========== BOX ESP ==========
				if _G.ESPSettings.BoxEnabled then
					local boxWidth, boxHeight
					
					-- Sizing Type
					if _G.ESPSettings.SizingType == "Fixed" then
						boxWidth = _G.ESPSettings.FixedSize and _G.ESPSettings.FixedSize.X or 100
						boxHeight = _G.ESPSettings.FixedSize and _G.ESPSettings.FixedSize.Y or 150
					elseif _G.ESPSettings.SizingType == "Scaled" then
						-- CORRECCIÓN: Usar ScaleFactor correctamente
						local baseScale = 1000 / distance
						local scaleFactor = baseScale * (_G.ESPSettings.ScaleFactor or 1.0)
						boxWidth = math.clamp(math.floor(4.5 * scaleFactor), 10, 300)
						boxHeight = math.clamp(math.floor(6 * scaleFactor), 14, 400)
					else -- Dynamic
						local scaleFactor = 1000 / (distance * _G.ESPSettings.FOV_TanHalf * 2)
						boxWidth = math.clamp(math.floor(4.5 * scaleFactor), 10, 300)
						boxHeight = math.clamp(math.floor(6 * scaleFactor), 14, 400)
					end
					
					local posX = screenPos.X - boxWidth / 2
					local posY = screenPos.Y - boxHeight / 2
					
					-- Outline
					if _G.ESPSettings.BoxOutlineEnabled then
						espData.boxOutline.Size = Vector2.new(boxWidth, boxHeight)
						espData.boxOutline.Position = Vector2.new(posX, posY)
						espData.boxOutline.Color = _G.ESPSettings.BoxOutlineColor
						espData.boxOutline.Visible = true
					else
						espData.boxOutline.Visible = false
					end
					
					-- Box
					espData.box.Size = Vector2.new(boxWidth, boxHeight)
					espData.box.Position = Vector2.new(posX, posY)
					espData.box.Color = dynamicColor
					espData.box.Thickness = _G.ESPSettings.BoxThickness
					espData.box.Visible = true
					
					-- ========== HEALTH BAR ==========
					if _G.ESPSettings.HealthBarEnabled and espData.humanoid then
						local health = espData.humanoid.Health
						local maxHealth = espData.humanoid.MaxHealth
						local healthPercent = math.clamp(health / maxHealth, 0, 1)
						
						local barWidth = 4
						local barHeight = boxHeight
						local barX = posX - barWidth - 2
						local barY = posY
						
						-- Outline
						espData.healthBarOutline.Size = Vector2.new(barWidth, barHeight)
						espData.healthBarOutline.Position = Vector2.new(barX, barY)
						espData.healthBarOutline.Visible = true
						
						-- Health fill
						local fillHeight = barHeight * healthPercent
						espData.healthBar.Size = Vector2.new(barWidth - 2, fillHeight)
						espData.healthBar.Position = Vector2.new(barX + 1, barY + barHeight - fillHeight)
						
						-- Color gradient
						if _G.ESPSettings.HealthBarGradient then
							if healthPercent > 0.5 then
								espData.healthBar.Color = Color3.fromRGB(
									math.floor((1 - healthPercent) * 2 * 255),
									255,
									0
								)
							else
								espData.healthBar.Color = Color3.fromRGB(
									255,
									math.floor(healthPercent * 2 * 255),
									0
								)
							end
						else
							espData.healthBar.Color = Color3.fromRGB(0, 255, 0)
						end
						
						espData.healthBar.Visible = true
					else
						espData.healthBar.Visible = false
						espData.healthBarOutline.Visible = false
					end
					
					-- ========== NAME ==========
					if _G.ESPSettings.NameEnabled then
						espData.nameLabel.Position = Vector2.new(screenPos.X, posY - 16)
						espData.nameLabel.Size = _G.ESPSettings.NameSize
						espData.nameLabel.Outline = _G.ESPSettings.NameOutline
						
						-- Gradient effect (simulado con interpolación)
						if _G.ESPSettings.NameGradient then
							local gradientPos = (screenPos.X % 100) / 100
							espData.nameLabel.Color = _G.ESPSettings.NameGradientColor1:Lerp(
								_G.ESPSettings.NameGradientColor2, 
								gradientPos
							)
						else
							espData.nameLabel.Color = dynamicColor
						end
						
						espData.nameLabel.Visible = true
					else
						espData.nameLabel.Visible = false
					end
					
					-- ========== DISTANCE ==========
					if _G.ESPSettings.DistanceEnabled then
						local distanceMeters = math.floor(distance)
						espData.distanceLabel.Text = tostring(distanceMeters) .. "m"
						espData.distanceLabel.Position = Vector2.new(screenPos.X, posY + boxHeight + 2)
						espData.distanceLabel.Color = _G.ESPSettings.DistanceColor
						espData.distanceLabel.Outline = _G.ESPSettings.DistanceOutline
						espData.distanceLabel.Visible = true
					else
						espData.distanceLabel.Visible = false
					end
				else
					espData.box.Visible = false
					espData.boxOutline.Visible = false
					espData.healthBar.Visible = false
					espData.healthBarOutline.Visible = false
					espData.nameLabel.Visible = false
					espData.distanceLabel.Visible = false
				end
				
				-- ========== TRACER ==========
				if _G.ESPSettings.TracersEnabled then
					local fromPos
					local origin = _G.ESPSettings.TracersOrigin
					
					if origin == "Top" then
						fromPos = Vector2.new(viewportSize.X / 2, 0)
					elseif origin == "Center" then
						fromPos = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
					elseif origin == "Bottom" then
						fromPos = Vector2.new(viewportSize.X / 2, viewportSize.Y)
					elseif origin == "Mouse" then
						local mousePos = utility:MouseLocation()
						fromPos = Vector2.new(mousePos.X, mousePos.Y)
					elseif origin == "Top-Left" then
						fromPos = Vector2.new(0, 0)
					elseif origin == "Top-Right" then
						fromPos = Vector2.new(viewportSize.X, 0)
					elseif origin == "Bottom-Left" then
						fromPos = Vector2.new(0, viewportSize.Y)
					elseif origin == "Bottom-Right" then
						fromPos = Vector2.new(viewportSize.X, viewportSize.Y)
					else
						-- Fallback a Bottom
						fromPos = Vector2.new(viewportSize.X / 2, viewportSize.Y)
					end
					
					espData.tracer.From = fromPos
					espData.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
					-- CORRECCIÓN: usar _G.ESPSettings.TracersColor en lugar de dynamicColor
					espData.tracer.Color = _G.ESPSettings.TracersColor
					espData.tracer.Thickness = _G.ESPSettings.TracersThickness
					espData.tracer.Visible = true
				else
					espData.tracer.Visible = false
				end
				
				-- ========== SKELETON ==========
				if _G.ESPSettings.SkeletonEnabled then
					local parts = GetCharacterParts(model)
					local lineIndex = 1
					
					local function drawBone(part1, part2)
						if part1 and part2 and part1.Parent and part2.Parent and lineIndex <= #espData.skeletonLines then
							local pos1, visible1 = Camera:WorldToViewportPoint(part1.Position)
							local pos2, visible2 = Camera:WorldToViewportPoint(part2.Position)
							
							if visible1 and visible2 then
								local line = espData.skeletonLines[lineIndex]
								line.From = Vector2.new(pos1.X, pos1.Y)
								line.To = Vector2.new(pos2.X, pos2.Y)
								-- CORRECCIÓN: usar _G.ESPSettings.SkeletonColor en lugar de dynamicColor
								line.Color = _G.ESPSettings.SkeletonColor
								line.Thickness = _G.ESPSettings.SkeletonThickness
								line.Visible = true
								lineIndex = lineIndex + 1
							end
						end
					end
					
					-- R15 Skeleton
					if parts.UpperTorso then
						drawBone(parts.Head, parts.UpperTorso)
						drawBone(parts.UpperTorso, parts.LowerTorso)
						drawBone(parts.UpperTorso, parts.RightUpperArm)
						drawBone(parts.RightUpperArm, parts.RightLowerArm)
						drawBone(parts.RightLowerArm, parts.RightHand)
						drawBone(parts.UpperTorso, parts.LeftUpperArm)
						drawBone(parts.LeftUpperArm, parts.LeftLowerArm)
						drawBone(parts.LeftLowerArm, parts.LeftHand)
						drawBone(parts.LowerTorso, parts.RightUpperLeg)
						drawBone(parts.RightUpperLeg, parts.RightLowerLeg)
						drawBone(parts.RightLowerLeg, parts.RightFoot)
						drawBone(parts.LowerTorso, parts.LeftUpperLeg)
						drawBone(parts.LeftUpperLeg, parts.LeftLowerLeg)
						drawBone(parts.LeftLowerLeg, parts.LeftFoot)
					-- R6 Skeleton
					elseif parts.Torso then
						drawBone(parts.Head, parts.Torso)
						drawBone(parts.Torso, parts.RightArm)
						drawBone(parts.Torso, parts.LeftArm)
						drawBone(parts.Torso, parts.RightLeg)
						drawBone(parts.Torso, parts.LeftLeg)
					end
					
					for i = lineIndex, #espData.skeletonLines do
						espData.skeletonLines[i].Visible = false
					end
				else
					for _, line in ipairs(espData.skeletonLines) do
						line.Visible = false
					end
				end
				
				-- ========== GLOW ==========
				if _G.ESPSettings.GlowEnabled then
					espData.highlight.FillColor = _G.ESPSettings.GlowColor
					espData.highlight.OutlineColor = _G.ESPSettings.GlowColor
					
					-- CORRECCIÓN: Highlight usa 0=visible, 1=invisible
					-- Pero el slider dice "Transparency" así que invertimos
					local fillTrans = 1 - _G.ESPSettings.GlowTransparency
					
					if _G.ESPSettings.SoftESP then
						espData.highlight.OutlineTransparency = 0.7
						espData.highlight.FillTransparency = math.max(0, fillTrans - 0.3)
					else
						espData.highlight.OutlineTransparency = 0
						espData.highlight.FillTransparency = fillTrans
					end
					
					espData.highlight.Enabled = true
				else
					espData.highlight.Enabled = false
				end
				
			else
				-- Fuera de pantalla
				espData.box.Visible = false
				espData.boxOutline.Visible = false
				espData.healthBar.Visible = false
				espData.healthBarOutline.Visible = false
				espData.nameLabel.Visible = false
				espData.distanceLabel.Visible = false
				espData.tracer.Visible = false
				espData.highlight.Enabled = false
				for _, line in ipairs(espData.skeletonLines) do
					line.Visible = false
				end
			end
		end
	end)

	print("=== ESP SYSTEM MEJORADO CARGADO ===")
end

do
	local RunService = game:GetService("RunService")
	local Players = game:GetService("Players")
	local Workspace = game:GetService("Workspace")
	local UserInputService = game:GetService("UserInputService")
	local localPlayer = Players.LocalPlayer
	
	-- ============================================================================
	-- CONFIGURACIÓN DEL RADAR
	-- ============================================================================
	
	_G.RadarSettings = {
		-- General
		Enabled = false,
		
		-- Apariencia
		Shape = "Circle",
		Size = 200,
		Position = {X = 100, Y = 100},
		BackgroundColor = Color3.fromRGB(20, 20, 25),
		BackgroundTransparency = 0.3,
		BorderEnabled = true,
		BorderColor = Color3.fromRGB(255, 255, 255),
		BorderThickness = 2,
		
		-- Grid mejorado
		GridEnabled = true,
		GridColor = Color3.fromRGB(60, 60, 70),
		GridLines = 3,
		GridStyle = "Cross", -- "Cross", "Circles", "Both"
		
		-- Puntos cardinales
		ShowCardinals = true,
		CardinalSize = 14,
		CardinalColor = Color3.fromRGB(255, 200, 0),
		CardinalDistance = 10,
		
		-- Jugadores
		PlayerDotSize = 8,
		PlayerDotShape = "Circle",
		ShowPlayerNames = true,
		NameSize = 11,
		NameDistance = 15,
		ShowDistance = true,
		DistanceFormat = "m", -- "m" o "studs"
		
		-- Colores
		LocalPlayerColor = Color3.fromRGB(100, 255, 100),
		TeammateColor = Color3.fromRGB(100, 150, 255),
		EnemyColor = Color3.fromRGB(255, 100, 100),
		UseTeamColors = false,
		
		-- Distancia y Zoom
		RadarRange = 500,
		AutoZoom = false,
		ZoomStep = 100,
		MinZoom = 100,
		MaxZoom = 2000,
		ShowRangeCircle = true,
		
		-- Rotación
		RotateWithCamera = true,
		ShowNorthIndicator = true,
		NorthColor = Color3.fromRGB(255, 200, 0),
		ShowAllCardinals = true,
		
		-- Filtros
		TeamCheck = false,
		MaxDistance = 1000,
		ShowOutOfRange = false,
		OutOfRangeAlpha = 0.3,
		
		-- Efectos
		FadeEdges = true,
		PulseEffect = false,
		PulseSpeed = 2,
		SmoothRotation = true,
		
		-- FOV Cone
		ShowFOVCone = false,
		FOVConeColor = Color3.fromRGB(100, 255, 100),
		FOVConeAlpha = 0.15,
		FOVAngle = 60,
		
		-- Controles
		Draggable = true,
		ScrollToZoom = true,
		ToggleKey = Enum.KeyCode.M,
		ZoomInKey = Enum.KeyCode.Equals,
		ZoomOutKey = Enum.KeyCode.Minus
	}
	
	-- ============================================================================
	-- VARIABLES INTERNAS
	-- ============================================================================
	
	local radarFrame
	local radarCanvas
	local playerBlips = {}
	local currentRotation = 0
	local targetRotation = 0
	
	-- ============================================================================
	-- UTILIDADES
	-- ============================================================================
	
	local function GetPlayerTeam(player)
		return player and player.Team
	end
	
	local function IsTeammate(player)
		if not _G.RadarSettings.TeamCheck then return false end
		return GetPlayerTeam(player) == GetPlayerTeam(localPlayer)
	end
	
	local function WorldToRadar(worldPos, centerPos, radarSize, range)
		local relativePos = worldPos - centerPos
		local distance = relativePos.Magnitude
		
		if distance > range then
			if _G.RadarSettings.ShowOutOfRange then
				relativePos = relativePos.Unit * range
			else
				return nil, distance
			end
		end
		
		local scale = radarSize / (range * 2)
		
		if _G.RadarSettings.RotateWithCamera then
			local camera = Workspace.CurrentCamera
			local camLook = camera.CFrame.LookVector
			local angle = math.atan2(camLook.X, camLook.Z)
			
			local cos = math.cos(-angle)
			local sin = math.sin(-angle)
			local x = relativePos.X * cos - relativePos.Z * sin
			local z = relativePos.X * sin + relativePos.Z * cos
			
			relativePos = Vector3.new(x, relativePos.Y, z)
		end
		
		local radarX = relativePos.X * scale
		local radarY = -relativePos.Z * scale
		
		return Vector2.new(radarX, radarY), distance
	end
	
	local function GetPlayerColor(player)
		if player == localPlayer then
			return _G.RadarSettings.LocalPlayerColor
		end
		
		if _G.RadarSettings.UseTeamColors and player.Team then
			return player.Team.TeamColor.Color
		end
		
		if IsTeammate(player) then
			return _G.RadarSettings.TeammateColor
		else
			return _G.RadarSettings.EnemyColor
		end
	end
	
	-- ============================================================================
	-- CREAR UI DEL RADAR MEJORADA
	-- ============================================================================
	
	local function CreateRadarUI()
		if radarFrame then
			radarFrame:Destroy()
		end
		
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "RadarESP"
		screenGui.ResetOnSpawn = false
		screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
		
		-- Frame principal
		radarFrame = Instance.new("Frame")
		radarFrame.Name = "RadarFrame"
		radarFrame.Size = UDim2.new(0, _G.RadarSettings.Size, 0, _G.RadarSettings.Size)
		radarFrame.Position = UDim2.new(0, _G.RadarSettings.Position.X, 0, _G.RadarSettings.Position.Y)
		radarFrame.BackgroundColor3 = _G.RadarSettings.BackgroundColor
		radarFrame.BackgroundTransparency = _G.RadarSettings.BackgroundTransparency
		radarFrame.BorderSizePixel = 0
		radarFrame.ClipsDescendants = true
		radarFrame.ZIndex = 10
		radarFrame.Parent = screenGui
		
		if _G.RadarSettings.Shape == "Circle" then
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = radarFrame
		end
		
		if _G.RadarSettings.BorderEnabled then
			local border = Instance.new("UIStroke")
			border.Color = _G.RadarSettings.BorderColor
			border.Thickness = _G.RadarSettings.BorderThickness
			border.Parent = radarFrame
		end
		
		-- Canvas giratorio
		radarCanvas = Instance.new("Frame")
		radarCanvas.Name = "RadarCanvas"
		radarCanvas.Size = UDim2.new(1, 0, 1, 0)
		radarCanvas.Position = UDim2.new(0.5, 0, 0.5, 0)
		radarCanvas.AnchorPoint = Vector2.new(0.5, 0.5)
		radarCanvas.BackgroundTransparency = 1
		radarCanvas.ClipsDescendants = true
		radarCanvas.ZIndex = 11
		radarCanvas.Parent = radarFrame
		
		-- ========== GRID MEJORADO (RESPETA LÍMITES CIRCULARES) ==========
		if _G.RadarSettings.GridEnabled then
			local gridContainer = Instance.new("Frame")
			gridContainer.Name = "GridContainer"
			gridContainer.Size = UDim2.new(1, 0, 1, 0)
			gridContainer.BackgroundTransparency = 1
			gridContainer.ZIndex = 11
			gridContainer.Parent = radarCanvas
			
			if _G.RadarSettings.Shape == "Circle" then
				local gridCorner = Instance.new("UICorner")
				gridCorner.CornerRadius = UDim.new(1, 0)
				gridCorner.Parent = gridContainer
			end
			
			local gridLines = _G.RadarSettings.GridLines
			
			-- Círculos concéntricos
			if _G.RadarSettings.GridStyle == "Circles" or _G.RadarSettings.GridStyle == "Both" then
				for i = 1, gridLines do
					local circle = Instance.new("Frame")
					circle.Name = "Circle_" .. i
					local ratio = i / (gridLines + 1)
					local size = ratio * 2
					circle.Size = UDim2.new(size, 0, size, 0)
					circle.Position = UDim2.new(0.5, 0, 0.5, 0)
					circle.AnchorPoint = Vector2.new(0.5, 0.5)
					circle.BackgroundTransparency = 1
					circle.BorderSizePixel = 0
					circle.ZIndex = 11
					circle.Parent = gridContainer
					
					local stroke = Instance.new("UIStroke")
					stroke.Color = _G.RadarSettings.GridColor
					stroke.Thickness = 1
					stroke.Transparency = 0.5
					stroke.Parent = circle
					
					local corner = Instance.new("UICorner")
					corner.CornerRadius = UDim.new(1, 0)
					corner.Parent = circle
				end
			end
			
			-- Cruz central
			if _G.RadarSettings.GridStyle == "Cross" or _G.RadarSettings.GridStyle == "Both" then
				-- Línea horizontal
				local hLine = Instance.new("Frame")
				hLine.Size = UDim2.new(1, 0, 0, 1)
				hLine.Position = UDim2.new(0, 0, 0.5, 0)
				hLine.BackgroundColor3 = _G.RadarSettings.GridColor
				hLine.BorderSizePixel = 0
				hLine.BackgroundTransparency = 0.5
				hLine.ZIndex = 11
				hLine.Parent = gridContainer
				
				-- Línea vertical
				local vLine = Instance.new("Frame")
				vLine.Size = UDim2.new(0, 1, 1, 0)
				vLine.Position = UDim2.new(0.5, 0, 0, 0)
				vLine.BackgroundColor3 = _G.RadarSettings.GridColor
				vLine.BorderSizePixel = 0
				vLine.BackgroundTransparency = 0.5
				vLine.ZIndex = 11
				vLine.Parent = gridContainer
			end
		end
		
		-- ========== PUNTOS CARDINALES (N, S, E, W) ==========
		if _G.RadarSettings.ShowCardinals then
			local cardinals = {
				{text = "N", pos = UDim2.new(0.5, 0, 0, _G.RadarSettings.CardinalDistance)},
				{text = "E", pos = UDim2.new(1, -_G.RadarSettings.CardinalDistance - 10, 0.5, -7)},
				{text = "S", pos = UDim2.new(0.5, 0, 1, -_G.RadarSettings.CardinalDistance - 16)},
				{text = "W", pos = UDim2.new(0, _G.RadarSettings.CardinalDistance, 0.5, -7)}
			}
			
			for _, cardinal in ipairs(cardinals) do
				local label = Instance.new("TextLabel")
				label.Name = "Cardinal_" .. cardinal.text
				label.Size = UDim2.new(0, 20, 0, 20)
				label.Position = cardinal.pos
				label.BackgroundTransparency = 1
				label.Text = cardinal.text
				label.TextColor3 = _G.RadarSettings.CardinalColor
				label.TextSize = _G.RadarSettings.CardinalSize
				label.Font = Enum.Font.SourceSansBold
				label.TextStrokeTransparency = 0.5
				label.ZIndex = 15
				label.Parent = radarFrame
			end
		end
		
		-- ========== CÍRCULO DE RANGO ==========
		if _G.RadarSettings.ShowRangeCircle then
			local rangeCircle = Instance.new("Frame")
			rangeCircle.Name = "RangeCircle"
			rangeCircle.Size = UDim2.new(0.85, 0, 0.85, 0)
			rangeCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
			rangeCircle.AnchorPoint = Vector2.new(0.5, 0.5)
			rangeCircle.BackgroundTransparency = 1
			rangeCircle.ZIndex = 11
			rangeCircle.Parent = radarCanvas
			
			local rangeStroke = Instance.new("UIStroke")
			rangeStroke.Color = _G.RadarSettings.BorderColor
			rangeStroke.Thickness = 1
			rangeStroke.Transparency = 0.7
			rangeStroke.Parent = rangeCircle
			
			local rangeCorner = Instance.new("UICorner")
			rangeCorner.CornerRadius = UDim.new(1, 0)
			rangeCorner.Parent = rangeCircle
		end
		
		-- ========== CENTRO DEL RADAR (JUGADOR LOCAL) ==========
		local centerDot = Instance.new("Frame")
		centerDot.Name = "CenterDot"
		centerDot.Size = UDim2.new(0, 10, 0, 10)
		centerDot.Position = UDim2.new(0.5, -5, 0.5, -5)
		centerDot.BackgroundColor3 = _G.RadarSettings.LocalPlayerColor
		centerDot.BorderSizePixel = 0
		centerDot.ZIndex = 14
		centerDot.Parent = radarCanvas
		
		local centerCorner = Instance.new("UICorner")
		centerCorner.CornerRadius = UDim.new(1, 0)
		centerCorner.Parent = centerDot
		
		local centerStroke = Instance.new("UIStroke")
		centerStroke.Color = Color3.fromRGB(255, 255, 255)
		centerStroke.Thickness = 2
		centerStroke.Parent = centerDot
		
		-- ========== FOV CONE ==========
		if _G.RadarSettings.ShowFOVCone then
			local fovCone = Instance.new("ImageLabel")
			fovCone.Name = "FOVCone"
			fovCone.Size = UDim2.new(0.6, 0, 0.6, 0)
			fovCone.Position = UDim2.new(0.5, 0, 0.5, 0)
			fovCone.AnchorPoint = Vector2.new(0.5, 0.5)
			fovCone.BackgroundTransparency = 1
			fovCone.Image = "rbxassetid://8647929419"
			fovCone.ImageColor3 = _G.RadarSettings.FOVConeColor
			fovCone.ImageTransparency = 1 - _G.RadarSettings.FOVConeAlpha
			fovCone.ZIndex = 12
			fovCone.Parent = radarCanvas
		end
		
		-- ========== LABEL DE RANGO ==========
		local rangeLabel = Instance.new("TextLabel")
		rangeLabel.Name = "RangeLabel"
		rangeLabel.Size = UDim2.new(0, 80, 0, 18)
		rangeLabel.Position = UDim2.new(0.5, -40, 1, -22)
		rangeLabel.BackgroundTransparency = 0.5
		rangeLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		rangeLabel.Text = _G.RadarSettings.RadarRange .. "m"
		rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		rangeLabel.TextSize = 11
		rangeLabel.Font = Enum.Font.Code
		rangeLabel.TextStrokeTransparency = 0.5
		rangeLabel.ZIndex = 15
		rangeLabel.Parent = radarFrame
		
		local rangeCorner = Instance.new("UICorner")
		rangeCorner.CornerRadius = UDim.new(0, 4)
		rangeCorner.Parent = rangeLabel
		
		-- ========== DRAGGABLE ==========
		if _G.RadarSettings.Draggable then
			local dragging = false
			local dragStart
			local startPos
			
			radarFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					dragStart = input.Position
					startPos = radarFrame.Position
				end
			end)
			
			radarFrame.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
					_G.RadarSettings.Position.X = radarFrame.Position.X.Offset
					_G.RadarSettings.Position.Y = radarFrame.Position.Y.Offset
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = input.Position - dragStart
					radarFrame.Position = UDim2.new(
						startPos.X.Scale,
						startPos.X.Offset + delta.X,
						startPos.Y.Scale,
						startPos.Y.Offset + delta.Y
					)
				end
			end)
		end
		
		-- ========== SCROLL TO ZOOM ==========
		if _G.RadarSettings.ScrollToZoom then
			radarFrame.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseWheel then
					local delta = input.Position.Z
					local step = _G.RadarSettings.ZoomStep
					_G.RadarSettings.RadarRange = math.clamp(
						_G.RadarSettings.RadarRange + (delta > 0 and -step or step),
						_G.RadarSettings.MinZoom,
						_G.RadarSettings.MaxZoom
					)
					rangeLabel.Text = _G.RadarSettings.RadarRange .. "m"
				end
			end)
		end
		
		radarFrame.Visible = _G.RadarSettings.Enabled
		
		return screenGui
	end
	
	-- ============================================================================
	-- CREAR BLIP DE JUGADOR
	-- ============================================================================
	
	local function CreatePlayerBlip(player)
		if playerBlips[player] then
			return playerBlips[player]
		end
		
		local blipContainer = Instance.new("Frame")
		blipContainer.Name = player.Name .. "_Blip"
		blipContainer.Size = UDim2.new(0, _G.RadarSettings.PlayerDotSize, 0, _G.RadarSettings.PlayerDotSize)
		blipContainer.BackgroundTransparency = 1
		blipContainer.ZIndex = 13
		blipContainer.Parent = radarCanvas
		
		local dot = Instance.new("Frame")
		dot.Name = "Dot"
		dot.Size = UDim2.new(1, 0, 1, 0)
		dot.Position = UDim2.new(0.5, 0, 0.5, 0)
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.BackgroundColor3 = GetPlayerColor(player)
		dot.BorderSizePixel = 0
		dot.ZIndex = 13
		dot.Parent = blipContainer
		
		if _G.RadarSettings.PlayerDotShape == "Circle" then
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(1, 0)
			corner.Parent = dot
		elseif _G.RadarSettings.PlayerDotShape == "Triangle" then
			dot.BackgroundTransparency = 1
			local triangle = Instance.new("ImageLabel")
			triangle.Size = UDim2.new(1, 0, 1, 0)
			triangle.BackgroundTransparency = 1
			triangle.Image = "rbxassetid://8647929419"
			triangle.ImageColor3 = GetPlayerColor(player)
			triangle.ZIndex = 13
			triangle.Parent = dot
		elseif _G.RadarSettings.PlayerDotShape == "Diamond" then
			dot.Rotation = 45
		end
		
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(0, 0, 0)
		stroke.Thickness = 1
		stroke.Parent = dot
		
		local nameLabel = nil
		if _G.RadarSettings.ShowPlayerNames then
			nameLabel = Instance.new("TextLabel")
			nameLabel.Name = "NameLabel"
			nameLabel.Size = UDim2.new(0, 100, 0, 20)
			nameLabel.Position = UDim2.new(0.5, -50, 1, _G.RadarSettings.NameDistance)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Text = player.Name
			nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			nameLabel.TextSize = _G.RadarSettings.NameSize
			nameLabel.Font = Enum.Font.Code
			nameLabel.TextStrokeTransparency = 0.5
			nameLabel.ZIndex = 13
			nameLabel.Parent = blipContainer
		end
		
		if _G.RadarSettings.PulseEffect then
			local pulse = Instance.new("Frame")
			pulse.Name = "Pulse"
			pulse.Size = UDim2.new(2, 0, 2, 0)
			pulse.Position = UDim2.new(0.5, 0, 0.5, 0)
			pulse.AnchorPoint = Vector2.new(0.5, 0.5)
			pulse.BackgroundColor3 = GetPlayerColor(player)
			pulse.BackgroundTransparency = 0.7
			pulse.BorderSizePixel = 0
			pulse.ZIndex = 12
			pulse.Parent = blipContainer
			
			if _G.RadarSettings.PlayerDotShape == "Circle" then
				local pulseCorner = Instance.new("UICorner")
				pulseCorner.CornerRadius = UDim.new(1, 0)
				pulseCorner.Parent = pulse
			end
		end
		
		playerBlips[player] = {
			Container = blipContainer,
			Dot = dot,
			NameLabel = nameLabel,
			Player = player
		}
		
		return playerBlips[player]
	end
	
	-- ============================================================================
	-- ACTUALIZAR RADAR
	-- ============================================================================
	
	local function UpdateRadar()
		if not _G.RadarSettings.Enabled or not radarCanvas then
			return
		end
		
		local character = localPlayer.Character
		if not character then return end
		
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end
		
		local localPos = rootPart.Position
		local radarSize = _G.RadarSettings.Size
		local radarRange = _G.RadarSettings.RadarRange
		
		-- Rotación suave
		if _G.RadarSettings.RotateWithCamera then
			local camera = Workspace.CurrentCamera
			local camLook = camera.CFrame.LookVector
			targetRotation = math.deg(math.atan2(camLook.X, camLook.Z))
			
			if _G.RadarSettings.SmoothRotation then
				currentRotation = currentRotation + (targetRotation - currentRotation) * 0.15
			else
				currentRotation = targetRotation
			end
		end
		
		-- Actualizar jugadores
		for _, player in ipairs(Players:GetPlayers()) do
			if player == localPlayer then continue end
			
			if _G.RadarSettings.TeamCheck and IsTeammate(player) then
				if playerBlips[player] then
					playerBlips[player].Container.Visible = false
				end
				continue
			end
			
			local playerChar = player.Character
			if not playerChar then
				if playerBlips[player] then
					playerBlips[player].Container.Visible = false
				end
				continue
			end
			
			local playerRoot = playerChar:FindFirstChild("HumanoidRootPart")
			if not playerRoot then
				if playerBlips[player] then
					playerBlips[player].Container.Visible = false
				end
				continue
			end
			
			local playerPos = playerRoot.Position
			local radarPos, distance = WorldToRadar(playerPos, localPos, radarSize, radarRange)
			
			if not radarPos then
				if playerBlips[player] then
					playerBlips[player].Container.Visible = false
				end
				continue
			end
			
			local blip = playerBlips[player] or CreatePlayerBlip(player)
			blip.Container.Visible = true
			
			blip.Container.Position = UDim2.new(
				0.5, radarPos.X - _G.RadarSettings.PlayerDotSize / 2,
				0.5, radarPos.Y - _G.RadarSettings.PlayerDotSize / 2
			)
			
			local color = GetPlayerColor(player)
			blip.Dot.BackgroundColor3 = color
			
			if distance > radarRange * 0.8 and _G.RadarSettings.FadeEdges then
				local alpha = 1 - ((distance - radarRange * 0.8) / (radarRange * 0.2))
				blip.Dot.BackgroundTransparency = 1 - alpha
				if blip.NameLabel then
					blip.NameLabel.TextTransparency = 1 - alpha
				end
			else
				blip.Dot.BackgroundTransparency = 0
				if blip.NameLabel then
					blip.NameLabel.TextTransparency = 0
				end
			end
			
			if blip.NameLabel and _G.RadarSettings.ShowPlayerNames then
				local text = player.Name
				if _G.RadarSettings.ShowDistance then
					local distStr = math.floor(distance) .. _G.RadarSettings.DistanceFormat
					text = player.Name .. " [" .. distStr .. "]"
				end
				blip.NameLabel.Text = text
				blip.NameLabel.Visible = true
			elseif blip.NameLabel then
				blip.NameLabel.Visible = false
			end
		end
		
		-- Limpiar blips viejos
		for player, blip in pairs(playerBlips) do
			if not player.Parent or player.Parent ~= Players then
				blip.Container:Destroy()
				playerBlips[player] = nil
			end
		end
		
		-- Efecto de pulso
		if _G.RadarSettings.PulseEffect then
			local time = tick()
			local pulseAlpha = (math.sin(time * _G.RadarSettings.PulseSpeed * math.pi) + 1) / 2
			
			for _, blip in pairs(playerBlips) do
				local pulse = blip.Container:FindFirstChild("Pulse")
				if pulse then
					pulse.Size = UDim2.new(1 + pulseAlpha, 0, 1 + pulseAlpha, 0)
					pulse.BackgroundTransparency = 0.7 + (pulseAlpha * 0.3)
				end
			end
		end
	end
	
	-- ============================================================================
	-- INICIALIZACIÓN
	-- ============================================================================
	
	_G.InitializeRadar = function()
		print("=== INICIALIZANDO RADAR ESP ===")
		CreateRadarUI()
		
		RunService.RenderStepped:Connect(function()
			if _G.RadarSettings.Enabled then
				UpdateRadar()
			end
		end)
	end
	
	-- Teclas de control
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == _G.RadarSettings.ToggleKey then
			_G.RadarSettings.Enabled = not _G.RadarSettings.Enabled
			if radarFrame then
				radarFrame.Visible = _G.RadarSettings.Enabled
			end
		elseif input.KeyCode == _G.RadarSettings.ZoomInKey then
			_G.RadarSettings.RadarRange = math.clamp(
				_G.RadarSettings.RadarRange - _G.RadarSettings.ZoomStep,
				_G.RadarSettings.MinZoom,
				_G.RadarSettings.MaxZoom
			)
			local rangeLabel = radarFrame and radarFrame:FindFirstChild("RangeLabel")
			if rangeLabel then
				rangeLabel.Text = _G.RadarSettings.RadarRange .. "m"
			end
		elseif input.KeyCode == _G.RadarSettings.ZoomOutKey then
			_G.RadarSettings.RadarRange = math.clamp(
				_G.RadarSettings.RadarRange + _G.RadarSettings.ZoomStep,
				_G.RadarSettings.MinZoom,
				_G.RadarSettings.MaxZoom
			)
			local rangeLabel = radarFrame and radarFrame:FindFirstChild("RangeLabel")
			if rangeLabel then
				rangeLabel.Text = _G.RadarSettings.RadarRange .. "m"
			end
		end
	end)
	
	-- Cleanup
	localPlayer.AncestryChanged:Connect(function()
		if radarFrame then
			radarFrame.Parent:Destroy()
		end
	end)
	
	-- ============================================================================
	-- FUNCIONES PÚBLICAS
	-- ============================================================================
	
	function _G.RadarSettings:SetEnabled(enabled)
		self.Enabled = enabled
		if radarFrame then
			radarFrame.Visible = enabled
		end
	end
	
	function _G.RadarSettings:SetSize(size)
		self.Size = math.clamp(size, 100, 500)
		if radarFrame then
			radarFrame.Size = UDim2.new(0, self.Size, 0, self.Size)
		end
	end
	
	function _G.RadarSettings:SetRange(range)
		self.RadarRange = math.clamp(range, 50, 2000)
		local rangeLabel = radarFrame and radarFrame:FindFirstChild("RangeLabel")
		if rangeLabel then
			rangeLabel.Text = self.RadarRange .. "m"
		end
	end
	
	function _G.RadarSettings:SetShape(shape)
		self.Shape = shape
		CreateRadarUI()
	end
	
	function _G.RadarSettings:ResetPosition()
		self.Position = {X = 100, Y = 100}
		if radarFrame then
			radarFrame.Position = UDim2.new(0, 100, 0, 100)
		end
	end
	
end

-- ============================================================================
-- SISTEMA DE ESP PARA CAJAS FUERTES
-- ============================================================================

-- Variables globales del Safe ESP
_G.SafeESPSettings = {
    Enabled = false,
    MaxDistance = 2000,
    Color = Color3.fromRGB(255, 215, 0),
    ShowDistance = true,
    TextSize = 18,
    TrackedSafes = {}
}

-- Función para identificar cajas fuertes
local function isSafe(model)
    if not model:IsA("Model") then return false end
    
    -- Método 1: Por MeshId específico
    local meshPart = model:FindFirstChildOfClass("MeshPart", true)
    if meshPart and meshPart.MeshId == "rbxassetid://13895292237" then
        return true
    end
    
    -- Método 2: Por estructura de partes
    local requiredParts = {"Bolts", "Dials", "Hinge", "Pins", "Wheel", "Body"}
    local foundCount = 0
    
    for _, partName in ipairs(requiredParts) do
        if model:FindFirstChild(partName) then
            foundCount = foundCount + 1
        end
    end
    
    if foundCount >= 4 then return true end
    
    -- Método 3: Por material y color
    local body = model:FindFirstChild("Body")
    if body and body:IsA("MeshPart") then
        local color = body.Color
        local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)
        
        if body.Material == Enum.Material.CorrodedMetal and
           r >= 130 and r <= 150 and
           g >= 130 and g <= 150 and
           b >= 130 and b <= 150 then
            return true
        end
    end
    
    return false
end

-- Función para obtener la parte principal
local function getMainPart(model)
    return model:FindFirstChild("Body") or
           model:FindFirstChild("Wheel") or
           model.PrimaryPart or
           model:FindFirstChildWhichIsA("BasePart")
end

-- Función para crear ESP en una caja fuerte
local function createSafeESP(model)
    if not _G.SafeESPSettings.Enabled then return end
    if not model or not model.Parent then return end
    if _G.SafeESPSettings.TrackedSafes[model] then return end
    
    if isSafe(model) then
        local mainPart = getMainPart(model)
        
        if mainPart then
            local textDrawing = Drawing.new("Text")
            textDrawing.Text = "Safe"
            textDrawing.Size = _G.SafeESPSettings.TextSize
            textDrawing.Color = _G.SafeESPSettings.Color
            textDrawing.Center = true
            textDrawing.Outline = true
            textDrawing.OutlineColor = Color3.new(0, 0, 0)
            textDrawing.Visible = false
            textDrawing.ZIndex = 3
            
            _G.SafeESPSettings.TrackedSafes[model] = {
                drawing = textDrawing,
                part = mainPart
            }
            
            model.Destroying:Connect(function()
                if _G.SafeESPSettings.TrackedSafes[model] then
                    _G.SafeESPSettings.TrackedSafes[model].drawing:Remove()
                    _G.SafeESPSettings.TrackedSafes[model] = nil
                end
            end)
        end
    end
end

-- Escanear todas las cajas fuertes
local function scanAllSafes()
    if not _G.SafeESPSettings.Enabled then return end
    
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") then
            createSafeESP(model)
        end
    end
    
    local folders = {"Items", "Loot", "Interactables", "Props", "Map"}
    for _, folderName in ipairs(folders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, model in ipairs(folder:GetDescendants()) do
                if model:IsA("Model") then
                    createSafeESP(model)
                end
            end
        end
    end
end

-- Limpiar todo el ESP
local function clearAllSafeESP()
    for model, data in pairs(_G.SafeESPSettings.TrackedSafes) do
        pcall(function()
            data.drawing:Remove()
        end)
    end
    _G.SafeESPSettings.TrackedSafes = {}
end

-- Detectar nuevas cajas fuertes
Workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.1)
    if descendant:IsA("Model") then
        createSafeESP(descendant)
    end
end)

-- Actualizar ESP en cada frame
local updateCounter = 0
RunService.RenderStepped:Connect(function()
    if _G.SafeESPSettings.Enabled then
        updateCounter = updateCounter + 1
        
        if updateCounter % 200 == 0 then
            scanAllSafes()
        end
        
        for model, data in pairs(_G.SafeESPSettings.TrackedSafes) do
            if model and model.Parent and data.part and data.part.Parent then
                local distance = (camera.CFrame.Position - data.part.Position).Magnitude
                
                if distance <= _G.SafeESPSettings.MaxDistance then
                    local screenPos, onScreen = camera:WorldToViewportPoint(data.part.Position)
                    
                    if onScreen then
                        data.drawing.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                        data.drawing.Color = _G.SafeESPSettings.Color
                        data.drawing.Size = _G.SafeESPSettings.TextSize
                        
                        if _G.SafeESPSettings.ShowDistance then
                            data.drawing.Text = string.format("Safe [%dm]", math.floor(distance))
                        else
                            data.drawing.Text = "Safe"
                        end
                        
                        data.drawing.Visible = true
                    else
                        data.drawing.Visible = false
                    end
                else
                    data.drawing.Visible = false
                end
            else
                pcall(function()
                    data.drawing:Remove()
                end)
                _G.SafeESPSettings.TrackedSafes[model] = nil
            end
        end
    else
        for _, data in pairs(_G.SafeESPSettings.TrackedSafes) do
            data.drawing.Visible = false
        end
    end
end)
return library  -- ✅ Retornar la tabla



