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

    bool IsTargetOnSight(Target target)
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


}
