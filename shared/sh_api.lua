 
---@class REC_Library.Shared.API
local api = {

    ---@class REC_Library.Shared.Class
    Class = {

        ---@class REC_Library.Shared.Class.Entity
        ---@field EntityProofsConfigBuilder REC_Library.Shared.Class.Entity.EntityProofsConfigBuilder
        Entity = {
            EntityProofsConfigBuilder = require "@REC_Library.shared.class.entity.sh_entityProofsConfigBuilder",
        },

        ---@class REC_Library.Shared.Class.Object
        ---@field ObjectConfigBuilder REC_Library.Shared.Class.Object.ObjectConfigBuilder
        ---@field DoorConfigBuilder REC_Library.Shared.Class.Object.DoorConfigBuilder
        Object = {
            ObjectConfigBuilder = require "@REC_Library.shared.class.object.sh_objectConfigBuilder",
            DoorConfigBuilder = require "@REC_Library.shared.class.object.sh_doorConfigBuilder",
        },

        ---@class REC_Library.Shared.Class.Ped
        ---@field PedConfigBuilder REC_Library.Shared.Class.Ped.PedConfigBuilder
        Ped = {
            PedConfigBuilder = require "@REC_Library.shared.class.ped.sh_pedConfigBuilder",
        },

        ---@class REC_Library.Shared.Class.Vehicle
        ---@field VehicleConfigBuilder REC_Library.Shared.Class.Vehicle.VehicleConfigBuilder
        Vehicle = {

            ---@class REC_Library.Shared.Class.Vehicle.Skylift
            ---@field SkyliftConfigBuilder REC_Library.Shared.Class.Vehicle.Skylift.SkyliftConfigBuilder
            Skylift = {
                SkyliftConfigBuilder = require "@REC_Library.shared.class.vehicle.skylift.sh_skyliftConfigBuilder",
            },

            VehicleConfigBuilder = require "@REC_Library.shared.class.vehicle.sh_vehicleConfigBuilder",
        },


        ---@class REC_Library.Shared.Class.Zone
        ---@field ZoneConfigBuilder REC_Library.Shared.Class.Zone.ZoneConfigBuilder
        ---@field BoxZoneConfigBuilder REC_Library.Shared.Class.Zone.BoxZoneConfigBuilder
        ---@field SphereZoneConfigBuilder REC_Library.Shared.Class.Zone.SphereZoneConfigBuilder
        ---@field PolyZoneConfigBuilder REC_Library.Shared.Class.Zone.PolyZoneConfigBuilder
        Zone = {
            ZoneConfigBuilder = require "@REC_Library.shared.class.zone.sh_zoneConfigBuilder",
            BoxConfigBuilder = require "@REC_Library.shared.class.zone.sh_boxZoneConfigBuilder",
            SphereZoneConfigBuilder = require "@REC_Library.shared.class.zone.sh_sphereZoneConfigBuidler",
            PolyZoneConfigBuilder = require "@REC_Library.shared.class.zone.sh_polyZoneConfigBuilder",
        },

        ---@class REC_Library.Shared.Class.Effect
        ---@field ParticleConfigBuilder REC_Library.Shared.Class.Effect.ParticleConfigBuilder
        ---@field SoundConfigBuilder REC_Library.Shared.Class.Effect.SoundConfigBuilder
        Effect = {
            ParticleConfigBuilder = require "@REC_Library.shared.class.effect.sh_particleConfigBuilder",
            SoundConfigBuilder = require "@REC_Library.shared.class.effect.sh_soundConfigBuilder",
        },

        ---@class REC_Library.Shared.Class.Web
        ---@field WebConfig REC_Library.Shared.Class.Web.WebConfig
        Web = {
            WebConfig = require "@REC_Library.shared.class.web.sh_webConfig",
        },
    },

    ---@type table<string, REC_Library.Shared.Animation>
    Animations = require "@REC_Library.shared.sh_animations",

    ---@class REC_Library.Shared.Enums
    Enums = require "@REC_Library.shared.sh_enums",

    ---@type REC_Library.Shared.Config
    Config = require "@REC_Library.shared.sh_config",

    ---@type REC_Library.Shared.Functions
    Functions = require "@REC_Library.shared.sh_functions",

    ---@type REC_Library.Shared.Validator
    Validator = require "@REC_Library.shared.sh_validator",
}

return api