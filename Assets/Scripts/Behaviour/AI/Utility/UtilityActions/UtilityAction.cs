using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class UtilityAction
{
    public string name { get; private set; }

    public float value { get; private set; }

    protected Action _preparationAction;
    protected Func<float> _valueCalculation;

    

    public UtilityAction(string name, Func<float> valueCalculation)
    {
        this.name = name;
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
