using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ground : MonoBehaviour
{
    [Header("References")]
    [SerializeField] Generation _generation;
    [SerializeField] GroundTile[] _tiles;

    [Header("Generation")]
    [SerializeField] [Range(0.01f, 2)] float _variation;
    [SerializeField] float _maxX;
    [SerializeField] float _maxY;

    [SerializeField] WeightedTile[] _tilePrefabs;
    float _totalWeight;

    public Dictionary<Vector2Int, GroundTile> groundMap;

    [Header("Settings")]
    [SerializeField] [Range(0.1f, 5f)] float _cellSize;
    [SerializeField] Color _gizmosColor;

    public float cellSize
    {
        get
        {
            return _cellSize;
        }
    }

    const float RootOf2 = 1.41421356f;
    const float MinimumFloatValue = 0.01f;


    enum Generation
    {
        GetFromScene,
        Random
    }

    private void Awake()
    {
        switch (_generation)
        {
            case Generation.GetFromScene:
                break;

            case Generation.Random:
                GenerateMap();
                break;

            default:
                break;
        }

        SetGroundGridFromScene();

        foreach (var target in FindObjectsOfType<Target>())
        {
            GroundTile tile;

            if (groundMap.TryGetValue(ToCellCoords(target.transform.position), out tile))
            {
                target.SetCurrentGroundTile(tile);
            }
        }
    }

    void GenerateMap()
    {
        SetGroundGridFromScene();

        float baseX = UnityEngine.Random.Range(-_maxX, _maxX);
        float basey = UnityEngine.Random.Range(-_maxY, _maxY);

        foreach (var prefab in _tilePrefabs)
        {
            _totalWeight += prefab.weight;
        }

        for (int i = 0; i < _maxX; i++)
        {
            for (int j = 0; j < _maxY; j++)
            {
                GroundTile outTile;
                if (groundMap.TryGetValue(new Vector2Int(i, j), out outTile) == false)
                {
                    float noiseValue = Mathf.PerlinNoise(baseX + i * _variation, basey + j * _variation);

                    var tile = GetTilePrefab(noiseValue);

                    var newTile = Instantiate(tile, new Vector3(i * _cellSize, 0, j * _cellSize), Quaternion.identity);

                    newTile.transform.parent = transform;
                }
            }

        }

    }

    GameObject GetTilePrefab(float value)
    {
        float accumulatedWeight = 0;

        for (int i = 0; i < _tilePrefabs.Length; i++)
        {
            accumulatedWeight += _tilePrefabs[i].weight / _totalWeight;

            if (value < accumulatedWeight)
            {
                Debug.Log(i);
                return _tilePrefabs[i].tilePrefab;
            }

        }

        return _tilePrefabs[_tilePrefabs.Length - 1].tilePrefab;
    }

    [ContextMenu("Set Ground Grid")]
    void SetGroundGridFromScene()
    {
        _tiles = GetComponentsInChildren<GroundTile>();
        groundMap = new Dictionary<Vector2Int, GroundTile>();

        if (_tiles != null && _tiles.Length != 0)
        {
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

        if (CanTraspassTile(destination, profile))
        {
            currentNode = destination;
        }
        else
        {
            currentNode = destination.parent;
        }

        origin.parent = null;

        while (currentNode != null && currentNode.parent != null)
        {
            path.Push(currentNode);

            currentNode = currentNode.parent;
        }

        path.Push(currentNode);


        //If path's count is 1, then no path has been found unless origin is neighbour of destination. That node in path is the just destination node
        if (path.Count == 1)
        {
            bool found = false;

            foreach (var neightbour in origin.neighbours)
            {
                if (neightbour == destination)
                {
                    found = true;
                    break;
                }
            }

            if (found == false)
            {
                path.Clear();

            }
        }

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
        if (a == b) return 0;

        var path = GetPath(a, b, profile);

        if (path.Length == 0)
            return int.MaxValue;

        return path.Length;
    }

    void CheckNeighbour(GroundTile currentNode, GroundTile neighbour, bool isDestination, List<GroundTile> openNodes, PathProfile profile)
    {
        if (!isDestination && !CanTraspassTile(neighbour, profile)) return;

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
        Vector3 v = worldPosition;

        v /= _cellSize;

        return new Vector2Int(Mathf.RoundToInt(v.x), Mathf.RoundToInt(v.z));
    }

    bool CanTraspassTile(GroundTile tile, PathProfile profile)
    {
        if (tile.unit) return false;

        if (!profile.canTraspass && tile.tileType == TileType.Untraversable) return false;

        if (!profile.canFly && tile.tileType == TileType.Void) return false;

        return true;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = _gizmosColor;
        for (int i = 0; i < _maxX; i++)
        {
            for (int j = 0; j < _maxY; j++)
            {
                Gizmos.DrawWireCube(new Vector3(_cellSize * i, 0, _cellSize * j), new Vector3(_cellSize, _cellSize, _cellSize));
            }

        }
    }


    [Serializable]
    struct WeightedTile
    {
        public GameObject tilePrefab;
        public int weight;
    }
}

