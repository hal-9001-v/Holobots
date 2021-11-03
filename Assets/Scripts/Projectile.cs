using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Collider))]
[RequireComponent(typeof(Rigidbody))]
public class Projectile : MonoBehaviour
{
    TurnActor _turnActor;
    Shooter _owner;

    Collider _collider;
    Rigidbody _rigidbody;

    MeshRenderer _meshRenderer;

    Coroutine _launchCoroutine;

    int _damage;

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

    /// <summary>
    /// Launch Projectile to target from origin. Y value from origin will be kept
    /// </summary>
    /// <param name="speed"></param>
    /// <param name="origin"></param>
    /// <param name="destination"></param>
    public void Launch(float speed, int damage, Shooter owner,TurnActor turnActor, Vector3 origin, Vector3 destination)
    {
        _owner = owner;
        _turnActor = turnActor;
        _damage = damage;

        destination.y = origin.y;

        if (_launchCoroutine != null)
            StopCoroutine(_launchCoroutine);

        _launchCoroutine = StartCoroutine(MoveToTarget(speed, origin, destination));
    }

    void DisableProjectile()
    {
        _meshRenderer.enabled = false;
        _collider.enabled = false;


    }

    void EnableProjectile()
    {
        _meshRenderer.enabled = true;
        _collider.enabled = true;

    }

    IEnumerator MoveToTarget(float speed, Vector3 origin, Vector3 destination)
    {

        float duration = Vector3.Distance(origin, destination) / speed;
        float elapsedTime = 0;
        transform.position = origin;

        EnableProjectile();
        while (elapsedTime < duration)
        {
            elapsedTime += Time.deltaTime;

            transform.position = Vector3.Lerp(origin, destination, elapsedTime / duration);

            yield return null;

        }

        transform.position = destination;
        DisableProjectile();
        _turnActor.EndStep();
    }

    private void OnTriggerEnter(Collider other)
    {

        var target = other.GetComponent<Target>();

        if (target && target.gameObject != _owner.gameObject)
        {
            target.Hurt(_damage);

            DisableProjectile();
        }


    }


}
