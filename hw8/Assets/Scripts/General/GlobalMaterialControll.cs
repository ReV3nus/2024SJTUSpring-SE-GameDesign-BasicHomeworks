using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GlobalMaterialControll : MonoBehaviour
{
    public List<Material> materials;
    public List<GameObject> objects;

    private int curIndex, totalIndex;

    private void Start()
    {
        curIndex = 0;
        totalIndex = materials.Count;
        SetMaterial();
    }

    private void SetMaterial()
    {
        foreach(GameObject go in objects)
            go.gameObject.GetComponent<Renderer>().material = materials[curIndex];
    }

    public Material GetCurrentMaterial()
    {
        return materials[curIndex];
    }

    public void NextMaterial()
    {
        curIndex++;
        if (curIndex == totalIndex)
            curIndex = 0;
        SetMaterial();
    }

    public void PreviousMaterial()
    {
        curIndex--;
        if (curIndex < 0)
            curIndex = totalIndex - 1;
        SetMaterial();
    }
}
