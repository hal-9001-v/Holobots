using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class Charger : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(3, 6)] int _chargeRange = 5;
    [SerializeField] [Range(1, 10)] int _chargeCost = 1;
    [SerializeField] float _movingSpeed;

    ChargerExecuter _executer;

    public int moveCost
    {
        get
        {
            return _chargeCost;
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

        _executer = new ChargerExecuter(_target, this, _turnActor, _movingSpeed);
    }

    public List<GroundTile> GetPossibleChargeTiles(GroundTile startingTile)
    {
        List<GroundTile> possibleTiles = new List<GroundTile>();

        GroundTile auxTile;
        for (int i = -_chargeRange + 1; i < _chargeRange; i++)
        {
            if (_ground.groundMap.TryGetValue(_target.currentGroundTile.cellCoord + new Vector2Int(i, 0), out auxTile))
            {
                if (auxTile.tileType != TileType.Untraversable)
                    possibleTiles.Add(auxTile);
            }

            if (_ground.groundMap.TryGetValue(_target.currentGroundTile.cellCoord + new Vector2Int(0, i), out auxTile))
            {
                if (auxTile.tileType != TileType.Untraversable)
                    possibleTiles.Add(auxTile);
            }

            if (_ground.groundMap.TryGetValue(_target.currentGroundTile.cellCoord + new Vector2Int(i, i), out auxTile))
            {
                if (auxTile.tileType != TileType.Untraversable)
                    possibleTiles.Add(auxTile);
            }

            if (_ground.groundMap.TryGetValue(_target.currentGroundTile.cellCoord + new Vector2Int(-i, i), out auxTile))
            {
                if (auxTile.tileType != TileType.Untraversable)
                    possibleTiles.Add(auxTile);
            }

        }

        return possibleTiles;
    }

    Charge GetChargeToTile(GroundTile destination)
    {
        Vector2Int direction = destination.cellCoord - _target.currentGroundTile.cellCoord;

        if ((direction.x == 0 || direction.y == 0) || (Mathf.Abs(direction.x) == Mathf.Abs(direction.y)))
        {
            if (direction.x > 0) direction.x = 1;
            else if (direction.x < 0) direction.x = -1;

            if (direction.y > 0) direction.y = 1;
            else if (direction.y < 0) direction.y = -1;


            

            return new Charge();
        }
        else
        {
            throw new System.Exception("Charge is not valid!");
        }


    }

    public void ChargeToTarget(Charge tiles)
    {
    }

}

public class ChargerExecuter
{
    TurnActor _actor;
    Target _target;
    Charger _charger;

    float _speed;

    public ChargerExecuter(Target target, Charger charger, TurnActor actor, float speed)
    {
        _speed = speed;

        _target = target;
        _charger = charger;
        _actor = actor;
    }

    public void Execute(GroundTile target)
    {
        Debug.Log(_target.name + " is moving from " + _target.currentGroundTile.name + " to " + target.name);
    }

    IEnumerator MoveToTarget(GroundTile destinationTile)
    {
        _actor.StartStep(_charger.moveCost);

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

        _actor.EndStep();
    }

}