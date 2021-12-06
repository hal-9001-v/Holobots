using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class Healer : MonoBehaviour
{
    TurnActor _turnActor;

    HealerExecuter _executer;


    [Header("Settings")]

    [SerializeField] [Range(1, 10)] int _heal;
    [SerializeField] [Range(1, 10)] int _healRange;
    [SerializeField] [Range(1, 5)] int _healCost;

    public int range
    {
        get
        {
            return _healRange;
        }
    }

    private void Awake()
    {
        _turnActor = GetComponent<TurnActor>();

        _executer = new HealerExecuter(_turnActor, _healCost);
    }

    public void Heal(Target target)
    {
        Debug.Log(_turnActor.name + " is healing " + target.name + " " + _heal + " points");
        _executer.Execute(target, _heal);
    }

}

class HealerExecuter
{
    TurnActor _actor;
    int _cost;

    public HealerExecuter(TurnActor actor, int cost)
    {
        _actor = actor;
        _cost = cost;
    }

    public void Execute(Target target, int points)
    {
        _actor.StartCoroutine(Heal(target, points));
    }

    IEnumerator Heal(Target target, int points)
    {
        _actor.StartStep(_cost);

        yield return new WaitForSeconds(1);

        target.Heal(points);

        _actor.EndStep();
    }

}
