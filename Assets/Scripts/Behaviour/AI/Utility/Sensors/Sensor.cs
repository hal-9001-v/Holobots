using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Sensor
{
    public UtilityFunction function { get; private set; }

    public Sensor(UtilityFunction function, List<TeamTag> teamMask)
    {
        this.teamMask = teamMask;
        this.function = function;
    }

    public List<TeamTag> teamMask { get; private set; }

    public abstract float GetScore();


}
