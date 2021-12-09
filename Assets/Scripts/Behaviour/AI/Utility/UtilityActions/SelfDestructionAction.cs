using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelfDestructionAction : UtilityAction
{
    SelfExplosion _explosioner;

    public SelfDestructionAction(SelfExplosion explosioner, string name, Func<float> valueCalculation) : base(name,valueCalculation)
    {
        _explosioner = explosioner;
    }

    public override void Execute()
    {
        if (_preparationAction != null)
            _preparationAction.Invoke();

        _explosioner.Explode();
    }

}
