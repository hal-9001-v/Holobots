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

    GameDirector _gameDirector;

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

    private void Awake()
    {
        _target = GetComponent<Target>();
        _actor = GetComponent<TurnActor>();

        _ground = FindObjectOfType<Ground>();

        _highlighter = new Highlighter();

        _vfxManager = FindObjectOfType<VFXManager>();
        _cameraMovement = FindObjectOfType<CameraMovement>();

        _gameDirector = FindObjectOfType<GameDirector>();
    }

    public void Explode()
    {
        Debug.Log(name + " selfdestructed");
        StartCoroutine(Explosion());
    }

    IEnumerator Explosion()
    {
        CountBarrier barrier = new CountBarrier(() =>
        {
            _actor.EndStep();
        });
        barrier.AddCounter();

        _actor.StartStep(int.MaxValue);
        var tiles = GetTilesInRange(_target.currentGroundTile);
        foreach (var tile in tiles)
        {

            _highlighter.AddDangerededHighlightable(tile.highlightable);

            if (tile.unit)
            {
                _highlighter.AddDangerededHighlightable(tile.unit.highlightable);
            }

        }

        _vfxManager.Play("Explosion", _target.currentGroundTile.transform, Quaternion.EulerAngles(Vector3.zero));

        _cameraMovement.FixLookAt(_vfxManager.VFXObject.transform);


        yield return new WaitForSeconds(_vfxManager.GetDuration());

        _highlighter.Unhighlight();

        //Add to counter so no hurt gives instant remove
        barrier.AddCounter();
        foreach (var tile in tiles)
        {
            if (tile.unit && tile.unit != _target)
            {
                Debug.Log(tile.unit.name);
                barrier.AddCounter();
                tile.unit.Hurt(_target, _damage, barrier);

            }
        }
        barrier.RemoveCounter();

        yield return new WaitForSeconds(1);
        _cameraMovement.FixLookAt(_vfxManager.VFXObject.transform);

        barrier.AddCounter();
        _target.Hurt(_target, int.MaxValue, barrier);

        barrier.RemoveCounter();

    }

    public List<GroundTile> GetTilesInRange(GroundTile centerTile)
    {
        return _ground.GetTilesInRange(centerTile, _range);
    }
}
