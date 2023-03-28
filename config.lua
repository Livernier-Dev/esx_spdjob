--[[
 	resource: Xuan
	discord: https://discord.gg/9RpKaQN7JJ
	หากมีปัญหาทักมาสอบถามได้เลยครับ
--]]
Config                            = {}

Config.DrawDistance               = 100.0
Config.MarkerType                 = 1
Config.MarkerSize                 = { x = 1.0, y = 1.0, z = 0.5 }
Config.MarkerColor                = { r = 0, g = 0, b = 0 }

Config.EnablePlayerManagement     = true
Config.EnableArmoryManagement     = true
Config.EnableESXIdentity          = true -- enable if you're using esx_identity
Config.EnableNonFreemodePeds      = true -- turn this on if you want custom peds
Config.EnableLicenses             = true -- enable if you're using esx_license

Config.EnableHandcuffTimer        = true -- enable handcuff timer? will unrestrain player after the time ends
Config.HandcuffTimer              = 10 * 60000 -- 10 mins

Config.EnableJobBlip              = true -- enable blips for colleagues, requires esx_society

Config.MaxInService               = -1
Config.Locale                     = 'en'

Config.spdStations = {

	SPD = {

		Blip = {
			Coords  = vector3(372.16, 16.34, 91.94),
			Sprite  = 487,
			Display = 4,
			Scale   = 1.0,
			Colour  = 3
		},

		--Cloakrooms = {
		--	vector3(433.09, 9.47, 91.94)
		--},

		Armories = {
			vector3(451.7, -980.1, 30.6)
		},

		Vehicles = {
			{
				Spawner = vector3(363.47, -20.57, 82.99),
				InsideShop = vector3(351.04, -13.75, 100.62),
				SpawnPoints = {
					{ coords = vector3(366.38, -17.71, 82.58), heading = 38.22, radius = 6.0 },					
					{ coords = vector3(372.22, -13.28, 82.58), heading = 38.47, radius = 6.0 },
					{ coords = vector3(369.69, -15.17, 82.58), heading = 36.66, radius = 6.0 },
					{ coords = vector3(369.62, -15.42, 82.58), heading = 38.25, radius = 6.0 }
				}
			}
		},

		Helicopters = {
			{
				Spawner = vector3(351.26, -8.16, 91.27),
				InsideShop = vector3(291.72, 35.58, 100.41),
				SpawnPoints = {
					{ coords = vector3(360.28, 3.02, 91.26), heading = 91.26, radius = 10.0 }
				}
			}
		},

		BossActions = {
			vector3(433.09, 9.47, 91.94)
		},

		SearchInfoActions = {
			vector3(433.09, 9.47, 91.94)
		}

	},

}
--[[
Config.AuthorizedWeapons = {
	recruit = {
		{weapon = 'WEAPON_STUNGUN', price = 100},
		{weapon = 'WEAPON_NIGHTSTICK', price = 100},
		{weapon = 'WEAPON_PUMPSHOTGUN', price = 10000}
	},

	officer = {
		{weapon = 'WEAPON_STUNGUN', price = 100},
		{weapon = 'WEAPON_NIGHTSTICK', price = 100},
		{weapon = 'WEAPON_PUMPSHOTGUN', price = 10000}
	},

	sergeant = {
		{weapon = 'WEAPON_STUNGUN', price = 100},
		{weapon = 'WEAPON_NIGHTSTICK', price = 100},
		{weapon = 'WEAPON_PUMPSHOTGUN', price = 10000}
	},

	lieutenant = {
		{weapon = 'WEAPON_STUNGUN', price = 100},
		{weapon = 'WEAPON_NIGHTSTICK', price = 100},
		{weapon = 'WEAPON_PUMPSHOTGUN', price = 10000}
	},

	boss = {
		{weapon = 'WEAPON_STUNGUN', price = 100},
		{weapon = 'WEAPON_NIGHTSTICK', price = 100},
		{weapon = 'WEAPON_PUMPSHOTGUN', price = 10000}
	}
}
--]]
Config.AuthorizedVehicles = {
	Shared = {
			{model = 'gtr50',label = 'GTR', price = 5000},
			--{model = 'POLICE3', price = 10000},
			--{model = 'ghispo2', price = 10000},
			--{model = 'pol718', price = 10000},
			--{model = 'R1CUSTOM', price = 10000},
			--{model = 'nm_911police', price = 50000},
			--{model = 'nm_c8', price = 250000},

	},

	recruit = {
		    -- {model = 'ghispo2', price = 5000},

	},

	officer = {
		    -- {model = 'ghispo2', price = 5000},
	},

	sergeant = {
		    -- {model = 'ghispo2', price = 5000},
	},

	intendent = {
		    -- {model = 'ghispo2', price = 5000},

	},

	lieutenant = {
		    -- {model = 'ghispo2', price = 5000},
	},

	chef = {
		    -- {model = 'ghispo2', price = 5000},

	},

	boss = {
		    -- {model = 'fbi', price = 5000},

	}
}

Config.AuthorizedHelicopters = {
	recruit = {},

	officer = {},

	sergeant = {},

	intendent = {},

	lieutenant = {},

	chef = {},

	boss = {
		{model = 'swift', props = {modLivery = 0}, price = 100000},
		{model = 'volatus', props = {modLivery = 0}, price = 100000}
	}
}

-- CHECK SKINCHANGER CLIENT MAIN.LUA for matching elements
--[[]]
Config.UniformsList = { -- BY THANAWUT PROMRAUNG
	{
		title = 'นักเรียนตำรวจ',
		male = {
			['tshirt_1'] = 44,  ['tshirt_2'] = 0,   --เสื้อด้านใน   สีเสื้อด้านใน
			['torso_1'] = 318,   ['torso_2'] = 0,   --เสื้อนอก    สีเสื้อนอก
			['decals_1'] = 0,   ['decals_2'] = 0,	--สติ๊กเกอร์ 1 สติ๊กเกอร์ 2
			['arms'] = 11,							--แขน/ถุงมือ
			['pants_1'] = 24,   ['pants_2'] = 2,    --กางเกง  สีกางเกง
			['shoes_1'] = 97,   ['shoes_2'] = 0,  	--รองเท้า  สีรองเท้า
			--['helmet_1'] = -1,  ['helmet_2'] = 0,   --หมวก  สีหมวก
			--['chain_1'] = 128,    ['chain_2'] = 0,	--สร้อยคอ  ขนหน้าอก
			-- ['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 10,  ['bproof_2'] = 0   --เสื้อเกาะ  สีเสื้อเกาะ
			
			
			
			
	},
	
	    female = {
	    	['tshirt_1'] = 15,  ['tshirt_2'] = 0,   --เสื้อด้านใน   สีเสื้อด้านใน
			['torso_1'] = 103,   ['torso_2'] = 3,   --เสื้อนอก    สีเสื้อนอก
			['decals_1'] = 0,   ['decals_2'] = 0,	--สติ๊กเกอร์ 1 สติ๊กเกอร์ 2
			['arms'] = 7,							--แขน/ถุงมือ
			['pants_1'] = 77,   ['pants_2'] = 0,    --กางเกง  สีกางเกง
			['shoes_1'] = 73,   ['shoes_2'] = 1,  	--รองเท้า  สีรองเท้า
			['helmet_1'] = -1,  ['helmet_2'] = 0,   --หมวก  สีหมวก
			['chain_1'] = 98,    ['chain_2'] = 0,	--สร้อยคอ  ขนหน้าอก
			-- ['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0   --เสื้อเกาะ  สีเสื้อเกาะ
    	}
    },
	{
		title = 'ตำรวจ',
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1'] = 241,   ['torso_2'] = 1,
			--['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 0,
			['pants_1'] = 24,   ['pants_2'] = 5,
			--['shoes_1'] = 10,   ['shoes_2'] = 3,  	--รองเท้า  สีรองเท้า
			--['helmet_1'] = -1,  ['helmet_2'] = 0,
			--['chain_1'] = -1,    ['chain_2'] = 0,
			-- ['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 18,  ['bproof_2'] = 0
	},

	female = {
		    ['tshirt_1'] = 15,  ['tshirt_2'] = 0,   --เสื้อด้านใน   สีเสื้อด้านใน
			['torso_1'] = 103,   ['torso_2'] = 3,   --เสื้อนอก    สีเสื้อนอก
			['decals_1'] = 0,   ['decals_2'] = 0,	--สติ๊กเกอร์ 1 สติ๊กเกอร์ 2
			['arms'] = 7,							--แขน/ถุงมือ
			['pants_1'] = 77,   ['pants_2'] = 0,    --กางเกง  สีกางเกง
			['shoes_1'] = 73,   ['shoes_2'] = 1,  	--รองเท้า  สีรองเท้า
			['helmet_1'] = -1,  ['helmet_2'] = 0,   --หมวก  สีหมวก
			['chain_1'] = 98,    ['chain_2'] = 0,	--สร้อยคอ  ขนหน้าอก
			-- ['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0   --เสื้อเกาะ  สีเสื้อเกาะ
	}
},

--[[ 	{
		title = 'ผบตร',
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1'] = 63,   ['torso_2'] = 1,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 0,
			['pants_1'] = 16,   ['pants_2'] = 0,
			['shoes_1'] = 10,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0
	},

	female = {
		['tshirt_1'] = 15,  ['tshirt_2'] = 1,
		 ['torso_1'] = 344,   ['torso_2'] = 0,
		['decals_1'] = -1,   ['decals_2'] = 0,
		['arms'] = 7,
		['pants_1'] = 112,   ['pants_2'] = 4,
		['shoes_1'] = 10,   ['shoes_2'] = 3,
		['helmet_1'] = -1,  ['helmet_2'] = 0,
		['chain_1'] = -1,    ['chain_2'] = 0,
		['glasses_1'] = -1, 	['glasses_2']= 0,  --แว่นตา
		['ears_1'] = -1,     ['ears_2'] = 0
	}
}, ]]
--[[ 	{
		title = 'FIB 1',
		male = {
			['tshirt_1'] = 11,  ['tshirt_2'] = 0,
			['torso_1'] = 35,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 4,
			['pants_1'] = 50,   ['pants_2'] = 2,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 20,  ['bproof_2'] = 0
		}
	}, ]]
--[[ 	{
		title = 'FIB 2',
		male = {
			['tshirt_1'] = 11,  ['tshirt_2'] = 0,
			['torso_1'] = 36,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 4,
			['pants_1'] = 50,   ['pants_2'] = 2,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 20,  ['bproof_2'] = 0
		}
	}, ]]
--[[ 	{
		title = 'FIB จู่โจม',
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1'] = 94,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 0,
			['pants_1'] = 46,   ['pants_2'] = 1,
			['shoes_1'] = 24,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0
		}
	}, ]]
--[[ 	{
		title = 'Sheriff แขนสั้น',
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1'] = 118,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 0,
			['pants_1'] = 49,   ['pants_2'] = 0,
			['shoes_1'] = 51,   ['shoes_2'] = 3,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0
		}
	}, ]]
--[[ 	{
		title = 'Sheriff แขนยาว',
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1'] = 24,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 1,
			['pants_1'] = 49,   ['pants_2'] = 0,
			['shoes_1'] = 51,   ['shoes_2'] = 3,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0
		}
	}, ]]
--[[ 	{
		title = 'ตำรวจทางหลวง',
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1'] = 118,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 0,
			['pants_1'] = 32,   ['pants_2'] = 0,
			['shoes_1'] = 13,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0
		}
	}, ]]
--[[ 	{
		title = 'Cost Guard',
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1'] = 93,   ['torso_2'] = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms'] = 0,
			['pants_1'] = 49,   ['pants_2'] = 1,
			['shoes_1'] = 25,   ['shoes_2'] = 0,
			['helmet_1'] = -1,  ['helmet_2'] = 0,
			['chain_1'] = -1,    ['chain_2'] = 0,
			['ears_1'] = -1,     ['ears_2'] = 0,
			['bproof_1'] = 0,  ['bproof_2'] = 0
		}
	} 
}

Config.UniformsListMore = { -- BY THANAWUT PROMRAUNG 
	{
		title = 'สร้อยคอ',
		male = {
			['chain_1'] = 125,  
		},

		female = {
			['chain_1'] = 95,  
		}
	},
	{
		title = 'เสื้อเกาะ',
		male = {
			['bproof_1'] = 18,  	 ['bproof_2'] = 0   
		},

		female = {
			['bproof_1'] = 95,       ['bproof_2'] = 125  
		}
	},

	
--[[ 	{
		title = 'เข็มขัด & ป้าย (แทนที่เกราะ)',
		male = {
			['bproof_1'] = 19,  ['bproof_2'] = 0
		}
	},
--[[ 	{
		title = 'ป้าย ',
		male = {
			['bproof_1'] = 131,  ['bproof_2'] = 0
		}
	}, ]]
--[[ 	{
		title = 'ป้าย LSPD (แทนที่เกราะ)',
		male = {
			['bproof_1'] = 21,  ['bproof_2'] = 0
		}
	},
	{
		title = 'ป้าย FIB (แทนที่เกราะ)',
		male = {
			['bproof_1'] = 21,  ['bproof_2'] = 3
		}
	},
	{
		title = 'ซองปืนที่ขา',
		male = {
			['chain_1'] = 3,  ['chain_2'] = 0
		}
	},
	{
		title = 'ซองปืนที่เอว 1',
		male = {
			['chain_1'] = 2,  ['chain_2'] = 0
		}
	},
	{
		title = 'ซองปืนที่เอว 2',
		male = {
			['chain_1'] = 5,  ['chain_2'] = 0
		}
	}, ]]
	-- {
	-- 	title = 'หมวก Sheriff 1',
	-- 	male = {
	-- 		['helmet_1'] = 10,  ['helmet_2'] = 0
	-- 	}
	-- },
	-- {
	-- 	title = 'หมวก Sheriff 2',
	-- 	male = {
	-- 		['helmet_1'] = 10,  ['helmet_2'] = 7
	-- 	}
	-- },
	-- {
	-- 	title = 'หมวก LSPD สีดำ',
	-- 	male = {
	-- 		['helmet_1'] = 10,  ['helmet_2'] = 1
	-- 	}
	-- },
	-- {
	-- 	title = 'หมวก LSPD สีกรมท่า',
	-- 	male = {
	-- 		['helmet_1'] = 10,  ['helmet_2'] = 3
	-- 	}
	-- },
	-- {
	-- 	title = 'หมวก FIB',
	-- 	male = {
	-- 		['helmet_1'] = 10,  ['helmet_2'] = 4
	-- 	}
	-- }
}

Config.Uniforms = {
}