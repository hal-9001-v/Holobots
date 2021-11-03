using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
[RequireComponent(typeof(TurnActor))]
public class Mover : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 10)] int _maxMoves;

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
        var totalPath = _ground.GetPath(startingTile, destinationTile);

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

    public void AddPathToSteps(List<GroundTile> path)
    {
        //Create Steps
        MoverTurnStep[] steps = new MoverTurnStep[path.Count - 1];
        for (int i = 0; i < steps.Length; i++)
        {
            //i + 1 because first tile in _confirmedPath is currentPositon at the start
            steps[i] = new MoverTurnStep(path[i + 1], _target, _turnActor, _stepDuration);
        }

        AddSteps(steps);
    }

    public List<GroundTile> GetTilesInMaxRange(int range)
    {
        List<GroundTile> tilesInRange = new List<GroundTile>();
        GroundTile newTile;

        for (int i = 0; i < range; i++)
        {
            for (int j = 0; j < range; j++)
            {
                if (_ground.groundMap.TryGetValue(_target.currentGroundTile.cellCoord + new Vector2Int(i, j), out newTile))
                {
                    //Paths are 0 if there is no possible path.
                    if (GetFilteredPath(_target.currentGroundTile, newTile).Count != 0)
                    {
                        tilesInRange.Add(newTile);
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

    float _duration;

    public MoverTurnStep(GroundTile destination, Target target, TurnActor actor, float duration)
    {
        this.destination = destination;

        _target = target;
        _actor = actor;
        _duration = duration;
    }

    public override void Execute()
    {
        _actor.StartCoroutine(MoveToTarget());

    }

    IEnumerator MoveToTarget()
    {
        if (destination.unit != null)
        {
            //Cant move there. End turn
            _actor.ResetSteps();
        }
        else
        {
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
        }

        _actor.EndStep();

    }
}
