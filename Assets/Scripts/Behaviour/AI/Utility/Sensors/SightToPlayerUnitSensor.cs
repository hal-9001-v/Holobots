using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SightToPlayerUnitSensor : Sensor
{
    Target _owner;

    LayerMask _obstacleLayers;

    public SightToPlayerUnitSensor(Target owner, LayerMask obstacleLayers, UtilityFunction function) : base(function)
    {
        _owner = owner;
        _obstacleLayers = obstacleLayers;
    }

    public override float GetScore()
    {
        return function.GetValue(GetTotalOnSight());
    }


    Score GetTotalOnSight()
    {
        var units = GameObject.FindObjectsOfType<PlayerUnit>();

        var maxScore = units.Length;
        int score = 0;

        foreach (var unit in units)
        {
            if (IsTargetOnSight(unit.target))
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

    public List<Target> GetTargetsOnSight(TeamTag team)
    {
        List<Target> targets = new List<Target>();

        foreach (var target in GameObject.FindObjectsOfType<Target>())
        {
            if (target.team == team && IsTargetOnSight(target))
            {
                targets.Add(target);
            }
        }

        return targets;
    }


}
