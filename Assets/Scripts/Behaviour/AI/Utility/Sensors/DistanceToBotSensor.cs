using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DistanceToBotSensor : Sensor
{
    int _threshold;

    Target _owner;
    Ground _ground;

    PathProfile _pathProfile;

    public Bot closestBot { get; private set; }
    public Bot furthestBot { get; private set; }

    public DistanceToBotSensor(Target owner,PathProfile pathProfile, int threshold, UtilityFunction function) : base(function)
    {
        _owner = owner;
        _threshold = threshold;
        _pathProfile = pathProfile;

        _ground = GameObject.FindObjectOfType<Ground>();


    }

    public override float GetScore()
    {
        return function.GetValue(ClosestBotScore());
    }

    Score ClosestBotScore()
    {
        var bots = GameObject.FindObjectsOfType<Bot>();
        Bot closestBot = null;
        int closestDistance = int.MaxValue;
        int maxDistance = int.MinValue;

        int newDistance;

        for (int i = 0; i < bots.Length; i++)
        {

            if (bots[i].gameObject == _owner.gameObject)
            {
                continue;
            }

            newDistance = _ground.GetDistance(_owner.currentGroundTile, bots[i].target.currentGroundTile, _pathProfile);

            if (newDistance < closestDistance || !closestBot)
            {
                closestBot = bots[i];
                closestDistance = newDistance;
            }
            else if (newDistance > maxDistance) {
                maxDistance = newDistance;
                furthestBot = bots[i];
            }
        }


        return new Score(closestDistance, maxDistance);

    }

    Score GetTotalProximityScore()
    {
        float value = 0;

        var units = GameObject.FindObjectsOfType<PlayerUnit>();

        foreach (var unit in units)
        {
            if (_ground.GetDistance(_owner.currentGroundTile, unit.target.currentGroundTile, _pathProfile) < _threshold)
            {
                value++;
            }
        }

        return new Score(value, units.Length);
    }

}
