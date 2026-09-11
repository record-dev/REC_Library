
---@type REC_Library.Server.Utils
local utils = require "@REC_Library.server.sv_utils"

local validator = require "@REC_Library.shared.sh_validator"

---@class REC_Library.Server.Class.Simulator.TrackSimulator
---@field info REC_Library.Server.Class.Simulator.TrackSimulatorConfigBuilder
local TrackSimulator = {}
TrackSimulator.__index = TrackSimulator

---instantiation
---@param config REC_Library.Server.Class.Simulator.TrackSimulatorConfigBuilder
---@return self
function TrackSimulator:new(config)
    local instance = setmetatable({}, self)
    instance.info = config
    return instance
end

---Monitor the train
---@param lastNodeIndex integer
---@param speed number
---@return boolean
function TrackSimulator:startMonitor(lastNodeIndex, speed)
    local info = self.info

    -- Skip if starting
    if info.hasRunningMonitor == true then
        utils:debugPrint("TrackSimulator:startMonitor - already running")
        return false
    end

    -- Monitoring enabled flag
    info.hasRunningMonitor = true

    info.currentNodeIndex = lastNodeIndex

    CreateThread(function (threadId)

        -- Store thread ID
        info.threadId = threadId

        info.timeAtNode = GetGameTimer()

        -- Start monitoring
        while info.hasRunningMonitor == true do
            Wait(info.waitTime)

            -- catch up on every node the train passed while we waited, a full lap is the
            -- most that can be needed and bounds the loop without yielding the server
            local guard = #info.trackNodes

            while guard > 0 do
                guard -= 1

                local nextNodeIndex = info.currentNodeIndex + 1

                -- If there is no next node, return to the first one and loop
                if info.trackNodes[nextNodeIndex] == nil then
                    nextNodeIndex = 1
                end

                -- Calculate distance to destination
                local distToNextNode = #(info.trackNodes[nextNodeIndex] - info.trackNodes[info.currentNodeIndex])

                -- Time required to reach destination
                local timeToNextNode = distToNextNode / speed

                -- Elapsed time
                local elapsedTime = (GetGameTimer() - info.timeAtNode) / 1000.0

                if elapsedTime < timeToNextNode then
                    break
                end

                info.currentNodeIndex = nextNodeIndex

                info.timeAtNode = info.timeAtNode + (timeToNextNode * 1000)

                utils:debugPrint("列車がノード " .. nextNodeIndex .. " に到達しました。（追いつき処理）")

                if info.onCurrentTrackNodeIndexChanged ~= nil then
                    info.onCurrentTrackNodeIndexChanged(self)
                end
            end
        end

        -- info.currentNodeIndex = 
    end)

    if info.onStartMonitor ~= nil then
        info.onStartMonitor(self)
    end

    return true
end

---Simulate the current node position
---@param speed number
---@param startNode integer
function TrackSimulator:simulateTrackNode(speed, startNode)
    local info = self.info


end

---Stop train monitoring
---@return boolean
function TrackSimulator:stopMonitor()
    local info = self.info

    -- Skip if not starting
    if info.hasRunningMonitor == false then
        utils:debugPrint("TrackSimulator:stopMonitor - not running")
        return false
    end

    --Disable monitoring
    info.hasRunningMonitor = false

    if info.onStopMonitor ~= nil then
        info.onStopMonitor(self)
    end

    return true
end

return TrackSimulator
