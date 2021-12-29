using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Target))]
public class Healer : MonoBehaviour
{
    [Header("Settings")]

    [SerializeField] [Range(1, 10)] int _heal;
    [SerializeField] [Range(1, 10)] int _healRange;
    [SerializeField] [Range(1, 5)] int _healCost;

    TurnActor _turnActor;

    HealerExecuter _executer;



    public int range
    {
        get
        {
            return _healRange;
        }
    }

    private void Awake()
    {
        _turnActor = GetComponent<TurnActor>();


        var rotator = GetComponentInChildren<CharacterRotator>();
        var cameraMovement = FindObjectOfType<CameraMovement>();
        var vfxManager = FindObjectOfType<VFXManager>();

        _executer = new HealerExecuter(_turnActor, rotator, vfxManager, cameraMovement, _healCost);
    }

    public void Heal(Target target)
    {
        Debug.Log(_turnActor.name + " is healing " + target.name + " " + _heal + " points");
        _executer.Execute(target, _heal);
    }

}

class HealerExecuter
{
    TurnActor _actor;
    int _cost;

    Highlighter _highlighter;

    CharacterRotator _rotator;

    VFXManager _vfxManager;
    CameraMovement _cameraMovement;

    public HealerExecuter(TurnActor actor, CharacterRotator rotator, VFXManager vfxManager, CameraMovement cameraMovement, int cost)
    {
        _actor = actor;
        _cost = cost;

        _rotator = rotator;

        _vfxManager = vfxManager;
        _cameraMovement = cameraMovement;

        _highlighter = new Highlighter();
    }

    public void Execute(Target target, int points)
    {
        _actor.StartCoroutine(Heal(target, points));
    }

    IEnumerator Heal(Target target, int points)
    {
        _actor.StartStep(_cost);

        _highlighter.AddHealedHighlightable(target.highlightable);
        _highlighter.AddHealedHighlightable(target.currentGroundTile.highlightable);

        if (_rotator)
        {
            var direction = target.transform.position - _actor.transform.position;
            direction.Normalize();

            _rotator.SetForward(direction, 0.35f);
        }

        _vfxManager.Play("Heal", target.transform,Quaternion.EulerAngles(Vector3.zero));
        _cameraMovement.FixLookAt(target.transform);

        yield return new WaitForSeconds(_vfxManager.GetDuration()-1.5f);

        target.Heal(points);

        _highlighter.Unhighlight();

        _actor.EndStep();
    }

}
