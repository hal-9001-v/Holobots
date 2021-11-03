using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Adapter
{
    protected bool _inputIsActive;


    public void EnableInput()
    {
        _inputIsActive = true;

        OnStartControl();
    }

    public void DisableInput()
    {
        _inputIsActive = false;

        OnStopControl();
    }

    public abstract void Reset();

    public abstract void OnStartControl();
    public abstract void OnStopControl();

}
