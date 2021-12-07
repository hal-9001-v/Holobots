using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LowHealthBotSensor : Sensor
{
    float _threshold;

    Target _owner;

    public LowHealthBotSensor(float threshold, UtilityFunction function) : base(function)
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

        foreach (var bot in GameObject.FindObjectsOfType<Bot>())
        {
            float currentHealth = bot.target.currentHealth;
            float maxHealth = bot.target.maxHealth;
            if (currentHealth / maxHealth < _threshold)
            {
                bots.Add(bot.target);
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
