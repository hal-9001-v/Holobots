using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Selectable))]
public class GroundTile : MonoBehaviour
{
    [Header("Settings")]

    public GroundTile[] neighbours;

    public bool isClosed;

    public TileType tileType;


    [Range(0, 10)] public int weight = 1;

    [HideInInspector]
    public float gCost;
    [HideInInspector]
    public GroundTile parent;

    public Target unit { get; private set; }

    public Vector2Int cellCoord { get; private set; }

    public void SetUnit(Target target)
    {
        unit = target;
    }

    public void FreeUnit()
    {
        unit = null;
    }

    public void SetCellCoord(Vector2Int v)
    {
        cellCoord = v;
    }

    public void GetNeighBours(Dictionary<Vector2Int, GroundTile> groundGrid)
    {
        List<GroundTile> newNeighbours = new List<GroundTile>();
        GroundTile neighbour;
        for (int i = -1; i < 2; i++)
        {
            if (i == 0) continue;

            if (groundGrid.TryGetValue(cellCoord + new Vector2Int(i, 0), out neighbour))
            {
           
                newNeighbours.Add(neighbour);

            }
           
        }

        for (int i = -1; i < 2; i++)
        {
            if (i == 0) continue;

            if (groundGrid.TryGetValue(cellCoord + new Vector2Int(0, i), out neighbour))
            {

                newNeighbours.Add(neighbour);

            }

        }

        neighbours = newNeighbours.ToArray();

    }

    public void GetHexagonalNeighBours(Dictionary<Vector2Int, GroundTile> groundGrid)
    {
        List<GroundTile> newNeighbours = new List<GroundTile>();
        GroundTile neighbour;
        for (int i = -1; i < 2; i++)
        {
            for (int j = -1; j < 2; j++)
            {
                if (i == 0 && j == 0) continue;

                if (groundGrid.TryGetValue(cellCoord + new Vector2Int(i, j), out neighbour))
                {

                    newNeighbours.Add(neighbour);

                }
            }
        }

        this.neighbours = newNeighbours.ToArray();

    }

}
