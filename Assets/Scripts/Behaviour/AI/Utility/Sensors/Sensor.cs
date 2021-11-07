using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Sensor
{
    public UtilityFunction function { get; private set; }

    public Sensor(UtilityFunction function)
    {
        this.function = function;
    }

    public abstract float GetScore();


}
