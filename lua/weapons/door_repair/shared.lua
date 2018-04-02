AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Door Repair Tool"
    SWEP.Slot = 1
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = false
end

SWEP.Author = "Derpes"
SWEP.Instructions = "Left Click: Repair Door"
SWEP.Contact = "gmodresolute.net"
SWEP.Purpose = ""

SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"

SWEP.ViewModelFlip = false
SWEP.AnimPrefix  = "rpg"

SWEP.UseHands = true

SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.Category = "Resolute Tools"
SWEP.Sound = "weapons/crowbar/crowbar_impact1.wav"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
    self:SetHoldType("melee")
    self:SetWeaponHoldType( "melee" )
end

function SWEP:Deploy()
    if CLIENT or not IsValid(self:GetOwner()) then return true end
    self:GetOwner():DrawWorldModel(true)
    self:GetOwner():DrawViewModel(true)
    return true
end

function SWEP:Holster()
    return true
end

local canAnim
function SWEP:PrimaryAttack()
    if(CLIENT)then
        self.Owner:SetAnimation( PLAYER_ATTACK1 )
    end
    if(SERVER)then
        self.Owner:SetAnimation( PLAYER_ATTACK1 )
        self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
        self.Weapon:SetNextPrimaryFire(CurTime() + .75)
        local door = self.Owner:GetEyeTrace().Entity
        if(door:GetClass()!="func_door" and door:GetClass()!="func_button")then return end
        if(door:GetNWBool("isDoorBroken")==true)then
            if(self.Owner:GetPos():Distance(door:GetPos())>75)then return end
            door:SetNWInt("doorProgress",(door:GetNWInt("doorProgress") or 0)+10)
            door:EmitSound("weapons/crowbar/crowbar_impact1.wav")
            if(door:GetNWInt("doorProgress")>=100)then
                door:SetNWBool("isDoorBroken",false)
                door:SetNWInt("doorProgress",0)
                door:Fire("unlock")
                door:Fire("open")
                self.Owner:ChatPrint("The door has been successfully repaired!")
            end
        else
            if(door:isLocked())then
                self.Owner:ChatPrint("This door is just locked, no need for repairs here!")
            else
                self.Owner:ChatPrint("This door doesn't need repairing!")
            end
        end
    end
end

function SWEP:SecondaryAttack()

end

if(CLIENT)then

    surface.CreateFont("doorMain", {font="bebasneue", size=27})
    surface.CreateFont("doorPercent", {font="Bebas Neue Book", size=24})

    hook.Add("HUDPaint","repairDoorHUD",function()
        if(IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass()=="door_repair")then
            local door = LocalPlayer():GetEyeTrace().Entity
            if(LocalPlayer():GetPos():Distance(door:GetPos())>200)then return end
            if(door:GetNWBool("isDoorBroken")==true)then
                draw.SimpleTextOutlined("Repair Progress","doorMain",ScrW()/2,ScrH()/2,Color(150,0,0),1,1,1,Color(0,0,0))
                draw.SimpleTextOutlined(door:GetNWInt("doorProgress").."%","doorPercent",ScrW()/2,ScrH()/2+32,Color(210,80,80),1,1,1,Color(0,0,0))
            end
        end
    end)

end