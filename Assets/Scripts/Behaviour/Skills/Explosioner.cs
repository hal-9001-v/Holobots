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

        var rotator = GetComponentInChildren<CharacterRotator>();
        _executer = new ExplosionerExecuter(actor, rotator, _explosion, _exploderCost);
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

    CharacterRotator _rotator;

    int _cost;

    public ExplosionerExecuter(TurnActor actor, CharacterRotator rotator, Explosion explosion, int cost)
    {
        _actor = actor;
        _explosion = explosion;

        _rotator = rotator;

        _cost = cost;
    }

    public void Execute(GroundTile tile)
    {
        _actor.StartStep(_cost);

        if (_rotator)
        {
            var direction = tile.transform.position - _actor.transform.position;
            direction.Normalize();

            _rotator.SetForward(direction, 0.35f);
        }

        var barrier = new CountBarrier(() =>
        {
            _actor.EndStep();
        });

        Animator anim = _actor.gameObject.GetComponentInChildren<Animator>();
        anim.SetTrigger("Attack");


        _explosion.Explode(tile, barrier, _actor.target);
        _actor.StartCoroutine(ResetExplosionAnim(anim));

    }

    private IEnumerator ResetExplosionAnim(Animator anim){
        yield return new WaitForSeconds(0.1f);
        anim.ResetTrigger("Attack");
    }

}
