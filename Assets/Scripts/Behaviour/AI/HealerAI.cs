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

    UtilityUnit _utilityUnit;

    [Header("Settings")]

    [Header("Utility")]
    [SerializeField] [Range(0, 5)] float _meleeWeight;
    [SerializeField] [Range(2, 10)] int _meleeThreshold;
    [SerializeField] [Range(0, 5)] float _healWeight;
    [SerializeField] [Range(0, 5)] float _followWeight;
    [SerializeField] [Range(0, 5)] float _fleeWeight;


    [SerializeField] [Range(0.1f, 1)] float _idleWeight = 0.1f;
    [Tooltip("Percentage of health to be considered low")]
    [SerializeField] [Range(0, 1)] float _lowHealthThreshold;


    //Sensors
    DistanceSensor _allyDistanceSensor;
    DistanceSensor _enemyDistanceSensor;
    LowHealthSensor _lowHealthSensor;
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

        Debug.Log(name + " is executing Action: " + action.name);

        action.Execute();
    }

    public void InitializeUtilityUnit()
    {
        _utilityUnit = new UtilityUnit();

        _allyDistanceSensor = new DistanceSensor(_target, new List<TeamTag>() { _target.teamTag }, _mover.pathProfile, _healer.range, new LinearMinUtilityFunction(0f));
        _enemyDistanceSensor = new DistanceSensor(_target, _actor.team.enemyTags, _mover.pathProfile, _meleeThreshold, new LinearMinUtilityFunction(0.2f));
        _lowHealthSensor = new LowHealthSensor(new List<TeamTag>() { _target.teamTag }, _lowHealthThreshold, new ThresholdUtilityFunction(0.3f));
        _healthSensor = new HealthSensor(_target, new LinearUtilityFunction());

        _utilityUnit.AddAction(GetMeleeTree());
        _utilityUnit.AddAction(GetHealTree());

        #region IDLE
        IdleAction idleAction = new IdleAction(_actor, "Idle", () =>
         {
             return _idleWeight;
         });

        _utilityUnit.AddAction(idleAction);
        #endregion

        #region FOLLOW ALLY
        EngageAction followAction = new EngageAction(_mover, "Follow", () =>
        {
            var allies = _allyDistanceSensor.FindTargetsOfTeam();
            allies.Remove(_target);

            float distanceValue;
            if (allies.Count != 0)
            {
                distanceValue = _allyDistanceSensor.GetScore(_allyDistanceSensor.GetClosestTargetFromList(allies));
            }
            else
            {
                distanceValue = 0;
            }

            return _followWeight * distanceValue;
        });
        followAction.AddPreparationListener(() =>
        {
            var allies = _allyDistanceSensor.FindTargetsOfTeam();
            allies.Remove(_target);

            followAction.SetTarget(_allyDistanceSensor.GetClosestTargetFromList(allies));
        });

        _utilityUnit.AddAction(followAction);

        #endregion

        #region FLEE
        FleeAction fleeAction = new FleeAction(_mover, _mover.pathProfile, "Flee", () =>
         {
             var dangerScore = _enemyDistanceSensor.GetScore();
             var healthScore = 1 - _healthSensor.GetScore();

             var value = Mathf.Pow(healthScore * _fleeWeight, 2) - dangerScore;
             return value;
         });

        fleeAction.AddPreparationListener(() =>
        {
            fleeAction.SetTarget(_enemyDistanceSensor.GetClosestTarget());
        });

        _utilityUnit.AddAction(fleeAction);

        #endregion

    }

    UtilityAction GetMeleeTree()
    {
        BehaviourTreeAction meleeTree = new BehaviourTreeAction("Melee Tree", () =>
        {

            var distanceValue = _enemyDistanceSensor.GetScore();
            if (distanceValue > 1f)
            {
                return 0;
            }
            else
            {
                return _meleeWeight * distanceValue;
            }

        });

        EngageAction engageAction = new EngageAction(_mover, "Melee Engage", () => { return 0; });

        engageAction.AddPreparationListener(() =>
        {
            var target = _enemyDistanceSensor.GetClosestTarget();
            engageAction.SetTarget(target);
        });

        meleeTree.AddAction(() =>
        {
            var closestTarget = _enemyDistanceSensor.GetClosestTarget();
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
            var target = _enemyDistanceSensor.GetClosestTarget();
            meleeAction.SetTarget(target);
        });

        meleeTree.AddAction(() =>
        {
            var closestTarget = _enemyDistanceSensor.GetClosestTarget();
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
        BehaviourTreeAction healTree = new BehaviourTreeAction("Heal Tree", () =>
         {
             var distValue = _allyDistanceSensor.GetScore();
             var lowHealth = _lowHealthSensor.GetScore();

             return distValue * _healWeight * lowHealth;
         });

        EngageAction engageAllyAction = new EngageAction(_mover, "Ally Engage", () => { return 0; });

        engageAllyAction.AddPreparationListener(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = _allyDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            engageAllyAction.SetTarget(target);
        });

        healTree.AddAction(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = this._allyDistanceSensor.GetClosestTargetFromList(lowHealthBots);

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

        HealBotAction healAction = new HealBotAction(_healer, "Heal", () =>
         {
             return 0;
         });

        healAction.AddPreparationListener(() =>
        {
            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = _allyDistanceSensor.GetClosestTargetFromList(lowHealthBots);

            healAction.SetHealTarget(target);
        });

        healTree.AddAction(() =>
        {

            var lowHealthBots = _lowHealthSensor.GetLowHealthBots();
            var target = this._allyDistanceSensor.GetClosestTargetFromList(lowHealthBots);

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
