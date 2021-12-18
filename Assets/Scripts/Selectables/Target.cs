
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

    public Action<CountBarrier> dieAction;

    CameraMovement _cameraMovement;

    void Awake()
    {
        highlightable = GetComponent<Highlightable>();
        _dissolver = GetComponent<Dissolver>();

        currentHealth = _maxHealth;
        _cameraMovement = FindObjectOfType<CameraMovement>();


        var selectable = GetComponent<Selectable>();
        selectable.selectAction += DisplayStats;
        selectable.deselectAction += HideStats;

        dieAction += (barrier) =>
        {
            selectable.DisableSelection();
        }; 
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

    public void Hurt(int damage, CountBarrier barrier)
    {
        int fixedDamage;

        if (currentGroundTile.shield)
        {
            currentGroundTile.shield.HurtShield(damage, out fixedDamage);
        }
        else
        {
            fixedDamage = damage;
        }

        currentHealth -= fixedDamage;
        UpdateText();

        if (currentHealth <= 0)
        {
            currentHealth = 0;

            Die(barrier);

        }
        else if (barrier != null)
        {
            //Here goes cinematic hit when getting damage. It should go on a coroutine.
            barrier.RemoveCounter();
        }
    }

    void Die(CountBarrier barrier)
    {
        _cameraMovement.FixLookAt(this.transform);

        if (currentGroundTile != null)
            currentGroundTile.FreeUnit();

        Debug.Log(name + " died");

        if (dieAction != null)
        {
            dieAction.Invoke(barrier);
        }

        if (_dissolver)
        {
            _dissolver.Dissolve(barrier);
        }
        else if(barrier != null)
        {
            barrier.RemoveCounter();
        }

    }

    void DisplayStats()
    {
        if (_healthMesh)
        {
            _healthMesh.enabled = true;
            UpdateText();
        }
    }

    void UpdateText()
    {
        if (_healthMesh)
        {
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

}
