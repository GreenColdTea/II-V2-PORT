package;

import flixel.FlxG;
import flixel.system.FlxAssets.FlxShader;

class ColorSwap {
    public var shader(default, null):ColorSwapShader = new ColorSwapShader();
    public var hue(default, set):Float = 0;
    public var saturation(default, set):Float = 0;
    public var brightness(default, set):Float = 0;

    private function set_hue(value:Float) {
        hue = value;
        shader.uTime.value[0] = hue;
        return hue;
    }

    private function set_saturation(value:Float) {
        saturation = value;
        shader.uTime.value[1] = saturation;
        return saturation;
    }

    private function set_brightness(value:Float) {
        brightness = value;
        shader.uTime.value[2] = brightness;
        return brightness;
    }

    public function new() {
        shader.uTime.value = [0, 0, 0];
        shader.awesomeOutline.value = [false];
    }
}

class ColorSwapShader extends FlxShader {
    @:glFragmentSource('
        #version 320 es
        precision mediump float;

        in float openfl_Alphav;
        in vec4 openfl_ColorMultiplierv;
        in vec4 openfl_ColorOffsetv;
        in vec2 openfl_TextureCoordv;

        uniform bool openfl_HasColorTransform;
        uniform vec2 openfl_TextureSize;
        uniform sampler2D bitmap;

        uniform bool hasTransform;
        uniform bool hasColorTransform;

        vec4 flixel_texture2D(sampler2D bitmap, vec2 coord) {
            vec4 color = texture(bitmap, coord);
            if (!hasTransform) {
                return color;
            }

            if (color.a == 0.0) {
                return vec4(0.0, 0.0, 0.0, 0.0);
            }

            if (!hasColorTransform) {
                return color * openfl_Alphav;
            }

            color = vec4(color.rgb / color.a, color.a);

            mat4 colorMultiplier = mat4(0);
            colorMultiplier[0][0] = openfl_ColorMultiplierv.x;
            colorMultiplier[1][1] = openfl_ColorMultiplierv.y;
            colorMultiplier[2][2] = openfl_ColorMultiplierv.z;
            colorMultiplier[3][3] = openfl_ColorMultiplierv.w;

            color = clamp(openfl_ColorOffsetv + (color * colorMultiplier), 0.0, 1.0);

            if (color.a > 0.0) {
                return vec4(color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
            }
            return vec4(0.0, 0.0, 0.0, 0.0);
        }

        uniform vec3 uTime;
        uniform bool awesomeOutline;

        const float offset = 1.0 / 128.0;

        vec3 normalizeColor(vec3 color) {
            return vec3(
                color[0] / 255.0,
                color[1] / 255.0,
                color[2] / 255.0
            );
        }

        vec3 rgb2hsv(vec3 c) {
            vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
            vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
            vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

            float d = q.x - min(q.w, q.y);
            float e = 1.0e-10;
            return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
        }

        vec3 hsv2rgb(vec3 c) {
            vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
            return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
        }

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

            vec4 swagColor = vec4(rgb2hsv(vec3(color[0], color[1], color[2])), color[3]);

            swagColor[0] = swagColor[0] + uTime[0];
            swagColor[1] = swagColor[1] + uTime[1];
            swagColor[2] = swagColor[2] * (1.0 + uTime[2]);
            
            if(swagColor[1] < 0.0) {
                swagColor[1] = 0.0;
            } else if(swagColor[1] > 1.0) {
                swagColor[1] = 1.0;
            }

            color = vec4(hsv2rgb(vec3(swagColor[0], swagColor[1], swagColor[2])), swagColor[3]);

            if (awesomeOutline) {
                vec2 size = vec2(3, 3);

                if (color.a <= 0.5) {
                    float w = size.x / openfl_TextureSize.x;
                    float h = size.y / openfl_TextureSize.y;
                    
                    if (flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x + w, openfl_TextureCoordv.y)).a != 0. ||
                        flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x - w, openfl_TextureCoordv.y)).a != 0. ||
                        flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y + h)).a != 0. ||
                        flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y - h)).a != 0.) {
                        color = vec4(1.0, 1.0, 1.0, 1.0);
                    }
                }
            }
            gl_FragColor = color;
        }')
    @:glVertexSource('
        #version 320 es
        precision mediump float;

        in float openfl_Alpha;
        in vec4 openfl_ColorMultiplier;
        in vec4 openfl_ColorOffset;
        in vec4 openfl_Position;
        in vec2 openfl_TextureCoord;

        out float openfl_Alphav;
        out vec4 openfl_ColorMultiplierv;
        out vec4 openfl_ColorOffsetv;
        out vec2 openfl_TextureCoordv;

        uniform mat4 openfl_Matrix;
        uniform bool openfl_HasColorTransform;
        uniform vec2 openfl_TextureSize;

        void main(void) {
            openfl_Alphav = openfl_Alpha;
            openfl_TextureCoordv = openfl_TextureCoord;

            if (openfl_HasColorTransform) {
                openfl_ColorMultiplierv = openfl_ColorMultiplier;
                openfl_ColorOffsetv = openfl_ColorOffset / 255.0;
            }

            gl_Position = openfl_Matrix * openfl_Position;
        }')

    public function new() {
        super();
    }
}
