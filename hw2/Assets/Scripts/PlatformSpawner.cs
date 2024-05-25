using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public class PlatformSpawner : MonoBehaviour
{
    public List<GameObject> platforms;
    public float min_spawntime, max_spawntime;

    private float spawntime;
    private float Timer = 0;

    // Start is called before the first frame update
    void Start()
    {
        spawntime = UnityEngine.Random.Range(min_spawntime, max_spawntime);
    }

    // Update is called once per frame
    void Update()
    {
        Timer += Time.deltaTime;
        if(Timer > spawntime)
        {
            SpawnPlatform();
            Timer = 0;
            spawntime = UnityEngine.Random.Range(min_spawntime, max_spawntime);
        }
    }

    public void SpawnPlatform()
    {
        Vector3 pos = transform.position;
        pos.x = UnityEngine.Random.Range(-2.2f, 2.2f);

        int index = UnityEngine.Random.Range(0, platforms.Count);

        GameObject go = Instantiate(platforms[index], pos,
       Quaternion.identity);
        go.transform.SetParent(this.gameObject.transform);

    }
}
