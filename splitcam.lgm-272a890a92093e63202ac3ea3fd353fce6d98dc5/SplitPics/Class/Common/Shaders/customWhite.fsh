varying highp vec2 textureCoordinate;
uniform sampler2D inputImageTexture;

void main()
{
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    lowp vec4 outputColor;

    if(textureColor.a <= 0.0){
        outputColor.r = 0.0;
        outputColor.g = 0.0;
        outputColor.b = 0.0;
        outputColor.a = 0.0;
    }else if(textureColor.a < 0.5){
        outputColor.r = textureColor.r*2.0;
        outputColor.g = textureColor.g*2.0;
        outputColor.b = textureColor.b*2.0;
        outputColor.a = textureColor.a*2.0;
    }else{
        outputColor.r = 1.0;
        outputColor.g = 1.0;
        outputColor.b = 1.0;
        outputColor.a = 1.0;
    }
    
    gl_FragColor = outputColor;
}