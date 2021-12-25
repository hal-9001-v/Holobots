using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explosion : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 10)] int _damage = 2;
    [SerializeField] [Range(1, 10)] int _range = 2;

    Highlighter _highlighter;

    VFXManager _vfxManager;
    CameraMovement _cameraMovement;

    public int range
    {
        get
        {
            return _range;
        }
    }

    Ground _ground;

    Target _target;

    private void Awake()
    {
        _highlighter = new Highlighter();

        _ground = FindObjectOfType<Ground>();

        _vfxManager = FindObjectOfType<VFXManager>();
        _cameraMovement = FindObjectOfType<CameraMovement>();
    }

    public void Explode(GroundTile centerTile, CountBarrier barrier, Target hurter)
    {
        StartCoroutine(ExplodeCoroutine(centerTile, barrier, hurter));
    }

    IEnumerator ExplodeCoroutine(GroundTile centerTile, CountBarrier barrier, Target hurter)
    {
        barrier.AddCounter();
        var tiles = _ground.GetTilesInRange(centerTile, _range);

        foreach (var tile in tiles)
        {
            _highlighter.AddDangerededHighlightable(tile.highlightable);

            if (tile.unit)
            {
                _highlighter.AddDangerededHighlightable(tile.unit.highlightable);
            }
        }

        _vfxManager.Play("Explosion", centerTile.transform);
        _cameraMovement.FixLookAt(_vfxManager.VFXObject.transform);

        yield return new WaitForSeconds(_vfxManager.GetDuration());
        //Add to barrier so it doesnt get to 0 in loop.
        barrier.AddCounter();
        foreach (var tile in tiles)
        {
            if (tile.unit && tile.unit.targetType != TargetType.Ranger)
            {
                barrier.AddCounter();
                tile.unit.Hurt(hurter, _damage, barrier);
            }
        }
        barrier.RemoveCounter();

        _highlighter.Unhighlight();
        yield return new WaitForSeconds(1.2f);

        barrier.RemoveCounter();
    }

    public List<GroundTile> GetTilesInRange(GroundTile centerTile)
    {
        return _ground.GetTilesInRange(centerTile, _range);
    }
}
