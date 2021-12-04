using System.Collections.Generic;

public abstract class BehaviourNode
{
    public string name;

    public List<BehaviourNode> children { get; private set;}

    public NodeType nodeType { get; private set;}

    public BehaviourNode(NodeType type)
    {
        nodeType = type;

        children = new List<BehaviourNode>();

    }

    public BehaviourNode(BehaviourNode parent, NodeType type)
    {
        parent.children.Add(this);

        nodeType = type;

        children = new List<BehaviourNode>();

    }

    public abstract void Execute();
}
