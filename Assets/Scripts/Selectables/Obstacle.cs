using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class Obstacle : MonoBehaviour
{
    [Header("References")]
    [SerializeField] MeshRenderer _buildingRenderer;
    [SerializeField] MeshRenderer _debrisPrototype;
    Target _target;

    [Header("Settings")]
    [SerializeField] [Range(0, 3)] int _debrisDamage;
    [SerializeField] [Range(1, 3)] int _debrisWeight = 1;

    Ground _ground;
    GroundTile _tile;

    ChildGiver _childGiver;

    // Start is called before the first frame update
    void Awake()
    {

        if (_debrisPrototype)
        {
            _childGiver = new ChildGiver(gameObject);
            _childGiver.AddChildToContainer(_debrisPrototype.gameObject);
            _debrisPrototype.enabled = false;
        }
    }

    private void Start()
    {
        _ground = FindObjectOfType<Ground>();

        _target = GetComponent<Target>();
        _target.dieAction += Vacate;


        OccupyTile();
    }

    void OccupyTile()
    {
        GroundTile tile;
        var cellCoords = _ground.ToCellCoords(transform.position);
        if (_ground.groundMap.TryGetValue(cellCoords, out tile))
        {
            _tile = tile;
            tile.tileType = TileType.Untraversable;
            tile.SetUnit(_target);
        }

    }

    void Vacate()
    {
        if (_tile)
        {
            _tile.FreeUnit();
            _tile.tileType = TileType.Traversable;

            if (_buildingRenderer)
                _buildingRenderer.enabled = false;

            foreach (var collider in GetComponentsInChildren<Collider>())
            {
                collider.enabled = false;
            }

            _tile.weight = 2;

            CreateDebris();
        }


    }

    void CreateDebris()
    {
        if (_debrisPrototype)
        {
            _debrisPrototype.enabled = true;

            var cellCoords = _ground.ToCellCoords(transform.position);

            for (int i = -1; i < 2; i++)
            {
                for (int j = -1; j < 2; j++)
                {
                    GroundTile tile;
                    Vector2Int offset = new Vector2Int(i, j);

                    if (offset == Vector2.zero) continue;

                    if (_ground.groundMap.TryGetValue(cellCoords + offset, out tile))
                    {
                        if (tile.unit != null)
                        {

                            tile.unit.Hurt(_debrisDamage, null);
                        }

                        var debrisClone = Instantiate(_debrisPrototype);
                        _childGiver.AddChildToContainer(debrisClone.gameObject);
                        debrisClone.transform.position = _debrisPrototype.transform.position;

                        debrisClone.transform.position += new Vector3(offset.x * _ground.cellSize, 0, offset.y * _ground.cellSize);

                        debrisClone.enabled = true;

                        tile.weight = _debrisWeight;
                    }


                }
            }
        }


    }

}
