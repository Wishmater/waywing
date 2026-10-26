//! Wayland host for a Flutter application using filo.
//!
//! The Flutter tool launches this executable from the app's `wayland/` folder
//! through a custom device. It reads the same `FILO_*` environment variables as
//! the development runner and forwards the engine switches Flutter passes in
//! `${engineOptions}`.
//!
//! Extra native code and future plugins belong here: add modules to
//! `build.zig`, import them below, and initialize them before `filo.run`.

const std = @import("std");
const filo = @import("filo");

var runtime: *filo.Runtime = undefined;

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const argv = try init.minimal.args.toSlice(arena);

    // argv[0] is this executable; the rest are engine switches from Flutter's
    // custom-device `runDebug` command.
    const args = if (argv.len > 1) argv[1..] else argv[0..0];
    const engine_args = try arena.alloc([]const u8, args.len);
    for (args, 0..) |arg, i| engine_args[i] = arg;

    var config = try filo.Config.fromEnv(init.environ_map);
    // argv[0] is this executable; everything after it goes to Dart.
    config.dart_entrypoint_args = if (argv.len > 1) argv[1..] else argv[0..0];
    config.bootstrap_layer = true;
    // The main bar is created by Dart as a normal layer window (so it can pick
    // an output and be recreated). Keep the implicit view's bootstrap surface
    // tiny, transparent and click-through; it only exists to give the engine a
    // startup surface.
    config.bootstrap_layer_surface = .{
        .layer = 0, // background
        .anchor = 1 | 4, // top | left
        .exclusive_zone = 0,
        .keyboard_interactivity = 0, // none
        .margin_top = 0,
        .margin_right = 0,
        .margin_bottom = 0,
        .margin_left = 0,
        .width = 1,
        .height = 1,
        .namespace = "waywing-bootstrap",
        .accepts_input = false,
    };
    config.engine_args = engine_args;

    runtime = try filo.Runtime.init(init.gpa, init.io, config);
    defer runtime.deinit();
    try runtime.run();
}

pub export fn waywing_create_region() *filo.wl.Region {
    const region = runtime.app.ctx.conn.compositor.createRegion() catch unreachable;
    region.add(0, 0, 1 << 30, 1 << 30);
    return region;
}

pub export fn waywing_destroy_region(region: *filo.wl.Region) void {
    region.destroy();
}

pub export fn waywing_region_add(region: *filo.wl.Region, x: i32, y: i32, width: i32, height: i32) void {
    region.add(x, y, width, height);
}

pub export fn waywing_region_subtract(region: *filo.wl.Region, x: i32, y: i32, width: i32, height: i32) void {
    region.subtract(x, y, width, height);
}

pub export fn waywing_set_input_region(view_id: filo.engine.ViewId, region: *filo.wl.Region) void {
    const view = runtime.view_by_id(view_id);
    if (view) |v| {
        v.surface.wl_surface.setInputRegion(region);
    }
}

const Cb = *const fn (token: [*:0]const u8) callconv(.c) void;
pub export fn waywing_get_activation_token(
    view_id: filo.engine.ViewId,
    cb: Cb,
) void {
    const conn = runtime.app.ctx.conn;
    const view = runtime.view_by_id(view_id);
    const token = conn.activation.?.getActivationToken() catch unreachable;
    token.setSerial(conn.last_serial orelse 0, conn.seat.?);
    if (view) |v| {
        token.setSurface(v.win.surface);
    }
    token.setListener(Cb, onTokenEvent, cb);
}

fn onTokenEvent(token: *filo.xdg.ActivationTokenV1, event: filo.xdg.ActivationTokenV1.Event, cb: Cb) void {
    switch (event) {
        .done => |v| {
            cb(v.token);
            token.destroy();
        },
    }
}
