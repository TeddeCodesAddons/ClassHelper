local ALL_NAMES={
    "C_ChatInfo.SendAddonMessage",
    "C_ChatInfo.RegisterAddonMessagePrefix",
    "GetScreenWidth",
    "GetScreenHeight",
    "GetSpellPowerCost",
    "UnitCastingInfo",
    "CombatLogGetCurrentEventInfo",
    "SendChatMessage",
    "IsInGroup",
    "IsInRaid",
    "IsInInstance",
    "PlaySound",
    "IsActiveBattlefieldArena",
    "IsInBattleground",
    "GetSpellCooldown",
    "GetSpellInfo",
    "GetGameTime",
    "GetLocalGameTime",
    "GetServerTime",
    "GetSessionTime",
    "GetTime",
    "GetTimePreciseSec",
    "RequestTimePlayed",
    "SecondsToTime",
    "SecondsToTimeAbbrev",
    "date",
    "time",
    "C_Timer.After",
    "C_Timer.NewTimer",
    "C_Timer.NewTicker",
    "RunScript",
    "addframetext",
    "debuglocals",
    "debugprofilestart",
    "debugprofilestop",
    "debugstack",
    "geterrorhandler",
    "seterrorhandler",
    "print",
    "getprinthandler",
    "setprinthandler",
    "message",
    "CreateFrame",
    "GetFontInfo",
    "GetFonts",
    "GetUnitSpeed",
    "UnitAffectingCombat",
    "UnitArmor",
    "UnitAttackPower",
    "UnitAttackSpeed",
    "UnitCanAssist",
    "UnitCanAttack",
    "UnitCanCooperate",
    "UnitCanPetBattle",
    "UnitCastingInfo",
    "UnitChannelInfo",
    "UnitClass",
    "UnitClassBase",
    "UnitClassification",
    "UnitCreatureFamily",
    "UnitCreatureType",
    "UnitDamage",
    "UnitDetailedThreatSituation",
    "UnitDistanceSquared",
    "UnitEffectiveLevel",
    "UnitExists",
    "UnitFactionGroup",
    "UnitFullName",
    "UnitGetAvailableRoles",
    "UnitGetIncomingHeals",
    "UnitGetTotalAbsorbs",
    "UnitGetTotalHealAbsorbs",
    "UnitGroupRolesAssigned",
    "UnitGUID",
    "UnitHPPerStamina",
    "UnitHasIncomingResurrection",
    "UnitHasLFGDeserter",
    "UnitHasLFGRandomCooldown",
    "UnitHasRelicSlot",
    "UnitHealth",
    "UnitHealthMax",
    "UnitInOtherParty",
    "UnitInPhase",
    "UnitIsInMyGuild",
    "UnitInRange",
    "UnitIsAFK",
    "UnitIsCharmed",
    "UnitIsConnected",
    "UnitIsControlling",
    "UnitIsCorpse",
    "UnitIsDead",
    "UnitIsDeadOrGhost",
    "UnitIsDND",
    "UnitIsEnemy",
    "UnitIsFeignDeath",
    "UnitIsFriend",
    "UnitIsGhost",
    "UnitIsGroupAssistant",
    "UnitIsOtherPlayersPet",
    "UnitIsOwnerOrControllerOfUnit",
    "UnitIsPlayer",
    "UnitIsPossessed",
    "UnitIsQuestBoss",
    "UnitIsRaidOfficer",
    "UnitIsSameServer",
    "UnitIsTapDenied",
    "UnitIsTrivial",
    "UnitIsUnconscious",
    "UnitIsUnit",
    "UnitIsVisible",
    "UnitLeadsAnyGroup",
    "UnitLevel",
    "UnitName",
    "UnitPlayerControlled",
    "UnitPlayerOrPetInParty",
    "UnitPlayerOrPetInRaid",
    "UnitPower",
    "UnitPowerDisplayMod",
    "UnitPowerMax",
    "UnitPowerType",
    "UnitRace",
    "UnitRangedAttackPower",
    "UnitRangedDamage",
    "UnitRealmRelationship",
    "UnitReaction",
    "UnitSelectionColor",
    "UnitSelectionType",
    "UnitSetRole",
    "UnitSex",
    "UnitShouldDisplayName",
    "UnitSpellHaste",
    "UnitStagger",
    "UnitStat",
    "UnitThreatPercentageOfLead",
    "UnitThreatSituation",
    "GetThreatStatusColor",
    "UnitTreatAsPlayerForDisplay",
    "UnitTrialXP",
    "UnitTrialBankedLevels",
    "UnitWeaponAttackPower",
    "UnitXP",
    "UnitXPMax",
    "GetUnitName",
    "CancelUnitBuff",
    "UnitAura",
    "UnitAuraBySlot",
    "UnitAuraSlots",
    "UnitBuff",
    "UnitDebuff",
    "strfind",
    "strsub",
    "strlen",
    "strlower",
    "strupper",
    "strsplit",
    "format",
    "gsub",
    "select",
    "unpack",
    "type",
    "next",
    "loadstring",
    "assert",
    "error",
    "math.abs",
    "math.ceil",
    "math.floor",
    "math.random",
    "tonumber",
    "tostring",
    "pairs",
    "sort",
    "ipairs",
    "tinsert",
    "tremove",
    "getn",
    "foreach",
    "foreachi"
}
function ClassHelper:GetAllInGameFunctionNames()
    return ALL_NAMES
end