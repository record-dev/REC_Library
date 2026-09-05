
---@class REC_Library.Shared.Enums
local enums = {}

---@enum REC_Library.Shared.Enums.Languages
enums.Languages = {
    en = "en",
    ja = "ja",
    custom = "custom",
}

---@enum REC_Library.Shared.Enums.Theme
enums.Themes = {
    rec = "rec",
    ox = "ox",
}

---@enum REC_Library.Shared.Enums.Framework
enums.FrameworkTypes = {
    ox = "ox",
    qbx = "qbx",
    esx = "esx",
    qb = "qb",
    rec = "rec",
    custom = "custom",
}

---@enum REC_Library.Shared.Enums.Bank
enums.BankTypes = {
    esx = "esx",
    qb = "qb",
    okok = "okok",
    renewed = "renewed",
    tgg = "tgg",
    custom = "custom",
}

---@enum REC_Library.Shared.Enums.Inventory
enums.InventoryTypes = {
    ox = "ox",
    qb = "qb",
    custom = "custom",
}

---@enum REC_Library.Shared.Enums.Target
enums.TargetTypes = {
    ox = "ox",
    qb = "qb",
    custom = "custom",
}

---@enum REC_Library.Shared.Enums.ZoneType
enums.ZoneType = {
    PolyZone = "PolyZone",
    BoxZone = "BoxZone",
    SphereZone = "SphereZone",
}

---@enum REC_Library.Shared.Enums.Doors
enums.DoorTypes = {
    qb = "qb",
    ox = "ox",
    custom = "custom",
}

---@enum REC_Library.Shared.Enums.Medicals
enums.MedicalTypes = {
    qb = "qb",
    qbx = "qbx",
    wsb_v1 = "wsb_v1",
    wsb_v2 = "wsb_v2",
    custom = "custom",
}

---@enum REC_Library.Shared.Enums.Vehiclekeys
enums.VehiclekeysTypes = {
    qb = "qb",
    qbx = "qbx",
    wsb = "wsb",
    custom = "custom",
}

---@enum REC_Library.Shared.Enums.Vehiclefuel
enums.VehiclefuelTypes = {
    ox = "ox",
    qb = "qb",
    cdn = "cdn",
    lc = "lc",
    custom = "custom",
}

---@enum REC_Library.Shared.Enums.Dispatch
enums.DispatchTypes = {
    lb = "lb-tablet",
    ps = "ps-dispatch",
    custom = "custom",
}

---@enum REC_Library.Shared.Enums.Notify
enums.NotifyTypes = {
    rec = "rec",
    ox = "ox",
    okok = "okok",
    custom = "custom",
}

enums.TargetType = {}

---@enum REC_Library.Shared.Enums.TargetType.QB
enums.TargetType.QB = {
    Client = "client",
    Server = "server",
}

---@enum REC_Library.Shared.Enums.EntityType
enums.EntityType = {
    object = "object",
    npc = "npc",
    vehicle = "vehicle",
}

---@enum REC_Library.Shared.Enums.PedType
enums.PedType = {
    Normal = "normal",
    Guard = "guard",
    Police = "police",
}

---@enum REC_Library.Shared.Enums.EntitySyncType
enums.EntitySyncType = {
    client = "client",
    server = "server",
}

---@enum REC_Library.Shared.Enums.AnimationSceneTypes
enums.AnimationSceneTypes = {
    simple = "simple",
    enter = "enter",
    idle = "idle",
    exit = "exit",
}

---@enum REC_Library.Shared.Enums.ZoneEventType
enums.ZoneEventType = {
    enter = "enter",
    exit = "exit",
}

---@enum REC_Library.Shared.Enums.ZoneHistoryEventType
enums.ZoneHistoryEventType = {
    enter = "enter",
    exit = "exit",
}

---@enum REC_Library.Shared.Enums.CameraType
enums.cameraType = {
    static = "static",
    dynamic = "dynamic",
}

---@enum REC_Library.Shared.Enums.CameraName
enums.cameraName = {
    DEFAULT_SCRIPTED_CAMERA = "DEFAULT_SCRIPTED_CAMERA",
    DEFAULT_ANIMATED_CAMERA = "DEFAULT_ANIMATED_CAMERA",
    DEFAULT_SPLINE_CAMERA = "DEFAULT_SPLINE_CAMERA",
    DEFAULT_SCRIPTED_FLY_CAMERA = "DEFAULT_SCRIPTED_FLY_CAMERA",
    TIMED_SPLINE_CAMERA = "TIMED_SPLINE_CAMERA",
    CUSTOM_TIMED_SPLINE_CAMERA = "CUSTOM_TIMED_SPLINE_CAMERA",
    ROUNDED_SPLINE_CAMERA = "ROUNDED_SPLINE_CAMERA",
    SMOOTHED_SPLINE_CAMERA = "SMOOTHED_SPLINE_CAMERA",
}

---@enum REC_Library.Shared.Enums.CameraShake
enums.cameraShake = {
    ASSAULT_RIFLE_RECOIL_SHAKE = "ASSAULT_RIFLE_RECOIL_SHAKE",
    BOAT_WATER_ENTRY_SHAKE = "BOAT_WATER_ENTRY_SHAKE",
    CAMERA_OPERATOR_SHAKE_X = "CAMERA_OPERATOR_SHAKE_X",
    CAMERA_OPERATOR_SHAKE_Z = "CAMERA_OPERATOR_SHAKE_Z",
    CAMERA_OPERATOR_TURBULENCE_SHAKE = "CAMERA_OPERATOR_TURBULENCE_SHAKE",
    CARBINE_RIFLE_ACCURACY_OFFSET_SHAKE = "CARBINE_RIFLE_ACCURACY_OFFSET_SHAKE",
    CARBINE_RIFLE_RECOIL_SHAKE = "CARBINE_RIFLE_RECOIL_SHAKE",
    CINEMATIC_SHOOTING_RUN_SHAKE = "CINEMATIC_SHOOTING_RUN_SHAKE",
    DAMPED_HAND_SHAKE = "DAMPED_HAND_SHAKE",
    DEATH_FAIL_IN_EFFECT_SHAKE = "DEATH_FAIL_IN_EFFECT_SHAKE",
    DEATH_FAIL_OUT_EFFECT_SHAKE = "DEATH_FAIL_OUT_EFFECT_SHAKE",
    DEFAULT_DEPLOY_PARACHUTE_SHAKE = "DEFAULT_DEPLOY_PARACHUTE_SHAKE",
    DEFAULT_FIRST_PERSON_RECOIL_SHAKE = "DEFAULT_FIRST_PERSON_RECOIL_SHAKE",
    DEFAULT_KILL_EFFECT_SHAKE = "DEFAULT_KILL_EFFECT_SHAKE",
    DEFAULT_THIRD_PERSON_ACCURACY_OFFSET_SHAKE = "DEFAULT_THIRD_PERSON_ACCURACY_OFFSET_SHAKE",
    DEFAULT_THIRD_PERSON_RECOIL_SHAKE = "DEFAULT_THIRD_PERSON_RECOIL_SHAKE",
    DRUNK_SHAKE = "DRUNK_SHAKE",
    FAMILY5_DRUG_TRIP_SHAKE = "FAMILY5_DRUG_TRIP_SHAKE",
    FIRST_PERSON_AIM_SHAKE = "FIRST_PERSON_AIM_SHAKE",
    FIRST_PERSON_DEPLOY_PARACHUTE_SHAKE = "FIRST_PERSON_DEPLOY_PARACHUTE_SHAKE",
    FOLLOW_RUN_SHAKE = "FOLLOW_RUN_SHAKE",
    FOLLOW_SWIM_SHAKE = "FOLLOW_SWIM_SHAKE",
    FPS_ASSAULT_RIFLE_RECOIL_SHAKE = "FPS_ASSAULT_RIFLE_RECOIL_SHAKE",
    FPS_BOLT_RELOAD_SHAKE = "FPS_BOLT_RELOAD_SHAKE",
    FPS_BULLET_HIT_SHAKE = "FPS_BULLET_HIT_SHAKE",
    FPS_DEATH_SHAKE = "FPS_DEATH_SHAKE",
    FPS_GRENADE_LAUNCHER_RECOIL_SHAKE = "FPS_GRENADE_LAUNCHER_RECOIL_SHAKE",
    FPS_MAG_DROP_SHAKE = "FPS_MAG_DROP_SHAKE",
    FPS_MAG_RELOAD_SHAKE = "FPS_MAG_RELOAD_SHAKE",
    FPS_MELEE_HIT_SHAKE = "FPS_MELEE_HIT_SHAKE",
    FPS_MG_RECOIL_SHAKE = "FPS_MG_RECOIL_SHAKE",
    FPS_MINIGUN_RECOIL_SHAKE = "FPS_MINIGUN_RECOIL_SHAKE",
    FPS_PISTOL_RECOIL_SHAKE = "FPS_PISTOL_RECOIL_SHAKE",
    FPS_RPG_RECOIL_SHAKE = "FPS_RPG_RECOIL_SHAKE",
    FPS_SHOTGUN_PUMP_SHAKE = "FPS_SHOTGUN_PUMP_SHAKE",
    FPS_SHOTGUN_RECOIL_SHAKE = "FPS_SHOTGUN_RECOIL_SHAKE",
    FPS_SMG_RECOIL_SHAKE = "FPS_SMG_RECOIL_SHAKE",
    FPS_STEERING_WHEEL_HIT_SHAKE = "FPS_STEERING_WHEEL_HIT_SHAKE",
    FPS_TANK_RECOIL_SHAKE = "FPS_TANK_RECOIL_SHAKE",
    FPS_THROW_SHAKE = "FPS_THROW_SHAKE",
    FPS_VEHICLE_HIT_SHAKE = "FPS_VEHICLE_HIT_SHAKE",
    FPS_ZOOM_IN_SHAKE = "FPS_ZOOM_IN_SHAKE",
    GAMEPLAY_EXPLOSION_SHAKE = "GAMEPLAY_EXPLOSION_SHAKE",
    GRENADE_EXPLOSION_SHAKE = "GRENADE_EXPLOSION_SHAKE",
    GRENADE_LAUNCHER_RECOIL_SHAKE = "GRENADE_LAUNCHER_RECOIL_SHAKE",
    HAND_SHAKE = "HAND_SHAKE",
    HAND_SHAKE_ROLL = "HAND_SHAKE_ROLL",
    HIGH_DIVE_SHAKE = "HIGH_DIVE_SHAKE",
    HIGH_FALL_SHAKE = "HIGH_FALL_SHAKE",
    HIGH_SPEED_BOAT_SHAKE = "HIGH_SPEED_BOAT_SHAKE",
    HIGH_SPEED_POV_SHAKE = "HIGH_SPEED_POV_SHAKE",
    HIGH_SPEED_VEHICLE_SHAKE = "HIGH_SPEED_VEHICLE_SHAKE",
    HIGH_SPEED_VIBRATION_POV_SHAKE = "HIGH_SPEED_VIBRATION_POV_SHAKE",
    IDLE_HAND_SHAKE = "IDLE_HAND_SHAKE",
    JOLT_SHAKE = "JOLT_SHAKE",
    KILL_SHOT_SHAKE = "KILL_SHOT_SHAKE",
    LARGE_EXPLOSION_SHAKE = "LARGE_EXPLOSION_SHAKE",
    LOW_ORBIT_HIGH_SPEED_CAMERA_SHAKE = "LOW_ORBIT_HIGH_SPEED_CAMERA_SHAKE",
    LOW_ORBIT_INACCURACY_CAMERA_SHAKE = "LOW_ORBIT_INACCURACY_CAMERA_SHAKE",
    MEDIUM_EXPLOSION_SHAKE = "MEDIUM_EXPLOSION_SHAKE",
    MG_RECOIL_SHAKE = "MG_RECOIL_SHAKE",
    MINIGUN_RECOIL_SHAKE = "MINIGUN_RECOIL_SHAKE",
    PARACHUTING_SHAKE = "PARACHUTING_SHAKE",
    PISTOL_RECOIL_SHAKE = "PISTOL_RECOIL_SHAKE",
    PLANE_PART_SPEED_SHAKE = "PLANE_PART_SPEED_SHAKE",
    POV_IDLE_SHAKE = "POV_IDLE_SHAKE",
    REPLAY_DRUNK_SHAKE = "REPLAY_DRUNK_SHAKE",
    REPLAY_EXPLOSION_SHAKE = "REPLAY_EXPLOSION_SHAKE",
    REPLAY_HAND_SHAKE = "REPLAY_HAND_SHAKE",
    REPLAY_HIGH_SPEED_VEHICLE_SHAKE = "REPLAY_HIGH_SPEED_VEHICLE_SHAKE",
    REPLAY_SKY_DIVING_SHAKE = "REPLAY_SKY_DIVING_SHAKE",
    ROAD_VIBRATION_SHAKE = "ROAD_VIBRATION_SHAKE",
    RPG_RECOIL_SHAKE = "RPG_RECOIL_SHAKE",
    SHOTGUN_RECOIL_SHAKE = "SHOTGUN_RECOIL_SHAKE",
    SKY_DIVING_SHAKE = "SKY_DIVING_SHAKE",
    SMALL_EXPLOSION_SHAKE = "SMALL_EXPLOSION_SHAKE",
    SMG_RECOIL_SHAKE = "SMG_RECOIL_SHAKE",
    STUNT_HAND_SHAKE = "STUNT_HAND_SHAKE",
    SWITCH_HAND_SHAKE = "SWITCH_HAND_SHAKE",
    TANK_RECOIL_SHAKE = "TANK_RECOIL_SHAKE",
    VEH_IMPACT_HEADING_SHAKE = "VEH_IMPACT_HEADING_SHAKE",
    VEH_IMPACT_PITCH_HEADING_SHAKE_FPS = "VEH_IMPACT_PITCH_HEADING_SHAKE_FPS",
    VEH_IMPACT_PITCH_SHAKE = "VEH_IMPACT_PITCH_SHAKE",
    VIBRATE_SHAKE = "VIBRATE_SHAKE",
    WATER_BOB_SHAKE = "WATER_BOB_SHAKE",
    WOBBLY_SHAKE = "WOBBLY_SHAKE"
}

return enums

---@alias REC_Library.Shared.3DCoords { x: number, y: number, z: number }

---@alias REC_Library.Shared.RGBA { r: number, g: number, b: number, a: number }

---@class REC_Library.Shared.Zone.Self
---@field coords vector3
---@field onExit fun()
---@field insideZone boolean
---@field onEnter fun()
---@field distance number
---@field width number
---@field radius number
---@field debugColour REC_Library.Shared.RGBA
---@field __type string
---@field setDebug fun()
---@field length number
---@field remove fun()
---@field id number
---@field inside fun()
---@field debug fun()
---@field contains fun(self: REC_Library.Shared.Zone.Self, coords: vector3): boolean
---@field remove fun()