using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IdleAction : UtilityAction
{

    TurnActor _actor;

    public IdleAction(TurnActor actor, Func<float> valueCalculation) : base(valueCalculation)
    {
        _actor = actor;
    }

    public override void Execute()
    {
        _actor.StartStep(1);
        _actor.EndStep();

    }
}
