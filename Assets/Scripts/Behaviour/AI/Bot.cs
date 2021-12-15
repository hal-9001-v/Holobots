using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Target))]
[RequireComponent(typeof(TurnActor))]
public abstract class Bot : MonoBehaviour
{
    public Target target { get; private set; }

    public TurnActor actor { get; private set; }

    private void Awake()
    {
        target = GetComponent<Target>();

        actor = GetComponent<TurnActor>();
    }

    public abstract void ExecuteStep();
}
