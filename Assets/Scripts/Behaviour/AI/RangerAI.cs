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
    [SerializeField] [Range(0, 5)] float _fleeWeight;
    [SerializeField] [Range(0, 5)] float _idleWeight;

    //Sensors
    DistanceSensor _distanceSensor;
    HealthSensor _healthSensor;
    SightSensor _sightSensor;
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

        Debug.Log(name + " is executing Action: " + action.name);

        action.Execute();
    }

    public void InitializeUtilityUnit()
    {
        _utilityUnit = new UtilityUnit();

        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());
        _groupSensor = new GroupSensor(actor.team.enemyTags, new List<TeamTag>() { _target.teamTag }, 0.4f, -0.2f, _explosioner.explosionRange, new LinearUtilityFunction());
        _distanceSensor = new DistanceSensor(_target, actor.team.enemyTags, _mover.pathProfile, 6, new LinearUtilityFunction());
        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());
        _sightSensor = new SightSensor(_target, actor.team.enemyTags, _obstacleMask, new ThresholdUtilityFunction(0.9f));

        _distanceToTankSensor = new DistanceSensor(_target, TargetType.Tank, new List<TeamTag>() { _target.teamTag }, _mover.pathProfile, 4, new ThresholdUtilityFunction(1));

        _utilityUnit.AddAction(GetShootTree());
        _utilityUnit.AddAction(GetExplosionerTree());
        _utilityUnit.AddAction(GetEngangeAllyAction());


        #region IDLE
        IdleAction idleAction = new IdleAction(actor, "Idle", () =>
         {
             return _idleWeight;
         });

        _utilityUnit.AddAction(idleAction);
        #endregion


        #region FLEE
        FleeAction fleeAction = new FleeAction(_mover, _mover.pathProfile, "Flee", () =>
         {
             var dangerScore = 1 - _distanceSensor.GetScore();
             var healthScore = 1 - _healthSensor.GetScore();

             return (dangerScore * 0.5f + healthScore * 0.5f) * _fleeWeight;
         });
        fleeAction.AddPreparationListener(() =>
        {
            fleeAction.SetTarget(_distanceSensor.GetClosestTarget());
        });

        _utilityUnit.AddAction(fleeAction);

        #endregion
    }

    UtilityAction GetShootTree()
    {
        BehaviourTreeAction shootTree = new BehaviourTreeAction("Shoot Tree", () =>
         {
             var shootValue = _sightSensor.GetScore();
             if (actor.currentTurnPoints == 1 && shootValue == 0)
             {
                 return _shootWeight * 0.05f;
             }


             var dangerValue = _distanceSensor.GetScore();
             if (dangerValue < 1)
             {
                 dangerValue = 1 - dangerValue;
                 dangerValue = -dangerValue * 2;
             }
             else
             {
                 dangerValue = Mathf.Sign(dangerValue) * Mathf.Pow(dangerValue, 2);
             }



             return shootValue * _shootWeight + _shootWeight * 0.2f + dangerValue;
         });

        #region ENGAGE

        EngageAction engageAction = new EngageAction(_mover, "Shoot Engage", () => { return 0; });

        engageAction.AddPreparationListener(() =>
        {
            engageAction.SetTarget(_distanceSensor.GetClosestTarget());
        });

        shootTree.AddAction(() =>
        {
            if (_sightSensor.GetScore() == 0)
            {
                engageAction.Execute();
                return true;
            }
            return false;
        });

        #endregion

        #region SHOOT
        ShootAction shootAction = new ShootAction(_shooter, "Shoot", () => { return 0; });

        shootAction.AddPreparationListener(() =>
        {
            var targets = _sightSensor.GetTargetsOnSight(actor.team.enemyTags);

            var closestTarget = _distanceSensor.GetClosestTargetFromList(targets);

            shootAction.SetTarget(closestTarget);
        });

        shootTree.AddAction(() =>
        {
            if (_sightSensor.GetScore() != 0)
            {
                shootAction.Execute();
                return true;
            }

            return false;
        });
        #endregion

        return shootTree;
    }

    UtilityAction GetExplosionerTree()
    {
        BehaviourTreeAction explosionerTree = new BehaviourTreeAction("Explosion Tree", () =>
         {

             var explosionValue = _groupSensor.GetScore();

             if (explosionValue >= 1)
             {
                 var groupedTargets = _groupSensor.GetGroupedTargets();
                 var distanceValue = 2 - _distanceSensor.GetScore(_distanceSensor.GetClosestTargetFromList(groupedTargets));

                 return distanceValue * explosionValue * _explosionerWeight;
             }

             return explosionValue;

         });

        #region ENGAGE
        EngageAction engageAction = new EngageAction(_mover, "Explosion Engage", () => { return 0; });

        engageAction.AddPreparationListener(() =>
        {
            var targets = _groupSensor.GetGroupedTargetsOfTeam(actor.team.enemyTags);

            var closestTarget = _distanceSensor.GetClosestTargetFromList(targets);

            engageAction.SetTarget(closestTarget);
        });

        explosionerTree.AddAction(() =>
        {
            var targets = _groupSensor.GetGroupedTargetsOfTeam(actor.team.enemyTags);

            var closestTarget = _distanceSensor.GetClosestTargetFromList(targets);

            if (_mover.DistanceToTarget(closestTarget.currentGroundTile) > _explosioner.exploderRange)
            {
                engageAction.Execute();
                return true;
            }

            return false;
        });
        #endregion

        #region EXPLOSION

        ExplosionAction explosionAction = new ExplosionAction(_explosioner, "Launch Explosion", () => { return 0; });

        explosionAction.AddPreparationListener(() =>
        {
            var targets = _groupSensor.GetGroupedTargets();

            var closestTarget = _distanceSensor.GetClosestTargetFromList(targets);

            explosionAction.SetTarget(closestTarget.currentGroundTile);
        });

        explosionerTree.AddAction(() =>
       {
           var targets = _groupSensor.GetGroupedTargetsOfTeam(actor.team.enemyTags);

           var closestTarget = _distanceSensor.GetClosestTargetFromList(targets);

           if (_mover.DistanceToTarget(closestTarget.currentGroundTile) <= _explosioner.exploderRange)
           {
               explosionAction.Execute();
               return true;
           }

           return false;
       });
        #endregion

        return explosionerTree;
    }

    UtilityAction GetEngangeAllyAction()
    {
        EngageAction engangeAlly = new EngageAction(_mover, "Ally Engage", () =>
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
