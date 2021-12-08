using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShootAction : UtilityAction
{
    Shooter _shooter;

    Target _target;

    public ShootAction( Shooter shooter, string name, Func<float> valueCalculation) : base(name,valueCalculation)
    {
        _shooter = shooter;
    }

    public void SetTarget(Target target)
    {
        _target = target;
    }

    public override void Execute()
    {
        if (_preparationAction != null)
            _preparationAction.Invoke();


        _shooter.AddShoot(_target);

    }


}
