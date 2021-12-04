using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
[RequireComponent(typeof(TurnActor))]
[RequireComponent(typeof(Mover))]
public class Shooter : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 5)] int _shootCost = 1;

    public int shootCost
    {
        get
        {
            return _shootCost;
        }
    }

    int _usedShoots;
    public int usedShoots
    {
        get
        {
            return _usedShoots;
        }
    }

    [SerializeField] [Range(1, 5)] int _damage;
    [SerializeField] [Range(1, 10)] float _speed;

    [SerializeField] Projectile _projectile;

    TurnActor _turnActor;
    Target _target;
    ShooterExecuter _executer;


    private void Awake()
    {
        _turnActor = GetComponent<TurnActor>();
        _target = GetComponent<Target>();

        _projectile.SetOwner(_target);
        _projectile.SetDamage(_damage);

        _executer = new ShooterExecuter(_projectile, this, _turnActor, _speed);
    }

    public void AddShoot(Target target)
    {
        _executer.Execute(target.transform.position);
    }

    [Serializable]
    class Shoot
    {
        public GroundTile origin { get; private set; }
        public GroundTile destination { get; private set; }

        public Shoot(GroundTile origin, GroundTile destination)
        {
            this.origin = origin;
            this.destination = destination;
        }

    }
}

public class ShooterExecuter
{
    Projectile _projectile;

    TurnActor _turnActor;
    Shooter _owner;

    float _speed;

    public ShooterExecuter(Projectile projectile, Shooter owner, TurnActor turnActor, float speed)
    {
        _projectile = projectile;
        _owner = owner;

        _turnActor = turnActor;

        _speed = speed;
    }

    public void Execute(Vector3 destination)
    {
        _owner.StartCoroutine(MoveProjectileToTarget(_speed, _turnActor.transform.position, destination));
    }

    IEnumerator MoveProjectileToTarget(float speed, Vector3 origin, Vector3 destination)
    {
        _turnActor.StartStep(_owner.shootCost);

        float duration = Vector3.Distance(origin, destination) / speed;
        float elapsedTime = 0;
        _projectile.transform.position = origin;

        _projectile.EnableProjectile();
        while (elapsedTime < duration)
        {
            elapsedTime += Time.deltaTime;

            _projectile.transform.position = Vector3.Lerp(origin, destination, elapsedTime / duration);

            yield return null;

        }

        _projectile.transform.position = destination;
        _projectile.DisableProjectile();
        _turnActor.EndStep();
    }

}
