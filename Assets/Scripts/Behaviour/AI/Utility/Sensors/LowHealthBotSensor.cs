using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LowHealthSensor : Sensor
{
    float _threshold;

    Target _owner;

    public LowHealthSensor(List<TeamTag> teamMask, float threshold, UtilityFunction function) : base(function, teamMask)
    {
        SetThreshold(threshold);
    }


    public override float GetScore()
    {
        return function.GetValue(TotalHealthScore());

    }

    public List<Target> GetLowHealthBots()
    {
        List<Target> bots = new List<Target>();



        foreach (var target in GameObject.FindObjectsOfType<Target>())
        {
            if (teamMask.Contains(target.teamTag))
            {

                float currentHealth = target.currentHealth;
                float maxHealth = target.maxHealth;
                if (currentHealth / maxHealth < _threshold)
                {
                    bots.Add(target);
                }
            }
        }

        return bots;
    }

    Score TotalHealthScore()
    {

        var bots = GameObject.FindObjectsOfType<Bot>();

        var lowHealthBots = GetLowHealthBots();

        return new Score(lowHealthBots.Count, bots.Length);
    }


    /// <summary>
    /// Greater than 0, lesser than 1
    /// </summary>
    public void SetThreshold(float value)
    {
        _threshold = value;
    }

}
