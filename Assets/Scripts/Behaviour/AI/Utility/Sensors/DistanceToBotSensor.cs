using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DistanceToBotSensor : Sensor
{
    int _threshold;

    Target _owner;
    Ground _ground;

    public Bot closestBot { get; private set; }

    public DistanceToBotSensor(Target owner, int threshold)
    {
        _owner = owner;
        _threshold = threshold;

        _ground = GameObject.FindObjectOfType<Ground>();
    }

    public override Score GetScore()
    {
        return GetTotalProximityScore();
    }

    float ClosestBotDistance()
    {
        var bots = GameObject.FindObjectsOfType<Bot>();
        Bot closestBot = null;
        int closestDistance = int.MaxValue;

        int newDistance;

        for (int i = 0; i < bots.Length; i++)
        {

            if (bots[i].gameObject == _owner.gameObject)
            {
                continue;
            }

            newDistance = _ground.GetDistance(_owner.currentGroundTile, bots[i].target.currentGroundTile);

            if (newDistance < closestDistance || !closestBot)
            {
                closestBot = bots[i];
                closestDistance = newDistance;
            }
        }

        return closestDistance;

    }

    Score GetTotalProximityScore()
    {
        float value = 0;

        var units = GameObject.FindObjectsOfType<PlayerUnit>();

        foreach (var unit in units)
        {
            if (_ground.GetDistance(_owner.currentGroundTile, unit.target.currentGroundTile) < _threshold)
            {
                value++;
            }
        }

        return new Score(value, units.Length);
    }

}
