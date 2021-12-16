using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(TurnActor))]
public class Explosioner : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 5)] int _exploderCost = 1;
    [SerializeField] [Range(1, 10)] int _exploderRange = 3;

    [Header("References")]
    [SerializeField] Explosion _explosion;

    public int explosionRange
    {
        get
        {
            return _explosion.range;
        }
    }

    public int exploderRange
    {
        get
        {
            return _exploderRange;
        }
    }

    ExplosionerExecuter _executer;

    private void Awake()
    {
        TurnActor actor = GetComponent<TurnActor>();

        _executer = new ExplosionerExecuter(actor, _explosion, _exploderCost);
    }

    public void Explode(GroundTile tile)
    {
        _executer.Execute(tile);
    }

}

class ExplosionerExecuter
{

    TurnActor _actor;
    Explosion _explosion;

    int _cost;

    public ExplosionerExecuter(TurnActor actor, Explosion explosion, int cost)
    {
        _actor = actor;
        _explosion = explosion;

        _cost = cost;
    }

    public void Execute(GroundTile tile)
    {
        _actor.StartStep(_cost);

        var barrier = new CountBarrier(() =>
        {
            _actor.EndStep();
        });

        _explosion.Explode(tile, barrier);
    }

}
