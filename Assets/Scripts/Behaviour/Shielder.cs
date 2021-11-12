using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shielder : MonoBehaviour
{

    Ground _ground;
    GroundTile _tile;

    [Header("Referenes")]
    [SerializeField] Shield _centerShield;
    [SerializeField] Shield _leftShield;
    [SerializeField] Shield _rightShield;


    bool _isFacingX;
    private void Awake()
    {
        _ground = FindObjectOfType<Ground>();
    }


    public void SetShield(GroundTile tile)
    {
        _tile = tile;

        _centerShield.SetTile(tile);

        GroundTile neighbourTile;


        Vector2Int offset;
        if (_isFacingX)
        {
            offset = new Vector2Int(1, 0);
        }
        else
        {
            offset = new Vector2Int(0, 1);
        }

        if (_ground.groundMap.TryGetValue(tile.cellCoord + offset, out neighbourTile))
        {
            _leftShield.SetTile(neighbourTile);
        }

        if (_ground.groundMap.TryGetValue(tile.cellCoord + offset * (-1), out neighbourTile))
        {
            _rightShield.SetTile(neighbourTile);
        }

    }

    public void RotateShield()
    {
        if (_isFacingX)
        {

        }
        //It is facing Z
        else
        {

        }

        _isFacingX = !_isFacingX;
    }

}
