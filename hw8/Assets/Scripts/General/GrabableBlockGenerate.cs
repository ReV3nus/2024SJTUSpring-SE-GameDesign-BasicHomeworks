using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrabableBlockGenerate : MonoBehaviour
{
    public GlobalMaterialControll globalMaterial;
    public GameObject block;
    public void GenerateBlock()
    {
        GameObject go = Instantiate(block, transform.position, Quaternion.identity);
        go.transform.Find("Block").gameObject.GetComponent<Renderer>().material = globalMaterial.GetCurrentMaterial();
    }
}
