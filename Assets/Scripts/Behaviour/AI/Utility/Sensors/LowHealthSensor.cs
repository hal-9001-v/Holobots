using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LowHealthSensor : Sensor
{
    float _threshold;

    GameDirector _gameDirector;

    public LowHealthSensor(List<TeamTag> teamMask, float threshold, UtilityFunction function) : base(function, teamMask)
    {
        SetThreshold(threshold);
        _gameDirector = GameObject.FindObjectOfType<GameDirector>();

    }


    public override float GetScore()
    {
        return function.GetValue(TotalHealthScore());

    }

    public List<Target> GetLowHealthBots()
    {
        List<Target> targets = new List<Target>();

        foreach (var target in _gameDirector.GetTargetsOfTeams(teamMask))
        {
            float currentHealth = target.currentHealth;
            float maxHealth = target.maxHealth;
            if (currentHealth / maxHealth < _threshold)
            {
                targets.Add(target);
            }
        }
        return targets;
    }

    Score TotalHealthScore()
    {
        var lowHealthBots = GetLowHealthBots();

        return new Score(lowHealthBots.Count, _gameDirector.GetTargetsOfTeams(teamMask).Count);
    }


    /// <summary>
    /// Greater than 0, lesser than 1
    /// </summary>
    public void SetThreshold(float value)
    {
        _threshold = value;
    }

}
