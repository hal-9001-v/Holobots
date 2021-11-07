using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FleeAction : UtilityAction
{
    Mover _mover;
    Ground _ground;
    Target _target;

    public FleeAction(Mover mover, Func<float> valueCalculation) : base(valueCalculation)
    {
        _mover = mover;
        _ground = GameObject.FindObjectOfType<Ground>();
    }

    public void SetTarget(Target target)
    {
        _target = target;
    }

    public override void Execute()
    {
        if (_preparationAction != null)
            _preparationAction.Invoke();

        int maxDistance = int.MinValue;
        GroundTile furthestTile = null;

        foreach (var distancedTile in _mover.GetTilesInMaxRange(_mover.maxMoves))
        {
            if (distancedTile.tile.unit != null) continue;

            var distance = _ground.GetDistance(distancedTile.tile, _target.currentGroundTile);

            if (distance > maxDistance)
            {
                furthestTile = distancedTile.tile;
                maxDistance = distance;
            }

        }


        _mover.AddStepsToReachTarget(furthestTile);

    }


}
