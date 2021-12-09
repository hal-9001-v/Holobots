using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;
public class DissolvingController : MonoBehaviour
{
   [SerializeField]Animator anim;
   [SerializeField] SkinnedMeshRenderer skinnedMesh;
   [SerializeField] MeshRenderer[] meshes;
    [SerializeField] VisualEffect VFXGraph;

    public float dissolveRate =  0.02f;
    public float refreshRate = 0.05f;

    private List<Material> dissolveMaterials;


    private void Awake() {
        
        if(VFXGraph != null) {

            VFXGraph.gameObject.SetActive(false);

        }

        dissolveMaterials = new List<Material>();
        if(skinnedMesh!=null) {

            foreach(Material m in skinnedMesh.materials){

                dissolveMaterials.Add(m);

            }

        } else if(meshes!=null) {

            for(int i = 0; i<meshes.Length; i++){

                foreach(Material m in meshes[i].materials){
                    dissolveMaterials.Add(m);
                }
            }

        }

    }

    private void Update() {
        if(Input.GetKeyDown(KeyCode.Space)){

            StartCoroutine(Dissolve());

        }
    }


    IEnumerator Dissolve(){

        if(anim!=null){
            
            //Play Death Anim
            yield return new WaitForSeconds(0.2f);
            if(VFXGraph!=null){

                VFXGraph.gameObject.SetActive(true);
                VFXGraph.Play();

            }

            float counter = 0;


            if(dissolveMaterials.Count > 0) {
                
                while(dissolveMaterials[0].GetFloat("_DissolveAmount") < 1){

                    counter += dissolveRate;

                    for(int i = 0; i<dissolveMaterials.Count; i++) {
                        dissolveMaterials[i].SetFloat("_DissolveAmount",counter); 
                    }
                    yield return new WaitForSeconds(refreshRate);
                }

            }

        }
        Destroy(gameObject,1);
    }

}
