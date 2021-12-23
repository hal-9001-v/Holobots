using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;
public class SkinnedMeshToMesh : MonoBehaviour
{
    public SkinnedMeshRenderer skinnedMesh;
    public VisualEffect VFXGraph;
    public float refreshRate;

    private void Awake()
    {
        refreshRate = 0.02f;
    }

    public IEnumerator UpdateVFXGraph()
    {
        while (gameObject.activeSelf)
        {
            Mesh m = new Mesh();
            skinnedMesh.BakeMesh(m);
            Vector3[] vertices = m.vertices;
            Mesh m2 = new Mesh();
            m2.vertices = m.vertices;
            VFXGraph.SetMesh("Mesh", m2);

            yield return new WaitForSeconds(refreshRate);
        }
    }
}
