local editFrame = CreateFrame("ScrollFrame", nil, UIParent, "InputScrollFrameTemplate")
editFrame:SetPoint("CENTER")
editFrame:SetSize(600, 300)
editFrame.CharCount:Hide()
editFrame:Hide()

local editBox = editFrame.EditBox
editBox:SetMultiLine(true)
editBox:SetMaxLetters(99999)
editBox:EnableMouse(true)
editBox:SetAutoFocus(false)
editBox:SetFontObject(ChatFontNormal)
editBox:SetWidth(editFrame:GetWidth())
editBox:SetTextInsets(20, 35, 20, 20)
editBox:SetAllPoints()

local closeButton = CreateFrame("Button", nil, editFrame, "UIPanelCloseButton")
closeButton:SetFrameStrata("HIGH")
closeButton:SetScript("OnClick", function(self)
	editBox:SetText("")
	editBox:ClearFocus()
	editFrame:Hide()
end)

editBox:SetScript("OnEscapePressed", function(self)
	closeButton:Click()
end)

local prevText = ""
editBox:SetScript("OnTextChanged", function(self)
	self:SetText(prevText)
	self:SetCursorPosition(0)
	self:SetFocus()
	self:HighlightText()
	if editFrame.ScrollBar:IsShown() then
		closeButton:SetPoint("TOPRIGHT", -15, 0)
	else
		closeButton:SetPoint("TOPRIGHT")
	end
end)

do
	-- https://wowwiki.fandom.com/wiki/UI_escape_sequences
	
	local patterns = {
		"{.-}",                             -- Icons
		"|T.-|t",                           -- Textures
		"|c%x%x%x%x%x%x%x%x(.-)|r",         -- Colors
		"|c%x%x%x%x%x%x%x%x|H.-|h(.-)|h",   -- Links
		"|H.-|h(.-)|h",                     -- Links
		"|K.-|k",                           -- Battle.Net
		-- review: Might want to escape pipes only in debug mode but we'll see.
		"\124"                              -- Pipe
	}

	local replacements = {
		"",                                 -- Icons
		"",                                 -- Textures
		"%1",                               -- Colors
		"%1",                               -- Links
		"%1",                               -- Links
		"BNPlayer",                         -- Battle.Net
		"%0%0"                              -- Pipe
	}

	local function Unescape(msg)
		for index = 1, #patterns do
			local pattern = patterns[index]
			local replacement = replacements[index]
			msg = msg:gsub(pattern, replacement)
		end
		msg = msg:trim()
		msg = msg:trim("")
		return msg
	end

	local function SetupButtons(chatFrame)
        local anchorFrame = CreateFrame("Frame", nil, chatFrame)
        anchorFrame:SetPoint("TOPRIGHT")
        anchorFrame:SetSize(140, 20)
        anchorFrame:Hide()

		local copyButton = CreateFrame("Button", nil, anchorFrame, "UIPanelButtonTemplate")
		copyButton:SetPoint("TOPRIGHT")
		copyButton:SetSize(70, 20)
		copyButton:SetText("Copy")
        
        local clearButton = CreateFrame("Button", nil, anchorFrame, "UIPanelButtonTemplate")
		clearButton:SetPoint("TOPRIGHT", copyButton, "TOPLEFT")
		clearButton:SetSize(70, 20)
		clearButton:SetText("Clear")

		copyButton:SetScript("OnClick", function(self)
			editBox:SetText("")

			if not chatFrame.lines then
				chatFrame.lines = {}
			else
				table.wipe(chatFrame.lines)
			end

			local lines = chatFrame.lines

			for index = 1, chatFrame:GetNumMessages() do
				local msg = chatFrame:GetMessageInfo(index)
				msg = Unescape(msg)
				if msg ~= "" then
					tinsert(lines, 1, msg)
				end
			end
			
			prevText = table.concat(lines, "\n")

            editBox:SetText(prevText)
			editFrame:Show()
		end)

        copyButton:SetScript("OnLeave", function(self)
            anchorFrame:Hide()
        end)

        clearButton:SetScript("OnClick", function(self)
			chatFrame:Clear()
		end)

        clearButton:SetScript("OnLeave", function(self)
            anchorFrame:Hide()
        end)

		chatFrame:SetScript("OnEnter", function(self)
            anchorFrame:Show()
        end)

		chatFrame:SetScript("OnLeave", function(self)
            local obj = GetMouseFocus()
            if obj and obj:GetObjectType() ~= "Button" then
                anchorFrame:Hide()
            end
        end)
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local chatFrame = _G["ChatFrame" .. i]
		if chatFrame then
			SetupButtons(chatFrame)
		end
	end
end