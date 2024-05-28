using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class GenerateBlockAtCollision : MonoBehaviour
{
    public float BlockSize = 1f;
    public GameObject PlaceableBlock;
    private void OnCollisionEnter(Collision collision)
    {
        //if (LayerMask.LayerToName(collision.gameObject.layer) != "Ground")
        //    return;

        float distance = Vector2.Distance(new Vector2(transform.position.x, transform.position.z), Vector2.zero);
        if (distance <= 2f)
        {
            if(transform.position.z <= 0.1f)
                Destroy(this.gameObject);
            return;
        }

        Vector3 placePos = collision.contacts[0].point + collision.contacts[0].normal * 0.5f * BlockSize;
        placePos = new Vector3((int)Math.Floor(placePos.x), (int)Math.Floor(placePos.y), (int)Math.Floor(placePos.z));

        GameObject go = Instantiate(PlaceableBlock, placePos, Quaternion.identity);

        Material mat = this.transform.Find("Block").gameObject.GetComponent<Renderer>().material;
        Renderer targetRenderer = go.transform.Find("Cube").gameObject.GetComponent<Renderer>();
        targetRenderer.material = mat;

        Destroy(this.gameObject);
    }
}
