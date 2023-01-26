
GreeceMainAttackPaths = {
	{ SouthAttackRally.Location, SouthAttack1.Location },
	{ EastAttackRally.Location, EastAttack1.Location, EastAttack2.Location, EastAttack3a.Location },
	{ EastAttackRally.Location, EastAttack1.Location, EastAttack2.Location, EastAttack3b.Location },
}

CruiserPatrolPath = { CruiserPatrol1.Location, CruiserPatrol2.Location, CruiserPatrol3.Location, CruiserPatrol4.Location, CruiserPatrol5.Location, CruiserPatrol6.Location, CruiserPatrol7.Location, CruiserPatrol8.Location, CruiserPatrol7.Location, CruiserPatrol6.Location, CruiserPatrol5.Location, CruiserPatrol4.Location, CruiserPatrol3.Location, CruiserPatrol2.Location }

TraitorUnits = {
	easy = {
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1" }, Vehicles = { "btr" }, MaxTime = DateTime.Minutes(14) },
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1", "shok" }, Vehicles = { "btr", "katy" }, MinTime = DateTime.Minutes(14) },
	},
	normal = {
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1" }, Vehicles = { "3tnk" }, MaxTime = DateTime.Minutes(12) },
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1", "shok" }, Vehicles = { "3tnk", "katy" }, MinTime = DateTime.Minutes(12) },
	},
	hard = {
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1" }, Vehicles = { "3tnk", "btr" }, MaxTime = DateTime.Minutes(10) },
		{ Infantry = { "e3", "e1", "e1", "e1", "e3", "e1", "shok" }, Vehicles = { "3tnk", "v2rl", "ttra" }, MinTime = DateTime.Minutes(10) },
	},
}

ReinforcementsDelay = {
	easy = DateTime.Minutes(10),
	normal = DateTime.Minutes(12),
	hard = DateTime.Minutes(14),
}

Squads = {
	Main = {
		Player = nil,
		Delay = {
			easy = DateTime.Minutes(4),
			normal = DateTime.Minutes(3),
			hard = DateTime.Minutes(2)
		},
		AttackValuePerSecond = {
			easy = { { MinTime = 0, Value = 20 }, { MinTime = DateTime.Minutes(15), Value = 40 } },
			normal = { { MinTime = 0, Value = 34 }, { MinTime = DateTime.Minutes(13), Value = 68 } },
			hard = { { MinTime = 0, Value = 52 }, { MinTime = DateTime.Minutes(11), Value = 105 } },
		},
		QueueProductionStatuses = { Infantry = false, Vehicles = false },
		FollowLeader = true,
		IdleUnits = { },
		ProducerActors = { Infantry = { AlliedSouthBarracks }, Vehicles = { AlliedSouthFactory } },
		Units = UnitCompositions.Allied.Main,
		AttackPaths = GreeceMainAttackPaths,
	},
	Traitor = {
		Player = nil,
		Delay = {
			easy = DateTime.Minutes(5),
			normal = DateTime.Minutes(4),
			hard = DateTime.Minutes(3)
		},
		AttackValuePerSecond = {
			easy = { { MinTime = 0, Value = 10 }, { MinTime = DateTime.Minutes(15), Value = 20 } },
			normal = { { MinTime = 0, Value = 16 }, { MinTime = DateTime.Minutes(13), Value = 32 } },
			hard = { { MinTime = 0, Value = 28 }, { MinTime = DateTime.Minutes(11), Value = 55 } },
		},
		QueueProductionStatuses = { Infantry = false, Vehicles = false },
		FollowLeader = true,
		IdleUnits = { },
		ProducerActors = { Infantry = { TraitorBarracks }, Vehicles = { TraitorFactory } },
		Units = TraitorUnits,
		AttackPaths = GreeceMainAttackPaths,
	},
	Air = {
		Player = nil,
		Delay = {
			easy = DateTime.Minutes(13),
			normal = DateTime.Minutes(12),
			hard = DateTime.Minutes(11)
		},
		Interval = {
			easy = DateTime.Minutes(3),
			normal = DateTime.Seconds(150),
			hard = DateTime.Minutes(2)
		},
		QueueProductionStatuses = {
			Aircraft = false
		},
		IdleUnits = { },
		ProducerActors = nil,
		ProducerTypes = { Aircraft = { "hpad" } },
		Units = {
			easy = {
				{ Aircraft = { "heli" } }
			},
			normal = {
				{ Aircraft = { "heli", "heli" } },
				{ Aircraft = { "harr" } }
			},
			hard = {
				{ Aircraft = { "heli", "heli", "heli" } },
				{ Aircraft = { "harr", "harr" } }
			}
		},
	}
}

WorldLoaded = function()
	USSR = Player.GetPlayer("USSR")
    Greece = Player.GetPlayer("Greece")
	Traitor = Player.GetPlayer("Traitor")
	USSRAbandoned = Player.GetPlayer("USSRAbandoned")
	MissionPlayer = USSR
	TimerTicks = 0

	Camera.Position = PlayerStart.CenterPosition

	InitObjectives(USSR)
	InitGreece()

	ObjectiveKillTraitor = USSR.AddObjective("Find and kill the traitor General Yegorov.")
	ObjectiveFindSovietBase = USSR.AddSecondaryObjective("Take control of abandoned Soviet base.")

	AbandonedHalo.ReturnToBase(AbandonedHelipad)

	if Difficulty == "hard" then
		Cruiser.Patrol(CruiserPatrolPath)
		AbandonedAirfield.Destroy()
		--local traitorConyardLocation = TraitorConyard.Location
		--TraitorConyard.Destroy()
		--Actor.Create("weap", true, { Owner = Traitor, Location = traitorConyardLocation })
	else
		Cruiser.Destroy()
		HardOnlyMGG.Destroy()
		HardOnlyTurret1.Destroy()
		HardOnlyTurret2.Destroy()
		HardOnlyTurret3.Destroy()
		HardOnlyTurret4.Destroy()
		HardOnlyTurret5.Destroy()
		HardOnlyGapGenerator.Destroy()
		HardOnlyTeslaCoil.Destroy()
		HardOnlyCryoLauncher.Destroy()
	end

	Trigger.OnCapture(AbandonedHelipad, function(self, captor, oldOwner, newOwner)
		if newOwner == USSR then
			AbandonedHalo.Owner = USSR
		end
	end)

	Trigger.OnEnteredProximityTrigger(GuardsReveal1.CenterPosition, WDist.New(11 * 1024), function(a, id)
		if a.Owner == USSR and not a.HasProperty("Land") then
			Trigger.RemoveProximityTrigger(id)
			local camera = Actor.Create("smallcamera", true, { Owner = USSR, Location = GuardsReveal1.Location })
			Trigger.AfterDelay(DateTime.Seconds(5), function()
				camera.Destroy()
			end)
		end
	end)

	Trigger.OnEnteredProximityTrigger(AbandonedBaseCenter.CenterPosition, WDist.New(10 * 1024), function(a, id)
		if a.Owner == USSR and not a.HasProperty("Land") then
			Trigger.RemoveProximityTrigger(id)
			AbandonedBaseDiscovered()
		end
	end)

	Trigger.OnKilled(Bodyguard1, function(self, killer)
		Trigger.AfterDelay(DateTime.Seconds(4), function()
			if not TraitorGeneral.IsDead then
				TraitorGeneral.Move(TraitorGeneralSafePoint.Location)
			end
		end)
	end)

	Trigger.OnKilled(TraitorGeneral, function(self, killer)
		USSR.MarkCompletedObjective(ObjectiveKillTraitor)
	end)

	Trigger.OnCapture(TraitorTechCenter, function(self, captor, oldOwner, newOwner)
		if newOwner == USSR then
			if ObjectiveCaptureTraitorTechCenter == nil then
				ObjectiveCaptureTraitorTechCenter = USSR.AddSecondaryObjective("Capture Traitor's Tech Center.")
			end
			USSR.MarkCompletedObjective(ObjectiveCaptureTraitorTechCenter)
		end
	end)

	Trigger.OnKilled(TraitorTechCenter, function(self, killer)
		if ObjectiveCaptureTraitorTechCenter ~= nil and not USSR.IsObjectiveCompleted(ObjectiveCaptureTraitorTechCenter) then
			USSR.MarkFailedObjective(ObjectiveCaptureTraitorTechCenter)
		end
	end)

	Trigger.OnKilled(TraitorHQ, function(self, killer)
		TraitorHQKilledOrCaptured()
	end)

	Trigger.OnCapture(TraitorHQ, function(self, captor, oldOwner, newOwner)
		TraitorHQKilledOrCaptured()
	end)

	-- After 10 minutes, remove Yegorov if player hasn't got close to him yet (effectively entering the HQ)
	Trigger.AfterDelay(DateTime.Minutes(10), function()
		TraitorRetreatToHQ()
	end)

	Trigger.OnEnteredProximityTrigger(TraitorHQSpawn.CenterPosition, WDist.New(12 * 1024), function(a, id)
		if a.Owner == USSR then
			Trigger.RemoveProximityTrigger(id)
			if TraitorGeneral.IsInWorld then
				YegorovStaysOutside = true
			end
		end
	end)
end

Tick = function()
	OncePerSecondChecks()
	OncePerFiveSecondChecks()
end

OncePerSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 25 == 0 then
		Greece.Cash = 3500
		Greece.Resources = 3500
		Traitor.Cash = 3500
		Traitor.Resources = 3500

		if TimerTicks > 0 then
			if TimerTicks > 25 then
				TimerTicks = TimerTicks - 25
			else
				TimerTicks = 0
			end
		end
	end
end

OncePerFiveSecondChecks = function()
	if DateTime.GameTime > 1 and DateTime.GameTime % 125 == 0 then
		UpdatePlayerBaseLocation()
	end
end

InitGreece = function()
	if Difficulty == "easy" then
		RebuildExcludes.Greece = { Types = { "gun", "pbox", "pris" } }
	end

	AutoRepairAndRebuildBuildings(Greece, 10)
	SetupRefAndSilosCaptureCredits(Greece)
	AutoReplaceHarvesters(Greece)

	Actor.Create("POWERCHEAT", true, { Owner = Traitor, Location = UpgradeCreationLocation })

	local alliedGroundAttackers = Greece.GetGroundAttackers()

	Utils.Do(alliedGroundAttackers, function(a)
		TargetSwapChance(a, Greece, 10)
		CallForHelpOnDamagedOrKilled(a, WDist.New(5120), IsGreeceGroundHunterUnit)
	end)

	local traitorGroundAttackers = Traitor.GetGroundAttackers()

	Utils.Do(traitorGroundAttackers, function(a)
		TargetSwapChance(a, Traitor, 10)
		CallForHelpOnDamagedOrKilled(a, WDist.New(5120), IsGroundHunterUnit)
	end)

	Actor.Create("hazmat.upgrade", true, { Owner = Greece, Location = UpgradeCreationLocation })
	Actor.Create("apb.upgrade", true, { Owner = Greece, Location = UpgradeCreationLocation })

	if Difficulty == "hard" then
		Actor.Create("cryr.upgrade", true, { Owner = Greece, Location = UpgradeCreationLocation })

		Trigger.AfterDelay(DateTime.Minutes(20), function()
			Actor.Create("flakarmor.upgrade", true, { Owner = Greece, Location = UpgradeCreationLocation })
		end)
	end
end

AbandonedBaseDiscovered = function()
	if IsAbandonedBaseDiscovered then
		return
	end

	IsAbandonedBaseDiscovered = true
	TraitorRetreatToHQ()

	local baseBuildings = Map.ActorsInBox(AbandonedBaseTopLeft.CenterPosition, AbandonedBaseBottomRight.CenterPosition, function(a)
		return a.Owner == USSRAbandoned
	end)

	Utils.Do(baseBuildings, function(a)
		a.Owner = USSR
	end)

	USSR.MarkCompletedObjective(ObjectiveFindSovietBase)
	if ObjectiveCaptureTraitorTechCenter == nil then
		ObjectiveCaptureTraitorTechCenter = USSR.AddSecondaryObjective("Capture Traitor's Tech Center.")
		if TraitorTechCenter.IsDead then
			USSR.MarkFailedObjective(ObjectiveCaptureTraitorTechCenter)
		end
	end

	Trigger.AfterDelay(Squads.Main.Delay[Difficulty], function()
		InitAttackSquad(Squads.Main, Greece)
	end)

	Trigger.AfterDelay(Squads.Traitor.Delay[Difficulty], function()
		InitAttackSquad(Squads.Traitor, Traitor)
	end)

	Trigger.AfterDelay(Squads.Air.Delay[Difficulty], function()
		InitAirAttackSquad(Squads.Air, Greece, Nod, { "harv", "v2rl", "apwr", "tsla", "ttra", "v3rl", "mig", "hind", "suk", "suk.upg", "kiro", "apoc" })
	end)

	Trigger.AfterDelay(1, function()
		Actor.Create("QueueUpdaterDummy", true, { Owner = USSR, Location = UpgradeCreationLocation })
	end)

	if not Boris.IsDead then
		Boris.GrantCondition("autoattack-enabled")
	end

	Trigger.AfterDelay(ReinforcementsDelay[Difficulty], function()
		Media.PlaySpeechNotification(USSR, "ReinforcementsArrived")
		Beacon.New(USSR, PlayerStart.CenterPosition)
		local reinforcements = { "4tnk", "4tnk", "v2rl", "btr" }
		if Difficulty == "easy" then
			reinforcements = { "4tnk", "4tnk", "v3rl", "v3rl", "btr" }
		elseif Difficulty == "normal" then
			reinforcements = { "4tnk", "4tnk", "v2rl", "v2rl", "btr" }
		end
		Reinforcements.Reinforce(USSR, reinforcements, { ReinforcementsSpawn.Location, PlayerStart.Location }, 75)
	end)

	Trigger.AfterDelay(DateTime.Seconds(30), function()
		ShockDrop = Actor.Create("shockdrop", false, { Owner = USSR, Location = UpgradeCreationLocation })
		ShockDrop.TargetParatroopers(AbandonedBaseCenter.CenterPosition, Angle.North)
	end)
end

TraitorHQKilledOrCaptured = function()
	-- Spawn Yegorov (unless he's outside already)
	if not TraitorGeneral.IsInWorld then
		local traitorGeneral = Actor.Create("gnrl", true, { Owner = Traitor, Location = TraitorHQSpawn.Location })
		traitorGeneral.Move(TraitorGeneralSafePoint.Location)
		Trigger.OnKilled(traitorGeneral, function(self, killer)
			USSR.MarkCompletedObjective(ObjectiveKillTraitor)
		end)
	end
end

TraitorRetreatToHQ = function()
	if not YegorovStaysOutside and TraitorGeneral.IsInWorld then
		TraitorGeneral.Destroy()
	end
end
