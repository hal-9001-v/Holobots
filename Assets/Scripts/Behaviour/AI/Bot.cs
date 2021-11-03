using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Target))]
[RequireComponent(typeof(TurnActor))]
public abstract class Bot : MonoBehaviour, ITurnPreviewer
{
    public Target target { get; private set; }

    public bool isDead
    {
        get
        {
            if (target != null)
            {

                return target.isDead;
            }
            else
            {
                target = GetComponent<Target>();


                return target.isDead;
            }
            
        }
    }

    private void Awake()
    {
        target = GetComponent<Target>();
    }

    public abstract void PrepareSteps();

    public abstract TurnPreview[] GetPossibleMoves();

    public abstract MinMaxWeights GetMinMaxWeights();
    
}
