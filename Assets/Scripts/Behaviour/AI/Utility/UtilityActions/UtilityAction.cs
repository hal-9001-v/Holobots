using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class UtilityAction
{
    public float value { get; private set; }

    protected Action _preparationAction;
    protected Func<float> _valueCalculation;

    

    public UtilityAction(Func<float> valueCalculation)
    {
        _valueCalculation = valueCalculation;
    }


    public void AddPreparationListener(Action action)
    {
        _preparationAction += action;
    }

    public void UpdateValue()
    {
        value = _valueCalculation.Invoke();
    }

    public abstract void Execute();

}
