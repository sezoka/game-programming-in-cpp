package asteroids


import "core:fmt"
import sdl "vendor:sdl2"
import "core:math/linalg"

Sprite_Component :: struct {
	texture:    ^sdl.Texture,
	width:      i32,
	height:     i32,
	draw_order: i32,
}

create_sprite_component :: proc(owner: ^Actor, draw_order: i32 = 100) -> ^Component {
	sprite := create_component(owner)
	sprite.variant = Sprite_Component {
		draw_order = draw_order,
	}
	add_sprite(owner.game, sprite)
	return sprite
}

destroy_sprite_component :: proc(c: ^Component) {
	remove_sprite(c.owner.game, c)
}

draw_sprite_component :: proc(c: ^Component, s: ^Sprite_Component, renderer: ^sdl.Renderer) {
	if s.texture == nil do return

	r: sdl.Rect
	r.w = i32(f64(s.width) * c.owner.scale)
	r.h = i32(f64(s.height) * c.owner.scale)
	r.x = i32(c.owner.position.x - f64(r.w / 2))
	r.y = i32(c.owner.position.y - f64(r.y / 2))

	sdl.RenderCopyEx(c.owner.game.renderer, s.texture, nil, &r, linalg.to_degrees(c.owner.rotation), nil, .NONE)
}

set_texture :: proc(s: ^Sprite_Component, texture: ^sdl.Texture) {
	s.texture = texture
	sdl.QueryTexture(texture, nil, nil, &s.width, &s.height)
}

draw_sprite :: proc(c: ^Component, renderer: ^sdl.Renderer) {
	#partial switch s in &c.variant {
	case Sprite_Component:
		draw_sprite_component(c, &s, renderer)
	case BG_Sprite_Component:
		draw_bg_sprite_component(s, c, renderer)
	case Anim_Sprite_Component:
		draw_sprite_component(c, &s.sprite, renderer)
	}
}

get_sprite_draw_order :: proc(c: ^Component) -> i32 {
	#partial switch s in c.variant {
	case Sprite_Component:
		return s.draw_order
	case BG_Sprite_Component:
		return s.draw_order
	case Anim_Sprite_Component:
		return s.draw_order
	}
	panic("Expect sprite got other shit")
}
