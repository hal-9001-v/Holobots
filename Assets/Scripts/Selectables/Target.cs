
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
    [SerializeField] TeamTag _team;
    
    private string _targetCode;
    public String targetCode{
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

    public TeamTag team
    {
        get
        {
            return _team;
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

    public bool isDead
    {
        get
        {
            return currentHealth <= 0;
        }
    }

    public Highlightable highlightable { get; private set; }

    public GroundTile currentGroundTile { get; private set; }

    public Action dieAction;

    void Awake()
    {
        highlightable = GetComponent<Highlightable>();

        currentHealth = _maxHealth;
    }

    void Start()
    {
        var selectable = GetComponent<Selectable>();

        selectable.selectAction += DisplayStats;
        selectable.deselectAction += HideStats;
        GenerateTargetCode();
        HideStats();
    }

    private void GenerateTargetCode(){

      _targetCode = "";
      _targetCode+= UnityEngine.Random.Range(0,10);
      _targetCode+= UnityEngine.Random.Range(0,10);
      _targetCode+= UnityEngine.Random.Range(0,10);
      _targetCode+= UnityEngine.Random.Range(0,10);
      
    }

    public void SetCurrentGroundTile(GroundTile tile)
    {
        if (currentGroundTile != null)
            currentGroundTile.FreeUnit();

        currentGroundTile = tile;
        currentGroundTile.SetUnit(this);
    }

    public void Hurt(int damage)
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

                Die();
            }
        }
    }



   void Die()
    {
        Debug.Log(this.name + " is dead");
        StartCoroutine(DieCoroutine());
        DissolvingController d = GetComponent<DissolvingController>();
        if(d !=null)  StartCoroutine(d.Dissolve());
    }

    public IEnumerator DieCoroutine(){
        CameraMovement c = FindObjectOfType<CameraMovement>();
        c.FixLookAt(this.transform);
        yield return new WaitForSeconds(2);
        if (dieAction != null)
                {
                    dieAction.Invoke();
                }

                if (currentGroundTile != null)
                    currentGroundTile.FreeUnit();
        DestroyImmediate(gameObject);
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

        [ContextMenu("Die")] void DieC(){

        Die();

    }
    
}
