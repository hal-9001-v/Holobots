using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Highlighter
{
    public List<Highlightable> highlightables { get; private set; }

    public Highlighter()
    {
        highlightables = new List<Highlightable>();
    }

    public void AddHighlightable(Highlightable highlightable)
    {
        highlightables.Add(highlightable);

        highlightable.Highlight();
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
