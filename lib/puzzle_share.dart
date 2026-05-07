/// Shared share-stack primitives across Brent's three puzzle games:
/// Ninjoku (sudoku), Pixdojo (picross), and Crowns (queens).
///
/// What's in here:
/// - [GridCodec]: 4-bit-per-cell deep-link codec with optional progress
/// - [EmojiGridSummary]: Wordle-style spoiler-safe N×3 grid renderer
/// - [ShareTextTemplate]: canonical share-text format
/// - [ShareUrlBuilder]: UTM-tagged URL builder
/// - [ShareLauncher]: native share / Twitter / LinkedIn / clipboard
/// - [ShareCardCanvas]: off-screen widget→PNG renderer
/// - [ShareChannelRow]: drop-in multi-channel button row
library puzzle_share;

export 'src/grid_codec.dart';
export 'src/emoji_grid.dart';
export 'src/share_text.dart';
export 'src/share_url.dart';
export 'src/share_launcher.dart';
export 'src/share_card_canvas.dart';
export 'src/share_channel_row.dart';
