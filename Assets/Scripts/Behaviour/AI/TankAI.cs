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
    DistanceSensor _botDistanceSensor;
    DistanceSensor _playerUnitDistanceSensor;
    LowHealthBotSensor _lowHealthSensor;
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

        _botDistanceSensor = new DistanceSensor(_target, TeamTag.AI, _mover.pathProfile, _shielder.maxShieldRange, new LinearMinUtilityFunction(0.2f));
        _playerUnitDistanceSensor = new DistanceSensor(_target, TeamTag.Player, _mover.pathProfile, _meleeThreshold, new LinearMinUtilityFunction(0.2f));
        _lowHealthSensor = new LowHealthBotSensor(_lowHealthThreshold, new LinearUtilityFunction());
        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());

        #region MELEE TREE
        BehaviourTreeAction meleeTree = new BehaviourTreeAction("Melee Tree", () =>
         {
             var distValue = _playerUnitDistanceSensor.GetScore();
             return _meleeWeight * distValue;
         });

        EngageAction engageAction = new EngageAction(_mover, "Melee Engage", () => { return 0; });

        engageAction.AddPreparationListener(() =>
        {
            var target = _playerUnitDistanceSensor.GetClosestTarget();
            engageAction.SetTarget(target);
        });

        meleeTree.AddAction(() =>
        {
            var closestTarget = _playerUnitDistanceSensor.GetClosestTarget();
            int distance = _mover.DistanceToTarget(closestTarget.currentGroundTile);

            if (distance > _meleer.meleeRange)
            {
                engageAction.Execute();
                return true;
            }

            return false;
        });

        MeleeAction meleeAction = new MeleeAction(_meleer, "Melee", () => { return 0; });

        meleeAction.AddPreparationListener(() =>
        {
            var target = _playerUnitDistanceSensor.GetClosestTarget();
            meleeAction.SetTarget(target);
        });

        meleeTree.AddAction(() =>
        {
            var closestTarget = _playerUnitDistanceSensor.GetClosestTarget();
            int distance = _mover.DistanceToTarget(closestTarget.currentGroundTile);

            if (distance <= _meleer.meleeRange)
            {
                meleeAction.Execute();
                return true;
            }

            return false;
        });

        _utilityUnit.AddAction(meleeTree);

        #endregion

        #region SHIELD TREE

        BehaviourTreeAction shieldTree = new BehaviourTreeAction("Shield Tree", () =>
         {
             var distValue = _botDistanceSensor.GetScore();
             var lowHealth = _lowHealthSensor.GetScore();

             return distValue * _shieldWeight * lowHealth;
         });

        EngageAction engageAllyAction = new EngageAction(_mover, "Shield Engage", () => { return 0; });

        engageAllyAction.AddPreparationListener(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = _botDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            engageAllyAction.SetTarget(target);
        });


        shieldTree.AddAction(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = this._botDistanceSensor.GetClosestTargetFromList(lowHealthBots);

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

        ShieldBotAction shieldAction = new ShieldBotAction(_shielder,"Shield", () =>
        {
            return 0;
        });

        shieldAction.AddPreparationListener(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = _botDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            shieldAction.SetShieldTarget(target);
        });

        shieldTree.AddAction(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = this._botDistanceSensor.GetClosestTargetFromList(lowHealthBots);

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

        _utilityUnit.AddAction(shieldTree);

        #endregion

        #region FLEE
        FleeAction fleeAction = new FleeAction(_mover, _mover.pathProfile, "Flee", () =>
         {
             var dangerScore = _playerUnitDistanceSensor.GetScore();
             var healthScore = 1 - _healthSensor.GetScore();

             return (dangerScore * 0.2f + healthScore * 0.8f) * _fleeWeight;
         });
        fleeAction.AddPreparationListener(() =>
        {
            fleeAction.SetTarget(_playerUnitDistanceSensor.GetClosestTarget());
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
    }

    public void ResetBehaviourComponents()
    {

    }
}
