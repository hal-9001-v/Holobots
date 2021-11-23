using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shield : MonoBehaviour
{
    MeshRenderer[] _renderers;

    private void Awake()
    {
        _renderers = GetComponentsInChildren<MeshRenderer>();

        TurnOff();
    }

    public void TurnOff()
    {
        foreach (var renderer in _renderers)
        {
            renderer.enabled = false;
        }
    }

    public void TurnOn()
    {
        foreach (var renderer in _renderers)
        {
            renderer.enabled = true;
        }
    }

    public void SetTile(GroundTile tile)
    {
        TurnOn();

        var newPosition = tile.transform.position;
        newPosition.y = transform.position.y;

        transform.position = newPosition;


        TurnOn();
    }
}
