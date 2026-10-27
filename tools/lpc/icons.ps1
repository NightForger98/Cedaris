param([string]$Jobs, [string]$Out)
# For each held item: over the candidate rows, find the frame with the most item pixels (all layers
# together) and that frame's bounding box. Writes: name <TAB> action <TAB> fs <TAB> col <TAB> row <TAB> x,y,w,h

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;

public static class IconPick {
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

    public static string Run(string jobsFile) {
        var sb = new System.Text.StringBuilder();
        foreach (var line in File.ReadAllLines(jobsFile)) {
            if (line.Trim().Length == 0) continue;
            var p = line.Split('\t');
            int fs = int.Parse(p[2]);
            var rows = Array.ConvertAll(p[3].Split(','), int.Parse);
            var sheets = new List<int[]>(); var ws = new List<int>(); var hs = new List<int>();
            foreach (var f in p[4].Split(';')) {
                if (!File.Exists(f)) continue;
                int w, h; sheets.Add(Read(f, out w, out h)); ws.Add(w); hs.Add(h);
            }
            if (sheets.Count == 0) continue;
            int bestCount = -1, bestCol = 0, bestRow = rows[0], bx0 = 0, by0 = 0, bx1 = fs, by1 = fs;
            int cols = ws[0] / fs;
            foreach (int r in rows) {
                for (int c = 0; c < cols; c++) {
                    int count = 0, x0 = fs, y0 = fs, x1 = -1, y1 = -1;
                    for (int s = 0; s < sheets.Count; s++) {
                        if ((r + 1) * fs > hs[s] || (c + 1) * fs > ws[s]) continue;
                        for (int y = 0; y < fs; y++) for (int x = 0; x < fs; x++) {
                            if (((sheets[s][(r * fs + y) * ws[s] + c * fs + x] >> 24) & 255) < 32) continue;
                            count++;
                            if (x < x0) x0 = x; if (x > x1) x1 = x; if (y < y0) y0 = y; if (y > y1) y1 = y;
                        }
                    }
                    if (count > bestCount) { bestCount = count; bestCol = c; bestRow = r; bx0 = x0; by0 = y0; bx1 = x1; by1 = y1; }
                }
            }
            if (bestCount <= 0) continue;
            sb.AppendLine(p[0] + "\t" + p[1] + "\t" + fs + "\t" + bestCol + "\t" + bestRow + "\t" + bx0 + "," + by0 + "," + (bx1 - bx0 + 1) + "," + (by1 - by0 + 1));
        }
        return sb.ToString();
    }
}
"@

[IconPick]::Run($Jobs) | Out-File -Encoding utf8 $Out
