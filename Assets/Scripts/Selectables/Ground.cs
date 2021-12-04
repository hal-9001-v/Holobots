using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ground : MonoBehaviour
{

    [Header("References")]
    [SerializeField] GroundTile[] _tiles;

    public Dictionary<Vector2Int, GroundTile> groundMap;

    public byte[][] byteMap;

    [Header("Settings")]
    [SerializeField] [Range(0.1f, 5f)] float _cellSize;

    GroundTile _zeroTile;

    public float cellSize
    {
        get
        {
            return _cellSize;
        }
    }

    [SerializeField] [Range(0.1f, 1)] float _gizmosSize;

    const float RootOf2 = 1.41421356f;
    const float MinimumFloatValue = 0.01f;

    private void Awake()
    {
        SetGroundGrid();

        foreach (var target in FindObjectsOfType<Target>())
        {
            GroundTile tile;

            if (groundMap.TryGetValue(ToCellCoords(target.transform.position), out tile))
            {
                target.SetCurrentGroundTile(tile);
            }
        }
    }

    [ContextMenu("Set Ground Grid")]
    void SetGroundGrid()
    {

        _tiles = GetComponentsInChildren<GroundTile>();

        _zeroTile = _tiles[0];

        foreach (var tile in _tiles)
        {
            if (tile.transform.position.x - _zeroTile.transform.position.x < 0.01f)
            {
                if (tile.transform.position.z - _zeroTile.transform.position.z < 0.01f)
                {
                    _zeroTile = tile;
                }
            }
        }

        _zeroTile = _tiles[0];
        groundMap = new Dictionary<Vector2Int, GroundTile>();

        for (int i = 0; i < _tiles.Length; i++)
        {
            var cellCoord = ToCellCoords(_tiles[i].transform.position);
            _tiles[i].SetCellCoord(cellCoord);

            _tiles[i].name = "Cell (" + cellCoord.x + ", " + cellCoord.y + ")";
            groundMap.Add(_tiles[i].cellCoord, _tiles[i]);

        }

        for (int i = 0; i < _tiles.Length; i++)
        {
            _tiles[i].GetNeighBours(groundMap);
        }

    }

    public GroundTile[] GetPath(GroundTile origin, GroundTile destination, PathProfile profile)
    {
        List<GroundTile> openNodes = new List<GroundTile>();

        foreach (var tile in _tiles)
        {
            tile.gCost = float.MaxValue;
            tile.isClosed = false;
            tile.parent = null;
        }

        //If not, it will be float.MaxValue and it may have some problems since it will be needed to add its weight to compare its succesors gCosts with (origin.gCost + weight)
        origin.gCost = 0;
        openNodes.Add(origin);

        GroundTile currentNode;

        while (openNodes.Count != 0)
        {
            currentNode = openNodes[0];
            openNodes.RemoveAt(0);

            currentNode.isClosed = true;

            //if (currentNode == destination) break;

            foreach (GroundTile neighbour in currentNode.neighbours)
            {
                if (neighbour == destination)
                    CheckNeighbour(currentNode, neighbour, true, openNodes, profile);
                else
                    CheckNeighbour(currentNode, neighbour, false, openNodes, profile);

            }
        }

        Stack<GroundTile> path = new Stack<GroundTile>();
        currentNode = destination;
        origin.parent = null;

        while (currentNode.parent != null)
        {
            path.Push(currentNode);

            currentNode = currentNode.parent;
        }

        path.Push(currentNode);

        //If path's count is 1, then no path has been found. That node in path is the just destination node
        if (path.Count == 1)
            path.Clear();

        return path.ToArray();
    }

    public List<GroundTile> GetTilesInRange(GroundTile center, int range)
    {
        List<GroundTile> avaliableTiles = new List<GroundTile>();

        for (int i = (-range + 1); i < range; i++)
        {
            for (int j = (-range + 1); j < range; j++)
            {
                GroundTile tile;
                if (groundMap.TryGetValue(center.cellCoord + new Vector2Int(i, j), out tile))
                {
                    avaliableTiles.Add(tile);
                }
            }
        }

        return avaliableTiles;
    }

    public int GetDistance(GroundTile a, GroundTile b, PathProfile profile)
    {
        var path = GetPath(a, b, profile);

        if (path.Length == 0)
            return int.MaxValue;

        return path.Length;
    }

    void CheckNeighbour(GroundTile currentNode, GroundTile neighbour, bool isDestination, List<GroundTile> openNodes, PathProfile profile)
    {
        if (!isDestination)
        {
            if (neighbour.unit) return;
            if (!profile.canTraspass && neighbour.tileType == TileType.Untraversable) return;
        }


        if (neighbour.isClosed) return;


        float fixedWeight = currentNode.weight;

        //If it is diagonal
        if (currentNode.cellCoord.x != neighbour.cellCoord.x && currentNode.cellCoord.y != neighbour.cellCoord.y)
        {
            fixedWeight *= RootOf2;
        }

        if (neighbour.gCost > (currentNode.gCost + fixedWeight))
        {
            neighbour.parent = currentNode;
            neighbour.gCost = currentNode.gCost + fixedWeight;

            if (!openNodes.Contains(neighbour))
            {
                openNodes.Add(neighbour);
            }

            openNodes.Sort(delegate (GroundTile a, GroundTile b)
            {
                if (a.gCost < b.gCost)
                    return -1;
                else
                    return 1;

            });
        }

    }

    public Vector3[] GetPointsOfPath(GroundTile origin, GroundTile destination, PathProfile pathProfile)
    {
        GroundTile[] path = GetPath(origin, destination, pathProfile);

        Vector3[] points = new Vector3[path.Length];

        for (int i = 0; i < path.Length; i++)
        {
            points[i] = path[i].transform.position;
        }

        return points;

    }

    public Vector2Int ToCellCoords(Vector3 worldPosition)
    {
        Vector3 v = worldPosition - _zeroTile.transform.position;

        v /= _cellSize;

        return new Vector2Int(Mathf.RoundToInt(v.x), Mathf.RoundToInt(v.z));
    }

    private void OnDrawGizmos()
    {
        if (_zeroTile)
        {
            Gizmos.DrawSphere(_zeroTile.transform.position, _gizmosSize * 0.5f);
            Gizmos.DrawWireCube(_zeroTile.transform.position, new Vector3(_gizmosSize, _gizmosSize, _gizmosSize));

        }
    }



}

