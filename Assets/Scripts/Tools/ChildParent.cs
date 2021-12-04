using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChildGiver
{
    List<GameObject> _children;

    GameObject _parent;

    ChildContainer _childContainer;

    public ChildGiver(GameObject parent)
    {
        _parent = parent;

        _children = new List<GameObject>();

        _childContainer = GameObject.FindObjectOfType<ChildContainer>();
    }

    public void GiveChildrenBack()
    {
        foreach (var child in _children)
        {
            child.transform.parent = _parent.transform;
        }
    }

    public void AddChildToContainer(GameObject child)
    {
        _children.Add(child);
        _childContainer.SetGameobjectAsChild(child);

    }

    public void AddChildrenToContainer(List<GameObject> children)
    {
        foreach (var child in children)
        {
            AddChildToContainer(child);
        }
    }


}
