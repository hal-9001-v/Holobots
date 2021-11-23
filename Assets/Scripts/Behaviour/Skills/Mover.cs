using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
[RequireComponent(typeof(TurnActor))]
public class Mover : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 10)] int _maxMoves;
    [SerializeField] PathProfile _pathProfile;

    public PathProfile pathProfile
    {
        get
        {
            return _pathProfile;

        }
    }

    public int maxMoves
    {
        get
        {
            return _maxMoves;
        }
    }

    [SerializeField] [Range(0.5f, 3)] float _stepDuration;

    public float stepDuration
    {
        get
        {
            return _stepDuration;
        }
    }

    int _avaliableMoves;

    public int avaliableMoves
    {
        get
        {
            return _avaliableMoves;
        }
    }
    public bool isReadyToMove { get; set; }

    Target _target;
    TurnActor _turnActor;

    Ground _ground;

    //Last of _confirmedPath
    public GroundTile lastPathTile { get; private set; }

    void Awake()
    {
        _target = GetComponent<Target>();
        _turnActor = GetComponent<TurnActor>();

        _ground = FindObjectOfType<Ground>();
    }
    public List<GroundTile> GetFilteredPath(GroundTile startingTile, GroundTile destinationTile)
    {
        var totalPath = _ground.GetPath(startingTile, destinationTile, _pathProfile);

        List<GroundTile> newList = new List<GroundTile>();

        int elapsedWeight = 0;
        for (int i = 0; i < totalPath.Length; i++)
        {
            if (elapsedWeight + totalPath[i].weight > _avaliableMoves)
                break;

            elapsedWeight += totalPath[i].weight;
            newList.Add(totalPath[i]);

        }

        return newList;
    }

    public void AddStepsToReachTarget(GroundTile target)
    {
        AddStepsFromPath(GetFilteredPath(_target.currentGroundTile, target));
    }

    public void AddStepsFromPath(List<GroundTile> path)
    {
        if (path.Count == 0) return;

        //Create Steps
        MoverTurnStep[] steps = new MoverTurnStep[path.Count - 1];
        for (int i = 0; i < steps.Length; i++)
        {
            //i + 1 because first tile in _confirmedPath is currentPositon at the start
            steps[i] = new MoverTurnStep(path[i + 1], _target, this, _turnActor, _stepDuration);
        }

        AddSteps(steps);
    }

    public List<DistancedTile> GetTilesInMaxRange(int range)
    {
        List<DistancedTile> tilesInRange = new List<DistancedTile>();
        GroundTile newTile;

        for (int i = -1; i <= range; i++)
        {
            for (int j = -1; j <= range; j++)
            {
                if (_ground.groundMap.TryGetValue(_target.currentGroundTile.cellCoord + new Vector2Int(i, j), out newTile))
                {
                    var pathLength = GetFilteredPath(_target.currentGroundTile, newTile).Count;
                    //Paths are 0 if there is no possible path.
                    if (pathLength != 0)
                    {

                        tilesInRange.Add(new DistancedTile(newTile, pathLength));
                    }
                }
            }
        }

        return tilesInRange;

    }

    void AddSteps(MoverTurnStep[] steps)
    {
        if (steps != null && steps.Length != 0)
        {
            lastPathTile = steps[steps.Length - 1].destination;

            _turnActor.AddSteps(steps);

            _avaliableMoves -= steps.Length;
        }
    }

    public void ResetSteps()
    {
        _avaliableMoves = _maxMoves;

        lastPathTile = _target.currentGroundTile;
    }
}

public class MoverTurnStep : TurnStep
{
    TurnActor _actor;
    public GroundTile destination;
    Target _target;
    Mover _mover;

    float _duration;

    public MoverTurnStep(GroundTile destination, Target target, Mover mover, TurnActor actor, float duration)
    {
        this.destination = destination;

        _target = target;
        _mover = mover;
        _actor = actor;
        _duration = duration;
    }

    public override void Execute()
    {
        _actor.StartCoroutine(MoveToTarget());

    }

    IEnumerator MoveToTarget()
    {
        //Cant move there. End turn
        if (!_mover.pathProfile.canTraspass && destination.unit != null)
            _actor.ResetSteps();

        var startingPosition = _actor.transform.position;
        _target.SetCurrentGroundTile(destination);

        var fixedDestination = destination.transform.position;
        fixedDestination.y = startingPosition.y;

        float elapsedTime = 0;

        while (elapsedTime < _duration)
        {
            elapsedTime += Time.deltaTime;

            _actor.transform.position = Vector3.Lerp(startingPosition, fixedDestination, elapsedTime / _duration);

            yield return null;
        }

        _actor.transform.position = fixedDestination;


        _actor.EndStep();
    }
}


public class DistancedTile
{
    public GroundTile tile;
    public int distance;

    public DistancedTile(GroundTile tile, int distance)
    {
        this.tile = tile;
        this.distance = distance;
    }
}