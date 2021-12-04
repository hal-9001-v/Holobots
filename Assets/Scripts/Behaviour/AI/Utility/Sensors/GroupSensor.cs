using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroupSensor : Sensor
{
    public TeamTag targetTeam { private get; set; }

    int _groupRange;

    float _targetTeamSum;
    float _noTargetTeamSum;

    public GroupSensor(TeamTag targetTeam, float targetTeamSum, float noTargetTeamSum, int range, UtilityFunction function) : base(function)
    {
        this.targetTeam = targetTeam;

        _targetTeamSum = targetTeamSum;
        _noTargetTeamSum = noTargetTeamSum;

        _groupRange = range;
    }

    public override float GetScore()
    {
        var targets = GetGroupedTargets();

        int targetCount = 0;
        int noTargetCount = 0;
        foreach (var target in targets)
        {
            if (target.team == targetTeam)
            {
                targetCount++;
            }
            else if (target.team != TeamTag.None)
            {
                noTargetCount++;
            }
        }

        float value = targetCount * _targetTeamSum + noTargetCount * _noTargetTeamSum;

        if (value > 1) value = 1;
        else if (value < 0) value = 0;

        return function.GetValue(new Score(value, 1));
    }

    public List<Target> GetGroupedTargets()
    {

        List<Target> targets = new List<Target>();

        foreach (var target in GameObject.FindObjectsOfType<Target>())
        {
            if (target.team != TeamTag.None)
            {
                targets.Add(target);
            }
        }

        List<Target> groupedTargets = new List<Target>();

        for (int i = 0; i < targets.Count; i++)
        {
            for (int j = 0; j < targets.Count; j++)
            {
                if (i == j) continue;

                Vector2Int v = targets[i].currentGroundTile.cellCoord - targets[j].currentGroundTile.cellCoord;

                v = new Vector2Int(Mathf.Abs(v.x), Mathf.Abs(v.y));

                if (v.x < _groupRange && v.y < _groupRange)
                {
                    if (!groupedTargets.Contains(targets[i]))
                    {
                        groupedTargets.Add(targets[i]);
                    }

                }


            }
        }

        return groupedTargets;
    }

    class TargetGroup
    {
        public int count;
        public GroundTile center;
    }
}
