using NUnit.Framework.Internal;
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using static Unity.VisualScripting.Member;

[UnityEngine.Scripting.Preserve]
public class MotionBlurRenderer : PostProcessEffectRenderer<MotionBlurSettings>
{

    private RenderTexture previousTexture;
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Custom/MotionBlur"));

        sheet.properties.SetFloat("_BlurAlpha", settings.blurAlpha);

        if(previousTexture == null || previousTexture.width != context.width || previousTexture.height != context.height)
        {
            previousTexture = new RenderTexture(context.width, context.height, 0);
            previousTexture.hideFlags = HideFlags.HideAndDontSave;
            context.command.BlitFullscreenTriangle(context.source, previousTexture, sheet, 0);
        }

        context.command.BlitFullscreenTriangle(context.source, previousTexture, sheet, 0);
        context.command.BlitFullscreenTriangle(previousTexture, context.destination);

    }
}