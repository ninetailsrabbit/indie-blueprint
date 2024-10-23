// https://lucassaturn.co.uk/dev/godot/texture_scroll.html
shader_type canvas_item; //set type of object it applies to

    uniform vec2 direction; //x and y direction
    uniform float speed; //speed value
    varying vec4 modulate; //grab colours after modulate/self-modulate

    void vertex() { //applies to every single vertex
        modulate = COLOR;
    }

    void fragment() { //applies to every single pixel
        vec2 move = direction * TIME * speed; //create offset
        COLOR = texture(TEXTURE, UV + move) * modulate; //set colour
    }