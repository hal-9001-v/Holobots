using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public struct Charge
{
    public GroundTile destination
    {
        get
        {
            if (path.Count != 0)
                return path[path.Count - 1];

            return null;
        }

    }

    public List<GroundTile> path { get; private set; }

    public Vector2Int direction { get; private set; }

    public Charge(List<GroundTile> path, Vector2Int direction)
    {
        this.path = path;
        this.direction = direction;
    }

}
