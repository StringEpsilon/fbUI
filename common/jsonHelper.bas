#include once "../fbUI.bas"

sub LoadUI(path as string)
	using fbUI
	dim json as JsonDocument
	
	if ( json.ReadFile(path) ) then
		if ( json.ContainsKey("window") ) then
			dim as uiControl ptr control
			dim as uiWindow ptr fbGUI = uiWindow.GetInstance()
			fbGUI->CreateWindow(cint(json["window"]["height"].value) , cint(json["window"]["width"].value))
			
			for i as integer = 0 to json["window"]["controls"].Count -1
				select case json["window"]["controls"][i]["type"].value
				case "scrollbar"
					fbGUI->AddControl(new uiScrollbar(json["window"]["controls"][i]))
				case "label"
					fbGUI->AddControl(new uiLabel(json["window"]["controls"][i]))
				case "listbox"
					fbGUI->AddControl(new uiListbox(json["window"]["controls"][i]))
				case "button"
					fbGUI->AddControl(new uiButton(json["window"]["controls"][i]))
				case "spinner"
					fbGUI->AddControl(new uiSpinner(json["window"]["controls"][i]))
				case "togglebutton"
					fbGUI->AddControl(new uiToggleButton(json["window"]["controls"][i]))
				case "textbox"
					fbGUI->AddControl(new uiTextbox(json["window"]["controls"][i]))
				end select
			next
			if ( control <> 0 ) then
				fbGUI->AddControl(control)
				control = 0
			end if
		end if
	end if
end sub
