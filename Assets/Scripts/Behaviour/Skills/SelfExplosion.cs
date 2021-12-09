using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(TurnActor))]
[RequireComponent(typeof(Target))]
public class SelfExplosion : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 10)] int _damage = 2;
    [SerializeField] [Range(1, 10)] int _range = 2;

    Target _target;
    TurnActor _actor;

    Highlighter _highlighter;

    public int range
    {
        get
        {
            return _range;
        }
    }

    Ground _ground;

    private void Awake()
    {
        _target = GetComponent<Target>();
        _actor = GetComponent<TurnActor>();

        _ground = FindObjectOfType<Ground>();

        _highlighter = new Highlighter();
    }

    public void Explode()
    {
        StartCoroutine(Explosion());
    }

    IEnumerator Explosion()
    {
        _actor.StartStep(1);
        var tiles = GetTilesInRange(_target.currentGroundTile);
        foreach (var tile in tiles)
        {

            _highlighter.AddDangerededHighlightable(tile.highlightable);

            if (tile.unit)
            {
                _highlighter.AddDangerededHighlightable(tile.unit.highlightable);
            }

        }

        VFXManager m = GameObject.FindObjectOfType<VFXManager>();
        m.Play("Explosion", _target.currentGroundTile.transform);
        CameraMovement c = GameObject.FindObjectOfType<CameraMovement>();
        c.FixLookAt(m.VFXObject.transform);
        yield return new WaitForSeconds(m.GetDuration() + 1.2f);
        _highlighter.Unhighlight();

        foreach (var tile in tiles)
        {
            if (tile.unit && tile.unit != _target)
            {
                tile.unit.Hurt(_damage);
            }
        }

        _target.Hurt(int.MaxValue);
    }

    public List<GroundTile> GetTilesInRange(GroundTile centerTile)
    {
        return _ground.GetTilesInRange(centerTile, _range);
    }
}
