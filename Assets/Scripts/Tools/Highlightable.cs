using UnityEngine;

public class Highlightable : MonoBehaviour
{
    [Header("References")]
    [SerializeField] Material _dangerMaterial;
    [SerializeField] Material _healMaterial;

    Renderer[] _renderers;

    Material[] _originalMaterials;

    private void Awake()
    {
        _renderers = GetComponentsInChildren<Renderer>();

        if (_renderers != null && _renderers.Length != 0)
        {
            _originalMaterials = new Material[_renderers.Length];

            for (int i = 0; i < _renderers.Length; i++)
            {
                _originalMaterials[i] = _renderers[i].material;
            }

        }
    }

    [ContextMenu("Hightlight")]
    public void DangerHighlight()
    {
        SetMaterial(_dangerMaterial);
    }

    public void HealHighlight()
    {
        SetMaterial(_healMaterial);
    }

    [ContextMenu("Unhightlight")]
    public void Unhighlight()
    {
        for (int i = 0; i < _renderers.Length; i++)
        {
            if (_renderers[i].material != null) _renderers[i].material = _originalMaterials[i];
        }
    }

    void SetMaterial(Material material)
    {
        foreach (var render in _renderers)
        {
            render.material = material;
        }
    }


}
