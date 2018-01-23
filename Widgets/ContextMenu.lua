local GRA, gra = unpack(select(2, ...))
local L = select(2, ...).L
local LPP = LibStub:GetLibrary("LibPixelPerfect")

------------------------------------------------
-- context menu
------------------------------------------------
-- numItems < #items then scroll
function GRA:ShowContextMenu(parent, width, title, numItems, items)
	local height = gra.size.height
	if not gra.contextMenu then
		gra.contextMenu = CreateFrame("Frame", "GRA_ContextMenu")
		gra.contextMenu:SetClampedToScreen(true)
		-- gra.contextMenu:EnableMouse(true)
		gra.contextMenu:SetFrameStrata("TOOLTIP")
		GRA:StylizeFrame(gra.contextMenu, {.1, .1, .1, .95})
		gra.contextMenu:SetScale(GRA:GetScale())
		gra.contextMenu:SetScript("OnShow", function()
			LPP:PixelPerfectPoint(gra.contextMenu)
		end)

		-- title
		gra.contextMenu.titleFrame = CreateFrame("Frame", "GRA_ContextMenu", gra.contextMenu)
		gra.contextMenu.titleFrame:SetPoint("BOTTOM", gra.contextMenu, "TOP", 0, -1)
		gra.contextMenu.titleFrame:EnableMouse(true)
		GRA:StylizeFrame(gra.contextMenu.titleFrame, {.1, .1, .1, 1})
		gra.contextMenu.titleFrame.text = gra.contextMenu.titleFrame:CreateFontString(nil, "OVERLAY", "GRA_FONT_SMALL")
		gra.contextMenu.titleFrame.text:SetPoint("LEFT", 8, 0)
	
		-- cancel
		gra.contextMenu.cancelBtn = GRA:CreateButton(gra.contextMenu, L["Cancel"], "red", {width ,height}, "GRA_FONT_SMALL")
		gra.contextMenu.cancelBtn:SetPushedTextOffset(0, 0)
		gra.contextMenu.cancelBtn:GetFontString():ClearAllPoints()
		gra.contextMenu.cancelBtn:GetFontString():SetPoint("LEFT", 8, 0)
		gra.contextMenu.cancelBtn:SetPoint("BOTTOM")
		gra.contextMenu.cancelBtn:SetScript("OnClick", function()
			gra.contextMenu:Hide()
		end)

		-- highlight
		-- gra.contextMenu.highlight = gra.contextMenu:CreateTexture()
		-- gra.contextMenu.highlight:SetSize(5, height - 2)
		-- gra.contextMenu.highlight:SetColorTexture(unpack(gra.colors.chartreuse.t))
	end

	gra.contextMenu:SetScript("OnUpdate", function()
		if not parent:IsVisible() then
			gra.contextMenu:Hide()
		end
	end)

	if title then
		gra.contextMenu.titleFrame:SetSize(width, height)
		gra.contextMenu.titleFrame.text:SetText(gra.colors.chartreuse.s .. title)
		gra.contextMenu.titleFrame:Show()
	else
		gra.contextMenu.titleFrame:Hide()
	end

	-- set size
	if numItems and numItems < #items then -- scroll!!!
		gra.contextMenu:SetSize(width, height * numItems - numItems + 20) -- + 1 + 19
	else
		gra.contextMenu:SetSize(width, height * #items - #items + 20)
	end

	-- before create scroll frame, MUST SetPoint & SetSize!!!
	gra.contextMenu:ClearAllPoints()
	gra.contextMenu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", GRA:GetCursorPosition())
	if not gra.contextMenu.scrollFrame then
		GRA:CreateScrollFrame(gra.contextMenu, 0, 19)
		gra.contextMenu.highlight = gra.contextMenu.scrollFrame.content:CreateTexture()
		gra.contextMenu.highlight:SetSize(5, height - 2)
		gra.contextMenu.highlight:SetColorTexture(unpack(gra.colors.chartreuse.t))
	end
	gra.contextMenu.scrollFrame:SetScrollStep(height - 1)
	gra.contextMenu.scrollFrame:Reset()

	-- hide highlight
	gra.contextMenu.highlight:ClearAllPoints()
	gra.contextMenu.highlight:Hide()

	local last
	for _, item in pairs(items) do
		local b = GRA:CreateButton(gra.contextMenu.scrollFrame.content, item.text, "transparent-white", {width ,height}, "GRA_FONT_TEXT")
		b:GetFontString():ClearAllPoints()
		b:GetFontString():SetPoint("LEFT", 8, 0)
		gra.contextMenu.scrollFrame:SetWidgetAutoWidth(b)
		b:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
			GRA:Debug("|cffCDCD00ContextMenu: |r" .. item.text)
			gra.contextMenu:Hide()
			if item.onClick then item.onClick(item.text) end
		end)

		if item.highlight then
			gra.contextMenu.highlight:SetPoint("LEFT", b, 1, 0)
			gra.contextMenu.highlight:Show()
		end

		if last then
			b:SetPoint("TOP", last, "BOTTOM", 0, 1)
		else
			b:SetPoint("TOP")
		end
		last = b
	end

	gra.contextMenu:Show()
end

------------------------------------------------
-- test
------------------------------------------------
--@debug@
SLASH_CONTEXTMENUTEST1 = "/cmtest"
function SlashCmdList.CONTEXTMENUTEST(msg, editbox)
	local items = {}
	for i = 1, 30 do
		table.insert(items, {
			["text"] = i,
			["onClick"] = nil,
		})
	end
	GRA:ShowContextMenu(UIParent, 100, nil, 15, items)
	-- menu:SetPoint("CENTER")
	-- menu:Show()

	-- local gra.contextMenu = CreateFrame("Frame")
	-- gra.contextMenu:SetSize(200, 300)
	-- gra.contextMenu:SetPoint("CENTER")
	-- gra.contextMenu:Show()

	-- GRA:CreateScrollFrame(gra.contextMenu)
	-- -- GRA:StylizeFrame(gra.contextMenu.scrollFrame, {.1, .1, .1, .95})
	
	-- local last
	-- for i = 1, 30 do
	-- 	-- local row =	GRA:CreateRow(gra.contextMenu.scrollFrame.content, gra.contextMenu:GetWidth(), i)
	-- 	local row =	GRA:CreateButton(gra.contextMenu.scrollFrame.content, i, "", {gra.contextMenu:GetWidth() , 20}, "GRA_FONT_TEXT")
	-- 	if last then
	-- 		row:SetPoint("TOP", last, "BOTTOM", 0, 1)
	-- 	else
	-- 		row:SetPoint("TOP")
	-- 	end
	-- 	last = row
	-- end
end
--@end-debug@