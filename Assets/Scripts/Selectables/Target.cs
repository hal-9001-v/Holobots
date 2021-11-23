using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

[RequireComponent(typeof(Selectable))]
public class Target : MonoBehaviour
{
    [Header("References")]
    [SerializeField] TextMeshPro _healthMesh;

    [Header("Settings")]
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

    public GroundTile currentGroundTile { get; private set; }

    public Action dieAction;

    void Awake()
    {
        currentHealth = _maxHealth;
    }

    void Start()
    {
        var selectable = GetComponent<Selectable>();

        selectable.selectAction += DisplayStats;
        selectable.deselectAction += HideStats;

        HideStats();
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
        currentHealth -= damage;

        if (currentHealth <= 0)
        {
            currentHealth = 0;

            Die();
        }
    }

    void Die()
    {
        if (dieAction != null)
        {
            dieAction.Invoke();

            if (currentGroundTile != null)
                currentGroundTile.FreeUnit();
        }
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

}
