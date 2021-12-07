using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Mover))]
[RequireComponent(typeof(Meleer))]
public class HealerAI : Bot, IUtilityAI
{
    TurnActor _actor;

    Healer _healer;

    Mover _mover;
    Meleer _meleer;

    Target _target;
    Target _selectedTarget;

    UtilityUnit _utilityUnit;

    [Header("Settings")]

    [Header("Utility")]
    [SerializeField] [Range(0, 5)] float _meleeWeight;
    [SerializeField] [Range(2, 10)] int _meleeThreshold;
    [SerializeField] [Range(0, 5)] float _healWeight;


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

        _healer = GetComponent<Healer>();

        _target = GetComponent<Target>();
        _mover = GetComponent<Mover>();
        _meleer = GetComponent<Meleer>();

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

        _botDistanceSensor = new DistanceSensor(_target, TeamTag.AI, _mover.pathProfile, _healer.range, new LinearMinUtilityFunction(0.2f));
        _playerUnitDistanceSensor = new DistanceSensor(_target, TeamTag.Player, _mover.pathProfile, _meleeThreshold, new LinearMinUtilityFunction(0.2f));
        _lowHealthSensor = new LowHealthBotSensor(_lowHealthThreshold, new ThresholdUtilityFunction(0.3f));
        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());

        _utilityUnit.AddAction(GetMeleeTree());
        _utilityUnit.AddAction(GetHealTree());

        #region IDLE
        IdleAction idleAction = new IdleAction(_actor, () =>
         {
             return _idleWeight;
         });

        _utilityUnit.AddAction(idleAction);
        #endregion
    }

    UtilityAction GetMeleeTree()
    {
        BehaviourTreeAction meleeTree = new BehaviourTreeAction(() =>
        {
            var distValue = _playerUnitDistanceSensor.GetScore();
            return _meleeWeight * distValue;
        });

        EngageAction engageAction = new EngageAction(_mover, () => { return 0; });

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

        MeleeAction meleeAction = new MeleeAction(_meleer, () => { return 0; });

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

        return meleeTree;
    }

    UtilityAction GetHealTree()
    {
        BehaviourTreeAction healTree = new BehaviourTreeAction(() =>
        {
            var distValue = _botDistanceSensor.GetScore();
            var lowHealth = _lowHealthSensor.GetScore();

            return distValue * _healWeight * lowHealth;
        });

        EngageAction engageAllyAction = new EngageAction(_mover, () => { return 0; });

        engageAllyAction.AddPreparationListener(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = _botDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            engageAllyAction.SetTarget(target);
        });

        healTree.AddAction(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = this._botDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            if (target)
            {
                var distance = _mover.DistanceToTarget((GroundTile)target.currentGroundTile);
                if (distance > _healer.range)
                {
                    engageAllyAction.Execute();
                    return true;
                }
            }

            return false;
        });

        HealBotAction healAction = new HealBotAction(_healer, () =>
        {
            return 0;
        });

        healAction.AddPreparationListener(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = _botDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            healAction.SetHealTarget(target);
        });

        healTree.AddAction(() =>
        {

            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = this._botDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            if (target)
            {
                if (_mover.DistanceToTarget((GroundTile)target.currentGroundTile) <= _healer.range)
                {
                    healAction.Execute();
                    return true;
                }
            }

            return false;
        });

        return healTree;
    }

    public void ResetBehaviourComponents()
    {

    }
}
