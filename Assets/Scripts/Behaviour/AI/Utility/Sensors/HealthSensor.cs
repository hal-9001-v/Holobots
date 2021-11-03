using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthSensor : Sensor
{
    Target _owner;

    public HealthSensor(Target owner)
    {
        _owner = owner;
    }

    public override Score GetScore()
    {
        return GetHealtScore();
    }

    Score GetHealtScore()
    {
        return new Score(_owner.currentHealth, _owner.maxHealth);
    }

}
