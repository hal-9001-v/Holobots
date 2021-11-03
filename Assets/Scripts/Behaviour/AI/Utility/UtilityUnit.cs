using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Target))]
public class UtilityUnit
{
    public Sensor[] sensors { get; private set;}
    public UtilityAction[] actions { get; private set;}


    public void SetSensors(Sensor[] sensors)
    {
        this.sensors = sensors;
    }

    public void SetActions(UtilityAction[] actions)
    {
        this.actions = actions;
    }
}
