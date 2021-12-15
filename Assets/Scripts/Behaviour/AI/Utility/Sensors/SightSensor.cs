using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SightSensor : Sensor
{
    Target _owner;

    LayerMask _obstacleLayers;

    GameDirector _gameDirector;

    List<TeamTag> _enemyMask;

    public SightSensor(Target owner, List<TeamTag> targetMask, LayerMask obstacleLayers, UtilityFunction function) : base(function, targetMask)
    {
        _owner = owner;
        _obstacleLayers = obstacleLayers;
        _enemyMask = targetMask;

        _gameDirector = GameObject.FindObjectOfType<GameDirector>();
    }

    public override float GetScore()
    {
        return function.GetValue(GetTotalOnSight());
    }


    Score GetTotalOnSight()
    {
        var units = _gameDirector.GetTargetsOfTeams(_enemyMask);

        var maxScore = units.Count;
        int score = 0;

        foreach (var unit in units)
        {
            if (IsTargetOnSight(unit))
            {
                score++;
            }
        }

        return new Score(score, maxScore);
    }

    public bool IsTargetOnSight(Target target)
    {

        var direction = target.transform.position - _owner.transform.position;
        var range = direction.magnitude;
        direction.Normalize();

        RaycastHit hit;
        if (Physics.Raycast(_owner.transform.position, direction, out hit, range, _obstacleLayers))
        {
            return false;
        }

        return true;

    }

    public List<Target> GetTargetsOnSight(List<TeamTag> teamMask)
    {
        List<Target> targets = _gameDirector.GetTargetsOfTeams(teamMask);

        for (int i = 0; i < targets.Count; i++)
        {
            if (IsTargetOnSight(targets[i]) == false)
            {
                targets.RemoveAt(i);
                i--;
            }
        }

        return targets;
    }


}
