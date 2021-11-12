using System.Collections.Generic;
using UnityEngine;
public class ShielderPlayerAdapter : Adapter, ISelectorObserver
{
    Shielder _shielder;
    Target _target;
    TurnActor _turnActor;

    public ShielderPlayerAdapter(Shielder shielder, Target target, TurnActor actor)
    {
        _shielder = shielder;
        _target = target;
        _turnActor = actor;

        SetNotifications();
    }

    public void OnRightClickNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;
        _shielder.RotateShield();
        

    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        var tile = selectable.GetComponent<GroundTile>();
        if (tile)
        {
            _shielder.SetShield(tile);
        }

    }

    public void SetNotifications()
    {
        var screenSelector = GameObject.FindObjectOfType<ScreenSelector>();

        screenSelector.onRightClickCallback += OnRightClickNotify;
        screenSelector.onSelectionCallback += OnSelectNotify;

    }

    public override void Reset()
    {

    }

    public override void OnStopControl()
    {

    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        throw new System.NotImplementedException();
    }

    public override void OnStartControl()
    {
        //Nothing!

    }

}

