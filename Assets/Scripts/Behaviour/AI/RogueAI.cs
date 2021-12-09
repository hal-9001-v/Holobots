using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Mover))]
[RequireComponent(typeof(Meleer))]
public class RogueAI: Bot, IUtilityAI
{
    TurnActor _actor;

    Mover _mover;
    Meleer _meleer;

    Target _target;

    UtilityUnit _utilityUnit;

    [Header("Settings")]

    [SerializeField] List<TeamTag> _enemyTeamMask;

    [Header("Utility")]
    [SerializeField] [Range(0, 5)] float _meleeWeight;
    [SerializeField] [Range(0, 5)] int _fleeWeight;
    [SerializeField] [Range(2, 10)] int _meleeThreshold;

    [SerializeField] [Range(0.1f, 1)] float _idleWeight = 0.1f;

    //Sensors
    DistanceSensor _distanceSensor;
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

        _distanceSensor = new DistanceSensor(_target, _enemyTeamMask, _mover.pathProfile, _meleeThreshold, new LinearMinUtilityFunction(0.2f));
        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());

        #region MELEE TREE
        BehaviourTreeAction meleeTree = new BehaviourTreeAction("Melee Tree",() =>
        {
            var distValue = _distanceSensor.GetScore();
            return _meleeWeight * distValue;
        });

        EngageAction engageAction = new EngageAction(_mover,"Melee Engage", () => { return 0; });

        engageAction.AddPreparationListener(() =>
        {
            var target = _distanceSensor.GetClosestTarget();
            engageAction.SetTarget(target);
        });

        meleeTree.AddAction(() =>
        {
            var closestTarget = _distanceSensor.GetClosestTarget();
            int distance = _mover.DistanceToTarget(closestTarget.currentGroundTile);

            if (distance > _meleer.meleeRange)
            {
                engageAction.Execute();
                return true;
            }

            return false;
        });

        MeleeAction meleeAction = new MeleeAction(_meleer, "Melee",() => { return 0; });

        meleeAction.AddPreparationListener(() =>
        {
            var target = _distanceSensor.GetClosestTarget();
            meleeAction.SetTarget(target);
        });

        meleeTree.AddAction(() =>
        {
            var closestTarget = _distanceSensor.GetClosestTarget();
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


        #region FLEE
        FleeAction fleeAction = new FleeAction(_mover, _mover.pathProfile, "Flee",() =>
        {
            var dangerScore = _distanceSensor.GetScore();
            var healthScore = 1 - _healthSensor.GetScore();

            return (dangerScore * 0.2f + healthScore * 0.8f) * _fleeWeight;
        });
        fleeAction.AddPreparationListener(() =>
        {
            fleeAction.SetTarget(_distanceSensor.GetClosestTarget());
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
