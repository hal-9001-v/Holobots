using UnityEngine;

public class ShooterPlayerAdapter : Adapter, ISelectorObserver
{
    Shooter _shooter;

    GridLine[] _gridLines;

    GroundTile _targetGroundTile;

    public ShooterPlayerAdapter(Shooter shooter) : base(AdapterType.Attack)
    {
        _shooter = shooter;

        _gridLines = new GridLine[shooter.maxShoots];

        GridLineProvider provider = GameObject.FindObjectOfType<GridLineProvider>();

        for (int i = 0; i < _gridLines.Length; i++)
        {
            _gridLines[i] = provider.CloneAttacktGridLine(shooter.name);
        }

        SetNotifications();
    }

    public void OnSelectNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        if (_shooter.usedShoots < _shooter.maxShoots)
        {
            _targetGroundTile = selectable.GetComponent<GroundTile>();

            if (!_targetGroundTile)
            {

                var target = selectable.GetComponent<Target>();

                if (target)
                    _targetGroundTile = target.currentGroundTile;


            }

            if (_targetGroundTile)
            {
                var points = new Vector3[2]
                    { _shooter.shootOriginTile.transform.position, _targetGroundTile.transform.position};

                _gridLines[_shooter.usedShoots].SetPoints(points);

            }
        }
    }

    public void SetNotifications()
    {
        ScreenSelector selector = GameObject.FindObjectOfType<ScreenSelector>();

        selector.onLeftClickCallback += OnLeftClickNotify;
        selector.onSelectionCallback += OnSelectNotify;
    }

    public void OnLeftClickNotify(Selectable selectable)
    {
        if (!_inputIsActive) return;

        if (_shooter.shootOriginTile != null && _targetGroundTile)
        {
            if (_shooter.usedShoots < _shooter.maxShoots)
            {
                _shooter.AddShootStep(_targetGroundTile);
            }
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
        for (int i = _shooter.usedShoots; i < _shooter.maxShoots; i++)
        {
            _gridLines[i].HideLine();
        }

    }

    public override void Reset()
    {
        _shooter.ResetSteps();

        foreach (var line in _gridLines)
        {
            line.HideLine();
        }

    }

    public void OnNothingSelectNotify()
    {
        _targetGroundTile = null;

        foreach (var line in _gridLines)
        {
            line.HideLine();
        }
    }
}
