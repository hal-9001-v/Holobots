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
    [SerializeField] [Range(1, 10)] int _moveCost = 1;
    [SerializeField] PathProfile _pathProfile;
    [SerializeField] float _movingSpeed;

    MoverExecuter _executer;
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

    public int moveCost
    {
        get
        {
            return _moveCost;
        }
    }

    public bool isReadyToMove { get; set; }

    Target _target;
    TurnActor _turnActor;

    Ground _ground;

    void Awake()
    {
        _target = GetComponent<Target>();
        _turnActor = GetComponent<TurnActor>();

        _ground = FindObjectOfType<Ground>();

        _executer = new MoverExecuter(_target, this, _turnActor, _movingSpeed);
    }

    public List<GroundTile> GetFilteredPath(GroundTile startingTile, GroundTile destinationTile)
    {
        var totalPath = _ground.GetPath(startingTile, destinationTile, _pathProfile);

        List<GroundTile> newList = new List<GroundTile>();

        int elapsedWeight = 0;
        for (int i = 0; i < totalPath.Length; i++)
        {
            if (elapsedWeight + totalPath[i].weight > maxMoves)
                break;

            elapsedWeight += totalPath[i].weight;
            newList.Add(totalPath[i]);

        }

        return newList;
    }

    public void MoveToTarget(GroundTile target)
    {
        _executer.Execute(GetFilteredPath(_target.currentGroundTile, target));
    }

    public int DistanceToTarget(GroundTile target)
    {
        return _ground.GetDistance(_target.currentGroundTile, target, pathProfile);
    }

    public void MoveInPath(List<GroundTile> path)
    {
        _executer.Execute(path);
    }
    public List<DistancedTile> GetTilesInMaxRange(int range)
    {
        List<DistancedTile> tilesInRange = new List<DistancedTile>();
        GroundTile newTile;

        for (int i = -range + 1; i <= range; i++)
        {
            for (int j = -range + 1; j <= range; j++)
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
}

public class MoverExecuter
{
    TurnActor _actor;
    Target _target;
    Mover _mover;

    float _speed;

    public MoverExecuter(Target target, Mover mover, TurnActor actor, float speed)
    {
        _speed = speed;

        _target = target;
        _mover = mover;
        _actor = actor;
    }

    public void Execute(List<GroundTile> tileList)
    {
        //if (tileList.Count > 1)
          //  Debug.Log(_target.name + " is moving from " + _target.currentGroundTile.name + " to " + tileList[tileList.Count - 1].name);

        _actor.StartCoroutine(MoveToTarget(tileList.ToArray()));
    }

    IEnumerator MoveToTarget(GroundTile[] path)
    {
        _actor.StartStep(_mover.moveCost);

        for (int i = 0; i < path.Length; i++)
        {
            var destinationTile = path[i];

            if (!_mover.pathProfile.canTraspass)
            {
                if (destinationTile.unit != null && destinationTile.unit != _target) break;
            }

            var startingPosition = _actor.transform.position;

            var fixedDestination = destinationTile.transform.position;
            fixedDestination.y = _actor.transform.position.y;

            float elapsedTime = 0;
            float duration = Vector3.Distance(startingPosition, fixedDestination) / _speed;

            while (elapsedTime < duration)
            {
                elapsedTime += Time.deltaTime;

                _actor.transform.position = Vector3.Lerp(startingPosition, fixedDestination, elapsedTime / duration);

                yield return null;
            }

            _target.transform.position = fixedDestination;

            _target.SetCurrentGroundTile(destinationTile);
        }

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