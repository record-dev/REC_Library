
---@class REC_Library.Server.API
local api = {

    ---@class REC_Library.Server.API.Class
    Class = {

        ---@class REC_Library.Server.API.Class.Manager
        ---@field EntityManager REC_Library.Server.Class.Manager.EntityManager
        ---@field EntityManagerConfigBuilder REC_Library.Server.Class.Manager.EntityManagerConfigBuilder
        ---@field HeartbeatManager  REC_Library.Server.Class.Manager.HeartbeatManager
        ---@field HeartbeatManagerConfigBuilder  REC_Library.Server.Class.Manager.HeartbeatManagerConfigBuilder
        ---@field HeistManager REC_Library.Server.Class.Manager.HeistManager
        ---@field HeistManagerConfigBuilder REC_Library.Server.Class.Manager.HeistManagerConfigBuilder
        ---@field OwnershipManager REC_Library.Server.Class.Manager.OwnershipManager
        ---@field OwnershipManagerConfigBuilder REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder
        ---@field PlayerManager REC_Library.Server.Class.Manager.PlayerManager
        ---@field PlayerManagerConfigBuilder REC_Library.Server.Class.Manager.PlayerManagerConfigBuilder
        ---@field SequenceManager REC_Library.Server.Class.Manager.SequenceManager
        ---@field SequenceManagerConfigBuilder REC_Library.Server.Class.Manager.SequenceManagerConfigBuilder
        ---@field ServerManager REC_Library.Server.Class.Manager.ServerManager
        ---@field ServerManagerConfigBuilder REC_Library.Server.Class.Manager.ServerManagerConfigBuilder
        ---@field ZoneManager REC_Library.Server.Class.Manager.ZoneManager
        ---@field ZoneManagerConfigBuilder REC_Library.Server.Class.Manager.ZoneManagerConfigBuilder
        Manager = {
            ServerManager = require "@REC_Library.server.class.manager.sv_serverManager",
            ServerManagerConfigBuilder = require "@REC_Library.server.class.manager.sv_serverManagerConfigBuilder",
            SequenceManager = require "@REC_Library.server.class.manager.sv_sequenceManager",
            SequenceManagerConfigBuilder = require "@REC_Library.server.class.manager.sv_sequenceManagerConfigBuilder",
            HeistManager = require "@REC_Library.server.class.manager.sv_heistManager",
            HeistManagerConfigBuilder = require "@REC_Library.server.class.manager.sv_heistManagerConfigBuilder",
            EntityManager = require "@REC_Library.server.class.manager.sv_entityManager",
            EntityManagerConfigBuilder = require "@REC_Library.server.class.manager.sv_entityManagerConfigBuilder",
            HeartbeatManager = require "@REC_Library.server.class.manager.sv_heartbeatManager",
            HeartbeatManagerConfigBuilder = require "@REC_Library.server.class.manager.sv_heartbeatManagerConfigBuilder",
            OwnershipManager = require "@REC_Library.server.class.manager.sv_ownershipManager",
            OwnershipManagerConfigBuilder = require "@REC_Library.server.class.manager.sv_ownershipManagerConfigBuilder",
            PlayerManager = require "@REC_Library.server.class.manager.sv_playerManager",
            PlayerManagerConfigBuilder = require "@REC_Library.server.class.manager.sv_playerManagerConfigBuilder",
            ZoneManager = require "@REC_Library.server.class.manager.sv_zoneManager",
            ZoneManagerConfigBuilder = require "@REC_Library.server.class.manager.sv_zoneManagerConfigBuilder",
        },

        ---@class REC_Library.Server.API.Class.Object
        ---@field Object REC_Library.Server.Class.Object.Object
        Object = {
            Object = require "@REC_Library.server.class.object.sv_object",
        },

        ---@class REC_Library.Server.API.Class.Ped
        ---@field Ped REC_Library.Server.Class.Ped.Ped
        Ped = {
            Ped = require "@REC_Library.server.class.ped.sv_ped",
        },

        ---@class REC_Library.Server.API.Class.Player
        ---@field Player REC_Library.Server.Class.Player.Player
        ---@field PlayerConfigBuilder REC_Library.Server.Class.Player.PlayerConfigBuilder
        Player = {
            Player = require "@REC_Library.server.class.player.sv_player",
            PlayerConfigBuilder = require "@REC_Library.server.class.player.sv_playerConfigBuilder",
        },

        ---@class REC_Library.Server.API.Class.Vehicle
        ---@field Vehicle REC_Library.Server.Class.Vehicle.Vehicle
        Vehicle = {
            Vehicle = require "@REC_Library.server.class.vehicle.sv_vehicle",

            ---@class REC_Library.Server.API.Class.Vehicle.Skylift
            ---@field Skylift REC_Library.Server.Class.Vehicle.Skylift.Skylift
            Skylift = {
                Skylift = require "@REC_Library.server.class.vehicle.skylift.sv_skylift",
            },
        },

        ---@class REC_Library.Server.API.Class.Staff
        ---@field Staff REC_Library.Server.Class.Staff.Staff
        ---@field StaffConfig REC_Library.Server.Class.Staff.StaffConfig
        Staff = {
            Staff = require "@REC_Library.server.class.staff.sv_staff",
            StaffConfig = require "@REC_Library.server.class.staff.sv_staffConfig",
        },

        ---@class REC_Library.Server.API.Class.Web
        ---@field WebAudit REC_Library.Server.Class.Web.WebAudit
        ---@field WebAuth REC_Library.Server.Class.Web.WebAuth
        ---@field WebConfig REC_Library.Server.Class.Web.WebConfig
        ---@field WebConfigStore REC_Library.Server.Class.Web.WebConfigStore
        ---@field WebSettingConfigBuilder REC_Library.Server.Class.Web.WebSettingConfigBuilder
        Web = {
            WebAudit = require "@REC_Library.server.class.web.sv_webAudit",
            WebAuth = require "@REC_Library.server.class.web.sv_webAuth",
            WebConfig = require "@REC_Library.server.class.web.sv_webConfig",
            WebConfigStore = require "@REC_Library.server.class.web.sv_webConfigStore",
            WebSettingConfigBuilder = require "@REC_Library.server.class.web.sv_webSettingConfigBuilder",
        },
    },
}

return api