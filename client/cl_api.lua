

---@class REC_Library.Client.API
local api = {

    ---@class REC_Library.Client.API.Class
    Class = {

        ---@class REC_Library.Client.API.Class._Core
        ---@field HeartBeat REC_Library.Client.Class._Core.Heartbeat
        ---@field HeartBeatConfigBuilder REC_Library.Client.Class._Core.HeartbeatConfigBuilder
        ---@field TickManager REC_Library.Client.Class._Core.TickManager
        ---@field TickManagerConfigBuilder REC_Library.Client.Class._Core.TickManagerConfigBuilder
        _Core = {
            HeartBeat = require "@REC_Library.client.class._core.cl_heartBeat",
            HeartBeatConfigBuilder = require "@REC_Library.client.class._core.cl_heartBeatConfigBuilder",
            TickManager = require "@REC_Library.client.class._core.cl_tickManager",
            TickManagerConfigBuilder = require "@REC_Library.client.class._core.cl_tickManagerConfigBuilder",
        },

        ---@class REC_Library.Client.API.Class.Handler
        ---@field HandlerBuilder REC_Library.Client.Class.Handler.HandlerBuilder
        Handler = {
            HandlerBuilder = require "@REC_Library.client.class.handler.cl_handlerBuilder",
        },

        ---@class REC_Library.Client.API.Class.Manager
        ---@field BlipManager REC_Library.Client.Class.Manager.BlipManager,
        ---@field BlipManagerConfigBuilder REC_Library.Client.Class.Manager.BlipManagerConfigBuilder
        ---@field EntityManager REC_Library.Client.Class.Manager.EntityManager
        ---@field EntityManagerConfigBuilder REC_Library.Client.Class.Manager.EntityManagerConfigBuilder
        ---@field SessionManager REC_Library.Client.Class.Manager.SessionManager
        ---@field SessionManagerConfigBuilder REC_Library.Client.Class.Manager.SessionManagerConfigBuilder
        ---@field ZoneManager REC_Library.Client.Class.Manager.ZoneManager
        ---@field ZoneManagerConfigBuilder REC_Library.Client.Class.Manager.ZoneManagerConfigBuilder
        Manager = {
            BlipManager = require "@REC_Library.client.class.manager.cl_blipManager",
            BlipManagerConfigBuilder = require "@REC_Library.client.class.manager.cl_blipManagerConfigBuilder",
            EntityManager = require "@REC_Library.client.class.manager.cl_entityManager",
            EntityManagerConfigBuilder = require "@REC_Library.client.class.manager.cl_entityManagerConfigBuilder",
            SessionManager = require "@REC_Library.client.class.manager.cl_sessionManager",
            SessionManagerConfigBuilder = require "@REC_Library.client.class.manager.cl_sessionManagerConfigBuilder",
            ZoneManager = require "@REC_Library.client.class.manager.cl_zoneManager",
            ZoneManagerConfigBuilder = require "@REC_Library.client.class.manager.cl_zoneManagerConfigBuilder",
        },

        ---@class REC_Library.Client.API.Class.Animation
        ---@field AnimationScene REC_Library.Client.Class.Animation.AnimationScene
        ---@field AnimationSceneConfigBuilder REC_Library.Client.Class.Animation.AnimationSceneConfigBuilder
        Animation = {

            Manager = {

                ---@type REC_Library.Client.Class.Animation.Manager.AnimationSceneManager
                AnimationSceneManager = require "@REC_Library.client.class.animation.manager.cl_animationSceneManager",

                ---@type REC_Library.Client.Class.Animation.Manager.AnimationSceneManagerConfigBuilder
                AnimationSceneManagerConfigBuilder = require "@REC_Library.client.class.animation.manager.cl_animationSceneManagerConfigBuilder",
            },

            ---@type REC_Library.Client.Class.Animation.AnimationScene
            AnimationScene = require "@REC_Library.client.class.animation.cl_animationScene",

            ---@type REC_Library.Client.Class.Animation.AnimationSceneConfigBuilder
            AnimationSceneConfigBuilder = require "@REC_Library.client.class.animation.cl_animationSceneConfigBuilder",
        },

        ---@class REC_Library.Client.API.Class.Blip
        ---@field Blip REC_Library.Client.Class.Blip.Blip
        ---@field BlipConfigBuilder REC_Library.Client.Class.Blip.BlipConfigBuilder
        Blip = {
            Blip = require "@REC_Library.client.class.blip.cl_blip",
            BlipConfigBuilder = require "@REC_Library.client.class.blip.cl_blipConfigBuilder",
        },

        ---@class REC_Library.Client.API.Class.Cutscene
        ---@field Cutscene REC_Library.Client.Class.Cutscene.Cutscene
        ---@field CutsceneConfigBuilder REC_Library.Client.Class.Cutscene.CutsceneConfigBuilder
        Cutscene = {
            Cutscene = require "@REC_Library.client.class.cutscene.cl_cutscene",
            CutsceneConfigBuilder = require "@REC_Library.client.class.cutscene.cl_cutsceneConfigBuilder",
        },

        ---@class REC_Library.Client.API.Class.Effect
        ---@field Particle REC_Library.Client.Class.Effect.Particle
        ---@field Sound REC_Library.Client.Class.Effect.Sound
        Effect = {
            Particle = require "@REC_Library.client.class.effect.cl_particle",
            Sound = require "@REC_Library.client.class.effect.cl_sound",
        },

        ---@class REC_Library.Client.API.Class.Marker
        ---@field Marker REC_Library.Client.Class.Marker.Marker
        ---@field MarkerConfigBuilder REC_Library.Client.Class.Marker.MarkerConfigBuilder
        Marker = {

            ---@class REC_Library.Client.API.Class.Marker.Managers
            ---@field StaticMarkerManager REC_Library.Client.Class.Marker.Managers.StaticMarkerManager
            ---@field DynamicMarkerManager REC_Library.Client.Class.Marker.Managers.DynamicMarkerManager
            Manager = {
                StaticMarkerManager = require "@REC_Library.client.class.marker.managers.cl_staticMarkerManager",
                DynamicMarkerManager = require "@REC_Library.client.class.marker.managers.cl_dynamicMarkerManager",
            },

            Marker = require "@REC_Library.client.class.marker.cl_marker",
            MarkerConfigBuilder = require "@REC_Library.client.class.marker.cl_markerConfigBuilder",
        },

        ---@class REC_Library.Client.API.Class.Object
        ---@field Object REC_Library.Client.Class.Object.Object
        ---@field Door REC_Library.Client.Class.Object.Door
        Object = {
            Object = require "@REC_Library.client.class.object.cl_object",
            Door = require "@REC_Library.client.class.object.cl_door",
        },

        ---@class REC_Library.Client.API.Class.Ped
        ---@field Ped REC_Library.Client.Class.Ped.Ped
        Ped = {

            ---@class REC_Library.Client.API.Class.Ped.Manager
            ---@field PedManager REC_Library.Client.Class.Ped.Manager.PedManager
            ---@field PedManagerConfigBuilder REC_Library.Client.Class.Ped.Manager.PedManagerConfigBuilder
            Manager = {
                PedManager = require "@REC_Library.client.class.ped.manager.cl_pedManager",
                PedManagerConfigBuilder = require "@REC_Library.client.class.ped.manager.cl_pedManagerConfigBuilder",
            },

            Ped = require "@REC_Library.client.class.ped.cl_ped",
            PedGroupController = require "@REC_Library.client.class.ped.cl_pedGroupController",
            PedGroupControllerBuilder = require "@REC_Library.client.class.ped.cl_pedGroupControllerConfigBuilder",
        },

        ---@class REC_Library.Client.API.Class.Target
        ---@field OxTargetConfigBuilder REC_Library.Client.Class.Target.OX.OXTargetConfigBuilder
        ---@field QbTargetConfigBuilder REC_Library.Client.Class.Target.QB.QBTargetConfigBuilder
        Target = {

            ---@class REC_Library.Client.API.Class.Target.Ox
            ---@field OxTargetConfigBuilder REC_Library.Client.Class.Target.OX.OXTargetConfigBuilder
            Ox = {
                OxTargetConfigBuilder = require "@REC_Library.client.class.target.ox.cl_oxTargetConfigBuilder",
            },

            ---@class REC_Library.Client.API.Class.Target.Qb
            ---@field QbTargetConfigBuilder REC_Library.Client.Class.Target.QB.QBTargetConfigBuilder
            Qb = {
                QbTargetConfigBuilder = require "@REC_Library.client.class.target.qb.cl_qbTargetConfigBuilder",
            },
        },

        ---@class REC_Library.Client.API.Class.UI
        ---@field HelpText REC_Library.Client.Class.UI.HelpText
        ---@field HelpTextConfigBuilder REC_Library.Client.Class.UI.HelpTextConfigBuilder
        ---@field Scaleform REC_Library.Client.Class.UI.Scaleform
        ---@field ScaleformConfigBuilder REC_Library.Client.Class.UI.ScaleformConfigBuilder
        ---@field Subtitle REC_Library.Client.Class.UI.Subtitle
        ---@field SubtitleConfigBuilder REC_Library.Client.Class.UI.SubtitleConfigBuilder
        UI = {

            -- ---@class REC_Library.Client.API.Class.UI.Managers
            -- ---@field HelpTextManager REC_Library.Client.Class.UI.Managers.HelpTextManager
            -- ---@field ScaleformManager ui.manager
            -- Managers = {
            --     HelpTextManager = require "@REC_Library.client.class.ui.managers.cl_helpTextManager",
            --     ScaleformManager = require "@REC_Library.client.class.ui.managers.cl_scaleformManager",
            -- },

            HelpText = require "@REC_Library.client.class.ui.cl_helpText",
            HelpTextConfigBuilder = require "@REC_Library.client.class.ui.cl_helpTextConfigBuilder",
            Scaleform = require "@REC_Library.client.class.ui.cl_scaleform",
            ScaleformConfigBuilder = require "@REC_Library.client.class.ui.cl_scaleformConfigBuilder",
            Subtitle = require "@REC_Library.client.class.ui.cl_subtitle",
            SubtitleConfigBuilder = require "@REC_Library.client.class.ui.cl_subtitleConfigBuilder",
        },

        ---@class REC_Library.Client.API.Class.Vehicle
        ---@field Vehicle REC_Library.Client.Class.Vehicle.Vehicle
        ---@field VhicleConfigBuilder REC_Library.Shared.Class.Vehicle.VehicleConfigBuilder
        Vehicle = {

            ---@class REC_Library.Client.API.Class.Vehicle.Skylift
            ---@field Skylift REC_Library.Client.Class.Vehicle.Skylift.Skylift
            Skylift = {
                Skylift = require "@REC_Library.client.class.vehicle.skylift.cl_skylift",
            },

            ---@class REC_Library.Client.API.Class.Vehicle.Train
            ---@field Train REC_Library.Client.Class.Vehicle.Train.Train
            Train = {
                Train = require "@REC_Library.client.class.vehicle.train.cl_train",
                TrainConfigBuilder = require "@REC_Library.client.class.vehicle.train.cl_trainConfigBuilder",
            },

            Vehicle = require "@REC_Library.client.class.vehicle.cl_vehicle",
            VehicleModsConfigBuilder = require "@REC_Library.client.class.vehicle.cl_vehicleModsConfigBuilder",
        },

        ---@class REC_Library.Client.API.Class.Zone
        ---@field Zone REC_Library.Client.Class.Zone.Zone
        Zone = {
            Zone = require "@REC_Library.client.class.zone.cl_zone",
        },

        ---@class REC_Library.Client.API.Class.Camera
        ---@field Camera REC_Library.Client.Class.Camera.Camera
        ---@field CameraConfigBuilder REC_Library.Client.Class.Camera.CameraConfigBuilder
        Camera = {

            ---@class REC_Library.Client.API.Class.Camera.Manager
            ---@field CameraManager REC_Library.Client.Class.Camera.CameraManager
            ---@field CameraManagerConfigBuilder REC_Library.Client.Class.Camera.CameraManagerConfigBuilder
            Manager = {
                CameraManager = require "@REC_Library.client.class.camera.cl_cameraManager",
                CameraManagerConfigBuilder = require "@REC_Library.client.class.camera.cl_cameraManagerConfigBuilder",
            },

            Camera = require "@REC_Library.client.class.camera.cl_camera",
            CameraConfigBuilder = require "@REC_Library.client.class.camera.cl_cameraConfigBuilder"
        },
    },

    ---@type REC_Library.Client.Functions
    Function = require "@REC_Library.client.cl_functions",
}

return api