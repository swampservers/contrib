-- This file is subject to copyright - contact swampservers@gmail.com for more information.
-- INSTALL: CINEMA

--[[   _                                
	( )                               
   _| |   __   _ __   ___ ___     _ _ 
 /'_` | /'__`\( '__)/' _ ` _ `\ /'_` )
( (_| |(  ___/| |   | ( ) ( ) |( (_| |
`\__,_)`\____)(_)   (_) (_) (_)`\__,_) 

	DHTML

--]]

local RealTime = RealTime

DEFINE_BASECLASS( "Panel" )

local PANEL = {}

local JS_CallbackHack = [[(function(){
	var funcname = '%s';
	window[funcname] = function(){
		_gm[funcname].apply(_gm,arguments);
	}
})();]]

local ConsoleColors = {
	["default"] = Color(255,160,255),
	["text"] = Color(255,255,255),
	["error"] = Color(235,57,65),
	["warn"] = Color(227,181,23),
	["info"] = Color(100,173,229),
}

local FilterCVar = CreateClientConVar( "cinema_html_filter", 0, true, false )

local FILTER_ALL = 0
local FILTER_NONE = 1

AccessorFunc( PANEL, "m_bScrollbars", 			"Scrollbars", 		FORCE_BOOL )
AccessorFunc( PANEL, "m_bAllowLua", 			"AllowLua", 		FORCE_BOOL )

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:Init()

	self.History = {}
	self.CurrentPage = 0

	self.URL = ""

	self:SetScrollbars( true )
	self:SetAllowLua( false )

	self.JS = {}
	self.Callbacks = {}

	self.urlLoading = true

	--
	-- Implement a console - because awesomium doesn't provide it for us anymore.
	--
	local console_funcs = {'log','error','debug','warn','info','gmod'}
	for _, func in pairs(console_funcs) do
		self:AddFunction( "console", func, function( param )
			self:ConsoleMessage( param, func )
		end )
	end
	
	self:AddFunction( "window", "open", function()
		-- prevents popups from opening
	end)

end

function PANEL:SetupCallbacks()

end

function PANEL:Think()

	-- Poll page for URL change
	if not self._nextUrlPoll or self._nextUrlPoll < RealTime() then
		self:FetchPageURL()
		self._nextUrlPoll = RealTime() + 0.1
	end

	if self:IsLoading() then
--[[
		-- Call started loading
		if not self._loading then

			self:FetchPageURL()

			-- Delay setting up callbacks
			timer.Simple( 0.05, function()
				if IsValid( self ) then
					self:SetupCallbacks()
				end
			end )

			self._loading = true
			self:OnStartLoading()
			
		end]]

	else
--[[
		-- Call finished loading
		if self._loading then

			self:FetchPageURL()

			-- Hack to add window object callbacks
			if self.Callbacks.window then

				for funcname, callback in pairs(self.Callbacks.window) do
					local js = JS_CallbackHack:format(funcname)
					self:RunJavascript(js)
				end

			end

			self._loading = nil
			self:OnFinishLoading()

		end]]

		-- Run queued javascript
		if self.JS then
			for k, v in pairs( self.JS ) do
				if (LocalPlayer().videoDebug) then print("(JS)",v) end
				self:RunJavascript( string.format( "if(document.readyState=='complete'){%s}else{if(typeof queuedJS=='undefined'){var queuedJS=[];window.addEventListener('load',function(){for(i in queuedJS){queuedJS[i]()}})};queuedJS.push(function(){%s})};", v, v ) )
			end
			self.JS = {}
		end

	end

end

function PANEL:EnsureURL(url)
	if self:GetURL() ~= url then self:OpenURL(url, true) end
end

function PANEL:FetchPageURL()
	self:RunJavascript('if (document.readyState === "complete") { console.log("HREF:"+window.location.href); }')
end

function PANEL:OpenURL( url, ignoreHistory )

	if not ignoreHistory then
		-- Pop URLs from the stack
		while #self.History ~= self.CurrentPage do
			table.remove( self.History )
		end
		table.insert( self.History, url )
		self.CurrentPage = self.CurrentPage + 1
	end

	self:SetURL( url )

	BaseClass.OpenURL( self, url )
	self.urlLoading = true

end

function PANEL:IsLoading()
	return self.urlLoading or BaseClass.IsLoading( self )
end

function PANEL:GetURL()
	return self.URL
end

function PANEL:SetURL( url )
	local current = self.URL

	if current ~= url then
		self:OnURLChanged( url, current )
	end

	self.URL = url
end

function PANEL:OnURLChanged( new, old )

end

--[[---------------------------------------------------------
	Window loading events
-----------------------------------------------------------]]

--
-- Called when the page begins loading
--
function PANEL:OnStartLoading()

end

--
-- Called when the page finishes loading all assets
--
function PANEL:OnFinishLoading()

end

function PANEL:QueueJavascript( js )

	--
	-- Can skip using the queue if there's nothing else in it
	--
	--if ( !self.JS && !self:IsLoading() ) then
	--	return self:RunJavascript( js )
	--end

	self.JS = self.JS or {}

	table.insert( self.JS, js )
	self:Think();

end

PANEL.QueueJavaScript = PANEL.QueueJavascript
PANEL.Call = PANEL.QueueJavascript

concommand.Add("cinema_debug_video",function(ply)
	ply.videoDebug = not ply.videoDebug
	print("video debug set to "..tostring(ply.videoDebug))
end)

concommand.Add("cinema_debug_setvideo",function(ply,cmd,str)
	if not ply:InTheater() or str[1] == nil then return end
	if not IsValid(ply.theaterPanel) then
		print("no valid theater panel")
		return
	end
	print("video set to "..str[1])
	ply.theaterPanel:EnsureURL(str[1])
end)

concommand.Add("cinema_debug_videojavascript",function(ply,cmd,str)
	if not ply:InTheater() or str[1] == nil then return end
	if not IsValid(ply.theaterPanel) then
		print("no valid theater panel")
		return
	end
	st = str[1] --string.JavascriptSafe(str[1])
	print("javascript ("..st..") sent to "..ply.theaterPanel:GetURL())
	ply.theaterPanel:RunJavascript(st)
end)

function PANEL:ConsoleMessage( msg, func )

	if (LocalPlayer().videoDebug and !isstring(msg)) then print("[JS] "..tostring(msg),type(msg)) end
	if (!isstring(msg)) then msg = "*js variable*" end
	
	if (LocalPlayer().videoDebug and not msg:StartWith("HREF:") and isstring(msg)) then print(msg) end

	if msg:StartWith("HREF:") then
		local url =msg:sub(6)
		self:SetURL( url )
		if url~="about:blank" then self.urlLoading = false end
	end

	if ( self.m_bAllowLua && msg:StartWith( "RUNLUA:" ) ) then
	
		local strLua = msg:sub( 8 )

		SELF = self
		--Too much exploit potential here
		--RunString( strLua )
		SELF = nil
		return; 

	end

	if ( self.m_bAllowLua && msg:StartWith( "RVIDEO:" ) ) then
	
		local strLua = msg:sub( 8 )

		SELF = self
		RequestVideoURL(strLua)
		SELF = nil

		return; 

	end

	if ( msg:StartWith( "CLIPBOARD:" ) ) then
	
		local strLua = msg:sub( 11 )

		SELF = self
		SetClipboardText(strLua)
		SELF = nil

		return; 

	end

	

	-- Filter messages output to the console
	-- 'console.gmod' always gets output
	local filterLevel = FilterCVar:GetInt()
	if ( func != "gmod" and filterLevel == FILTER_ALL ) then return end

	local prefixColor = ConsoleColors.default
	local prefix = "[HTML"
	if func and func:len() > 0 and func ~= "log" then
		if ConsoleColors[func] then
			prefixColor = ConsoleColors[func]
		end
		prefix = prefix .. "::" .. func:upper()
	end
	prefix = prefix .. "] "

	MsgC( prefixColor, prefix )
	MsgC( ConsoleColors.text, msg, "\n" )	

end

local JSObjects = {
	window 	= "_gm",
	this 	= "_gm",
	_gm = "window"
}

--
-- Called by the engine when a callback function is called
--
function PANEL:OnCallback( obj, func, args )

	-- Hack for adding window callbacks
	obj = JSObjects[obj] or obj

	if not self.Callbacks[ obj ] then return end

	--
	-- Use AddFunction to add functions to this.
	--
	local f = self.Callbacks[ obj ][ func ]

	if ( f ) then
		return f( unpack( args ) )
	end

end

--
-- Add a function to Javascript
--
function PANEL:AddFunction( obj, funcname, func )

	if obj == "this" then
		obj = "window"
	end

	--
	-- Create the `object` if it doesn't exist
	--
	if ( !self.Callbacks[ obj ] ) then
		self:NewObject( obj )
		self.Callbacks[ obj ] = {}
	end

	--
	-- This creates the function in javascript (which redirects to c++ which calls OnCallback here)
	--
	self:NewObjectCallback( JSObjects[obj] or obj, funcname )

	--
	-- Store the function so OnCallback can find it and call it
	--
	self.Callbacks[ obj ][ funcname ] = func;

end

function PANEL:HTMLBack()
	if self.CurrentPage <= 1 then return end
	self.CurrentPage = self.CurrentPage - 1
	self:OpenURL( self.History[ self.CurrentPage ], true )
end

function PANEL:HTMLForward()
	if self.CurrentPage == #self.History then return end
	self.CurrentPage = self.CurrentPage + 1
	self:OpenURL( self.History[ self.CurrentPage ], true )
end

function PANEL:OpeningURL( url )
	
end

function PANEL:FinishedURL( url )
	
end

derma.DefineControl( "TheaterHTML", "Extended DHTML control", PANEL, "Awesomium" )
