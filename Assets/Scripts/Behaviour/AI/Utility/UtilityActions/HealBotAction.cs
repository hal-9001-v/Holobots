using System;

public class HealBotAction : UtilityAction
{
    Healer _healer;

    Target _healTarget;

    public HealBotAction(Healer healer, string name, Func<float> valueCalculation) : base(name,valueCalculation)
    {
        _healer = healer;
    }

    public override void Execute()
    {
        if (_preparationAction != null)
            _preparationAction.Invoke();

        _healer.Heal(_healTarget);
    }

    public void SetHealTarget(Target target)
    {
        _healTarget = target;
    }
}
