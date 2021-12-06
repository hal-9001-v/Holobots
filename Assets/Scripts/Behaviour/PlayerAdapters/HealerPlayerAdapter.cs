using System.Collections.Generic;
using UnityEngine;
public class HealerPlayerAdapter : Adapter, ISelectorObserver
{
    Healer _healer;
    Target _target;

    Target _selectedTarget;

    Highlighter _highlighter;

    Ground _ground;

    List<GroundTile> _avaliableTiles;

    public HealerPlayerAdapter(Healer healer, Target target) : base(AdapterType.Heal)
    {

        _healer = healer;
        _target = target;

        _highlighter = new Highlighter();

        _ground = GameObject.FindObjectOfType<Ground>();

        SetNotifications();
    }

    public void OnRightClickNotify(Selectable selectable)
    {
        //Nothing
    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        if (_selectedTarget)
        {
            _healer.Heal(_selectedTarget);
            _highlighter.Unhighlight();
        }
    }

    public void OnNothingSelectNotify()
    {
        if (!_inputIsActive) return;

        _highlighter.Unhighlight();
        _selectedTarget = null;
    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        _highlighter.Unhighlight();

        var target = selectable.GetComponent<Target>();

        if (!target)
        {
            var tile = selectable.GetComponent<GroundTile>();

            if (tile)
            {
                target = tile.unit;
            }

        }

        _selectedTarget = target;

        if (_selectedTarget)
        {

            if (_selectedTarget.team == _target.team)
            {
                if (_avaliableTiles.Contains(_selectedTarget.currentGroundTile))
                {
                    _highlighter.Unhighlight();

                    _highlighter.AddHealedHighlightable(_selectedTarget.highlightable);
                }
                else
                {
                    _selectedTarget = null;
                }
            }
            else
            {
                _selectedTarget = null;
            }
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
        _avaliableTiles = _ground.GetTilesInRange(_target.currentGroundTile, _healer.range);
    }

    public override void OnStopControl()
    {
        _highlighter.Unhighlight();
    }

}

