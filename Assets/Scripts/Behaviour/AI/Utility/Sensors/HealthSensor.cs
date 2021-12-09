using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthSensor : Sensor
{
    Target _owner;

    public HealthSensor(Target owner, UtilityFunction function) : base(function, null)
    {
        _owner = owner;
    }

    public override float GetScore()
    {
        return function.GetValue(GetHealtScore());
    }

    Score GetHealtScore()
    {
        return new Score(_owner.currentHealth, _owner.maxHealth);
    }

}
