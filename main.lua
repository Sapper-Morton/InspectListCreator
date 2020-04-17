ILC = LibStub("AceAddon-3.0"):NewAddon("ILC", "AceConsole-3.0", "AceEvent-3.0")

function ILC:OnInitialize()
---------------------------------------
-- Global variable initialization
---------------------------------------
	self.db = LibStub("AceDB-3.0"):New("InspectListCreatorDb", defaults)
	ILC:RegisterChatCommand('ilc', 'HandleChatCommand');

	if (UseCSV == nil) then
		UseCSV = false
	end

	if not InspectFrame then
		LoadAddOn("Blizzard_InspectUI")
	end

	local btn = CreateFrame('Button', nil, InspectFrame, 'UIPanelButtonTemplate')
	btn:SetPoint('BOTTOM', 0, 438)
	btn:SetText('Create list')
	btn:SetWidth(100)
	btn:SetHeight(25)
	btn:SetScript('OnClick', function()
		ILC:Generatelist()
	end)
	btn:RegisterEvent("PLAYER_LOGIN")	

end

function ILC:BoolText(input)
	local booltext = 'False'

	if (input) then
		booltext = 'True'
	end
	
	return booltext
end

function ILC:Generatelist()
	local characterSlots = {"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "Finger 1", "Finger 2", "Trinket 1", "Trinket 2", "Back", "Main hand", "Off hand", "Ranged"}
	local InspectItems = ILC:GetTargetItems()
	local itemlistsort = {}
	local exportString = ''
	local wowheadlink = ''
	local gametimehours, gametimeminutes = GetGameTime()
	local servertime = string.format("%02d", gametimehours) .. '.' .. string.format("%02d", gametimeminutes)
	if (UseCSV) then
		exportString = date("%d.%m.%Y ") .. ',' .. servertime .. ',' .. UnitName('target') .. ', \n'
	else
		exportString = 'Inspect list updated on ' .. date("%d.%m.%Y ") .. servertime .. ' server time\nCharacter: ' .. UnitName('target') .. '\n\n'
	end
	local itemCounter = ''

	for i = 1, 18 do
		if (UseCSV) then
			if (InspectItems[i].itemID > 0) then
				wowheadlink = 'https://classic.wowhead.com/item=' .. InspectItems[i].itemID
			else
				wowheadlink = ''
			end
			itemCounter = string.format("%d", InspectItems[i].count)
			exportString = exportString .. characterSlots[i] .. ',' .. InspectItems[i].itemName .. ',' .. itemCounter .. ',' .. wowheadlink ..'\n'
		else
			if (InspectItems[i].itemID > 0) then
				wowheadlink = ' https://classic.wowhead.com/item=' .. InspectItems[i].itemID
			else
				wowheadlink = ''
			end
			
			if (InspectItems[i].count > 0) then
				itemCounter = ' (' .. InspectItems[i].count .. ')  '
			else
				itemCounter = '  '
			end
			exportString = exportString .. characterSlots[i] .. ': ' .. InspectItems[i].itemName .. itemCounter .. wowheadlink ..'\n'
		end
	end
	
	ILC:DisplayExportString(exportString)
end

function ILC:GetTargetItems()

	local InspectItems = {}

	for slot = 1, 18 do
		local itemID = GetInventoryItemID("target", slot)

		local sName = "Empty slot"
		local sLink = 0
		local iRarity = 0
		local iLevel = 0
		local iMinLevel = 0 
		local sType = 0
		local sSubType = 0
		local count = 0			

		if (itemID == nil) then
			itemID = 0
		end

		if (itemID > 0) then
			sName, sLink, iRarity, iLevel, iMinLevel, sType, sSubType, count = GetItemInfo(itemID)
		end

		if (UseCSV) then
			if (count == nil) then
				count = 0
			end
			
			if ((sName == nil) or (sName == 'Empty slot')) then
				sName = ""
			end
		else
			if ((count == nil) or (count == 1)) then
				count = 0
			end
			
			if (sName == nil) then
				sName = "Empty slot"
			end
		end
		
		InspectItems[#InspectItems + 1] = {
			itemslot = slot,
			itemName = sName,
			itemID = itemID,
			count = count
		}
	end

	return InspectItems
end

function ILC:DisplayExportString(str)

	InspectLCFrame:Show();
	InspectLCFrameScroll:Show()
	InspectLCFrameScrollText:Show()
	InspectLCFrameScrollText:SetText(str)
	InspectLCFrameScrollText:HighlightText()
	InspectLCFrameButton:SetScript("OnClick", function(self)
		InspectLCFrame:Hide();
	end
	);
end

function ILC:HandleChatCommand(input)	

	local lcinput = string.lower(input)
	local gotcommands = false

---------------------------------------
-- Display help
---------------------------------------

	if (string.match(lcinput, "help")) then
		ILC:Print('Inspect List Creator Help')
		ILC:Print('Usage:')
		ILC:Print('Inspect target player and press Create list button')
		ILC:Print('/ilc               -- Manually initialize list creation of inspected player')
		ILC:Print('/ilc csv  true   -- Output list in CSV format')
		ILC:Print('/ilc csv  false -- Output list in original format')
		gotcommands = true
	end

	if (string.match(lcinput, "csv")) then
			if (string.match(lcinput, "csv true")) then
				ILC:Print('Outputting in CSV format')
				UseCSV = true
			end

			if (string.match(lcinput, "csv false")) then
				ILC:Print('Outputting in original format')
				UseCSV = false
			end
		gotcommands = true
	end

---------------------------------------
-- Generate list
---------------------------------------

	if (not gotcommands) then
		ILC:Generatelist()
	end
end
