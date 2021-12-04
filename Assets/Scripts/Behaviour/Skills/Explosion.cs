using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Explosion : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 10)] int _damage = 2;
    [SerializeField] [Range(1, 10)] int _range = 2;

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
        _ground = FindObjectOfType<Ground>();
    }

    public void Explode(GroundTile centerTile)
    {
        var tiles = _ground.GetTilesInRange(centerTile, _range);

        foreach (var tile in tiles)
        {
            if (tile.unit)
            {
                tile.unit.Hurt(_damage);
            }
        }
    }
}
