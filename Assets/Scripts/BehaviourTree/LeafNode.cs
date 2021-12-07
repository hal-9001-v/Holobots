using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LeafNode : BehaviourNode
{

    public LeafNode(BehaviourNode parent, Func<bool> execution) : base(parent, execution, NodeType.Leaf)
    {

    }

    public LeafNode(Func<bool> execution) : base(execution, NodeType.Leaf)
    {

    }
}
