// Modified version from https://github.com/LesusX/YouTube/blob/main/WaterShader/water.gdshader
// The following shader is used in order to simulate a simple ocean using Gerstner waves.
// This shader can be added in a plane mesh. For a more detailed ocean, increase the width and depth subdivison.
// Note: On larger planes ex. 500x500, increasing the subdivision above 1000 comes at great performance cost

shader_type spatial;

// Set render modes: always draw depth and disable backface culling
render_mode depth_draw_always, cull_disabled;

// Uniforms for screen and depth textures
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

// Group uniforms for wave parameters
group_uniforms Waves;
// Each wave is defined by a vec4: direction (x,y), amplitude, frequency
uniform vec4 wave_1 = vec4(0.3, 4.0, 0.2, 0.6);
uniform vec4 wave_2 = vec4(-0.26, -0.19, 0.01, 0.47);
uniform vec4 wave_3 = vec4(-7.67, 5.63, 0.1, 0.38);
uniform vec4 wave_4 = vec4(-0.42, -1.63, 0.1, 0.28);
uniform vec4 wave_5 = vec4(1.66, 0.07, 0.15, 1.81);
uniform vec4 wave_6 = vec4(1.20, 1.14, 0.01, 0.33);
uniform vec4 wave_7 = vec4(-1.6, 7.3, 0.11, 0.73);
uniform vec4 wave_8 = vec4(-0.42, -1.63, 0.15, 1.52);

// Uniforms for time factor, noise zoom, and noise amplitude
uniform float time_factor = 2.5;
uniform float noise_zoom = 2.0;
uniform float noise_amp = 1.0;

// Group uniforms for water colors
group_uniforms Water_colours;
uniform vec3 base_water_color:source_color;
uniform vec3 fresnel_water_color:source_color;
uniform vec4 deep_water_color : source_color;
uniform vec4 shallow_water_color : source_color;

// Group uniforms for depth-related parameters
group_uniforms Depth;
uniform float beers_law = 0.5;
uniform float depth_offset = -1.2;
uniform float near = 7.0;
uniform float far = 10000.0;

// Group uniforms for edge detection and foam effects
group_uniforms Edge_Detection;
uniform float edge_texture_scale = 3.5;
uniform float edge_texture_offset = 1.0;
uniform float edge_texture_speed = 0.1;
uniform float edge_foam_intensity = 2.0;
uniform float edge_fade_start = -3.0;
uniform float edge_fade_end = 6.6;
uniform sampler2D edge_foam_texture;

// Group uniforms for wave peak effects
group_uniforms WavePeakEffect;
uniform float peak_height_threshold = 1.0;
uniform vec3 peak_color = vec3(1.0, 1.0, 1.0);
uniform float peak_intensity = 1.0;
uniform sampler2D foam_texture;
uniform float foam_intensity = 1.0;
uniform float foam_scale = 1.0;

// Group uniforms for surface details
group_uniforms Surface_details;
uniform float metallic = 0.6;
uniform float roughness = 0.045;
uniform float uv_scale_text_a = 0.1;
uniform vec2 uv_speed_text_a = vec2(0.42, 0.3);
uniform float uv_scale_text_b = 0.6;
uniform vec2 uv_speed_text_b = vec2(0.15, 0.1);
uniform float normal_strength = 1.0;
uniform float uv_sampler_scale = 0.3;
uniform float blend_factor = 0.28;
uniform sampler2D normalmap_a;
uniform sampler2D normalmap_b;
uniform sampler2D uv_sampler;
uniform sampler2DArray caustic_sampler : hint_default_black;
uniform float caustic_distortion_strength: hint_range(0.0, 0.009) = 0.001; // New uniform for tweaking
uniform float num_caustic_layers = 16.0; // <<< IMPORTANT: DOUBLE CHECK THIS against your Texture2DArray's actual slices!
uniform float refraction_strength = 0.05; // How much the background is distorted
uniform float refraction_fresnel_power = 2.0;
uniform vec3 underwater_fog_color : source_color; // New uniform for fog color
uniform float underwater_fog_density = 0.1; // New uniform for fog density
uniform float underwater_fog_start = 0.0; // New uniform: distance from camera where fog starts (can be negative to make it start immediately)

// Fresnel function to calculate the reflection/refraction effect
float fresnel(float amount, vec3 normal, vec3 view) {
    return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

// Function to calculate edge depth
float edge(float depth) {
    depth = 2.0 * depth - 1.0;
    return near * far / (far - depth * (near - far));
}

// Function to calculate dynamic amplitude based on position and time
float dynamic_amplitude(vec2 pos, float time) {
    return 1.0 + 0.5 * sin(time + length(pos) * 0.1);
}

// Hash function for noise generation
float hash(vec2 p) {
    return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}

// 2D noise function
float noise(vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    vec2 a = vec2(1.0, 0.0);
    return mix(mix(hash(p + a.yy), hash(p + a.xy), f.x),
               mix(hash(p + a.yx), hash(p + a.xx), f.x), f.y);
}

// Fractional Brownian Motion (fBM) function for generating complex noise
float fbm(vec2 x) {
    float height = 0.0;
    float amplitude = 0.5;
    float frequency = 3.0;
    for (int i = 0; i < 6; i++) {
        height += noise(x * frequency) * amplitude;
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return height;
}

// Structure to hold wave results: displacement, tangent, binormal, and normal
struct WaveResult {
    vec3 displacement;
    vec3 tangent;
    vec3 binormal;
    vec3 normal;
};

// Gerstner wave function to calculate wave displacement and normals
WaveResult gerstner_wave(vec4 params, vec2 pos, float time) {
    float steepness = params.z * dynamic_amplitude(pos, time);
    float wavelength = params.w;
    float k = 2.0 * PI / wavelength;
    float c = sqrt(9.81 / k);
    vec2 d = normalize(params.xy);
    float f = k * (dot(d, pos.xy) - c * time);
    float a = steepness / k;

    vec3 displacement = vec3(d.x * (a * cos(f)), a * sin(f), d.y * (a * cos(f)));

    vec3 tangent = vec3(1.0 - d.x * d.x * steepness * sin(f), steepness * cos(f), -d.x * d.y * steepness * sin(f));
    vec3 binormal = vec3(-d.x * d.y * steepness * sin(f), steepness * cos(f), 1.0 - d.y * d.y * steepness * sin(f));
    vec3 normal = normalize(cross(tangent, binormal));

    return WaveResult(displacement, tangent, binormal, normal);
}

// Function to combine multiple Gerstner waves
WaveResult wave(vec2 pos, float time) {
    WaveResult waveResult;
    waveResult.displacement = vec3(0.0);
    waveResult.tangent = vec3(1.0, 0.0, 0.0);
    waveResult.binormal = vec3(0.0, 0.0, 1.0);
    waveResult.normal = vec3(0.0, 1.0, 0.0);

    WaveResult wr;
    wr = gerstner_wave(wave_1, pos, time);
    waveResult.displacement += wr.displacement;
    waveResult.tangent += wr.tangent;
    waveResult.binormal += wr.binormal;
    waveResult.normal += wr.normal;

    wr = gerstner_wave(wave_2, pos, time);
    waveResult.displacement += wr.displacement;
    waveResult.tangent += wr.tangent;
    waveResult.binormal += wr.binormal;
    waveResult.normal += wr.normal;

    wr = gerstner_wave(wave_3, pos, time);
    waveResult.displacement += wr.displacement;
    waveResult.tangent += wr.tangent;
    waveResult.binormal += wr.binormal;
    waveResult.normal += wr.normal;

    wr = gerstner_wave(wave_4, pos, time);
    waveResult.displacement += wr.displacement;
    waveResult.tangent += wr.tangent;
    waveResult.binormal += wr.binormal;
    waveResult.normal += wr.normal;

    wr = gerstner_wave(wave_5, pos, time);
    waveResult.displacement += wr.displacement;
    waveResult.tangent += wr.tangent;
    waveResult.binormal += wr.binormal;
    waveResult.normal += wr.normal;

    wr = gerstner_wave(wave_6, pos, time);
    waveResult.displacement += wr.displacement;
    waveResult.tangent += wr.tangent;
    waveResult.binormal += wr.binormal;
    waveResult.normal += wr.normal;

    wr = gerstner_wave(wave_7, pos, time);
    waveResult.displacement += wr.displacement;
    waveResult.tangent += wr.tangent;
    waveResult.binormal += wr.binormal;
    waveResult.normal += wr.normal;

    wr = gerstner_wave(wave_8, pos, time);
    waveResult.displacement += wr.displacement;
    waveResult.tangent += wr.tangent;
    waveResult.binormal += wr.binormal;
    waveResult.normal += wr.normal;

    // Add noise to the wave displacement for more natural look
    waveResult.displacement.y += fbm(pos.xy * (noise_zoom / 50.0)) * noise_amp;

    return waveResult;
}

// Varying variables to pass data from vertex to fragment shader
varying float height;
varying vec3 world_position;
varying mat3 tbn_matrix;
varying mat4 inv_mvp;

// Vertex shader function
void vertex() {
    // Calculate time based on the global TIME variable and time_factor
    float time = TIME / time_factor;
    // Calculate wave displacement and normals
    WaveResult waveResult = wave(VERTEX.xz, time);
    // Apply wave displacement to the vertex position
    VERTEX += waveResult.displacement;
    // Store the height of the wave displacement
    height = waveResult.displacement.y;

    // Transform normals, tangents, and binormals to world space
    vec3 n = normalize((MODELVIEW_MATRIX * vec4(waveResult.normal, 0.0)).xyz);
    vec3 t = normalize((MODELVIEW_MATRIX * vec4(waveResult.tangent.xyz, 0.0)).xyz);
    vec3 b = normalize((MODELVIEW_MATRIX * vec4((cross(waveResult.normal, waveResult.tangent.xyz)), 0.0)).xyz);
    // Calculate world position of the vertex
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    // Create TBN matrix for normal mapping
    tbn_matrix = mat3(t, b, n);
    // Calculate inverse MVP matrix for screen space transformations
    inv_mvp = inverse(PROJECTION_MATRIX * MODELVIEW_MATRIX);
}

// Fragment shader function
void fragment() {
    // Calculate UV coordinates based on world position
    vec2 uv = world_position.xz;
    // Sample UV offset texture
    vec2 uv_offset = texture(uv_sampler, uv * uv_sampler_scale).rg;
    
    // Calculate animated UV coordinates for normal maps
    vec2 animated_uv_a = (uv + uv_speed_text_a * TIME + uv_offset) * uv_scale_text_a;
    vec2 animated_uv_b = (uv + uv_speed_text_b * TIME + uv_offset) * uv_scale_text_b;
    // Sample normal maps
    vec3 normal_sample_a = texture(normalmap_a, animated_uv_a).rgb;
    vec3 normal_sample_b = texture(normalmap_b, animated_uv_b).rgb;
    
    // Normalize normal samples and combine them
    normal_sample_a = normalize(normal_sample_a * 2.0 - 1.0);
    normal_sample_b = normalize(normal_sample_b * 2.0 - 1.0);
    vec3 combined_normal = normalize(mix(normal_sample_a, normal_sample_b, blend_factor));
    
    // Perturb the normal using the TBN matrix
    vec3 perturbed_normal = normalize(tbn_matrix * (combined_normal * normal_strength));
    // Sample depth texture
    float depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    float depth = PROJECTION_MATRIX[3][2] / (depth_raw + PROJECTION_MATRIX[2][2]);
    
    // Calculate the distance from the camera to the water surface
    float camera_depth = INV_VIEW_MATRIX[3].y - world_position.y;
    if (camera_depth < 0.0) { // Camera is underwater
        // Map the depth to a range where deeper = positive beers_law, closer = negative beers_law
        float depth_factor = smoothstep(-10.0, 0.0, camera_depth); // Adjust -10.0 for the depth range
        ALPHA -= depth_factor * 0.3;
        }
    // Calculate depth blend factor using Beer's law
    float depth_blend = exp((depth + VERTEX.z + depth_offset) * -beers_law);
    depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);
    float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);
    
	// --- Refraction Distortion Implementation ---
	vec2 refraction_uv_offset = perturbed_normal.xy * refraction_strength; // Use XY of normal for 2D screen UV distortion
	// Add some noise to the offset for more organic look (optional, can be subtle)
	refraction_uv_offset += texture(uv_sampler, SCREEN_UV * 0.1 + TIME * 0.05).rg * 0.01; 

	// The final UV for sampling the screen texture
	vec2 refracted_screen_uv = SCREEN_UV + refraction_uv_offset;

	// Blend between refracted and original screen UV based on fresnel (less refraction at grazing angles)
	// This makes reflections stronger than refraction at high angles, which is physically correct.
	float refraction_fresnel = fresnel(refraction_fresnel_power, NORMAL, VIEW); // Use original NORMAL for camera view
	refracted_screen_uv = mix(SCREEN_UV, refracted_screen_uv, 1.0 - refraction_fresnel); 

    // Sample screen color using the new refracted UVand blend it with depth color
	vec3 screen_color = textureLod(SCREEN_TEXTURE, refracted_screen_uv, depth_blend_power * 2.5).rgb;
    vec3 depth_color = mix(shallow_water_color.rgb, deep_water_color.rgb, depth_blend_power);
    vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);
    
    // Calculate depth difference for edge detection
    float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
    float z_pos = edge(FRAGCOORD.z);
    float z_dif = z_depth - z_pos;
    
	// Calculate caustic effect
	vec4 caustic_screenPos = vec4(SCREEN_UV * 2.0 - 1.0, depth_raw, 1.0);
	vec4 caustic_localPos = inv_mvp * caustic_screenPos;
	caustic_localPos = vec4(caustic_localPos.xyz / caustic_localPos.w, caustic_localPos.w);
	 
	vec2 caustic_Uv = caustic_localPos.xz / vec2(1024.0) + 0.5;
	caustic_Uv += perturbed_normal.xz * caustic_distortion_strength; 

	float caustic_layer_index = floor(mod(TIME * 26.0, num_caustic_layers)); // Use floor for integer index

	vec4 caustic_color = texture(caustic_sampler, vec3(caustic_Uv * 660.0, caustic_layer_index));
	float caustic_intensity_multiplier = (1.0 - depth_blend_power) * 6.0; 

	color *= 1.0 + pow(caustic_color.r, 1.50) * caustic_intensity_multiplier;

 // Calculate fresnel effect
    float fresnel = fresnel(5.0, NORMAL, VIEW);
    vec3 surface_color = mix(base_water_color, fresnel_water_color, fresnel);
    
    // Calculate edge foam effect
    vec2 edge_uv = world_position.xz * edge_texture_scale + edge_texture_offset + TIME * edge_texture_speed;
    float edge_fade = smoothstep(edge_fade_start, edge_fade_end, z_dif);
    vec3 depth_color_adj = mix(texture(edge_foam_texture, edge_uv).rgb * edge_foam_intensity, color, edge_fade);
    
    // Apply peak color effect based on height with noise
   // --- Peak Foam Effect ---
	// Foam should appear on higher peaks
	// The height uniform comes from the vertex shader's displacement.y
	float foam_threshold_start = peak_height_threshold;
	float foam_threshold_end = peak_height_threshold + 0.2; // Adjust for fade range

	// Smoothstep creates a gradient for foam appearance based on height
	float height_foam_alpha = smoothstep(foam_threshold_start, foam_threshold_end, height);

	// Add noise to make foam patchy and less uniform
	// Use a faster moving noise for foam animation
	float foam_noise = fbm(world_position.xz * 0.5 + TIME * 0.5); // Faster moving noise
	height_foam_alpha *= foam_noise * 2.0; // Intensify and make patchier

	// Clamp to ensure alpha is between 0 and 1
	height_foam_alpha = clamp(height_foam_alpha, 0.0, 1.0);

	// Sample foam texture for detail. Add some distortion based on normals for more realism.
	// Perturb the foam UV slightly by the normal map for more organic look
	vec2 foam_uv_distorted = world_position.xz * foam_scale + TIME * 0.1;
	foam_uv_distorted += perturbed_normal.xz * 0.05; // Small distortion

	float foam_texture_sample = texture(foam_texture, foam_uv_distorted).r;

	// Combine height-based alpha with texture sample and overall intensity
	float final_foam_alpha = height_foam_alpha * foam_texture_sample * foam_intensity;

	// Apply peak color as a blend
	vec3 final_color = mix(surface_color, peak_color * peak_intensity, final_foam_alpha);

	// Optionally, make the foam whiter instead of just tinted
	final_color = mix(final_color, vec3(1.0), final_foam_alpha);
	
		// --- Underwater Fog/Color Implementation ---
	// Check if the camera is underwater
	float camera_water_height = INV_VIEW_MATRIX[3].y; // Camera's Y position in world space
	float water_surface_height = world_position.y; // Water's Y position at this fragment (displaced)
	vec3 final_albedo_color; // Declare a variable to hold the final ALBEDO before assignment
	
// --- MODIFIED ALPHA & UNDERWATER FOG BLEND ---
	if (camera_water_height < water_surface_height) { // Camera is underwater
	    // Calculate the distance the camera is *below* the water surface
	    float dist_below_surface = water_surface_height - camera_water_height;

	    // Define a shallow zone where transparency and fog blend in
	    float shallow_zone_start = 0.0;  // Camera is exactly at surface (or just below)
	    float shallow_zone_end = 0.5;   // Camera is 0.5 units below surface (adjust this value!)

	    // Calculate an alpha multiplier for the water surface itself based on depth
	    // Smoothly transition water's alpha from 1.0 (fully opaque) to a lower value (more transparent)
	    // as the camera goes deeper into the shallow zone.
	    float surface_alpha_blend = smoothstep(shallow_zone_start, shallow_zone_end, dist_below_surface);
	    
	    // Apply a base transparency if desired, or fade it out completely
	    // ALPHA = mix(1.0, 0.7, surface_alpha_blend); // Water stays somewhat opaque, becomes more transparent deeper
	    ALPHA = mix(1.0, 0.2, surface_alpha_blend); // Water becomes quite transparent when fully submerged in shallow zone
	    // If you want it to gradually become more transparent based on actual depth, like your old line:
	    // float underwater_alpha_factor = smoothstep(water_surface_height - 10.0, water_surface_height, camera_water_height);
	    // ALPHA = mix(ALPHA, 1.0 - (underwater_alpha_factor * 0.3), underwater_alpha_factor); // Combine with previous alpha
	    // Let's stick with the simple shallow zone fade for now to fix the "holes"

	    // --- Fog Amount Blending ---
	    // The previous fog_amount is correct for fading distant objects.
	    // We now use 'surface_alpha_blend' to mix how much of that fog is applied to what we see.
	    // When dist_below_surface is small (camera near surface), surface_alpha_blend is low,
	    // so we see LESS of the fog and more of the clear background.
	    // As camera goes deeper, surface_alpha_blend increases, so we see MORE fog.

	    float scene_depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	    vec4 world_pos_from_depth_clip = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, scene_depth_raw, 1.0);
	    vec3 world_pos_from_depth = world_pos_from_depth_clip.xyz / world_pos_from_depth_clip.w;

	    float dist_to_scene_object = length(world_pos_from_depth - INV_VIEW_MATRIX[3].xyz);
	    
	    float fog_amount = 1.0 - exp(-(dist_to_scene_object - underwater_fog_start) * underwater_fog_density);
	    fog_amount = clamp(fog_amount, 0.0, 1.0); 

	    // Adjust the fog blend based on how far below the surface the camera is
	    // When camera is very close to surface, fog_amount is reduced (more clear)
	    // As camera goes deeper, fog_amount is fully applied.
	    float final_fog_blend_factor = mix(0.0, fog_amount, surface_alpha_blend); // Adjust 0.0 to a small value if you want slight fog even right at surface
	    
	    final_albedo_color = mix(color, underwater_fog_color, final_fog_blend_factor);
	    // This mix for the water surface still holds:
	    final_albedo_color = mix(final_albedo_color, final_color, 0.2); 
	    
	} else { // Camera is above water (standard rendering)
	    final_albedo_color = final_color + depth_color_adj; 
	}
	// --- END MODIFIED ALPHA & UNDERWATER FOG BLEND ---
	
    // Set the final color, metallic, roughness, and normal
	ALBEDO = clamp(final_albedo_color, vec3(0.0), vec3(1.0)); // Assign the final albedo color
    METALLIC = metallic;
    ROUGHNESS = roughness;
    NORMAL = perturbed_normal;
}