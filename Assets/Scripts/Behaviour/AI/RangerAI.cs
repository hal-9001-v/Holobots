using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Mover))]
[RequireComponent(typeof(Shooter))]
[RequireComponent(typeof(Explosioner))]

public class RangerAI : Bot, IUtilityAI
{
    Mover _mover;
    Shooter _shooter;
    Explosioner _explosioner;

    Target _target;

    UtilityUnit _utilityUnit;

    [Header("Settings")]

    [SerializeField] LayerMask _obstacleMask;

    [Header("Utility")]
    [SerializeField] [Range(0, 5)] float _shootWeight;
    [SerializeField] [Range(0, 5)] float _engageAllyWeight;
    [SerializeField] [Range(0, 5)] float _explosionerWeight;


    //Sensors
    DistanceSensor _distanceSensor;
    HealthSensor _healthSensor;
    SightToPlayerUnitSensor _sightSensor;
    GroupSensor _groupSensor;

    DistanceSensor _distanceToTankSensor;


    private void Start()
    {
        _target = GetComponent<Target>();
        _mover = GetComponent<Mover>();
        _shooter = GetComponent<Shooter>();
        _explosioner = GetComponent<Explosioner>();

        InitializeUtilityUnit();
    }

    public override void ExecuteStep()
    {
        ResetBehaviourComponents();

        var action = _utilityUnit.GetHighestAction();

        Debug.Log(name + " is executing Action: " + action.GetType().ToString());

        action.Execute();
    }

    public void InitializeUtilityUnit()
    {
        _utilityUnit = new UtilityUnit();

        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());
        _groupSensor = new GroupSensor(TeamTag.Player, 0.4f, -0.2f, _explosioner.explosionRange, new LinearUtilityFunction());
        _distanceSensor = new DistanceSensor(_target, TeamTag.Player, _mover.pathProfile, 5, new ThresholdUtilityFunction(0.9f));
        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());
        _sightSensor = new SightToPlayerUnitSensor(_target, _obstacleMask, new ThresholdUtilityFunction(0.9f));

        _distanceToTankSensor = new DistanceSensor(_target, TargetType.Tank, TeamTag.AI, _mover.pathProfile, 4, new ThresholdUtilityFunction(1));

        _utilityUnit.AddAction(GetShootTree());
        _utilityUnit.AddAction(GetExplosionerTree());
        _utilityUnit.AddAction(GetEngangeAllyAction());

    }

    UtilityAction GetShootTree()
    {
        BehaviourTreeAction shootTree = new BehaviourTreeAction(() =>
        {
            var shootValue = _sightSensor.GetScore();

            return (shootValue + 0.5f) * _shootWeight;
        });

        #region ENGAGE

        EngageAction engageAction = new EngageAction(_mover, () => { return 0; });

        engageAction.AddPreparationListener(() =>
        {
            engageAction.SetTarget(_distanceSensor.GetClosestTarget());
        });

        shootTree.AddAction(engageAction, () =>
        {
            if (_sightSensor.GetScore() == 0)
            {
                return true;
            }
            return false;
        });

        #endregion

        #region SHOOT
        ShootAction shootAction = new ShootAction(_shooter, () => { return 0; });

        shootAction.AddPreparationListener(() =>
        {
            var targets = _sightSensor.GetTargetsOnSight(TeamTag.Player);

            var closestTarget = _distanceSensor.GetClosestTargetFromList(targets);

            shootAction.SetTarget(closestTarget);
        });

        shootTree.AddAction(shootAction, () =>
        {
            if (_sightSensor.GetScore() != 0)
            {
                return true;
            }

            return false;
        });
        #endregion

        return shootTree;
    }

    UtilityAction GetExplosionerTree()
    {
        BehaviourTreeAction explosionerTree = new BehaviourTreeAction(() =>
        {
            var explosionValue = _groupSensor.GetScore();

            return explosionValue * _explosionerWeight;
        });

        #region ENGAGE
        EngageAction engageAction = new EngageAction(_mover, () => { return 0; });

        engageAction.AddPreparationListener(() =>
        {
            var targets = _groupSensor.GetGroupedTargetsWithTag(TeamTag.Player);

            var closestTarget = _distanceSensor.GetClosestTargetFromList(targets);

            engageAction.SetTarget(closestTarget);
        });

        explosionerTree.AddAction(engageAction, () =>
        {
            var targets = _groupSensor.GetGroupedTargetsWithTag(TeamTag.Player);

            var closestTarget = _distanceSensor.GetClosestTargetFromList(targets);

            if (_mover.DistanceToTarget(closestTarget.currentGroundTile) > _explosioner.exploderRange)
            {
                return true;
            }

            return false;
        });
        #endregion

        #region EXPLOSION

        ExplosionAction explosionAction = new ExplosionAction(_explosioner, () => { return 0; });

        explosionAction.AddPreparationListener(() =>
        {
            var targets = _groupSensor.GetGroupedTargets();

            var closestTarget = _distanceSensor.GetClosestTargetFromList(targets);

            explosionAction.SetTarget(closestTarget.currentGroundTile);
        });

        explosionerTree.AddAction(explosionAction, () =>
        {
            var targets = _groupSensor.GetGroupedTargetsWithTag(TeamTag.Player);

            var closestTarget = _distanceSensor.GetClosestTargetFromList(targets);

            if (_mover.DistanceToTarget(closestTarget.currentGroundTile) <= _explosioner.exploderRange)
            {
                return true;
            }

            return false;
        });
        #endregion

        return explosionerTree;
    }

    UtilityAction GetEngangeAllyAction()
    {
        EngageAction engangeAlly = new EngageAction(_mover, () =>
        {
            var healthScore = 1 - _healthSensor.GetScore();
            var distanceToTankScore = _distanceToTankSensor.GetScore();

            return healthScore * distanceToTankScore * _engageAllyWeight;
        });

        engangeAlly.AddPreparationListener(() =>
        {
            var tanks = _distanceToTankSensor.FindTargetWithTag(TargetType.Tank);
            var tank = _distanceToTankSensor.GetClosestTargetFromList(tanks);

            engangeAlly.SetTarget(tank);

        });

        return engangeAlly;

    }

    public void ResetBehaviourComponents()
    {

    }
}
