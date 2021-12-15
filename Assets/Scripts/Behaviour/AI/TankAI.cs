using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Mover))]
[RequireComponent(typeof(Shielder))]
[RequireComponent(typeof(Meleer))]
public class TankAI : Bot, IUtilityAI
{
    TurnActor _actor;

    Shielder _shielder;

    Mover _mover;
    Meleer _meleer;

    Target _target;

    UtilityUnit _utilityUnit;

    [Header("Settings")]
    [Header("Utility")]
    [SerializeField] [Range(0, 5)] float _shieldWeight;
    [SerializeField] [Range(0, 5)] float _fleeWeight;
    [SerializeField] [Range(0, 5)] float _meleeWeight;
    [SerializeField] [Range(2, 10)] int _meleeThreshold;



    [SerializeField] [Range(0.1f, 1)] float _idleWeight = 0.1f;
    [Tooltip("Percentage of health to be considered low")]
    [SerializeField] [Range(0, 1)] float _lowHealthThreshold;


    //Sensors
    DistanceSensor _allyDistanceSensor;
    DistanceSensor _enemyDistanceSensor;
    DistanceSensor _shieldEnemyDistanceSensor;
    LowHealthSensor _lowHealthSensor;
    HealthSensor _healthSensor;


    private void Start()
    {
        _actor = GetComponent<TurnActor>();

        _shielder = GetComponent<Shielder>();

        _target = GetComponent<Target>();
        _mover = GetComponent<Mover>();
        _meleer = GetComponent<Meleer>();



        InitializeUtilityUnit();
    }

    public override void ExecuteStep()
    {
        ResetBehaviourComponents();

        var action = _utilityUnit.GetHighestAction();

        Debug.Log(name + "is executing Action: " + action.name);

        action.Execute();
    }

    public void InitializeUtilityUnit()
    {
        _utilityUnit = new UtilityUnit();

        _allyDistanceSensor = new DistanceSensor(_target, new List<TeamTag>() { _target.teamTag }, _mover.pathProfile, _shielder.maxShieldRange, new LinearMinUtilityFunction(0.2f));
        _enemyDistanceSensor = new DistanceSensor(_target, _actor.team.enemyTags, _mover.pathProfile, _meleeThreshold, new LinearMinUtilityFunction(0.2f));

        _shieldEnemyDistanceSensor = new DistanceSensor(_target, _actor.team.enemyTags, _mover.pathProfile, 1, new ThresholdUtilityFunction(1f));

        _lowHealthSensor = new LowHealthSensor(new List<TeamTag>() { _target.teamTag }, _lowHealthThreshold, new LinearUtilityFunction());
        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());

        #region FLEE
        FleeAction fleeAction = new FleeAction(_mover, _mover.pathProfile, "Flee", () =>
         {
             if (_target.currentGroundTile.shield) return 0;

             var dangerScore = _enemyDistanceSensor.GetScore();
             var healthScore = 1 - _healthSensor.GetScore();

             return (dangerScore * 0.2f + healthScore * 0.8f) * _fleeWeight;
         });
        fleeAction.AddPreparationListener(() =>
        {
            fleeAction.SetTarget(_enemyDistanceSensor.GetClosestTarget());
        });

        _utilityUnit.AddAction(fleeAction);

        #endregion

        #region IDLE
        IdleAction idleAction = new IdleAction(_actor, "Idle", () =>
         {
             return _idleWeight;
         });

        _utilityUnit.AddAction(idleAction);

        #endregion

        #region SHIELDED MELEE
        MeleeAction shieldedMeleeAction = new MeleeAction(_meleer, "Shielded Melee", () =>
        {
            if (!_target.currentGroundTile.shield) return 0;

            var meleeScore = _shieldEnemyDistanceSensor.GetScore();

            return meleeScore * _meleeWeight;

        });
        shieldedMeleeAction.AddPreparationListener(() =>
        {
            var target = _shieldEnemyDistanceSensor.GetClosestTarget();

            shieldedMeleeAction.SetTarget(target);
        });
        #endregion

        _utilityUnit.AddAction(shieldedMeleeAction);

        _utilityUnit.AddAction(GetMeleeTree());
        _utilityUnit.AddAction(GetShieldTree());
    }

    BehaviourTreeAction GetMeleeTree()
    {
        BehaviourTreeAction meleeTree = new BehaviourTreeAction("Melee Tree", () =>
        {
            var distValue = _enemyDistanceSensor.GetScore();
            return _meleeWeight * distValue;
        });

        #region MELEE
        MeleeAction meleeAction = new MeleeAction(_meleer, "Melee", () => { return 0; });

        meleeAction.AddPreparationListener(() =>
        {
            var target = _enemyDistanceSensor.GetClosestTarget();
            meleeAction.SetTarget(target);
        });

        Func<bool> meleeFunc = () =>
        {
            var closestTarget = _enemyDistanceSensor.GetClosestTarget();
            int distance = _mover.DistanceToTarget(closestTarget.currentGroundTile);

            if (distance <= _meleer.meleeRange)
            {
                meleeAction.Execute();
                return true;
            }

            return false;
        };

        meleeTree.AddAction(meleeFunc);
        #endregion

        #region SHIELD
        ShieldBotAction shieldAction = new ShieldBotAction(_shielder, "Shield", () =>
        {
            return 0;
        });

        shieldAction.AddPreparationListener(() =>
        {
            shieldAction.SetShieldTarget(_target);
        });

        Func<bool> shieldFunc = () =>
        {
            if (_actor.currentTurnPoints == 1)
            {
                shieldAction.Execute();
                return true;
            }

            return false;
        };

        meleeTree.AddAction(shieldFunc);
        #endregion

        #region ENGAGE
        EngageAction engageAction = new EngageAction(_mover, "Melee Engage", () => { return 0; });

        engageAction.AddPreparationListener(() =>
        {
            var target = _enemyDistanceSensor.GetClosestTarget();
            engageAction.SetTarget(target);
        });

        Func<bool> engageFunc = () =>
        {
            engageAction.Execute();
            return true;
        };

        meleeTree.AddAction(engageFunc);
        #endregion


        return meleeTree;
    }

    BehaviourTreeAction GetShieldTree()
    {
        BehaviourTreeAction shieldTree = new BehaviourTreeAction("Shield Tree", () =>
        {
            if (_target.currentGroundTile.shield) return 0;

            var distValue = _allyDistanceSensor.GetScore();
            var lowHealth = _lowHealthSensor.GetScore();

            float dangerScore = 0;

            foreach (var unit in _lowHealthSensor.GetLowHealthBots())
            {

                var auxScore = _enemyDistanceSensor.GetScore(unit);

                if (auxScore > dangerScore)
                {
                    dangerScore = auxScore;
                }
            }


            return distValue * _shieldWeight * lowHealth * dangerScore;
        });

        EngageAction engageAllyAction = new EngageAction(_mover, "Shield Engage", () => { return 0; });

        engageAllyAction.AddPreparationListener(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = _allyDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            engageAllyAction.SetTarget(target);
        });


        shieldTree.AddAction(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = this._allyDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            if (target)
            {
                if (_mover.DistanceToTarget((GroundTile)target.currentGroundTile) > _shielder.maxShieldRange)
                {
                    engageAllyAction.Execute();
                    return true;
                }
            }

            return false;
        });

        ShieldBotAction shieldAction = new ShieldBotAction(_shielder, "Shield", () =>
        {
            return 0;
        });

        shieldAction.AddPreparationListener(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = _allyDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            shieldAction.SetShieldTarget(target);
        });

        shieldTree.AddAction(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = this._allyDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            if (target)
            {
                if (_mover.DistanceToTarget((GroundTile)target.currentGroundTile) <= _shielder.maxShieldRange)
                {
                    shieldAction.Execute();
                    return true;
                }
            }

            return false;
        });

        return shieldTree;
    }

    public void ResetBehaviourComponents()
    {

    }
}
