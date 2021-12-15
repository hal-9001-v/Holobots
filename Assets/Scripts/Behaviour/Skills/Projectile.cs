using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Collider))]
[RequireComponent(typeof(Rigidbody))]
public class Projectile : MonoBehaviour
{
    TurnActor _turnActor;
    Target _owner;

    Collider _collider;
    Rigidbody _rigidbody;

    MeshRenderer _meshRenderer;

    Coroutine _launchCoroutine;

    int _damage;

    public Target damagedTarget { get; private set; }

    private void Awake()
    {
        _rigidbody = GetComponent<Rigidbody>();
        _collider = GetComponent<Collider>();
        _meshRenderer = GetComponent<MeshRenderer>();

        DisableProjectile();
    }

    private void Start()
    {
        _rigidbody.isKinematic = true;
    }
    public void DisableProjectile()
    {
        _meshRenderer.enabled = false;
        _collider.enabled = false;


    }

    public void EnableProjectile()
    {
        _meshRenderer.enabled = true;
        _collider.enabled = true;

        damagedTarget = null;

    }

    public void SetOwner(Target owner) {
        _owner = owner;
    }

    public void SetDamage(int damage) {
        _damage = damage;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (damagedTarget) return;

        var target = other.GetComponent<Target>();

        if (target && target.teamTag != _owner.teamTag)
        {
            damagedTarget = target;

            DisableProjectile();
        }


    }


}
