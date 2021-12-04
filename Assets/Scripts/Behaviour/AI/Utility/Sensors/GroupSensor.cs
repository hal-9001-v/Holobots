using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroupSensor : Sensor
{
    public TeamTag targetTeam { private get; set; }

    Ground _ground;

    int _groupRange;

    public GroupSensor(TeamTag targetTeam, int range, UtilityFunction function) : base(function)
    {
        this.targetTeam = targetTeam;

        _groupRange = range;

        _ground = GameObject.FindObjectOfType<Ground>();
    }

    public override float GetScore()
    {
        var targets = GetGroupedTargets();

        if (targets.Count == 0)
            return function.GetValue(new Score(0, 1));

        return function.GetValue(new Score(1, 1));
    }

    public List<Target> GetGroupedTargets()
    {
        List<Target> targets = new List<Target>();

        foreach (var target in GameObject.FindObjectsOfType<Target>())
        {
            if (target.team == targetTeam)
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

                if (v.x < _groupRange || v.y < _groupRange)
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
