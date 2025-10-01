const std = @import("std");

pub fn testFn(p: []const u8) void {
    std.debug.print("{s}\n", .{p});
}

pub const WaywingClient = struct {
    buffer: []u8,
    writer: std.net.Stream.Writer,
    reader: std.net.Stream.Reader,

    pub fn connect(path: []const u8, buffer: []u8) !WaywingClient {
        const stream = try std.net.connectUnixSocket(path);
        const reader = stream.reader(buffer);
        const writer = stream.writer(buffer);
        return .{ .buffer = buffer, .reader = reader, .writer = writer };
    }

    pub fn list(self: *WaywingClient, gpa: std.mem.Allocator) !Response {
        try self.writePath("list-actions");
        try self.writeHeaderEnd();
        try self.writer.interface.flush();
        const response = read(self, gpa);
        return response;
    }

    pub fn sendCmd(self: *WaywingClient, gpa: std.mem.Allocator, cmd: []const u8, body: ?*std.fs.File.Reader) !Response {
        try self.writePath(cmd);
        std.debug.print("ASDADS {}\n", .{body == null});
        if (body != null) {
            std.debug.print("ASDADS Transfer-Encoding zero \n", .{});
            try self.writeHeader("Transfer-Encoding", "zero-ended");
        }
        try self.writeHeaderEnd();
        try self.writer.interface.flush();
        if (body) |b| {
            // var buff: [2048]u8 = undefined;
            // var ss = std.fs.File.stderr().writer(&buff);
            // _ = try ss.interface.sendFileReadingAll(b, .unlimited);
            // try ss.interface.flush();
            _ = try self.writer.interface.sendFileAll(b, .unlimited);
            try self.writer.interface.writeByte(0); // body end acording to the `Transfer-Encoding` zero-ended
            try self.writer.interface.flush();
        }
        const response = read(self, gpa);
        return response;
    }

    fn writePath(self: *WaywingClient, cmd: []const u8) !void {
        _ = try self.writer.interface.write(cmd);
        try self.writer.interface.writeByte('\n');
    }

    fn writeHeader(self: *WaywingClient, key: []const u8, value: []const u8) !void {
        _ = try self.writer.interface.write(key);
        _ = try self.writer.interface.write(": ");
        _ = try self.writer.interface.write(value);
        try self.writer.interface.writeByte('\n');
    }

    fn writeHeaderEnd(self: *WaywingClient) !void {
        _ = try self.writer.interface.write("\n");
    }

    const Response = struct {
        status: u32,
        body: []const u8,
    };

    fn read(self: *WaywingClient, gpa: std.mem.Allocator) Response {
        var statusBuff: [255]u8 = undefined;
        var statusWriter = std.Io.Writer.fixed(&statusBuff);

        const n = self.reader.interface().streamDelimiter(&statusWriter, '\n') catch |err| {
            switch (err) {
                error.ReadFailed => @panic("read response ReadFailed unreachable"),
                error.WriteFailed => @panic("bad status response from server. 255 bytes buffer fill"),
                error.EndOfStream => @panic("read response EndOfStream unreachable"),
            }
        };
        std.debug.assert(n != 0);
        const status = std.fmt.parseInt(u32, statusBuff[0..n], 10) catch |err| {
            switch (err) {
                inline else => |e| @panic("invalid status response " ++ @errorName(e)),
            }
        };
        _ = self.reader.interface().discard(std.Io.Limit.limited(1)) catch unreachable;

        var lineWriter = std.Io.Writer.Allocating.init(gpa);
        defer lineWriter.deinit();
        while (true) {
            const data = self.reader.interface().takeDelimiterInclusive('\n') catch break;
            _ = lineWriter.writer.write(data) catch unreachable;
        }
        var bodyList = lineWriter.toArrayList();
        bodyList.shrinkAndFree(gpa, bodyList.items.len);
        return .{ .status = status, .body = bodyList.items };
    }
};
