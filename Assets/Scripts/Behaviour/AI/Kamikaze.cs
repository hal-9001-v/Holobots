using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Explosioner))]
[RequireComponent(typeof(TurnActor))]
[RequireComponent(typeof(Mover))]
public class Kamikaze : Bot
{
    [Header("Settings")]
    [SerializeField] [Range(2, 10)] int _detectionRange;
    [SerializeField] [Range(2, 10)] int _roamRange;

    Target _target;
    TurnActor _actor;
    Explosioner _explosioner;
    Mover _mover;

    DistanceSensor _distanceSensor;

    BehaviourTree _tree;

    Ground _ground;

    bool _found;

    private void Start()
    {
        _explosioner = GetComponent<Explosioner>();
        _mover = GetComponent<Mover>();
        _target = GetComponent<Target>();
        _actor = GetComponent<TurnActor>();

        _ground = FindObjectOfType<Ground>();


        InitializeTree();
    }

    public override void ExecuteStep()
    {
        if (_found)
        {
            _tree.Tick();
        }
        else
        {
            _tree.StartTree();
        }
    }

    public void InitializeTree()
    {
        _distanceSensor = new DistanceSensor(_target, TeamTag.AIorPlayer, _mover.pathProfile, _detectionRange, new ThresholdUtilityFunction(1f));

        ExplosionAction explosionAction = new ExplosionAction(_explosioner, "Explosion Kamikaze", () => { return -1; });

        explosionAction.AddPreparationListener(() =>
        {
            explosionAction.SetTarget(_target.currentGroundTile);
        });

        EngageAction engageAction = new EngageAction(_mover, "Kamikaze Engage", () => { return -1; });
        engageAction.AddPreparationListener(() =>
        {
            var closestTarget = _distanceSensor.GetClosestTarget();

            engageAction.SetTarget(closestTarget);
        });

        IdleAction idleAction = new IdleAction(_actor, "Idle", () => { return -1; });

        _tree = new BehaviourTree();
        SelectorNode rootNode = new SelectorNode();
        _tree.root = rootNode;

        #region ATTACK SEQUENCE
        SequenceNode attackSequence = new SequenceNode(rootNode);

        LeafNode checkEnemyNode = new LeafNode(attackSequence, () =>
        {
            if (_distanceSensor.GetScore() == 1)
            {
                engageAction.Execute();
                _found = true;
                return true;
            }

            return false;
        });

        WaitForTickNode getCloserNode = new WaitForTickNode(attackSequence);

        LeafNode explodeNode = new LeafNode(getCloserNode, () =>
        {
            explosionAction.Execute();
            return true;
        });
        #endregion

        #region ROAM
        EngageAction roamAction = new EngageAction(_mover, "Roam Engage", () => { return -1; });
        roamAction.AddPreparationListener(() =>
        {
            var tiles = _ground.GetTilesInRange(_target.currentGroundTile, _roamRange);

            for (int i = 0; i < tiles.Count; i++)
            {
                if (tiles[i].tileType == TileType.Untraversable || tiles[i].unit != null)
                {
                    tiles.RemoveAt(i);

                    i--;
                }
            }
            if (tiles.Count != 0)
                roamAction.SetTarget(tiles[Random.Range(0, tiles.Count - 1)]);
            else
                roamAction.SetTarget(target.currentGroundTile);

        });

        LeafNode roamNode = new LeafNode(rootNode, () =>
        {
            roamAction.Execute();

            return true;
        });
        #endregion
    }

}
