using System.Collections.Generic;
using UnityEngine;
public class ShielderPlayerAdapter : Adapter, ISelectorObserver
{
    Shielder _shielder;
    Target _target;

    GroundTile _selectedTile;

    public ShielderPlayerAdapter(Shielder shielder, Target target) : base(AdapterType.Shield)
    {
        _shielder = shielder;
        _target = target;

        SetNotifications();
    }

    public void OnRightClickNotify(Selectable selectable)
    {
        //Nothing
    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;
        if (_selectedTile)
        {
            _shielder.SetProtectingShield(_selectedTile);
        }
    }

    public void OnNothingSelectNotify()
    {
        if (!_inputIsActive) return;

        _selectedTile = null;

        _shielder.HidePlanningShield();
    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        var tile = selectable.GetComponent<GroundTile>();


        if (!tile)
        {

            var target = selectable.GetComponent<Target>();

            if (target)
            {
                tile = target.currentGroundTile;
            }
        }


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

    public override void OnStartControl()
    {
        _shielder.ShowPlanningShield();
    }

    public override void OnStopControl()
    {
        _shielder.HidePlanningShield();
    }

}

