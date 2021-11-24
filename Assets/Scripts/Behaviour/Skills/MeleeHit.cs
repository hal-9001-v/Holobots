using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeleeHit : MonoBehaviour
{
    GroundTile _currentTile;
    Renderer _renderer;


    private void Awake()
    {
        _renderer = GetComponent<Renderer>();
    }

    public void SetTile(GroundTile tile)
    {
        Show();

        _currentTile = tile;

        transform.position = new Vector3(tile.transform.position.x, transform.position.y, tile.transform.position.z);
    }

    public void Hide()
    {
        _renderer.enabled = false;
    }

    void Show()
    {
        _renderer.enabled = true;
    }

}
