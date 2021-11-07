using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class UtilityUnit
{
    List<UtilityAction> _actions;

    public UtilityUnit()
    {
        _actions = new List<UtilityAction>();
    }
    public UtilityAction GetHighestAction()
    {
        UtilityAction highestAction = _actions[0];
        highestAction.UpdateValue();

        for (int i = 1; i < _actions.Count; i++)
        {
            _actions[i].UpdateValue();

            if (highestAction.value < _actions[i].value)
            {
                highestAction = _actions[i];
            }

        }

         return highestAction;
    }

    public void AddAction(UtilityAction action)
    {
        _actions.Add(action);
    }

}
