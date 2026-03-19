--!strict
--[[
    State Machine
    by @M_RandomUser
]]

type CleanupFN = (() -> ())?
type StateFN = () -> CleanupFN

export type StateMachine<T> = {
	__index: any,

	CurrentState: T,

	_cleanup: () -> ()?, -- Cleanup function for current state
	_stateFNs: { [string]: StateFN },

	SetState: (self: StateMachine<T>, newState: T) -> (),
	OnState: (self: StateMachine<T>, state: T, StateFN) -> (),
}

local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new<T>(): StateMachine<T>
	local self = setmetatable({}, StateMachine) :: StateMachine<T>

	self.CurrentState = nil :: any

	self._cleanup = nil

	return self
end

function StateMachine.OnState<T>(self: StateMachine<T>, state: T, onEnter: StateFN)
	self._stateFNs[state :: string] = onEnter
end

function StateMachine.SetState<T>(self: StateMachine<T>, newState: T)
	if newState == self.CurrentState then
		return
	end

	if self.CurrentState and self._cleanup then
		self._cleanup()
		self._cleanup = nil
	end

	self.CurrentState = newState
	local onEnter = self._stateFNs[newState]
	if onEnter then
		self._cleanup = onEnter()
	end
end

return StateMachine
