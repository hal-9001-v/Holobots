using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(SelfExplosion))]
[RequireComponent(typeof(TurnActor))]
[RequireComponent(typeof(Mover))]
public class Kamikaze : Bot
{
    [Header("Settings")]
    [SerializeField] [Range(0, 100)] float _rotationSpeed;
    [SerializeField] [Range(2, 10)] int _detectionRange;
    [SerializeField] [Range(2, 10)] int _roamRange;

    Target _target;
    TurnActor _actor;
    SelfExplosion _selfExplosion;
    Mover _mover;

    DistanceSensor _distanceSensor;

    BehaviourTree _tree;

    Ground _ground;

    bool _found;

    private void Start()
    {
        _selfExplosion = GetComponent<SelfExplosion>();
        _mover = GetComponent<Mover>();
        _target = GetComponent<Target>();
        _actor = GetComponent<TurnActor>();

        _ground = FindObjectOfType<Ground>();

        _target.dieAction += () =>
        {
            enabled = false;
        };

        InitializeTree();
    }

    private void FixedUpdate()
    {
        transform.localEulerAngles += new Vector3(0, _rotationSpeed * Time.fixedDeltaTime, 0);
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
        _distanceSensor = new DistanceSensor(_target, _actor.team.enemyTags, _mover.pathProfile, _detectionRange, new ThresholdUtilityFunction(_detectionRange));

        SelfDestructionAction explosionAction = new SelfDestructionAction(_selfExplosion, "Explosion Kamikaze", () => { return -1; });

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
            var distanceValue = 1 - _distanceSensor.GetScore();

            if (distanceValue == 1)
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
