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

    List<TeamTag> _unwantedMask;

    public GroupSensor(List<TeamTag> targetMask, List<TeamTag> unwantedMask, float targetTeamSum, float noTargetTeamSum, int range, UtilityFunction function) : base(function, targetMask)
    {
        this.targetTeam = targetTeam;

        _unwantedMask = unwantedMask;

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
            if (teamMask.Contains(target.teamTag))
            {
                targetCount++;
            }
            else if (_unwantedMask.Contains(target.teamTag))
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
            if (teamMask.Contains(target.teamTag))
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

    public List<Target> GetGroupedTargetsOfTeam(List<TeamTag> teamMask)
    {
        var targets = GetGroupedTargets();

        for (int i = 0; i < targets.Count; i++)
        {
            if (!teamMask.Contains(targets[i].teamTag))
            {
                targets.RemoveAt(i);

                i--;
            }
        }

        return targets;
    }

    class TargetGroup
    {
        public int count;
        public GroundTile center;
    }
}
