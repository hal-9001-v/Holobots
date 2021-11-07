using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DistanceToPlayerUnitSensor : Sensor
{

    int _threshold;
    Target _owner;
    Ground _ground;

    public PlayerUnit closestPlayerUnit { get; private set; }

    public DistanceToPlayerUnitSensor(Target owner, int threshold, UtilityFunction function) : base(function)
    {
        _owner = owner;
        _threshold = threshold;

        _ground = GameObject.FindObjectOfType<Ground>();
    }

    public override float GetScore()
    {
        return function.GetValue(TotalProximityScore());
    }

    float ClosestPlayerUnitDistance()
    {
        var playerUnits = GameObject.FindObjectsOfType<PlayerUnit>();
        PlayerUnit closestUnit = null;
        int closestDistance = int.MaxValue;

        int newDistance;

        for (int i = 0; i < playerUnits.Length; i++)
        {

            if (playerUnits[i].gameObject == _owner.gameObject)
            {
                continue;
            }

            newDistance = _ground.GetDistance(_owner.currentGroundTile, playerUnits[i].target.currentGroundTile);

            if (newDistance < closestDistance || !closestUnit)
            {
                closestUnit = playerUnits[i];
                closestDistance = newDistance;
            }
        }


        return closestDistance;
    }

    Score TotalProximityScore()
    {
        float value = 0;
        float closestDistance = float.MaxValue;

        var units = GameObject.FindObjectsOfType<PlayerUnit>();

        foreach (var unit in units)
        {
            var distance = _ground.GetDistance(_owner.currentGroundTile, unit.target.currentGroundTile);

            if (distance < _threshold)
            {
                value++;
            }

            if (distance < closestDistance)
            {
                closestDistance = distance;
                closestPlayerUnit = unit;
            }
        }

        return new Score(value, units.Length);
    }

}
