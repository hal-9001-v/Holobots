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

    VFXManager _vfxManager;

    public Target damagedTarget { get; private set; }

    private void Awake()
    {
        _rigidbody = GetComponent<Rigidbody>();
        _collider = GetComponent<Collider>();
        _meshRenderer = GetComponent<MeshRenderer>();

        _vfxManager = FindObjectOfType<VFXManager>();

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

    private void OnTriggerEnter(Collider other)
    {
        if (damagedTarget) return;

        var target = other.GetComponent<Target>();

        if (target && target.teamTag != _owner.teamTag)
        {
            damagedTarget = target;

            _vfxManager.PlaySpark(transform);

            DisableProjectile();


        }


    }


}
