using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SightToPlayerUnitSensor : Sensor
{
    Target _owner;

    LayerMask _obstacleLayers;

    public SightToPlayerUnitSensor(Target owner)
    {
        _owner = owner;
    }

    public override Score GetScore()
    {
        return GetTotalOnSight();
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
