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

    [SerializeField] [Range(0, 5)] int _maxRange;

    [SerializeField] [Range(0, 5)] float _shootWeight;
    [SerializeField] [Range(0, 5)] float _fleeWeight;
    [SerializeField] [Range(0, 5)] float _engageWeight;

    [SerializeField] LayerMask _obstacleLayer;


    //Sensors
    DistanceToPlayerUnitSensor _distanceSensor;
    HealthSensor _healthSensor;
    SightToPlayerUnitSensor _sightSensor;

    private void Awake()
    {
        _target = GetComponent<Target>();
        _mover = GetComponent<Mover>();
        _shooter = GetComponent<Shooter>();

        InitializeUtilityUnit();
    }



    private void Start()
    {
        _target.dieAction += Dead;
    }

    public override void PrepareSteps()
    {
        ResetBehaviourComponents();

        var action = _utilityUnit.GetHighestAction();

        action.Execute();

    }

    void Dead()
    {
        foreach (var renderer in GetComponentsInChildren<Renderer>())
        {
            renderer.enabled = false;
        }

        foreach (var collider in GetComponentsInChildren<Collider>())
        {
            collider.enabled = false;
        }
    }

    public override TurnPreview[] GetPossibleMoves()
    {
        /*
        int range = 4;

        var moves = _mover.GetTilesInMaxRange(range);

        TurnPreview[] preview = new TurnPreview[moves.Count];

        for (int i = 0; i < moves.Count; i++)
        {
            preview[i] = new TurnPreview();
            preview[i].position = moves[i];
        }
        */
        return null;

    }

    public override MinMaxWeights GetMinMaxWeights()
    {
        throw new System.NotImplementedException();
    }

    public void InitializeUtilityUnit()
    {
        _utilityUnit = new UtilityUnit();

        _distanceSensor = new DistanceToPlayerUnitSensor(_target,_mover.pathProfile, _maxRange, new LinearUtilityFunction());
        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());
        _sightSensor = new SightToPlayerUnitSensor(_target, _obstacleLayer, new ThresholdUtilityFunction(0.5f));

        ShootPlayerUnitAction shootAction = new ShootPlayerUnitAction(_shooter, () =>
        {
            var value1 = _sightSensor.GetScore();
            var value2 = _distanceSensor.GetScore();
            return value1 * value2 * _shootWeight;
        });

        shootAction.AddPreparationListener(() =>
        {
            shootAction.SetTarget(_distanceSensor.closestPlayerUnit);
        });

        _utilityUnit.AddAction(shootAction);


        EngageAction engageAction = new EngageAction(_mover, () =>
        {
            var value = (1 - _distanceSensor.GetScore()) * 0.5f + _sightSensor.GetScore() * 0.5f;
            return value * _engageWeight;
        });

        engageAction.AddPreparationListener(() =>
        {
            engageAction.SetTarget(_distanceSensor.closestPlayerUnit);
        });
        _utilityUnit.AddAction(engageAction);

        FleeAction fleeAction = new FleeAction(_mover,_mover.pathProfile, () =>
        {
            var healthValue = 1 - _healthSensor.GetScore();
            var distanceValue = _distanceSensor.GetScore();
            return healthValue * (healthValue + distanceValue * 4) * _fleeWeight;
        });

        fleeAction.AddPreparationListener(() =>
        {
            fleeAction.SetTarget(_distanceSensor.closestPlayerUnit.target);
        });

        _utilityUnit.AddAction(fleeAction);

    }

    public void ResetBehaviourComponents()
    {
        _mover.ResetSteps();
        _shooter.ResetSteps();
    }
}
