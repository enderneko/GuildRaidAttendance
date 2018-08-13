local GRA, gra = unpack(select(2, ...))
-----------------------------------------------------------------------------------
-- create scroll frame (with scrollbar & content frame) 2017-07-17 08:40:41
-----------------------------------------------------------------------------------
function GRA:CreateScrollFrame(parent, top, bottom, color, border)
	-- create scrollFrame & scrollbar seperately (instead of UIPanelScrollFrameTemplate), in order to custom it
	local scrollFrame = CreateFrame("ScrollFrame", nil, parent)
	if not top then top = 0 end
	if not bottom then bottom = 0 end
	scrollFrame:SetPoint("TOPLEFT", 0, top) 
	scrollFrame:SetPoint("BOTTOMRIGHT", 0, bottom)

	function scrollFrame:Resize(newTop, newBottom)
		top = newTop
		bottom = newBottom
		scrollFrame:SetPoint("TOPLEFT", 0, top) 
		scrollFrame:SetPoint("BOTTOMRIGHT", 0, bottom)
	end

	if color then
		GRA:StylizeFrame(scrollFrame, color, border)
	end
	parent.scrollFrame = scrollFrame
	
	-- content
	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetSize(scrollFrame:GetWidth(), 20)
	scrollFrame:SetScrollChild(content)
	scrollFrame.content = content
	-- content:SetFrameLevel(2)
	
	-- scrollbar
	local scrollbar = CreateFrame("Frame", nil, scrollFrame)
	-- scrollbar:SetPoint("TOPLEFT", parent, "TOPRIGHT", -5, top) 
	-- scrollbar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, bottom)
	scrollbar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 2, 0)
	scrollbar:SetPoint("BOTTOMRIGHT", scrollFrame, 7, 0)
	scrollbar:Hide()
	GRA:StylizeFrame(scrollbar, {.1, .1, .1, .8})
	scrollFrame.scrollbar = scrollbar
	
	-- scrollbar thumb
	local scrollThumb = CreateFrame("Frame", nil, scrollbar)
	scrollThumb:SetWidth(scrollbar:GetWidth())
	scrollThumb:SetHeight(scrollbar:GetHeight())
	scrollThumb:SetPoint("TOP")
	GRA:StylizeFrame(scrollThumb, {.5, 1, 0, .8})
	scrollThumb:EnableMouse(true)
	scrollThumb:SetMovable(true)
	scrollThumb:SetHitRectInsets(-5, -5, 0, 0) -- Frame:SetHitRectInsets(left, right, top, bottom)
	
	-- reset content height manually ==> content:GetBoundsRect() make it right @OnUpdate
	function scrollFrame:ResetHeight()
		content:SetHeight(20)
	end
	
	-- local beforeScroll, afterScroll = nil, 0 -- no checking again and again -- TODO: remove
	-- reset to top, useful when used with DropDownMenu (variable content height)
	function scrollFrame:ResetScroll()
		scrollFrame:SetVerticalScroll(0)
		-- beforeScroll, afterScroll = nil, 0 -- TODO: remove
	end
	
	-- TODO: test on higher resolution
	-- local scrollRange -- ACCURATE scroll range, for SetVerticalScroll(), instead of scrollFrame:GetVerticalScrollRange()
	function scrollFrame:VerticalScroll(step)
		local scroll = scrollFrame:GetVerticalScroll() + step
		-- if CANNOT SCROLL then scroll = -25/25, scrollFrame:GetVerticalScrollRange() = 0
		-- then scrollFrame:SetVerticalScroll(0) and scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange()) ARE THE SAME
		if scroll <= 0 then
			scrollFrame:SetVerticalScroll(0)
		elseif  scroll >= scrollFrame:GetVerticalScrollRange() then
			scrollFrame:SetVerticalScroll(scrollFrame:GetVerticalScrollRange())
		else
			scrollFrame:SetVerticalScroll(scroll)
		end
	end

	-- gra.test = {}
	-- to remove/hide widgets "widget:SetParent(nil)" MUST be called!!!
	scrollFrame:SetScript("OnUpdate", function()
		-- set content height, check if it CAN SCROLL
		content:SetHeight(select(4, content:GetBoundsRect()))

		-- FIXME: it seems that BLZ has fix this problem (widgets in scroll child are not click-through even if they're not shown)
		--[[
		if beforeScroll ~= afterScroll then -- if scrollED then
			local top, bottom = scrollFrame:GetTop(), scrollFrame:GetBottom()
			-- GRA:Debug("Update Scroll Widgets Visibility...")
			-- hide "invisible" widgets
			for k, widget in pairs({content:GetChildren()}) do
				local widgetTop, widgetBottom = widget:GetTop(), widget:GetBottom()
				-- if widgetBottom+5 >= top or widgetTop-5 <= bottom then -- "invisible"
				if widgetTop and widgetBottom then -- "invisible"
					-- gra.test[k] = "visible"
					widget:Show()
				else
					-- gra.test[k] = "invisible"
					widget:Hide() -- hide will cause scrollrange changed, content:SetHeight() to prevent it
				end
			end
			beforeScroll = afterScroll
		end
		]]
	end)
	
	-- stores all widgets on content frame
	local autoWidthWidgets = {}

	function scrollFrame:ClearContent()
		for _, c in pairs({content:GetChildren()}) do
			c:SetParent(nil)  -- or it will show (OnUpdate)
			c:ClearAllPoints()
			c:Hide()
		end
		autoWidthWidgets = {}
		scrollFrame:ResetHeight()
	end

	function scrollFrame:Reset()
		scrollFrame:ResetScroll()
		scrollFrame:ClearContent()
	end
	
	-- just hide widgets, may STILL IN autoWidthWidgets
	-- function scrollFrame:HideWidget(widget)
	-- 	widget:SetParent(nil)
	-- 	widget:ClearAllPoints()
	-- 	widget:Hide()
	-- 	content:SetHeightselect(4, content:GetBoundsRect())
	-- end

	function scrollFrame:SetWidgetAutoWidth(widget)
		table.insert(autoWidthWidgets, widget)
	end
	
	-- on width changed, make the same change to widgets
	scrollFrame:SetScript("OnSizeChanged", function()
		-- change widgets width (marked as auto width)
		for i = 1, #autoWidthWidgets do
			autoWidthWidgets[i]:SetWidth(scrollFrame:GetWidth())
		end
		
		-- update content width
		content:SetWidth(scrollFrame:GetWidth())
	end)

	-- check if it can scroll
	content:SetScript("OnSizeChanged", function()
		-- set ACCURATE scroll range
		-- scrollRange = content:GetHeight() - scrollFrame:GetHeight()

		-- recheck widgets visibility
		-- beforeScroll, afterScroll = nil, 0 -- TODO: remove
		-- set thumb height (%)
		local p = scrollFrame:GetHeight() / content:GetHeight()
		p = tonumber(string.format("%.3f", p))
		if p < 1 then -- can scroll
			-- scrollThumb:SetHeight(GRA:Round(scrollbar:GetHeight()*p))
			scrollThumb:SetHeight(scrollbar:GetHeight()*p)
			-- space for scrollbar
			scrollFrame:SetPoint("BOTTOMRIGHT", parent, -7, bottom)
			scrollbar:Show()
		else
			scrollFrame:SetPoint("BOTTOMRIGHT", parent, 0, bottom)
			scrollbar:Hide()
		end
	end)

	-- DO NOT USE OnScrollRangeChanged to check whether it can scroll.
	-- "invisible" widgets should be hidden, then the scroll range is NOT accurate!
	-- scrollFrame:SetScript("OnScrollRangeChanged", function(self, xOffset, yOffset) end)
	
	-- dragging and scrolling
	scrollThumb:SetScript("OnMouseDown", function(self, button)
		if button ~= 'LeftButton' then return end
		local offsetY = select(5, scrollThumb:GetPoint(1))
		local mouseY = select(2, GetCursorPosition())
		local currentScroll = scrollFrame:GetVerticalScroll()
		self:SetScript("OnUpdate", function(self)
			--------------------- y offset before dragging + mouse offset
			local newOffsetY = offsetY + (select(2, GetCursorPosition()) - mouseY)
			
			-- even scrollThumb:SetPoint is already done in OnVerticalScroll, but it's useful in some cases.
			if newOffsetY >= 0 then -- @top
				scrollThumb:SetPoint("TOP")
				newOffsetY = 0
			elseif (-newOffsetY) + scrollThumb:GetHeight() >= scrollbar:GetHeight() then -- @bottom
				scrollThumb:SetPoint("TOP", 0, -(scrollbar:GetHeight() - scrollThumb:GetHeight()))
				newOffsetY = -(scrollbar:GetHeight() - scrollThumb:GetHeight())
			else
				scrollThumb:SetPoint("TOP", 0, newOffsetY)
			end
			-- GRA:Debug(newOffsetY)
			-- local vs = GRA:Round((-newOffsetY / (scrollbar:GetHeight()-scrollThumb:GetHeight())) * scrollFrame:GetVerticalScrollRange())
			local vs = (-newOffsetY / (scrollbar:GetHeight()-scrollThumb:GetHeight())) * scrollFrame:GetVerticalScrollRange()
			-- condition 0.99999 with GRA:Round?
			-- if scrollFrame:GetVerticalScrollRange() - vs <= 1 then vs = scrollFrame:GetVerticalScrollRange() end
			scrollFrame:SetVerticalScroll(vs)
		end)
	end)

	scrollThumb:SetScript("OnMouseUp", function(self)
		self:SetScript("OnUpdate", nil)
	end)
	
	scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
		local scrollP = scrollFrame:GetVerticalScroll()/scrollFrame:GetVerticalScrollRange()
		local yoffset = -((scrollbar:GetHeight()-scrollThumb:GetHeight())*scrollP)
		scrollThumb:SetPoint("TOP", 0, yoffset)

		-- afterScroll = scrollFrame:GetVerticalScroll() -- TODO: remove
	end)
	
	local step = 25
	
	function scrollFrame:SetScrollStep(s)
		step = s
	end
	
	-- enable mouse wheel scroll
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		if delta == 1 then -- scroll up
			scrollFrame:VerticalScroll(-step)
		elseif delta == -1 then -- scroll down
			scrollFrame:VerticalScroll(step)
		end
	end)
	
	return scrollFrame
end