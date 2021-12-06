using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Shooter))]
[RequireComponent(typeof(TurnActor))]
[RequireComponent(typeof(Mover))]
public class Turret : Bot
{
    [Header("Settings")]
    [SerializeField] LayerMask _obstacleLayers;

    [SerializeField] [Range(0, 10)] int _maxRange;

    Shooter _shooter;
    Target _target;
    TurnActor _actor;
    Mover _mover;

    DistanceSensor _distanceSensor;
    SightToPlayerUnitSensor _sightSensor;

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
        _distanceSensor = new DistanceSensor(_target, TeamTag.AIorPlayer, _mover.pathProfile, _maxRange, new ThresholdUtilityFunction(1f));
        _sightSensor = new SightToPlayerUnitSensor(_target, _obstacleLayers, new ThresholdUtilityFunction(0.5f));

        ShootAction shootAction = new ShootAction(_shooter, () => { return -1; });

        shootAction.AddPreparationListener(() =>
        {
            var targets = _sightSensor.GetTargetsOnSight(TeamTag.AIorPlayer);

            shootAction.SetTarget(targets[0]);

        });

        IdleAction idleAction = new IdleAction(_actor, () => { return -1; });

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
                 var targets = _sightSensor.GetTargetsOnSight(TeamTag.AIorPlayer);

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
