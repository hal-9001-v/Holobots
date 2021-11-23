using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SkillSelector : MonoBehaviour
{
    [Header("References")]
    [SerializeField] SkillHolder[] _skillHolders;

    PlayerUnit _selectedUnit;
    SkillHolder _selectedSkill;

    public void SetSelectedUnit(PlayerUnit unit)
    {
        _selectedUnit = unit;

        UpdateSkillHolders();

        //Select First Adapter
        SetSelectedSkill(_skillHolders[0]);
    }

    public void SetSelectedSkill(SkillHolder selectedSkill)
    {
        foreach (var skill in _skillHolders)
        {
            skill.DeselectSkill();
        }

        _selectedSkill = selectedSkill;
        _selectedSkill.SelectSkill();
    }

    void UpdateSkillHolders()
    {
        foreach (var holder in _skillHolders)
        {
            holder.Hide();
        }

        for (int i = 0; i < _selectedUnit.adapters.Count; i++)
        {
            if (i >= _skillHolders.Length)
            {
                Debug.LogWarning("Not enough SkillHolders for unit " + _selectedUnit.name + "!");

                break;
            }

            _skillHolders[i].Show(_selectedUnit.adapters[i]);
        }
    }

}
