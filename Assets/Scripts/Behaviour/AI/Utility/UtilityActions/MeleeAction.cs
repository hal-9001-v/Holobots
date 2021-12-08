using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeleeAction : UtilityAction
{
    Meleer _meleer;

    Target _target;

    public MeleeAction( Meleer meleer, string name, Func<float> valueCalculation) : base(name, valueCalculation)
    {
        _meleer = meleer;
    }

    public void SetTarget(Target target)
    {
        _target = target;
    }

    public override void Execute()
    {
        if (_preparationAction != null)
            _preparationAction.Invoke();

        _meleer.Hit(_target);
    }


}
