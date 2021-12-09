using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(TurnActor))]
public class Explosioner : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(1, 5)] int _exploderCost = 1;
    [SerializeField] [Range(1, 10)] int _exploderRange = 3;

    [Header("References")]
    [SerializeField] Explosion _explosion;
    Highlighter _highlighter;

    public int explosionRange
    {
        get
        {
            return _explosion.range;
        }
    }
    
    public int exploderRange
    {
        get
        {
            return _exploderRange;
        }
    }

    ExplosionerExecuter _executer;

    private void Awake()
    {
        TurnActor _actor = GetComponent<TurnActor>();

        _executer = new ExplosionerExecuter(_actor, _explosion, _exploderCost);
    }

    public void Explode(GroundTile tile)
    {
        _executer.Execute(tile);
    }

}

class ExplosionerExecuter
{

    TurnActor _actor;
    Explosion _explosion;

    int _cost;

    Highlighter _highlighter;

    public ExplosionerExecuter(TurnActor actor, Explosion explosion, int cost)
    {
        _actor = actor;
        _explosion = explosion;

        _cost = cost;

        _highlighter = new Highlighter();
    }

    public void Execute(GroundTile tile)
    {
        _explosion.StartCoroutine(Explode(tile));
    }

    IEnumerator Explode(GroundTile centerTile)
    {
        foreach (var tile in _explosion.GetTilesInRange(centerTile))
        {

            _highlighter.AddDangerededHighlightable(tile.highlightable);

            if (tile.unit)
            {
                _highlighter.AddDangerededHighlightable(tile.unit.highlightable);
            }

        }

        _actor.StartStep(_cost);
        VFXManager m = GameObject.FindObjectOfType<VFXManager>();
        m.Play("Explosion", centerTile.transform);
        CameraMovement c = GameObject.FindObjectOfType<CameraMovement>();
        c.FixLookAt(m.VFXObject.transform);
        yield return new WaitForSeconds(m.GetDuration());
        _highlighter.Unhighlight();
        yield return new WaitForSeconds(1.2f);

        _actor.EndStep();


        _explosion.Explode(centerTile);

    }


}
