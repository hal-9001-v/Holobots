using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Mover))]
[RequireComponent(typeof(Shooter))]
public class Hunter : Bot, IUtilityAI
{
    Mover _mover;
    Shooter _shooter;

    Target _target;
    Target _selectedTarget;

    UtilityUnit _utilityUnit;

    [SerializeField] List<TeamTag> _enemyTeamMask;


    [SerializeField] [Range(0, 5)] int _maxRange;

    [SerializeField] [Range(0, 5)] float _shootWeight;
    [SerializeField] [Range(0, 5)] float _fleeWeight;
    [SerializeField] [Range(0, 5)] float _engageWeight;

    [SerializeField] LayerMask _obstacleLayer;

    //Sensors
    DistanceSensor _distanceSensor;

    HealthSensor _healthSensor;
    SightSensor _sightSensor;

    private void Start()
    {
        _target = GetComponent<Target>();
        _mover = GetComponent<Mover>();
        _shooter = GetComponent<Shooter>();

        InitializeUtilityUnit();
    }

    public override void ExecuteStep()
    {
        ResetBehaviourComponents();

        var action = _utilityUnit.GetHighestAction();

        Debug.Log("Executing Action: " + action.name);

        action.Execute();
    }


    public void InitializeUtilityUnit()
    {
        _utilityUnit = new UtilityUnit();

        _distanceSensor = new DistanceSensor(_target,_enemyTeamMask, _mover.pathProfile, _maxRange, new LinearUtilityFunction());
        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());
        _sightSensor = new SightSensor(_target,_enemyTeamMask, _obstacleLayer, new ThresholdUtilityFunction(0.5f));

        ShootAction shootAction = new ShootAction(_shooter, "Shoot",() =>
        {
            var value1 = _sightSensor.GetScore();
            var value2 = _distanceSensor.GetScore();
            return value1 * value2 * _shootWeight;
        });

        shootAction.AddPreparationListener(() =>
        {
            //shootAction.SetTarget(_distanceSensor.closestPlayerUnit);
        });

        _utilityUnit.AddAction(shootAction);


        EngageAction engageAction = new EngageAction(_mover, "Shoot Engage", () =>
        {
            var distValue = _distanceSensor.GetScore();
            var sightValue = _sightSensor.GetScore();

            var value = distValue * 0.5f + sightValue * 0.5f + 0.1f;

            return value * _engageWeight;
        });

        engageAction.AddPreparationListener(() =>
        {
            //engageAction.SetTarget(_distanceSensor.closestPlayerUnit.target);
        });
        _utilityUnit.AddAction(engageAction);

        FleeAction fleeAction = new FleeAction(_mover, _mover.pathProfile,"Flee", () =>
         {
             var healthValue = 1 - _healthSensor.GetScore();
             var distanceValue = _distanceSensor.GetScore();

             return healthValue * (healthValue + distanceValue * 4) * _fleeWeight;
         });

        fleeAction.AddPreparationListener(() =>
        {
            //fleeAction.SetTarget(_distanceSensor.closestPlayerUnit.target);
        });

        _utilityUnit.AddAction(fleeAction);
    }

    public void ResetBehaviourComponents()
    {

    }
}
