using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(Target))]
[RequireComponent(typeof(TurnActor))]
public abstract class Bot : MonoBehaviour
{

    protected Target _target;

    public Target target
    {
        get
        {
            if (!_target)

                _target = GetComponent<Target>();


            return _target;
        }


    }

    protected TurnActor _actor;

    public TurnActor actor
    {
        get
        {
            if (!_actor)
            {
                _actor = GetComponent<TurnActor>();
            }

            return _actor;
        }
    }

    private void Awake()
    {
        _target = GetComponent<Target>();

        _actor = GetComponent<TurnActor>();
    }

    public abstract void ExecuteStep();
}
