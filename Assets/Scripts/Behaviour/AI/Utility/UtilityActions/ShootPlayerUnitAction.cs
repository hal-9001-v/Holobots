using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShootPlayerUnitAction : UtilityAction
{
    Target _owner;
    Shooter _shooter;

    PlayerUnit _target;

    public ShootPlayerUnitAction(Target owner, Shooter shooter)
    {
        _owner = owner;
        _shooter = shooter;
    }

    public void SetTarget(PlayerUnit target)
    {
        _target = target;
    }

    public override void Execute()
    {
        for (int i = 0; i < _shooter.maxShoots; i++)
        {
            _shooter.AddShootStep(_target.target.currentGroundTile);
        }

    }


}
