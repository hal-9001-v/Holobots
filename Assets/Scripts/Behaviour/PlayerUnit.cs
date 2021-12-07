using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
[RequireComponent(typeof(Selectable))]
[RequireComponent(typeof(TurnActor))]

public class PlayerUnit : MonoBehaviour, ITurnPreviewer
{
    public Target target { get; private set; }
    TurnActor _turnActor;

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
            adapters.Add(new ShooterPlayerAdapter(target, shooter));
        }

        var shielder = GetComponent<Shielder>();
        if (shielder)
        {
            adapters.Add(new ShielderPlayerAdapter(shielder, target));
        }

        var meleer = GetComponent<Meleer>();
        if (meleer)
        {
            adapters.Add(new MeleerPlayerAdapter(meleer, target));
        }

        var explosioner = GetComponent<Explosioner>();
        if (explosioner)
        {
            adapters.Add(new ExplosionerPlayerAdapter(target, explosioner));
        }

        var healer = GetComponent<Healer>();
        if (healer)
        {
            adapters.Add(new HealerPlayerAdapter(healer, target));
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
