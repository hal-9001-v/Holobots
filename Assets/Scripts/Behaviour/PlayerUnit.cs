using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
[RequireComponent(typeof(Selectable))]
[RequireComponent(typeof(Mover))]
[RequireComponent(typeof(Shooter))]
[RequireComponent(typeof(TurnActor))]
public class PlayerUnit : MonoBehaviour, ITurnPreviewer
{
    public Target target;
    TurnActor _turnActor;
    Mover _mover;

    public List<Adapter> adapters { get; private set; }

    public bool isControlActive;

    public bool isDead
    {
        get
        {
            return target.isDead;
        }
    }


    private void Awake()
    {
        target = GetComponent<Target>();
        _mover = GetComponent<Mover>();
        _turnActor = GetComponent<TurnActor>();

        CreateAdapters();
    }

    private void Start()
    {
        target.dieAction += Dead;
    }

    void CreateAdapters()
    {
        adapters = new List<Adapter>();

        var mover = GetComponent<Mover>();
        if (mover)
        {
            adapters.Add(new MoverPlayerAdapter(mover, target, _turnActor));
        }

        var shooter = GetComponent<Shooter>();
        if (shooter)
        {
            adapters.Add(new ShooterPlayerAdapter(shooter));
        }

        var shielder = GetComponent<Shielder>();
        if (shielder)
        {
            adapters.Add(new ShielderPlayerAdapter(shielder, target, _turnActor));
        }
    }

    void Dead()
    {
        foreach (var renderer in GetComponentsInChildren<Renderer>())
        {
            renderer.enabled = false;
        }

        foreach (var collider in GetComponentsInChildren<Collider>())
        {
            collider.enabled = false;
        }
    }

    public void ResetAdapters()
    {
        foreach (var adapter in adapters)
        {
            adapter.Reset();
        }

        _turnActor.ResetSteps();
    }

    public TurnPreview[] GetPossibleMoves()
    {
        /*
        int range = 4;
        
        var moves = _mover.GetTilesInMaxRange(range);

        TurnPreview[] preview = new TurnPreview[moves.Count];

        for (int i = 0; i < moves.Count; i++)
        {
            preview[i] = new TurnPreview();
            preview[i].position = moves[i];
        }
        */
        return null;
    }

    public MinMaxWeights GetMinMaxWeights()
    {
        throw new System.NotImplementedException();
    }
}
