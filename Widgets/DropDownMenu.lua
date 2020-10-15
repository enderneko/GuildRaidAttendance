local GRA, gra = unpack(select(2, ...))

------------------------------------------------
-- drop down menu 2019-04-21 22:48:12
------------------------------------------------
function GRA:CreateDropDownMenu(parent, width)
	local menu = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	menu:SetSize(width, 20)
	menu:EnableMouse(true)
	menu:SetFrameLevel(6)
	GRA:StylizeFrame(menu)
	
	-- button: open/close menu list
	menu.button = GRA:CreateButton(menu, "", nil, {18 ,20}, "GRA_FONT_SMALL")
	menu.button:SetPoint("RIGHT")
	menu.button:SetFrameLevel(7)
	menu.button:SetNormalTexture([[Interface\AddOns\GuildRaidAttendance\Media\dropdown]])
	menu.button:SetPushedTexture([[Interface\AddOns\GuildRaidAttendance\Media\dropdown-pushed]])
	menu.button:SetDisabledTexture([[Interface\AddOns\GuildRaidAttendance\Media\dropdown-disabled]])
	
	-- selected item: just let you know which menu item is selected
	menu.text = menu:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	menu.text:SetJustifyV("MIDDLE")
	menu.text:SetJustifyH("LEFT")
	menu.text:SetWordWrap(false)
	menu.text:SetPoint("TOPLEFT", 5, -1)
	menu.text:SetPoint("BOTTOMRIGHT", -19, 1)
	
	-- item list
	local list = CreateFrame("Frame", nil, menu, "BackdropTemplate")
	GRA:StylizeFrame(list, {.1, .1, .1, .95})
	list:SetPoint("TOP", menu, "BOTTOM", 0, -2)
	list:SetFrameLevel(7) -- top of its strata
	list:SetSize(width, 5)
	list:Hide()
	
	-- keep all menu item buttons
	menu.items = {}

	-- selected text -> SavedVariable
	menu.selected = ""
	
	function menu:SetSelected(text)
		menu.text:SetText(text ~= "" and text or "-")
		menu.selected = text
		-- TODO: highlight
	end

	function menu:ClearItems()
		for _, b in pairs(menu.items) do
			b:SetParent(nil)
			b:ClearAllPoints()
			b:Hide()
		end
		table.wipe(menu.items)
		menu:SetSelected("")
	end
	
	-- items = {{["text"] = (string), ["onClick"] = (function)}, ...}
	function menu:SetItems(items)
		menu:ClearItems()
		local last = nil
		for k, item in pairs(items) do
			local b = GRA:CreateButton(list, item.text, "transparent", {width-2 ,18}, "GRA_FONT_SMALL", true)
			b.text = item.text
			table.insert(menu.items, b)
			b:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
				menu:SetSelected(item.text)
				GRA:Debug("|cffCDCD00DropDownMenu: |r" .. item.text)
				list:Hide()
				if item.onClick then item.onClick(item.text) end
			end)
			
			-- SetPoint
			if last then
				b:SetPoint("TOP", last, "BOTTOM", 0, 0)
			else
				b:SetPoint("TOPLEFT", 1, -1)
			end
			last = b
		end

		if #menu.items == 0 then
			list:SetHeight(5)
		else
			list:SetHeight(2 + #menu.items*18)
		end
	end

	function menu:AddItem(item)
		local b = GRA:CreateButton(list, item.text, "transparent", {width-2 ,18}, "GRA_FONT_SMALL")
		b.text = item.text
		b:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
			menu:SetSelected(item.text)
			GRA:Debug("|cffCDCD00DropDownMenu: |r" .. item.text)
			list:Hide()
			if item.onClick then item.onClick(item.text) end
		end)

		if #menu.items ~= 0 then
			b:SetPoint("TOP", menu.items[#menu.items], "BOTTOM", 0, 0)
		else
			b:SetPoint("TOPLEFT", 1, -1)
		end
		table.insert(menu.items, b)
		list:SetHeight(2 + #menu.items*18)
	end

	-- remove current selected item from list
	function menu:RemoveCurrentItem()
		for i = 1, #menu.items do
			if menu.selected  == menu.items[i].text then
				-- set next button position
				if menu.items[i+1] then
					menu.items[i+1]:SetPoint(menu.items[i]:GetPoint(1))
				end
				-- hide item
				menu.items[i]:SetParent(nil)
				menu.items[i]:ClearAllPoints()
				menu.items[i]:Hide()
				-- remove from table
				table.remove(menu.items, i)
				-- reset selected
				menu.selected = ""
				break
			end
		end

		menu.text:SetText("-")
		if #menu.items == 0 then
			list:SetHeight(5)
		else
			list:SetHeight(2 + #menu.items*18)
		end
	end

	-- set current item button 
	function menu:SetCurrentItem(item)
		for _, b in pairs(menu.items) do
			if menu.selected == b.text then
				b:SetText(item.text)
				b:SetScript("OnClick", function()
					PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
					menu:SetSelected(item.text)
					GRA:Debug("|cffCDCD00DropDownMenu: |r" .. item.text)
					list:Hide()
					if item.onClick then item.onClick(item.text) end
				end)
				break
			end
		end
		-- re-set current selected text
		menu:SetSelected(item.text)
	end

	function menu:Close()
		list:Hide()
	end
	
	function menu:SetEnabled(f)
		if f then
			menu.text:SetTextColor(1, 1, 1, 1)
		else
			menu.text:SetTextColor(unpack(gra.colors.grey.t))
		end
		menu.button:SetEnabled(f)
	end
	
	-- scripts
	menu.button:HookScript("OnClick", function()
		if list:IsShown() then list:Hide() else list:Show() end
	end)
	
	menu:SetScript("OnShow", function()
		list:Hide()
	end)
	
	return menu
end

------------------------------------------------
-- scrolled drop down menu 2017-06-19 04:09:59
------------------------------------------------
function GRA:CreateScrollDropDownMenu(parent, width)
	local menu = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	menu:SetSize(width, 20)
	menu:EnableMouse(true)
	menu:SetFrameLevel(6)
	GRA:StylizeFrame(menu)
	
	-- button: open/close menu list
	local button = GRA:CreateButton(menu, "", nil, {18 ,20}, "GRA_FONT_SMALL")
	button:SetPoint("RIGHT")
	button:SetFrameLevel(10)
	button:SetNormalTexture([[Interface\AddOns\GuildRaidAttendance\Media\dropdown]])
	button:SetPushedTexture([[Interface\AddOns\GuildRaidAttendance\Media\dropdown-pushed]])
	button:SetDisabledTexture([[Interface\AddOns\GuildRaidAttendance\Media\dropdown-disabled]])
	
	-- selected item: just let you know which menu item is selected
	menu.text = menu:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
	menu.text:SetJustifyV("MIDDLE")
	menu.text:SetJustifyH("LEFT")
	menu.text:SetWordWrap(false)
	menu.text:SetPoint("TOPLEFT", 5, -1)
	menu.text:SetPoint("BOTTOMRIGHT", -19, 1)
	
	-- scroll list
	local list = CreateFrame("ScrollFrame", nil, menu, "BackdropTemplate")
	GRA:StylizeFrame(list)
	list:SetPoint("TOP", menu, "BOTTOM", 0, -2)
	list:SetFrameLevel(7) -- top of its strata
	list:SetSize(width, 120)
	list:Hide()

	-- scroll content
	local content = CreateFrame("Frame", nil, list, "BackdropTemplate")
	-- GRA:StylizeFrame(content, {1, 0, 0, .1}, {0, 0, 0, 0})
	content:SetSize(width-20, 20)
	list:SetScrollChild(content)

	-- scroll bar
	local scrollBar = GRA:CreateSlider(list, nil, 0, 90, 120, 17, function(value)
		list:SetVerticalScroll(value)
	end, nil, "VERTICAL")
	scrollBar:SetPoint("TOPRIGHT")

	list:SetScript("OnVerticalScroll", function(self, offset)
		scrollBar:SetValue(offset)
	end)

	list:SetScript("OnUpdate", function()
		content:SetHeight(select(4, content:GetBoundsRect()))
		local top, bottom = list:GetTop(), list:GetBottom()
		for k, item in pairs({content:GetChildren()}) do
			local itemTop, itemBottom = item:GetTop(), item:GetBottom()
			if itemBottom+5 >= top or itemTop-5 <= bottom then -- "invisible"
				item:Hide()
			else
				item:Show()
			end
		end
	end)

	list:SetScript("OnScrollRangeChanged", function(self, x, y)
		scrollBar:SetMinMaxValues(0, y)
	end)
	
	list:SetScript("OnMouseWheel", function(self, delta)
		local scrolled = 0
		if delta == 1 then
			scrolled = list:GetVerticalScroll() - 18
			if scrolled <= 0 then
				list:SetVerticalScroll(0)
			else
				list:SetVerticalScroll(scrolled)
			end
		else
			scrolled = list:GetVerticalScroll() + 18
			if scrolled >= list:GetVerticalScrollRange() then
				list:SetVerticalScroll(list:GetVerticalScrollRange())
			else
				list:SetVerticalScroll(scrolled)
			end
		end
	end)

	-- keep all menu item buttons
	-- {(button), ...}
	menu.items = {}

	-- string
	menu.selected = nil

	function menu:SetSelected(text)
		menu.text:SetText((text and text ~= "") and text or "-")
		menu.selected = text
		-- TODO: highlight
	end

	function menu:ClearItems()
		for _, b in pairs(menu.items) do
			b:SetParent(nil)
			b:ClearAllPoints()
			b:Hide()
		end
		table.wipe(menu.items)
		menu:SetSelected(nil)
	end

	function menu:SetItems(items)
		-- clear items befor set
		menu:ClearItems()
		local last = nil
		for _, item in pairs(items) do
			local b = GRA:CreateButton(content, item.text, "transparent-white", {list:GetWidth()-5 ,18}, "GRA_FONT_SMALL")
			table.insert(menu.items, b)
			b:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
				menu:SetSelected(item.text)
				GRA:Debug("|cffCDCD00ScrolledDropDownMenu: |r" .. item.text)
				list:Hide()
				if item.onClick then item.onClick(item.text) end
			end)
			
			-- SetPoint
			if last then
				b:SetPoint("TOP", last, "BOTTOM", 0, 1)
			else
				b:SetPoint("TOPLEFT")
			end
			last = b
		end
	end

	--[[ test
	for i = 1, 10 do
		local b = GRA:CreateButton(content, i, "transparent", {list:GetWidth()-6 ,18}, "GRA_FONT_SMALL")
		b:SetScript("OnClick", function() list:Hide() end)
		table.insert(items, b)
	end
	]]

	button:SetScript("OnClick", function()
		if list:IsShown() then list:Hide() else list:Show() end
	end)

	function menu:Close()
		list:Hide()
	end
	
	function menu:SetEnabled(f)
		if f then
			menu.text:SetTextColor(1, 1, 1, 1)
		else
			menu.text:SetTextColor(unpack(gra.colors.grey.t))
		end
		button:SetEnabled(f)
	end

	-- function menu:ShowDropDown()
	-- 	menu:Show()
	-- end

	menu:SetScript("OnShow", function()
		list:SetVerticalScroll(0)
		list:Hide()
		menu.text:SetText(menu.selected and menu.selected or "-")
	end)

	return menu
end