using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShootPlayerUnitAction : UtilityAction
{
    Shooter _shooter;

    PlayerUnit _target;

    public ShootPlayerUnitAction( Shooter shooter, Func<float> valueCalculation) : base(valueCalculation)
    {
        _shooter = shooter;
    }

    public void SetTarget(PlayerUnit target)
    {
        _target = target;
    }

    public override void Execute()
    {
        if (_preparationAction != null)
            _preparationAction.Invoke();

        for (int i = 0; i < _shooter.maxShoots; i++)
        {
            _shooter.AddShootStep(_target.target.currentGroundTile);
        }

    }


}
