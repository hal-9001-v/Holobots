using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shield : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 10)] int _maxHealth;

    public int currentHealthPoints { get; private set; }

    MeshRenderer[] _renderers;
    Collider[] _colliders;

    GroundTile _currentTile;

    private void Awake()
    {
        _renderers = GetComponentsInChildren<MeshRenderer>();
        _colliders = GetComponentsInChildren<Collider>();
        TurnOff();
    }

    public void TurnOff()
    {
        if (_renderers != null)
        {
            foreach (var renderer in _renderers)
            {
                renderer.enabled = false;
            }
        }

        if (_colliders != null)
        {
            foreach (var collider in _colliders)
            {
                collider.enabled = false;
            }
        }

        if (_currentTile)
        {
            _currentTile.UnsetShield(this);
            _currentTile = null;
        }
    }

    public void TurnOn()
    {
        currentHealthPoints = _maxHealth;

        foreach (var renderer in _renderers)
        {
            renderer.enabled = true;
        }

        foreach (var collider in _colliders)
        {
            collider.enabled = true;
        }
    }

    public void SetTile(GroundTile tile)
    {
        TurnOn();

        var newPosition = tile.transform.position;
        newPosition.y = transform.position.y;

        transform.position = newPosition;

        _currentTile = tile;
        tile.SetShield(this);
    }


    /// <summary>
    ///Hurt shield and return true if shield didnt resist the hit.
    /// </summary>
    /// <param name="damage"></param>
    /// <param name="target">Target which whill get hurt if the shield is destroyed. If null, no damage will occur.</param>
    /// <returns></returns>
    public bool HurtShield(int damage, out int extraDamage)
    {
        currentHealthPoints -= damage;

        if (currentHealthPoints <= 0)
        {
            extraDamage = -currentHealthPoints;

            TurnOff();

            return true;
        }
        else
        {
            extraDamage = 0;
        }

        return false;
    }

}
