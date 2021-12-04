using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExplosionAction : UtilityAction
{
    Explosioner _explosioner;
    GroundTile _targetTile;

    public ExplosionAction(Explosioner explosioner, Func<float> valueCalculation) : base(valueCalculation)
    {
        _explosioner = explosioner;
    }

    public override void Execute()
    {
        if (_preparationAction != null)
            _preparationAction.Invoke();

        _explosioner.Explode(_targetTile);
    }

    public void SetTarget(GroundTile targetTile)
    {
        _targetTile = targetTile;
    }
}
