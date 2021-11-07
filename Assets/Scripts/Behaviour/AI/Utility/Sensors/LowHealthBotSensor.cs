using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LowHealthBotSensor : Sensor
{
    float _threshold;

    public LowHealthBotSensor(float threshold, UtilityFunction function) : base(function)
    {
        SetThreshold(threshold);
    }

    public override float GetScore()
    {
        return function.GetValue(TotalHealthScore());
    }

    Score TotalHealthScore()
    {
        float value = 0;

        var bots = GameObject.FindObjectsOfType<Bot>();

        foreach (var bot in bots)
        {
            if (bot.target.currentHealth / bot.target.maxHealth < _threshold)
            {
                value++;
            }
        }

        return new Score(value, bots.Length);
    }

    /// <summary>
    /// Greater than 0, lesser than 1
    /// </summary>
    public void SetThreshold(float value)
    {
        value = _threshold;
    }

}
