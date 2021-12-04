using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DistanceSensor : Sensor
{
    //Score
    int _threshold;

    Target _owner;
    Ground _ground;

    PathProfile _pathProfile;

    /// <summary>
    /// GetScore() will depend on this variable. Besides, methods will use this TeamTag for queries by default
    /// </summary>
    public TeamTag teamForScoreCalculation { get; private set; }

    public DistanceSensor(Target owner, TeamTag teamForScore, PathProfile pathProfile, int threshold, UtilityFunction function) : base(function)
    {
        _owner = owner;
        _threshold = threshold;
        _pathProfile = pathProfile;

        teamForScoreCalculation = teamForScore;

        _ground = GameObject.FindObjectOfType<Ground>();

    }

    /// <summary>
    /// Returns the closes target to owner.
    /// </summary>
    /// <param name="targets"></param>
    /// <returns></returns>
    public Target GetClosestTargetFromList(List<Target> targets)
    {
        Target closestTarget = targets[0];
        int currentDistance = _ground.GetDistance(_owner.currentGroundTile, targets[0].currentGroundTile, _pathProfile);

        for (int i = 1; i < targets.Count; i++)
        {
            int newDistance = _ground.GetDistance(_owner.currentGroundTile, targets[i].currentGroundTile, _pathProfile);

            if (currentDistance < newDistance)
            {
                currentDistance = newDistance;
            }
        }


        return closestTarget;
    }

    /// <summary>
    /// Returns closest target from such team.
    /// </summary>
    /// <param name="team"></param>
    /// <returns></returns>
    public Target GetClosestTarget(TeamTag team)
    {
        var targets = GameObject.FindObjectsOfType<Target>();

        List<Target> targetList = new List<Target>();

        foreach (var target in targets)
        {
            if (target.team == team)
            {
                targetList.Add(target);
            }
        }

        return GetClosestTargetFromList(targetList);
    }

    /// <summary>
    /// Returns closest target from teamForScoreCalculation
    /// </summary>
    /// <returns></returns>
    public Target GetClosestTarget()
    {
        return GetClosestTarget(teamForScoreCalculation);
    }

    /// <summary>
    /// Returns targets from such team with specified TargetType
    /// </summary>
    /// <param name="team"></param>
    /// <param name="targetType"></param>
    /// <returns></returns>
    public List<Target> FindTargetsWithTag(TeamTag team, TargetType targetType)
    {
        List<Target> targets = FindTargetsOfTeam(team);

        foreach (var target in GameObject.FindObjectsOfType<Target>())
        {
            if (target.targetType == targetType)
            {
                targets.Add(target);
            }
        }

        return targets;
    }

    /// <summary>
    /// Returns targets from teamForScoreCalculation with specified targetType
    /// </summary>
    /// <param name="targetType"></param>
    /// <returns></returns>
    public List<Target> FindTargetWithTag(TargetType targetType)
    {
        return FindTargetsWithTag(teamForScoreCalculation, targetType);
    }

    /// <summary>
    /// Returns Targets from such team
    /// </summary>
    /// <param name="team"></param>
    /// <returns></returns>
    public List<Target> FindTargetsOfTeam(TeamTag team)
    {
        List<Target> targets = new List<Target>();

        foreach (var target in GameObject.FindObjectsOfType<Target>())
        {
            if (target.team == team)
            {
                targets.Add(target);
            }
        }

        return targets;
    }

    /// <summary>
    /// Returns targets from teamForScoreCalculation
    /// </summary>
    /// <returns></returns>
    public List<Target> FindTargetsOfTeam()
    {
        return FindTargetsOfTeam(teamForScoreCalculation);
    }

    public override float GetScore()
    {
        return function.GetValue(GetClosestUnitProximity(teamForScoreCalculation));
    }

    Score GetTotalProximityScore(TeamTag team)
    {
        float value = 0;
        float totalTargets = 0;

        var targets = GameObject.FindObjectsOfType<Target>();

        foreach (var unit in targets)
        {
            if (unit.team == team)
            {
                totalTargets++;

                if (_ground.GetDistance(_owner.currentGroundTile, unit.currentGroundTile, _pathProfile) < _threshold)
                {
                    value++;
                }
            }
        }

        return new Score(value, totalTargets);
    }

    Score GetClosestUnitProximity(TeamTag team)
    {
        
        var targets = GameObject.FindObjectsOfType<Target>();

        if (targets.Length == 0)
        {
            return new Score(int.MaxValue, 0);
        }

        Target closestUnit = null;
        float closestDistance = int.MaxValue;

        foreach (var unit in targets)
        {
            if (unit.team == team)
            {
                var newDistance = _ground.GetDistance(_owner.currentGroundTile, unit.currentGroundTile, _pathProfile);

                if (newDistance < closestDistance) {
                    closestUnit = unit;
                    closestDistance = newDistance;
                }
            }
        }

        return new Score(closestDistance, _threshold);
    }

}
