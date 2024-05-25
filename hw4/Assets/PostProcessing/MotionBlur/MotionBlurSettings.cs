using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[UnityEngine.Scripting.Preserve]
[Serializable]
[PostProcess(typeof(MotionBlurRenderer), PostProcessEvent.AfterStack, "Custom/MotionBlur")]
public class MotionBlurSettings : PostProcessEffectSettings
{
    [Range(0f, 1f), Tooltip("Alpha for Blur.")]
    public FloatParameter blurAlpha = new FloatParameter { value = 0.9f };


}