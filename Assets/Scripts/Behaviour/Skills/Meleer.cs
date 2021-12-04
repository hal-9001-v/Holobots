using System.Collections;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class Meleer : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(2, 5)] int _meleeRange = 2;
    [SerializeField] [Range(1, 5)] int _meleerDamage = 1;
    [SerializeField] [Range(1, 5)] int _meleerCost = 1;

    public int meleeRange
    {
        get
        {
            return _meleeRange;
        }
    }

    [Header("References")]
    [SerializeField] MeleeHit _planningHit;

    MeleerExecuter _executer;
    TurnActor _actor;

    private void Awake()
    {
        _actor = GetComponent<TurnActor>();

        _executer = new MeleerExecuter(_actor, _meleerCost);
    }

    public void Hit(GroundTile tile)
    {
        _executer.Execute(tile, _meleerDamage);
    }

    public void SetPlanningHit(GroundTile tile)
    {
        _planningHit.SetTile(tile);
    }

    public void Hide()
    {
        _planningHit.Hide();
    }

}

class MeleerExecuter
{
    TurnActor _actor;
    int _cost = 0;

    public MeleerExecuter(TurnActor actor, int cost)
    {
        _actor = actor;
        _cost = cost;
    }

    public void Execute(GroundTile tile, int damage)
    {
        Debug.Log(_actor.name + " is attacking with melee " + tile);

        _actor.StartCoroutine(MakeHit(tile, damage));
    }

    IEnumerator MakeHit(GroundTile tile, int damage)
    {
        _actor.StartStep(_cost);
        yield return new WaitForSeconds(1f);

        if (tile.unit != null)
        {
            tile.unit.Hurt(damage);
        }
        _actor.EndStep();
    }
}