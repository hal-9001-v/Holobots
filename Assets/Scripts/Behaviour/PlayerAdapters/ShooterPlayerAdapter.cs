using UnityEngine;

public class ShooterPlayerAdapter : Adapter, ISelectorObserver
{
    Shooter _shooter;
    Target _target;

    Target _shootTarget;

    GridLine _gridLine;

    Highlighter _highlighter;

    public ShooterPlayerAdapter(Target target, Shooter shooter) : base(AdapterType.Attack)
    {
        _shooter = shooter;
        _target = target;
        _highlighter = new Highlighter();


        GridLineProvider provider = GameObject.FindObjectOfType<GridLineProvider>();

        _gridLine = provider.CloneAttacktGridLine(shooter.name);

        SetNotifications();
    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        _shootTarget = selectable.GetComponent<Target>();

        _highlighter.Unhighlight();

        if (_shootTarget == null)
        {
            var tile = selectable.GetComponent<GroundTile>();

            if (tile)
            {
                _shootTarget = tile.unit;
            }
        }


        if (_shootTarget && _shootTarget.teamTag != _target.teamTag)
        {
            var points = new Vector3[2]
                {_target.transform.position, _shootTarget.currentGroundTile.transform.position};

            _gridLine.SetPoints(points);

            _highlighter.AddDangerededHighlightable(_shootTarget.highlightable);
            _highlighter.AddDangerededHighlightable(_shootTarget.currentGroundTile.highlightable);

        }
    }

    public void SetNotifications()
    {
        ScreenSelector selector = GameObject.FindObjectOfType<ScreenSelector>();

        selector.onLeftClickCallback += OnLeftClickNotify;
        selector.onSelectionCallback += OnSelectNotify;
        selector.onNothingSelectedCallback += OnNothingSelectNotify;
    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        if (_shootTarget)
        {
            _shooter.AddShoot(_shootTarget);
        }
    }

    public void OnRightClickNotify(Selectable selectable)
    {
    }

    public override void OnStartControl()
    {
    }

    public override void OnStopControl()
    {
        _gridLine.HideLine();
        _highlighter.Unhighlight();
    }

    public void OnNothingSelectNotify()
    {
        _shootTarget = null;

        _gridLine.HideLine();
    }
}
