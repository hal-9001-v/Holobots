using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Shooter))]
[RequireComponent(typeof(TurnActor))]
[RequireComponent(typeof(Mover))]
public class Turret : Bot
{
    [Header("Settings")]
    [SerializeField] List<TeamTag> _enemyTeamMask;
    [SerializeField] LayerMask _obstacleLayers;

    [SerializeField] [Range(0, 10)] int _maxRange;

    Shooter _shooter;
    Target _target;
    TurnActor _actor;
    Mover _mover;

    DistanceSensor _distanceSensor;
    SightSensor _sightSensor;

    FSMachine _machine;

    private void Start()
    {
        _shooter = GetComponent<Shooter>();
        _mover = GetComponent<Mover>();
        _target = GetComponent<Target>();
        _actor = GetComponent<TurnActor>();

        InitializeFSM();

    }

    public override void ExecuteStep()
    {
        _machine.Update();
    }

    public void InitializeFSM()
    {
        _distanceSensor = new DistanceSensor(_target, _enemyTeamMask, _mover.pathProfile, _maxRange, new ThresholdUtilityFunction(1f));
        _sightSensor = new SightSensor(_target,_enemyTeamMask, _obstacleLayers, new ThresholdUtilityFunction(0.5f));

        ShootAction shootAction = new ShootAction(_shooter, "Shoot", () => { return -1; });

        shootAction.AddPreparationListener(() =>
        {
            var targets = _sightSensor.GetTargetsOnSight(_enemyTeamMask);

            shootAction.SetTarget(targets[0]);

        });

        IdleAction idleAction = new IdleAction(_actor, "Idle", () => { return -1; });

        FSMState idleState = new FSMState("Idle State", () =>
         {
             return true;
         },
        () =>
        {
            idleAction.Execute();
        });

        FSMState checkForTarget = new FSMState("Check State", () =>
         {
             return true;
         },
        () =>
        {
            _machine.Update();
        });


        FSMState shootTarget = new FSMState("Shoot State", () =>
         {
             var distanceValue = _distanceSensor.GetScore();

             if (distanceValue == 1)
             {
                 var targets = _sightSensor.GetTargetsOnSight(_enemyTeamMask);

                 if (targets.Count != 0)
                 {
                     return true;
                 }

             }

             return false;
         },
        () =>
        {
            shootAction.Execute();
        });

        FSMState reloadState = new FSMState("Reload State", () =>
         {
             return true;
         },
        () =>
        {
            idleAction.Execute();
        });

        _machine = new FSMachine(checkForTarget);

        idleState.children.Add(checkForTarget);

        checkForTarget.children.Add(shootTarget);
        checkForTarget.children.Add(idleState);

        shootTarget.children.Add(reloadState);

        reloadState.children.Add(checkForTarget);


        /*
        IdleAction idleAction = new IdleAction(() =>
        {
            return (1 - _distanceSensor.GetScore() * _idleWeight);
        });
        _utilityUnit.AddAction(idleAction);
        */
    }

}
