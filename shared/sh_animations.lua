
---@type table<string, REC_Library.Shared.Animation>
local animations = {
    ["plant_bomb_l"] = {
        model = "*",
        dict = "anim@scripted@player@mission@tun_bomb_plant@male@",
        scenes = {
            ["enter"] = {
                pedAnim = "enter",
                objAnim = "",
                propAnims = {
                    ["hei_p_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "enter_bag",
                    },
                    ["ch_prop_ch_ld_bomb_01a"] = {
                        -- dict = "",
                        name = "enter_bomb",
                    },
                },
            },
        },
        defaultScenesSequence = {
            [1] = "enter",
        },
        needCamera = false,
        needNetworked = false,
    },
    ["hack_laptop"] = {
        model = "xm_prop_x17_laptop_mrsr",
        dict = "anim@gangops@morgue@office@laptop@",
        scenes = {
            ["enter"] = {
                pedAnim = "enter",
                objAnim = "enter_laptop",
                propAnims = {
                    ["hei_prop_hst_usb_drive"] = {
                        -- dict = "",
                        name = "enter_usb",
                    },
                },
            },
            ["idle"] = {
                pedAnim = "idle",
                objAnim = "idle_laptop",
                propAnims = {
                    ["hei_prop_hst_usb_drive"] = {
                        -- dict = "",
                        name = "idle_usb",
                    },
                },
            },
            ["exit"] = {
                pedAnim = "exit",
                objAnim = "exit_laptop",
                propAnims = {
                    ["hei_prop_hst_usb_drive"] = {
                        -- dict = "",
                        name = "exit_usb",
                    },
                },
            },
        },
        defaultScenesSequence = {
            [1] = "enter",
            [2] = "idle",
            [3] = "exit",
        },
        needCamera = false,
        needNetworked = false,
    },
    -- ["plugin_drive"] = { -- Unusable due to multiple objects
    --     model = "tr_prop_tr_ser_storage_01a",
    --     dict = "anim@scripted@player@mission@tunf_bunk_ig2_hdd_nas@male@",
    --     scenes = {
    --         ["enter"] = {
    --             pedAnim = "enter",
    --             objAnim = "player_pluging_in_nas",
    --             propAnims = {
    --                 ["hei_p_m_bag_var22_arm_s"] = {
    --                     -- dict = "",
    --                     name = "player_pluging_in_bag",
    --                 },
    --                 ["prop_cs_server_drive"] = {
    --                     -- dict = "",
    --                     name = "enter_bomb",
    --                 },
    --             },
    --         },
    --     },
    --     defaultScenesSequence = {
    --         [1] = "enter",
    --         [2] = "idle",
    --         [3] = "simple",
    --         [4] = "exit",
    --     },
    --     needCamera = false,
    --     needNetworked = false,
    -- },
    ["grab_cash_trolly"] = {
        model = "hei_prop_hei_cash_trolly_01",
        dict = "anim@heists@ornate_bank@grab_cash",
        scenes = {
            ["enter"] = {
                pedAnim = "intro",
                objAnim = "",
                propAnims = {
                    ["hei_p_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "bag_intro",
                    },
                },
            },
            -- ["idle"] = {
            --     pedAnim = "grab_idle",
            --     objAnim = "",
            --     propAnims = {
            --         ["hei_p_m_bag_var22_arm_s"] = {
            --             -- dict = "",
            --             name = "bag_grab_idle",
            --         },
            --     },
            -- },
            ["simple"] = {
                pedAnim = "grab",
                objAnim = "cart_cash_dissapear",
                propAnims = {
                    ["hei_p_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "bag_grab",
                    },
                    ["hei_prop_heist_cash_pile"] = {
                        dict = "anim@heists@ornate_bank@cash_trolley",
                        name = "grab_cash_trolley",
                    },
                },
                phaseEvents = {
                    0.022660873830318,
                    0.043917909264565,
                    0.062120895832777,
                    0.085019364953041,
                    0.10222642868757,
                    0.12069732695818,
                    0.13790367543697,
                    0.15724964439869,
                    0.17990316450596,
                    0.20153354108334,
                    0.22353671491146,
                    0.24947494268417,
                    0.27047136425972,
                    0.28982728719711,
                    0.31550496816635,
                    0.34132051467896,
                    0.36459398269653,
                    0.38558954000473,
                    0.40582743287086,
                    0.42606630921364,
                    0.45504236221313,
                    0.4774269759655,
                    0.49969118833542,
                    0.52384960651398,
                    0.54232239723206,
                    0.56547111272812,
                    0.5846945643425,
                    0.61126297712326,
                    0.63454711437225,
                    0.65579921007156,
                    0.67692571878433,
                    0.69677990674973,
                    0.71943002939224,
                    0.73954010009766,
                    0.76003259420395,
                    0.78255033493042,
                    0.81164157390594,
                    0.83087033033371,
                    0.85288548469543,
                    0.88564622402191,
                    0.91498774290085,
                    0.93383395671844,
                    0.9553399682045,
                    0.97431719303131,
                    0.98431719303131,
                },
            },
            ["exit"] = {
                pedAnim = "exit",
                objAnim = "",
                propAnims = {
                    ["hei_p_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "bag_exit_no_armour",
                    },
                },
            },
        },
        defaultScenesSequence = {
            [1] = "enter",
            -- [2] = "idle",
            [2] = "simple",
            [3] = "exit",
        },
        needCamera = false,
        needNetworked = true,
    },
    ["grab_cash_stack"] = {
        model = "rec_prop_cash_stack_01a",
        dict = "anim@scripted@heist@ig1_table_grab@cash@male@",
        scenes = {
            ["enter"] = {
                pedAnim = "enter",
                objAnim = "",
                propAnims = {
                    ["h4_p_h4_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "enter_bag",
                    },
                },
            },
            ["idle"] = {
                pedAnim = "grab_idle",
                objAnim = "",
                propAnims = {
                    ["h4_p_h4_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "grab_idle_bag",
                    },
                },
            },
            ["simple"] = {
                pedAnim = "grab",
                objAnim = "grab_cash",
                propAnims = {
                    ["h4_p_h4_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "grab_bag",
                    },
                },
                phaseEvents = {
                    0.054654441773891,
                    0.081956446170807,
                    0.16569481790066,
                    0.28463765978813,
                    0.34987613558769,
                    0.39130538702011,
                    0.44944095611572,
                    0.54098695516586,
                    0.5595024228096,
                    0.62658679485321,
                    0.64062738418579,
                    0.65652877092361,
                    0.74810791015625,
                    0.77807235717773,
                    0.8626816868782,
                    0.87588161230087,
                    0.88732248544693,
                    0.89873671531677,
                    0.95083159208298,
                    0.98083159208298,
                },
            },
            ["exit"] = {
                pedAnim = "exit",
                objAnim = "",
                propAnims = {
                    ["h4_p_h4_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "exit_bag",
                    },
                },
            },
        },
        defaultScenesSequence = {
            [1] = "enter",
            -- [2] = "idle",
            [2] = "simple",
            [3] = "exit",
        },
        needCamera = true,
        needNetworked = true,
    },
    ["grab_gold_stack"] = {
        model = "rec_prop_rec_gold_stack_01a",
        dict = "anim@scripted@heist@ig1_table_grab@gold@male@",
        scenes = {
            ["enter"] = {
                pedAnim = "enter",
                objAnim = "",
                propAnims = {
                    ["h4_p_h4_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "enter_bag",
                    },
                },
            },
            ["idle"] = {
                pedAnim = "grab_idle",
                objAnim = "",
                propAnims = {
                    ["h4_p_h4_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "grab_idle_bag",
                    },
                },
            },
            ["simple"] = {
                pedAnim = "grab",
                objAnim = "grab_gold",
                propAnims = {
                    ["h4_p_h4_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "grab_bag",
                    },
                },
                phaseEvents = {
                    0.10810603201389,
                    0.19564913213253,
                    0.21111688017845,
                    0.30064368247986,
                    0.40223750472069,
                    0.43473157286644,
                    0.53403747081757,
                    0.61619526147842,
                    0.63975185155869,
                    0.77370029687881,
                    0.79921221733093,
                    0.93679612874985,
                },
            },
            ["exit"] = {
                pedAnim = "exit",
                objAnim = "",
                propAnims = {
                    ["h4_p_h4_m_bag_var22_arm_s"] = {
                        -- dict = "",
                        name = "exit_bag",
                    },
                },
            },
        },
        defaultScenesSequence = {
            [1] = "enter",
            -- [2] = "idle",
            [2] = "simple",
            [3] = "exit",
        },
        needCamera = true,
        needNetworked = true,
    },
    ["ceo_chair"] = {
        model = "ex_prop_offchair_exec_03",
        dict = "anim@amb@office@boss@male@",
        scenes = {
            ["enter"] = {
                pedAnim = "enter",
                objAnim = "enter_chair",
                propAnims = {},
            },
            ["simple"] = {
                pedAnim = "idle_a",
                objAnim = "idle_a_chair",
                propAnims = {},
            },
            ["exit"] = {
                pedAnim = "exit",
                objAnim = "exit_chair",
                propAnims = {},
            },
        },
        defaultScenesSequence = {
            [1] = "enter",
            [2] = "simple",
            [3] = "exit",
        },
        needCamera = false,
        needNetworked = true,
    },
}

return animations

---@class REC_Library.Shared.Animation
---@field model string
---@field dict string
---@field flag? integer
---@field scenes table<string|REC_Library.Shared.Enums.AnimationSceneTypes, REC_Library.Shared.Animation.Scene>
---@field defaultScenesSequence table<integer, string>
---@field needCamera boolean
---@field needNetworked boolean

---@class REC_Library.Shared.Animation.Scene
---@field pedAnim string
---@field objAnim string
---@field propAnims table<string, REC_Library.Shared.Animation.Scene.PropAnim>
---@field camAnim? string|false
---@field flag? integer
---@field phaseEvents? number[]

---@class REC_Library.Shared.Animation.Scene.PropAnim
---@field dict? string
---@field name string
---@
