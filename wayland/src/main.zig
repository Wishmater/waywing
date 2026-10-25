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

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const argv = try init.minimal.args.toSlice(arena);

    // argv[0] is this executable; the rest are engine switches from Flutter's
    // custom-device `runDebug` command.
    const args = if (argv.len > 1) argv[1..] else argv[0..0];
    const engine_args = try arena.alloc([]const u8, args.len);
    for (args, 0..) |arg, i| engine_args[i] = arg;

    var config = try filo.Config.fromEnv(init.environ_map);
    config.engine_args = engine_args;
    try filo.run(init.gpa, init.io, config);
}
