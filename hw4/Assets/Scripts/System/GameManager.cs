using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using UnityEngine.UIElements;

public class GameManager : MonoBehaviour
{
    public PostProcessVolume volume;
    public PostProcessProfile profile;

    private BloomSettings bloom;
    private MotionBlurSettings motion;
    private DOFSettings dof;
    private FogSettings fog;

    public GameObject SettingPanel;
    bool modifying = false;

    private void Start()
    {
        profile = volume.profile;
        profile.TryGetSettings(out bloom);
        profile.TryGetSettings(out motion);
        profile.TryGetSettings(out dof);
        profile.TryGetSettings(out fog);
    }
    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            if(modifying)
            {
                SettingPanel.SetActive(false);
                Time.timeScale = 1f;
                modifying = false;
                UnityEngine.Cursor.lockState = CursorLockMode.Locked;
                UnityEngine.Cursor.visible = false;
            }
            else
            {
                SettingPanel.SetActive(true);
                Time.timeScale = 0f;
                modifying = true;
                UnityEngine.Cursor.lockState = CursorLockMode.Confined;
                UnityEngine.Cursor.visible = true;
            }
        }
    }

    public void SwitchBloom()
    {
        bloom.enabled.value ^= true;
    }
    public void SwitchMotionBlur()
    {
        motion.enabled.value ^= true;
    }
    public void SwitchDOF()
    {
        dof.enabled.value ^= true;
    }
    public void SwtichFog()
    {
        fog.enabled.value ^= true;
    }
}
