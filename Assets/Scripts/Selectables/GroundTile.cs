using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Selectable))]
[RequireComponent(typeof(Highlightable))]
public class GroundTile : MonoBehaviour
{
    [Header("Settings")]
    public GroundTile[] neighbours;
    public TileType tileType;

    [Range(0, 10)] public int weight = 1;

    public Shield shield { get; private set; }

    public Target unit { get; private set; }
    public Vector2Int cellCoord { get; private set; }
    public Highlightable highlightable { get; private set; }

    [HideInInspector]
    public bool isClosed;
    [HideInInspector]
    public float gCost;
    [HideInInspector]
    public GroundTile parent;

    Vector3 _originalPosition;
    Vector3 _introStartingPosition;
    Vector3 _unitIntroStartingPosition;

    [SerializeField] Vector2 _cordsOffset;
    [SerializeField] [Range(-25, -1)] float _introDepth;
    [SerializeField] [Range(1, 20)] float _introSpeed;

    private void Awake()
    {
        highlightable = GetComponent<Highlightable>();
    }

    void Start()
    {
        IntroAnimation();
    }
    void IntroAnimation()
    {
        _originalPosition = transform.position;
        _introStartingPosition = _originalPosition + new Vector3(0, 0.1f + _cordsOffset.x * Mathf.Abs(cellCoord.x) + _cordsOffset.y * Mathf.Abs(cellCoord.y), 0) * _introDepth;

        if (unit)
        {
            _unitIntroStartingPosition = unit.transform.position;
        }

        StartCoroutine(IntroAnimationCoroutine());
    }

    IEnumerator IntroAnimationCoroutine()
    {
        float elapsedTime = 0;

        float introTime = Vector3.Distance(_introStartingPosition, _originalPosition) / _introSpeed;

        while (elapsedTime < introTime)
        {
            elapsedTime += Time.deltaTime;

            transform.position = Vector3.Lerp(_introStartingPosition, _originalPosition, elapsedTime / introTime);

            if (unit)
            {
                unit.transform.position = Vector3.Lerp(_introStartingPosition, _unitIntroStartingPosition, elapsedTime / introTime);
            }

            yield return null;
        }

        transform.position = _originalPosition;
    }

    public void SetShield(Shield shield)
    {
        this.shield = shield;
    }

    public void UnsetShield(Shield shield)
    {
        if (this.shield == shield)
        {
            this.shield = null;
        }
    }


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
