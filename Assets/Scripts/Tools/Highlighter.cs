using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Highlighter
{
    public List<Highlightable> highlightables { get; private set; }

    enum HighlightType
    {
        Danger,
        Heal

    }

    public Highlighter()
    {
        highlightables = new List<Highlightable>();
    }

    public void AddDangerededHighlightable(Highlightable highlightable)
    {
        AddHighlightable(highlightable, HighlightType.Danger);
    }

    public void AddHealedHighlightable(Highlightable highlightable)
    {
        AddHighlightable(highlightable, HighlightType.Heal);
    }

    void AddHighlightable(Highlightable highlightable, HighlightType type)
    {
        switch (type)
        {
            case HighlightType.Danger:
                highlightable.DangerHighlight();
                break;
            case HighlightType.Heal:
                highlightable.HealHighlight();
                break;
        }

        highlightables.Add(highlightable);
    }

    public void Unhighlight()
    {
        foreach (var highlightable in highlightables)
        {
            highlightable.Unhighlight();
        }

        highlightables.Clear();
    }

}
