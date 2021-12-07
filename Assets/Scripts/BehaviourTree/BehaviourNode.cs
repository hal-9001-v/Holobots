using System;
using System.Collections.Generic;

public abstract class BehaviourNode
{
    public string name;

    public List<BehaviourNode> children { get; private set; }

    protected Func<bool> _execution;

    public NodeType nodeType { get; private set; }

    public BehaviourNode(BehaviourNode parent, Func<bool> executionAction, NodeType nodeType)
    {
        children = new List<BehaviourNode>();

        parent.children.Add(this);

        _execution = executionAction;

        this.nodeType = nodeType;
    }

    public BehaviourNode(Func<bool> execution, NodeType nodeType)
    {
        _execution = execution;

        children = new List<BehaviourNode>();

        this.nodeType = nodeType;
    }

    public bool Execute()
    {
        return _execution.Invoke();

    }

    public bool CheckSuccess()
    {
        return _execution.Invoke();

    }
}
