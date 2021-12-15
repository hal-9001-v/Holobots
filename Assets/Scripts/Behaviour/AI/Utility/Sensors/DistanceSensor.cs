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

    GameDirector _gameDirector;

    /// <summary>
    /// GetScore() will depend on this variable. Besides, methods will use this TeamTag for queries by default
    /// </summary>
    public TargetType typeForScoreCalculation { get; private set; }

    public DistanceSensor(Target owner, List<TeamTag> targetMask, PathProfile pathProfile, int threshold, UtilityFunction function) : base(function, targetMask)
    {

        _owner = owner;
        _threshold = threshold;
        _pathProfile = pathProfile;

        typeForScoreCalculation = TargetType.Any;

        _ground = GameObject.FindObjectOfType<Ground>();
        _gameDirector = GameObject.FindObjectOfType<GameDirector>();

    }

    public DistanceSensor(Target owner, TargetType typeForScore, List<TeamTag> teamMask, PathProfile pathProfile, int threshold, UtilityFunction function) : base(function, teamMask)
    {
        typeForScoreCalculation = typeForScore;

        _owner = owner;
        _threshold = threshold;
        _pathProfile = pathProfile;


        _ground = GameObject.FindObjectOfType<Ground>();
        _gameDirector = GameObject.FindObjectOfType<GameDirector>();

    }


    /// <summary>
    /// Returns the closes target to owner.
    /// </summary>
    /// <param name="targets"></param>
    /// <returns></returns>
    public Target GetClosestTargetFromList(List<Target> targets)
    {
        if (targets.Count == 0) return null;

        Target closestTarget = targets[0];
        int currentDistance = _ground.GetDistance(_owner.currentGroundTile, targets[0].currentGroundTile, _pathProfile);

        for (int i = 1; i < targets.Count; i++)
        {
            int newDistance = _ground.GetDistance(_owner.currentGroundTile, targets[i].currentGroundTile, _pathProfile);

            if (currentDistance > newDistance)
            {
                currentDistance = newDistance;
                closestTarget = targets[i];
            }
        }

        return closestTarget;
    }

    /// <summary>
    /// Returns closest target from such team.
    /// </summary>
    /// <param name="team"></param>
    /// <returns></returns>
    public Target GetClosestTarget(List<TeamTag> teams)
    {
        return GetClosestTargetFromList(_gameDirector.GetTargetsOfTeams(teams));
    }

    /// <summary>
    /// Returns closest target from teamForScoreCalculation
    /// </summary>
    /// <returns></returns>
    public Target GetClosestTarget()
    {
        return GetClosestTarget(teamMask);
    }

    /// <summary>
    /// Returns targets from such team with specified TargetType
    /// </summary>
    /// <param name="team"></param>
    /// <param name="targetType"></param>
    /// <returns></returns>
    public List<Target> FindTargetsWithTag(List<TeamTag> team, TargetType targetType)
    {
        return _gameDirector.GetTargetsOfTeamWithTag(team, targetType);
    }

    /// <summary>
    /// Returns targets from teamForScoreCalculation with specified targetType
    /// </summary>
    /// <param name="targetType"></param>
    /// <returns></returns>
    public List<Target> FindTargetWithTag(TargetType targetType)
    {
        return FindTargetsWithTag(teamMask, targetType);
    }

    /// <summary>
    /// Returns Targets from such team
    /// </summary>
    /// <param name="team"></param>
    /// <returns></returns>
    public List<Target> FindTargetsOfTeam(List<TeamTag> teams)
    {
        return _gameDirector.GetTargetsOfTeams(teams);
    }

    /// <summary>
    /// Returns targets from teamForScoreCalculation
    /// </summary>
    /// <returns></returns>
    public List<Target> FindTargetsOfTeam()
    {
        return FindTargetsOfTeam(teamMask);
    }

    public override float GetScore()
    {
        return function.GetValue(GetClosestUnitProximity(_owner, teamMask));
    }

    public float GetScore(Target target)
    {
        return function.GetValue(GetClosestUnitProximity(target, teamMask));
    }

    Score GetClosestUnitProximity(Target target, List<TeamTag> mask)
    {
        var targets = _gameDirector.GetTargetsOfTeams(mask);

        if (targets.Count == 0)
        {
            return new Score(int.MaxValue, _threshold);
        }

        float closestDistance = int.MaxValue;

        foreach (var unit in targets)
        {
            var newDistance = _ground.GetDistance(target.currentGroundTile, unit.currentGroundTile, _pathProfile);

            if (newDistance < closestDistance)
            {
                closestDistance = newDistance;
            }
        }

        if (closestDistance < 0) closestDistance = 0;

        return new Score(closestDistance, _threshold);
    }

}
