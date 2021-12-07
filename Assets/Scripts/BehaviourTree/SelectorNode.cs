using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectorNode : BehaviourNode
{
    public SelectorNode(BehaviourNode parent) : base(parent, null, NodeType.Selector)
    {

    }

    public SelectorNode() : base(null, NodeType.Selector)
    {

    }
}
