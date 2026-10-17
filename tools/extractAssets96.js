// NHL 96 asset extractor.
// Usage: node tools/extractAssets96.js lst/nhl96.bin
// Writes Extracted/NHL96/... and Extracted/.extract-complete.json last.
const fs = require('fs');
const path = require('path');
const ROOT = path.join(__dirname, '..');
const romPath = process.argv[2] || path.join(ROOT, 'lst', 'nhl96.bin');
if (!fs.existsSync(romPath)) {
  console.error('Missing ' + romPath + '. Put the retail ROM at lst/nhl96.bin first.');
  process.exit(1);
}

// Known retail ROMs. NHL 96 had one retail release (1995.JUL, GM T-172036-00).
const VERSIONS = [
  { id: 'retail', label: 'NHL 96 retail (1995.JUL, GM T-172036-00)', file: 'lst/nhl96.bin',
    sha1: '7204633fbb9966ac637e7966d02ba15c5acdee6b', size: 0x200000, serial: 'GM T-172036-00',
    map: (a) => a },
];

function detectVersion(data) {
  const sha1 = require('crypto').createHash('sha1').update(data).digest('hex');
  const v = VERSIONS.find((x) => x.sha1 === sha1);
  if (v) return v;
  const date = data.subarray(0x118, 0x120).toString('latin1');
  const serial = data.subarray(0x180, 0x18E).toString('latin1');
  const near = VERSIONS.find((x) => x.size === data.length && x.serial === serial);
  let msg = `Unknown ROM ${romPath}: SHA-1 ${sha1}, ${data.length} bytes, header date '${date}', serial '${serial}'.\n`;
  if (near) msg += `Header matches ${near.label}, but the SHA-1 does not (bad dump, hack, or byte-swapped/interleaved file?).\n`;
  msg += 'Supported ROMs:\n' + VERSIONS.map((x) => `  ${x.label}: SHA-1 ${x.sha1} (${x.file})`).join('\n');
  console.error(msg + '\nAborting extraction.');
  process.exit(1);
}
// Slices: name, folder under Extracted, start, end (exclusive).
const assets = [
    { name: 'ANHh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000007fa, end: 0x0000081a }, // ANHh96
    { name: 'ANHv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x0000081a, end: 0x0000083a }, // ANHv96
    { name: 'BOSh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00000af8, end: 0x00000b18 }, // BOSh96
    { name: 'BOSv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00000b18, end: 0x00000b38 }, // BOSv96
    { name: 'BUFh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00000de0, end: 0x00000e00 }, // BUFh96
    { name: 'BUFv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00000e00, end: 0x00000e20 }, // BUFv96
    { name: 'CGYh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000010d0, end: 0x000010f0 }, // CGYh96
    { name: 'CGYv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000010f0, end: 0x00001110 }, // CGYv96
    { name: 'CHIh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000013c6, end: 0x000013e6 }, // CHIh96
    { name: 'CHIv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000013e6, end: 0x00001406 }, // CHIv96
    { name: 'DETh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000016b2, end: 0x000016d2 }, // DETh96
    { name: 'DETv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000016d2, end: 0x000016f2 }, // DETv96
    { name: 'EDMh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000019b8, end: 0x000019d8 }, // EDMh96
    { name: 'EDMv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000019d8, end: 0x000019f8 }, // EDMv96
    { name: 'FLAh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00001cb8, end: 0x00001cd8 }, // FLAh96
    { name: 'FLAv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00001cd8, end: 0x00001cf8 }, // FLAv96
    { name: 'HFDh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00001fac, end: 0x00001fcc }, // HFDh96
    { name: 'HFDv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00001fcc, end: 0x00001fec }, // HFDv96
    { name: 'LAh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000022b0, end: 0x000022d0 }, // LAh96
    { name: 'LAv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000022d0, end: 0x000022f0 }, // LAv96
    { name: 'DALh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00002592, end: 0x000025b2 }, // DALh96
    { name: 'DALv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000025b2, end: 0x000025d2 }, // DALv96
    { name: 'MTLh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00002876, end: 0x00002896 }, // MTLh96
    { name: 'MTLv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00002896, end: 0x000028b6 }, // MTLv96
    { name: 'NJh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00002b78, end: 0x00002b98 }, // NJh96
    { name: 'NJv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00002b98, end: 0x00002bb8 }, // NJv96
    { name: 'NYIh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00002e90, end: 0x00002eb0 }, // NYIh96
    { name: 'NYIv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00002eb0, end: 0x00002ed0 }, // NYIv96
    { name: 'NYRh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x0000318e, end: 0x000031ae }, // NYRh96
    { name: 'NYRv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000031ae, end: 0x000031ce }, // NYRv96
    { name: 'OTWh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00003484, end: 0x000034a4 }, // OTWh96
    { name: 'OTWv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000034a4, end: 0x000034c4 }, // OTWv96
    { name: 'PHIh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00003786, end: 0x000037a6 }, // PHIh96
    { name: 'PHIv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x000037a6, end: 0x000037c6 }, // PHIv96
    { name: 'PITh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00003a7e, end: 0x00003a9e }, // PITh96
    { name: 'PITv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00003a9e, end: 0x00003abe }, // PITv96
    { name: 'QUEh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00003d78, end: 0x00003d98 }, // QUEh96
    { name: 'QUEv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00003d98, end: 0x00003db8 }, // QUEv96
    { name: 'SJh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x0000407a, end: 0x0000409a }, // SJh96
    { name: 'SJv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x0000409a, end: 0x000040ba }, // SJv96
    { name: 'STLh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x0000435e, end: 0x0000437e }, // STLh96
    { name: 'STLv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x0000437e, end: 0x0000439e }, // STLv96
    { name: 'TBh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x0000464a, end: 0x0000466a }, // TBh96
    { name: 'TBv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x0000466a, end: 0x0000468a }, // TBv96
    { name: 'TORh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x0000492c, end: 0x0000494c }, // TORh96
    { name: 'TORv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x0000494c, end: 0x0000496c }, // TORv96
    { name: 'VANh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00004c16, end: 0x00004c36 }, // VANh96
    { name: 'VANv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00004c36, end: 0x00004c56 }, // VANv96
    { name: 'WSHh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00004f18, end: 0x00004f38 }, // WSHh96
    { name: 'WSHv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00004f38, end: 0x00004f58 }, // WSHv96
    { name: 'WPGh96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00005200, end: 0x00005220 }, // WPGh96
    { name: 'WPGv96.pal', folder: 'NHL96/Graphics/Pals', start: 0x00005220, end: 0x00005240 }, // WPGv96
    { name: 'z80_snd_drv96.bin', folder: 'NHL96/Sound', start: 0x00025500, end: 0x00027026 }, // Z80Program
    { name: 'snd96_sample_00.bin', folder: 'NHL96/Sound/Bank', start: 0x000272c8, end: 0x0002940b }, // sample 0
    { name: 'snd96_sample_01.bin', folder: 'NHL96/Sound/Bank', start: 0x0002940b, end: 0x00029632 }, // sample 1
    { name: 'snd96_sample_02.bin', folder: 'NHL96/Sound/Bank', start: 0x00029632, end: 0x0002b6fd }, // sample 2
    { name: 'snd96_sample_03.bin', folder: 'NHL96/Sound/Bank', start: 0x0002b6fd, end: 0x0002bf60 }, // sample 3
    { name: 'snd96_sample_04.bin', folder: 'NHL96/Sound/Bank', start: 0x0002bf60, end: 0x0002dd73 }, // sample 4
    { name: 'snd96_sample_05.bin', folder: 'NHL96/Sound/Bank', start: 0x0002dd73, end: 0x0002ec7c }, // sample 5
    { name: 'snd96_sample_06.bin', folder: 'NHL96/Sound/Bank', start: 0x0002ec7c, end: 0x0002fb9f }, // sample 6
    { name: 'snd96_sample_07.bin', folder: 'NHL96/Sound/Bank', start: 0x0002fb9f, end: 0x00030a62 }, // sample 7
    { name: 'snd96_sample_08.bin', folder: 'NHL96/Sound/Bank', start: 0x00030a62, end: 0x00031b35 }, // sample 8
    { name: 'snd96_sample_09.bin', folder: 'NHL96/Sound/Bank', start: 0x00031b35, end: 0x00031e64 }, // sample 9
    { name: 'snd96_sample_0A.bin', folder: 'NHL96/Sound/Bank', start: 0x00031e64, end: 0x000321b7 }, // sample 10
    { name: 'snd96_sample_0B.bin', folder: 'NHL96/Sound/Bank', start: 0x000321b7, end: 0x00033779 }, // sample 11
    { name: 'snd96_sample_0C.bin', folder: 'NHL96/Sound/Bank', start: 0x00033779, end: 0x000347be }, // sample 12
    { name: 'snd96_sample_0E.bin', folder: 'NHL96/Sound/Bank', start: 0x000347be, end: 0x0003e381 }, // sample 14
    { name: 'snd96_sample_10.bin', folder: 'NHL96/Sound/Bank', start: 0x0003e381, end: 0x0004cfaa }, // sample 16
    { name: 'snd96_sample_11.bin', folder: 'NHL96/Sound/Bank', start: 0x0004cfaa, end: 0x0004f4d2 }, // sample 17
    { name: 'snd96_sample_13.bin', folder: 'NHL96/Sound/Bank', start: 0x0004f4d2, end: 0x00054ca0 }, // sample 19
    { name: 'snd96_sample_15.bin', folder: 'NHL96/Sound/Bank', start: 0x00054ca0, end: 0x00056b69 }, // sample 21
    { name: 'snd96_sample_16.bin', folder: 'NHL96/Sound/Bank', start: 0x00056b69, end: 0x00063bec }, // sample 22
    { name: 'snd96_sample_17.bin', folder: 'NHL96/Sound/Bank', start: 0x00063bec, end: 0x000683bc }, // sample 23
    { name: 'snd96_sample_18.bin', folder: 'NHL96/Sound/Bank', start: 0x000683bc, end: 0x00069bef }, // sample 24
    { name: 'snd96_sample_19.bin', folder: 'NHL96/Sound/Bank', start: 0x00069bef, end: 0x0006ba6a }, // sample 25
    { name: 'snd96_sample_1B.bin', folder: 'NHL96/Sound/Bank', start: 0x0006ba6a, end: 0x0006d29d }, // sample 27
    { name: 'snd96_sample_1D.bin', folder: 'NHL96/Sound/Bank', start: 0x0006d29d, end: 0x0006d4cf }, // sample 29
    { name: 'snd96_sample_2E.bin', folder: 'NHL96/Sound/Bank', start: 0x0006d4cf, end: 0x0007329a }, // sample 46
    { name: 'snd96_sample_5A.bin', folder: 'NHL96/Sound/Bank', start: 0x0007329a, end: 0x00073e0a }, // sample 90
    { name: 'snd96_sample_5B.bin', folder: 'NHL96/Sound/Bank', start: 0x00073e0a, end: 0x00074a2a }, // sample 91
    { name: 'snd96_sample_5C.bin', folder: 'NHL96/Sound/Bank', start: 0x00074a2a, end: 0x000753d8 }, // sample 92
    { name: 'snd96_sample_5D.bin', folder: 'NHL96/Sound/Bank', start: 0x000753d8, end: 0x000784cc }, // sample 93
    { name: 'snd96_sample_5E.bin', folder: 'NHL96/Sound/Bank', start: 0x000784cc, end: 0x00079104 }, // sample 94
    { name: 'snd96_patch_00.bin', folder: 'NHL96/Sound/Bank', start: 0x00079104, end: 0x00079109 }, // patch 0
    { name: 'snd96_patch_01.bin', folder: 'NHL96/Sound/Bank', start: 0x00079109, end: 0x0007910e }, // patch 1
    { name: 'snd96_patch_02.bin', folder: 'NHL96/Sound/Bank', start: 0x0007910e, end: 0x00079113 }, // patch 2
    { name: 'snd96_patch_03.bin', folder: 'NHL96/Sound/Bank', start: 0x00079113, end: 0x00079118 }, // patch 3
    { name: 'snd96_patch_04.bin', folder: 'NHL96/Sound/Bank', start: 0x00079118, end: 0x0007911d }, // patch 4
    { name: 'snd96_patch_05.bin', folder: 'NHL96/Sound/Bank', start: 0x0007911d, end: 0x00079122 }, // patch 5
    { name: 'snd96_patch_06.bin', folder: 'NHL96/Sound/Bank', start: 0x00079122, end: 0x00079127 }, // patch 6
    { name: 'snd96_patch_07.bin', folder: 'NHL96/Sound/Bank', start: 0x00079127, end: 0x0007912c }, // patch 7
    { name: 'snd96_patch_08.bin', folder: 'NHL96/Sound/Bank', start: 0x0007912c, end: 0x00079131 }, // patch 8
    { name: 'snd96_patch_09.bin', folder: 'NHL96/Sound/Bank', start: 0x00079131, end: 0x00079136 }, // patch 9
    { name: 'snd96_patch_0A.bin', folder: 'NHL96/Sound/Bank', start: 0x00079136, end: 0x0007913b }, // patch 10
    { name: 'snd96_patch_0B.bin', folder: 'NHL96/Sound/Bank', start: 0x0007913b, end: 0x00079162 }, // patch 11
    { name: 'snd96_patch_0C.bin', folder: 'NHL96/Sound/Bank', start: 0x00079162, end: 0x00079167 }, // patch 12
    { name: 'snd96_patch_0D.bin', folder: 'NHL96/Sound/Bank', start: 0x00079167, end: 0x0007918e }, // patch 13
    { name: 'snd96_patch_0E.bin', folder: 'NHL96/Sound/Bank', start: 0x0007918e, end: 0x000791b5 }, // patch 14
    { name: 'snd96_patch_0F.bin', folder: 'NHL96/Sound/Bank', start: 0x000791b5, end: 0x000791dc }, // patch 15
    { name: 'snd96_patch_11.bin', folder: 'NHL96/Sound/Bank', start: 0x000791dc, end: 0x00079203 }, // patch 17
    { name: 'snd96_patch_12.bin', folder: 'NHL96/Sound/Bank', start: 0x00079203, end: 0x00079213 }, // patch 18
    { name: 'snd96_patch_13.bin', folder: 'NHL96/Sound/Bank', start: 0x00079213, end: 0x00079223 }, // patch 19
    { name: 'snd96_patch_14.bin', folder: 'NHL96/Sound/Bank', start: 0x00079223, end: 0x00079233 }, // patch 20
    { name: 'snd96_patch_15.bin', folder: 'NHL96/Sound/Bank', start: 0x00079233, end: 0x0007925a }, // patch 21
    { name: 'snd96_patch_16.bin', folder: 'NHL96/Sound/Bank', start: 0x0007925a, end: 0x00079281 }, // patch 22
    { name: 'snd96_patch_17.bin', folder: 'NHL96/Sound/Bank', start: 0x00079281, end: 0x000792a8 }, // patch 23
    { name: 'snd96_patch_19.bin', folder: 'NHL96/Sound/Bank', start: 0x000792a8, end: 0x000792cf }, // patch 25
    { name: 'snd96_patch_1A.bin', folder: 'NHL96/Sound/Bank', start: 0x000792cf, end: 0x000792f6 }, // patch 26
    { name: 'snd96_patch_1E.bin', folder: 'NHL96/Sound/Bank', start: 0x000792f6, end: 0x0007931d }, // patch 30
    { name: 'snd96_patch_1F.bin', folder: 'NHL96/Sound/Bank', start: 0x0007931d, end: 0x00079344 }, // patch 31
    { name: 'snd96_patch_20.bin', folder: 'NHL96/Sound/Bank', start: 0x00079344, end: 0x0007936b }, // patch 32
    { name: 'snd96_patch_21.bin', folder: 'NHL96/Sound/Bank', start: 0x0007936b, end: 0x00079392 }, // patch 33
    { name: 'snd96_patch_26.bin', folder: 'NHL96/Sound/Bank', start: 0x00079392, end: 0x000793b9 }, // patch 38
    { name: 'snd96_patch_27.bin', folder: 'NHL96/Sound/Bank', start: 0x000793b9, end: 0x000793e0 }, // patch 39
    { name: 'snd96_patch_28.bin', folder: 'NHL96/Sound/Bank', start: 0x000793e0, end: 0x00079407 }, // patch 40
    { name: 'snd96_patch_2A.bin', folder: 'NHL96/Sound/Bank', start: 0x00079407, end: 0x0007942e }, // patch 42
    { name: 'snd96_patch_2E.bin', folder: 'NHL96/Sound/Bank', start: 0x0007942e, end: 0x00079433 }, // patch 46
    { name: 'snd96_patch_33.bin', folder: 'NHL96/Sound/Bank', start: 0x00079433, end: 0x00079438 }, // patch 51
    { name: 'snd96_patch_36.bin', folder: 'NHL96/Sound/Bank', start: 0x00079438, end: 0x0007943d }, // patch 54
    { name: 'snd96_patch_38.bin', folder: 'NHL96/Sound/Bank', start: 0x0007943d, end: 0x00079442 }, // patch 56
    { name: 'snd96_patch_39.bin', folder: 'NHL96/Sound/Bank', start: 0x00079442, end: 0x00079447 }, // patch 57
    { name: 'snd96_patch_3B.bin', folder: 'NHL96/Sound/Bank', start: 0x00079447, end: 0x0007944c }, // patch 59
    { name: 'snd96_patch_3C.bin', folder: 'NHL96/Sound/Bank', start: 0x0007944c, end: 0x00079473 }, // patch 60
    { name: 'snd96_patch_3D.bin', folder: 'NHL96/Sound/Bank', start: 0x00079473, end: 0x00079478 }, // patch 61
    { name: 'snd96_patch_3E.bin', folder: 'NHL96/Sound/Bank', start: 0x00079478, end: 0x0007949f }, // patch 62
    { name: 'snd96_patch_3F.bin', folder: 'NHL96/Sound/Bank', start: 0x0007949f, end: 0x000794c6 }, // patch 63
    { name: 'snd96_patch_40.bin', folder: 'NHL96/Sound/Bank', start: 0x000794c6, end: 0x000794ed }, // patch 64
    { name: 'snd96_patch_41.bin', folder: 'NHL96/Sound/Bank', start: 0x000794ed, end: 0x000794f2 }, // patch 65
    { name: 'snd96_patch_42.bin', folder: 'NHL96/Sound/Bank', start: 0x000794f2, end: 0x000794f7 }, // patch 66
    { name: 'snd96_patch_43.bin', folder: 'NHL96/Sound/Bank', start: 0x000794f7, end: 0x000794fc }, // patch 67
    { name: 'snd96_patch_44.bin', folder: 'NHL96/Sound/Bank', start: 0x000794fc, end: 0x00079501 }, // patch 68
    { name: 'snd96_patch_45.bin', folder: 'NHL96/Sound/Bank', start: 0x00079501, end: 0x00079528 }, // patch 69
    { name: 'snd96_patch_46.bin', folder: 'NHL96/Sound/Bank', start: 0x00079528, end: 0x0007952d }, // patch 70
    { name: 'snd96_patch_47.bin', folder: 'NHL96/Sound/Bank', start: 0x0007952d, end: 0x00079554 }, // patch 71
    { name: 'snd96_patch_48.bin', folder: 'NHL96/Sound/Bank', start: 0x00079554, end: 0x00079559 }, // patch 72
    { name: 'snd96_patch_49.bin', folder: 'NHL96/Sound/Bank', start: 0x00079559, end: 0x00079580 }, // patch 73
    { name: 'snd96_patch_5A.bin', folder: 'NHL96/Sound/Bank', start: 0x00079580, end: 0x00079585 }, // patch 90
    { name: 'snd96_patch_5B.bin', folder: 'NHL96/Sound/Bank', start: 0x00079585, end: 0x0007958a }, // patch 91
    { name: 'snd96_patch_5C.bin', folder: 'NHL96/Sound/Bank', start: 0x0007958a, end: 0x0007958f }, // patch 92
    { name: 'snd96_patch_5D.bin', folder: 'NHL96/Sound/Bank', start: 0x0007958f, end: 0x00079594 }, // patch 93
    { name: 'snd96_patch_5E.bin', folder: 'NHL96/Sound/Bank', start: 0x00079594, end: 0x00079599 }, // patch 94
    { name: 'snd96_song_00.bin', folder: 'NHL96/Sound/Bank', start: 0x00079599, end: 0x0007c58b }, // song 0
    { name: 'snd96_song_01.bin', folder: 'NHL96/Sound/Bank', start: 0x0007c58b, end: 0x0007df6d }, // song 1
    { name: 'snd96_song_02.bin', folder: 'NHL96/Sound/Bank', start: 0x0007df6d, end: 0x00080267 }, // song 2
    { name: 'snd96_song_03.bin', folder: 'NHL96/Sound/Bank', start: 0x00080267, end: 0x0008199e }, // song 3
    { name: 'snd96_song_04.bin', folder: 'NHL96/Sound/Bank', start: 0x0008199e, end: 0x000819b2 }, // song 4
    { name: 'snd96_song_05.bin', folder: 'NHL96/Sound/Bank', start: 0x000819b2, end: 0x000819be }, // song 5
    { name: 'snd96_song_06.bin', folder: 'NHL96/Sound/Bank', start: 0x000819be, end: 0x000819ca }, // song 6
    { name: 'snd96_song_07.bin', folder: 'NHL96/Sound/Bank', start: 0x000819ca, end: 0x000819d6 }, // song 7
    { name: 'snd96_song_08.bin', folder: 'NHL96/Sound/Bank', start: 0x000819d6, end: 0x000819e2 }, // song 8
    { name: 'snd96_song_09.bin', folder: 'NHL96/Sound/Bank', start: 0x000819e2, end: 0x000819ee }, // song 9
    { name: 'snd96_song_0A.bin', folder: 'NHL96/Sound/Bank', start: 0x000819ee, end: 0x000819fa }, // song 10
    { name: 'snd96_song_0B.bin', folder: 'NHL96/Sound/Bank', start: 0x000819fa, end: 0x00081a06 }, // song 11
    { name: 'snd96_song_0E.bin', folder: 'NHL96/Sound/Bank', start: 0x00081a06, end: 0x00081a12 }, // song 14
    { name: 'snd96_song_10.bin', folder: 'NHL96/Sound/Bank', start: 0x00081a12, end: 0x00081a1e }, // song 16
    { name: 'snd96_song_11.bin', folder: 'NHL96/Sound/Bank', start: 0x00081a1e, end: 0x00081a2a }, // song 17
    { name: 'snd96_song_13.bin', folder: 'NHL96/Sound/Bank', start: 0x00081a2a, end: 0x00081a36 }, // song 19
    { name: 'snd96_song_15.bin', folder: 'NHL96/Sound/Bank', start: 0x00081a36, end: 0x00081a42 }, // song 21
    { name: 'snd96_song_16.bin', folder: 'NHL96/Sound/Bank', start: 0x00081a42, end: 0x00081aa5 }, // song 22
    { name: 'snd96_song_17.bin', folder: 'NHL96/Sound/Bank', start: 0x00081aa5, end: 0x00081af9 }, // song 23
    { name: 'snd96_song_18.bin', folder: 'NHL96/Sound/Bank', start: 0x00081af9, end: 0x00081b05 }, // song 24
    { name: 'snd96_song_19.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b05, end: 0x00081b11 }, // song 25
    { name: 'snd96_song_1A.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b11, end: 0x00081b1d }, // song 26
    { name: 'snd96_song_1B.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b1d, end: 0x00081b29 }, // song 27
    { name: 'snd96_song_1C.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b29, end: 0x00081b35 }, // song 28
    { name: 'snd96_song_1D.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b35, end: 0x00081b41 }, // song 29
    { name: 'snd96_song_1E.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b41, end: 0x00081b4f }, // song 30
    { name: 'snd96_song_20.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b4f, end: 0x00081b5b }, // song 32
    { name: 'snd96_song_21.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b5b, end: 0x00081b67 }, // song 33
    { name: 'snd96_song_22.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b67, end: 0x00081b73 }, // song 34
    { name: 'snd96_song_23.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b73, end: 0x00081b7f }, // song 35
    { name: 'snd96_song_24.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b7f, end: 0x00081b8b }, // song 36
    { name: 'snd96_song_25.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b8b, end: 0x00081b97 }, // song 37
    { name: 'snd96_song_26.bin', folder: 'NHL96/Sound/Bank', start: 0x00081b97, end: 0x00081e6b }, // song 38
    { name: 'snd96_song_27.bin', folder: 'NHL96/Sound/Bank', start: 0x00081e6b, end: 0x00081e7f }, // song 39
    { name: 'snd96_song_28.bin', folder: 'NHL96/Sound/Bank', start: 0x00081e7f, end: 0x00081e93 }, // song 40
    { name: 'snd96_song_29.bin', folder: 'NHL96/Sound/Bank', start: 0x00081e93, end: 0x00081e9f }, // song 41
    { name: 'snd96_song_2E.bin', folder: 'NHL96/Sound/Bank', start: 0x00081e9f, end: 0x00081eb3 }, // song 46
    { name: 'snd96_song_32.bin', folder: 'NHL96/Sound/Bank', start: 0x00081eb3, end: 0x000820a5 }, // song 50
    { name: 'snd96_song_33.bin', folder: 'NHL96/Sound/Bank', start: 0x000820a5, end: 0x00082589 }, // song 51
    { name: 'snd96_song_34.bin', folder: 'NHL96/Sound/Bank', start: 0x00082589, end: 0x000827dd }, // song 52
    { name: 'snd96_song_35.bin', folder: 'NHL96/Sound/Bank', start: 0x000827dd, end: 0x00082a8b }, // song 53
    { name: 'snd96_song_36.bin', folder: 'NHL96/Sound/Bank', start: 0x00082a8b, end: 0x00082da7 }, // song 54
    { name: 'snd96_song_37.bin', folder: 'NHL96/Sound/Bank', start: 0x00082da7, end: 0x0008304f }, // song 55
    { name: 'snd96_song_38.bin', folder: 'NHL96/Sound/Bank', start: 0x0008304f, end: 0x000832eb }, // song 56
    { name: 'snd96_song_39.bin', folder: 'NHL96/Sound/Bank', start: 0x000832eb, end: 0x00083497 }, // song 57
    { name: 'snd96_song_3A.bin', folder: 'NHL96/Sound/Bank', start: 0x00083497, end: 0x0008387b }, // song 58
    { name: 'snd96_song_3B.bin', folder: 'NHL96/Sound/Bank', start: 0x0008387b, end: 0x00083abf }, // song 59
    { name: 'snd96_song_3C.bin', folder: 'NHL96/Sound/Bank', start: 0x00083abf, end: 0x00083aef }, // song 60
    { name: 'snd96_song_3D.bin', folder: 'NHL96/Sound/Bank', start: 0x00083aef, end: 0x00083ef3 }, // song 61
    { name: 'snd96_song_3E.bin', folder: 'NHL96/Sound/Bank', start: 0x00083ef3, end: 0x00084234 }, // song 62
    { name: 'snd96_song_3F.bin', folder: 'NHL96/Sound/Bank', start: 0x00084234, end: 0x0008443c }, // song 63
    { name: 'snd96_song_40.bin', folder: 'NHL96/Sound/Bank', start: 0x0008443c, end: 0x000846ba }, // song 64
    { name: 'snd96_song_41.bin', folder: 'NHL96/Sound/Bank', start: 0x000846ba, end: 0x00084a12 }, // song 65
    { name: 'snd96_song_42.bin', folder: 'NHL96/Sound/Bank', start: 0x00084a12, end: 0x00084b3e }, // song 66
    { name: 'snd96_song_43.bin', folder: 'NHL96/Sound/Bank', start: 0x00084b3e, end: 0x00084f02 }, // song 67
    { name: 'snd96_song_44.bin', folder: 'NHL96/Sound/Bank', start: 0x00084f02, end: 0x0008510e }, // song 68
    { name: 'snd96_song_45.bin', folder: 'NHL96/Sound/Bank', start: 0x0008510e, end: 0x00085382 }, // song 69
    { name: 'snd96_song_46.bin', folder: 'NHL96/Sound/Bank', start: 0x00085382, end: 0x000854da }, // song 70
    { name: 'snd96_song_47.bin', folder: 'NHL96/Sound/Bank', start: 0x000854da, end: 0x00085896 }, // song 71
    { name: 'snd96_song_48.bin', folder: 'NHL96/Sound/Bank', start: 0x00085896, end: 0x00085cba }, // song 72
    { name: 'snd96_song_49.bin', folder: 'NHL96/Sound/Bank', start: 0x00085cba, end: 0x000860ba }, // song 73
    { name: 'snd96_song_4A.bin', folder: 'NHL96/Sound/Bank', start: 0x000860ba, end: 0x000863cf }, // song 74
    { name: 'snd96_song_4B.bin', folder: 'NHL96/Sound/Bank', start: 0x000863cf, end: 0x00086734 }, // song 75
    { name: 'snd96_song_4C.bin', folder: 'NHL96/Sound/Bank', start: 0x00086734, end: 0x00086a97 }, // song 76
    { name: 'snd96_song_4D.bin', folder: 'NHL96/Sound/Bank', start: 0x00086a97, end: 0x00086d60 }, // song 77
    { name: 'snd96_song_4E.bin', folder: 'NHL96/Sound/Bank', start: 0x00086d60, end: 0x0008717c }, // song 78
    { name: 'snd96_song_4F.bin', folder: 'NHL96/Sound/Bank', start: 0x0008717c, end: 0x00087608 }, // song 79
    { name: 'snd96_song_50.bin', folder: 'NHL96/Sound/Bank', start: 0x00087608, end: 0x0008785d }, // song 80
    { name: 'snd96_song_51.bin', folder: 'NHL96/Sound/Bank', start: 0x0008785d, end: 0x00087a87 }, // song 81
    { name: 'snd96_song_52.bin', folder: 'NHL96/Sound/Bank', start: 0x00087a87, end: 0x00087b77 }, // song 82
    { name: 'snd96_song_53.bin', folder: 'NHL96/Sound/Bank', start: 0x00087b77, end: 0x00087deb }, // song 83
    { name: 'snd96_song_54.bin', folder: 'NHL96/Sound/Bank', start: 0x00087deb, end: 0x00087ebf }, // song 84
    { name: 'snd96_song_55.bin', folder: 'NHL96/Sound/Bank', start: 0x00087ebf, end: 0x000882e8 }, // song 85
    { name: 'snd96_song_5A.bin', folder: 'NHL96/Sound/Bank', start: 0x000882e8, end: 0x000882f4 }, // song 90
    { name: 'snd96_song_5B.bin', folder: 'NHL96/Sound/Bank', start: 0x000882f4, end: 0x00088300 }, // song 91
    { name: 'snd96_song_5C.bin', folder: 'NHL96/Sound/Bank', start: 0x00088300, end: 0x0008830c }, // song 92
    { name: 'snd96_song_5D.bin', folder: 'NHL96/Sound/Bank', start: 0x0008830c, end: 0x00088318 }, // song 93
    { name: 'snd96_song_5E.bin', folder: 'NHL96/Sound/Bank', start: 0x00088318, end: 0x00088324 }, // song 94
    { name: 'snd96_list_00.bin', folder: 'NHL96/Sound/Bank', start: 0x00088324, end: 0x0008834b }, // list 0
    { name: 'snd96_list_01.bin', folder: 'NHL96/Sound/Bank', start: 0x0008834b, end: 0x0008839e }, // list 1
    { name: 'ScoutTextScript.bin', folder: 'NHL96/Text', start: 0x0008880a, end: 0x00088a18 }, // ScoutTextScript
    { name: 'TitleScreenImg.map.jim', folder: 'NHL96/Graphics', start: 0x00088a18, end: 0x0008f2c6 }, // TitleScreenImg
    { name: 'NHLShieldMap.map.jim', folder: 'NHL96/Graphics', start: 0x0008f2c6, end: 0x00090686 }, // NHLShieldMap
    { name: 'NHLPALogoMap.map.jim', folder: 'NHL96/Graphics', start: 0x00090686, end: 0x000911b8 }, // NHLPALogoMap
    { name: 'CreditsBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x000911b8, end: 0x00091b86 }, // CreditsBgMap
    { name: 'Framermap.map.jim', folder: 'NHL96/Graphics', start: 0x00091b86, end: 0x00091d46 }, // Framermap
    { name: 'FaceOffMap.map.jim', folder: 'NHL96/Graphics', start: 0x00091d46, end: 0x000923e4 }, // FaceOffMap
    { name: 'Rinktilelist.map.jim', folder: 'NHL96/Graphics', start: 0x000923e4, end: 0x00097e72 }, // Rinktilelist
    { name: 'RefTiles.map.jim', folder: 'NHL96/Graphics', start: 0x00097e72, end: 0x00098f30 }, // RefTiles
    { name: 'RefTilesHor.map.jim', folder: 'NHL96/Graphics', start: 0x00098f30, end: 0x0009aa9e }, // RefTilesHor
    { name: 'Sprites.bin', folder: 'NHL96/Graphics', start: 0x0009aa9e, end: 0x0009aaa8 }, // Sprites
    { name: 'Spritetiles.bin', folder: 'NHL96/Graphics', start: 0x0009aaa8, end: 0x0012f588 }, // Spritetiles
    { name: 'SpritePalette.bin', folder: 'NHL96/Graphics', start: 0x0012f588, end: 0x0012f608 }, // SpritePalette
    { name: 'frameSprData.bin', folder: 'NHL96/Graphics', start: 0x0012f608, end: 0x0013938e }, // frameSprData
    { name: 'HotList.bin', folder: 'NHL96/Graphics', start: 0x0013938e, end: 0x0013a212 }, // HotList
    { name: 'HotList2.bin', folder: 'NHL96/Graphics', start: 0x0013a212, end: 0x0013aa96 }, // HotList2
    { name: 'CrowdFrameList.map.jim', folder: 'NHL96/Graphics', start: 0x0013aa96, end: 0x0013bcb0 }, // CrowdFrameList
    { name: 'FaceOffSprites.map.jim', folder: 'NHL96/Graphics', start: 0x0013bcb0, end: 0x0013d290 }, // FaceOffSprites
    { name: 'EnergyBarMap.map.jim', folder: 'NHL96/Graphics', start: 0x0013d290, end: 0x0013d59e }, // EnergyBarMap
    { name: 'EASNmap.map.jim', folder: 'NHL96/Graphics', start: 0x0013d59e, end: 0x0013da74 }, // EASNmap
    { name: 'EASportsMap.map.jim', folder: 'NHL96/Graphics', start: 0x0013da74, end: 0x0013e99a }, // EASportsMap
    { name: 'RevRinkTilelist.bin', folder: 'NHL96/Graphics', start: 0x0013e99a, end: 0x00140afe }, // RevRinkTilelist
    { name: 'ReplayIconMap.map.jim', folder: 'NHL96/Graphics', start: 0x00140afe, end: 0x00141228 }, // ReplayIconMap
    { name: 'ReplayBannerMap.map.jim', folder: 'NHL96/Graphics', start: 0x00141228, end: 0x001417b6 }, // ReplayBannerMap
    { name: 'unk_1417B6.map.jim', folder: 'NHL96/Graphics', start: 0x001417b6, end: 0x001468d6 }, // unk_1417B6
    { name: 'HiScoreBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x001468d6, end: 0x00147896 }, // HiScoreBgMap
    { name: 'HiScoreImg.map.jim', folder: 'NHL96/Graphics', start: 0x00147896, end: 0x00148054 }, // HiScoreImg
    { name: 'TeamBlockANH.map.jim', folder: 'NHL96/Graphics', start: 0x00148054, end: 0x00148502 }, // TeamBlockANH
    { name: 'TeamBlockBOS.map.jim', folder: 'NHL96/Graphics', start: 0x00148502, end: 0x00148970 }, // TeamBlockBOS
    { name: 'TeamBlockBUF.map.jim', folder: 'NHL96/Graphics', start: 0x00148970, end: 0x00148dde }, // TeamBlockBUF
    { name: 'TeamBlockCGY.map.jim', folder: 'NHL96/Graphics', start: 0x00148dde, end: 0x0014928c }, // TeamBlockCGY
    { name: 'TeamBlockCHI.map.jim', folder: 'NHL96/Graphics', start: 0x0014928c, end: 0x0014973a }, // TeamBlockCHI
    { name: 'TeamBlockDAL.map.jim', folder: 'NHL96/Graphics', start: 0x0014973a, end: 0x00149ba8 }, // TeamBlockDAL
    { name: 'TeamBlockDET.map.jim', folder: 'NHL96/Graphics', start: 0x00149ba8, end: 0x0014a016 }, // TeamBlockDET
    { name: 'TeamBlockEDM.map.jim', folder: 'NHL96/Graphics', start: 0x0014a016, end: 0x0014a4e4 }, // TeamBlockEDM
    { name: 'TeamBlockFLA.map.jim', folder: 'NHL96/Graphics', start: 0x0014a4e4, end: 0x0014a952 }, // TeamBlockFLA
    { name: 'TeamBlockHFD.map.jim', folder: 'NHL96/Graphics', start: 0x0014a952, end: 0x0014ae20 }, // TeamBlockHFD
    { name: 'TeamBlockLA.map.jim', folder: 'NHL96/Graphics', start: 0x0014ae20, end: 0x0014b2ee }, // TeamBlockLA
    { name: 'TeamBlockMTL.map.jim', folder: 'NHL96/Graphics', start: 0x0014b2ee, end: 0x0014b7bc }, // TeamBlockMTL
    { name: 'TeamBlockNJ.map.jim', folder: 'NHL96/Graphics', start: 0x0014b7bc, end: 0x0014bc8a }, // TeamBlockNJ
    { name: 'TeamBlockNYI.map.jim', folder: 'NHL96/Graphics', start: 0x0014bc8a, end: 0x0014c158 }, // TeamBlockNYI
    { name: 'TeamBlockNYR.map.jim', folder: 'NHL96/Graphics', start: 0x0014c158, end: 0x0014c626 }, // TeamBlockNYR
    { name: 'TeamBlockOTW.map.jim', folder: 'NHL96/Graphics', start: 0x0014c626, end: 0x0014cad4 }, // TeamBlockOTW
    { name: 'TeamBlockPHI.map.jim', folder: 'NHL96/Graphics', start: 0x0014cad4, end: 0x0014cfa2 }, // TeamBlockPHI
    { name: 'TeamBlockPIT.map.jim', folder: 'NHL96/Graphics', start: 0x0014cfa2, end: 0x0014d470 }, // TeamBlockPIT
    { name: 'TeamBlockQUE.map.jim', folder: 'NHL96/Graphics', start: 0x0014d470, end: 0x0014d8de }, // TeamBlockQUE
    { name: 'TeamBlockSJ.map.jim', folder: 'NHL96/Graphics', start: 0x0014d8de, end: 0x0014dd6c }, // TeamBlockSJ
    { name: 'TeamBlockSTL.map.jim', folder: 'NHL96/Graphics', start: 0x0014dd6c, end: 0x0014e1da }, // TeamBlockSTL
    { name: 'TeamBlockTB.map.jim', folder: 'NHL96/Graphics', start: 0x0014e1da, end: 0x0014e6a8 }, // TeamBlockTB
    { name: 'TeamBlockTOR.map.jim', folder: 'NHL96/Graphics', start: 0x0014e6a8, end: 0x0014eb56 }, // TeamBlockTOR
    { name: 'TeamBlockVAN.map.jim', folder: 'NHL96/Graphics', start: 0x0014eb56, end: 0x0014f024 }, // TeamBlockVAN
    { name: 'TeamBlockWSH.map.jim', folder: 'NHL96/Graphics', start: 0x0014f024, end: 0x0014f4f2 }, // TeamBlockWSH
    { name: 'TeamBlockWPG.map.jim', folder: 'NHL96/Graphics', start: 0x0014f4f2, end: 0x0014f9a0 }, // TeamBlockWPG
    { name: 'TeamLogoANH.map.jim', folder: 'NHL96/Graphics', start: 0x0014f9a0, end: 0x00150a8e }, // TeamLogoANH
    { name: 'TeamLogoBOS.map.jim', folder: 'NHL96/Graphics', start: 0x00150a8e, end: 0x00151b1c }, // TeamLogoBOS
    { name: 'TeamLogoBUF.map.jim', folder: 'NHL96/Graphics', start: 0x00151b1c, end: 0x00152bea }, // TeamLogoBUF
    { name: 'TeamLogoCGY.map.jim', folder: 'NHL96/Graphics', start: 0x00152bea, end: 0x00153cd8 }, // TeamLogoCGY
    { name: 'TeamLogoCHI.map.jim', folder: 'NHL96/Graphics', start: 0x00153cd8, end: 0x00154de6 }, // TeamLogoCHI
    { name: 'TeamLogoDAL.map.jim', folder: 'NHL96/Graphics', start: 0x00154de6, end: 0x00155ed4 }, // TeamLogoDAL
    { name: 'TeamLogoDET.map.jim', folder: 'NHL96/Graphics', start: 0x00155ed4, end: 0x00156fa2 }, // TeamLogoDET
    { name: 'TeamLogoEDM.map.jim', folder: 'NHL96/Graphics', start: 0x00156fa2, end: 0x001580b0 }, // TeamLogoEDM
    { name: 'TeamLogoFLA.map.jim', folder: 'NHL96/Graphics', start: 0x001580b0, end: 0x0015919e }, // TeamLogoFLA
    { name: 'TeamLogoHFD.map.jim', folder: 'NHL96/Graphics', start: 0x0015919e, end: 0x0015a2ac }, // TeamLogoHFD
    { name: 'TeamLogoLA.map.jim', folder: 'NHL96/Graphics', start: 0x0015a2ac, end: 0x0015b3da }, // TeamLogoLA
    { name: 'TeamLogoMTL.map.jim', folder: 'NHL96/Graphics', start: 0x0015b3da, end: 0x0015c508 }, // TeamLogoMTL
    { name: 'TeamLogoNJ.map.jim', folder: 'NHL96/Graphics', start: 0x0015c508, end: 0x0015d636 }, // TeamLogoNJ
    { name: 'TeamLogoNYI.map.jim', folder: 'NHL96/Graphics', start: 0x0015d636, end: 0x0015e764 }, // TeamLogoNYI
    { name: 'TeamLogoNYR.map.jim', folder: 'NHL96/Graphics', start: 0x0015e764, end: 0x0015f872 }, // TeamLogoNYR
    { name: 'TeamLogoOTW.map.jim', folder: 'NHL96/Graphics', start: 0x0015f872, end: 0x00160980 }, // TeamLogoOTW
    { name: 'TeamLogoPHI.map.jim', folder: 'NHL96/Graphics', start: 0x00160980, end: 0x00161aae }, // TeamLogoPHI
    { name: 'TeamLogoPIT.map.jim', folder: 'NHL96/Graphics', start: 0x00161aae, end: 0x00162bdc }, // TeamLogoPIT
    { name: 'TeamLogoQUE.map.jim', folder: 'NHL96/Graphics', start: 0x00162bdc, end: 0x00163caa }, // TeamLogoQUE
    { name: 'TeamLogoSJ.map.jim', folder: 'NHL96/Graphics', start: 0x00163caa, end: 0x00164db8 }, // TeamLogoSJ
    { name: 'TeamLogoSTL.map.jim', folder: 'NHL96/Graphics', start: 0x00164db8, end: 0x00165ea6 }, // TeamLogoSTL
    { name: 'TeamLogoTB.map.jim', folder: 'NHL96/Graphics', start: 0x00165ea6, end: 0x00166fb4 }, // TeamLogoTB
    { name: 'TeamLogoTOR.map.jim', folder: 'NHL96/Graphics', start: 0x00166fb4, end: 0x001680a2 }, // TeamLogoTOR
    { name: 'TeamLogoVAN.map.jim', folder: 'NHL96/Graphics', start: 0x001680a2, end: 0x001691d0 }, // TeamLogoVAN
    { name: 'TeamLogoWSH.map.jim', folder: 'NHL96/Graphics', start: 0x001691d0, end: 0x0016a2fe }, // TeamLogoWSH
    { name: 'TeamLogoWPG.map.jim', folder: 'NHL96/Graphics', start: 0x0016a2fe, end: 0x0016b40c }, // TeamLogoWPG
    { name: 'SmallLogoFLA.map.jim', folder: 'NHL96/Graphics', start: 0x0016b40c, end: 0x0016b78c }, // SmallLogoFLA
    { name: 'SmallLogoBUF.map.jim', folder: 'NHL96/Graphics', start: 0x0016b78c, end: 0x0016baac }, // SmallLogoBUF
    { name: 'SmallLogoANH.map.jim', folder: 'NHL96/Graphics', start: 0x0016baac, end: 0x0016bdec }, // SmallLogoANH
    { name: 'SmallLogoBOS.map.jim', folder: 'NHL96/Graphics', start: 0x0016bdec, end: 0x0016c14c }, // SmallLogoBOS
    { name: 'SmallLogoCGY.map.jim', folder: 'NHL96/Graphics', start: 0x0016c14c, end: 0x0016c52c }, // SmallLogoCGY
    { name: 'SmallLogoCHI.map.jim', folder: 'NHL96/Graphics', start: 0x0016c52c, end: 0x0016c8cc }, // SmallLogoCHI
    { name: 'SmallLogoDAL.map.jim', folder: 'NHL96/Graphics', start: 0x0016c8cc, end: 0x0016cbac }, // SmallLogoDAL
    { name: 'SmallLogoDET.map.jim', folder: 'NHL96/Graphics', start: 0x0016cbac, end: 0x0016ceec }, // SmallLogoDET
    { name: 'SmallLogoEDM.map.jim', folder: 'NHL96/Graphics', start: 0x0016ceec, end: 0x0016d2cc }, // SmallLogoEDM
    { name: 'SmallLogoHFD.map.jim', folder: 'NHL96/Graphics', start: 0x0016d2cc, end: 0x0016d56c }, // SmallLogoHFD
    { name: 'SmallLogoLA.map.jim', folder: 'NHL96/Graphics', start: 0x0016d56c, end: 0x0016d86c }, // SmallLogoLA
    { name: 'SmallLogoMTL.map.jim', folder: 'NHL96/Graphics', start: 0x0016d86c, end: 0x0016dbac }, // SmallLogoMTL
    { name: 'SmallLogoNJ.map.jim', folder: 'NHL96/Graphics', start: 0x0016dbac, end: 0x0016df4c }, // SmallLogoNJ
    { name: 'SmallLogoNYI.map.jim', folder: 'NHL96/Graphics', start: 0x0016df4c, end: 0x0016e26c }, // SmallLogoNYI
    { name: 'SmallLogoNYR.map.jim', folder: 'NHL96/Graphics', start: 0x0016e26c, end: 0x0016e64c }, // SmallLogoNYR
    { name: 'SmallLogoOTW.map.jim', folder: 'NHL96/Graphics', start: 0x0016e64c, end: 0x0016e9cc }, // SmallLogoOTW
    { name: 'SmallLogoPHI.map.jim', folder: 'NHL96/Graphics', start: 0x0016e9cc, end: 0x0016ecec }, // SmallLogoPHI
    { name: 'SmallLogoPIT.map.jim', folder: 'NHL96/Graphics', start: 0x0016ecec, end: 0x0016f00c }, // SmallLogoPIT
    { name: 'SmallLogoQUE.map.jim', folder: 'NHL96/Graphics', start: 0x0016f00c, end: 0x0016f32c }, // SmallLogoQUE
    { name: 'SmallLogoSJ.map.jim', folder: 'NHL96/Graphics', start: 0x0016f32c, end: 0x0016f6ac }, // SmallLogoSJ
    { name: 'SmallLogoSTL.map.jim', folder: 'NHL96/Graphics', start: 0x0016f6ac, end: 0x0016fa0c }, // SmallLogoSTL
    { name: 'SmallLogoTB.map.jim', folder: 'NHL96/Graphics', start: 0x0016fa0c, end: 0x0016fdec }, // SmallLogoTB
    { name: 'SmallLogoTOR.map.jim', folder: 'NHL96/Graphics', start: 0x0016fdec, end: 0x001700ec }, // SmallLogoTOR
    { name: 'SmallLogoVAN.map.jim', folder: 'NHL96/Graphics', start: 0x001700ec, end: 0x0017040c }, // SmallLogoVAN
    { name: 'SmallLogoWSH.map.jim', folder: 'NHL96/Graphics', start: 0x0017040c, end: 0x0017074c }, // SmallLogoWSH
    { name: 'SmallLogoWPG.map.jim', folder: 'NHL96/Graphics', start: 0x0017074c, end: 0x00170b0c }, // SmallLogoWPG
    { name: 'IceBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x00170b0c, end: 0x00173c7a }, // IceBgMap
    { name: 'ControllerBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x00173c7a, end: 0x00179168 }, // ControllerBgMap
    { name: 'RosterFont.bin', folder: 'NHL96/Graphics', start: 0x00179168, end: 0x00179a76 }, // RosterFont
    { name: 'SmallFontMap.map.jim', folder: 'NHL96/Graphics', start: 0x00179a76, end: 0x0017a164 }, // SmallFontMap
    { name: 'SmallFontMap2.map.jim', folder: 'NHL96/Graphics', start: 0x0017a164, end: 0x0017aa72 }, // SmallFontMap2
    { name: 'BigFontMap2.map.jim', folder: 'NHL96/Graphics', start: 0x0017aa72, end: 0x0017b680 }, // BigFontMap2
    { name: 'BigFontMap4.map.jim', folder: 'NHL96/Graphics', start: 0x0017b680, end: 0x0017c2ae }, // BigFontMap4
    { name: 'unk_17C2AE.map.jim', folder: 'NHL96/Graphics', start: 0x0017c2ae, end: 0x0017c2ce }, // unk_17C2AE
    { name: 'LeagueOptionsBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x0017c2ce, end: 0x0017dbdc }, // LeagueOptionsBgMap
    { name: 'LeagueOptionsTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x0017dbdc, end: 0x0017e3fc }, // LeagueOptionsTitleMap
    { name: 'LeagueOptionsSprites.map.jim', folder: 'NHL96/Graphics', start: 0x0017e3fc, end: 0x0017ecea }, // LeagueOptionsSprites
    { name: 'SelectTeamSeasonBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x0017ecea, end: 0x001808b8 }, // SelectTeamSeasonBgMap
    { name: 'SelectTeamSeasonSprites.map.jim', folder: 'NHL96/Graphics', start: 0x001808b8, end: 0x00180c36 }, // SelectTeamSeasonSprites
    { name: 'StandingsTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x00180c36, end: 0x00181456 }, // StandingsTitleMap
    { name: 'StandingsBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x00181456, end: 0x00183024 }, // StandingsBgMap
    { name: 'StandingsSprites.map.jim', folder: 'NHL96/Graphics', start: 0x00183024, end: 0x001833a2 }, // StandingsSprites
    { name: 'GameOptionsBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x001833a2, end: 0x00185770 }, // GameOptionsBgMap
    { name: 'GameOptionsTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x00185770, end: 0x00185f90 }, // GameOptionsTitleMap
    { name: 'GameOptionsSprites.map.jim', folder: 'NHL96/Graphics', start: 0x00185f90, end: 0x0018633e }, // GameOptionsSprites
    { name: 'LeadersBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x0018633e, end: 0x0018800c }, // LeadersBgMap
    { name: 'LeagueLeadersTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x0018800c, end: 0x0018882c }, // LeagueLeadersTitleMap
    { name: 'LeadersSprites.map.jim', folder: 'NHL96/Graphics', start: 0x0018882c, end: 0x00188c4a }, // LeadersSprites
    { name: 'PlayoffLeadersTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x00188c4a, end: 0x0018948a }, // PlayoffLeadersTitleMap
    { name: 'PlayerStatsBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x0018948a, end: 0x0018acd8 }, // PlayerStatsBgMap
    { name: 'SeasonStatsTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x0018acd8, end: 0x0018b4f8 }, // SeasonStatsTitleMap
    { name: 'PlayerStatsSprites.map.jim', folder: 'NHL96/Graphics', start: 0x0018b4f8, end: 0x0018b916 }, // PlayerStatsSprites
    { name: 'PlayoffStatsTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x0018b916, end: 0x0018c136 }, // PlayoffStatsTitleMap
    { name: 'SelectTeamTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x0018c136, end: 0x0018c936 }, // SelectTeamTitleMap
    { name: 'SelectTeamBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x0018c936, end: 0x0018de04 }, // SelectTeamBgMap
    { name: 'SelectTeamSprites.map.jim', folder: 'NHL96/Graphics', start: 0x0018de04, end: 0x0018e152 }, // SelectTeamSprites
    { name: 'TransactionsTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x0018e152, end: 0x0018e932 }, // TransactionsTitleMap
    { name: 'TransactionsBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x0018e932, end: 0x00190380 }, // TransactionsBgMap
    { name: 'TransactionsSprites.map.jim', folder: 'NHL96/Graphics', start: 0x00190380, end: 0x001906fe }, // TransactionsSprites
    { name: 'TradeTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001906fe, end: 0x00190efe }, // TradeTitleMap
    { name: 'TradeBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x00190efe, end: 0x0019262c }, // TradeBgMap
    { name: 'TradeSprites.map.jim', folder: 'NHL96/Graphics', start: 0x0019262c, end: 0x001929fa }, // TradeSprites
    { name: 'CreateTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001929fa, end: 0x0019321a }, // CreateTitleMap
    { name: 'CreateBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x0019321a, end: 0x00194c48 }, // CreateBgMap
    { name: 'CreateSprites.map.jim', folder: 'NHL96/Graphics', start: 0x00194c48, end: 0x00195086 }, // CreateSprites
    { name: 'CreateRatingsBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x00195086, end: 0x001969b4 }, // CreateRatingsBgMap
    { name: 'CreateRatingsSprites.map.jim', folder: 'NHL96/Graphics', start: 0x001969b4, end: 0x00196e0a }, // CreateRatingsSprites
    { name: 'SignPlayersTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x00196e0a, end: 0x0019762a }, // SignPlayersTitleMap
    { name: 'SignPlayersSprites.map.jim', folder: 'NHL96/Graphics', start: 0x0019762a, end: 0x00197a60 }, // SignPlayersSprites
    { name: 'ReleasePlayersTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x00197a60, end: 0x00198260 }, // ReleasePlayersTitleMap
    { name: 'SignReleaseBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x00198260, end: 0x001997ae }, // SignReleaseBgMap
    { name: 'ReleasePlayersSprites.map.jim', folder: 'NHL96/Graphics', start: 0x001997ae, end: 0x00199be4 }, // ReleasePlayersSprites
    { name: 'MainMenuTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x00199be4, end: 0x0019a3e4 }, // MainMenuTitleMap
    { name: 'MainMenuBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x0019a3e4, end: 0x0019c232 }, // MainMenuBgMap
    { name: 'MainMenuSprites.map.jim', folder: 'NHL96/Graphics', start: 0x0019c232, end: 0x0019c628 }, // MainMenuSprites
    { name: 'EditLinesTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x0019c628, end: 0x0019ce08 }, // EditLinesTitleMap
    { name: 'LineEditorBgMap2.map.jim', folder: 'NHL96/Graphics', start: 0x0019ce08, end: 0x0019e7f6 }, // LineEditorBgMap2
    { name: 'LineEditorBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x0019e7f6, end: 0x001a0244 }, // LineEditorBgMap
    { name: 'LineEditorSprites2.map.jim', folder: 'NHL96/Graphics', start: 0x001a0244, end: 0x001a0632 }, // LineEditorSprites2
    { name: 'LineEditorSprites.map.jim', folder: 'NHL96/Graphics', start: 0x001a0632, end: 0x001a0a58 }, // LineEditorSprites
    { name: 'TeamRosterBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x001a0a58, end: 0x001a1ec6 }, // TeamRosterBgMap
    { name: 'TeamRosterSprites.map.jim', folder: 'NHL96/Graphics', start: 0x001a1ec6, end: 0x001a22fc }, // TeamRosterSprites
    { name: 'TeamRosterTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001a22fc, end: 0x001a2b1c }, // TeamRosterTitleMap
    { name: 'SummaryBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x001a2b1c, end: 0x001a454a }, // SummaryBgMap
    { name: 'SummarySprites.map.jim', folder: 'NHL96/Graphics', start: 0x001a454a, end: 0x001a4968 }, // SummarySprites
    { name: 'ScoringTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001a4968, end: 0x001a5148 }, // ScoringTitleMap
    { name: 'PenaltiesTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001a5148, end: 0x001a5928 }, // PenaltiesTitleMap
    { name: 'PeriodStatsTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001a5928, end: 0x001a6148 }, // PeriodStatsTitleMap
    { name: 'PeriodStatsMap.map.jim', folder: 'NHL96/Graphics', start: 0x001a6148, end: 0x001a76b6 }, // PeriodStatsMap
    { name: 'GameStatsTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001a76b6, end: 0x001a7ed6 }, // GameStatsTitleMap
    { name: 'GameStatsBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x001a7ed6, end: 0x001a98a4 }, // GameStatsBgMap
    { name: 'GameStatsSprites.map.jim', folder: 'NHL96/Graphics', start: 0x001a98a4, end: 0x001a9c72 }, // GameStatsSprites
    { name: 'ShootoutSetupTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001a9c72, end: 0x001aa452 }, // ShootoutSetupTitleMap
    { name: 'RecordHoldersTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001aa452, end: 0x001aac72 }, // RecordHoldersTitleMap
    { name: 'RecordHoldersBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x001aac72, end: 0x001ac3a0 }, // RecordHoldersBgMap
    { name: 'RecordHoldersSprites.map.jim', folder: 'NHL96/Graphics', start: 0x001ac3a0, end: 0x001ac7c6 }, // RecordHoldersSprites
    { name: 'PlayerStatsTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001ac7c6, end: 0x001acfe6 }, // PlayerStatsTitleMap
    { name: 'NameEntryTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001acfe6, end: 0x001ad7c6 }, // NameEntryTitleMap
    { name: 'NameEntryBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x001ad7c6, end: 0x001aeb94 }, // NameEntryBgMap
    { name: 'NameEntrySprites.map.jim', folder: 'NHL96/Graphics', start: 0x001aeb94, end: 0x001aef62 }, // NameEntrySprites
    { name: 'AwardsTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001aef62, end: 0x001af782 }, // AwardsTitleMap
    { name: 'AwardsBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x001af782, end: 0x001b11b0 }, // AwardsBgMap
    { name: 'AwardsSprites.map.jim', folder: 'NHL96/Graphics', start: 0x001b11b0, end: 0x001b14de }, // AwardsSprites
    { name: 'PresidentsPic.map.jim', folder: 'NHL96/Graphics', start: 0x001b14de, end: 0x001b1b34 }, // PresidentsPic
    { name: 'ArtRossPic.map.jim', folder: 'NHL96/Graphics', start: 0x001b1b34, end: 0x001b244a }, // ArtRossPic
    { name: 'NorrisPic.map.jim', folder: 'NHL96/Graphics', start: 0x001b244a, end: 0x001b2bc0 }, // NorrisPic
    { name: 'VezinaPic.map.jim', folder: 'NHL96/Graphics', start: 0x001b2bc0, end: 0x001b32b6 }, // VezinaPic
    { name: 'CampbellPic.map.jim', folder: 'NHL96/Graphics', start: 0x001b32b6, end: 0x001b3a0c }, // CampbellPic
    { name: 'WalesPic.map.jim', folder: 'NHL96/Graphics', start: 0x001b3a0c, end: 0x001b3f82 }, // WalesPic
    { name: 'HartPic.map.jim', folder: 'NHL96/Graphics', start: 0x001b3f82, end: 0x001b4538 }, // HartPic
    { name: 'ConnSmythePic.map.jim', folder: 'NHL96/Graphics', start: 0x001b4538, end: 0x001b4d4e }, // ConnSmythePic
    { name: 'PearsonPic.map.jim', folder: 'NHL96/Graphics', start: 0x001b4d4e, end: 0x001b53c4 }, // PearsonPic
    { name: 'PadIconMap1.map.jim', folder: 'NHL96/Graphics', start: 0x001b53c4, end: 0x001b5942 }, // PadIconMap1
    { name: 'PadIconMap2.map.jim', folder: 'NHL96/Graphics', start: 0x001b5942, end: 0x001b5ec0 }, // PadIconMap2
    { name: 'PadIconMap3.map.jim', folder: 'NHL96/Graphics', start: 0x001b5ec0, end: 0x001b643e }, // PadIconMap3
    { name: 'PadIconMap4.map.jim', folder: 'NHL96/Graphics', start: 0x001b643e, end: 0x001b69bc }, // PadIconMap4
    { name: 'PadCursorMap.map.jim', folder: 'NHL96/Graphics', start: 0x001b69bc, end: 0x001b6f3a }, // PadCursorMap
    { name: 'ControllerTitleMap.map.jim', folder: 'NHL96/Graphics', start: 0x001b6f3a, end: 0x001b773a }, // ControllerTitleMap
    { name: 'ControllerFrameMap.map.jim', folder: 'NHL96/Graphics', start: 0x001b773a, end: 0x001b89c8 }, // ControllerFrameMap
    { name: 'BigFontMap.map.jim', folder: 'NHL96/Graphics', start: 0x001b89c8, end: 0x001b9416 }, // BigFontMap
    { name: 'BigFontMap3.map.jim', folder: 'NHL96/Graphics', start: 0x001b9416, end: 0x001b9ed8 }, // BigFontMap3
    { name: 'DigitFontMap.map.jim', folder: 'NHL96/Graphics', start: 0x001b9ed8, end: 0x001ba4be }, // DigitFontMap
    { name: 'PauseRinkMap.map.jim', folder: 'NHL96/Graphics', start: 0x001ba4be, end: 0x001bbbec }, // PauseRinkMap
    { name: 'PauseBgBitmap.map.jim', folder: 'NHL96/Graphics', start: 0x001bbbec, end: 0x001bcbfa }, // PauseBgBitmap
    { name: 'PauseSprites.map.jim', folder: 'NHL96/Graphics', start: 0x001bcbfa, end: 0x001bcf78 }, // PauseSprites
    { name: 'FoxBannerMap.map.jim', folder: 'NHL96/Graphics', start: 0x001bcf78, end: 0x001bd5e6 }, // FoxBannerMap
    { name: 'HockeyNewsBannerMap.map.jim', folder: 'NHL96/Graphics', start: 0x001bd5e6, end: 0x001bdcd4 }, // HockeyNewsBannerMap
    { name: 'PlayoffTreeMap.map.jim', folder: 'NHL96/Graphics', start: 0x001bdcd4, end: 0x001c0302 }, // PlayoffTreeMap
    { name: 'PlayoffTreeBgMap.map.jim', folder: 'NHL96/Graphics', start: 0x001c0302, end: 0x001c4810 }, // PlayoffTreeBgMap
    { name: 'PlayoffTeamFrameMap.map.jim', folder: 'NHL96/Graphics', start: 0x001c4810, end: 0x001c4c4e }, // PlayoffTeamFrameMap
    { name: 'PuckAnimMap.map.jim', folder: 'NHL96/Graphics', start: 0x001c4c4e, end: 0x001c6c4c }, // PuckAnimMap
    { name: 'CupChampsMap.map.jim', folder: 'NHL96/Graphics', start: 0x001c6c4c, end: 0x001caefa }, // CupChampsMap
    { name: 'CupChampsMap2.map.jim', folder: 'NHL96/Graphics', start: 0x001caefa, end: 0x001ccba8 }, // CupChampsMap2
    { name: 'CupChampsPals.map.jim', folder: 'NHL96/Graphics', start: 0x001ccba8, end: 0x001ccee8 }, // CupChampsPals
    { name: 'unk_1CCEE8.map.jim', folder: 'NHL96/Graphics', start: 0x001ccee8, end: 0x001d5420 }, // unk_1CCEE8
    { name: 'unk_1D5420.map.jim', folder: 'NHL96/Graphics', start: 0x001d5420, end: 0x001d579e }, // unk_1D5420
    { name: 'revframetbl.map.jim', folder: 'NHL96/Graphics', start: 0x001d579e, end: 0x001d6622 }, // revframetbl
];
const outRoot = path.join(ROOT, 'Extracted');
const rom = fs.readFileSync(romPath);
const version = detectVersion(rom);
console.log('ROM: ' + version.label);
const markerPath = path.join(outRoot, '.extract-complete.json');
fs.rmSync(markerPath, { force: true });
const written = [];
for (const asset of assets) {
  const dir = path.join(outRoot, asset.folder);
  fs.mkdirSync(dir, { recursive: true });
  const data = rom.subarray(version.map(asset.start), version.map(asset.end - 1) + 1);
  fs.writeFileSync(path.join(dir, asset.name), data);
  written.push({ path: path.posix.join(asset.folder.replace(/\\/g, '/'), asset.name), size: data.length });
}
const sha1 = (b) => require('crypto').createHash('sha1').update(b).digest('hex');
fs.writeFileSync(markerPath, JSON.stringify({ rom: version.id, romSha1: sha1(rom), extractor: path.basename(__filename),
  extractorSha1: sha1(fs.readFileSync(__filename)), files: written }, null, 1) + '\n');
console.log('Extracted ' + assets.length + ' assets to ' + outRoot + '.');
