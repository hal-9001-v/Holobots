using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExplosionerPlayerAdapter : Adapter, ISelectorObserver
{
    Target _target;

    Explosioner _explosioner;

    GroundTile _selectedTile;

    Ground _ground;

    Highlighter _highlighter;

    public ExplosionerPlayerAdapter(Target target, Explosioner explosioner) : base(AdapterType.Explosioner)
    {
        _target = target;
        _explosioner = explosioner;
        _ground = GameObject.FindObjectOfType<Ground>();

        _highlighter = new Highlighter();

        SetNotifications();
    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        if (_selectedTile)
        {
            _highlighter.Unhighlight();
            _explosioner.Explode(_selectedTile);
        }
    }

    public void OnNothingSelectNotify()
    {
        if (!_inputIsActive) return;

        _selectedTile = null;
        _highlighter.Unhighlight();
    }

    public void OnRightClickNotify(Selectable selectable)
    {
        throw new System.NotImplementedException();
    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        _selectedTile = selectable.GetComponent<GroundTile>();

        if (_selectedTile == null)
        {
            var target = selectable.GetComponent<Target>();

            if (target)
            {
                _selectedTile = target.currentGroundTile;
            }
        }

        _highlighter.Unhighlight();

        if (_selectedTile)
        {
            Vector2Int v = _selectedTile.cellCoord - _target.currentGroundTile.cellCoord;

            v = new Vector2Int(Mathf.Abs(v.x), Mathf.Abs(v.y));
            if (v.x < _explosioner.exploderRange && v.y < _explosioner.exploderRange)
            {
                foreach (var tile in _ground.GetTilesInRange(_selectedTile, _explosioner.explosionRange))
                {
                    _highlighter.AddDangerededHighlightable(tile.highlightable);

                    if (tile.unit)
                    {
                        _highlighter.AddDangerededHighlightable(tile.unit.highlightable);
                    }

                }

            }
            else
            {
                _selectedTile = null;
            }
        }
    }

    public override void OnStartControl()
    {

    }

    public override void OnStopControl()
    {
        _highlighter.Unhighlight();
    }

    public void SetNotifications()
    {
        var screenSelector = GameObject.FindObjectOfType<ScreenSelector>();

        screenSelector.onLeftClickCallback += OnLeftClickNotify;
        screenSelector.onSelectionCallback += OnSelectNotify;
        screenSelector.onNothingSelectedCallback += OnNothingSelectNotify;
    }
}
