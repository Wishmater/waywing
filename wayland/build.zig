const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const app_name = b.option([]const u8, "app-name", "Name of the host executable") orelse "app";

    const filo = b.dependency("filo", .{
        .target = target,
        .optimize = optimize,
    }).module("filo");

    const exe = b.addExecutable(.{
        .name = app_name,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "filo", .module = filo },
                // Add extra Zig modules and plugin support here.
            },
        }),
    });

    // The Dart `filo_windowing` package resolves `filo_window_*` with
    // `DynamicLibrary.executable()`, so those symbols must stay in the
    // executable's dynamic symbol table.
    exe.rdynamic = true;

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addPassthruArgs();
    const run_step = b.step("run", "Run the Wayland host");
    run_step.dependOn(&run_cmd.step);
}
