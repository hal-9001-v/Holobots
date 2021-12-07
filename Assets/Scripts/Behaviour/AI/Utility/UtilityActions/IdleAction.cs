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
        _actor.StartCoroutine(Execution());
    }

    IEnumerator Execution() {
        _actor.StartStep(1);
        yield return new WaitForSeconds(0.5f);
        _actor.EndStep();
    }

}
