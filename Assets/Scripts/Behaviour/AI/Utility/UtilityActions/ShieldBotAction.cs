using System;

public class ShieldBotAction : UtilityAction
{
    Shielder _shielder;

    Target _shieldTarget;

    public ShieldBotAction(Shielder shielder, Func<float> valueCalculation) : base(valueCalculation)
    {
        _shielder = shielder;
    }

    public override void Execute()
    {
        if (_preparationAction != null)
            _preparationAction.Invoke();

        _shielder.SetProtectingShield(_shieldTarget.currentGroundTile);
    }

    public void SetShieldTarget(Target target)
    {
        _shieldTarget = target;
    }
}
