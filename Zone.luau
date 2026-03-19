--[[
    Made by @M_RandomUser
]]

local Zone = {}
Zone.__index = Zone

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Modules
local Trove = require(ReplicatedStorage.Packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)

-->> Local Functions <<--
local function getHitPlayer(hit: Instance)
	local character = hit:FindFirstAncestorWhichIsA("Model")
	local player = character and Players:GetPlayerFromCharacter(character)
	return player
end

-->> Functions <<--
function Zone.new(part: BasePart)
	local self = setmetatable({}, Zone)

	self._trove = Trove.new()
	self.Instance = part

	-- Signals
	self.PlayerEntered = self._trove:Add(Signal.new())
	self.PlayerLeft = self._trove:Add(Signal.new())
	self.LocalPlayerEntered = self._trove:Add(Signal.new()) -- Client only
	self.LocalPlayerLeft = self._trove:Add(Signal.new()) -- Client only

	-- State
	self.PlayersInZone = {}

	self:Setup()

	return self
end

-->> Methods <<--
function Zone:Setup()
	self._trove:Connect(self.Instance.Touched, function(hit)
		self:OnTouched(hit)
	end)
	self._trove:Connect(self.Instance.TouchEnded, function(hit)
		self:OnTouchEnded(hit)
	end)
	self._trove:Connect(Players.PlayerRemoving, function(player)
		self.PlayersInZone[player] = nil
	end)
end

function Zone:OnTouched(hit)
	local player = getHitPlayer(hit)
	if not player or self.PlayersInZone[player] or not self:IsPlayerInRegion(player) then
		return
	end

	self.PlayersInZone[player] = true
	self.PlayerEntered:Fire(player)

	if RunService:IsClient() and player == Players.LocalPlayer then
		self.LocalPlayerEntered:Fire()
	end
end

function Zone:OnTouchEnded(hit)
	local player = getHitPlayer(hit)
	if not player or not self.PlayersInZone[player] or self:IsPlayerInRegion(player) then
		return
	end

	self.PlayersInZone[player] = nil
	self.PlayerLeft:Fire(player)

	if RunService:IsClient() and player == Players.LocalPlayer then
		self.LocalPlayerLeft:Fire()
	end
end

function Zone:IsPlayerInRegion(player)
	local parts = workspace:GetPartsInPart(self.Instance)
	for _, part in parts do
		local otherPlayer = getHitPlayer(part)
		if player == otherPlayer then
			return true
		end
	end

	return false
end

function Zone:Destroy()
	self._trove:Clean()
end

return Zone
