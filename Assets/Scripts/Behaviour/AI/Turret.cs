using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Shooter))]
public class Turret : Bot, IUtilityAI
{
    [Header("Settings")]
    [SerializeField] LayerMask _obstacleLayers;

    [SerializeField] [Range(0, 10)] int _maxRange;
    [SerializeField] [Range(0, 5)] float _shootWeight = 1;
    [SerializeField] [Range(0, 5)] float _idleWeight = 1;

    Shooter _shooter;
    Target _target;

    DistanceToPlayerUnitSensor _distanceSensor;
    SightToPlayerUnitSensor _sightSensor;

    UtilityUnit _utilityUnit;

    private void Awake()
    {
        _shooter = GetComponent<Shooter>();
        _target = GetComponent<Target>();

        InitializeUtilityUnit();

    }


    public override void PrepareSteps()
    {
        ResetBehaviourComponents();

        _utilityUnit.GetHighestAction().Execute();
    }

    public override TurnPreview[] GetPossibleMoves()
    {
        throw new System.NotImplementedException();
    }

    public override MinMaxWeights GetMinMaxWeights()
    {
        throw new System.NotImplementedException();
    }

    public void InitializeUtilityUnit()
    {

        _utilityUnit = new UtilityUnit();

        _distanceSensor = new DistanceToPlayerUnitSensor(_target, _maxRange, new LinearUtilityFunction());
        _sightSensor = new SightToPlayerUnitSensor(_target, _obstacleLayers, new ThresholdUtilityFunction(0.5f));

        ShootPlayerUnitAction shootAction = new ShootPlayerUnitAction(_shooter, () =>
        {
            return _sightSensor.GetScore() * _distanceSensor.GetScore() * _shootWeight;
        });

        shootAction.AddPreparationListener(() =>
        {
            shootAction.SetTarget(_distanceSensor.closestPlayerUnit);
        });
        _utilityUnit.AddAction(shootAction);



        IdleAction idleAction = new IdleAction(() =>
        {
            return (1 - _distanceSensor.GetScore() * _idleWeight);
        });
        _utilityUnit.AddAction(idleAction);

    }

    public void ResetBehaviourComponents()
    {
        _shooter.ResetSteps();
    }
}
