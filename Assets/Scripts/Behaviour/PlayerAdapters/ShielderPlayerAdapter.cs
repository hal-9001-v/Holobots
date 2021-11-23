using System.Collections.Generic;
using UnityEngine;
public class ShielderPlayerAdapter : Adapter, ISelectorObserver
{
    Shielder _shielder;
    Target _target;
    TurnActor _turnActor;

    GroundTile _selectedTile;

    public ShielderPlayerAdapter(Shielder shielder, Target target, TurnActor actor) : base(AdapterType.Shield)
    {
        _shielder = shielder;
        _target = target;
        _turnActor = actor;

        SetNotifications();
    }

    public void OnRightClickNotify(Selectable selectable)
    {
        //Nothing
    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        if (_selectedTile)
        {
            _shielder.SetProtectingShield(_selectedTile);
        }
    }

    public void OnNothingSelectNotify()
    {
        _selectedTile = null;

        _shielder.HideShields();
    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        var tile = selectable.GetComponent<GroundTile>();
        if (tile)
        {
            _selectedTile = tile;

            _shielder.SetPlanningShield(tile);
        }

    }

    public void SetNotifications()
    {
        var screenSelector = GameObject.FindObjectOfType<ScreenSelector>();

        screenSelector.onLeftClickCallback += OnLeftClickNotify;
        screenSelector.onSelectionCallback += OnSelectNotify;
        screenSelector.onNothingSelectedCallback += OnNothingSelectNotify;

    }

    public override void Reset()
    {

    }

    public override void OnStartControl()
    {
        _shielder.ShowShields();

    }

    public override void OnStopControl()
    {
        _shielder.HideShields();
    }

}

