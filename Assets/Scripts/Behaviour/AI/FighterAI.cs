using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Mover))]
[RequireComponent(typeof(Meleer))]
public class FighterAI : Bot, IUtilityAI
{
    TurnActor _actor;

    Mover _mover;
    Meleer _meleer;

    Target _target;

    UtilityUnit _utilityUnit;

    [Header("Settings")]

    [Header("Utility")]
    [SerializeField] [Range(0, 5)] float _meleeWeight;
    [SerializeField] [Range(2, 10)] int _meleeThreshold;

    [SerializeField] [Range(0.1f, 1)] float _idleWeight = 0.1f;
    [SerializeField] [Range(0.1f, 3)] float _fleeWeight = 0.1f;

    //Sensors
    DistanceSensor _playerUnitDistanceSensor;
    HealthSensor _healthSensor;

    private void Start()
    {
        _actor = GetComponent<TurnActor>();

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

        _playerUnitDistanceSensor = new DistanceSensor(_target, TeamTag.Player, _mover.pathProfile, _meleeThreshold, new LinearMinUtilityFunction(0.2f));
        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());

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
             if (_actor.currentTurnPoints == 1) return _idleWeight * 2;

             return _idleWeight;
         });

        _utilityUnit.AddAction(idleAction);
        #endregion

        _utilityUnit.AddAction(GetMeleeTree());
    }

    public BehaviourTreeAction GetMeleeTree()
    {
        BehaviourTreeAction meleeTree = new BehaviourTreeAction("Melee Tree", () =>
        {
            var distValue = _playerUnitDistanceSensor.GetScore();
            return _meleeWeight * distValue + _meleeWeight;
        });

        #region MELEE
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
        #endregion

        #region ENGAGE
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
        #endregion

        return meleeTree;

    }

    public void ResetBehaviourComponents()
    {

    }
}
