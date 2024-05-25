using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class LineStyleRender : PostProcessEffectRenderer<LineStyle>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("TMP/LineStyle"));
        sheet.properties.SetFloat("_lineStrength", settings.lineStrength);
        sheet.properties.SetColor("_lineColor", settings.lineColor);
        sheet.properties.SetColor("_baseColor", settings.baseColor);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}