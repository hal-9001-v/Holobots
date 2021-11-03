using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(LineRenderer))]
public class GridLine : MonoBehaviour
{
    LineRenderer _line;

    private void Awake()
    {
        _line = GetComponent<LineRenderer>();
    }

    public void SetPoints(Vector3[] points)
    {
        _line.positionCount = points.Length;

        for (int i = 0; i < points.Length; i++)
        {
            points[i].y = transform.position.y;
        }

        _line.SetPositions(points);
    }

    public void HideLine() {
        _line.positionCount = 0;
    }
}
