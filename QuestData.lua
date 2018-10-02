local L = LibStub("AceLocale-3.0"):GetLocale("WorldBossStatus")


local maps = {	{	name	=	"BROKENISLES"	,		mapId	=	619	}	,
				{	name	=	"DALARAN"	,			mapId	=	627	}	,
				{	name	=	"AZSUNA"	,			mapId	=	630	}	,
				{	name	=	"STORMHEIM"	,			mapId	=	634	}	,
				{	name	=	"VALSHARAH"	,			mapId	=	641	}	,
				{	name	=	"HIGHMOUNTAIN"	,		mapId	=	650	}	,
				{	name	=	"SURAMAR"	,			mapId	=	680	}	,
				{	name	=	"EYEOFAZSHARA"	,		mapId	=	790	}	,
				{	name	=	"BROKENSHORE"	,		mapId	=	646	}	,
				{	name	=	"ARGUS"	,				mapId	=	905	}	,
				{	name	=	"ANTORANWASTES"	,		mapId	=	885	}	,
				{	name	=	"KROKUUN"	,			mapId	=	830	}	,
				{	name	=	"MACAREE"	,			mapId	=	882	}	,
				{	name	=	"DARKSHORE"	,			mapId	=	62	}	,
				{	name	=	"AZEROTH"	,			mapId	=	947	}	,
				{	name	=	"ZANDALAR"	,			mapId	=	875	}	,
				{	name	=	"VOLDUN"	,			mapId	=	864	}	,
				{	name	=	"NAZMIR"	,			mapId	=	863	}	,
				{	name	=	"ZULDAZAR"	,			mapId	=	862	}	,
				{	name	=	"KUL_TIRAS"	,			mapId	=	876	}	,
				{	name	=	"STORMSONG_VALLEY"	,	mapId	=	942	}	,
				{	name	=	"DRUSTVAR"	,			mapId	=	896	}	,
				{	name	=	"TIRAGARDE_SOUND"	,	mapId	=	895	}	,
				{	name	=	"TOL_DAGOR"	,			mapId	=	1169	}	}

				


function WorldBossStatus:FlagQuestBosses()
    
	  local bossData = WorldBossStatus.bossData

      for key, map in pairs(maps) do
			local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(map.mapId)


			if taskInfo then
				for i, info in ipairs(taskInfo) do
					for _, category in pairs(bossData) do
						for _, boss in pairs(category.bosses) do
							 if boss.questId and boss.questId == info.questId then
								 boss.active = true
							 end	 
						end
					end				
			    end
			end
		end

end



