/*---------------------------------------------------------------------------
Degradable StarwarsRP doors
Developed By Derpes, For Resolute Networks (Public on Facepunch though <3)

Any suggestions? Did I do some retarded code that could be much more efficient?
Let me know, I'm always up for criticism and want to learn from my mistakes!

Thanks for downloading this script and checking it out, I hope it helps increase
engineer RP upon your server!
---------------------------------------------------------------------------*/
--[[---------------------------------------------------------------------------------------
Configuration                                                                            --
-----------------------------------------------------------------------------------------]]
local mapsTable = {"rp_venator_extensive"} --Add more maps like so (AND REMEMBER, NO COMMA AFTER THE LAST STRING): local mapsTable = {"map1","map2","map3"}
local chanceDegraded = 400 --The chance in which it will degrade at random (This number is calculated by the times the door is used with E) Default: 400
local showDegradedMsg = true --Should a red chat message appear (SET BELOW WITH degradedMsg) to indicate that this door has degraded? Default: true
local degradedMsg = "This door is jammed, contact an engineer in comms!" --The message that shows when you attempt to open a door that is degraded
--[[
MapcreationID's of doors that won't degrade, use in server console while looking at a door:
lua_run print(Entity(1):GetEyeTrace().Entity:MapCreationID())
(Also I'm sorry, but these door IDs aren't for the extensive venator if you were curious, they were for Resolute's old custom map)
]]--
local unbreakableDoors = {
	[2306] = true,
	[2307] = true,
	[2278] = true,
	[2276] = true,
	[2274] = true,
	[2272] = true,
	[1408] = true,
	[1399] = true,
	[1395] = true,
	[1412] = true
}
--[[---------------------------------------------------------------------------------------
End of Configuration, don't touch anything below unless you're sure of what you're doing --
-----------------------------------------------------------------------------------------]]

if(SERVER)then
	
	if not(table.HasValue(mapsTable,game.GetMap()))then return end

	util.AddNetworkString("doorBreakClient")

	local cooldownMsg
	local cooldownBreak
	hook.Add("PlayerUse","doorBreak",function(ply,ent)

		if(ent:GetNWBool("isDoorBroken")==true)then
			if(ent.cooldownMsg)then return end
			if(ent:isLocked())then return end
			net.Start("doorBreakClient")
			net.Send(ply)
			ent.cooldownMsg = true
			timer.Simple(1.5,function()
				ent.cooldownMsg = false
			end)
			return
		else
			if(ent:isLocked() or unbreakableDoors[ent:MapCreationID()])then return end
			if(ent.cooldownBreak)then return end
			if(math.random(1,chanceDegraded)==(chanceDegraded/2))then
				ent:SetNWBool("isDoorBroken",true)
				ent:Fire("close")
				ent:Fire("lock")
			end
			ent.cooldownMsg = true
			timer.Simple(1,function()
				ent.cooldownMsg = false
			end)
		end

	end)

	local delayThink = 0
	hook.Add("Think","doorSpark",function()

		--6 second think hook delay to this from stressing your server out, don't worry; think hooks can be friendly
		if(delayThink>CurTime())then return end
		delayThink=CurTime()+6

		for k,v in pairs(ents.FindByClass("func_door"))do
			
			if(v:GetNWBool("isDoorBroken") == true)then
			
				v:Fire("unlock")
				v:Fire("open")
				timer.Simple(0.2,function()
					v:Fire("close")
					v:Fire("lock")
				end)

				local effectdata = EffectData()
				effectdata:SetOrigin( v:GetPos()+v:GetUp()*40+v:GetForward()*12 )
				effectdata:SetNormal( v:GetForward() )
				effectdata:SetMagnitude( 1 )
				effectdata:SetScale( 4 )
				effectdata:SetRadius( 5 )
				util.Effect( "Sparks", effectdata, true, true )

			end

		end

	end)

elseif(CLIENT)then
	
	net.Receive("doorBreakClient",function()
		if not(showDegradedMsg)then return end
		chat.AddText(Color(255,0,0),degradedMsg)
	end)

end