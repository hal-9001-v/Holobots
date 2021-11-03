using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Shooter))]
public class Turret : Bot
{
    [Header("Settings")]
    [SerializeField] [Range(0, 10)] int _maxRange;

    Shooter _shooter;
    Target _target;

    UtilityUnit _utilityUnit;

    private void Awake()
    {
        _shooter = GetComponent<Shooter>();
        _target = GetComponent<Target>();

        Sensor[] sensors = new Sensor[3];

        sensors[0] = new HealthSensor(_target);
        sensors[1] = new DistanceToBotSensor(_target, _maxRange);
        sensors[2] = new SightToPlayerUnitSensor(_target);




    }


    public override void PrepareSteps()
    {
        _shooter.ResetSteps();

        var playerUnits = FindObjectsOfType<PlayerUnit>();

        if (playerUnits != null && playerUnits.Length != 0)
        {
            var target = playerUnits[Random.Range(0, playerUnits.Length)].GetComponent<Target>();

            for (int i = 0; i < _shooter.maxShoots; i++)
            {
                _shooter.AddShootStep(target.currentGroundTile);
            }

        }



    }

    public override TurnPreview[] GetPossibleMoves()
    {
        throw new System.NotImplementedException();
    }

    public override MinMaxWeights GetMinMaxWeights()
    {
        throw new System.NotImplementedException();
    }
}
