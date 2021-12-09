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

    Highlighter _highlighter;


    public HealerExecuter(TurnActor actor, int cost)
    {
        _actor = actor;
        _cost = cost;

        _highlighter = new Highlighter();
    }

    public void Execute(Target target, int points)
    {
        _actor.StartCoroutine(Heal(target, points));
    }

    IEnumerator Heal(Target target, int points)
    {
        _actor.StartStep(_cost);

        _highlighter.AddHealedHighlightable(target.highlightable);
        _highlighter.AddHealedHighlightable(target.currentGroundTile.highlightable);

        yield return new WaitForSeconds(1);

        target.Heal(points);

        _highlighter.Unhighlight();

        _actor.EndStep();
    }

}
