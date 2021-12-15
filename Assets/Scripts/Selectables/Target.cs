
using System;
using TMPro;
using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Selectable))]
[RequireComponent(typeof(Highlightable))]
public class Target : MonoBehaviour
{
    [Header("References")]
    [SerializeField] TextMeshPro _healthMesh;

    [Header("Settings")]
    [SerializeField] TargetType _targetType;
    [SerializeField] TeamTag _teamTag;

    private string _targetCode;
    public string targetCode
    {
        get
        {
            return _targetCode;
        }
    }

    public TargetType targetType
    {
        get
        {
            return _targetType;
        }
    }

    public TeamTag teamTag
    {
        get
        {
            return _teamTag;
        }
    }

    [SerializeField] [Range(0, 10)] int _maxHealth;

    public int currentHealth { get; private set; }
    public int maxHealth
    {
        get
        {
            return _maxHealth;
        }
    }

    public bool isAlive
    {
        get
        {
            return currentHealth > 0;
        }
    }

    Dissolver _dissolver;

    public Highlightable highlightable { get; private set; }

    public GroundTile currentGroundTile { get; private set; }

    public Action dieAction;

    CameraMovement _cameraMovement;

    void Awake()
    {
        highlightable = GetComponent<Highlightable>();
        _dissolver = GetComponent<Dissolver>();

        var selectable = GetComponent<Selectable>();

        selectable.selectAction += DisplayStats;
        selectable.deselectAction += HideStats;

        dieAction += selectable.DisableSelection;

        currentHealth = _maxHealth;

        _cameraMovement = FindObjectOfType<CameraMovement>();
    }

    void Start()
    {


        GenerateTargetCode();
        HideStats();
    }

    private void GenerateTargetCode()
    {

        _targetCode = "";
        _targetCode += UnityEngine.Random.Range(0, 10);
        _targetCode += UnityEngine.Random.Range(0, 10);
        _targetCode += UnityEngine.Random.Range(0, 10);
        _targetCode += UnityEngine.Random.Range(0, 10);

    }

    public void SetCurrentGroundTile(GroundTile tile)
    {
        if (currentGroundTile != null)
            currentGroundTile.FreeUnit();

        currentGroundTile = tile;
        currentGroundTile.SetUnit(this);
    }

    public float Hurt(int damage)
    {
        bool hurtPlayer = false;
        int fixedDamage = 0;

        if (currentGroundTile.shield)
        {
            if (currentGroundTile.shield.HurtShield(damage, out fixedDamage))
            {
                hurtPlayer = true;
            }

        }
        else
        {
            fixedDamage = damage;
            hurtPlayer = true;
        }

        if (hurtPlayer)
        {
            currentHealth -= fixedDamage;

            if (currentHealth <= 0)
            {
                currentHealth = 0;

                return Die();
            }
        }

        return 0;
    }

    float Die()
    {
        _cameraMovement.FixLookAt(this.transform);

        if (currentGroundTile != null)
            currentGroundTile.FreeUnit();

        Debug.Log(name + " died");

        if (dieAction != null)
        {
            dieAction.Invoke();
        }

        if (_dissolver)
        {
            return _dissolver.Dissolve();
        }

        return 0;

    }

    void DisplayStats()
    {
        if (_healthMesh)
        {
            _healthMesh.enabled = true;
            _healthMesh.text = currentHealth.ToString() + "/" + _maxHealth.ToString();
        }
    }

    void HideStats()
    {

        if (_healthMesh)
        {
            _healthMesh.enabled = false;
        }
    }

    public void Heal(int points)
    {
        currentHealth += Math.Abs(points);

        if (currentHealth > _maxHealth)
        {
            currentHealth = _maxHealth;
        }
    }

    [ContextMenu("Die")]
    void DieC()
    {

        Die();

    }

}
