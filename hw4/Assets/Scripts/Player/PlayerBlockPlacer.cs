using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PlayerBlockPlacer : MonoBehaviour
{
    public ToggleGroup toggleGroup;
    private Toggle[] toggles;

    public float maxPlaceDistance;

    public List<GameObject> Blocks;
    public float BlockSize = 1f;

    private int curBlock, totalBlock;
    private Color selectColor = new Color32(0xA1, 0xF6, 0x81, 0xFF);
    private Color defaultColor = new Color(1f, 1f, 1f);

    void SetToggleColor(Toggle toggle, Color color)
    {
        Image img = toggle.targetGraphic as Image;
        if (img != null)
            img.color = color;
    }
    private void Start()
    {
        totalBlock = Blocks.Count;
        curBlock = 0;
        toggles = toggleGroup.GetComponentsInChildren<Toggle>();
        foreach(Toggle toggle in toggles)
            SetToggleColor(toggle, defaultColor);
        SetToggleColor(toggles[0], selectColor);
    }
    void Update()
    {

        if (Input.GetMouseButtonDown(1))
        {
            Vector3 mousePosition = Input.mousePosition;
            Ray ray = Camera.main.ScreenPointToRay(mousePosition);
            RaycastHit hitInfo;
            if (Physics.Raycast(ray, out hitInfo, maxPlaceDistance))
            {

                PlaceBlock(hitInfo.point + hitInfo.normal * BlockSize * 0.5f);
            }
        }

        CheckToggleChange();
    }
    
    void PlaceBlock(Vector3 insidePos)
    {
        Vector3 truePos = new Vector3((int)Math.Floor(insidePos.x), (int)Math.Floor(insidePos.y), (int)Math.Floor(insidePos.z));
        GameObject go = Instantiate(Blocks[curBlock], truePos, Quaternion.identity);
    }
    void CheckToggleChange()
    {
        int oldCur = curBlock;

        float MouseScrollOffset = Input.GetAxisRaw("Mouse ScrollWheel");
        if(MouseScrollOffset < 0)
        {
            curBlock++;
            if (curBlock >= totalBlock) curBlock--;
        }
        if(MouseScrollOffset > 0)
        {
            curBlock--;
            if (curBlock < 0) curBlock++;
        }
        if (Input.GetKey(KeyCode.Alpha1))
        {
            curBlock = 0;
        }
        if (Input.GetKey(KeyCode.Alpha2))
        {
            curBlock = 1;
        }
        if (Input.GetKey(KeyCode.Alpha3))
        {
            curBlock = 2;
        }
        if (Input.GetKey(KeyCode.Alpha4))
        {
            curBlock = 3;
        }
        if (Input.GetKey(KeyCode.Alpha5))
        {
            curBlock = 4;
        }
        if(oldCur != curBlock)
        {
            SetToggleColor(toggles[oldCur], defaultColor);
            SetToggleColor(toggles[curBlock], selectColor);
        }
    }
}
