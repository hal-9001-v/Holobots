using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DistanceToPlayerUnitSensor : Sensor
{
    int _threshold;

    Target _owner;
    Ground _ground;

    public Bot closestBot { get; private set; }

    public DistanceToPlayerUnitSensor(Target owner, int threshold)
    {
        _owner = owner;
        _threshold = threshold;

        _ground = GameObject.FindObjectOfType<Ground>();
    }

    public override Score GetScore()
    {
        return TotalProximityScore();
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

        var bots = GameObject.FindObjectsOfType<Bot>();

        foreach (var bot in bots)
        {
            if (_ground.GetDistance(_owner.currentGroundTile, bot.target.currentGroundTile) < _threshold)
            {
                value++;
            }
        }

        return new Score(value, bots.Length);
    }

}
