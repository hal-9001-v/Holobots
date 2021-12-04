using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EngageAction : UtilityAction
{
    Mover _mover;

    Target _target;

    public EngageAction(Mover mover, Func<float> valueCalculation) : base(valueCalculation)
    {
        _mover = mover;
    }



    public void SetTarget(Target target)
    {
        _target = target;
    }

    public override void Execute()
    {
        if (_preparationAction != null)
            _preparationAction.Invoke();

        _mover.MoveToTarget(_target.currentGroundTile);
    }


}
