const std = @import("std");
const lib = @import("lib");

pub fn main() !void {
    var args = std.process.args();
    _ = args.skip();
    var arg = advance(&args);

    var socket_path: ?[]const u8 = null;

    if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
        printHelp();
    }
    if (std.mem.eql(u8, arg, "--socket") or std.mem.eql(u8, arg, "-s")) {
        arg = advance(&args);
        socket_path = arg;
        arg = advance(&args);
    } else if (std.mem.startsWith(u8, arg, "--socket=")) {
        socket_path = arg["--socket=".len..];
        arg = advance(&args);
    } else if (std.mem.startsWith(u8, arg, "-s=")) {
        socket_path = arg["-s=".len..];
        arg = advance(&args);
    }

    if (socket_path == null) {
        const envs = try std.process.getEnvMap(std.heap.smp_allocator);
        const runtimeDir = envs.get("XDG_RUNTIME_DIR") orelse @panic("no XDG_RUNTIME_DIR en var found");
        socket_path = try std.fs.path.join(std.heap.smp_allocator, &.{ runtimeDir, "waywing/waywing.sock" });
    }

    var buffer: [1024]u8 = undefined;
    var client = lib.WaywingClient.connect(socket_path.?, &buffer) catch |err| {
        switch (err) {
            error.FileNotFound => {
                printOut("socket not found\n", .{});
                printHelp();
            },
            else => {
                printOut("error: {s}\n", .{@errorName(err)});
                printHelp();
            },
        }
    };

    if (std.mem.eql(u8, arg, "list")) {
        const response = try client.list(std.heap.smp_allocator);
        std.debug.assert(response.status == 200);
        printOut("{s}", .{response.body});
        return;
    }
    const response = try client.sendCmd(std.heap.smp_allocator, arg);
    if (response.status > 400) {
        printOut("bad status code {d}\n", .{response.status});
    }
    printOut("{s}", .{response.body});
}

fn advance(iter: *std.process.ArgIterator) [:0]const u8 {
    return iter.next() orelse printHelp();
}

fn printOut(comptime fmt: []const u8, args: anytype) void {
    var buff: [50]u8 = undefined;
    var stdoutW = std.fs.File.stdout().writer(&buff);
    std.Io.Writer.print(&stdoutW.interface, fmt, args) catch unreachable;
    stdoutW.interface.flush() catch unreachable;
}

fn printHelp() noreturn {
    const help_text =
        \\Usage: waywing_client [OPTIONS] COMMAND
        \\
        \\Flags:
        \\  -h, --help            Print this help message
        \\  -s, --socket PATH     Specify socket path (default: $XDG_RUNTIME_DIR/waywing/waywing.sock)
        \\
        \\Commands:
        \\  list                  List available actions
        \\  <action-name>         Send an action to the server
        \\
    ;

    printOut(help_text, .{});
    std.process.exit(1);
}
