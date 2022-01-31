﻿#region Copyright & License Information
/*
 * Copyright 2007-2020 The OpenRA Developers (see AUTHORS)
 * This file is part of OpenRA, which is free software. It is made
 * available to you under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version. For more
 * information, see COPYING.
 */
#endregion

using OpenRA.Mods.Common.Traits;
using OpenRA.Traits;

namespace OpenRA.Mods.CA.Traits
{
	[Desc("Reveals shroud and fog across the whole map while active.")]
	public class RevealsMapCAInfo : ConditionalTraitInfo
	{
		[Desc("Relationships the watching player needs to see the shroud removed.")]
		public readonly PlayerRelationship ValidRelationships = PlayerRelationship.Ally;

		[Desc("Can this actor reveal shroud generated by the `GeneratesShroud` trait?")]
		public readonly bool RevealGeneratedShroud = true;

		public override object Create(ActorInitializer init) { return new RevealsMapCA(this); }
	}

	public class RevealsMapCA : ConditionalTrait<RevealsMapCAInfo>, INotifyKilled, INotifyActorDisposing
	{
		readonly Shroud.SourceType type;

		public RevealsMapCA(RevealsMapCAInfo info)
			: base(info)
		{
			type = info.RevealGeneratedShroud ? Shroud.SourceType.Visibility
				: Shroud.SourceType.PassiveVisibility;
		}

		protected void AddCellsToPlayerShroud(Actor self, Player p, PPos[] uv)
		{
			if (!Info.ValidRelationships.HasRelationship(self.Owner.RelationshipWith(p)))
				return;

			p.Shroud.AddSource(this, type, uv);
		}

		protected void RemoveCellsFromPlayerShroud(Actor self, Player p)
			{
			if (!Info.ValidRelationships.HasRelationship(self.Owner.RelationshipWith(p)))
				return;

			p.Shroud.RemoveSource(this);
			}

		protected PPos[] ProjectedCells(Actor self)
		{
			return self.World.Map.ProjectedCells;
		}

		void INotifyActorDisposing.Disposing(Actor self)
		{
			foreach (var player in self.World.Players)
			{
				RemoveCellsFromPlayerShroud(self, player);
			}
		}

		void INotifyKilled.Killed(Actor self, AttackInfo e)
		{
			foreach (var player in self.World.Players)
			{
				RemoveCellsFromPlayerShroud(self, player);
			}
		}

		protected override void TraitEnabled(Actor self)
		{
			foreach (var player in self.World.Players)
			{
				AddCellsToPlayerShroud(self, player, ProjectedCells(self));
			}
		}

		protected override void TraitDisabled(Actor self)
		{
			foreach (var player in self.World.Players)
			{
				RemoveCellsFromPlayerShroud(self, player);
			}
		}
	}
}
