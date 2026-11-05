param([string]$Jobs, [string]$OutDir)
# Assembles LPC per-animation PNGs into one universal sheet per sprite and converts
# colours to palette indexes (grey level = position along the palette strip).

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;

public static class LpcConv {
    // Universal sheet rows (64px each) for each animation
    static readonly Dictionary<string, int> Row = new Dictionary<string, int> {
        {"spellcast", 0}, {"thrust", 4}, {"walk", 8}, {"slash", 12}, {"shoot", 16}, {"hurt", 20}, {"watering", 21}, {"run", 25}
    };
    const int Rows = 29;

    static int[] Read(string path, out int w, out int h) {
        using (var bmp = new Bitmap(path)) {
            w = bmp.Width; h = bmp.Height;
            var data = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            var px = new int[w * h];
            for (int y = 0; y < h; y++) Marshal.Copy(data.Scan0 + y * data.Stride, px, y * w, w);
            bmp.UnlockBits(data);
            return px;
        }
    }

    static void Write(string path, int[] px, int w, int h) {
        using (var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb)) {
            var data = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
            for (int y = 0; y < h; y++) Marshal.Copy(px, y * w, data.Scan0 + y * data.Stride, w);
            bmp.UnlockBits(data);
            bmp.Save(path, ImageFormat.Png);
        }
    }

    public static string Run(string jobsFile, string outDir) {
        var log = new System.Text.StringBuilder();
        Directory.CreateDirectory(outDir);
        foreach (var line in File.ReadAllLines(jobsFile)) {
            if (line.Trim().Length == 0) continue;
            var parts = line.Split('\t');
            string name = parts[0];

            // Assemble the sheet
            int W = 832, H = Rows * 64;
            int[] sheet;
            if (parts[2].StartsWith("CUSTOM|")) {
                // Oversized tool/weapon animation: 4 rows (n, w, s, e) of frameSize frames.
                // With a frame map, each output frame copies the listed source frame from the same row.
                var c = parts[2].Split(new char[] { '|' }, 5);
                int fs = int.Parse(c[1]), cols = int.Parse(c[2]);
                string[] map = c[3].Length > 0 ? c[3].Split('/') : null;
                if (!File.Exists(c[4])) { log.AppendLine("MISSING " + name + " " + c[4]); continue; }
                int sw, sh;
                var spx = Read(c[4], out sw, out sh);
                W = cols * fs; H = 4 * fs;
                sheet = new int[W * H];
                for (int r = 0; r < 4; r++) {
                    var fr = map != null ? map[r].Split(',') : null;
                    for (int col = 0; col < cols; col++) {
                        int src = fr != null ? int.Parse(fr[col]) : col;
                        if ((src + 1) * fs > sw || (r + 1) * fs > sh) continue;
                        for (int y = 0; y < fs; y++) Array.Copy(spx, (r * fs + y) * sw + src * fs, sheet, (r * fs + y) * W + col * fs, fs);
                    }
                }
            } else {
                var srcs = new List<KeyValuePair<int, int[]>>();
                var dims = new List<int[]>();
                foreach (var f in parts[2].Split(';')) {
                    int eq = f.IndexOf('=');
                    string anim = f.Substring(0, eq), path = f.Substring(eq + 1);
                    if (!File.Exists(path)) { log.AppendLine("MISSING " + name + " " + path); continue; }
                    int w, h;
                    var px = Read(path, out w, out h);
                    srcs.Add(new KeyValuePair<int, int[]>(Row[anim] * 64, px));
                    dims.Add(new int[] { w, h });
                    if (w > W) W = w;
                }
                sheet = new int[W * H];
                for (int s = 0; s < srcs.Count; s++) {
                    int top = srcs[s].Key, w = dims[s][0], h = Math.Min(dims[s][1], H - top);
                    for (int y = 0; y < h; y++) Array.Copy(srcs[s].Value, y * w, sheet, (top + y) * W, w);
                }
            }

            // Always keep the original colours, used when an item can't be recoloured
            Write(Path.Combine(outDir, name + "_raw.png"), sheet, W, H);
            if (parts[1].Length == 0) {
                log.AppendLine("OK " + name + " raw " + W + "x" + H);
                continue;
            }

            // Colour histogram, to score candidate ramps quickly
            var hist = new Dictionary<int, int>();
            foreach (int c in sheet) {
                if (((c >> 24) & 255) == 0) continue;
                int k = c & 0xFFFFFF, n0;
                hist.TryGetValue(k, out n0);
                hist[k] = n0 + 1;
            }

            // Per colour group, pick the candidate ramp that matches the most pixels
            var groups = parts[1].Split('|');
            var ramps = new int[groups.Length][];
            var picks = new int[groups.Length];
            for (int g = 0; g < groups.Length; g++) {
                var cands = groups[g].Split('/');
                int best = 0, bestScore = -1;
                for (int ci = 0; ci < cands.Length; ci++) {
                    var hex = cands[ci].Split(',');
                    var rc = new int[hex.Length];
                    for (int i = 0; i < hex.Length; i++) rc[i] = Convert.ToInt32(hex[i], 16);
                    int score = 0;
                    foreach (var kv in hist) {
                        int r = (kv.Key >> 16) & 255, gg = (kv.Key >> 8) & 255, b = kv.Key & 255;
                        foreach (int c in rc) {
                            if (Math.Abs(r - ((c >> 16) & 255)) <= 1 && Math.Abs(gg - ((c >> 8) & 255)) <= 1 && Math.Abs(b - (c & 255)) <= 1) { score += kv.Value; break; }
                        }
                    }
                    if (score > bestScore) { bestScore = score; best = ci; ramps[g] = rc; }
                }
                picks[g] = best;
            }
            var outs = new int[groups.Length][];
            for (int g = 0; g < groups.Length; g++) outs[g] = new int[W * H];
            var fix = new int[W * H];
            int opaque = 0, unmatched = 0;
            for (int p = 0; p < sheet.Length; p++) {
                int c = sheet[p];
                int a = (c >> 24) & 255;
                if (a == 0) continue;
                opaque++;
                int r = (c >> 16) & 255, gr = (c >> 8) & 255, b = c & 255;
                int bestG = -1, bestI = -1, bestD = int.MaxValue;
                for (int g = 0; g < ramps.Length && bestD > 3; g++) {
                    for (int i = 0; i < ramps[g].Length; i++) {
                        int rc = ramps[g][i];
                        int dr = r - ((rc >> 16) & 255), dg = gr - ((rc >> 8) & 255), db = b - (rc & 255);
                        int d = dr * dr + dg * dg + db * db;
                        if (d < bestD) { bestD = d; bestG = g; bestI = i; }
                    }
                }
                if (bestD > 3) {
                    // Not in any ramp (eye whites, gems, outlines): keep its own colour on the fixed layer
                    fix[p] = c;
                    unmatched++;
                    continue;
                }
                int n = ramps[bestG].Length;
                int grey = (int)Math.Round((bestI + 0.5) / n * 255.0);
                outs[bestG][p] = (a << 24) | (grey << 16) | (grey << 8) | grey;
            }
            for (int g = 0; g < groups.Length; g++) {
                Write(Path.Combine(outDir, name + (g == 0 ? "" : "_g" + (g + 1)) + ".png"), outs[g], W, H);
            }
            if (unmatched > 0) Write(Path.Combine(outDir, name + "_fix.png"), fix, W, H);
            log.AppendLine("OK " + name + " groups=" + groups.Length + " " + W + "x" + H + " opaque=" + opaque + " unmatched=" + unmatched + " pick=" + string.Join(",", picks));
        }
        return log.ToString();
    }
}
"@

[LpcConv]::Run($Jobs, $OutDir)
