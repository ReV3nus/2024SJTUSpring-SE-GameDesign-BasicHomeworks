using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[UnityEngine.Scripting.Preserve]
[Serializable]
[PostProcess(typeof(DOFRenderer), PostProcessEvent.AfterStack, "Custom/DOF")]
public class DOFSettings : PostProcessEffectSettings
{
    [Range(0f, 10f), Tooltip("Strength for Blur.")]
    public FloatParameter blurStrength = new FloatParameter { value = 1f };

    [Range(1, 10), Tooltip("Iterations for Blur.")]
    public IntParameter iteratorTimes = new IntParameter { value = 6 };

    [Range(0.001f, 1f), Tooltip("Minimum Distance of Focus.")]
    public FloatParameter minFocusDistance = new FloatParameter { value = 0.3f };

    [Range(0.001f, 1f), Tooltip("Maximum Distance of Focus.")]
    public FloatParameter maxFocusDistance = new FloatParameter { value = 0.5f };

    [Tooltip("less scale.")]
    public FloatParameter lessScale = new FloatParameter { value = 2f };

    [Tooltip("more scale.")]
    public FloatParameter moreScale = new FloatParameter { value = 2f };
}