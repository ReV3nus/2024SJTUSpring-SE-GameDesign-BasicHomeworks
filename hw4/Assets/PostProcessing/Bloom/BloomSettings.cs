using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[UnityEngine.Scripting.Preserve]
[Serializable]
[PostProcess(typeof(BloomRenderer), PostProcessEvent.AfterStack, "Custom/Bloom")]
public class BloomSettings : PostProcessEffectSettings
{
    [ColorUsage(false), Tooltip("Color for Bloom.")]
    public ColorParameter bloomColor = new ColorParameter { value = Color.white };

    [Range(0f, 10f), Tooltip("Strength of Bloom.")]
    public FloatParameter bloomStrength = new FloatParameter { value = 0.1f };


    [Range(1, 8), Tooltip("Times for Gaussian iterations.")]
    public IntParameter iteratorTimes = new IntParameter { value = 1 };
}